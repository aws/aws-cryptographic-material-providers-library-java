// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
// Do not modify this file. This file is machine generated, and any changes to it will be overwritten.
package software.amazon.cryptography.materialproviders;

import software.amazon.awssdk.services.kms.KmsClient;
import software.amazon.cryptography.materialproviders.model.GetClientInput;

public interface IClientSupplier {
  /**
   * Returns an AWS KMS Client.
   *
   * @param input Inputs for getting a AWS KMS Client.
   *
   */
  KmsClient GetClient(GetClientInput input);
}
