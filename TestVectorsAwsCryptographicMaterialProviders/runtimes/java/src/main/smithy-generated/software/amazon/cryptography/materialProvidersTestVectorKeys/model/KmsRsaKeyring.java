// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
// Do not modify this file. This file is machine generated, and any changes to it will be overwritten.
package software.amazon.cryptography.materialProvidersTestVectorKeys.model;

import java.util.Objects;

public class KmsRsaKeyring {
  private final String keyId;

  protected KmsRsaKeyring(BuilderImpl builder) {
    this.keyId = builder.keyId();
  }

  public String keyId() {
    return this.keyId;
  }

  public Builder toBuilder() {
    return new BuilderImpl(this);
  }

  public static Builder builder() {
    return new BuilderImpl();
  }

  public interface Builder {
    Builder keyId(String keyId);

    String keyId();

    KmsRsaKeyring build();
  }

  static class BuilderImpl implements Builder {
    protected String keyId;

    protected BuilderImpl() {
    }

    protected BuilderImpl(KmsRsaKeyring model) {
      this.keyId = model.keyId();
    }

    public Builder keyId(String keyId) {
      this.keyId = keyId;
      return this;
    }

    public String keyId() {
      return this.keyId;
    }

    public KmsRsaKeyring build() {
      if (Objects.isNull(this.keyId()))  {
        throw new IllegalArgumentException("Missing value for required field `keyId`");
      }
      return new KmsRsaKeyring(this);
    }
  }
}
