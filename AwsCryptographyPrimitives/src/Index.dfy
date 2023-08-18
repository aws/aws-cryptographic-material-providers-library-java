// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../Model/AwsCryptographyPrimitivesTypes.dfy"
include "AwsCryptographyPrimitivesOperations.dfy"

module {:extern "software.amazon.cryptography.primitives.internaldafny" } Aws.Cryptography.Primitives refines AbstractAwsCryptographyPrimitivesService {
  import Operations = AwsCryptographyPrimitivesOperations

  function method DefaultCryptoConfig(): CryptoConfig {
    CryptoConfig(
      hkdfPolicy := None
    )
  }

  method AtomicPrimitives(config: CryptoConfig)
    returns (res: Result<AtomicPrimitivesClient, Error>)
  {
    var finalConfig: Operations.Config;
    var accpInstalled :- CheckForAccp(config);
    finalConfig := Operations.Config(
      hkdfProvider := accpInstalled
    );
    // TODO: author an extern that runs here and checks if ACCP-FIPS is registered.
    // If it is, then the AtomicPrimitivesClient ALWAYS uses it.
    // If it is not, and the policy is NONE or Not set,
    // we carry on.
    // Otherwise, we fail.
    var client := new AtomicPrimitivesClient(finalConfig);
    return Success(client);
  }

  method CheckForAccp(config: CryptoConfig)
    returns (res: Result<HKDFProvider, Error>)
  {
    // TODO: call an extern that checks for ACCP
    // If config requires FIPS, and FIPS is not installed, return Failure.
    // Then, return if ACCP is installed and version is >= 2.3
    var policy: HKDFPolicy := config.hkdfPolicy.UnwrapOr(NONE);
    res := Operations.CheckForAccp(policy);
  }

  class AtomicPrimitivesClient... {

    predicate ValidState()
    {
      && Operations.ValidInternalConfig?(config)
      && Modifies == Operations.ModifiesInternalConfig(config) + {History}
    }

    constructor(config: Operations.InternalConfig)
    {
      this.config := config;
      History := new IAwsCryptographicPrimitivesClientCallHistory();
      Modifies := Operations.ModifiesInternalConfig(config) + {History};
    }

  }
}
