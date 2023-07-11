include "../Model/AwsCryptographyKeyStoreTypes.dfy"
include "Structure.dfy"

module DDBKeystoreOperations {
  import opened Wrappers
  import opened UInt = StandardLibrary.UInt
  import Seq
  import Types = AwsCryptographyKeyStoreTypes
  import DDB = ComAmazonawsDynamodbTypes
  import UTF8
  import Structure

  const BRANCH_KEY_NOT_EXIST := "attribute_not_exists(" + Structure.BRANCH_KEY_IDENTIFIER_FIELD + ")"
  const BRANCH_KEY_EXISTS := "attribute_exists(" + Structure.BRANCH_KEY_IDENTIFIER_FIELD + ")"

  method WriteNewKeyToStore(
    versionBranchKeyItem: Structure.VersionBranchKeyItem,
    activeBranchKeyItem: Structure.ActiveBranchKeyItem,
    beaconKeyItem: Structure.BeaconKeyItem,
    tableName: DDB.TableName,
    ddbClient: DDB.IDynamoDBClient
  )
    returns (output: Result<DDB.TransactWriteItemsOutput, Types.Error>)
    requires
      && activeBranchKeyItem[Structure.BRANCH_KEY_IDENTIFIER_FIELD]
      == versionBranchKeyItem[Structure.BRANCH_KEY_IDENTIFIER_FIELD]
      == beaconKeyItem[Structure.BRANCH_KEY_IDENTIFIER_FIELD]
      && activeBranchKeyItem[Structure.BRANCH_KEY_ACTIVE_VERSION_FIELD] == versionBranchKeyItem[Structure.TYPE_FIELD]
    requires ddbClient.ValidState()
    modifies ddbClient.Modifies
    ensures ddbClient.ValidState()
  {
    var items: DDB.TransactWriteItemList := [
      CreateTransactWritePutItem(versionBranchKeyItem, tableName, Some(BRANCH_KEY_NOT_EXIST)),
      CreateTransactWritePutItem(activeBranchKeyItem, tableName, Some(BRANCH_KEY_NOT_EXIST)),
      CreateTransactWritePutItem(beaconKeyItem, tableName, Some(BRANCH_KEY_NOT_EXIST))
    ];

    var transactRequest := DDB.TransactWriteItemsInput(
      TransactItems := items,
      ReturnConsumedCapacity := None,
      ReturnItemCollectionMetrics := None,
      ClientRequestToken := None
    );

    var maybeTransactWriteResponse := ddbClient.TransactWriteItems(transactRequest);
    var transactWriteItemsResponse :- maybeTransactWriteResponse
    .MapFailure(e => Types.ComAmazonawsDynamodb(ComAmazonawsDynamodb := e));

    output := Success(transactWriteItemsResponse);
  }

  method WriteNewBranchKeyVersionToKeystore(
    versionBranchKeyItem: Structure.VersionBranchKeyItem,
    activeBranchKeyItem: Structure.ActiveBranchKeyItem,
    tableName: DDB.TableName,
    ddbClient: DDB.IDynamoDBClient
  )
    returns (output: Result<DDB.TransactWriteItemsOutput, Types.Error>)
    requires
      && activeBranchKeyItem[Structure.BRANCH_KEY_IDENTIFIER_FIELD] == versionBranchKeyItem[Structure.BRANCH_KEY_IDENTIFIER_FIELD]
      && activeBranchKeyItem[Structure.BRANCH_KEY_ACTIVE_VERSION_FIELD] == versionBranchKeyItem[Structure.TYPE_FIELD]
    requires ddbClient.ValidState()
    modifies ddbClient.Modifies
    ensures ddbClient.ValidState()
  {
    var items: DDB.TransactWriteItemList := [
      CreateTransactWritePutItem(versionBranchKeyItem, tableName, Some(BRANCH_KEY_EXISTS)),
      CreateTransactWritePutItem(activeBranchKeyItem, tableName, Some(BRANCH_KEY_NOT_EXIST))
    ];

    var transactRequest := DDB.TransactWriteItemsInput(
      TransactItems := items,
      ReturnConsumedCapacity := None,
      ReturnItemCollectionMetrics := None,
      ClientRequestToken := None
    );

    var maybeTransactWriteResponse := ddbClient.TransactWriteItems(transactRequest);
    var transactWriteItemsResponse :- maybeTransactWriteResponse
    .MapFailure(e => Types.ComAmazonawsDynamodb(ComAmazonawsDynamodb := e));

    output := Success(transactWriteItemsResponse);
  }


  method GetActiveBranchKeyItem(
    branchKeyIdentifier: string,
    tableName: DDB.TableName,
    ddbClient: DDB.IDynamoDBClient
  )
    returns (output: Result<Structure.ActiveBranchKeyItem, Types.Error>)
    requires DDB.IsValid_TableName(tableName)
    requires ddbClient.ValidState()
    modifies ddbClient.Modifies
    ensures ddbClient.ValidState()
    ensures output.Success?
            ==>
              && output.value[Structure.BRANCH_KEY_IDENTIFIER_FIELD].S == branchKeyIdentifier
  {
    var dynamoDbKey: DDB.Key := map[
      Structure.BRANCH_KEY_IDENTIFIER_FIELD := DDB.AttributeValue.S(branchKeyIdentifier),
      Structure.TYPE_FIELD := DDB.AttributeValue.S(Structure.BRANCH_KEY_ACTIVE_TYPE)
    ];
    var ItemRequest := DDB.GetItemInput(
      Key := dynamoDbKey,
      TableName := tableName,
      AttributesToGet := None,
      ConsistentRead :=  None,
      ReturnConsumedCapacity := None,
      ProjectionExpression := None,
      ExpressionAttributeNames := None
    );

    var maybeGetItem := ddbClient.GetItem(ItemRequest);
    var getItemResponse :- maybeGetItem
    .MapFailure(e => Types.ComAmazonawsDynamodb(ComAmazonawsDynamodb := e));

    :- Need(
      getItemResponse.Item.Some?,
      Types.KeyStoreException( message := "No item found for corresponding branch key identifier.")
    );

    :- Need(
      && Structure.ActiveBranchKeyItem?(getItemResponse.Item.value)
      && getItemResponse.Item.value[Structure.BRANCH_KEY_IDENTIFIER_FIELD].S == branchKeyIdentifier,
      Types.KeyStoreException( message := "Item found is not a valid active branch key.")
    );

    output := Success(getItemResponse.Item.value);
  }

  method GetVersionBranchKeyItem(
    branchKeyIdentifier: string,
    branchKeyVersion: string,
    tableName: DDB.TableName,
    ddbClient: DDB.IDynamoDBClient
  )
    returns (output: Result<Structure.VersionBranchKeyItem, Types.Error>)
    requires DDB.IsValid_TableName(tableName)
    requires ddbClient.ValidState()
    modifies ddbClient.Modifies
    ensures ddbClient.ValidState()
    ensures output.Success?
            ==>
              && output.value[Structure.BRANCH_KEY_IDENTIFIER_FIELD].S == branchKeyIdentifier
              && output.value[Structure.TYPE_FIELD].S == Structure.BRANCH_KEY_TYPE_PREFIX + branchKeyVersion
  {
    var dynamoDbKey: DDB.Key := map[
      Structure.BRANCH_KEY_IDENTIFIER_FIELD := DDB.AttributeValue.S(branchKeyIdentifier),
      Structure.TYPE_FIELD := DDB.AttributeValue.S(Structure.BRANCH_KEY_TYPE_PREFIX + branchKeyVersion)
    ];
    var ItemRequest := DDB.GetItemInput(
      Key := dynamoDbKey,
      TableName := tableName,
      AttributesToGet := None,
      ConsistentRead :=  None,
      ReturnConsumedCapacity := None,
      ProjectionExpression := None,
      ExpressionAttributeNames := None
    );

    var maybeGetItem := ddbClient.GetItem(ItemRequest);
    var getItemResponse :- maybeGetItem
    .MapFailure(e => Types.ComAmazonawsDynamodb(ComAmazonawsDynamodb := e));

    :- Need(
      getItemResponse.Item.Some?,
      Types.KeyStoreException( message := "No item found for corresponding branch key identifier.")
    );

    :- Need(
      && Structure.VersionBranchKeyItem?(getItemResponse.Item.value)
      && getItemResponse.Item.value[Structure.BRANCH_KEY_IDENTIFIER_FIELD].S == branchKeyIdentifier
      && getItemResponse.Item.value[Structure.TYPE_FIELD].S == Structure.BRANCH_KEY_TYPE_PREFIX + branchKeyVersion,
      Types.KeyStoreException( message := "Item found is not a valid branch key version.")
    );

    output := Success(getItemResponse.Item.value);
  }

  method GetBeaconKeyItem(
    branchKeyIdentifier: string,
    tableName: DDB.TableName,
    ddbClient: DDB.IDynamoDBClient
  )
    returns (output: Result<Structure.BeaconKeyItem, Types.Error>)
    requires DDB.IsValid_TableName(tableName)
    requires ddbClient.ValidState()
    modifies ddbClient.Modifies
    ensures ddbClient.ValidState()
    ensures output.Success?
            ==>
              output.value[Structure.BRANCH_KEY_IDENTIFIER_FIELD].S == branchKeyIdentifier
  {
    var dynamoDbKey: DDB.Key := map[
      Structure.BRANCH_KEY_IDENTIFIER_FIELD := DDB.AttributeValue.S(branchKeyIdentifier),
      Structure.TYPE_FIELD := DDB.AttributeValue.S(Structure.BEACON_KEY_TYPE_VALUE)
    ];
    var ItemRequest := DDB.GetItemInput(
      Key := dynamoDbKey,
      TableName := tableName,
      AttributesToGet := None,
      ConsistentRead :=  None,
      ReturnConsumedCapacity := None,
      ProjectionExpression := None,
      ExpressionAttributeNames := None
    );

    var maybeGetItem := ddbClient.GetItem(ItemRequest);
    var getItemResponse :- maybeGetItem
    .MapFailure(e => Types.ComAmazonawsDynamodb(ComAmazonawsDynamodb := e));

    :- Need(
      getItemResponse.Item.Some?,
      Types.KeyStoreException( message := "No item found for corresponding branch key identifier.")
    );

    :- Need(
      && Structure.BeaconKeyItem?(getItemResponse.Item.value)
      && getItemResponse.Item.value[Structure.BRANCH_KEY_IDENTIFIER_FIELD].S == branchKeyIdentifier,
      Types.KeyStoreException( message := "Item found is not a valid beacon key.")
    );

    output := Success(getItemResponse.Item.value);
  }

  function method CreateTransactWritePutItem(
    item: DDB.AttributeMap,
    tableName: DDB.TableName,
    ConditionExpression: Option<DDB.ConditionExpression> := None
  ): (output: DDB.TransactWriteItem)
  {
    DDB.TransactWriteItem(
      ConditionCheck := None,
      Put := Some(DDB.Put(
                    Item := item,
                    TableName := tableName,
                    ConditionExpression := ConditionExpression,
                    ExpressionAttributeNames := None,
                    ExpressionAttributeValues := None,
                    ReturnValuesOnConditionCheckFailure := None)),
      Delete := None,
      Update := None
    )
  }

}
