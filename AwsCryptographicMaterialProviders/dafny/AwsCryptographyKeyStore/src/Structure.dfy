// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../Model/AwsCryptographyKeyStoreTypes.dfy"

module {:options "/functionSyntax:4" } Structure {
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
  predicate BranchKeyContext?(m: map<string, string>) {
    && BRANCH_KEY_IDENTIFIER_FIELD in m
    && TYPE_FIELD in m
    && KEY_CREATE_TIME in m
    && HIERARCHY_VERSION in m
    && TABLE_FIELD in m
    && KMS_FIELD in m

    //= aws-encryption-sdk-specification/framework/branch-key-store.md#authenticating-a-keystore-item
    //# The key `enc` MUST NOT exist in the constructed [encryption context](#encryption-context).
    && BRANCH_KEY_FIELD !in m.Keys

    && 0 < |m[BRANCH_KEY_IDENTIFIER_FIELD]|

    && (forall k <- m.Keys :: DDB.IsValid_AttributeName(k))

    && (BRANCH_KEY_ACTIVE_VERSION_FIELD in m ==>
          && m[TYPE_FIELD] == BRANCH_KEY_ACTIVE_TYPE
          && BRANCH_KEY_TYPE_PREFIX < m[BRANCH_KEY_ACTIVE_VERSION_FIELD])
    && (BRANCH_KEY_ACTIVE_VERSION_FIELD !in m ==>
          || m[TYPE_FIELD] == BEACON_KEY_TYPE_VALUE
          || BRANCH_KEY_TYPE_PREFIX < m[TYPE_FIELD])

  }

  function ToAttributeMap(
    encryptionContext: BranchKeyContext,
    encryptedKey: seq<uint8>
  ): (output: DDB.AttributeMap)
    requires KMS.IsValid_CiphertextType(encryptedKey)
    ensures BranchKeyItem?(output)
    ensures ToBranchKeyContext(output, encryptionContext[TABLE_FIELD]) == encryptionContext
  {
    map k <- encryptionContext.Keys + {BRANCH_KEY_FIELD} - {TABLE_FIELD}
      :: k := match k
      case HIERARCHY_VERSION => DDB.AttributeValue.N(encryptionContext[HIERARCHY_VERSION])
      case BRANCH_KEY_FIELD => DDB.AttributeValue.B(encryptedKey)
      case _ => DDB.AttributeValue.S(encryptionContext[k])
  }

  function ToBranchKeyContext(
    item: DDB.AttributeMap,
    logicalKeyStoreName: string
  ): (output: BranchKeyContext)
    requires BranchKeyItem?(item)
  {
    map k <- item.Keys - {BRANCH_KEY_FIELD} + {TABLE_FIELD}
      :: k := match k
      case HIERARCHY_VERSION => item[k].N
      case TABLE_FIELD => logicalKeyStoreName
      case _ => item[k].S
  }

  function ToBranchKeyMaterials(
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
              branchKey := plaintextKey,
              encryptionContext := map[]
            ))
  }

  function ToBeaconKeyMaterials(
    encryptionContext: BranchKeyContext,
    plaintextKey: seq<uint8>
  ): (output: Result<Types.BeaconKeyMaterials, Types.Error>)
    requires encryptionContext[TYPE_FIELD] == BEACON_KEY_TYPE_VALUE
  {

    Success(Types.BeaconKeyMaterials(
              beaconKeyIdentifier := encryptionContext[BRANCH_KEY_IDENTIFIER_FIELD],
              beaconKey := Some(plaintextKey),
              hmacKeys := None,
              encryptionContext := map[]
            ))
  }

  function DecryptOnlyBranchKeyEncryptionContext(
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

  function ActiveBranchKeyEncryptionContext(
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

  function BeaconKeyEncryptionContext(
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

  function NewVersionFromActiveBranchKeyEncryptionContext(
    activeBranchKeyEncryptionContext: map<string, string>,
    branchKeyVersion: string,
    timestamp: string
  ): (output: map<string, string>)
    requires BranchKeyContext?(activeBranchKeyEncryptionContext)
    requires BRANCH_KEY_ACTIVE_VERSION_FIELD in activeBranchKeyEncryptionContext
    requires 0 < |branchKeyVersion|

    ensures BranchKeyContext?(output)
    ensures BRANCH_KEY_TYPE_PREFIX < output[TYPE_FIELD]
    ensures BRANCH_KEY_ACTIVE_VERSION_FIELD !in output
  {
    activeBranchKeyEncryptionContext
    + map[
      TYPE_FIELD := BRANCH_KEY_TYPE_PREFIX + branchKeyVersion,
      KEY_CREATE_TIME := timestamp
    ]
    - {BRANCH_KEY_ACTIVE_VERSION_FIELD}
  }



  type BranchKeyItem = m: DDB.AttributeMap | BranchKeyItem?(m) witness *
  predicate BranchKeyItem?(m: DDB.AttributeMap) {
    && BRANCH_KEY_IDENTIFIER_FIELD in m && m[BRANCH_KEY_IDENTIFIER_FIELD].S?
    && TYPE_FIELD in m && m[TYPE_FIELD].S?
    && KEY_CREATE_TIME in m && m[KEY_CREATE_TIME].S?
    && HIERARCHY_VERSION in m && m[HIERARCHY_VERSION].N?
    && TABLE_FIELD !in m
    && KMS_FIELD in m && m[KMS_FIELD].S?
    && BRANCH_KEY_FIELD in m && m[BRANCH_KEY_FIELD].B?

    && 0 < |m[BRANCH_KEY_IDENTIFIER_FIELD].S|

    && (forall k <- m.Keys - {BRANCH_KEY_FIELD, HIERARCHY_VERSION} :: m[k].S?)

    && (BRANCH_KEY_ACTIVE_VERSION_FIELD in m ==>
          && m[TYPE_FIELD].S == BRANCH_KEY_ACTIVE_TYPE
          && BRANCH_KEY_TYPE_PREFIX < m[BRANCH_KEY_ACTIVE_VERSION_FIELD].S)
    && (BRANCH_KEY_ACTIVE_VERSION_FIELD !in m ==>
          || m[TYPE_FIELD].S == BEACON_KEY_TYPE_VALUE
          || BRANCH_KEY_TYPE_PREFIX < m[TYPE_FIELD].S)

    && KMS.IsValid_CiphertextType(m[BRANCH_KEY_FIELD].B)
  }

  type ActiveBranchKeyItem = m: DDB.AttributeMap | ActiveBranchKeyItem?(m) witness *
  predicate ActiveBranchKeyItem?(m: DDB.AttributeMap) {
    && BranchKeyItem?(m)
    && m[TYPE_FIELD].S == BRANCH_KEY_ACTIVE_TYPE
    && BRANCH_KEY_ACTIVE_VERSION_FIELD in m && m[BRANCH_KEY_ACTIVE_VERSION_FIELD].S?
    && BRANCH_KEY_TYPE_PREFIX < m[BRANCH_KEY_ACTIVE_VERSION_FIELD].S
  }

  type VersionBranchKeyItem = m: DDB.AttributeMap | VersionBranchKeyItem?(m) witness *
  predicate VersionBranchKeyItem?(m: DDB.AttributeMap) {
    && BranchKeyItem?(m)
    && BRANCH_KEY_ACTIVE_VERSION_FIELD !in m
    && BRANCH_KEY_TYPE_PREFIX < m[TYPE_FIELD].S
  }

  type BeaconKeyItem = m: DDB.AttributeMap | BeaconKeyItem?(m) witness *
  predicate BeaconKeyItem?(m: DDB.AttributeMap) {
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

  lemma ToBranchKeyContextIsCorrect(
    encryptionContext: map<string, string>,
    logicalKeyStoreName: string,
    item: DDB.AttributeMap
  )
    requires BranchKeyItem?(item)
    requires encryptionContext == ToBranchKeyContext(item, logicalKeyStoreName)

    ensures encryptionContext.Keys == item.Keys - {BRANCH_KEY_FIELD} + {TABLE_FIELD}
    ensures encryptionContext[TABLE_FIELD] == logicalKeyStoreName

    //= aws-encryption-sdk-specification/framework/branch-key-store.md#authenticating-a-keystore-item
    //= type=implication
    //# Every key in the constructed [encryption context](#encryption-context)
    //# except `tableName`
    //# MUST exist as a string attribute in the AWS DDB response item.
    ensures
      forall k <- encryptionContext.Keys - {BRANCH_KEY_FIELD, TABLE_FIELD}
        ::
          //= aws-encryption-sdk-specification/framework/branch-key-store.md#authenticating-a-keystore-item
          //= type=implication
          //# Every value in the constructed [encryption context](#encryption-context)
          //# except the logical table name
          //# MUST equal the value with the same key in the AWS DDB response item.
          match k
          case HIERARCHY_VERSION => encryptionContext[k] == item[k].N
          case _ => encryptionContext[k] == item[k].S

    //= aws-encryption-sdk-specification/framework/branch-key-store.md#authenticating-a-keystore-item
    //= type=implication
    //# The key `enc` MUST NOT exist in the constructed [encryption context](#encryption-context).
    ensures BRANCH_KEY_FIELD !in encryptionContext
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
    encryptionContext: map<string, string>,
    item: DDB.AttributeMap
  )
    requires BranchKeyItem?(item) && BranchKeyContext?(encryptionContext)
    ensures
      item == ToAttributeMap(encryptionContext, item[BRANCH_KEY_FIELD].B)
      <==>
      ToBranchKeyContext(item, encryptionContext[TABLE_FIELD]) == encryptionContext
  {}

}
