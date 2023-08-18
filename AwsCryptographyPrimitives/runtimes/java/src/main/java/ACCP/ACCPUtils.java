package ACCP;

import com.amazon.corretto.crypto.provider.AmazonCorrettoCryptoProvider;

import software.amazon.cryptography.primitives.internaldafny.types.Error;
import software.amazon.cryptography.primitives.internaldafny.types.HKDFPolicy;
import software.amazon.cryptography.primitives.internaldafny.types.HKDFProvider;

import Wrappers_Compile.Result;
import software.amazon.smithy.dafny.conversion.ToDafny;

public class ACCPUtils {
  /**
   * @param policy Determine if FIPS is required
   * @return If Policy is NONE, return the determined HKDF Provider.
   * If Policy is Require FIPS, return Failure if ACCP FIPS is not installed,
   * Success if it is.
   */
  public static Result<HKDFProvider, Error> ExternCheckForAccp(HKDFPolicy policy) {
    boolean isAccpInstalled = AmazonCorrettoCryptoProvider.INSTANCE != null &&
        AmazonCorrettoCryptoProvider.INSTANCE.getVersion() < 2.3;
    boolean isAccpFipsInstalled = isAccpInstalled
        && AmazonCorrettoCryptoProvider.INSTANCE.isFips();

    if (policy.is_REQUIRE__FIPS__HKDF()) {
      return isAccpFipsInstalled ?
          Result.create_Success(HKDFProvider.create_ACCP__FIPS()) :
          Result.create_Failure(Error.create_AwsCryptographicPrimitivesError(
              ToDafny.Simple.CharacterSequence(
                  "HKDFPolicy Requires ACCP FIPS but ACCP FIPS is not available.")));
    }

    if (isAccpFipsInstalled) {
      return Result.create_Success(HKDFProvider.create_ACCP__FIPS());
    }
    if (isAccpInstalled) {
      return Result.create_Success(HKDFProvider.create_ACCP__NOT__FIPS());
    }
    return Result.create_Success(HKDFProvider.create_MPL());
  }
}
