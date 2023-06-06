namespace aws.cryptography.materialProviders

use aws.polymorph#reference
use aws.polymorph#positional
use aws.polymorph#extendable
use aws.polymorph#javadoc

use com.amazonaws.kms#EncryptionAlgorithmSpec

@extendable
resource Keyring {
  operations: [OnEncrypt, OnDecrypt]
}

/////////////////////
// Keyring Structures

@reference(resource: Keyring)
structure KeyringReference {}

list KeyringList {
  member: KeyringReference
}

@javadoc("A filter which defines what AWS partition and AWS accounts a KMS Key may be in for a Keyring to be allowed to attempt to decrypt it.")
structure DiscoveryFilter {
  @required
  @javadoc("A list of allowed AWS account IDs.")
  accountIds: AccountIdList,

  @required
  @javadoc("The AWS partition which is allowed.")
  partition: String
}

// Grant Tokens are base64 encoded strings
// https://docs.aws.amazon.com/kms/latest/developerguide/grants.html#grant_token
// We could theoretically put a @pattern trait here limited to base64 characters,
// but the actual Coral model/API docs for KMS don't include this constraint:
// https://docs.aws.amazon.com/kms/latest/APIReference/API_CreateGrant.html
// For now we'll mirror the API docs (generated from the model) and omit the pattern.
list GrantTokenList {
  member: String
}


/////////////////////
// Keyring Operations

//= aws-encryption-sdk-specification/framework/keyring-interface.md#onencrypt
//= type=implication
//# This interface MUST take [encryption materials](structures.md#encryption-materials) as input.
operation OnEncrypt {
  input: OnEncryptInput,
  output: OnEncryptOutput,
}

structure OnEncryptInput {
  @required
  materials: EncryptionMaterials
}

structure OnEncryptOutput {
  @required
  materials: EncryptionMaterials
}

//= aws-encryption-sdk-specification/framework/keyring-interface.md#ondecrypt
//= type=implication
//# This interface MUST take [decryption materials](structures.md#decryption-materials) and
//# a list of [encrypted data keys](structures.md#encrypted-data-key) as input.
operation OnDecrypt {
  input: OnDecryptInput,
  output: OnDecryptOutput,
}

structure OnDecryptInput {
  @required
  materials: DecryptionMaterials,

  @required
  encryptedDataKeys: EncryptedDataKeyList
}

structure OnDecryptOutput {
  @required
  materials: DecryptionMaterials
}


///////////////////////
// Keyring Constructors

@positional
@javadoc("Outputs for creating a Keyring.")
structure CreateKeyringOutput {
  @required
  @javadoc("The created Keyring.")
  keyring: KeyringReference
}

// KMS - Strict
@javadoc("Creates an AWS KMS Keyring, which wraps and unwraps data keys using single symmetric AWS KMS Key.")
operation CreateAwsKmsKeyring {
  input: CreateAwsKmsKeyringInput,
  output: CreateKeyringOutput
}
@javadoc("Inputs for for creating a AWS KMS Keyring.")
structure CreateAwsKmsKeyringInput {
  @required
  @javadoc("The identifier for the symmetric AWS KMS Key responsible for wrapping and unwrapping data keys. This should not be a AWS KMS Multi-Region Key.")
  kmsKeyId: KmsKeyId,

  @required
  @javadoc("The KMS Client this Keyring will use to call KMS.")
  kmsClient: KmsClientReference,

  @javadoc("A list of grant tokens to be used when calling KMS.")
  grantTokens: GrantTokenList
}

@javadoc("Creates an AWS KMS Multi-Keyring, which wraps and unwraps data keys using one or more symmetric AWS KMS Keys.")
operation CreateAwsKmsMultiKeyring {
  input: CreateAwsKmsMultiKeyringInput,
  output: CreateKeyringOutput,
}

@javadoc("Inputs for for creating a AWS KMS Multi-Keyring.")
structure CreateAwsKmsMultiKeyringInput {
  @javadoc("A identifier for a symmetric AWS KMS Key responsible for wrapping and unwrapping data keys. KMS.GenerateDataKey may be called with this key if the data key has not already been generated by another Keyring. This should not be a AWS KMS Multi-Region Key.")
  generator:  KmsKeyId,

  @javadoc("A list of identifiers for the symmetric AWS KMS Keys (other than the generator) responsible for wrapping and unwrapping data keys. This list should not contain AWS KMS Multi-Region Keys.")
  kmsKeyIds: KmsKeyIdList,

  @javadoc("The Client Supplier which will be used to get KMS Clients for use with this Keyring. The Client Supplier will create a client for each region specified in the generator and kmsKeyIds ARNs. If not specified on input, the Default Client Supplier is used.")
  clientSupplier: ClientSupplierReference,

  @javadoc("A list of grant tokens to be used when calling KMS.")
  grantTokens: GrantTokenList
}

// KMS - Discovery
@javadoc("Creates an AWS KMS Discovery Keyring, which supports unwrapping data keys wrapped by a symmetric AWS KMS Key for a single region.")
operation CreateAwsKmsDiscoveryKeyring {
  input: CreateAwsKmsDiscoveryKeyringInput,
  output: CreateKeyringOutput
}

@javadoc("Inputs for for creating a AWS KMS Discovery Keyring.")
structure CreateAwsKmsDiscoveryKeyringInput {
  @required
  @javadoc("The KMS Client this Keyring will use to call KMS.")
  kmsClient: KmsClientReference,

  @javadoc("A filter which restricts which KMS Keys this Keyring may attempt to decrypt with by AWS partition and account.")
  discoveryFilter: DiscoveryFilter,

  @javadoc("A list of grant tokens to be used when calling KMS.")
  grantTokens: GrantTokenList
}

@javadoc("Creates an AWS KMS Discovery Multi-Keyring, which supports unwrapping data keys wrapped by a symmetric AWS KMS Key, for multiple regions.")
operation CreateAwsKmsDiscoveryMultiKeyring {
  input: CreateAwsKmsDiscoveryMultiKeyringInput,
  output: CreateKeyringOutput,
}

@javadoc("Inputs for for creating an AWS KMS Discovery Multi-Keyring.")
structure CreateAwsKmsDiscoveryMultiKeyringInput {
  @required
  @javadoc("The list of regions this Keyring will creates KMS clients for.")
  regions: RegionList,

  @javadoc("A filter which restricts which KMS Keys this Keyring may attempt to decrypt with by AWS partition and account.")
  discoveryFilter: DiscoveryFilter,

  @javadoc("The Client Supplier which will be used to get KMS Clients for use with this Keyring. If not specified on input, a Default Client Supplier is created which creates a KMS Client for each region in the 'regions' input.")
  clientSupplier: ClientSupplierReference,

  @javadoc("A list of grant tokens to be used when calling KMS.")
  grantTokens: GrantTokenList
}

// KMS - MRK Aware, Strict
@javadoc("Creates an AWS KMS MRK Keyring, which wraps and unwraps data keys using single symmetric AWS KMS Key or AWS KMS Multi-Region Key.")
operation CreateAwsKmsMrkKeyring {
  input: CreateAwsKmsMrkKeyringInput,
  output: CreateKeyringOutput,
}

@javadoc("Inputs for for creating an AWS KMS MRK Keyring.")
structure CreateAwsKmsMrkKeyringInput {
  @required
  @javadoc("The identifier for the symmetric AWS KMS Key or AWS KMS Multi-Region Key responsible for wrapping and unwrapping data keys.")
  kmsKeyId: KmsKeyId,

  @required
  @javadoc("The KMS Client this Keyring will use to call KMS.")
  kmsClient: KmsClientReference,

  @javadoc("A list of grant tokens to be used when calling KMS.")
  grantTokens: GrantTokenList
}

@javadoc("Creates an AWS KMS MRK Multi-Keyring, which wraps and unwraps data keys using one or more symmetric AWS KMS Keys or AWS KMS Multi-Region Keys.")
operation CreateAwsKmsMrkMultiKeyring {
  input: CreateAwsKmsMrkMultiKeyringInput,
  output: CreateKeyringOutput,
}

@javadoc("Inputs for for creating a AWS KMS MRK Multi-Keyring.")
structure CreateAwsKmsMrkMultiKeyringInput {
  @javadoc("A symmetric AWS KMS Key or AWS KMS Multi-Region Key responsible for wrapping and unwrapping data keys. KMS.GenerateDataKey may be called with this key if the data key has not already been generated by another Keyring.")
  generator:  KmsKeyId,

  @javadoc("A list of identifiers for the symmetric AWS KMS Keys and/or AWS KMS Multi-Region Keys (other than the generator) responsible for wrapping and unwrapping data keys.")
  kmsKeyIds: KmsKeyIdList,

  @javadoc("The Client Supplier which will be used to get KMS Clients for use with this Keyring. The Client Supplier will create a client for each region specified in the generator and kmsKeyIds ARNs. If not specified on input, the Default Client Supplier is used.")
  clientSupplier: ClientSupplierReference,

  @javadoc("A list of grant tokens to be used when calling KMS.")
  grantTokens: GrantTokenList
}

// KMS - MRK Aware, Discovery

@javadoc("Creates an AWS KMS MRK Discovery Keyring, which supports unwrapping data keys wrapped by a symmetric AWS KMS Key or AWS KMS Multi-Region Key in a particular region.")
operation CreateAwsKmsMrkDiscoveryKeyring {
  input: CreateAwsKmsMrkDiscoveryKeyringInput,
  output: CreateKeyringOutput,
}

@javadoc("Inputs for for creating a AWS KMS MRK Discovery Keyring.")
structure CreateAwsKmsMrkDiscoveryKeyringInput {
  @required
  @javadoc("The KMS Client this Keyring will use to call KMS.")
  kmsClient: KmsClientReference,

  @javadoc("A filter which restricts which KMS Keys this Keyring may attempt to decrypt with by AWS partition and account.")
  discoveryFilter: DiscoveryFilter,

  @javadoc("A list of grant tokens to be used when calling KMS.")
  grantTokens: GrantTokenList,

  @required
  @javadoc("The region the input 'kmsClient' is in.")
  region: Region
}

@javadoc("Creates an AWS KMS MRK Discovery Multi-Keyring that supports unwrapping data keys wrapped by a symmetric AWS KMS Key or AWS KMS Multi-Region Key, for a single region.")
operation CreateAwsKmsMrkDiscoveryMultiKeyring {
  input: CreateAwsKmsMrkDiscoveryMultiKeyringInput,
  output: CreateKeyringOutput,
}

@javadoc("Inputs for for creating a AWS KMS MRK Discovery Multi-Keyring.")
structure CreateAwsKmsMrkDiscoveryMultiKeyringInput {
  @required
  @javadoc("The list of regions this Keyring will creates KMS clients for.")
  regions: RegionList,

  @javadoc("A filter which restricts which KMS Keys this Keyring may attempt to decrypt with by AWS partition and account.")
  discoveryFilter: DiscoveryFilter,

  @javadoc("The Client Supplier which will be used to get KMS Clients for use with this Keyring. If not specified on input, a Default Client Supplier is created which creates a KMS Client for each region in the 'regions' input.")
  clientSupplier: ClientSupplierReference,

  @javadoc("A list of grant tokens to be used when calling KMS.")
  grantTokens: GrantTokenList
}

// Multi

@javadoc("Creates a Multi-Keyring comprised of one or more other Keyrings.")
operation CreateMultiKeyring {
  input: CreateMultiKeyringInput,
  output: CreateKeyringOutput,
}

@javadoc("Inputs for creating a Multi-Keyring.")
structure CreateMultiKeyringInput {
  @javadoc("A keyring responsible for wrapping and unwrapping the data key. This is the first keyring that will be used to wrap the data key, and may be responsible for additionally generating the data key.")
  generator: KeyringReference,

  // We'll represent "no children" as an empty list
  @required
  @javadoc("A list of keyrings (other than the generator) responsible for wrapping and unwrapping the data key.")
  childKeyrings: KeyringList
}

// KMS - Hierarchical Keyring
@javadoc("Creates a Hierarchical Keyring, which supports wrapping and unwrapping data keys using Branch Keys persisted in DynamoDB and protected by a symmetric AWS KMS Key or AWS KMS Multi-Region Key.")
operation CreateAwsKmsHierarchicalKeyring {
    input: CreateAwsKmsHierarchicalKeyringInput,
    output: CreateKeyringOutput,
}

@extendable
resource BranchKeyIdSupplier {
  operations: [GetBranchKeyId],
}

@reference(resource: BranchKeyIdSupplier)
structure BranchKeyIdSupplierReference {}

@javadoc("Given the Encryption Context associated with this encryption or decryption, returns the branch key that should be responsible for unwrapping or wrapping the data key.")
operation GetBranchKeyId {
  input: GetBranchKeyIdInput,
  output: GetBranchKeyIdOutput
}

@javadoc("Inputs for determining the Branch Key which should be used to wrap or unwrap the data key for this encryption or decryption")
structure GetBranchKeyIdInput {
  @required
  @javadoc("The Encryption Context used with this encryption or decryption.")
  encryptionContext: EncryptionContext
}

@javadoc("Outputs for the Branch Key repsonsible for wrapping or unwrapping the data key in this encryption or decryption.")
structure GetBranchKeyIdOutput {
  @required
  @javadoc("The identifier of the Branch Key that should be responsible for wrapping or unwrapping the data key in this encryption or decryption.")
  branchKeyId: String
}

@javadoc("Inputs for creating a Hierarchical Keyring.")
structure CreateAwsKmsHierarchicalKeyringInput {
    // branchKeyId XOR BranchKeyIdSupplier required
    @javadoc("The identifier for the single Branch Key repsonsible for wrapping and unwrapping the data key. Either a Branch Key ID or Branch Key Supplier must be specified.")
    branchKeyId: String,
    @javadoc("A Branch Key Supplier which determines what Branch Key to use to wrap and unwrap the data key. Either a Branch Key ID or Branch Key Supplier must be specified.")
    branchKeyIdSupplier: BranchKeyIdSupplierReference,

    @required
    @javadoc("The Key Store which contains the Branch Key(s) responsible for wrapping and unwrapping data keys.")
    keyStore: KeyStoreReference,
    
    @required
    @javadoc("How many seconds the Branch Key material is allowed to be reused within the local cache before it is re-retrieved from Amazon DynamoDB and re-authenticated with AWS KMS.")
    ttlSeconds: PositiveLong,

    @javadoc("How many entries the local cache for Branch Key material can hold before evicting older entries.")
    maxCacheSize: PositiveInteger
}

// Raw

@javadoc("Creates a Raw AES Keyring, which wraps and unwraps data keys locally using AES_GCM.")
operation CreateRawAesKeyring {
  input: CreateRawAesKeyringInput,
  output: CreateKeyringOutput,
}

@javadoc("Inputs for creating a Raw AES Keyring.")
structure CreateRawAesKeyringInput {
  @required
  @javadoc("A namespace associated with this wrapping key.")
  keyNamespace: String,

  @required
  @javadoc("A name associated with this wrapping key.")
  keyName: String,

  @required
  @javadoc("The AES key used with AES_GCM encryption and decryption.")
  wrappingKey: Blob,

  @required
  @javadoc("The AES_GCM algorithm this Keyring uses to wrap and unwrap data keys.")
  wrappingAlg: AesWrappingAlg,
}

 @javadoc("Creates a Raw RSA Keyring, which wraps and unwraps data keys locally using RSA.")
 operation CreateRawRsaKeyring {
   input: CreateRawRsaKeyringInput,
   output: CreateKeyringOutput,
 }

 @javadoc("Inputs for creating a Raw RAW Keyring.")
 structure CreateRawRsaKeyringInput {
   @required
   @javadoc("A namespace associated with this wrapping key.")
   keyNamespace: String,

   @required
   @javadoc("A name associated with this wrapping key.")
   keyName: String,

   @required
   @javadoc("The RSA padding scheme to use with this keyring.")
   paddingScheme: PaddingScheme,

   // One or both is required
   @javadoc("The public RSA Key responsible for wrapping data keys, as a UTF8 encoded, PEM encoded X.509 SubjectPublicKeyInfo structure. If not specified, this Keyring cannot be used on encrypt. A public key and/or a private key must be specified.")
   publicKey: Blob,
   @javadoc("The private RSA Key responsible for wrapping data keys, as a UTF8 encoded, PEM encoded PKCS #8 PrivateKeyInfo structure. If not specified, this Keyring cannot be used on decrypt. A public key and/or a private key must be specified.")
   privateKey: Blob
 }

  @javadoc("Creates an AWS KMS RSA Keyring, which wraps and unwraps data keys using a single asymmetric AWS KMS Key for RSA.")
  operation CreateAwsKmsRsaKeyring {
    input: CreateAwsKmsRsaKeyringInput,
    output: CreateKeyringOutput,
  }

  @javadoc("Inputs for creating a AWS KMS RSA Keyring.")
  structure CreateAwsKmsRsaKeyringInput {
    //= aws-encryption-sdk-specification/framework/aws-kms/aws-kms-rsa-keyring.md#initialization
    //= type=implication
    //# - MAY provide a PEM encoded Public Key
    @javadoc("The public RSA Key responsible for wrapping data keys, as a UTF8 encoded, PEM encoded X.509 SubjectPublicKeyInfo structure. This should be the public key as exported from KMS. If not specified, this Keyring cannot be used on encrypt.")
    publicKey: Secret,
    //= aws-encryption-sdk-specification/framework/aws-kms/aws-kms-rsa-keyring.md#initialization
    //= type=implication
    //# - MUST provide an AWS KMS key identifier
    @required
    @javadoc("The ARN for the asymmetric AWS KMS Key for RSA responsible for wrapping and unwrapping data keys.")
    kmsKeyId: KmsKeyId,
    //= aws-encryption-sdk-specification/framework/aws-kms/aws-kms-rsa-keyring.md#initialization
    //= type=implication
    //# - MUST provide an [AWS KMS Encryption Algorithm](#supported-padding-schemes)
    @required
    @javadoc("The RSA algorithm used to wrap and unwrap data keys.")
    encryptionAlgorithm: EncryptionAlgorithmSpec,
    //= aws-encryption-sdk-specification/framework/aws-kms/aws-kms-rsa-keyring.md#initialization
    //= type=implication
    //# - MAY provide an AWS KMS SDK client
    @javadoc("The KMS Client this Keyring will use to call KMS.")
    kmsClient: KmsClientReference,
    //= aws-encryption-sdk-specification/framework/aws-kms/aws-kms-rsa-keyring.md#initialization
    //= type=implication
    //# - MAY provide a list of Grant Tokens
    @javadoc("A list of grant tokens to be used when calling KMS.")
    grantTokens: GrantTokenList
  }
