// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
// Do not modify this file. This file is machine generated, and any changes to it will be overwritten.
package software.amazon.cryptography.materialProviders.wrapped.keys;

import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.KeyVectorsClient;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.Error;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.IKeyVectorsClient;
import Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.__default;
import Wrappers_Compile.Result;
import java.lang.IllegalArgumentException;
import java.util.Objects;
import software.amazon.cryptography.materialProviders.IKeyring;
import software.amazon.cryptography.materialProviders.Keyring;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.GetKeyDescriptionInput;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.GetKeyDescriptionOutput;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.KeyVectorsConfig;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.SerializeKeyDescriptionInput;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.SerializeKeyDescriptionOutput;
import software.amazon.cryptography.materialProviders.wrapped.keys.model.TestVectorKeyringInput;

public class KeyVectors {
  private final IKeyVectorsClient _impl;

  protected KeyVectors(BuilderImpl builder) {
    KeyVectorsConfig nativeValue = builder.KeyVectorsConfig();
    Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.KeyVectorsConfig dafnyValue = ToDafny.KeyVectorsConfig(nativeValue);
    Result<KeyVectorsClient, Error> result = __default.KeyVectors(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    this._impl = result.dtor_value();
  }

  public static Builder builder() {
    return new BuilderImpl();
  }

  public IKeyring CreateTestVectorKeyring(TestVectorKeyringInput nativeValue) {
    Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.TestVectorKeyringInput dafnyValue = ToDafny.TestVectorKeyringInput(nativeValue);
    Result<Dafny.Aws.Cryptography.MaterialProviders.Types.IKeyring, Error> result = this._impl.CreateTestVectorKeyring(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return Keyring.wrap(result.dtor_value());
  }

  public IKeyring CreateWappedTestVectorKeyring(TestVectorKeyringInput nativeValue) {
    Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.TestVectorKeyringInput dafnyValue = ToDafny.TestVectorKeyringInput(nativeValue);
    Result<Dafny.Aws.Cryptography.MaterialProviders.Types.IKeyring, Error> result = this._impl.CreateWappedTestVectorKeyring(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return Keyring.wrap(result.dtor_value());
  }

  public GetKeyDescriptionOutput GetKeyDescription(GetKeyDescriptionInput nativeValue) {
    Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.GetKeyDescriptionInput dafnyValue = ToDafny.GetKeyDescriptionInput(nativeValue);
    Result<Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.GetKeyDescriptionOutput, Error> result = this._impl.GetKeyDescription(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return ToNative.GetKeyDescriptionOutput(result.dtor_value());
  }

  public SerializeKeyDescriptionOutput SerializeKeyDescription(
      SerializeKeyDescriptionInput nativeValue) {
    Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.SerializeKeyDescriptionInput dafnyValue = ToDafny.SerializeKeyDescriptionInput(nativeValue);
    Result<Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.SerializeKeyDescriptionOutput, Error> result = this._impl.SerializeKeyDescription(dafnyValue);
    if (result.is_Failure()) {
      throw ToNative.Error(result.dtor_error());
    }
    return ToNative.SerializeKeyDescriptionOutput(result.dtor_value());
  }

  protected IKeyVectorsClient impl() {
    return this._impl;
  }

  public interface Builder {
    Builder KeyVectorsConfig(KeyVectorsConfig KeyVectorsConfig);

    KeyVectorsConfig KeyVectorsConfig();

    KeyVectors build();
  }

  static class BuilderImpl implements Builder {
    protected KeyVectorsConfig KeyVectorsConfig;

    protected BuilderImpl() {
    }

    public Builder KeyVectorsConfig(KeyVectorsConfig KeyVectorsConfig) {
      this.KeyVectorsConfig = KeyVectorsConfig;
      return this;
    }

    public KeyVectorsConfig KeyVectorsConfig() {
      return this.KeyVectorsConfig;
    }

    public KeyVectors build() {
      if (Objects.isNull(this.KeyVectorsConfig()))  {
        throw new IllegalArgumentException("Missing value for required field `KeyVectorsConfig`");
      }
      return new KeyVectors(this);
    }
  }
}
