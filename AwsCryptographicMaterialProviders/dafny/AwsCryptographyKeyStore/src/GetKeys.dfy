// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../Model/AwsCryptographyKeyStoreTypes.dfy"
include "Structure.dfy"
include "DDBKeystoreOperations.dfy"
include "KMSKeystoreOperations.dfy"

module GetKeys {
  import opened StandardLibrary
  import opened Wrappers
  import opened Seq

  import Structure
  import KMSKeystoreOperations
  import DDBKeystoreOperations

  import Types = AwsCryptographyKeyStoreTypes
  import DDB = ComAmazonawsDynamodbTypes
  import KMS = ComAmazonawsKmsTypes

  method GetActiveKeyAndUnwrap(
    input: Types.GetActiveBranchKeyInput,
    tableName: DDB.TableName,
    logicalKeyStoreName: string,
    kmsConfiguration: Types.KMSConfiguration,
    grantTokens: KMS.GrantTokenList,
    kmsClient: KMS.IKMSClient,
    ddbClient: DDB.IDynamoDBClient
  )
    returns (output: Result<Types.GetActiveBranchKeyOutput, Types.Error>)
    requires kmsClient.ValidState() && ddbClient.ValidState()
    modifies ddbClient.Modifies, kmsClient.Modifies
    ensures ddbClient.ValidState() && kmsClient.ValidState()

    ensures output.Success? ==>
              input.branchKeyIdentifier == output.value.branchKeyMaterials.branchKeyIdentifier
  {

    var branchKeyItem :- DDBKeystoreOperations.GetActiveBranchKeyItem(
      input.branchKeyIdentifier,
      tableName,
      ddbClient
    );

    var encryptionContext := Structure.ToBranchKeyContext(branchKeyItem, logicalKeyStoreName);

    :- Need(
      KMSKeystoreOperations.AttemptKmsOperation?(kmsConfiguration, encryptionContext),
      Types.KeyStoreException( message := "AWS KMS Key ARN does not match configured value")
    );

    var branchKey :- KMSKeystoreOperations.DecryptKey(
      encryptionContext,
      branchKeyItem,
      kmsConfiguration,
      grantTokens,
      kmsClient
    );

    var branchKeyMaterials :- Structure.ToBranchKeyMaterials(
      encryptionContext,
      branchKey.Plaintext.value
    );

    return Success(Types.GetActiveBranchKeyOutput(
                     branchKeyMaterials := branchKeyMaterials
                   ));

  }

  method GetBranchKeyVersion(
    input: Types.GetBranchKeyVersionInput,
    tableName: DDB.TableName,
    logicalKeyStoreName: string,
    kmsConfiguration: Types.KMSConfiguration,
    grantTokens: KMS.GrantTokenList,
    kmsClient: KMS.IKMSClient,
    ddbClient: DDB.IDynamoDBClient
  )
    returns (output: Result<Types.GetBranchKeyVersionOutput, Types.Error>)
    requires kmsClient.ValidState() && ddbClient.ValidState()
    modifies ddbClient.Modifies, kmsClient.Modifies
    ensures ddbClient.ValidState() && kmsClient.ValidState()
    ensures output.Success? ==>
              && input.branchKeyIdentifier == output.value.branchKeyMaterials.branchKeyIdentifier
    // && TODO add version info
  {

    var branchKeyItem :- DDBKeystoreOperations.GetVersionBranchKeyItem(
      input.branchKeyIdentifier,
      input.branchKeyVersion,
      tableName,
      ddbClient
    );

    var encryptionContext := Structure.ToBranchKeyContext(branchKeyItem, logicalKeyStoreName);

    :- Need(
      KMSKeystoreOperations.AttemptKmsOperation?(kmsConfiguration, encryptionContext),
      Types.KeyStoreException( message := "AWS KMS Key ARN does not match configured value")
    );

    var branchKey :- KMSKeystoreOperations.DecryptKey(
      encryptionContext,
      branchKeyItem,
      kmsConfiguration,
      grantTokens,
      kmsClient
    );

    var branchKeyMaterials :- Structure.ToBranchKeyMaterials(
      encryptionContext,
      branchKey.Plaintext.value
    );

    return Success(Types.GetBranchKeyVersionOutput(
                     branchKeyMaterials := branchKeyMaterials
                   ));
  }

  method GetBeaconKeyAndUnwrap(
    input: Types.GetBeaconKeyInput,
    tableName: DDB.TableName,
    logicalKeyStoreName: string,
    kmsConfiguration: Types.KMSConfiguration,
    grantTokens: KMS.GrantTokenList,
    kmsClient: KMS.IKMSClient,
    ddbClient: DDB.IDynamoDBClient
  )
    returns (output: Result<Types.GetBeaconKeyOutput, Types.Error>)
    requires kmsClient.ValidState() && ddbClient.ValidState()
    modifies ddbClient.Modifies, kmsClient.Modifies
    ensures ddbClient.ValidState() && kmsClient.ValidState()
    ensures output.Success? ==>
              && input.branchKeyIdentifier == output.value.beaconKeyMaterials.beaconKeyIdentifier
  {
    var branchKeyItem :- DDBKeystoreOperations.GetBeaconKeyItem(
      input.branchKeyIdentifier,
      tableName,
      ddbClient
    );

    var encryptionContext := Structure.ToBranchKeyContext(branchKeyItem, logicalKeyStoreName);

    :- Need(
      KMSKeystoreOperations.AttemptKmsOperation?(kmsConfiguration, encryptionContext),
      Types.KeyStoreException( message := "AWS KMS Key ARN does not match configured value")
    );

    var branchKey :- KMSKeystoreOperations.DecryptKey(
      encryptionContext,
      branchKeyItem,
      kmsConfiguration,
      grantTokens,
      kmsClient
    );

    var branchKeyMaterials :- Structure.ToBeaconKeyMaterials(
      encryptionContext,
      branchKey.Plaintext.value
    );

    return Success(Types.GetBeaconKeyOutput(
                     beaconKeyMaterials := branchKeyMaterials
                   ));
  }

}
