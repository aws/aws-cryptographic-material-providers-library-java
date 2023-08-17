// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../Model/AwsCryptographyPrimitivesTypes.dfy"

module
  {:options "-functionSyntax:4"}
  {:extern "ACCP"}
  ACCP
{
  import opened Wrappers
  import opened StandardLibrary
  import opened UInt = StandardLibrary.UInt
  import Types = AwsCryptographyPrimitivesTypes
  // An extern that checks for ACCP
  // if hdfkPolicy is NONE,  return if ACCP is installed and version is >= 2.3
  // otherwise, return if ACCP is installed, version is >= 2.3, && FIPS is enabled.
  method
  {:extern "ACCP.ACCPUtils", "ExternCheckForAccp"}
  ExternCheckForAccp(hkdfPolicy: Types.HKDFPolicy)
    returns (res: bool)
}
