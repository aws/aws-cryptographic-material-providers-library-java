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
  import UTF8

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
    requires ddbClient.Modifies !! kmsClient.Modifies

    requires kmsClient.ValidState() && ddbClient.ValidState()
    modifies ddbClient.Modifies, kmsClient.Modifies
    ensures ddbClient.ValidState() && kmsClient.ValidState()

    ensures
      //= aws-encryption-sdk-specification/framework/branch-key-store.md#getactivebranchkey
      //= type=implication
      //# To get the active version for the branch key id from the keystore
      //# this operation MUST call AWS DDB `GetItem`
      //# using the `branch-key-id` as the Partition Key and `"branch:ACTIVE"` value as the Sort Key.
      && |ddbClient.History.GetItem| == |old(ddbClient.History.GetItem)| + 1
      && Seq.Last(ddbClient.History.GetItem).input.Key
         == map[
              Structure.BRANCH_KEY_IDENTIFIER_FIELD := DDB.AttributeValue.S(input.branchKeyIdentifier),
              Structure.TYPE_FIELD := DDB.AttributeValue.S(Structure.BRANCH_KEY_ACTIVE_TYPE)
            ]

    ensures output.Success?
            ==>

              && Seq.Last(ddbClient.History.GetItem).output.Success?
              && Seq.Last(ddbClient.History.GetItem).output.value.Item.Some?
              && var activeItem := Seq.Last(ddbClient.History.GetItem).output.value.Item.value;

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#getactivebranchkey
              //= type=implication
              //# The AWS DDB response MUST contain the fields defined in the [branch keystore record format](#record-format).
              && Structure.BranchKeyItem?(activeItem)
              && activeItem[Structure.HIERARCHY_VERSION].N?
              && Structure.BRANCH_KEY_ACTIVE_VERSION_FIELD in activeItem

              && KMSKeystoreOperations.AttemptKmsOperation?(kmsConfiguration, Structure.ToBranchKeyContext(activeItem, logicalKeyStoreName))

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#getactivebranchkey
              //= type=implication
              //# The operation MUST decrypt the branch key according to the [AWS KMS Branch Key Decryption](#aws-kms-branch-key-decryption) section.

              && var versionEncryptionContext := Structure.ToBranchKeyContext(activeItem, logicalKeyStoreName);

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# Every key in the constructed [encryption context](#encryption-context)
              //# except `tableName`
              //# MUST exist as a string attribute in the AWS DDB response item.
              && versionEncryptionContext.Keys - {Structure.TABLE_FIELD} < activeItem.Keys

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# Every value in the constructed [encryption context](#encryption-context)
              //# except the logical table name
              //# MUST equal the value with the same key in the AWS DDB response item.
              && (forall k <- versionEncryptionContext.Keys - {Structure.TABLE_FIELD}
                    :: match k
                       case HIERARCHY_VERSION => versionEncryptionContext[Structure.HIERARCHY_VERSION] == activeItem[Structure.HIERARCHY_VERSION].N
                       case _ => versionEncryptionContext[k] == activeItem[k].S)

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# The key `enc` MUST NOT exist in the constructed [encryption context](#encryption-context).
              && Structure.BRANCH_KEY_FIELD !in  versionEncryptionContext

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# The operation MUST use the configured `KMS SDK Client` to decrypt the value of the branch key field.
              && |kmsClient.History.Decrypt| == |old(kmsClient.History.Decrypt)| + 1

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# When calling [AWS KMS Decrypt](https://docs.aws.amazon.com/kms/latest/APIReference/API_Decrypt.html),
              //# the keystore operation MUST call with a request constructed as follows:
              && var decryptRequest := Seq.Last(kmsClient.History.Decrypt).input;

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# - `KeyId` MUST be the configured `AWS KMS Key ARN` in the [AWS KMS Configuration](#aws-kms-configuration) for this keystore
              && decryptRequest.KeyId == Some(kmsConfiguration.kmsKeyArn)

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# - `CiphertextBlob` MUST be the `enc` attribute value on the AWS DDB response item
              && decryptRequest.CiphertextBlob == activeItem[Structure.BRANCH_KEY_FIELD].B

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# Every attribute except for `enc` on the AWS DDB response item
              //# MUST be authenticated in the decryption of `enc`

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# - `EncryptionContext` MUST be the [encryption context](#encryption-context) constructed above
              && decryptRequest.EncryptionContext == Some(versionEncryptionContext)

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# - `GrantTokens` MUST be this keystore's [grant tokens](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#grant_token).
              && decryptRequest.GrantTokens == Some(grantTokens)

              && Seq.Last(kmsClient.History.Decrypt).output.Success?
              && Seq.Last(kmsClient.History.Decrypt).output.value.Plaintext.Some?
              && var decryptResponse := Seq.Last(kmsClient.History.Decrypt).output.value;

              && Structure.ToBranchKeyMaterials(versionEncryptionContext, decryptResponse.Plaintext.value).Success?

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#getactivebranchkey
              //= type=implication
              //# This GetActiveBranchKey MUST construct [beacon key materials](./structures.md#beacon-key-materials)
              //# according to [Branch Key Materials From Authenticated Encryption Context](#branch-key-materials-from-authenticated-encryption-context).
              && var branchKeyMaterials :=  Structure.ToBranchKeyMaterials(
                                              versionEncryptionContext,
                                              decryptResponse.Plaintext.value
                                            ).value;

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#getactivebranchkey
              //= type=implication
              //# This operation MUST return the constructed [branch key materials](./structures.md#branch-key-materials).
              && output.value.branchKeyMaterials == branchKeyMaterials

              && output.value.branchKeyMaterials.branchKeyIdentifier == input.branchKeyIdentifier

    ensures
      //= aws-encryption-sdk-specification/framework/branch-key-store.md#getactivebranchkey
      //= type=implication
      //# If the record does not contain the defined fields, this operation MUST fail.
      || (&& |ddbClient.History.GetItem| == |old(ddbClient.History.GetItem)| + 1
          && Seq.Last(ddbClient.History.GetItem).output.Success?
          && Seq.Last(ddbClient.History.GetItem).output.value.Item.Some?
          && !Structure.ActiveBranchKeyItem?(Seq.Last(ddbClient.History.GetItem).output.value.Item.value)
          ==> output.Failure?)

      //= aws-encryption-sdk-specification/framework/branch-key-store.md#getactivebranchkey
      //= type=implication
      //# If the branch key fails to decrypt, GetActiveBranchKey MUST fail.
      || (&& |kmsClient.History.Decrypt| == |old(kmsClient.History.Decrypt)| + 1
          && Seq.Last(kmsClient.History.Decrypt).output.Failure?
          ==> output.Failure?)
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
    requires ddbClient.Modifies !! kmsClient.Modifies

    requires kmsClient.ValidState() && ddbClient.ValidState()
    modifies ddbClient.Modifies, kmsClient.Modifies
    ensures ddbClient.ValidState() && kmsClient.ValidState()



    ensures
      //= aws-encryption-sdk-specification/framework/branch-key-store.md#getbranchkeyversion
      //= type=implication
      //# To get a branch key from the keystore this operation MUST call AWS DDB `GetItem`
      //# using the `branch-key-id` as the Partition Key and "branch:version:" + `branchKeyVersion` value as the Sort Key.
      && |ddbClient.History.GetItem| == |old(ddbClient.History.GetItem)| + 1
      && Seq.Last(ddbClient.History.GetItem).input.Key
         == map[
              Structure.BRANCH_KEY_IDENTIFIER_FIELD := DDB.AttributeValue.S(input.branchKeyIdentifier),
              Structure.TYPE_FIELD := DDB.AttributeValue.S(Structure.BRANCH_KEY_TYPE_PREFIX + input.branchKeyVersion)
            ]

    ensures output.Success?
            ==>

              && Seq.Last(ddbClient.History.GetItem).output.Success?
              && Seq.Last(ddbClient.History.GetItem).output.value.Item.Some?
              && var versionItem := Seq.Last(ddbClient.History.GetItem).output.value.Item.value;

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#getbranchkeyversion
              //= type=implication
              //# The AWS DDB response MUST contain the fields defined in the [branch keystore record format](#record-format).
              && Structure.BranchKeyItem?(versionItem)
              && versionItem[Structure.HIERARCHY_VERSION].N?
              && Structure.BRANCH_KEY_ACTIVE_VERSION_FIELD !in versionItem
              && Structure.BRANCH_KEY_TYPE_PREFIX < versionItem[Structure.TYPE_FIELD].S

              && KMSKeystoreOperations.AttemptKmsOperation?(kmsConfiguration, Structure.ToBranchKeyContext(versionItem, logicalKeyStoreName))

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#getbranchkeyversion
              //= type=implication
              //# The operation MUST decrypt the branch key according to the [AWS KMS Branch Key Decryption](#aws-kms-branch-key-decryption) section.

              && var versionEncryptionContext := Structure.ToBranchKeyContext(versionItem, logicalKeyStoreName);

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# Every key in the constructed [encryption context](#encryption-context)
              //# except `tableName`
              //# MUST exist as a string attribute in the AWS DDB response item.
              && versionEncryptionContext.Keys - {Structure.TABLE_FIELD} < versionItem.Keys

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# Every value in the constructed [encryption context](#encryption-context)
              //# except the logical table name
              //# MUST equal the value with the same key in the AWS DDB response item.
              && (forall k <- versionEncryptionContext.Keys - {Structure.TABLE_FIELD}
                    :: match k
                       case HIERARCHY_VERSION => versionEncryptionContext[Structure.HIERARCHY_VERSION] == versionItem[Structure.HIERARCHY_VERSION].N
                       case _ => versionEncryptionContext[k] == versionItem[k].S)

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# The key `enc` MUST NOT exist in the constructed [encryption context](#encryption-context).
              && Structure.BRANCH_KEY_FIELD !in  versionEncryptionContext

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# The operation MUST use the configured `KMS SDK Client` to decrypt the value of the branch key field.
              && |kmsClient.History.Decrypt| == |old(kmsClient.History.Decrypt)| + 1

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# When calling [AWS KMS Decrypt](https://docs.aws.amazon.com/kms/latest/APIReference/API_Decrypt.html),
              //# the keystore operation MUST call with a request constructed as follows:
              && var decryptRequest := Seq.Last(kmsClient.History.Decrypt).input;

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# - `KeyId` MUST be the configured `AWS KMS Key ARN` in the [AWS KMS Configuration](#aws-kms-configuration) for this keystore
              && decryptRequest.KeyId == Some(kmsConfiguration.kmsKeyArn)

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# - `CiphertextBlob` MUST be the `enc` attribute value on the AWS DDB response item
              && decryptRequest.CiphertextBlob == versionItem[Structure.BRANCH_KEY_FIELD].B

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# Every attribute except for `enc` on the AWS DDB response item
              //# MUST be authenticated in the decryption of `enc`

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# - `EncryptionContext` MUST be the [encryption context](#encryption-context) constructed above
              && decryptRequest.EncryptionContext == Some(versionEncryptionContext)

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#aws-kms-branch-key-decryption
              //= type=implication
              //# - `GrantTokens` MUST be this keystore's [grant tokens](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#grant_token).
              && decryptRequest.GrantTokens == Some(grantTokens)

              && Seq.Last(kmsClient.History.Decrypt).output.Success?
              && Seq.Last(kmsClient.History.Decrypt).output.value.Plaintext.Some?
              && var decryptResponse := Seq.Last(kmsClient.History.Decrypt).output.value;

              && Structure.ToBranchKeyMaterials(versionEncryptionContext, decryptResponse.Plaintext.value).Success?

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#getbranchkeyversion
              //= type=implication
              //# This GetBranchKeyVersion MUST construct [beacon key materials](./structures.md#beacon-key-materials)
              //# according to [Branch Key Materials From Authenticated Encryption Context](#branch-key-materials-from-authenticated-encryption-context).
              && var branchKeyMaterials :=  Structure.ToBranchKeyMaterials(
                                              versionEncryptionContext,
                                              decryptResponse.Plaintext.value
                                            ).value;

              //= aws-encryption-sdk-specification/framework/branch-key-store.md#getbranchkeyversion
              //= type=implication
              //# This operation MUST return the constructed [branch key materials](./structures.md#branch-key-materials).
              && output.value.branchKeyMaterials == branchKeyMaterials

              && output.value.branchKeyMaterials.branchKeyIdentifier == input.branchKeyIdentifier

    ensures
      //= aws-encryption-sdk-specification/framework/branch-key-store.md#getbranchkeyversion
      //= type=implication
      //# If the record does not contain the defined fields, this operation MUST fail.
      || (&& |ddbClient.History.GetItem| == |old(ddbClient.History.GetItem)| + 1
          && Seq.Last(ddbClient.History.GetItem).output.Success?
          && Seq.Last(ddbClient.History.GetItem).output.value.Item.Some?
          && !Structure.VersionBranchKeyItem?(Seq.Last(ddbClient.History.GetItem).output.value.Item.value)
          ==> output.Failure?)

      //= aws-encryption-sdk-specification/framework/branch-key-store.md#getbranchkeyversion
      //= type=implication
      //# If the branch key fails to decrypt, this operation MUST fail.
      || (&& |kmsClient.History.Decrypt| == |old(kmsClient.History.Decrypt)| + 1
          && Seq.Last(kmsClient.History.Decrypt).output.Failure?
          ==> output.Failure?)
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
    requires ddbClient.Modifies !! kmsClient.Modifies

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
