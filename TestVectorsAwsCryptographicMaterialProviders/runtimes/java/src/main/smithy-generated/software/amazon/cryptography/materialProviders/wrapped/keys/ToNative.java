// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
// Do not modify this file. This file is machine generated, and any changes to it will be overwritten.
package software.amazon.cryptography.materialProviders.wrapped.keys;

import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.Error;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.Error_CollectionOfErrors;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.Error_KeyVectorException;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.Error_Opaque;
import java.lang.RuntimeException;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.CollectionOfErrors;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.GetKeyDescriptionInput;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.GetKeyDescriptionOutput;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.InvalidKeyring;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.KMSInfo;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.KeyDescription;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.KeyVectorException;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.KeyVectorsConfig;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.KmsMrkAware;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.KmsMrkAwareDiscovery;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.OpaqueError;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.RawAES;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.RawRSA;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.SerializeKeyDescriptionInput;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.SerializeKeyDescriptionOutput;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.TestVectorKeyringInput;

public class ToNative {
  public static OpaqueError Error(Error_Opaque dafnyValue) {
    OpaqueError.Builder nativeBuilder = OpaqueError.builder();
    nativeBuilder.obj(dafnyValue.dtor_obj());
    return nativeBuilder.build();
  }

  public static CollectionOfErrors Error(Error_CollectionOfErrors dafnyValue) {
    CollectionOfErrors.Builder nativeBuilder = CollectionOfErrors.builder();
    nativeBuilder.list(
        software.amazon.dafny.conversion.ToNative.Aggregate.GenericToList(
        dafnyValue.dtor_list(), 
        ToNative::Error));
    return nativeBuilder.build();
  }

  public static KeyVectorException Error(Error_KeyVectorException dafnyValue) {
    KeyVectorException.Builder nativeBuilder = KeyVectorException.builder();
    nativeBuilder.message(software.amazon.dafny.conversion.ToNative.Simple.String(dafnyValue.dtor_message()));
    return nativeBuilder.build();
  }

  public static RuntimeException Error(Error dafnyValue) {
    if (dafnyValue.is_KeyVectorException()) {
      return ToNative.Error((Error_KeyVectorException) dafnyValue);
    }
    if (dafnyValue.is_Opaque()) {
      return ToNative.Error((Error_Opaque) dafnyValue);
    }
    if (dafnyValue.is_CollectionOfErrors()) {
      return ToNative.Error((Error_CollectionOfErrors) dafnyValue);
    }
    OpaqueError.Builder nativeBuilder = OpaqueError.builder();
    nativeBuilder.obj(dafnyValue);
    return nativeBuilder.build();
  }

  public static GetKeyDescriptionOutput GetKeyDescriptionOutput(
      Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.GetKeyDescriptionOutput dafnyValue) {
    GetKeyDescriptionOutput.Builder nativeBuilder = GetKeyDescriptionOutput.builder();
    nativeBuilder.keyDescription(ToNative.KeyDescription(dafnyValue.dtor_keyDescription()));
    return nativeBuilder.build();
  }

  public static TestVectorKeyringInput TestVectorKeyringInput(
      Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.TestVectorKeyringInput dafnyValue) {
    TestVectorKeyringInput.Builder nativeBuilder = TestVectorKeyringInput.builder();
    nativeBuilder.keyDescription(ToNative.KeyDescription(dafnyValue.dtor_keyDescription()));
    return nativeBuilder.build();
  }

  public static SerializeKeyDescriptionOutput SerializeKeyDescriptionOutput(
      Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.SerializeKeyDescriptionOutput dafnyValue) {
    SerializeKeyDescriptionOutput.Builder nativeBuilder = SerializeKeyDescriptionOutput.builder();
    nativeBuilder.json(software.amazon.dafny.conversion.ToNative.Simple.ByteBuffer(dafnyValue.dtor_json()));
    return nativeBuilder.build();
  }

  public static SerializeKeyDescriptionInput SerializeKeyDescriptionInput(
      Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.SerializeKeyDescriptionInput dafnyValue) {
    SerializeKeyDescriptionInput.Builder nativeBuilder = SerializeKeyDescriptionInput.builder();
    nativeBuilder.keyDescription(ToNative.KeyDescription(dafnyValue.dtor_keyDescription()));
    return nativeBuilder.build();
  }

  public static KmsMrkAwareDiscovery KmsMrkAwareDiscovery(
      Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.KmsMrkAwareDiscovery dafnyValue) {
    KmsMrkAwareDiscovery.Builder nativeBuilder = KmsMrkAwareDiscovery.builder();
    nativeBuilder.keyId(software.amazon.dafny.conversion.ToNative.Simple.String(dafnyValue.dtor_keyId()));
    nativeBuilder.defaultMrkRegion(software.amazon.dafny.conversion.ToNative.Simple.String(dafnyValue.dtor_defaultMrkRegion()));
    if (dafnyValue.dtor_awsKmsDiscoveryFilter().is_Some()) {
      nativeBuilder.awsKmsDiscoveryFilter(software.amazon.cryptography.materialProviders.ToNative.DiscoveryFilter(dafnyValue.dtor_awsKmsDiscoveryFilter().dtor_value()));
    }
    return nativeBuilder.build();
  }

  public static KmsMrkAware KmsMrkAware(
      Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.KmsMrkAware dafnyValue) {
    KmsMrkAware.Builder nativeBuilder = KmsMrkAware.builder();
    nativeBuilder.keyId(software.amazon.dafny.conversion.ToNative.Simple.String(dafnyValue.dtor_keyId()));
    return nativeBuilder.build();
  }

  public static GetKeyDescriptionInput GetKeyDescriptionInput(
      Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.GetKeyDescriptionInput dafnyValue) {
    GetKeyDescriptionInput.Builder nativeBuilder = GetKeyDescriptionInput.builder();
    nativeBuilder.json(software.amazon.dafny.conversion.ToNative.Simple.ByteBuffer(dafnyValue.dtor_json()));
    return nativeBuilder.build();
  }

  public static RawAES RawAES(
      Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.RawAES dafnyValue) {
    RawAES.Builder nativeBuilder = RawAES.builder();
    nativeBuilder.keyId(software.amazon.dafny.conversion.ToNative.Simple.String(dafnyValue.dtor_keyId()));
    nativeBuilder.providerId(software.amazon.dafny.conversion.ToNative.Simple.String(dafnyValue.dtor_providerId()));
    return nativeBuilder.build();
  }

  public static KeyVectorsConfig KeyVectorsConfig(
      Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.KeyVectorsConfig dafnyValue) {
    KeyVectorsConfig.Builder nativeBuilder = KeyVectorsConfig.builder();
    nativeBuilder.keyManifiestPath(software.amazon.dafny.conversion.ToNative.Simple.String(dafnyValue.dtor_keyManifiestPath()));
    return nativeBuilder.build();
  }

  public static RawRSA RawRSA(
      Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.RawRSA dafnyValue) {
    RawRSA.Builder nativeBuilder = RawRSA.builder();
    nativeBuilder.keyId(software.amazon.dafny.conversion.ToNative.Simple.String(dafnyValue.dtor_keyId()));
    nativeBuilder.providerId(software.amazon.dafny.conversion.ToNative.Simple.String(dafnyValue.dtor_providerId()));
    nativeBuilder.padding(software.amazon.cryptography.materialProviders.ToNative.PaddingScheme(dafnyValue.dtor_padding()));
    return nativeBuilder.build();
  }

  public static InvalidKeyring InvalidKeyring(
      Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.InvalidKeyring dafnyValue) {
    InvalidKeyring.Builder nativeBuilder = InvalidKeyring.builder();
    nativeBuilder.keyId(software.amazon.dafny.conversion.ToNative.Simple.String(dafnyValue.dtor_keyId()));
    return nativeBuilder.build();
  }

  public static KMSInfo KMSInfo(
      Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.KMSInfo dafnyValue) {
    KMSInfo.Builder nativeBuilder = KMSInfo.builder();
    nativeBuilder.keyId(software.amazon.dafny.conversion.ToNative.Simple.String(dafnyValue.dtor_keyId()));
    return nativeBuilder.build();
  }

  public static KeyDescription KeyDescription(
      Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.KeyDescription dafnyValue) {
    KeyDescription.Builder nativeBuilder = KeyDescription.builder();
    if (dafnyValue.is_Kms()) {
      nativeBuilder.Kms(ToNative.KMSInfo(dafnyValue.dtor_Kms()));
    }
    if (dafnyValue.is_KmsMrk()) {
      nativeBuilder.KmsMrk(ToNative.KmsMrkAware(dafnyValue.dtor_KmsMrk()));
    }
    if (dafnyValue.is_KmsMrkDiscovery()) {
      nativeBuilder.KmsMrkDiscovery(ToNative.KmsMrkAwareDiscovery(dafnyValue.dtor_KmsMrkDiscovery()));
    }
    if (dafnyValue.is_RSA()) {
      nativeBuilder.RSA(ToNative.RawRSA(dafnyValue.dtor_RSA()));
    }
    if (dafnyValue.is_AES()) {
      nativeBuilder.AES(ToNative.RawAES(dafnyValue.dtor_AES()));
    }
    if (dafnyValue.is_Invalid()) {
      nativeBuilder.Invalid(ToNative.InvalidKeyring(dafnyValue.dtor_Invalid()));
    }
    return nativeBuilder.build();
  }
}
