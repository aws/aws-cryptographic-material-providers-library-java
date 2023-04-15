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
    returns (output: bool)
    requires test.cmm.ValidState()
    modifies test.cmm.Modifies
    ensures test.cmm.ValidState()
  {
    print "\nTEST===> ",
      test.vector.name,
      if test.vector.description.Some? then "\n" + test.vector.description.value else "",
      if test.vector.NegativeEncryptKeyringVector? then "\n" + test.vector.errorDescription else "", "\n";

    var result := test.cmm.GetEncryptionMaterials(test.input);

    output := match test.vector
      case PositiveEncryptKeyringVector(_,_,_,_,_,_,_,_)
        => result.Success?
      case NegativeEncryptKeyringVector(_,_,_,_,_,_,_,_,_)
        => !result.Success?;

    if !output {
      print "FAILED!\n";
    }
  }

  method TestDecryptMaterials(test: DecryptTest)
    returns (output: bool)
    requires test.cmm.ValidState()
    modifies test.cmm.Modifies
    ensures test.cmm.ValidState()
  {
    print "\nTEST===> ",
      test.vector.name, "\n",
      if test.vector.description.Some? then test.vector.description.value else "",
      if test.vector.NegativeDecryptKeyringTest? then test.vector.errorDescription + "\n" else "";

    var result := test.cmm.DecryptMaterials(test.input);

    output := match test.vector
      case PositiveDecryptKeyringTest(_,_,_,_,_,_,_,_)
        => result.Success?
      case NegativeDecryptKeyringTest(_,_,_,_,_,_,_,_,_)
        => result.Success?;

    if !output {
      print "FAILED!\n";
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

    var keyring :- ToKeyring(vector.keyringInfo);

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
      keyringInfo: KeyringInfo
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
      material: string,
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

}