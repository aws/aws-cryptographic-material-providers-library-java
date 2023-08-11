// Class __default
// Dafny class __default compiled into Java
package HKDF_Compile;

import java.security.GeneralSecurityException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;

import javax.crypto.Cipher;
import javax.crypto.NoSuchPaddingException;

import software.amazon.cryptography.primitives.internaldafny.types.*;
import Random_Compile.*;
import AESEncryption.*;
import Digest_Compile.*;
import HMAC.*;
import WrappedHMAC_Compile.*;

@SuppressWarnings({"unchecked", "deprecation"})
public class __default {
  public __default() {
  }
  public static dafny.DafnySequence<? extends java.lang.Byte> Extract(HMAC.HMac hmac, dafny.DafnySequence<? extends java.lang.Byte> salt, dafny.DafnySequence<? extends java.lang.Byte> ikm)
  {
    dafny.DafnySequence<? extends java.lang.Byte> prk = dafny.DafnySequence.<java.lang.Byte> empty(BoundedInts_Compile.uint8._typeDescriptor());
    (hmac).Init(salt);
    (hmac).BlockUpdate(ikm);
    dafny.DafnySequence<? extends java.lang.Byte> _out4;
    _out4 = (hmac).GetResult();
    prk = _out4;
    prk = prk;
    return prk;
  }
  public static dafny.DafnySequence<? extends java.lang.Byte> Expand(HMAC.HMac hmac, dafny.DafnySequence<? extends java.lang.Byte> prk, dafny.DafnySequence<? extends java.lang.Byte> info, java.math.BigInteger expectedLength, software.amazon.cryptography.primitives.internaldafny.types.DigestAlgorithm digest)
  {
    dafny.DafnySequence<? extends java.lang.Byte> okm = dafny.DafnySequence.<java.lang.Byte> empty(BoundedInts_Compile.uint8._typeDescriptor());
    if(true) {
      java.math.BigInteger _34_hashLength = java.math.BigInteger.ZERO;
      _34_hashLength = Digest_Compile.__default.Length(digest);
      java.math.BigInteger _35_n = java.math.BigInteger.ZERO;
      _35_n = dafny.DafnyEuclidean.EuclideanDivision(((_34_hashLength).add(expectedLength)).subtract(java.math.BigInteger.ONE), _34_hashLength);
      (hmac).Init(prk);
      dafny.DafnySequence<? extends java.lang.Byte> _36_t__prev;
      _36_t__prev = dafny.DafnySequence.<java.lang.Byte> empty(BoundedInts_Compile.uint8._typeDescriptor());
      dafny.DafnySequence<? extends java.lang.Byte> _37_t__n;
      _37_t__n = _36_t__prev;
      java.math.BigInteger _38_i = java.math.BigInteger.ZERO;
      _38_i = java.math.BigInteger.ONE;
      while ((_38_i).compareTo(_35_n) <= 0) {
        (hmac).BlockUpdate(_36_t__prev);
        (hmac).BlockUpdate(info);
        (hmac).BlockUpdate(dafny.DafnySequence.of((_38_i).byteValue()));
        dafny.DafnySequence<? extends java.lang.Byte> _out5;
        _out5 = (hmac).GetResult();
        _36_t__prev = _out5;
        _37_t__n = dafny.DafnySequence.<java.lang.Byte>concatenate(_37_t__n, _36_t__prev);
        _38_i = (_38_i).add(java.math.BigInteger.ONE);
      }
      okm = _37_t__n;
      if ((expectedLength).compareTo(java.math.BigInteger.valueOf((okm).length())) < 0) {
        okm = (okm).take(expectedLength);
      }
    }
    return okm;
  }
  public static dafny.DafnySequence<? extends java.lang.Byte> Hkdf(software.amazon.cryptography.primitives.internaldafny.types.DigestAlgorithm digest, Wrappers_Compile.Option<dafny.DafnySequence<? extends java.lang.Byte>> salt, dafny.DafnySequence<? extends java.lang.Byte> ikm, dafny.DafnySequence<? extends java.lang.Byte> info, java.math.BigInteger L)
  {
    try {
      if (
          Cipher.getInstance("AES/GCM/NoPadding", "AmazonCorrettoCryptoProvider")
              .getProvider().getName()
              .equals("AmazonCorrettoCryptoProvider")
      ) {
        return ACCP_HKDF.ACCP_HKDF.Hkdf(digest, salt, ikm, info, L);
      }
    } catch (GeneralSecurityException ignored) {}
      dafny.DafnySequence<? extends java.lang.Byte> okm = dafny.DafnySequence.<java.lang.Byte> empty(BoundedInts_Compile.uint8._typeDescriptor());
    if(true) {
      if ((L).signum() == 0) {
        okm = dafny.DafnySequence.<java.lang.Byte> empty(BoundedInts_Compile.uint8._typeDescriptor());
        return okm;
      }
      HMAC.HMac _39_hmac;
      Wrappers_Compile.Result<HMAC.HMac, software.amazon.cryptography.primitives.internaldafny.types.Error> _40_valueOrError0 = (Wrappers_Compile.Result<HMAC.HMac, software.amazon.cryptography.primitives.internaldafny.types.Error>)null;
      Wrappers_Compile.Result<HMAC.HMac, software.amazon.cryptography.primitives.internaldafny.types.Error> _out6;
      _out6 = HMAC.HMac.Build(digest);
      _40_valueOrError0 = _out6;
      if (!(!((_40_valueOrError0).IsFailure(HMAC.HMac._typeDescriptor(), software.amazon.cryptography.primitives.internaldafny.types.Error._typeDescriptor())))) {
        throw new dafny.DafnyHaltException("/Volumes/workplace/aws-cryptographic-material-providers-library-java/AwsCryptographyPrimitives/src/HKDF/HKDF.dfy(222,13): " + java.lang.String.valueOf(_40_valueOrError0));
      }
      _39_hmac = (_40_valueOrError0).Extract(HMAC.HMac._typeDescriptor(), software.amazon.cryptography.primitives.internaldafny.types.Error._typeDescriptor());
      java.math.BigInteger _41_hashLength = java.math.BigInteger.ZERO;
      _41_hashLength = Digest_Compile.__default.Length(digest);
      dafny.DafnySequence<? extends java.lang.Byte> _42_nonEmptySalt = dafny.DafnySequence.<java.lang.Byte> empty(BoundedInts_Compile.uint8._typeDescriptor());
      Wrappers_Compile.Option<dafny.DafnySequence<? extends java.lang.Byte>> _source1 = salt;
      if (_source1.is_None()) {
        _42_nonEmptySalt = StandardLibrary_Compile.__default.<java.lang.Byte>Fill(BoundedInts_Compile.uint8._typeDescriptor(), (byte) 0, _41_hashLength);
      } else {
        dafny.DafnySequence<? extends java.lang.Byte> _43___mcc_h0 = ((Wrappers_Compile.Option_Some<dafny.DafnySequence<? extends java.lang.Byte>>)_source1)._value;
        dafny.DafnySequence<? extends java.lang.Byte> _44_s = _43___mcc_h0;
        _42_nonEmptySalt = _44_s;
      }
      dafny.DafnySequence<? extends java.lang.Byte> _45_prk;
      dafny.DafnySequence<? extends java.lang.Byte> _out7;
      _out7 = __default.Extract(_39_hmac, _42_nonEmptySalt, ikm);
      _45_prk = _out7;
      dafny.DafnySequence<? extends java.lang.Byte> _out8;
      _out8 = __default.Expand(_39_hmac, _45_prk, info, L, digest);
      okm = _out8;
    }
    return okm;
  }
  private static final dafny.TypeDescriptor<__default> _TYPE = dafny.TypeDescriptor.<__default>referenceWithInitializer(__default.class, () -> (__default) null);
  public static dafny.TypeDescriptor<__default> _typeDescriptor() {
    return (dafny.TypeDescriptor<__default>) (dafny.TypeDescriptor<?>) _TYPE;
  }
  @Override
  public java.lang.String toString() {
    return "HKDF_Compile._default";
  }
}
