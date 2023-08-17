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
    // TODO: Replace this if statement with the extern logic
    // and Operations Config refactor described below
    // and in Operations
    if (config.hkdfPolicy.None?) {
      finalConfig := Operations.Config(
        hkdfPolicy := HKDFPolicy.NONE
      );
    } else {
      finalConfig := Operations.Config(
        hkdfPolicy := config.hkdfPolicy.Extract()
      );
    }
    // TODO: author an extern that runs here and checks if ACCP-FIPS is registered.
    // If it is, then the AtomicPrimitivesClient ALWAYS uses it.
    // If it is not, and the policy is NONE or Not set,
    // we carry on.
    // Otherwise, we fail.
    var client := new AtomicPrimitivesClient(finalConfig);
    return Success(client);
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
