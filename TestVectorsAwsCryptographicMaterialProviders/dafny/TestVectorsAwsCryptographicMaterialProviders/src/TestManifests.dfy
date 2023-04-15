// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "TestVectors.dfy"
include "ParseJsonManifests.dfy"

module {:options "-functionSyntax:4"} TestManifests {
  import opened Wrappers
  import TestVectors
  import FileIO
  import JSON.API
  import JSON.AST
  import BoundedInts
  import opened JSONHelpers
  import ParseJsonManifests

  method  {:options "-functionSyntax:4"} StartEncrypt(encryptManifestPath: string) 
  {
    var encryptManifestBv :- expect FileIO.ReadBytesFromFile(encryptManifestPath);
    var encryptManifestBytes := BvToBytes(encryptManifestBv);
    var encryptManifestJSON :- expect API.Deserialize(encryptManifestBytes);
    expect encryptManifestJSON.Object?;

    var keysManifest :- expect Get("keys", encryptManifestJSON.obj);
    expect keysManifest.Object?;
    var keysObject :- expect Get("keys", keysManifest.obj);
    expect keysObject.Object?;
    var keys :- expect ParseJsonManifests.BuildKeyMaterials(keysObject.obj);

    var jsonTests :- expect GetObject("tests", encryptManifestJSON.obj);
    var encryptVectors :- expect ParseJsonManifests.BuildEncryptTestVector(keys, jsonTests);

    var encryptTests :- expect ToEncryptTests(encryptVectors);

    var decryptTests := TestEncrypt(encryptTests);
    var _ := TestDecrypt(decryptTests);
  }

  method TestEncrypt(tests: seq<TestVectors.EncryptTest>)
    returns (output: seq<TestVectors.DecryptTest>)
    requires forall t <- tests :: t.cmm.ValidState()
    modifies set t <- tests, o | o in t.cmm.Modifies :: o
    ensures forall t <- tests :: t.cmm.ValidState()
    ensures forall t <- output ::
      && t.cmm.ValidState()
      && fresh(t.cmm.Modifies)
  {
    var hasFailure := false;

    print "Starting Encrypt Tests \n\n";

    for i := 0 to |tests|
      invariant forall t <- tests :: t.cmm.ValidState()
    {
      var pass := TestVectors.TestGetEncryptionMaterials(tests[i]);
      if !pass {
        hasFailure := true;
      }
    }
    expect !hasFailure;
    output :- expect ToDecryptTest(tests);
  }

  method TestDecrypt(tests: seq<TestVectors.DecryptTest>)
    returns (manifest: seq<BoundedInts.byte>)
    requires forall t <- tests :: t.cmm.ValidState()
    modifies set t <- tests, o | o in t.cmm.Modifies :: o
    ensures forall t <- tests :: t.cmm.ValidState()
  {
    var hasFailure := false;

    for i := 0 to |tests|
      invariant forall t <- tests :: t.cmm.ValidState()
    {
      var pass := TestVectors.TestDecryptMaterials(tests[i]);
      if !pass {
        hasFailure := true;
      }
    }
    expect !hasFailure;

    manifest := ToJSONDecryptManifiest(tests);
  }

  method ToEncryptTests(encryptVectors: seq<TestVectors.EncryptTestVector>)
    returns (output: Result<seq<TestVectors.EncryptTest>, string>)
    ensures output.Success? ==>
      && forall t <- output.value ::
        && t.cmm.ValidState()
        && fresh(t.cmm.Modifies)
  {
    var encryptTests: seq<TestVectors.EncryptTest> := [];
    for i := 0 to |encryptVectors|
      invariant forall t <- encryptTests ::
        && t.cmm.ValidState()
        && fresh(t.cmm.Modifies)
    {
      var test :- TestVectors.ToEncryptTest(encryptVectors[i]);
      encryptTests := encryptTests + [test];
    }

    return Success(encryptTests);
  }

  method ToDecryptTest(tests: seq<TestVectors.EncryptTest>)
    returns (output: Result<seq<TestVectors.DecryptTest>, string>)
    ensures output.Success? ==>
      && forall t <- output.value ::
        && t.cmm.ValidState()
        && fresh(t.cmm.Modifies)
  {
    return Success([]);
  }

  function ToJSONDecryptManifiest(tests: seq<TestVectors.DecryptTest>)
    : seq<BoundedInts.byte>
  {
    []
  }

}