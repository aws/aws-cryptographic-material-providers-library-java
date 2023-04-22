// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../Model/AwsCryptographyMaterialProvidersTestVectorKeysTypes.dfy"
  // Yes, this is reaching across.
  // idealy all these functions would exist in the STD Library.
include "../../TestVectorsAwsCryptographicMaterialProviders/src/JSONHelpers.dfy"

module {:options "-functionSyntax:4"} KeyDescription {
  import opened Wrappers
  import opened JSON.AST
  import AwsCryptographyMaterialProvidersTypes
  import opened Types = AwsCryptographyMaterialProvidersTestVectorKeysTypes
  import opened JSONHelpers

  function ToKeyDescription(obj: JSON): Result<KeyDescription, string>
  {
    :- Need(obj.Object?, "KeyDescription not an object");
    var obj := obj.obj;
    var typString := "type";
    var typ :- GetString(typString, obj);

    :- Need(KeyDescriptionString?(typ), "Unsupported KeyDescription type:" + typ);
    var key :- GetString("key", obj);

    match typ
    case "invalid" =>
      Success(Invalid(InvalidKeyring( keyId := key )))
    case "aws-kms" =>
      Success(Kms(KMSInfo( keyId := key )))
    case "aws-kms-mrk-aware" =>
      Success(KmsMrk(KmsMrkAware( keyId := key )))
    case "aws-kms-mrk-aware-discovery" =>
      var defaultMrkRegion :- GetString("partition", obj);
      var filter := GetObject("aws-kms-discovery-filter", obj);
      var awsKmsDiscoveryFilter := ToDiscoveryFilter(obj);
      Success(KmsMrkDiscovery(KmsMrkAwareDiscovery(
                                keyId := "aws-kms-mrk-aware-discovery",
                                defaultMrkRegion := defaultMrkRegion,
                                awsKmsDiscoveryFilter := awsKmsDiscoveryFilter
                              )))
    case "raw" =>
      var algorithm :- GetString("encryption-algorithm", obj);
      var providerId :- GetString("provider-id", obj);
      :- Need(RawAlgorithmString?(algorithm), "Unsupported algorithm:" + algorithm);
      match algorithm
      case "aes" =>
        Success(AES(RawAES( keyId := key, providerId := providerId )))
      case "rsa" =>
        var paddingAlgorithm :- GetString("padding-algorithm", obj);
        var paddingHash :- GetString("padding-hash", obj);
        :- Need(PaddingAlgorithmString?(paddingAlgorithm), "Unsupported paddingAlgorithm:" + paddingAlgorithm);
        :- Need(PaddingHashString?(paddingHash), "Unsupported paddingHash:" + paddingHash);

        match paddingAlgorithm
        case "pkcs1" =>
          :- Need(paddingHash == "sha1", "Unsupported padding with pkcs1:" + paddingHash);
          Success(RSA(RawRSA( keyId := key, providerId := providerId, padding := AwsCryptographyMaterialProvidersTypes.PKCS1 )))
        case "oaep-mgf1" => match paddingHash
          case "sha1" => Success(RSA(RawRSA( keyId := key, providerId := providerId, padding := AwsCryptographyMaterialProvidersTypes.OAEP_SHA1_MGF1 )))
          case "sha256" => Success(RSA(RawRSA( keyId := key, providerId := providerId, padding := AwsCryptographyMaterialProvidersTypes.OAEP_SHA256_MGF1 )))
          case "sha384" => Success(RSA(RawRSA( keyId := key, providerId := providerId, padding := AwsCryptographyMaterialProvidersTypes.OAEP_SHA384_MGF1 )))
          case "sha512" => Success(RSA(RawRSA( keyId := key, providerId := providerId, padding := AwsCryptographyMaterialProvidersTypes.OAEP_SHA512_MGF1 )))
  }

  function ToDiscoveryFilter(obj: seq<(string, JSON)>)
    : Option<AwsCryptographyMaterialProvidersTypes.DiscoveryFilter>
  {
    var filter :- GetObject("aws-kms-discovery-filter", obj).ToOption();
    var partition :- GetString("partition", filter).ToOption();
    var accountIds :- GetArrayString("account-ids", filter).ToOption();
    Some(AwsCryptographyMaterialProvidersTypes.DiscoveryFilter(
           partition := partition,
           accountIds := accountIds
         ))
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
