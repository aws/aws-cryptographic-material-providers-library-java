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

///////////////////
// Errors

@error("client")
structure AwsCryptographicPrimitivesError {
  @required
  message: String,
}
