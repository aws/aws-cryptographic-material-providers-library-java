// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../src/StandardLibrary.dfy"
include "../src/CallMany.dfy"

module TestCallMany {
  import opened StandardLibrary
  import opened Wrappers
  import opened StandardLibrary.UInt
  import opened BoundedInts
  import CallMany


  class MyCallee extends CallMany.Callee {
    var count : uint32
    constructor()
    {
      count := 0;
    }
    method call(inner : uint32, outer : uint32)
      modifies this
    {
      if count < UINT32_MAX {
        count := count + 1; // not technically thread safe, but usually works
      }
    }
  }

  method {:test} TestBasic() {
    var c := new MyCallee();
    CallMany.CallMany(c, 2, 3, 2);
    expect c.count == 6;
  }

}
