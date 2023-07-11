// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../Model/AwsCryptographyKeyStoreTypes.dfy"

module Structure {
  import opened Wrappers
  import opened UInt = StandardLibrary.UInt
  import Types = AwsCryptographyKeyStoreTypes
  import DDB = ComAmazonawsDynamodbTypes
  import KMS = ComAmazonawsKmsTypes
  import UTF8

  const KEY_CREATE_TIME := "create-time"
  const HIERARCHY_VERSION := "hierarchy-version"
  const TYPE_FIELD := "type"
  const BRANCH_KEY_IDENTIFIER_FIELD := "branch-key-id"
  const BRANCH_KEY_ACTIVE_VERSION_FIELD := "version"
  const TABLE_FIELD := "tablename"
  const KMS_FIELD := "kms-arn"
  const BRANCH_KEY_FIELD := "enc"

  const BRANCH_KEY_TYPE_PREFIX := "branch:version:"
  const BRANCH_KEY_ACTIVE_TYPE := "branch:ACTIVE"
  const BEACON_KEY_TYPE_VALUE := "beacon:ACTIVE"

  // A GenerateDataKeyWithoutPlaintext of request size 32 returns a ciphertext size of 184 bytes.
  const KMS_GEN_KEY_NO_PLAINTEXT_LENGTH_32 := 184

  type BranchKeyContext = m: map<string, string> | BranchKeyContext?(m) witness *
  predicate method BranchKeyContext?(m: map<string, string>) {
    && BRANCH_KEY_IDENTIFIER_FIELD in m
    && TYPE_FIELD in m
    && KEY_CREATE_TIME in m
    && HIERARCHY_VERSION in m
    && TABLE_FIELD in m
    && KMS_FIELD in m
    && (forall k <- m.Keys :: DDB.IsValid_AttributeName(k))
    && 0 < |m[BRANCH_KEY_IDENTIFIER_FIELD]|
    && (BRANCH_KEY_ACTIVE_VERSION_FIELD in m ==>
          && m[TYPE_FIELD] == BRANCH_KEY_ACTIVE_TYPE
          && BRANCH_KEY_TYPE_PREFIX < m[BRANCH_KEY_ACTIVE_VERSION_FIELD])
    && (BRANCH_KEY_ACTIVE_VERSION_FIELD !in m ==>
          || m[TYPE_FIELD] == BEACON_KEY_TYPE_VALUE
          || BRANCH_KEY_TYPE_PREFIX < m[TYPE_FIELD])
    && BRANCH_KEY_FIELD !in m.Keys
  }

  // We specify that every item on the encryption context to KMS is stored in the branch/beacon key item.
  // This method allows us to convert from a BranchKeyContext map to a DDB.AttributeMap easily.
  function method ToAttributeMap(
    encryptionContext: BranchKeyContext,
    encryptedKey: seq<uint8>
  ): (output: DDB.AttributeMap)
    requires KMS.IsValid_CiphertextType(encryptedKey)
    ensures BranchKeyItem?(output)
  {
    map k <- encryptionContext.Keys + {BRANCH_KEY_FIELD} - {TABLE_FIELD}
      :: k := match k
      case HIERARCHY_VERSION => DDB.AttributeValue.N(encryptionContext[HIERARCHY_VERSION])
      case BRANCH_KEY_FIELD => DDB.AttributeValue.B(encryptedKey)
      case _ => DDB.AttributeValue.S(encryptionContext[k])
  }

  function method ToBranchKeyContext(
    item: DDB.AttributeMap,
    logicalKeyStoreName: string
  ): (output: BranchKeyContext)
    requires BranchKeyItem?(item)
  {
    map k <- item.Keys + {TABLE_FIELD} - {BRANCH_KEY_FIELD}
      :: k := match k
      case HIERARCHY_VERSION => item[k].N
      case TABLE_FIELD => logicalKeyStoreName
      case _ => item[k].S
  }

  function method ToBranchKeyMaterials(
    encryptionContext: BranchKeyContext,
    plaintextKey: seq<uint8>
  ): (output: Result<Types.BranchKeyMaterials, Types.Error>)
    requires encryptionContext[TYPE_FIELD] != BEACON_KEY_TYPE_VALUE
  {
    var versionInformation := if BRANCH_KEY_ACTIVE_VERSION_FIELD in encryptionContext then
                                encryptionContext[BRANCH_KEY_ACTIVE_VERSION_FIELD]
                              else
                                encryptionContext[TYPE_FIELD];
    var branchKeyVersion := versionInformation[|BRANCH_KEY_TYPE_PREFIX|..];
    var branchKeyVersionUtf8 :- UTF8.Encode(branchKeyVersion)
                                .MapFailure(e => Types.KeyStoreException( message := e ));

    Success(Types.BranchKeyMaterials(
              branchKeyIdentifier := encryptionContext[BRANCH_KEY_IDENTIFIER_FIELD],
              branchKeyVersion := branchKeyVersionUtf8,
              branchKey := plaintextKey
            ))
  }

  function method ToBeaconKeyMaterials(
    encryptionContext: BranchKeyContext,
    plaintextKey: seq<uint8>
  ): (output: Result<Types.BeaconKeyMaterials, Types.Error>)
    requires encryptionContext[TYPE_FIELD] == BEACON_KEY_TYPE_VALUE
  {

    Success(Types.BeaconKeyMaterials(
              beaconKeyIdentifier := encryptionContext[BRANCH_KEY_IDENTIFIER_FIELD],
              beaconKey := Some(plaintextKey),
              hmacKeys := None
            ))
  }

  function method DecryptOnlyBranchKeyEncryptionContext(
    branchKeyId: string,
    branchKeyVersion: string,
    timestamp: string,
    logicalKeyStoreName: string,
    kmsKeyArn: string
  ): (output: map<string, string>)
    requires 0 < |branchKeyId|
    requires 0 < |branchKeyVersion|
    ensures BranchKeyContext?(output)
    ensures BRANCH_KEY_TYPE_PREFIX < output[TYPE_FIELD]
    ensures BRANCH_KEY_ACTIVE_VERSION_FIELD !in output
  {
    map[
      BRANCH_KEY_IDENTIFIER_FIELD := branchKeyId,
      TYPE_FIELD := BRANCH_KEY_TYPE_PREFIX + branchKeyVersion,
      KEY_CREATE_TIME := timestamp,
      TABLE_FIELD := logicalKeyStoreName,
      KMS_FIELD := kmsKeyArn,
      HIERARCHY_VERSION := "1"
    ]
  }

  function method ActiveBranchKeyEncryptionContext(
    decryptOnlyEncryptionContext: map<string, string>
  ): (output: map<string, string>)
    requires BranchKeyContext?(decryptOnlyEncryptionContext)
    requires
      && BRANCH_KEY_TYPE_PREFIX < decryptOnlyEncryptionContext[TYPE_FIELD]
      && BRANCH_KEY_ACTIVE_VERSION_FIELD !in decryptOnlyEncryptionContext
    ensures BranchKeyContext?(output)
    ensures BRANCH_KEY_ACTIVE_VERSION_FIELD in output
  {
    decryptOnlyEncryptionContext + map[
      BRANCH_KEY_ACTIVE_VERSION_FIELD := decryptOnlyEncryptionContext[TYPE_FIELD],
      TYPE_FIELD := BRANCH_KEY_ACTIVE_TYPE
    ]
  }

  function method BeaconKeyEncryptionContext(
    decryptOnlyEncryptionContext: map<string, string>
  ): (output: map<string, string>)
    requires BranchKeyContext?(decryptOnlyEncryptionContext)
    requires
      && BRANCH_KEY_TYPE_PREFIX < decryptOnlyEncryptionContext[TYPE_FIELD]
      && BRANCH_KEY_ACTIVE_VERSION_FIELD !in decryptOnlyEncryptionContext
    ensures BranchKeyContext?(output)
    ensures output[TYPE_FIELD] == BEACON_KEY_TYPE_VALUE
  {
    decryptOnlyEncryptionContext + map[
      TYPE_FIELD := BEACON_KEY_TYPE_VALUE
    ]
  }

  // function method GetBranchKeyVersion(
  //   encryptionContext: BranchKeyContext,
  // ): (version: Result<string, Types.Error>)
  //   requires BranchKeyContext?(decryptOnlyEncryptionContext)

  predicate method BranchKeyItem?(m: DDB.AttributeMap) {
    && BRANCH_KEY_IDENTIFIER_FIELD in m && m[BRANCH_KEY_IDENTIFIER_FIELD].S?
    && 0 < |m[BRANCH_KEY_IDENTIFIER_FIELD].S|
    && TYPE_FIELD in m && m[TYPE_FIELD].S?
    && KEY_CREATE_TIME in m && m[KEY_CREATE_TIME].S?
    && HIERARCHY_VERSION in m && m[HIERARCHY_VERSION].N?
    && KMS_FIELD in m && m[KMS_FIELD].S?
    && (BRANCH_KEY_ACTIVE_VERSION_FIELD in m ==>
          && m[TYPE_FIELD].S? && m[BRANCH_KEY_ACTIVE_VERSION_FIELD].S?
          && m[TYPE_FIELD].S == BRANCH_KEY_ACTIVE_TYPE
          && BRANCH_KEY_TYPE_PREFIX < m[BRANCH_KEY_ACTIVE_VERSION_FIELD].S
       )
    && (BRANCH_KEY_ACTIVE_VERSION_FIELD !in m ==>
          && m[TYPE_FIELD].S?
          && (m[TYPE_FIELD].S == BEACON_KEY_TYPE_VALUE || BRANCH_KEY_TYPE_PREFIX < m[TYPE_FIELD].S)
       )
    && BRANCH_KEY_FIELD in m && m[BRANCH_KEY_FIELD].B?
    && KMS.IsValid_CiphertextType(m[BRANCH_KEY_FIELD].B)
    && (forall k <- m.Keys - {BRANCH_KEY_FIELD, HIERARCHY_VERSION} :: m[k].S?)
  }

  type ActiveBranchKeyItem = m: DDB.AttributeMap | ActiveBranchKeyItem?(m) witness *
  predicate method ActiveBranchKeyItem?(m: DDB.AttributeMap) {
    && BranchKeyItem?(m)
    && m[TYPE_FIELD].S == BRANCH_KEY_ACTIVE_TYPE
    && BRANCH_KEY_ACTIVE_VERSION_FIELD in m && m[BRANCH_KEY_ACTIVE_VERSION_FIELD].S?
    && BRANCH_KEY_TYPE_PREFIX < m[BRANCH_KEY_ACTIVE_VERSION_FIELD].S
  }

  type VersionBranchKeyItem = m: DDB.AttributeMap | VersionBranchKeyItem?(m) witness *
  predicate method VersionBranchKeyItem?(m: DDB.AttributeMap) {
    && BranchKeyItem?(m)
    && BRANCH_KEY_ACTIVE_VERSION_FIELD !in m
    && BRANCH_KEY_TYPE_PREFIX < m[TYPE_FIELD].S
  }

  type BeaconKeyItem = m: DDB.AttributeMap | BeaconKeyItem?(m) witness *
  predicate method BeaconKeyItem?(m: DDB.AttributeMap) {
    && BranchKeyItem?(m)
    && BRANCH_KEY_ACTIVE_VERSION_FIELD !in m
    && m[TYPE_FIELD].S == BEACON_KEY_TYPE_VALUE
  }

  lemma BranchKeyItemsDoNotCollide(a: ActiveBranchKeyItem, b: VersionBranchKeyItem, c: BeaconKeyItem)
    requires a[BRANCH_KEY_IDENTIFIER_FIELD] == b[BRANCH_KEY_IDENTIFIER_FIELD] == c[BRANCH_KEY_IDENTIFIER_FIELD]
    ensures a[TYPE_FIELD] != b[TYPE_FIELD]
    ensures a[TYPE_FIELD] != c[TYPE_FIELD]
    ensures c[TYPE_FIELD] != b[TYPE_FIELD]
  {}

  lemma ToAttributeMapIsCorrect(
    encryptionContext: BranchKeyContext,
    encryptedKey: seq<uint8>,
    item: DDB.AttributeMap
  )
    requires KMS.IsValid_CiphertextType(encryptedKey)
    requires item == ToAttributeMap(encryptionContext, encryptedKey)
    ensures item.Keys == encryptionContext.Keys + {BRANCH_KEY_FIELD} - {TABLE_FIELD}
    ensures item[BRANCH_KEY_FIELD].B == encryptedKey
    ensures
      && (forall k <- item.Keys - {BRANCH_KEY_FIELD, HIERARCHY_VERSION}
            ::
              && item[k].S?
              && encryptionContext[k] == item[k].S
         )
      && encryptionContext[HIERARCHY_VERSION] == item[HIERARCHY_VERSION].N
  {}

  lemma EncryptionContextConstructorsAreCorrect(
    branchKeyId: string,
    branchKeyVersion: string,
    timestamp: string,
    logicalKeyStoreName: string,
    kmsKeyArn: string
  )
    requires 0 < |branchKeyId|
    requires 0 < |branchKeyVersion|

    ensures
      var decryptOnly := DecryptOnlyBranchKeyEncryptionContext(branchKeyId, branchKeyVersion, timestamp, logicalKeyStoreName, kmsKeyArn);
      var active := ActiveBranchKeyEncryptionContext(decryptOnly);
      var beacon := BeaconKeyEncryptionContext(decryptOnly);
      && decryptOnly[TYPE_FIELD] != active[TYPE_FIELD]
      && decryptOnly[TYPE_FIELD] != beacon[TYPE_FIELD]
      && active[TYPE_FIELD] != beacon[TYPE_FIELD]
      && (forall k <- decryptOnly.Keys - {TYPE_FIELD} ::
            && decryptOnly[k] == active[k] == beacon[k]
         )
      && active[BRANCH_KEY_ACTIVE_VERSION_FIELD] == decryptOnly[TYPE_FIELD]
  {}

  lemma ToAttributeMapAndToBranchKeyContextAreInverse(
    encryptionContext: BranchKeyContext,
    encryptedKey: seq<uint8>,
    item: DDB.AttributeMap
  )
    requires KMS.IsValid_CiphertextType(encryptedKey)
    requires item == ToAttributeMap(encryptionContext, encryptedKey)
    ensures ToBranchKeyContext(item, encryptionContext[TABLE_FIELD]) == encryptionContext
  {}

}
