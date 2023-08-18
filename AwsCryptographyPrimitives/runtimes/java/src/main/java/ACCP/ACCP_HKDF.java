// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
package ACCP;

// It SHOULD BE safe to reference ACCP in this class,
// as it will only be loaded if ACCPUtils determined ACCP
// is available.
import com.amazon.corretto.crypto.provider.AmazonCorrettoCryptoProvider;
import com.amazon.corretto.crypto.provider.HkdfSpec;

import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;

import javax.crypto.SecretKeyFactory;

import software.amazon.cryptography.primitives.ToNative;
import software.amazon.cryptography.primitives.internaldafny.types.Error;
import software.amazon.cryptography.primitives.internaldafny.types.HkdfInput;
import software.amazon.cryptography.primitives.internaldafny.types.HkdfExpandInput;
import software.amazon.cryptography.primitives.internaldafny.types.HkdfExtractInput;
import software.amazon.cryptography.primitives.model.AwsCryptographicPrimitivesError;

import software.amazon.smithy.dafny.conversion.ToDafny;

import Wrappers_Compile.Result;

import static software.amazon.cryptography.primitives.ToDafny.Error;

public class ACCP_HKDF {
  private static final byte[] EMPTY_ARRAY = new byte[0];

  public static Result<dafny.DafnySequence<? extends java.lang.Byte>, Error> ExternExtract(
      HkdfExtractInput input
  ) {
    //final HMAC.HMac hmac,
    //         final dafny.DafnySequence<? extends java.lang.Byte> salt,
    //         final dafny.DafnySequence<? extends java.lang.Byte> ikm
    return Result.create_Failure(Error(
        AwsCryptographicPrimitivesError
            .builder()
            .message("TODO")
            .build()));
  }

  public static Result<dafny.DafnySequence<? extends java.lang.Byte>, Error> ExternExpand(
      HkdfExpandInput input
  ) {
    //final HMAC.HMac hmac,
    //         final dafny.DafnySequence<? extends java.lang.Byte> prk,
    //         final dafny.DafnySequence<? extends java.lang.Byte> info,
    //         final java.math.BigInteger expectedLength,
    //         final DigestAlgorithm digest
    return Result.create_Failure(Error(
        AwsCryptographicPrimitivesError
            .builder()
            .message("TODO")
            .build()));
  }

  public static Result<dafny.DafnySequence<? extends java.lang.Byte>, Error> ExternHkdf(
      HkdfInput input
  ) {
    //= aws-encryption-sdk-specification/framework/transitive-requirements.md#hkdf-encryption-key
    // # - The hash function MUST be specified by the [algorithm suite key derivation settings](#algorithm-suites-encryption-key-derivation-settings).
    final String nativeDigest = "HkdfWithHmac" + ToNative.DigestAlgorithm(input.dtor_digestAlgorithm())
        .toString().replace("_", "");
    final byte[] nativeSalt = input.dtor_salt().is_None() ? EMPTY_ARRAY :
        (byte[]) input.dtor_salt().dtor_value().toRawArray();
    final byte[] nativeIkm = (byte[]) input.dtor_ikm().toRawArray();
    final byte[] nativeInfo = (byte[]) input.dtor_info().toRawArray();
    try {
      final int nativeKeyLength = input.dtor_expectedLength();
      final SecretKeyFactory secretKeyFactory = SecretKeyFactory.getInstance(
          nativeDigest, AmazonCorrettoCryptoProvider.INSTANCE);
      final HkdfSpec hkdfSpec = HkdfSpec.hkdfSpec(nativeIkm, nativeSalt, nativeInfo, nativeKeyLength, null);
      final byte[] pseudorandomKey = secretKeyFactory.generateSecret(hkdfSpec).getEncoded();
      return Result.create_Success(ToDafny.Simple.ByteSequence(pseudorandomKey));
    } catch (NoSuchAlgorithmException ex) {
      return Result.create_Failure(Error(
          AwsCryptographicPrimitivesError
            .builder()
              .message(String.format(
                  "ACCP does not support requested HKDF Algorithm: %s",
                  nativeDigest))
              .cause(ex).build()));
    } catch (InvalidKeySpecException ex) {
      //noinspection SpellCheckingInspection
      return Result.create_Failure(Error(
          AwsCryptographicPrimitivesError
            .builder()
              .message("ACCP's HKDF throw an exception")
              .cause(ex).build()));
    }
  }
}
