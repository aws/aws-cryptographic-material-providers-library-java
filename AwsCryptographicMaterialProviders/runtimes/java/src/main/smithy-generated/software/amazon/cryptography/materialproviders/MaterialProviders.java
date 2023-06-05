// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
// Do not modify this file. This file is machine generated, and any changes to it will be overwritten.
package software.amazon.cryptography.materialproviders;

import Wrappers_Compile.Result;
import dafny.DafnySequence;
import dafny.Tuple0;
import java.lang.Byte;
import java.lang.IllegalArgumentException;
import java.nio.ByteBuffer;
import java.util.Objects;
import software.amazon.cryptography.materialproviders.internaldafny.MaterialProvidersClient;
import software.amazon.cryptography.materialproviders.internaldafny.__default;
import software.amazon.cryptography.materialproviders.internaldafny.types.Error;
import software.amazon.cryptography.materialproviders.internaldafny.types.IAwsCryptographicMaterialProvidersClient;
import software.amazon.cryptography.materialproviders.model.AlgorithmSuiteInfo;
import software.amazon.cryptography.materialproviders.model.CreateAwsKmsDiscoveryKeyringInput;
import software.amazon.cryptography.materialproviders.model.CreateAwsKmsDiscoveryMultiKeyringInput;
import software.amazon.cryptography.materialproviders.model.CreateAwsKmsHierarchicalKeyringInput;
import software.amazon.cryptography.materialproviders.model.CreateAwsKmsKeyringInput;
import software.amazon.cryptography.materialproviders.model.CreateAwsKmsMrkDiscoveryKeyringInput;
import software.amazon.cryptography.materialproviders.model.CreateAwsKmsMrkDiscoveryMultiKeyringInput;
import software.amazon.cryptography.materialproviders.model.CreateAwsKmsMrkKeyringInput;
import software.amazon.cryptography.materialproviders.model.CreateAwsKmsMrkMultiKeyringInput;
import software.amazon.cryptography.materialproviders.model.CreateAwsKmsMultiKeyringInput;
import software.amazon.cryptography.materialproviders.model.CreateAwsKmsRsaKeyringInput;
import software.amazon.cryptography.materialproviders.model.CreateCryptographicMaterialsCacheInput;
import software.amazon.cryptography.materialproviders.model.CreateDefaultClientSupplierInput;
import software.amazon.cryptography.materialproviders.model.CreateDefaultCryptographicMaterialsManagerInput;
import software.amazon.cryptography.materialproviders.model.CreateExpectedEncryptionContextCMMInput;
import software.amazon.cryptography.materialproviders.model.CreateMultiKeyringInput;
import software.amazon.cryptography.materialproviders.model.CreateRawAesKeyringInput;
import software.amazon.cryptography.materialproviders.model.CreateRawRsaKeyringInput;
import software.amazon.cryptography.materialproviders.model.DecryptionMaterials;
import software.amazon.cryptography.materialproviders.model.EncryptionMaterials;
import software.amazon.cryptography.materialproviders.model.InitializeDecryptionMaterialsInput;
import software.amazon.cryptography.materialproviders.model.InitializeEncryptionMaterialsInput;
import software.amazon.cryptography.materialproviders.model.MaterialProvidersConfig;
import software.amazon.cryptography.materialproviders.model.ValidDecryptionMaterialsTransitionInput;
import software.amazon.cryptography.materialproviders.model.ValidEncryptionMaterialsTransitionInput;
import software.amazon.cryptography.materialproviders.model.ValidateCommitmentPolicyOnDecryptInput;
import software.amazon.cryptography.materialproviders.model.ValidateCommitmentPolicyOnEncryptInput;

public class MaterialProviders {
  private final IAwsCryptographicMaterialProvidersClient _impl;

  protected MaterialProviders(BuilderImpl builder) {
    MaterialProvidersConfig nativeValue = builder.MaterialProvidersConfig();
    software.amazon.cryptography.materialproviders.internaldafny.types.MaterialProvidersConfig dafnyValue = ToDafny.MaterialProvidersConfig(nativeValue);
    Result<MaterialProvidersClient, Error> result = __default.MaterialProviders(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    this._impl = result.dtor_value();
  }

  MaterialProviders(IAwsCryptographicMaterialProvidersClient impl) {
    this._impl = impl;
  }

  public static Builder builder() {
    return new BuilderImpl();
  }

  /**
   * Creates an AWS KMS Discovery Keyring, which supports unwrapping data keys wrapped by a symmetric AWS KMS Key for a single region.
   *
   * @param createAwsKmsDiscoveryKeyringInput Inputs for for creating a AWS KMS Discovery Keyring.
   * @return Outputs for creating a Keyring.
   */
  public IKeyring CreateAwsKmsDiscoveryKeyring(CreateAwsKmsDiscoveryKeyringInput createAwsKmsDiscoveryKeyringInput) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateAwsKmsDiscoveryKeyringInput dafnyValue = ToDafny.CreateAwsKmsDiscoveryKeyringInput(createAwsKmsDiscoveryKeyringInput);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.IKeyring, Error> result = this._impl.CreateAwsKmsDiscoveryKeyring(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return Keyring.wrap(result.dtor_value());
  }

  /**
   * Creates an AWS KMS Discovery Multi-Keyring, which supports unwrapping data keys wrapped by a symmetric AWS KMS Key, for multiple regions.
   *
   * @param createAwsKmsDiscoveryMultiKeyringInput Inputs for for creating an AWS KMS Discovery Multi-Keyring.
   * @return Outputs for creating a Keyring.
   */
  public IKeyring CreateAwsKmsDiscoveryMultiKeyring(
      CreateAwsKmsDiscoveryMultiKeyringInput createAwsKmsDiscoveryMultiKeyringInput) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateAwsKmsDiscoveryMultiKeyringInput dafnyValue = ToDafny.CreateAwsKmsDiscoveryMultiKeyringInput(createAwsKmsDiscoveryMultiKeyringInput);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.IKeyring, Error> result = this._impl.CreateAwsKmsDiscoveryMultiKeyring(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return Keyring.wrap(result.dtor_value());
  }

  /**
   * Creates a Hierarchical Keyring, which supports wrapping and unwrapping data keys using Branch Keys persisted in DynamoDB and protected by a symmetric AWS KMS Key or AWS KMS Multi-Region Key.
   *
   * @param createAwsKmsHierarchicalKeyringInput Inputs for creating a Hierarchical Keyring.
   * @return Outputs for creating a Keyring.
   */
  public IKeyring CreateAwsKmsHierarchicalKeyring(
      CreateAwsKmsHierarchicalKeyringInput createAwsKmsHierarchicalKeyringInput) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateAwsKmsHierarchicalKeyringInput dafnyValue = ToDafny.CreateAwsKmsHierarchicalKeyringInput(createAwsKmsHierarchicalKeyringInput);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.IKeyring, Error> result = this._impl.CreateAwsKmsHierarchicalKeyring(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return Keyring.wrap(result.dtor_value());
  }

  /**
   * Creates an AWS KMS Keyring, which wraps and unwraps data keys using single symmetric AWS KMS Key.
   *
   * @param createAwsKmsKeyringInput Inputs for for creating a AWS KMS Keyring.
   * @return Outputs for creating a Keyring.
   */
  public IKeyring CreateAwsKmsKeyring(CreateAwsKmsKeyringInput createAwsKmsKeyringInput) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateAwsKmsKeyringInput dafnyValue = ToDafny.CreateAwsKmsKeyringInput(createAwsKmsKeyringInput);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.IKeyring, Error> result = this._impl.CreateAwsKmsKeyring(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return Keyring.wrap(result.dtor_value());
  }

  /**
   * Creates an AWS KMS MRK Discovery Keyring, which supports unwrapping data keys wrapped by a symmetric AWS KMS Key or AWS KMS Multi-Region Key in a particular region.
   *
   * @param createAwsKmsMrkDiscoveryKeyringInput Inputs for for creating a AWS KMS MRK Discovery Keyring.
   * @return Outputs for creating a Keyring.
   */
  public IKeyring CreateAwsKmsMrkDiscoveryKeyring(
      CreateAwsKmsMrkDiscoveryKeyringInput createAwsKmsMrkDiscoveryKeyringInput) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateAwsKmsMrkDiscoveryKeyringInput dafnyValue = ToDafny.CreateAwsKmsMrkDiscoveryKeyringInput(createAwsKmsMrkDiscoveryKeyringInput);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.IKeyring, Error> result = this._impl.CreateAwsKmsMrkDiscoveryKeyring(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return Keyring.wrap(result.dtor_value());
  }

  /**
   * Creates an AWS KMS MRK Discovery Multi-Keyring in 'discovery mode' that supports unwrapping data keys wrapped by a symmetric AWS KMS Key or AWS KMS Multi-Region Key, for a single region.
   *
   * @param createAwsKmsMrkDiscoveryMultiKeyringInput Inputs for for creating a AWS KMS MRK Discovery Multi-Keyring.
   * @return Outputs for creating a Keyring.
   */
  public IKeyring CreateAwsKmsMrkDiscoveryMultiKeyring(
      CreateAwsKmsMrkDiscoveryMultiKeyringInput createAwsKmsMrkDiscoveryMultiKeyringInput) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateAwsKmsMrkDiscoveryMultiKeyringInput dafnyValue = ToDafny.CreateAwsKmsMrkDiscoveryMultiKeyringInput(createAwsKmsMrkDiscoveryMultiKeyringInput);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.IKeyring, Error> result = this._impl.CreateAwsKmsMrkDiscoveryMultiKeyring(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return Keyring.wrap(result.dtor_value());
  }

  /**
   * Creates an AWS KMS MRK Keyring, which wraps and unwraps data keys using single symmetric AWS KMS Key or AWS KMS Multi-Region Key.
   *
   * @param createAwsKmsMrkKeyringInput Inputs for for creating an AWS KMS MRK Keyring.
   * @return Outputs for creating a Keyring.
   */
  public IKeyring CreateAwsKmsMrkKeyring(CreateAwsKmsMrkKeyringInput createAwsKmsMrkKeyringInput) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateAwsKmsMrkKeyringInput dafnyValue = ToDafny.CreateAwsKmsMrkKeyringInput(createAwsKmsMrkKeyringInput);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.IKeyring, Error> result = this._impl.CreateAwsKmsMrkKeyring(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return Keyring.wrap(result.dtor_value());
  }

  /**
   * Creates an AWS KMS MRK Multi-Keyring, which wraps and unwraps data keys using one or more symmetric AWS KMS Keys or AWS KMS Multi-Region Keys.
   *
   * @param createAwsKmsMrkMultiKeyringInput Inputs for for creating a AWS KMS MRK Multi-Keyring.
   * @return Outputs for creating a Keyring.
   */
  public IKeyring CreateAwsKmsMrkMultiKeyring(CreateAwsKmsMrkMultiKeyringInput createAwsKmsMrkMultiKeyringInput) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateAwsKmsMrkMultiKeyringInput dafnyValue = ToDafny.CreateAwsKmsMrkMultiKeyringInput(createAwsKmsMrkMultiKeyringInput);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.IKeyring, Error> result = this._impl.CreateAwsKmsMrkMultiKeyring(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return Keyring.wrap(result.dtor_value());
  }

  /**
   * Creates an AWS KMS Multi-Keyring, which wraps and unwraps data keys using one or more symmetric AWS KMS Keys.
   *
   * @param createAwsKmsMultiKeyringInput Inputs for for creating a AWS KMS Multi-Keyring.
   * @return Outputs for creating a Keyring.
   */
  public IKeyring CreateAwsKmsMultiKeyring(CreateAwsKmsMultiKeyringInput createAwsKmsMultiKeyringInput) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateAwsKmsMultiKeyringInput dafnyValue = ToDafny.CreateAwsKmsMultiKeyringInput(createAwsKmsMultiKeyringInput);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.IKeyring, Error> result = this._impl.CreateAwsKmsMultiKeyring(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return Keyring.wrap(result.dtor_value());
  }

  /**
   * Creates an AWS KMS RSA Keyring, which wraps and unwraps data keys using a single asymmetric AWS KMS Key for RSA.
   *
   * @param createAwsKmsRsaKeyringInput Inputs for creating a AWS KMS RSA Keyring.
   * @return Outputs for creating a Keyring.
   */
  public IKeyring CreateAwsKmsRsaKeyring(CreateAwsKmsRsaKeyringInput createAwsKmsRsaKeyringInput) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateAwsKmsRsaKeyringInput dafnyValue = ToDafny.CreateAwsKmsRsaKeyringInput(createAwsKmsRsaKeyringInput);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.IKeyring, Error> result = this._impl.CreateAwsKmsRsaKeyring(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return Keyring.wrap(result.dtor_value());
  }

  public ICryptographicMaterialsCache CreateCryptographicMaterialsCache(
      CreateCryptographicMaterialsCacheInput nativeValue) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateCryptographicMaterialsCacheInput dafnyValue = ToDafny.CreateCryptographicMaterialsCacheInput(nativeValue);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.ICryptographicMaterialsCache, Error> result = this._impl.CreateCryptographicMaterialsCache(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return CryptographicMaterialsCache.wrap(result.dtor_value());
  }

  public IClientSupplier CreateDefaultClientSupplier(CreateDefaultClientSupplierInput nativeValue) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateDefaultClientSupplierInput dafnyValue = ToDafny.CreateDefaultClientSupplierInput(nativeValue);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.IClientSupplier, Error> result = this._impl.CreateDefaultClientSupplier(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return ClientSupplier.wrap(result.dtor_value());
  }

  /**
   * Creates a Default Cryptographic Materials Manager.
   *
   * @param createDefaultCryptographicMaterialsManagerInput Inputs for creating a Default Cryptographic Materials Manager.
   * @return Outputs for creating a Default Cryptographic Materials Manager.
   */
  public ICryptographicMaterialsManager CreateDefaultCryptographicMaterialsManager(
      CreateDefaultCryptographicMaterialsManagerInput createDefaultCryptographicMaterialsManagerInput) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateDefaultCryptographicMaterialsManagerInput dafnyValue = ToDafny.CreateDefaultCryptographicMaterialsManagerInput(createDefaultCryptographicMaterialsManagerInput);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.ICryptographicMaterialsManager, Error> result = this._impl.CreateDefaultCryptographicMaterialsManager(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return CryptographicMaterialsManager.wrap(result.dtor_value());
  }

  /**
   * Creates an Expected Cryptographic Materials Manager.
   *
   * @param createExpectedEncryptionContextCMMInput Inputs for creating an Expected Cryptographic Materials Manager.
   * @return Outputs for creating an Expected Cryptographic Materials Manager.
   */
  public ICryptographicMaterialsManager CreateExpectedEncryptionContextCMM(
      CreateExpectedEncryptionContextCMMInput createExpectedEncryptionContextCMMInput) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateExpectedEncryptionContextCMMInput dafnyValue = ToDafny.CreateExpectedEncryptionContextCMMInput(createExpectedEncryptionContextCMMInput);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.ICryptographicMaterialsManager, Error> result = this._impl.CreateExpectedEncryptionContextCMM(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return CryptographicMaterialsManager.wrap(result.dtor_value());
  }

  /**
   * Creates a Multi-Keyring comprised of one or more other Keyrings.
   *
   * @param createMultiKeyringInput Inputs for creating a Multi-Keyring.
   * @return Outputs for creating a Keyring.
   */
  public IKeyring CreateMultiKeyring(CreateMultiKeyringInput createMultiKeyringInput) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateMultiKeyringInput dafnyValue = ToDafny.CreateMultiKeyringInput(createMultiKeyringInput);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.IKeyring, Error> result = this._impl.CreateMultiKeyring(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return Keyring.wrap(result.dtor_value());
  }

  /**
   * Creates a Raw AES Keyring, which wraps and unwraps data keys locally using AES_GCM.
   *
   * @param createRawAesKeyringInput Inputs for creating a Raw AES Keyring.
   * @return Outputs for creating a Keyring.
   */
  public IKeyring CreateRawAesKeyring(CreateRawAesKeyringInput createRawAesKeyringInput) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateRawAesKeyringInput dafnyValue = ToDafny.CreateRawAesKeyringInput(createRawAesKeyringInput);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.IKeyring, Error> result = this._impl.CreateRawAesKeyring(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return Keyring.wrap(result.dtor_value());
  }

  /**
   * Creates a Raw RSA Keyring, which wraps and unwraps data keys locally using RSA.
   *
   * @param createRawRsaKeyringInput Inputs for creating a Raw RAW Keyring.
   * @return Outputs for creating a Keyring.
   */
  public IKeyring CreateRawRsaKeyring(CreateRawRsaKeyringInput createRawRsaKeyringInput) {
    software.amazon.cryptography.materialproviders.internaldafny.types.CreateRawRsaKeyringInput dafnyValue = ToDafny.CreateRawRsaKeyringInput(createRawRsaKeyringInput);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.IKeyring, Error> result = this._impl.CreateRawRsaKeyring(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return Keyring.wrap(result.dtor_value());
  }

  public void DecryptionMaterialsWithPlaintextDataKey(DecryptionMaterials nativeValue) {
    software.amazon.cryptography.materialproviders.internaldafny.types.DecryptionMaterials dafnyValue = ToDafny.DecryptionMaterials(nativeValue);
    Result<Tuple0, Error> result = this._impl.DecryptionMaterialsWithPlaintextDataKey(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
  }

  public void EncryptionMaterialsHasPlaintextDataKey(EncryptionMaterials nativeValue) {
    software.amazon.cryptography.materialproviders.internaldafny.types.EncryptionMaterials dafnyValue = ToDafny.EncryptionMaterials(nativeValue);
    Result<Tuple0, Error> result = this._impl.EncryptionMaterialsHasPlaintextDataKey(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
  }

  public AlgorithmSuiteInfo GetAlgorithmSuiteInfo(ByteBuffer nativeValue) {
    DafnySequence<? extends Byte> dafnyValue = ToDafny.GetAlgorithmSuiteInfoInput(nativeValue);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.AlgorithmSuiteInfo, Error> result = this._impl.GetAlgorithmSuiteInfo(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return ToNative.AlgorithmSuiteInfo(result.dtor_value());
  }

  public DecryptionMaterials InitializeDecryptionMaterials(
      InitializeDecryptionMaterialsInput nativeValue) {
    software.amazon.cryptography.materialproviders.internaldafny.types.InitializeDecryptionMaterialsInput dafnyValue = ToDafny.InitializeDecryptionMaterialsInput(nativeValue);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.DecryptionMaterials, Error> result = this._impl.InitializeDecryptionMaterials(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return ToNative.DecryptionMaterials(result.dtor_value());
  }

  public EncryptionMaterials InitializeEncryptionMaterials(
      InitializeEncryptionMaterialsInput nativeValue) {
    software.amazon.cryptography.materialproviders.internaldafny.types.InitializeEncryptionMaterialsInput dafnyValue = ToDafny.InitializeEncryptionMaterialsInput(nativeValue);
    Result<software.amazon.cryptography.materialproviders.internaldafny.types.EncryptionMaterials, Error> result = this._impl.InitializeEncryptionMaterials(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return ToNative.EncryptionMaterials(result.dtor_value());
  }

  public void ValidAlgorithmSuiteInfo(AlgorithmSuiteInfo nativeValue) {
    software.amazon.cryptography.materialproviders.internaldafny.types.AlgorithmSuiteInfo dafnyValue = ToDafny.AlgorithmSuiteInfo(nativeValue);
    Result<Tuple0, Error> result = this._impl.ValidAlgorithmSuiteInfo(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
  }

  public void ValidateCommitmentPolicyOnDecrypt(
      ValidateCommitmentPolicyOnDecryptInput nativeValue) {
    software.amazon.cryptography.materialproviders.internaldafny.types.ValidateCommitmentPolicyOnDecryptInput dafnyValue = ToDafny.ValidateCommitmentPolicyOnDecryptInput(nativeValue);
    Result<Tuple0, Error> result = this._impl.ValidateCommitmentPolicyOnDecrypt(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
  }

  public void ValidateCommitmentPolicyOnEncrypt(
      ValidateCommitmentPolicyOnEncryptInput nativeValue) {
    software.amazon.cryptography.materialproviders.internaldafny.types.ValidateCommitmentPolicyOnEncryptInput dafnyValue = ToDafny.ValidateCommitmentPolicyOnEncryptInput(nativeValue);
    Result<Tuple0, Error> result = this._impl.ValidateCommitmentPolicyOnEncrypt(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
  }

  public void ValidDecryptionMaterialsTransition(
      ValidDecryptionMaterialsTransitionInput nativeValue) {
    software.amazon.cryptography.materialproviders.internaldafny.types.ValidDecryptionMaterialsTransitionInput dafnyValue = ToDafny.ValidDecryptionMaterialsTransitionInput(nativeValue);
    Result<Tuple0, Error> result = this._impl.ValidDecryptionMaterialsTransition(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
  }

  public void ValidEncryptionMaterialsTransition(
      ValidEncryptionMaterialsTransitionInput nativeValue) {
    software.amazon.cryptography.materialproviders.internaldafny.types.ValidEncryptionMaterialsTransitionInput dafnyValue = ToDafny.ValidEncryptionMaterialsTransitionInput(nativeValue);
    Result<Tuple0, Error> result = this._impl.ValidEncryptionMaterialsTransition(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
  }

  protected IAwsCryptographicMaterialProvidersClient impl() {
    return this._impl;
  }

  public interface Builder {
    Builder MaterialProvidersConfig(MaterialProvidersConfig MaterialProvidersConfig);

    MaterialProvidersConfig MaterialProvidersConfig();

    MaterialProviders build();
  }

  static class BuilderImpl implements Builder {
    protected MaterialProvidersConfig MaterialProvidersConfig;

    protected BuilderImpl() {
    }

    public Builder MaterialProvidersConfig(MaterialProvidersConfig MaterialProvidersConfig) {
      this.MaterialProvidersConfig = MaterialProvidersConfig;
      return this;
    }

    public MaterialProvidersConfig MaterialProvidersConfig() {
      return this.MaterialProvidersConfig;
    }

    public MaterialProviders build() {
      if (Objects.isNull(this.MaterialProvidersConfig()))  {
        throw new IllegalArgumentException("Missing value for required field `MaterialProvidersConfig`");
      }
      return new MaterialProviders(this);
    }
  }
}
