// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../src/Index.dfy"
include "Fixtures.dfy"
include "../src/Structure.dfy"
include "CleanupItems.dfy"

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
  import CleanupItems
  import DDBKeystoreOperations

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
    CleanupItems.DeleteVersion(branchKeyId.branchKeyIdentifier, branchKeyVersion, ddbClient);
    CleanupItems.DeleteActive(branchKeyId.branchKeyIdentifier, ddbClient);

    expect beaconKeyResult.beaconKeyMaterials.beaconKey.Some?;
    expect |beaconKeyResult.beaconKeyMaterials.beaconKey.value| == 32;
    expect |activeResult.branchKeyMaterials.branchKey| == 32;
    expect versionResult.branchKeyMaterials.branchKey == activeResult.branchKeyMaterials.branchKey;
    expect versionResult.branchKeyMaterials.branchKeyVersion == activeResult.branchKeyMaterials.branchKeyVersion;
  }

  method {:test} InsertingADuplicateWillFail()
  {
    var ddbClient :- expect DDB.DynamoDBClient();

    var encryptionContext := Structure.DecryptOnlyBranchKeyEncryptionContext(
      branchKeyId,
      branchKeyIdActiveVersion,
      "",
      "",
      keyArn
    );

    var output := DDBKeystoreOperations.WriteNewKeyToStore(
      Structure.ToAttributeMap(encryptionContext, [1]),
      Structure.ToAttributeMap(Structure.ActiveBranchKeyEncryptionContext(encryptionContext), [2]),
      Structure.ToAttributeMap(Structure.BeaconKeyEncryptionContext(encryptionContext), [3]),
      branchKeyStoreName,
      ddbClient
    );

    expect output.Failure?;
  }

  method {:test} InsertingADuplicateWillWithADifferentVersionFail()
  {
    var ddbClient :- expect DDB.DynamoDBClient();

    var encryptionContext := Structure.DecryptOnlyBranchKeyEncryptionContext(
      branchKeyId,
      "!= branchKeyIdActiveVersion",
      "",
      "",
      keyArn
    );

    var output := DDBKeystoreOperations.WriteNewKeyToStore(
      Structure.ToAttributeMap(encryptionContext, [1]),
      Structure.ToAttributeMap(Structure.ActiveBranchKeyEncryptionContext(encryptionContext), [2]),
      Structure.ToAttributeMap(Structure.BeaconKeyEncryptionContext(encryptionContext), [3]),
      branchKeyStoreName,
      ddbClient
    );

    expect output.Failure?;
  }
}
