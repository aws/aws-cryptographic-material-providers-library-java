// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
package software.amazon.cryptography.primitives;

import org.testng.annotations.Test;

import java.nio.ByteBuffer;

import software.amazon.cryptography.primitives.model.CryptoConfig;
import software.amazon.cryptography.primitives.model.DigestAlgorithm;
import software.amazon.cryptography.primitives.model.HKDFPolicy;
import software.amazon.cryptography.primitives.model.HkdfInput;

import static org.testng.Assert.assertEquals;

public class ClientTest {
  private static HkdfInput HKDF_INPUT_A1 = HkdfInput.builder()
      .digestAlgorithm(DigestAlgorithm.SHA_256)
      .ikm(ByteBuffer.wrap(TestUtils.fromHex("0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b")))
      .salt(ByteBuffer.wrap(TestUtils.fromHex("000102030405060708090a0b0c")))
      .info(ByteBuffer.wrap(TestUtils.fromHex("f0f1f2f3f4f5f6f7f8f")))
      .expectedLength(42)
      .build();
  private static ByteBuffer OKM_A1 = ByteBuffer.wrap(TestUtils.fromHex(
      "3cb25f25faacd57a90434f64d0362f2a" +
      "2d2d0a90cf1a5a4c5db02d56ecc4c5bf" +
      "34007208d5b887185865"));

  @Test
  public void TestHKDFPolicyNone() {
    CryptoConfig config = CryptoConfig.builder()
        .hkdfPolicy(HKDFPolicy.NONE).build();
    AtomicPrimitives client = AtomicPrimitives.builder().CryptoConfig(config).build();
    ByteBuffer actual = client.Hkdf(HKDF_INPUT_A1);
    assertEquals(actual, OKM_A1);
  }

  @Test
  public void TestHKDFPolicyRequireFIPS() {
    CryptoConfig config = CryptoConfig.builder()
        .hkdfPolicy(HKDFPolicy.REQUIRE_FIPS_HKDF).build();
    AtomicPrimitives client = AtomicPrimitives.builder().CryptoConfig(config).build();
    ByteBuffer actual = client.Hkdf(HKDF_INPUT_A1);
    assertEquals(actual, OKM_A1);
  }
}
