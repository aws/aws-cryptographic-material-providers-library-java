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

  method WriteNewKeyToStore(
    versionBranchKeyItem: Structure.VersionBranchKeyItem,
    activeBranchKeyItem: Structure.ActiveBranchKeyItem,
    beaconKeyItem: Structure.BeaconKeyItem,
    tableName: DDB.TableName,
    ddbClient: DDB.IDynamoDBClient
  )
    returns (res: Result<DDB.TransactWriteItemsOutput, Types.Error>)
    requires
      && activeBranchKeyItem[Structure.BRANCH_KEY_IDENTIFIER_FIELD] == versionBranchKeyItem[Structure.BRANCH_KEY_IDENTIFIER_FIELD] == beaconKeyItem[Structure.BRANCH_KEY_IDENTIFIER_FIELD]
      && activeBranchKeyItem[Structure.BRANCH_KEY_ACTIVE_VERSION_FIELD] == versionBranchKeyItem[Structure.TYPE_FIELD]
    requires ddbClient.ValidState()
    modifies ddbClient.Modifies
    ensures ddbClient.ValidState()
  // {
  //   var branchKeyDDBMap := ToBranchKeyItemAttributeMap(branchKeyContext, wrappedBranchKey);
  //   var branchKeyTransactWriteItem := CreateTransactWritePutItem(branchKeyDDBMap, tableName);

  //   var beaconKeyDDBMap := ToBranchKeyItemAttributeMap(beaconKeyContext, wrappedBeaconKey);
  //   var beaconKeyTransactWriteItem := CreateTransactWritePutItem(beaconKeyDDBMap, tableName);

  //   :- Need(
  //     // In order to be certain we are writing something that is well formed
  //     // and something we will be able to get or query we need to ensure it has certain properties
  //     && validBeaconKeyItem?(beaconKeyDDBMap)
  //     && validActiveBranchKey?(branchKeyDDBMap),
  //     Types.KeyStoreException(message := "Unable to write key material to Key Store: " + tableName)
  //   );

  //   var items: DDB.TransactWriteItemList := [
  //     branchKeyTransactWriteItem,
  //     beaconKeyTransactWriteItem
  //   ];

  //   var transactRequest := DDB.TransactWriteItemsInput(
  //     TransactItems := items,
  //     ReturnConsumedCapacity := None,
  //     ReturnItemCollectionMetrics := None,
  //     ClientRequestToken := None
  //   );

  //   var maybeTransactWriteResponse := ddbClient.TransactWriteItems(transactRequest);
  //   var transactWriteItemsResponse :- maybeTransactWriteResponse
  //   .MapFailure(e => Types.ComAmazonawsDynamodb(ComAmazonawsDynamodb := e));

  //   res := Success(transactWriteItemsResponse);
  // }


  method WriteNewBranchKeyVersionToKeystore(
    versionBranchKeyItem: Structure.VersionBranchKeyItem,
    activeBranchKeyItem: Structure.ActiveBranchKeyItem,
    tableName: DDB.TableName,
    ddbClient: DDB.IDynamoDBClient
  )
    returns (res: Result<DDB.TransactWriteItemsOutput, Types.Error>)
    requires
      && activeBranchKeyItem[Structure.BRANCH_KEY_IDENTIFIER_FIELD] == versionBranchKeyItem[Structure.BRANCH_KEY_IDENTIFIER_FIELD]
      && activeBranchKeyItem[Structure.BRANCH_KEY_ACTIVE_VERSION_FIELD] == versionBranchKeyItem[Structure.TYPE_FIELD]
    requires ddbClient.ValidState()
    modifies ddbClient.Modifies
    ensures ddbClient.ValidState()
  // {
  // var decryptOnlyBranchKeyTransactWriteItem := CreateTransactWritePutItem(decryptOnlyBranchKey, tableName);
  // var newActiveBranchKeyTransactWriteItem := CreateTransactWritePutItem(newActiveBranchKey, tableName);

  // :- Need(
  //   // In order to be certain we are writing something that is well formed
  //   // and something we will be able to get or query we need to ensure it has certain properties
  //   && validActiveBranchKey?(newActiveBranchKey)
  //   && validVersionBranchKey?(decryptOnlyBranchKey),
  //   Types.KeyStoreException(message := "Unable to write key material to Key Store: " + tableName)
  // );

  // var items: DDB.TransactWriteItemList := [
  //   decryptOnlyBranchKeyTransactWriteItem,
  //   newActiveBranchKeyTransactWriteItem
  // ];

  // var transactRequest := DDB.TransactWriteItemsInput(
  //   TransactItems := items,
  //   ReturnConsumedCapacity := None,
  //   ReturnItemCollectionMetrics := None,
  //   ClientRequestToken := None
  // );

  // var maybeTransactWriteResponse := ddbClient.TransactWriteItems(transactRequest);
  // var transactWriteItemsResponse :- maybeTransactWriteResponse
  // .MapFailure(e => Types.ComAmazonawsDynamodb(ComAmazonawsDynamodb := e));

  // res := Success(transactWriteItemsResponse);
  // }


  method GetActiveBranchKeyItem(
    branchKeyIdentifier: string,
    tableName: DDB.TableName,
    ddbClient: DDB.IDynamoDBClient
  )
    returns (res: Result<Structure.ActiveBranchKeyItem, Types.Error>)
    requires DDB.IsValid_TableName(tableName)
    requires ddbClient.ValidState()
    modifies ddbClient.Modifies
    ensures ddbClient.ValidState()

  method GetVersionBranchKeyItem(
    branchKeyIdentifier: string,
    branchKeyVersion: string,
    tableName: DDB.TableName,
    ddbClient: DDB.IDynamoDBClient
  )
    returns (res: Result<Structure.VersionBranchKeyItem, Types.Error>)
    requires DDB.IsValid_TableName(tableName)
    requires ddbClient.ValidState()
    modifies ddbClient.Modifies
    ensures ddbClient.ValidState()

  method GetBeaconKeyItem(
    branchKeyIdentifier: string,
    tableName: DDB.TableName,
    ddbClient: DDB.IDynamoDBClient
  )
    returns (res: Result<Structure.BeaconKeyItem, Types.Error>)
    requires DDB.IsValid_TableName(tableName)
    requires ddbClient.ValidState()
    modifies ddbClient.Modifies
    ensures ddbClient.ValidState()

}