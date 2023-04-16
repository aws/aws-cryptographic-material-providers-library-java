// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../Model/AwsCryptographyMaterialProvidersTypesWrapped.dfy"
include "JSONHelpers.dfy"
include "TestVectors.dfy"

module {:options "-functionSyntax:4"} ParseJsonManifests {

  import Types = AwsCryptographyMaterialProvidersTypes

  import JSON.API
  import JSON.Utils.Unicode
  import opened JSON.AST
  import opened Wrappers
  import UTF8
  import Seq
  import opened StandardLibrary.UInt
  import opened JSONHelpers
  import opened TestVectors
  import HexStrings
  import Base64
  // This is a HACK!
  // This is *ONLY* because this is wrapping the MPL
  import AlgorithmSuites

  function BuildKeyMaterials(obj: seq<(string, JSON)>): Result<map<string, KeyMaterial>, string>
  {
    if |obj| == 0 then
      Success(map[])
    else
      var name := obj[0].0;
      var keyMaterial :- ToKeyMaterial(name, obj[0].1);
      var tail :- BuildKeyMaterials(obj[1..]);
      Success(map[ name := keyMaterial] + tail)
  }

  function ToKeyMaterial(name: string, obj: JSON): Result<KeyMaterial, string>
  {
    :- Need(obj.Object?, "KeyDescription not an object");
    var obj := obj.obj;
    var typString := "type";
    var typ :- GetString(typString, obj);

    match typ
      case "invalid" =>
        var algorithmSuiteHex :- GetString("algorithmSuiteId", obj);
        :- Need(HexStrings.IsLooseHexString(algorithmSuiteHex), "Not hex encoded binnary");
        var binaryId := HexStrings.FromHexString(algorithmSuiteHex);
        var algorithmSuite :- AlgorithmSuites
          .GetAlgorithmSuiteInfo(binaryId)
          .MapFailure(e => "Invalid Suite:" + algorithmSuiteHex);

        var encryptionContextStrings :- SmallObjectToStringStringMap("encryptionContext", obj);
        var encryptionContext :- utf8EncodeMap(encryptionContextStrings);

        var keysAsStrings :- GetArrayString("requiredEncryptionContextKeys", obj);
        var requiredEncryptionContextKeys :- utf8EncodeSeq(keysAsStrings);

        var encryptedDataKeysJSON :- GetArrayObject("encryptedDataKeys", obj);
        var encryptedDataKeys :- Seq.MapWithResult(ToEncryptedDataKey, encryptedDataKeysJSON);

        var plaintextDataKeyEncoded :- GetOptionalString("plaintextDataKey", obj);
        var plaintextDataKey :- if plaintextDataKeyEncoded.Some? then
            var result := Base64.Decode(plaintextDataKeyEncoded.value);
            if result.Success? then Success(Some(result.value)) else Failure(result.error)
          else Success(None);
        var signingKey :- GetOptionalString("signingKey", obj);
        var verificationKey :- GetOptionalString("verificationKey", obj);
        var symmetricSigningKeys := GetArrayString("symmetricSigningKeys", obj).ToOption();

        Success(InvalidMaterial(
          name := name,
          algorithmSuite := algorithmSuite,
          encryptionContext := encryptionContext,
          encryptedDataKeys := encryptedDataKeys,
          requiredEncryptionContextKeys := requiredEncryptionContextKeys,
          plaintextDataKey := plaintextDataKey,
          // This is just for now...
          signingKey := None,
          verificationKey := None,
          symmetricSigningKeys := None
        ))
      case _ => 
        var encrypt :- GetBool("encrypt", obj);
        var decrypt :- GetBool("decrypt", obj);
        var keyIdentifier :- GetString("key-id", obj);
        
        match typ
          case "aws-kms" =>
            Success(KeyMaterial.KMS(
              name := name,
              encrypt := encrypt,
              decrypt := decrypt,
              keyIdentifier := keyIdentifier
            ))
          case _ =>
            var algorithm :- GetString("algorithm", obj);
            var bits :- GetNat("bits", obj);
            var encoding :- GetString("encoding", obj);
            var material :- GetString("material", obj);

            match typ
              case "symmetric" =>
                var materialBytes :- Base64.Decode(material);
                Success(Symetric(
                  name := name,
                  encrypt := encrypt,
                  decrypt := decrypt,
                  keyIdentifier := keyIdentifier,
                  algorithm := algorithm,
                  bits := bits,
                  encoding := encoding,
                  wrappingKey := materialBytes
                ))
              case "private" =>
                Success(PrivateRSA(
                  name := name,
                  encrypt := encrypt,
                  decrypt := decrypt,
                  keyIdentifier := keyIdentifier,
                  algorithm := algorithm,
                  bits := bits,
                  encoding := encoding,
                  material := material
                ))
              case "public" =>
                Success(PublicRSA(
                  name := name,
                  encrypt := encrypt,
                  decrypt := decrypt,
                  keyIdentifier := keyIdentifier,
                  algorithm := algorithm,
                  bits := bits,
                  encoding := encoding,
                  material := material
                ))
              case _ => Failure("Unsupported KeyMaterial type:" + typ)
  }

  function BuildEncryptTestVector(keys: map<string, KeyMaterial>, obj: seq<(string, JSON)>)
    : Result<seq<EncryptTestVector>, string>
  {
    if |obj| == 0 then
      Success([])
    else
      var name := obj[0].0;
      var encryptVector :- ToEncryptTestVector(keys, name, obj[0].1);
      var tail :- BuildEncryptTestVector(keys, obj[1..]);
      Success([ encryptVector ] + tail)
  }

  function ToEncryptTestVector(keys: map<string, KeyMaterial>, name: string, obj: JSON)
    : Result<EncryptTestVector, string>
  {
    :- Need(obj.Object?, "EncryptTestVector not an object");
    var obj := obj.obj;
    var typString := "type";
    var typ :- GetString(typString, obj);

    var description := GetString("description", obj).ToOption();

    var encryptionContextStrings :- SmallObjectToStringStringMap("encryptionContext", obj);
    var encryptionContext :- utf8EncodeMap(encryptionContextStrings);

    var algorithmSuiteHex :- GetString("algorithmSuiteId", obj);
    :- Need(HexStrings.IsLooseHexString(algorithmSuiteHex), "Not hex encoded binnary");
    var binaryId := HexStrings.FromHexString(algorithmSuiteHex);
    var algorithmSuite :- AlgorithmSuites
      .GetAlgorithmSuiteInfo(binaryId)
      .MapFailure(e => "Invalid Suite:" + algorithmSuiteHex);

    var keysAsStrings := GetArrayString("requiredEncryptionContextKeys", obj).ToOption();
    var requiredEncryptionContextKeys :- if keysAsStrings.Some? then
        var result := utf8EncodeSeq(keysAsStrings.value);
        if result.Success? then Success(Some(result.value)) else Failure(result.error)
      else Success(None);

    // TODO fix me
    var commitmentPolicy := Types.CommitmentPolicy.ESDK(Types.ESDKCommitmentPolicy.FORBID_ENCRYPT_ALLOW_DECRYPT);
    var maxPlaintextLength := None; // GetString("maxPlaintextLength", obj);
    
    match typ
      case "positive-keyring" =>
        var encryptKeyDescriptionObject :- Get("encryptKeyDescription", obj);
        var decryptKeyDescriptionObject :- Get("decryptKeyDescription", obj);

        var encryptKeyDescription :- ToKeyDescription(encryptKeyDescriptionObject);
        var decryptKeyDescription :- ToKeyDescription(decryptKeyDescriptionObject);

        var encryptInfo :- ToKeyringInfo(keys, encryptKeyDescription);
        var decryptInfo :- ToKeyringInfo(keys, decryptKeyDescription);

        Success(PositiveEncryptKeyringVector(
          name := name,
          description := description,
          encryptionContext := encryptionContext,
          commitmentPolicy := commitmentPolicy,
          algorithmSuite := algorithmSuite,
          maxPlaintextLength := maxPlaintextLength,
          requiredEncryptionContextKeys := requiredEncryptionContextKeys,
          keyringInfos := PositiveKeyringInfo(encryptInfo, decryptInfo)
        ))
      case "negative-keyring" =>
        var keyDescriptionObject :- Get("keyDescription", obj);
        var keyDescription :- ToKeyDescription(keyDescriptionObject);
        var keyringInfo :- ToKeyringInfo(keys, keyDescription);

        var errorDescription :- GetString("errorDescription", obj);
        Success(NegativeEncryptKeyringVector(
          name := name,
          description := description,
          encryptionContext := encryptionContext,
          commitmentPolicy := commitmentPolicy,
          algorithmSuite := algorithmSuite,
          maxPlaintextLength := maxPlaintextLength,
          requiredEncryptionContextKeys := requiredEncryptionContextKeys,
          errorDescription := errorDescription,
          keyringInfo := keyringInfo
        ))
      case _ => Failure("Unsupported EncryptTestVector type:" + typ)
  }

  function ToKeyDescription(obj: JSON): Result<KeyDescription, string>
  {
    :- Need(obj.Object?, "KeyDescription not an object");
    var obj := obj.obj;
    var typString := "type";
    var typ :- GetString(typString, obj);
    var key :- GetString("key", obj);

    match typ
      case "invalid" =>
        Success(InvalidKeyring(key))
      case "aws-kms" =>
        Success(KMSInfo(key))
      case "aws-kms-mrk-aware" =>
        Success(KmsMrkAware(key))
      case "aws-kms-mrk-aware-discovery" =>
        var defaultMrkRegion :- GetString("partition", obj);
        var filter := GetObject("aws-kms-discovery-filter", obj);
        var awsKmsDiscoveryFilter := ToDiscoveryFilter(obj);
        Success(KmsMrkAwareDiscovery(
          defaultMrkRegion := defaultMrkRegion,
          awsKmsDiscoveryFilter := awsKmsDiscoveryFilter
        ))
      case "raw" =>
        var algorithm :- GetString("encryption-algorithm", obj);
        var providerId :- GetString("provider-id", obj);
        (match algorithm
          case "aes" =>
            Success(RawAES(key, providerId))
          case "rsa" =>
            var paddingAlgorithm :- GetString("padding-algorithm", obj);
            var paddingHash :- GetString("padding-hash", obj);
            (match (paddingAlgorithm, paddingHash)
              // PKCS1 MAY be None hash...
              case ("pkcs1", "sha1") => Success(RawRSA(key, providerId, Types.PKCS1))
              case ("oaep-mgf1", "sha1") => Success(RawRSA(key, providerId, Types.OAEP_SHA1_MGF1))
              case ("oaep-mgf1", "sha256") => Success(RawRSA(key, providerId, Types.OAEP_SHA256_MGF1))
              case ("oaep-mgf1", "sha384") => Success(RawRSA(key, providerId, Types.OAEP_SHA384_MGF1))
              case ("oaep-mgf1", "sha512") => Success(RawRSA(key, providerId, Types.OAEP_SHA512_MGF1))
              case _ => Failure("Unsupported padding:" + paddingAlgorithm + " : " + paddingHash))
          case _ => Failure("Unsupported algorithm:" + algorithm))
      case _ => Failure("Unsupported KeyDescription type:" + typ)
  }

  function ToKeyringInfo(keys: map<string, KeyMaterial>,  description: KeyDescription)
    : Result<KeyringInfo, string>
  {
    var material :- match description
      case KmsMrkAwareDiscovery(_, _) => Success(None)
      case _ => 
      :- Need(description.key in keys, "Key does not exist");
      Success(Some(keys[description.key]));
    Success(KeyringInfo(description, material))
  }

  function ToDiscoveryFilter(obj: seq<(string, JSON)>) : Option<Types.DiscoveryFilter>
  {
    var filter :- GetObject("aws-kms-discovery-filter", obj).ToOption();
    var partition :- GetString("partition", filter).ToOption();
    var accountIds :- GetArrayString("account-ids", filter).ToOption();
    Some(Types.DiscoveryFilter(
      partition := partition,
      accountIds := accountIds
    ))
  }

  function ToEncryptedDataKey(obj: seq<(string, JSON)>)
    : Result<Types.EncryptedDataKey, string>
  {
    var keyProviderIdJSON :- GetString("keyProviderId", obj);
    var keyProviderInfoJSON :- GetString("keyProviderInfo", obj);
    var ciphertextJSON :- GetString("ciphertext", obj);

    var keyProviderId :- UTF8.Encode(keyProviderIdJSON);
    var keyProviderInfo :- Base64.Decode(keyProviderInfoJSON);
    var ciphertext :- Base64.Decode(ciphertextJSON);

    Success(Types.EncryptedDataKey(
      keyProviderId := keyProviderId,
      keyProviderInfo := keyProviderInfo,
      ciphertext := ciphertext
    ))
  }

  function utf8EncodePair(key: string, value: string):
    (res: Result<(UTF8.ValidUTF8Bytes, UTF8.ValidUTF8Bytes), string>)
  {
    var utf8Key :- UTF8.Encode(key);
    var utf8Value :- UTF8.Encode(value);

    Success((utf8Key, utf8Value))
  }

    // TODO: These EncryptionContext methods can be removed once we move to UTF8 strings
  function utf8EncodeMap(mapStringString: map<string, string>):
    (res: Result<Types.EncryptionContext, string>)
  {
    if |mapStringString| == 0 then
      Success(map[])
    else

      var encodedResults := map key <- mapStringString :: key := utf8EncodePair(key, mapStringString[key]);
      :- Need(forall r <- encodedResults.Values :: r.Success?, "String can not be UTF8 Encoded?");

      Success(map r <- encodedResults.Values :: r.value.0 := r.value.1)
  }

  function utf8EncodeSeq(seqOfStrings: seq<string>)
    :(res: Result<seq<Types.Utf8Bytes>, string>)
  {
    var encodedResults := seq(|seqOfStrings|, i requires 0 <= i < |seqOfStrings| => UTF8.Encode(seqOfStrings[i]));
    :- Need(forall r <- encodedResults :: r.Success?, "String can not be UTF8 Encoded?");
    Success(seq(|encodedResults|, i requires 0 <= i < |encodedResults| => encodedResults[i].value))
  }

}