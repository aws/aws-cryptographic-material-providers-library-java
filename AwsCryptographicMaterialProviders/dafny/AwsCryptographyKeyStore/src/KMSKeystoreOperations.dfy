include "../Model/AwsCryptographyKeyStoreTypes.dfy"
include "Structure.dfy"

module {:options "/functionSyntax:4" } KMSKeystoreOperations {
  import opened Wrappers
  import opened UInt = StandardLibrary.UInt
  import Seq
  import Types = AwsCryptographyKeyStoreTypes
  import DDB = ComAmazonawsDynamodbTypes
  import KMS = ComAmazonawsKmsTypes
  import UTF8
  import Structure

  
  predicate AttemptKmsOperation?(awsKmsConfig: Types.KMSConfiguration, encryptionContext: Structure.BranchKeyContext)
  {
    match awsKmsConfig
      case kmsKeyArn(arn) => arn == encryptionContext[Structure.KMS_FIELD]
  }

  // function awsKmsArn(
  //   awsKmsConfig: Types.KMSConfiguration,
  //   encryptionContext: Structure.BranchKeyContext
  // ): (arn: KMS.KmsKeyArn)



  method GenerateKey(
    encryptionContext: Structure.BranchKeyContext,
    awsKmsConfig: Types.KMSConfiguration,
    grantTokens: KMS.GrantTokenList,
    kmsClient: KMS.IKMSClient
  )
    returns (res: Result<KMS.GenerateDataKeyWithoutPlaintextResponse, Types.Error>)
    requires AttemptKmsOperation?(awsKmsConfig, encryptionContext)
    requires kmsClient.ValidState()
    modifies kmsClient.Modifies
    ensures kmsClient.ValidState()
    ensures
      && |kmsClient.History.GenerateDataKeyWithoutPlaintext| == |old(kmsClient.History.GenerateDataKeyWithoutPlaintext)| + 1
      && KMS.GenerateDataKeyWithoutPlaintextRequest(
           KeyId := awsKmsConfig.kmsKeyArn,
           EncryptionContext := Some(encryptionContext),
           KeySpec := None,
           NumberOfBytes := Some(32),
           GrantTokens := Some(grantTokens)
         )
         == Seq.Last(kmsClient.History.GenerateDataKeyWithoutPlaintext).input

    ensures res.Success? ==>
              && res.value.KeyId.Some?
              && res.value.CiphertextBlob.Some?
              && |res.value.CiphertextBlob.value| == Structure.KMS_GEN_KEY_NO_PLAINTEXT_LENGTH_32
              && |kmsClient.History.GenerateDataKeyWithoutPlaintext| > 0
              && KMS.IsValid_CiphertextType(res.value.CiphertextBlob.value)
              && var kmsOperationOutput := Seq.Last(kmsClient.History.GenerateDataKeyWithoutPlaintext).output;
              && kmsOperationOutput.Success?
              && kmsOperationOutput.value.CiphertextBlob.Some?
              && kmsOperationOutput.value.CiphertextBlob == res.value.CiphertextBlob
              && kmsOperationOutput.value.KeyId.Some?
              && kmsOperationOutput.value.KeyId == res.value.KeyId
    {
      var generatorRequest := KMS.GenerateDataKeyWithoutPlaintextRequest(
        KeyId := awsKmsConfig.kmsKeyArn,
        EncryptionContext := Some(encryptionContext),
        KeySpec := None,
        NumberOfBytes := Some(32),
        GrantTokens := Some(grantTokens)
      );

      var maybeGenerateResponse := kmsClient.GenerateDataKeyWithoutPlaintext(generatorRequest);
      var generateResponse :- maybeGenerateResponse
      .MapFailure(e => Types.ComAmazonawsKms(ComAmazonawsKms := e));

      :- Need(
        && generateResponse.KeyId.Some?,
        // && ParseAwsKmsIdentifier(generateResponse.KeyId.value).Success?,
        Types.KeyStoreException(
          message := "Invalid response from KMS GenerateDataKey:: Invalid Key Id")
      );

      :- Need(
        && generateResponse.CiphertextBlob.Some?
        && |generateResponse.CiphertextBlob.value| == Structure.KMS_GEN_KEY_NO_PLAINTEXT_LENGTH_32
        && KMS.IsValid_CiphertextType(generateResponse.CiphertextBlob.value),
        Types.KeyStoreException(
          message := "Invalid response from AWS KMS GeneratedDataKey: Invalid ciphertext")
      );

      return Success(generateResponse);
    }

  method ReEncryptKey(
    ciphertext: seq<uint8>,
                    sourceEncryptionContext: Structure.BranchKeyContext,
                    destinationEncryptionContext: Structure.BranchKeyContext,
                    awsKmsConfig: Types.KMSConfiguration,
                    grantTokens: KMS.GrantTokenList,
                    kmsClient: KMS.IKMSClient
  )
    returns (res: Result<KMS.ReEncryptResponse, Types.Error>)
    requires KMS.IsValid_CiphertextType(ciphertext)
    requires
      // This is to validate the encryption context
      || (destinationEncryptionContext == sourceEncryptionContext)
      || (
           && Structure.BRANCH_KEY_TYPE_PREFIX < sourceEncryptionContext[Structure.TYPE_FIELD]
           && Structure.BRANCH_KEY_ACTIVE_VERSION_FIELD !in sourceEncryptionContext
           && destinationEncryptionContext == Structure.ActiveBranchKeyEncryptionContext(sourceEncryptionContext)
         )
    requires AttemptKmsOperation?(awsKmsConfig, destinationEncryptionContext)
    requires kmsClient.ValidState()
    modifies kmsClient.Modifies
    ensures kmsClient.ValidState()
    ensures res.Success? ==>
              && res.value.CiphertextBlob.Some?
              && res.value.SourceKeyId.Some?
              && res.value.KeyId.Some?
              && res.value.SourceKeyId.value == awsKmsConfig.kmsKeyArn
              && res.value.KeyId.value == awsKmsConfig.kmsKeyArn
              && |kmsClient.History.ReEncrypt| > 0
              && KMS.IsValid_CiphertextType(res.value.CiphertextBlob.value)
              && var kmsOperationInput := Seq.Last(kmsClient.History.ReEncrypt).input;
              && var kmsOperationOutput := Seq.Last(kmsClient.History.ReEncrypt).output;
              && kmsOperationOutput.Success?
              && KMS.ReEncryptRequest(
                   CiphertextBlob := ciphertext,
                   SourceEncryptionContext := Some(sourceEncryptionContext),
                   SourceKeyId := Some(awsKmsConfig.kmsKeyArn),
                   DestinationKeyId := awsKmsConfig.kmsKeyArn,
                   DestinationEncryptionContext := Some(destinationEncryptionContext),
                   SourceEncryptionAlgorithm := None,
                   DestinationEncryptionAlgorithm := None,
                   GrantTokens := Some(grantTokens)
                 ) == kmsOperationInput
              && kmsOperationOutput.value.CiphertextBlob.Some?
              && kmsOperationOutput.value.SourceKeyId.Some?
              && kmsOperationOutput.value.KeyId.Some?
              && kmsOperationOutput.value.CiphertextBlob.value == res.value.CiphertextBlob.value
              && kmsOperationOutput.value.SourceKeyId.value == res.value.SourceKeyId.value
              && kmsOperationOutput.value.KeyId.value == res.value.KeyId.value
    {
      var reEncryptRequest := KMS.ReEncryptRequest(
        CiphertextBlob := ciphertext,
        SourceEncryptionContext := Some(sourceEncryptionContext),
        SourceKeyId := Some(awsKmsConfig.kmsKeyArn),
        DestinationKeyId := awsKmsConfig.kmsKeyArn,
        DestinationEncryptionContext := Some(destinationEncryptionContext),
        SourceEncryptionAlgorithm := None,
        DestinationEncryptionAlgorithm := None,
        GrantTokens := Some(grantTokens)
      );

      var maybeReEncryptResponse := kmsClient.ReEncrypt(reEncryptRequest);
      var reEncryptResponse :- maybeReEncryptResponse
      .MapFailure(e => Types.ComAmazonawsKms(ComAmazonawsKms := e));

      :- Need(
        && reEncryptResponse.SourceKeyId.Some?
        && reEncryptResponse.KeyId.Some?
        && reEncryptResponse.SourceKeyId.value == awsKmsConfig.kmsKeyArn
        && reEncryptResponse.KeyId.value == awsKmsConfig.kmsKeyArn,
        // && ParseAwsKmsIdentifier(reEncryptResponse.SourceKeyId.value).Success?
        // && ParseAwsKmsIdentifier(reEncryptResponse.KeyId.value).Success?,
        Types.KeyStoreException(
          message := "Invalid response from KMS GenerateDataKey:: Invalid Key Id")
      );

      :- Need(
        && reEncryptResponse.CiphertextBlob.Some?
        && KMS.IsValid_CiphertextType(reEncryptResponse.CiphertextBlob.value),
        Types.KeyStoreException(
          message := "Invalid response from AWS KMS GeneratedDataKey: Invalid ciphertext")
      );

      return Success(reEncryptResponse);
    }

  method DecryptKey(
    encryptionContext: Structure.BranchKeyContext,
    wrappedBranchKey: KMS.CiphertextType,
    awsKmsConfig: Types.KMSConfiguration,
    grantTokens: KMS.GrantTokenList,
    kmsClient: KMS.IKMSClient
  )
    returns (output: Result<KMS.DecryptResponse, Types.Error>)
    requires AttemptKmsOperation?(awsKmsConfig, encryptionContext)
    requires KMS.IsValid_CiphertextType(wrappedBranchKey)
    ensures
      && |kmsClient.History.Decrypt| == |old(kmsClient.History.Decrypt)| + 1
      && KMS.DecryptRequest(
           CiphertextBlob := wrappedBranchKey,
           EncryptionContext := Some(encryptionContext),
           GrantTokens := Some(grantTokens),
           KeyId := Some(awsKmsConfig.kmsKeyArn),
           EncryptionAlgorithm := None
         )
         == Seq.Last(kmsClient.History.Decrypt).input;
    ensures output.Success?
            ==>
              && Seq.Last(kmsClient.History.Decrypt).output.Success?
              && output.value.Plaintext.Some?
              && 32 == |output.value.Plaintext.value|



}