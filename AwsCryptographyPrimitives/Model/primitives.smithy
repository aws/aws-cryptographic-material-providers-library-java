namespace aws.cryptography.primitives

@range(min: 0)
integer PositiveInteger

@aws.polymorph#localService(
  sdkId: "AtomicPrimitives",
  config: CryptoConfig,
)
service AwsCryptographicPrimitives {
  version: "2020-10-24",
  operations: [
    GenerateRandomBytes,
    Digest,
    HMac,
    HkdfExtract,
    HkdfExpand,
    Hkdf,
    KdfCounterMode,
    AesKdfCounterMode,
    AESEncrypt,
    AESDecrypt,
    GenerateRSAKeyPair,
    GetRSAKeyModulusLength,
    RSADecrypt,
    RSAEncrypt,
    GenerateECDSASignatureKey,
    ECDSASign,
    ECDSAVerify,
    GetHKDFProvider
  ],
  errors: [AwsCryptographicPrimitivesError]
}

@enum([
  {
    name: "REQUIRE_FIPS_HKDF",
    value: "REQUIRE_FIPS_HKDF",
  },
  {
    name: "NONE",
    value: "NONE",
  },
])
string HKDFPolicy

structure CryptoConfig {
  hkdfPolicy: HKDFPolicy
}

@enum([
  {
    name: "ACCP_FIPS",
    value: "ACCP_FIPS",
  },
  {
    name: "ACCP_NOT_FIPS",
    value: "ACCP_NOT_FIPS",
  },
  {
    name: "MPL",
    value: "MPL",
  },
])
string HKDFProvider

operation GetHKDFProvider {
  input: GetHKDFProviderInput,
  output: GetHKDFProviderOutput,
  errors: []
}

structure GetHKDFProviderInput {}

structure GetHKDFProviderOutput {
  @required
  provider: HKDFProvider
}

///////////////////
// Errors

@error("client")
structure AwsCryptographicPrimitivesError {
  @required
  message: String,
}
