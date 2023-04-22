// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../Model/AwsCryptographyMaterialProvidersTestVectorKeysTypes.dfy"
  // Yes this is including from somewhere else.
include "../../TestVectorsAwsCryptographicMaterialProviders/src/LibraryIndex.dfy"
include "KeyMaterial.dfy"
include "CreateInvalidKeyrings.dfy"

module {:options "-functionSyntax:4"} KeyringFromKeyDescription {
  import opened Types = AwsCryptographyMaterialProvidersTestVectorKeysTypes
  import MPL = AwsCryptographyMaterialProvidersTypes
    // import WrappedMaterialProviders
  import opened Wrappers
  import KeyMaterial
  import CreateInvalidKeyrings

  datatype KeyringInfo = KeyringInfo(
    description: KeyDescription,
    material: Option<KeyMaterial.KeyMaterial>
  )

  method ToKeyring(mpl: MPL.IAwsCryptographicMaterialProvidersClient, info: KeyringInfo)
    returns (output: Result<MPL.IKeyring, Error>)
    requires mpl.ValidState()
    modifies mpl.Modifies
    ensures mpl.ValidState()
    ensures output.Success? ==>
              && output.value.ValidState()
              && fresh(output.value.Modifies - mpl.Modifies - {mpl.History})
  {
    var KeyringInfo(description, material) := info;
    match (description, material)
    case (
      Invalid(InvalidKeyring(key)),
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

      var encrypt := MPL.EncryptionMaterials(
        algorithmSuite := algorithmSuite,
        encryptedDataKeys := encryptedDataKeys,
        encryptionContext := encryptionContext,
        requiredEncryptionContextKeys := requiredEncryptionContextKeys,
        plaintextDataKey := plaintextDataKey,
        signingKey := signingKey,
        symmetricSigningKeys := symmetricSigningKeys
      );
      var decrypt := MPL.DecryptionMaterials(
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

    case (Kms(KMSInfo(key)), Some(KMS(_, _, _, keyIdentifier))) => {
      var input := MPL.CreateAwsKmsMultiKeyringInput(
        generator := Some(keyIdentifier),
        kmsKeyIds := None,
        clientSupplier := None,
        grantTokens := None
      );
      var keyring := mpl.CreateAwsKmsMultiKeyring(input);
      return keyring.MapFailure(e => AwsCryptographyMaterialProviders(e));
    }
    case (KmsMrk(KmsMrkAware(key)), Some(KMS(_, _, _, keyIdentifier))) => {
      var input := MPL.CreateAwsKmsMrkMultiKeyringInput(
        generator := Some(keyIdentifier),
        kmsKeyIds := None,
        clientSupplier := None,
        grantTokens := None
      );
      var keyring := mpl.CreateAwsKmsMrkMultiKeyring(input);
      return keyring.MapFailure(e => AwsCryptographyMaterialProviders(e));
    }
    case (
      KmsMrkDiscovery(KmsMrkAwareDiscovery(_, defaultMrkRegion, awsKmsDiscoveryFilter)),
        Some(KMS(_, _, decrypt, keyIdentifier))
        ) => {
      :- Need(decrypt, KeyVectorException( message := "Discovery only supports decrypt."));
      var input := MPL.CreateAwsKmsDiscoveryMultiKeyringInput(
        regions := [defaultMrkRegion],
        discoveryFilter := awsKmsDiscoveryFilter,
        clientSupplier := None,
        grantTokens := None
      );
      var keyring := mpl.CreateAwsKmsDiscoveryMultiKeyring(input);
      return keyring.MapFailure(e => AwsCryptographyMaterialProviders(e));
    }
    case (
      AES(RawAES(key, providerId)),
        Some(Symetric(_, _, _, algorithm, bits, encoding, wrappingKey, keyIdentifier))
        ) => {
      var wrappingAlg :- match bits
        case 128 => Success(MPL.ALG_AES128_GCM_IV12_TAG16)
        case 192 => Success(MPL.ALG_AES192_GCM_IV12_TAG16)
        case 256 => Success(MPL.ALG_AES256_GCM_IV12_TAG16)
        case _ => Failure(KeyVectorException( message := "Not a supported bit length" ));

      var input := MPL.CreateRawAesKeyringInput(
        keyNamespace := providerId,
        keyName := keyIdentifier,
        wrappingKey := wrappingKey,
        wrappingAlg := wrappingAlg
      );
      var keyring := mpl.CreateRawAesKeyring(input);
      return keyring.MapFailure(e => AwsCryptographyMaterialProviders(e));
    }
    case (
      RSA(RawRSA(key, providerId, padding)),
        Some(PrivateRSA(_, _, decrypt, algorithm, bits, encoding, material, keyIdentifier))
        ) => {
      :- Need(decrypt, KeyVectorException( message := "Private RSA keys only supports decrypt." ));
      var privateKeyPemBytes :- UTF8.Encode(material).MapFailure(e => KeyVectorException( message := e ));
      var input := MPL.CreateRawRsaKeyringInput(
        keyNamespace := providerId,
        keyName := keyIdentifier,
        paddingScheme := padding,
        publicKey := None,
        privateKey := Some(privateKeyPemBytes)
      );
      var keyring := mpl.CreateRawRsaKeyring(input);
      return keyring.MapFailure(e => AwsCryptographyMaterialProviders(e));
    }
    case (
      RSA(RawRSA(key, providerId, padding)),
        Some(PublicRSA(_, encrypt, _, algorithm, bits, encoding, material, keyIdentifier))
        ) => {
      :- Need(encrypt, KeyVectorException( message := "Public RSA keys only supports encrypt." ));
      var publicKeyPemBytes :- UTF8.Encode(material).MapFailure(e => KeyVectorException( message := e ));
      var input := MPL.CreateRawRsaKeyringInput(
        keyNamespace := providerId,
        keyName := keyIdentifier,
        paddingScheme := padding,
        publicKey := Some(publicKeyPemBytes),
        privateKey := None
      );
      var keyring := mpl.CreateRawRsaKeyring(input);
      return keyring.MapFailure(e => AwsCryptographyMaterialProviders(e));
    }

    case _ => {
      return Failure(KeyVectorException( message := "Unsuported Material combination"));
    }
  }
}
