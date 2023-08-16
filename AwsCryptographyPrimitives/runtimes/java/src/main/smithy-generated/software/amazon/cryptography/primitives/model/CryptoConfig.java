// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
// Do not modify this file. This file is machine generated, and any changes to it will be overwritten.
package software.amazon.cryptography.primitives.model;

public class CryptoConfig {
  private final HKDFPolicy hkdfPolicy;

  protected CryptoConfig(BuilderImpl builder) {
    this.hkdfPolicy = builder.hkdfPolicy();
  }

  public HKDFPolicy hkdfPolicy() {
    return this.hkdfPolicy;
  }

  public Builder toBuilder() {
    return new BuilderImpl(this);
  }

  public static Builder builder() {
    return new BuilderImpl();
  }

  public interface Builder {
    Builder hkdfPolicy(HKDFPolicy hkdfPolicy);

    HKDFPolicy hkdfPolicy();

    CryptoConfig build();
  }

  static class BuilderImpl implements Builder {
    protected HKDFPolicy hkdfPolicy;

    protected BuilderImpl() {
    }

    protected BuilderImpl(CryptoConfig model) {
      this.hkdfPolicy = model.hkdfPolicy();
    }

    public Builder hkdfPolicy(HKDFPolicy hkdfPolicy) {
      this.hkdfPolicy = hkdfPolicy;
      return this;
    }

    public HKDFPolicy hkdfPolicy() {
      return this.hkdfPolicy;
    }

    public CryptoConfig build() {
      return new CryptoConfig(this);
    }
  }
}
