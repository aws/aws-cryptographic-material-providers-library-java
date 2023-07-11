// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

module Fixtures {
  // The following are test resources that exist in tests accounts:

  const branchKeyStoreName := "KeyStoreTestTableV2"
  const logicalKeyStoreName := branchKeyStoreName;
  const branchKeyId := "71c83ce3-aad6-4aab-a4c4-d02bb9273305";
  // THESE ARE TESTING RESOURCES DO NOT USE IN A PRODUCTION ENVIRONMENT
  const keyArn := "arn:aws:kms:us-west-2:370957321024:key/9d989aa2-2f9c-438c-a745-cc57d3ad0126";
  const mkrKeyArn := "arn:aws:kms:us-west-2:370957321024:key/mrk-63d386cb70614ea59b32ad65c9315297";
  const keyId := "9d989aa2-2f9c-438c-a745-cc57d3ad0126";

}
