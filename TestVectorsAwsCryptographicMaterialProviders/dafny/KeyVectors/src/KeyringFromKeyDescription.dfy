// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../Model/AwsCryptographyMaterialProvidersTestVectorKeysTypes.dfy"
  // Yes this is including from somewhere else.
include "../../TestVectorsAwsCryptographicMaterialProviders/src/LibraryIndex.dfy"
include "KeyMaterial.dfy"
include "CreateStaticKeyrings.dfy"

module {:options "-functionSyntax:4"} KeyringFromKeyDescription {
  import opened Types = AwsCryptographyMaterialProvidersTestVectorKeysTypes
  import MPL = AwsCryptographyMaterialProvidersTypes
    // import WrappedMaterialProviders
  import opened Wrappers
  import KeyMaterial
  import CreateStaticKeyrings

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

    match description
    case Static(StaticKeyring(key)) => {

      :- Need(material.Some? && material.value.InvalidMaterial?, KeyVectorException( message := "Not type: InvalidMaterial"));
      var encrypt := MPL.EncryptionMaterials(
        algorithmSuite := material.value.algorithmSuite,
        encryptedDataKeys := material.value.encryptedDataKeys,
        encryptionContext := material.value.encryptionContext,
        requiredEncryptionContextKeys := material.value.requiredEncryptionContextKeys,
        plaintextDataKey := material.value.plaintextDataKey,
        signingKey := material.value.signingKey,
        symmetricSigningKeys := material.value.symmetricSigningKeys
      );
      var decrypt := MPL.DecryptionMaterials(
        algorithmSuite := material.value.algorithmSuite,
        encryptionContext := material.value.encryptionContext,
        requiredEncryptionContextKeys := material.value.requiredEncryptionContextKeys,
        plaintextDataKey := material.value.plaintextDataKey,
        verificationKey := material.value.verificationKey,
        symmetricSigningKey := None // need to pass one vs many :(
      );

      var keyring := CreateStaticKeyrings.CreateStaticMaterialsKeyring(encrypt, decrypt);
      return Success(keyring);
    }
    case Kms(KMSInfo(key)) => {
      :- Need(material.Some? && material.value.KMS?, KeyVectorException( message := "Not type: KMS" ));
      var input := MPL.CreateAwsKmsMultiKeyringInput(
        generator := Some(material.value.keyIdentifier),
        kmsKeyIds := None,
        clientSupplier := None,
        grantTokens := None
      );
      var keyring := mpl.CreateAwsKmsMultiKeyring(input);
      return keyring.MapFailure(e => AwsCryptographyMaterialProviders(e));
    }
    case KmsMrk(KmsMrkAware(key)) => {
      :- Need(material.Some? && material.value.KMS?, KeyVectorException( message := "Not type: KMS" ));
      var input := MPL.CreateAwsKmsMrkMultiKeyringInput(
        generator := Some(material.value.keyIdentifier),
        kmsKeyIds := None,
        clientSupplier := None,
        grantTokens := None
      );
      var keyring := mpl.CreateAwsKmsMrkMultiKeyring(input);
      return keyring.MapFailure(e => AwsCryptographyMaterialProviders(e));
    }
    case KmsMrkDiscovery(KmsMrkAwareDiscovery(_, defaultMrkRegion, awsKmsDiscoveryFilter)) => {
      :- Need(material.None?, KeyVectorException( message := "Discovery has not key"));
      var input := MPL.CreateAwsKmsMrkDiscoveryMultiKeyringInput(
        regions := [defaultMrkRegion],
        discoveryFilter := awsKmsDiscoveryFilter,
        clientSupplier := None,
        grantTokens := None
      );
      var keyring := mpl.CreateAwsKmsMrkDiscoveryMultiKeyring(input);
      return keyring.MapFailure(e => AwsCryptographyMaterialProviders(e));
    }
    case AES(RawAES(key, providerId)) => {
      :- Need(material.Some? && material.value.Symetric?, KeyVectorException( message := "Not type: Symetric" ));
      var wrappingAlg :- match material.value.bits
        case 128 => Success(MPL.ALG_AES128_GCM_IV12_TAG16)
        case 192 => Success(MPL.ALG_AES192_GCM_IV12_TAG16)
        case 256 => Success(MPL.ALG_AES256_GCM_IV12_TAG16)
        case _ => Failure(KeyVectorException( message := "Not a supported bit length" ));

      var input := MPL.CreateRawAesKeyringInput(
        keyNamespace := providerId,
        keyName := material.value.keyIdentifier,
        wrappingKey := material.value.wrappingKey,
        wrappingAlg := wrappingAlg
      );
      var keyring := mpl.CreateRawAesKeyring(input);
      return keyring.MapFailure(e => AwsCryptographyMaterialProviders(e));
    }
    case RSA(RawRSA(key, providerId, padding)) => {
      :- Need(
        && material.Some?
        && (material.value.PrivateRSA? || material.value.PublicRSA?),
        KeyVectorException( message := "Not type: PrivateRSA or PublicRSA" ));
      match material
      case Some(PrivateRSA(_,_, decrypt, _,_,_, material, keyIdentifier)) => {
        // :- Need(material.Some? && material.value.PrivateRSA?, KeyVectorException( message := "Not type: PrivateRSA" ));
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
      case Some(PublicRSA(_, encrypt,_, _,_,_, material, keyIdentifier)) => {
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
    }
  }
}
