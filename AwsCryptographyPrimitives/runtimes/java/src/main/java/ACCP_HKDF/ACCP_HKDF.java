// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
package ACCP_HKDF;

import com.amazon.corretto.crypto.provider.AmazonCorrettoCryptoProvider;
import com.amazon.corretto.crypto.provider.HkdfSpec;

import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;

import javax.crypto.SecretKeyFactory;

import software.amazon.cryptography.primitives.ToNative;
import software.amazon.cryptography.primitives.internaldafny.types.DigestAlgorithm;
import software.amazon.cryptography.primitives.model.AwsCryptographicPrimitivesError;
import software.amazon.smithy.dafny.conversion.ToDafny;


public class ACCP_HKDF {
    private static final byte[] EMPTY_ARRAY = new byte[0];

    public static dafny.DafnySequence<? extends java.lang.Byte> Extract(
        final HMAC.HMac hmac,
        final dafny.DafnySequence<? extends java.lang.Byte> salt,
        final dafny.DafnySequence<? extends java.lang.Byte> ikm
    ) {
        throw new RuntimeException("TODO");
    }

    public static dafny.DafnySequence<? extends java.lang.Byte> Expand(
        final HMAC.HMac hmac,
        final dafny.DafnySequence<? extends java.lang.Byte> prk,
        final dafny.DafnySequence<? extends java.lang.Byte> info,
        final java.math.BigInteger expectedLength,
        final DigestAlgorithm digest
    ) {
        throw new RuntimeException("TODO");
    }

    public static dafny.DafnySequence<? extends java.lang.Byte> Hkdf(
        final software.amazon.cryptography.primitives.internaldafny.types.DigestAlgorithm digest,
        final Wrappers_Compile.Option<dafny.DafnySequence<? extends java.lang.Byte>> salt,
        final dafny.DafnySequence<? extends java.lang.Byte> ikm,
        final dafny.DafnySequence<? extends java.lang.Byte> info,
        final java.math.BigInteger keyLength
    ) {
        //= aws-encryption-sdk-specification/framework/transitive-requirements.md#hkdf-encryption-key
        // # - The hash function MUST be specified by the [algorithm suite key derivation settings](#algorithm-suites-encryption-key-derivation-settings).
        final String nativeDigest = "HkdfWithHmac" + ToNative.DigestAlgorithm(digest).toString().replace("_", "");
        final byte[] nativeSalt = salt.is_None() ? EMPTY_ARRAY :
            (byte[]) salt.dtor_value().toRawArray();
        final byte[] nativeIkm = (byte[]) ikm.toRawArray();
        final byte[] nativeInfo = (byte[]) info.toRawArray();
        try {
          final int nativeKeyLength = keyLength.intValueExact();
          final SecretKeyFactory secretKeyFactory = SecretKeyFactory.getInstance(nativeDigest, AmazonCorrettoCryptoProvider.INSTANCE);
          final HkdfSpec hkdfSpec = HkdfSpec.hkdfSpec(nativeIkm, nativeSalt, nativeInfo, nativeKeyLength, null);
          final byte[] pseudorandomKey = secretKeyFactory.generateSecret(hkdfSpec).getEncoded();
          return ToDafny.Simple.ByteSequence(pseudorandomKey);
        } catch (ArithmeticException ex) {
          throw AwsCryptographicPrimitivesError
              .builder().message(String.format(
                  "Requested KeyLength is too large: %s",
                  keyLength))
              .cause(ex).build();
        } catch (NoSuchAlgorithmException ex) {
            throw AwsCryptographicPrimitivesError
                .builder().message(String.format(
                    "ACCP does not support requested HKDF Algorithm: %s",
                    nativeDigest))
                .cause(ex).build();
        } catch (InvalidKeySpecException e) {
            throw new RuntimeException(e);
        }
    }
}
