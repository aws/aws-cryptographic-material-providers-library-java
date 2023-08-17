package ACCP;

import software.amazon.cryptography.primitives.internaldafny.types.HKDFPolicy;

@SuppressWarnings("UnresolvedClassReferenceRepair")
public class ACCPUtils {
  /**
   * @param hkdfPolicy Determine if FIPS is required
   * @return If hdfkPolicy is NONE, return if ACCP is installed and version is >= 2.3.
   * Otherwise, return if ACCP is installed, version is >= 2.3, && FIPS is enabled.
   */
public static boolean ExternCheckForAccp(HKDFPolicy hkdfPolicy) {
    if (
        //noinspection UnresolvedClassReferenceRepair
        com.amazon.corretto.crypto.provider.AmazonCorrettoCryptoProvider.INSTANCE == null
    ) {
      return false;
    }
    if (
        //noinspection UnresolvedClassReferenceRepair
        com.amazon.corretto.crypto.provider.AmazonCorrettoCryptoProvider.INSTANCE.getVersion() < 2.3
    ) {
      return false;
    }
    if (hkdfPolicy.is_REQUIRE__FIPS__HKDF()) {
      return
          //noinspection UnresolvedClassReferenceRepair
          com.amazon.corretto.crypto.provider.AmazonCorrettoCryptoProvider.INSTANCE.isFips();
    }
    return true;
  }
}
