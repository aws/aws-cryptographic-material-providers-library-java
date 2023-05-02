// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
// Do not modify this file. This file is machine generated, and any changes to it will be overwritten.
package software.amazon.cryptography.materialProvidersTestVectorKeys;

import Dafny.Aws.Cryptography.MaterialProviders.Types.DiscoveryFilter;
import Dafny.Aws.Cryptography.MaterialProviders.Types.PaddingScheme;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.Error;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.Error_KeyVectorException;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.GetKeyDescriptionInput;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.GetKeyDescriptionOutput;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.HierarchyKeyring;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.IKeyVectorsClient;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.KMSInfo;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.KeyDescription;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.KeyVectorsConfig;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.KmsMrkAware;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.KmsMrkAwareDiscovery;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.KmsRsaKeyring;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.RawAES;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.RawRSA;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.SerializeKeyDescriptionInput;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.SerializeKeyDescriptionOutput;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.StaticKeyring;
import Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.TestVectorKeyringInput;
import Dafny.Com.Amazonaws.Kms.Types.EncryptionAlgorithmSpec;
import Wrappers_Compile.Option;
import dafny.DafnySequence;
import java.lang.Byte;
import java.lang.Character;
import java.lang.IllegalArgumentException;
import java.lang.RuntimeException;
import java.util.Objects;
import software.amazon.cryptography.materialProvidersTestVectorKeys.model.CollectionOfErrors;
import software.amazon.cryptography.materialProvidersTestVectorKeys.model.KeyVectorException;
import software.amazon.cryptography.materialProvidersTestVectorKeys.model.OpaqueError;

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

  public static GetKeyDescriptionInput GetKeyDescriptionInput(
      software.amazon.cryptography.materialProvidersTestVectorKeys.model.GetKeyDescriptionInput nativeValue) {
    DafnySequence<? extends Byte> json;
    json = software.amazon.dafny.conversion.ToDafny.Simple.ByteSequence(nativeValue.json());
    return new GetKeyDescriptionInput(json);
  }

  public static GetKeyDescriptionOutput GetKeyDescriptionOutput(
      software.amazon.cryptography.materialProvidersTestVectorKeys.model.GetKeyDescriptionOutput nativeValue) {
    KeyDescription keyDescription;
    keyDescription = ToDafny.KeyDescription(nativeValue.keyDescription());
    return new GetKeyDescriptionOutput(keyDescription);
  }

  public static HierarchyKeyring HierarchyKeyring(
      software.amazon.cryptography.materialProvidersTestVectorKeys.model.HierarchyKeyring nativeValue) {
    DafnySequence<? extends Character> keyId;
    keyId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.keyId());
    return new HierarchyKeyring(keyId);
  }

  public static KeyVectorsConfig KeyVectorsConfig(
      software.amazon.cryptography.materialProvidersTestVectorKeys.model.KeyVectorsConfig nativeValue) {
    DafnySequence<? extends Character> keyManifiestPath;
    keyManifiestPath = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.keyManifiestPath());
    return new KeyVectorsConfig(keyManifiestPath);
  }

  public static KMSInfo KMSInfo(
      software.amazon.cryptography.materialProvidersTestVectorKeys.model.KMSInfo nativeValue) {
    DafnySequence<? extends Character> keyId;
    keyId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.keyId());
    return new KMSInfo(keyId);
  }

  public static KmsMrkAware KmsMrkAware(
      software.amazon.cryptography.materialProvidersTestVectorKeys.model.KmsMrkAware nativeValue) {
    DafnySequence<? extends Character> keyId;
    keyId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.keyId());
    return new KmsMrkAware(keyId);
  }

  public static KmsMrkAwareDiscovery KmsMrkAwareDiscovery(
      software.amazon.cryptography.materialProvidersTestVectorKeys.model.KmsMrkAwareDiscovery nativeValue) {
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

  public static KmsRsaKeyring KmsRsaKeyring(
      software.amazon.cryptography.materialProvidersTestVectorKeys.model.KmsRsaKeyring nativeValue) {
    DafnySequence<? extends Character> keyId;
    keyId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.keyId());
    EncryptionAlgorithmSpec encryptionAlgorithm;
    encryptionAlgorithm = Dafny.Com.Amazonaws.Kms.ToDafny.EncryptionAlgorithmSpec(nativeValue.encryptionAlgorithm());
    return new KmsRsaKeyring(keyId, encryptionAlgorithm);
  }

  public static RawAES RawAES(
      software.amazon.cryptography.materialProvidersTestVectorKeys.model.RawAES nativeValue) {
    DafnySequence<? extends Character> keyId;
    keyId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.keyId());
    DafnySequence<? extends Character> providerId;
    providerId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.providerId());
    return new RawAES(keyId, providerId);
  }

  public static RawRSA RawRSA(
      software.amazon.cryptography.materialProvidersTestVectorKeys.model.RawRSA nativeValue) {
    DafnySequence<? extends Character> keyId;
    keyId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.keyId());
    DafnySequence<? extends Character> providerId;
    providerId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.providerId());
    PaddingScheme padding;
    padding = software.amazon.cryptography.materialProviders.ToDafny.PaddingScheme(nativeValue.padding());
    return new RawRSA(keyId, providerId, padding);
  }

  public static SerializeKeyDescriptionInput SerializeKeyDescriptionInput(
      software.amazon.cryptography.materialProvidersTestVectorKeys.model.SerializeKeyDescriptionInput nativeValue) {
    KeyDescription keyDescription;
    keyDescription = ToDafny.KeyDescription(nativeValue.keyDescription());
    return new SerializeKeyDescriptionInput(keyDescription);
  }

  public static SerializeKeyDescriptionOutput SerializeKeyDescriptionOutput(
      software.amazon.cryptography.materialProvidersTestVectorKeys.model.SerializeKeyDescriptionOutput nativeValue) {
    DafnySequence<? extends Byte> json;
    json = software.amazon.dafny.conversion.ToDafny.Simple.ByteSequence(nativeValue.json());
    return new SerializeKeyDescriptionOutput(json);
  }

  public static StaticKeyring StaticKeyring(
      software.amazon.cryptography.materialProvidersTestVectorKeys.model.StaticKeyring nativeValue) {
    DafnySequence<? extends Character> keyId;
    keyId = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.keyId());
    return new StaticKeyring(keyId);
  }

  public static TestVectorKeyringInput TestVectorKeyringInput(
      software.amazon.cryptography.materialProvidersTestVectorKeys.model.TestVectorKeyringInput nativeValue) {
    KeyDescription keyDescription;
    keyDescription = ToDafny.KeyDescription(nativeValue.keyDescription());
    return new TestVectorKeyringInput(keyDescription);
  }

  public static Error Error(KeyVectorException nativeValue) {
    DafnySequence<? extends Character> message;
    message = software.amazon.dafny.conversion.ToDafny.Simple.CharacterSequence(nativeValue.message());
    return new Error_KeyVectorException(message);
  }

  public static KeyDescription KeyDescription(
      software.amazon.cryptography.materialProvidersTestVectorKeys.model.KeyDescription nativeValue) {
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
    if (Objects.nonNull(nativeValue.Static())) {
      return KeyDescription.create_Static(ToDafny.StaticKeyring(nativeValue.Static()));
    }
    if (Objects.nonNull(nativeValue.KmsRsa())) {
      return KeyDescription.create_KmsRsa(ToDafny.KmsRsaKeyring(nativeValue.KmsRsa()));
    }
    if (Objects.nonNull(nativeValue.Hierarchy())) {
      return KeyDescription.create_Hierarchy(ToDafny.HierarchyKeyring(nativeValue.Hierarchy()));
    }
    throw new IllegalArgumentException("Cannot convert " + nativeValue + " to Dafny.Aws.Cryptography.MaterialProvidersTestVectorKeys.Types.KeyDescription.");
  }

  public static IKeyVectorsClient KeyVectors(KeyVectors nativeValue) {
    return nativeValue.impl();
  }
}
