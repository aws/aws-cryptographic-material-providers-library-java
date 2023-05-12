// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "KeysVectorOperations.dfy"
include "../../TestVectorsAwsCryptographicMaterialProviders/src/JSONHelpers.dfy"
include "KeyMaterial.dfy"

module {:extern "Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys"} KeyVectors refines AbstractAwsCryptographyMaterialProvidersWrappedKeysService {
  import Operations = KeysVectorOperations
  import JSON.API
  import JSON.Errors
  import FileIO
  import opened JSONHelpers
  import KeyMaterial
  import MaterialProviders

  function method DefaultKeyVectorsConfig() : KeyVectorsConfig {
    KeyVectorsConfig(
      keyManifiestPath := ""
    )
  }

  method KeyVectors(config: KeyVectorsConfig)
    returns (res: Result<KeyVectorsClient, Error>)
  {
    var keysManifestBv :- expect FileIO.ReadBytesFromFile(config.keyManifiestPath);
    var keysManifestBytes := BvToBytes(keysManifestBv);
    var keysManifestJSON :- API.Deserialize(keysManifestBytes)
    .MapFailure((e: Errors.DeserializationError)  => KeyVectorException(
                    message := e.ToString()
                  ));
    expect keysManifestJSON.Object?;
    var keysObject :- expect Get("keys", keysManifestJSON.obj);
    expect keysObject.Object?;

    var maybeMpl := MaterialProviders.MaterialProviders();
    var mpl :- maybeMpl.MapFailure(e => AwsCryptographyMaterialProviders(e));

    var keys :- KeyMaterial.BuildKeyMaterials(mpl, keysObject.obj)
    .MapFailure((e) => KeyVectorException(
                    message := e
                  ));

    var config := Operations.Config( keys := keys );
    var client := new KeyVectorsClient(config);

    res := Success(client);
  }

  class KeyVectorsClient... {

    predicate ValidState()
    {
      && Operations.ValidInternalConfig?(config)
      && Modifies == Operations.ModifiesInternalConfig(config) + {History}
    }

    constructor(config: Operations.InternalConfig)
    {
      this.config := config;
      History := new IKeyVectorsClientCallHistory();
      Modifies := Operations.ModifiesInternalConfig(config) + {History};
    }

  }

}
