// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "./StandardLibrary.dfy"
include "./UInt.dfy"

/*
  Call a single function many times in many threads

  CallMany(callee : Callee, innerIters : uint32, outerIters : uint32, threads : uint32)
  This is effectively 

  for i n 0..outerIters
     for j in 0..innerIters
       callee(j, i)

  but multi threaded.
  Depending on the platform, the number of parallel threads is either `threads` or `outerIters`
*/

module {:extern "CallMany"} CallMany {
  import opened StandardLibrary
  import opened Wrappers
  import opened StandardLibrary.UInt

  trait {:termination false} Callee {
    method call(inner : uint32, outer : uint32)
      modifies (set o: object | true)
    // modifies this, plus anything else that might be needed.
  }

  method {:extern "CallMany"} CallMany(callee : Callee, innerIters : uint32, outerIters : uint32, threads : uint32)


}
