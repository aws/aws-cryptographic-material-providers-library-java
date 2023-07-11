// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../Model/AwsCryptographyKeyStoreTypes.dfy"
include "Structure.dfy"
include "DDBKeystoreOperations.dfy"
include "KMSKeystoreOperations.dfy"

module CreateKeys {
  import opened StandardLibrary
  import opened Wrappers

  import Structure
  import KMSKeystoreOperations
  import DDBKeystoreOperations

  import opened Seq
  import opened UInt = StandardLibrary.UInt
  import Types = AwsCryptographyKeyStoreTypes
  import DDB = ComAmazonawsDynamodbTypes
  import KMS = ComAmazonawsKmsTypes
  import UUID
  import Time

  method CreateBranchAndBeaconKeys(
    branchKeyId: string,
    ddbTableName: DDB.TableName,
    logicalKeyStoreName: string,
    kmsConfiguration: Types.KMSConfiguration,
    grantTokens: KMS.GrantTokenList,
    kmsClient: KMS.IKMSClient,
    ddbClient: DDB.IDynamoDBClient
  )
    returns (res: Result<Types.CreateKeyOutput, Types.Error>)
    requires 0 < |branchKeyId|
    requires kmsClient.ValidState() && ddbClient.ValidState()
    modifies ddbClient.Modifies, kmsClient.Modifies
    ensures ddbClient.ValidState() && kmsClient.ValidState()
  {
    //= aws-encryption-sdk-specification/framework/key-store.md#wrapped-branch-key-creation
    //# - `timestamp`: a timestamp for the current time.
    //# This timestamp MUST be in ISO8601 format in UTC, to microsecond precision (e.g. “YYYY-MM-DDTHH:mm:ss.ssssssZ“)
    var timestamp :- Time.GetCurrentTimeStamp()
    .MapFailure(e => Types.KeyStoreException(message := e));

    var maybeBranchKeyVersion := UUID.GenerateUUID();
    //= aws-encryption-sdk-specification/framework/key-store.md#wrapped-branch-key-creation
    //# - `version`: a new guid. This guid MUST be [version 4 UUID](https://www.ietf.org/rfc/rfc4122.txt)
    var branchKeyVersion :- maybeBranchKeyVersion
    .MapFailure(e => Types.KeyStoreException(message := e));

    var decryptOnlyEncryptionContext := Structure.DecryptOnlyBranchKeyEncryptionContext(
      branchKeyId,
      branchKeyVersion,
      timestamp,
      logicalKeyStoreName,
      kmsConfiguration.kmsKeyArn
    );
    var activeEncryptionContext := Structure.ActiveBranchKeyEncryptionContext(decryptOnlyEncryptionContext);
    var beaconEncryptionContext := Structure.BeaconKeyEncryptionContext(decryptOnlyEncryptionContext);

    var wrappedDecryptOnlyBranchKey :- KMSKeystoreOperations.GenerateKey(
      decryptOnlyEncryptionContext,
      kmsConfiguration,
      grantTokens,
      kmsClient
    );
    var wrappedActiveBranchKey :- KMSKeystoreOperations.GenerateKey(
      activeEncryptionContext,
      kmsConfiguration,
      grantTokens,
      kmsClient
    );
    var wrappedBeaconKey :- KMSKeystoreOperations.GenerateKey(
      beaconEncryptionContext,
      kmsConfiguration,
      grantTokens,
      kmsClient
    );

    var decryptOnlyBranchKeyItem: Structure.VersionBranchKeyItem := Structure.ToAttributeMap(
      decryptOnlyEncryptionContext,
      wrappedDecryptOnlyBranchKey.CiphertextBlob.value
    );
    var activeBranchKeyItem: Structure.ActiveBranchKeyItem := Structure.ToAttributeMap(
      activeEncryptionContext,
      wrappedActiveBranchKey.CiphertextBlob.value
    );
    var beaconKeyItem := Structure.ToAttributeMap(
      beaconEncryptionContext,
      wrappedBeaconKey.CiphertextBlob.value
    );

    var _ :- DDBKeystoreOperations.WriteNewKeyToStore(
      decryptOnlyBranchKeyItem,
      activeBranchKeyItem,
      beaconKeyItem,
      ddbTableName,
      ddbClient
    );

    res := Success(Types.CreateKeyOutput(
                     branchKeyIdentifier := branchKeyId
                   ));
  }

  method VersionActiveBranchKey(
    input: Types.VersionKeyInput,
    ddbTableName: DDB.TableName,
    logicalKeyStoreName: string,
    kmsConfiguration: Types.KMSConfiguration,
    grantTokens: KMS.GrantTokenList,
    kmsClient: KMS.IKMSClient,
    ddbClient: DDB.IDynamoDBClient
  )
    returns (res: Result<(), Types.Error>)
    requires 0 < |input.branchKeyIdentifier|
    requires kmsClient.ValidState() && ddbClient.ValidState()
    modifies ddbClient.Modifies, kmsClient.Modifies
    ensures ddbClient.ValidState() && kmsClient.ValidState()
  {

    var timestamp :- Time.GetCurrentTimeStamp()
    .MapFailure(e => Types.KeyStoreException(message := e));

    var maybeBranchKeyVersion := UUID.GenerateUUID();
    var branchKeyVersion :- maybeBranchKeyVersion
    .MapFailure(e => Types.KeyStoreException(message := e));

    var decryptOnlyEncryptionContext := Structure.DecryptOnlyBranchKeyEncryptionContext(
      input.branchKeyIdentifier,
      branchKeyVersion,
      timestamp,
      logicalKeyStoreName,
      kmsConfiguration.kmsKeyArn
    );
    var activeEncryptionContext := Structure.ActiveBranchKeyEncryptionContext(decryptOnlyEncryptionContext);

    var wrappedDecryptOnlyBranchKey :- KMSKeystoreOperations.GenerateKey(
      decryptOnlyEncryptionContext,
      kmsConfiguration,
      grantTokens,
      kmsClient
    );
    var wrappedActiveBranchKey :- KMSKeystoreOperations.GenerateKey(
      activeEncryptionContext,
      kmsConfiguration,
      grantTokens,
      kmsClient
    );

    var decryptOnlyBranchKeyItem: Structure.VersionBranchKeyItem := Structure.ToAttributeMap(
      decryptOnlyEncryptionContext,
      wrappedDecryptOnlyBranchKey.CiphertextBlob.value
    );
    var activeBranchKeyItem: Structure.ActiveBranchKeyItem := Structure.ToAttributeMap(
      activeEncryptionContext,
      wrappedActiveBranchKey.CiphertextBlob.value
    );

    var _ :- DDBKeystoreOperations.WriteNewBranchKeyVersionToKeystore(
      decryptOnlyBranchKeyItem,
      activeBranchKeyItem,
      ddbTableName,
      ddbClient
    );

    res := Success(());
  }

}
