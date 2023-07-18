package CallMany;

import Wrappers_Compile.Result;
import dafny.DafnySequence;

import CallMany.Callee;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class __default {
    public __default() {
    }
    public static void CallMany(Callee callee, int innerIters, int outerIters, int threads)
    {
        // Runnable myThread = (n) -> {
        //     for(int j = 0; j < innerIters; ++j) {
        //         callee.call(i, j);
        //     }
        // };
        ExecutorService pool = Executors.newFixedThreadPool(threads);  
        for(int i = 0; i < outerIters; i++) {
            final int ii = i;
            pool.execute(() -> {
                for(int j = 0; j < innerIters; ++j) {
                    callee.call(ii, j);
                }
            }
            );
        }
        pool.shutdown();
        try {pool.awaitTermination(120, TimeUnit.SECONDS);} catch (Exception e) {}
    }
    private static final dafny.TypeDescriptor<__default> _TYPE = dafny.TypeDescriptor.<__default>referenceWithInitializer(__default.class, () -> (__default) null);
    public static dafny.TypeDescriptor<__default> _typeDescriptor() {
      return (dafny.TypeDescriptor<__default>) (dafny.TypeDescriptor<?>) _TYPE;
    }
    @Override
    public java.lang.String toString() {
      return "CallMany_Compile._default";
    }
  }

