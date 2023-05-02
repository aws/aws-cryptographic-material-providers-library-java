// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
// Do not modify this file. This file is machine generated, and any changes to it will be overwritten.
package software.amazon.cryptography.materialProvidersTestVectorKeys.model;

import java.util.Objects;

public class Hierarchy {
  private final String branchKeyId;

  protected Hierarchy(BuilderImpl builder) {
    this.branchKeyId = builder.branchKeyId();
  }

  public String branchKeyId() {
    return this.branchKeyId;
  }

  public Builder toBuilder() {
    return new BuilderImpl(this);
  }

  public static Builder builder() {
    return new BuilderImpl();
  }

  public interface Builder {
    Builder branchKeyId(String branchKeyId);

    String branchKeyId();

    Hierarchy build();
  }

  static class BuilderImpl implements Builder {
    protected String branchKeyId;

    protected BuilderImpl() {
    }

    protected BuilderImpl(Hierarchy model) {
      this.branchKeyId = model.branchKeyId();
    }

    public Builder branchKeyId(String branchKeyId) {
      this.branchKeyId = branchKeyId;
      return this;
    }

    public String branchKeyId() {
      return this.branchKeyId;
    }

    public Hierarchy build() {
      if (Objects.isNull(this.branchKeyId()))  {
        throw new IllegalArgumentException("Missing value for required field `branchKeyId`");
      }
      return new Hierarchy(this);
    }
  }
}
