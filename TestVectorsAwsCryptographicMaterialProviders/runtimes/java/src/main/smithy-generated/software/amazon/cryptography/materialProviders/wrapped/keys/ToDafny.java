// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
// Do not modify this file. This file is machine generated, and any changes to it will be overwritten.
package software.amazon.cryptography.materialProviders.wrapped.keys;

import Dafny.Aws.Cryptography.MaterialProviders.Types.DiscoveryFilter;
import Dafny.Aws.Cryptography.MaterialProviders.Types.PaddingScheme;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.Error;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.Error_KeyVectorException;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.GetKeyDescriptionInput;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.GetKeyDescriptionOutput;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.InvalidKeyring;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.KMSInfo;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.KeyDescription;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.KeyVectorsConfig;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.KmsMrkAware;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.KmsMrkAwareDiscovery;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.RawAES;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.RawRSA;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.SerializeKeyDescriptionInput;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.SerializeKeyDescriptionOutput;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.TestVectorKeyringInput;
import Wrappers_Compile.Option;
import dafny.DafnySequence;
import java.lang.Byte;
import java.lang.Character;
import java.lang.IllegalArgumentException;
import java.lang.RuntimeException;
import java.util.Objects;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.CollectionOfErrors;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.KeyVectorException;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.OpaqueError;

public class ToDafny {
  public static Error Error(RuntimeException nativeValue) {
    if (nativeValue instanceof KeyVectorException) {
      return ToDafny.Error((KeyVectorException) nativeValue);
    }
    if (nativeValue instanceof OpaqueError) {
      return ToDafny.Error((OpaqueError) nativeValue);
    }
    if (nativeValue instanceof CollectionOfErrors) {
      return ToDafny.Error((CollectionOfErrors) nativeValue);
    }
    return Error.create_Opaque(nativeValue);
  }

  public static Error Error(OpaqueError nativeValue) {
    return Error.create_Opaque(nativeValue.obj());
  }

  public static Error Error(CollectionOfErrors nativeValue) {
    DafnySequence<? extends Error> list = software.amazon.dafny.conversion.ToDafny.Aggregate.GenericToSequence(
        nativeValue.list(), 
        ToDafny::Error, 
        Error._typeDescriptor());
    return Error.create_CollectionOfErrors(list);
  }

  public static GetKeyDescriptionOutput GetKeyDescriptionOutput(
      software.amazon.cryptography.materialProviders.wrapped.keys.model.GetKeyDescriptionOutput nativeValue) {
    KeyDescription keyDescription;
    keyDescription = ToDafny.KeyDescription(nativeValue.keyDescription());
    return new GetKeyDescriptionOutput(keyDescription);
  }

  public static TestVectorKeyringInput TestVectorKeyringInput(
      software.amazon.cryptography.materialProviders.wrapped.keys.model.TestVectorKeyringInput nativeValue) {
    KeyDescription keyDescription;
    keyDescription = ToDafny.KeyDescription(nativeValue.keyDescription());
    return new TestVectorKeyringInput(keyDescription);
  }

  public static SerializeKeyDescriptionOutput SerializeKeyDescriptionOutput(
      software.amazon.cryptography.materialProviders.wrapped.keys.model.SerializeKeyDescriptionOutput nativeValue) {
    DafnySequence<? extends Byte> json;
    json = software.amazon.dafny.conversion.ToDafny.Simple.ByteSequence(nativeValue.json());
    return new SerializeKeyDescriptionOutput(json);
  }

  public static SerializeKeyDescriptionInput SerializeKeyDescriptionInput(
      software.amazon.cryptography.materialProviders.wrapped.keys.model.SerializeKeyDescriptionInput nativeValue) {
    KeyDescription keyDescription;
    keyDescription = ToDafny.KeyDescription(nativeValue.keyDescription());
    return new SerializeKeyDescriptionInput(keyDescription);
  }

  public static KmsMrkAwareDiscovery KmsMrkAwareDiscovery(
      software.amazon.cryptography.materialProviders.wrapped.keys.model.KmsMrkAwareDiscovery nativeValue) {
    DafnySequence<? extends Character> keyId;
    keyId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.keyId());
    DafnySequence<? extends Character> defaultMrkRegion;
    defaultMrkRegion = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.defaultMrkRegion());
    Option<DiscoveryFilter> awsKmsDiscoveryFilter;
    awsKmsDiscoveryFilter = Objects.nonNull(nativeValue.awsKmsDiscoveryFilter()) ?
        Option.create_Some(software.amazon.cryptography.materialProviders.ToDafny.DiscoveryFilter(nativeValue.awsKmsDiscoveryFilter()))
        : Option.create_None();
    return new KmsMrkAwareDiscovery(keyId, defaultMrkRegion, awsKmsDiscoveryFilter);
  }

  public static KmsMrkAware KmsMrkAware(
      software.amazon.cryptography.materialProviders.wrapped.keys.model.KmsMrkAware nativeValue) {
    DafnySequence<? extends Character> keyId;
    keyId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.keyId());
    return new KmsMrkAware(keyId);
  }

  public static GetKeyDescriptionInput GetKeyDescriptionInput(
      software.amazon.cryptography.materialProviders.wrapped.keys.model.GetKeyDescriptionInput nativeValue) {
    DafnySequence<? extends Byte> json;
    json = software.amazon.dafny.conversion.ToDafny.Simple.ByteSequence(nativeValue.json());
    return new GetKeyDescriptionInput(json);
  }

  public static RawAES RawAES(
      software.amazon.cryptography.materialProviders.wrapped.keys.model.RawAES nativeValue) {
    DafnySequence<? extends Character> keyId;
    keyId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.keyId());
    DafnySequence<? extends Character> providerId;
    providerId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.providerId());
    return new RawAES(keyId, providerId);
  }

  public static KeyVectorsConfig KeyVectorsConfig(
      software.amazon.cryptography.materialProviders.wrapped.keys.model.KeyVectorsConfig nativeValue) {
    DafnySequence<? extends Character> keyManifiestPath;
    keyManifiestPath = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.keyManifiestPath());
    return new KeyVectorsConfig(keyManifiestPath);
  }

  public static RawRSA RawRSA(
      software.amazon.cryptography.materialProviders.wrapped.keys.model.RawRSA nativeValue) {
    DafnySequence<? extends Character> keyId;
    keyId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.keyId());
    DafnySequence<? extends Character> providerId;
    providerId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.providerId());
    PaddingScheme padding;
    padding = software.amazon.cryptography.materialProviders.ToDafny.PaddingScheme(nativeValue.padding());
    return new RawRSA(keyId, providerId, padding);
  }

  public static InvalidKeyring InvalidKeyring(
      software.amazon.cryptography.materialProviders.wrapped.keys.model.InvalidKeyring nativeValue) {
    DafnySequence<? extends Character> keyId;
    keyId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.keyId());
    return new InvalidKeyring(keyId);
  }

  public static KMSInfo KMSInfo(
      software.amazon.cryptography.materialProviders.wrapped.keys.model.KMSInfo nativeValue) {
    DafnySequence<? extends Character> keyId;
    keyId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.keyId());
    return new KMSInfo(keyId);
  }

  public static Error Error(KeyVectorException nativeValue) {
    DafnySequence<? extends Character> message;
    message = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.message());
    return new Error_KeyVectorException(message);
  }

  public static KeyDescription KeyDescription(
      software.amazon.cryptography.materialProviders.wrapped.keys.model.KeyDescription nativeValue) {
    if (Objects.nonNull(nativeValue.Kms())) {
      return KeyDescription.create_Kms(ToDafny.KMSInfo(nativeValue.Kms()));
    }
    if (Objects.nonNull(nativeValue.KmsMrk())) {
      return KeyDescription.create_KmsMrk(ToDafny.KmsMrkAware(nativeValue.KmsMrk()));
    }
    if (Objects.nonNull(nativeValue.KmsMrkDiscovery())) {
      return KeyDescription.create_KmsMrkDiscovery(ToDafny.KmsMrkAwareDiscovery(nativeValue.KmsMrkDiscovery()));
    }
    if (Objects.nonNull(nativeValue.RSA())) {
      return KeyDescription.create_RSA(ToDafny.RawRSA(nativeValue.RSA()));
    }
    if (Objects.nonNull(nativeValue.AES())) {
      return KeyDescription.create_AES(ToDafny.RawAES(nativeValue.AES()));
    }
    if (Objects.nonNull(nativeValue.Invalid())) {
      return KeyDescription.create_Invalid(ToDafny.InvalidKeyring(nativeValue.Invalid()));
    }
    throw new IllegalArgumentException("Cannot convert " + nativeValue + " to Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.KeyDescription.");
  }
}
