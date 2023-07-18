// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "./StandardLibrary.dfy"
include "./UInt.dfy"

module {:extern "CallMany"} CallMany {
  import opened StandardLibrary
  import opened Wrappers
  import opened StandardLibrary.UInt

  trait {:termination false} Callee {
    method call(inner : uint32, outer : uint32)
      modifies (set o: object | true)
      // modifies this
  }

  method {:extern "CallMany"} CallMany(callee : Callee, innerIters : uint32, outerIters : uint32, threads : uint32)


}
