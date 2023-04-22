// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "TestVectors.dfy"
include "JSONHelpers.dfy"

module {:options "-functionSyntax:4"} CompleteVectors {
  import Types = AwsCryptographyMaterialProvidersTypes
  import MaterialProviders
  import TestVectors
  import Seq
  import opened Wrappers
  import opened StandardLibrary.UInt
  import HexStrings
  import opened JSON.AST

  import UUID
  import JSONHelpers
  import JSON.API
  import SortedSets
  import FileIO


  // TODO Make AES pass
  // TODO Add a path to write manifies to
  // TODO Add discovery keyrings for decrypt
  // TODO Add KMS RSA
  // TODO Add hierarkey keyring
  // TODO Add negative encrypt tests
  // TODO Add negative decrypt tests
  // TODO move keys/ToKeyring into seperate service
  // TODO Add additional manifest data to decrypt manifiest
  // TODO Add resutl to decrypt manifiests
  // TODO open other PR for fixes to pirmatives and KMS and shared makefile
  // TODO support required encrytion context
  // TODO serialize commitment policy
  // TODO serialize maxPlaintextLength





  // This is a HACK!
  // This is *ONLY* because this is wrapping the MPL
  import AlgorithmSuites

  function GetCompatableCommitmentPolicy(algorithmSuite: Types.AlgorithmSuiteInfo)
    : (commitmentPolicy: Types.CommitmentPolicy)
  {
    match algorithmSuite.id
    case ESDK(_) =>
      if algorithmSuite.commitment.None? then
        Types.CommitmentPolicy.ESDK(Types.ESDKCommitmentPolicy.FORBID_ENCRYPT_ALLOW_DECRYPT)
      else
        Types.CommitmentPolicy.ESDK(Types.ESDKCommitmentPolicy.REQUIRE_ENCRYPT_REQUIRE_DECRYPT)
    case DBE(_) =>
      Types.CommitmentPolicy.DBE(Types.DBECommitmentPolicy.REQUIRE_ENCRYPT_REQUIRE_DECRYPT)
  }

  const ESDKAlgorithmSuites := set id: Types.ESDKAlgorithmSuiteId :: AlgorithmSuites.GetESDKSuite(id);

  const DBEAlgorithmSuites := set id: Types.DBEAlgorithmSuiteId :: AlgorithmSuites.GetDBESuite(id);

  const AllAlgorithmSuites := ESDKAlgorithmSuites + DBEAlgorithmSuites;

  lemma AllAlgorithmSuitesIsComplete(id: Types.AlgorithmSuiteId)
    ensures AlgorithmSuites.GetSuite(id) in AllAlgorithmSuites
  {}

  // const asdfasdf: map<string, Types.AlgorithmSuiteInfo> := map
  //                                                            s <- AllAlgorithmSuites
  //                                                            ::
  //                                                              ( HexStrings.ToHexStringIsInjective(); HexStrings.ToHexString(s.binaryId) ) := s;


  // datatype PositiveKeyDescription = PositiveKeyDescription(
  //   encryptDescription: TestVectors.KeyDescription,
  //   decryptDescription: TestVectors.KeyDescription
  // )

  datatype PositiveKeyDescriptionJSON = PositiveKeyDescriptionJSON(
    description: string,
    encrypt: JSON,
    decrypt: JSON
  )

  // These are all the PositiveKeyDescription for the RawAESKeyring
  const aesPersistentKeyNames := [ "aes-128", "aes-192", "aes-256"]
  const AllRawAES :=
    set
      key <- aesPersistentKeyNames
      ::
        var keyDescription := Object([
                                       ("type", String("raw")),
                                       ("encryption-algorithm", String("aes")),
                                       ("provider-id", String("aws-raw-vectors-persistent-" + key)),
                                       ("key", String(key))
                                     ]);
        PositiveKeyDescriptionJSON(
          description := "Generated RawAES " + key,
          encrypt := keyDescription,
          decrypt := keyDescription
        );

  // These are all the PositiveKeyDescription for the RawRSAKeyring
  const rsaPersistentKeyNamesWithoutPublicPrivate := [ "rsa-4096" ]
  const AllRawRSA :=
    set
      key <- rsaPersistentKeyNamesWithoutPublicPrivate,
      padding: Types.PaddingScheme
      ::
        var sharedOptions := [
                               ("type", String("raw")),
                               ("encryption-algorithm", String("rsa")),
                               ("provider-id", String("aws-raw-vectors-persistent-" + key)),
                               ("padding-algorithm", String(match padding
                                case PKCS1() => "pkcs1"
                                case _ => "oaep-mgf1"
                                )),
                               ("padding-hash", String(match padding
                                case PKCS1() => "sha1"
                                case OAEP_SHA1_MGF1() => "sha1"
                                case OAEP_SHA256_MGF1() => "sha256"
                                case OAEP_SHA384_MGF1() => "sha384"
                                case OAEP_SHA512_MGF1() => "sha512"
                                ))
                             ];
        PositiveKeyDescriptionJSON(
          description := "Generated RawRSA " + key + " "
          + match padding
            case PKCS1() => "pkcs1-sha1"
            case OAEP_SHA1_MGF1() => "oaep-mgf1-sha1"
            case OAEP_SHA256_MGF1() => "oaep-mgf1-sha256"
            case OAEP_SHA384_MGF1() => "oaep-mgf1-sha384"
            case OAEP_SHA512_MGF1() => "oaep-mgf1-sha512"
        ,
          encrypt := Object(
            sharedOptions +
            [("key", String(key + "-public"))]
          ),
          decrypt := Object(
            sharedOptions +
            [("key", String(key + "-private"))]
          )
        );

  const AllAwsKMSKeys := [ "us-west-2-decryptable", "us-west-2-mrk" ]
  const AllKMSInfo :=
    set
      key <- AllAwsKMSKeys
      ::
        var keyDescription := Object([
                                       ("type", String("aws-kms")),
                                       ("key", String(key))
                                     ]);
        PositiveKeyDescriptionJSON(
          description := "Generated KMS " + key,
          encrypt := keyDescription,
          decrypt := keyDescription
        );

  const AllAwsKMSMrkKeys := [ "us-west-2-mrk", "us-east-1-mrk" ]
  const AllKmsMrkAware :=
    set
      encryptKey <- AllAwsKMSMrkKeys,
      decryptKey <- AllAwsKMSMrkKeys
      ::
        PositiveKeyDescriptionJSON(
          description := "Generated KMS MRK " + encryptKey + "->" + decryptKey,
          encrypt := Object([
                              ("type", String("aws-kms-mrk-aware")),
                              ("key", String(encryptKey))
                            ]),
          decrypt := Object([
                              ("type", String("aws-kms-mrk-aware")),
                              ("key", String(decryptKey))
                            ])
        );

  // These values MUST corospond to the KMS keys above
  // At this time, this list is simplisitic
  const AwsPartitions := [ "aws" ];
  const AWSAccounts := [ "658956600833" ];
  const AllDiscoveryFilters := {
    Some(Types.DiscoveryFilter(
           partition := "aws",
           accountIds := [ "658956600833" ]
         )),
    Some(Types.DiscoveryFilter(
           partition := "aws",
           accountIds := [ ]
         )),
    None
  };

  // const AllKmsMrkAwareDiscovery :=
  //   set
  //     keyId <- AllAwsKMSKeys,
  //     filter <- AllDiscoveryFilters
  //     ::
  //       PositiveKeyDescription(
  //         encryptDescription := TestVectors.KmsMrkAware(
  //           key := keyId
  //         ),
  //         decryptDescription := TestVectors.KmsMrkAwareDiscovery(
  //           defaultMrkRegion := "us-west-2",
  //           awsKmsDiscoveryFilter := filter
  //         )
  //       );

  const AllPositiveKeyringTests :=
    set
      postiveKeyDescription <- AllKMSInfo +
      AllKmsMrkAware +
      // AllRawAES + // TODO need to fix one
      AllRawRSA,
      algorithmSuite <- AllAlgorithmSuites
      ::
        var id := HexStrings.ToHexString(algorithmSuite.binaryId);
        Object([
                 ("type", String("positive-keyring")),
                 ("description", String(postiveKeyDescription.description + " " + id)),
                 ("algorithmSuiteId", String(id)),
                 ("encryptionContext", Object([])),
                 ("requiredEncryptionContextKeys", Array([])),
                 ("encryptKeyDescription", postiveKeyDescription.encrypt),
                 ("decryptKeyDescription", postiveKeyDescription.decrypt)
               ]);

  method WriteStuff() {

    var tests := SortedSets.ComputeSetToSequence(AllPositiveKeyringTests);
    // So that we can build the tests
    var testsJSON: seq<(string, JSON)> := [];

    for i := 0 to |tests|
    {
      var name :- expect UUID.GenerateUUID();
      testsJSON := testsJSON + [(name, tests[i])];
    }

    var mplEncryptManifies := Object(
      [
        ("tests", Object(testsJSON))
      ]);

    var mplEncryptManifiesBytes :- expect API.Serialize(mplEncryptManifies);
    var mplEncryptManifiesBv := JSONHelpers.BytesBv(mplEncryptManifiesBytes);

    var _ :- expect FileIO.WriteBytesToFile(
      "dafny/TestVectorsAwsCryptographicMaterialProviders/test/test.json",
      mplEncryptManifiesBv
    );
  }

}