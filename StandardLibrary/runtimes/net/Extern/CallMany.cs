// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

using System;
using System.Numerics;
using Microsoft.VisualBasic;
using Wrappers_Compile;
using ibyteseq = Dafny.ISequence<byte>;
using byteseq = Dafny.Sequence<byte>;
using icharseq = Dafny.ISequence<char>;
using charseq = Dafny.Sequence<char>;

namespace CallMany
{

  public partial class __default
  {
    public static void CallMany(CallMany.Callee callee, uint innerIters, uint outerIters, uint threads)
    {
      Thread[] threadsArray = new Thread[outerIters];
      for (uint i = 0; i < outerIters; i++)
      {
        uint localNum = i;
        threadsArray[i] = new Thread(() =>
        {
          for (uint j = 0; j < innerIters; ++j)
          {
            (callee).call(j, localNum);
          };
        });
      }
      for (uint i = 0; i < outerIters; i++)
        threadsArray[i].Start();

      for (uint i = 0; i < outerIters; i++)
        threadsArray[i].Join();

    }
  }
}
