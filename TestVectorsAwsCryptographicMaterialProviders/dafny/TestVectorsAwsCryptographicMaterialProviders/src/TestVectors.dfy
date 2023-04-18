// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "LibraryIndex.dfy"
include "CreateKeyrings.dfy"
include "CreateKeyrings/CreateInvalidKeyrings.dfy"

module {:options "-functionSyntax:4"} TestVectors {
  import Types = AwsCryptographyMaterialProvidersTypes
  import WrappedMaterialProviders

  import opened Wrappers
  import opened StandardLibrary.UInt
  import UTF8

  // Import all the keyring factorys
  import CreateInvalidKeyrings
  import CreateAwsKmsKeyrings
  import CreateAwsKmsMultiKeyrings
  import CreateAwsKmsMrkKeyrings
  import CreateAwsKmsMrkMultiKeyrings
  import CreateRawAesKeyrings
  import CreateRawRsaKeyrings

  datatype EncryptTest = EncryptTest(
      input: Types.GetEncryptionMaterialsInput,
      cmm: Types.ICryptographicMaterialsManager,
      vector: EncryptTestVector
    )

  datatype DecryptTest = DecryptTest(
      input: Types.DecryptMaterialsInput,
      cmm: Types.ICryptographicMaterialsManager,
      vector: DecryptTestVector
    )

  method TestGetEncryptionMaterials(test: EncryptTest)
    returns (testResult: bool, edks: Option<Types.EncryptionMaterials>)
    requires test.cmm.ValidState()
    modifies test.cmm.Modifies
    ensures test.cmm.ValidState()
    ensures testResult && test.vector.PositiveEncryptKeyringVector? ==> edks.Some?
  {
    print "\nTEST===> ",
      test.vector.name,
      if test.vector.description.Some? then "\n" + test.vector.description.value else "",
      if test.vector.NegativeEncryptKeyringVector? then "\n" + test.vector.errorDescription else "", "\n";

    var result := test.cmm.GetEncryptionMaterials(test.input);

    testResult := match test.vector
      case PositiveEncryptKeyringVector(_,_,_,_,_,_,_,_)
        => result.Success?
      case NegativeEncryptKeyringVector(_,_,_,_,_,_,_,_,_)
        => !result.Success?;

    edks := if test.vector.PositiveEncryptKeyringVector? && result.Success? then
        Some(result.value.encryptionMaterials)
      else
        None;

    if !testResult {
      print "FAILED! <-----------\n";
    }
  }

  method TestDecryptMaterials(test: DecryptTest)
    returns (output: bool)
    requires test.cmm.ValidState()
    modifies test.cmm.Modifies
    ensures test.cmm.ValidState()
  {
    print "\nTEST===> ",
      test.vector.name,
      if test.vector.description.Some? then "\n" + test.vector.description.value else "",
      if test.vector.NegativeDecryptKeyringTest? then "\n" + test.vector.errorDescription else "\n";

    var result := test.cmm.DecryptMaterials(test.input);

    output := match test.vector
      case PositiveDecryptKeyringTest(_,_,_,_,_,_,_,_)
        // TODO need to verify the ouput. E.g. is the PTDK correct?
        => result.Success?
      case NegativeDecryptKeyringTest(_,_,_,_,_,_,_,_,_)
        => !result.Success?;

    if !output {
      print "FAILED! <-----------\n";
    }
  }

  method ToEncryptTest(vector: EncryptTestVector)
    returns (output: Result<EncryptTest, string>)
    ensures output.Success? ==>
      && output.value.cmm.ValidState()
      && fresh(output.value.cmm.Modifies)
  {
    var input := match vector
      case PositiveEncryptKeyringVector(
        _,_,
        encryptionContext, commitmentPolicy, algorithmSuite, maxPlaintextLength, requiredEncryptionContextKeys,
        _
      ) =>
        Types.GetEncryptionMaterialsInput(
          encryptionContext := encryptionContext,
          commitmentPolicy := commitmentPolicy,
          algorithmSuiteId := Some(algorithmSuite.id),
          maxPlaintextLength := maxPlaintextLength,
          requiredEncryptionContextKeys := requiredEncryptionContextKeys
        )
      case NegativeEncryptKeyringVector(
        _,_,
        encryptionContext, commitmentPolicy, algorithmSuite, maxPlaintextLength, requiredEncryptionContextKeys,
        _, _
      ) =>
        Types.GetEncryptionMaterialsInput(
          encryptionContext := encryptionContext,
          commitmentPolicy := commitmentPolicy,
          algorithmSuiteId := Some(algorithmSuite.id),
          maxPlaintextLength := maxPlaintextLength,
          requiredEncryptionContextKeys := requiredEncryptionContextKeys
        );

    var mpl :- expect WrappedMaterialProviders.WrappedMaterialProviders();

    var keyring :- ToKeyring(if vector.PositiveEncryptKeyringVector? then
        vector.keyringInfos.encryptInfo
      else
        vector.keyringInfo);

    var maybeCmm := mpl
      .CreateDefaultCryptographicMaterialsManager(
        Types.CreateDefaultCryptographicMaterialsManagerInput( keyring := keyring )
      );
    var cmm :- maybeCmm.MapFailure(e => "CMM failure");

    return Success(EncryptTest(
      input := input,
      cmm := cmm,
      vector := vector
    ));

  }

  method ToDecryptTest(test: EncryptTest, materials: Types.EncryptionMaterials)
    returns (output: Result<DecryptTest, string>)
    requires test.vector.PositiveEncryptKeyringVector?
    ensures output.Success? ==>
      && output.value.cmm.ValidState()
      && fresh(output.value.cmm.Modifies)
  {

    // TODO remove requiredEncryptionContextKeys, and add to reproducedEncryptionContext
    var reproducedEncryptionContext := None;
    var input := Types.DecryptMaterialsInput(
      algorithmSuiteId := materials.algorithmSuite.id,
      commitmentPolicy := test.vector.commitmentPolicy,
      encryptedDataKeys := materials.encryptedDataKeys,
      encryptionContext := materials.encryptionContext,
      reproducedEncryptionContext := reproducedEncryptionContext
    );

    var vector := PositiveDecryptKeyringTest(
      name := test.vector.name + "->Decryption",
      algorithmSuite := materials.algorithmSuite,
      commitmentPolicy := test.vector.commitmentPolicy,
      encryptedDataKeys := materials.encryptedDataKeys,
      encryptionContext := materials.encryptionContext,
      keyrings := test.vector.keyringInfos.decryptInfo,
      description := if test.vector.description.Some? then
        Some("Decryption for " + test.vector.description.value)
      else None,
      reproducedEncryptionContext := reproducedEncryptionContext
    );

    var mpl :- expect WrappedMaterialProviders.WrappedMaterialProviders();

    var keyring :- ToKeyring(test.vector.keyringInfos.decryptInfo);

    var maybeCmm := mpl
      .CreateDefaultCryptographicMaterialsManager(
        Types.CreateDefaultCryptographicMaterialsManagerInput( keyring := keyring )
      );
    var cmm :- maybeCmm.MapFailure(e => "CMM failure");

    return Success(DecryptTest(
      input := input,
      cmm := cmm,
      vector := vector
    ));
  }

  method ToKeyring(info: KeyringInfo)
    returns (output: Result<Types.IKeyring, string>)
    ensures output.Success? ==>
      && output.value.ValidState()
      && fresh(output.value.Modifies)
  {
    var mpl :- expect WrappedMaterialProviders.WrappedMaterialProviders();
    var KeyringInfo(description, material) := info;
    match (description, material)
      case (
        InvalidKeyring(key),
        Some(InvalidMaterial(
          _,
          algorithmSuite,
          encryptionContext,
          encryptedDataKeys,
          requiredEncryptionContextKeys,
          plaintextDataKey,
          signingKey,
          verificationKey,
          symmetricSigningKeys
        ))
      ) => {

        var encrypt := Types.EncryptionMaterials(
          algorithmSuite := algorithmSuite,
          encryptedDataKeys := encryptedDataKeys,
          encryptionContext := encryptionContext,
          requiredEncryptionContextKeys := requiredEncryptionContextKeys,
          plaintextDataKey := plaintextDataKey,
          signingKey := signingKey,
          symmetricSigningKeys := symmetricSigningKeys
        );
        var decrypt := Types.DecryptionMaterials(
          algorithmSuite := algorithmSuite,
          encryptionContext := encryptionContext,
          requiredEncryptionContextKeys := requiredEncryptionContextKeys,
          plaintextDataKey := plaintextDataKey,
          verificationKey := verificationKey,
          symmetricSigningKey := None // need to pass one vs many :(
        );

        var keyring := CreateInvalidKeyrings.CreateInvalidMaterialKeyring(encrypt, decrypt);
        return Success(keyring);
      }

      case (KMSInfo(key), Some(KMS(_, _, _, keyIdentifier))) => {
        var input := Types.CreateAwsKmsMultiKeyringInput(
          generator := Some(keyIdentifier),
          kmsKeyIds := None,
          clientSupplier := None,
          grantTokens := None
        );
        var keyring := mpl.CreateAwsKmsMultiKeyring(input);
        return keyring.MapFailure(e => "Unable to CreateAwsKmsMultiKeyring");
      }
      case (KmsMrkAware(key), Some(KMS(_, _, _, keyIdentifier))) => {
        var input := Types.CreateAwsKmsMrkMultiKeyringInput(
          generator := Some(keyIdentifier),
          kmsKeyIds := None,
          clientSupplier := None,
          grantTokens := None
        );
        var keyring := mpl.CreateAwsKmsMrkMultiKeyring(input);
        return keyring.MapFailure(e => "Unable to CreateAwsKmsMrkMultiKeyring");
      }
      case (
        KmsMrkAwareDiscovery(defaultMrkRegion, awsKmsDiscoveryFilter),
        Some(KMS(_, _, decrypt, keyIdentifier))
      ) => {
        :- Need(decrypt, "Discovery only supports decrypt.");
        var input := Types.CreateAwsKmsDiscoveryMultiKeyringInput(
          regions := [defaultMrkRegion],
          discoveryFilter := awsKmsDiscoveryFilter,
          clientSupplier := None,
          grantTokens := None
        );
        var keyring := mpl.CreateAwsKmsDiscoveryMultiKeyring(input);
        return keyring.MapFailure(e => "Unable to CreateAwsKmsDiscoveryMultiKeyring");
      }
      case (
        RawAES(key, providerId),
        Some(Symetric(_, _, _, algorithm, bits, encoding, wrappingKey, keyIdentifier))
      ) => {
        var wrappingAlg :- match bits
          case 128 => Success(Types.ALG_AES128_GCM_IV12_TAG16)
          case 192 => Success(Types.ALG_AES192_GCM_IV12_TAG16)
          case 256 => Success(Types.ALG_AES256_GCM_IV12_TAG16)
          case _ => Failure("Not a supported bit length");

        var input := Types.CreateRawAesKeyringInput(
          keyNamespace := providerId,
          keyName := keyIdentifier,
          wrappingKey := wrappingKey,
          wrappingAlg := wrappingAlg
        );
        var keyring := mpl.CreateRawAesKeyring(input);
        return keyring.MapFailure(e => "Unable to CreateRawAesKeyring");
      }
      case (
        RawRSA(key, providerId, padding),
        Some(PrivateRSA(_, _, decrypt, algorithm, bits, encoding, material, keyIdentifier))
      ) => {
        :- Need(decrypt, "Private RSA keys only supports decrypt.");
        var privateKeyPemBytes :- UTF8.Encode(material);
        var input := Types.CreateRawRsaKeyringInput(
          keyNamespace := providerId,
          keyName := keyIdentifier,
          paddingScheme := padding,
          publicKey := None,
          privateKey := Some(privateKeyPemBytes)
        );
        var keyring := mpl.CreateRawRsaKeyring(input);
        return keyring.MapFailure(e => "Unable to CreateRawRsaKeyring");
      }
      case (
        RawRSA(key, providerId, padding),
        Some(PublicRSA(_, encrypt, _, algorithm, bits, encoding, material, keyIdentifier))
      ) => {
        :- Need(encrypt, "Public RSA keys only supports encrypt.");
        var publicKeyPemBytes :- UTF8.Encode(material);
        var input := Types.CreateRawRsaKeyringInput(
          keyNamespace := providerId,
          keyName := keyIdentifier,
          paddingScheme := padding,
          publicKey := Some(publicKeyPemBytes),
          privateKey := None
        );
        var keyring := mpl.CreateRawRsaKeyring(input);
        return keyring.MapFailure(e => "Unable to CreateRawRsaKeyring");
      }

      case _ => {
        return Failure("Unsuported Material combination");
      }
  }

  datatype EncryptTestVector =
    | PositiveEncryptKeyringVector(
      name: string,
      description: Option<string>,
      encryptionContext: Types.EncryptionContext,
      commitmentPolicy: Types.CommitmentPolicy,
      // algorithmSuiteId is NOT an option
      // because test vectors are not the place to test defaults
      algorithmSuite: Types.AlgorithmSuiteInfo,
      maxPlaintextLength: Option<UInt.int64>,
      requiredEncryptionContextKeys: Option<Types.EncryptionContextKeys>,
      keyringInfos: PositiveKeyringInfo
    )
    | NegativeEncryptKeyringVector(
      name: string,
      description: Option<string>,
      encryptionContext: Types.EncryptionContext,
      commitmentPolicy: Types.CommitmentPolicy,
      // algorithmSuiteId is NOT an option
      // because test vectors are not the place to test defaults
      algorithmSuite: Types.AlgorithmSuiteInfo,
      maxPlaintextLength: Option<UInt.int64>,
      requiredEncryptionContextKeys: Option<Types.EncryptionContextKeys>,
      errorDescription: string,
      keyringInfo: KeyringInfo
    )
    // | PositiveEncryptCMMTest
    // | NegativeEncryptCMMTest

  datatype PositiveKeyringInfo = PositiveKeyringInfo(
    encryptInfo: KeyringInfo,
    decryptInfo: KeyringInfo
  )

  datatype DecryptTestVector =
    | PositiveDecryptKeyringTest(
      name: string,
      algorithmSuite: Types.AlgorithmSuiteInfo,
      commitmentPolicy: Types.CommitmentPolicy,
      encryptedDataKeys: Types.EncryptedDataKeyList,
      encryptionContext: Types.EncryptionContext,
      keyrings: KeyringInfo,
      description: Option<string> := None,
      reproducedEncryptionContext: Option<Types.EncryptionContext> := None
    )
    | NegativeDecryptKeyringTest(
      name: string,
      algorithmSuite: Types.AlgorithmSuiteInfo,
      commitmentPolicy: Types.CommitmentPolicy,
      encryptedDataKeys: Types.EncryptedDataKeyList,
      encryptionContext: Types.EncryptionContext,
      errorDescription: string,
      keyrings: KeyringInfo,
      reproducedEncryptionContext: Option<Types.EncryptionContext> := None,
      description: Option<string> := None
    )
    // | PositiveDecryptCMMTest
    // | NegativeDecryptCMMTest




  datatype KeyDescription =
    | KMSInfo(key: string)
    | KmsMrkAware(key: string)
    | KmsMrkAwareDiscovery(
      defaultMrkRegion: string,
      awsKmsDiscoveryFilter: Option<Types.DiscoveryFilter> := None
    )
    | RawRSA( key: string, providerId: string, padding: Types.PaddingScheme)
    | RawAES( key: string, providerId: string )
    | InvalidKeyring( key: string)

  datatype KeyMaterial =
    | Symetric(
      name: string,
      encrypt: bool, decrypt: bool,
      algorithm: string,
      bits: nat,
      encoding: string,
      wrappingKey: Types.Secret,
      keyIdentifier: string
    )
    | PrivateRSA(
      name: string,
      encrypt: bool, decrypt: bool,
      algorithm: string,
      bits: nat,
      encoding: string,
      material: string,
      keyIdentifier: string
    )
    | PublicRSA(
      name: string,
      encrypt: bool, decrypt: bool,
      bits: nat,
      algorithm: string,
      encoding: string,
      material: string,
      keyIdentifier: string
    )
    | KMS(
      name: string,
      encrypt: bool, decrypt: bool,
      keyIdentifier: string
    )
    | InvalidMaterial(
      name: string,
      algorithmSuite: Types.AlgorithmSuiteInfo,
      encryptionContext: Types.EncryptionContext,
      encryptedDataKeys: Types.EncryptedDataKeyList,
      requiredEncryptionContextKeys: Types.EncryptionContextKeys,
      plaintextDataKey: Option<Types.Secret> := None,
      signingKey: Option<Types.Secret> := None,
      verificationKey: Option<Types.Secret> := None,
      symmetricSigningKeys: Option<Types.SymmetricSigningKeyList> := None
    )

  datatype KeyringInfo = KeyringInfo(
    description: KeyDescription,
    material: Option<KeyMaterial>
  )

  type KeyMaterialString = s: string | KeyMaterialString?(s) witness *
  predicate KeyMaterialString?(s: string)
  {
    || s == "invalid"
    || s == "aws-kms"
    || s == "symmetric"
    || s == "private"
    || s == "public"
  }

  type KeyDescriptionString = s: string | KeyDescriptionString?(s) witness *
  predicate KeyDescriptionString?(s: string)
  {
    || s == "invalid"
    || s == "aws-kms"
    || s == "aws-kms-mrk-aware"
    || s == "aws-kms-mrk-aware-discovery"
    || s == "raw"
  }

  type RawAlgorithmString = s: string | RawAlgorithmString?(s) witness *
  predicate RawAlgorithmString?(s: string)
  {
    || s == "aes"
    || s == "rsa"
  }

  type PaddingAlgorithmString = s: string | PaddingAlgorithmString?(s) witness *
  predicate PaddingAlgorithmString?(s: string)
  {
    || s == "pkcs1"
    || s == "oaep-mgf1"
  }

  type PaddingHashString = s: string | PaddingHashString?(s) witness *
  predicate PaddingHashString?(s: string)
  {
    || s == "sha1"
    || s == "sha1"
    || s == "sha256"
    || s == "sha384"
    || s == "sha512"
  }




}