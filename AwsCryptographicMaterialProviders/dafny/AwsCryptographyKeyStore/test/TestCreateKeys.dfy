// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../src/Index.dfy"
include "Fixtures.dfy"
include "../src/Structure.dfy"

module TestCreateKeys {
  import Types = AwsCryptographyKeyStoreTypes
  import ComAmazonawsKmsTypes
  import KMS = Com.Amazonaws.Kms
  import DDB = Com.Amazonaws.Dynamodb
  import KeyStore
  import opened Wrappers
  import opened Fixtures
  import Structure
  import UTF8

  method {:test} TestCreateBranchAndBeaconKeys()
  {
    var kmsClient :- expect KMS.KMSClient();
    var ddbClient :- expect DDB.DynamoDBClient();
    var kmsConfig := Types.KMSConfiguration.kmsKeyArn(keyArn);

    var keyStoreConfig := Types.KeyStoreConfig(
      id := None,
      kmsConfiguration := kmsConfig,
      logicalKeyStoreName := logicalKeyStoreName,
      grantTokens := None,
      ddbTableName := branchKeyStoreName,
      ddbClient := Some(ddbClient),
      kmsClient := Some(kmsClient)
    );

    var keyStore :- expect KeyStore.KeyStore(keyStoreConfig);

    var branchKeyId :- expect keyStore.CreateKey(Types.CreateKeyInput());

    var beaconKeyResult :- expect keyStore.GetBeaconKey(
      Types.GetBeaconKeyInput(
        branchKeyIdentifier := branchKeyId.branchKeyIdentifier
      ));

    var activeResult :- expect keyStore.GetActiveBranchKey(
      Types.GetActiveBranchKeyInput(
        branchKeyIdentifier := branchKeyId.branchKeyIdentifier
      ));

    var branchKeyVersion :- expect UTF8.Decode(activeResult.branchKeyMaterials.branchKeyVersion);
    var versionResult :- expect keyStore.GetBranchKeyVersion(
      Types.GetBranchKeyVersionInput(
        branchKeyIdentifier := branchKeyId.branchKeyIdentifier,
        branchKeyVersion := branchKeyVersion
      ));

    // Since this process uses a read DDB table,
    // the number of records will forever increase.
    // To avoid this, remove the items.

    DeleteItem(branchKeyId.branchKeyIdentifier, branchKeyVersion, ddbClient);

    expect beaconKeyResult.beaconKeyMaterials.beaconKey.Some?;
    expect |beaconKeyResult.beaconKeyMaterials.beaconKey.value| == 32;
    expect |activeResult.branchKeyMaterials.branchKey| == 32;
    expect versionResult.branchKeyMaterials.branchKey == activeResult.branchKeyMaterials.branchKey;
    expect versionResult.branchKeyMaterials.branchKeyVersion == activeResult.branchKeyMaterials.branchKeyVersion;
  }

  method DeleteItem(
    branchKeyIdentifier: string,
    branchKeyVersion: string,
    ddbClient: DDB.Types.IDynamoDBClient
  )
    requires ddbClient.ValidState()
    modifies ddbClient.Modifies
    ensures ddbClient.ValidState()
  {

    // This is a best effort to remove these items.
    var _ := ddbClient.DeleteItem(
      DDB.Types.DeleteItemInput(
        TableName := branchKeyStoreName,
        Key := map[
          Structure.BRANCH_KEY_IDENTIFIER_FIELD := DDB.Types.AttributeValue.S(branchKeyIdentifier),
          Structure.TYPE_FIELD := DDB.Types.AttributeValue.S(Structure.BRANCH_KEY_TYPE_PREFIX + branchKeyVersion)
        ],
        Expected := None,
        ConditionalOperator := None,
        ReturnValues := None,
        ReturnConsumedCapacity := None,
        ReturnItemCollectionMetrics := None,
        ConditionExpression := None,
        ExpressionAttributeNames := None,
        ExpressionAttributeValues := None

      )
    );

    var _ := ddbClient.DeleteItem(
      DDB.Types.DeleteItemInput(
        TableName := branchKeyStoreName,
        Key := map[
          Structure.BRANCH_KEY_IDENTIFIER_FIELD := DDB.Types.AttributeValue.S(branchKeyIdentifier),
          Structure.TYPE_FIELD := DDB.Types.AttributeValue.S(Structure.BRANCH_KEY_ACTIVE_TYPE)
        ],
        Expected := None,
        ConditionalOperator := None,
        ReturnValues := None,
        ReturnConsumedCapacity := None,
        ReturnItemCollectionMetrics := None,
        ConditionExpression := None,
        ExpressionAttributeNames := None,
        ExpressionAttributeValues := None

      )
    );

    var _ := ddbClient.DeleteItem(
      DDB.Types.DeleteItemInput(
        TableName := branchKeyStoreName,
        Key := map[
          Structure.BRANCH_KEY_IDENTIFIER_FIELD := DDB.Types.AttributeValue.S(branchKeyIdentifier),
          Structure.TYPE_FIELD := DDB.Types.AttributeValue.S(Structure.BEACON_KEY_TYPE_VALUE)
        ],
        Expected := None,
        ConditionalOperator := None,
        ReturnValues := None,
        ReturnConsumedCapacity := None,
        ReturnItemCollectionMetrics := None,
        ConditionExpression := None,
        ExpressionAttributeNames := None,
        ExpressionAttributeValues := None

      )
    );

  }

}
