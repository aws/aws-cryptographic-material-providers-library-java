// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

using software.amazon.cryptography.primitives.internaldafny.types;

namespace software.amazon.cryptography.internaldafny
{
  public partial class SynchronizedLocalCMC : software.amazon.cryptography.materialproviders.internaldafny.types.ICryptographicMaterialsCache
  {
    public LocalCMC_Compile.LocalCMC wrapped;
    public SynchronizedLocalCMC(LocalCMC_Compile.LocalCMC cmc)
    {
      this.wrapped = cmc;
    }
    [System.Runtime.CompilerServices.MethodImpl(System.Runtime.CompilerServices.MethodImplOptions.Synchronized)]
    public Wrappers_Compile._IResult<_System._ITuple0, software.amazon.cryptography.materialproviders.internaldafny.types._IError> PutCacheEntry(software.amazon.cryptography.materialproviders.internaldafny.types._IPutCacheEntryInput input)
    {
      return this.wrapped.PutCacheEntry(input);
    }
    [System.Runtime.CompilerServices.MethodImpl(System.Runtime.CompilerServices.MethodImplOptions.Synchronized)]
    public Wrappers_Compile._IResult<_System._ITuple0, software.amazon.cryptography.materialproviders.internaldafny.types._IError> UpdaterUsageMetadata(software.amazon.cryptography.materialproviders.internaldafny.types._IUpdaterUsageMetadataInput input)
    {
      return this.wrapped.UpdaterUsageMetadata(input);
    }
    [System.Runtime.CompilerServices.MethodImpl(System.Runtime.CompilerServices.MethodImplOptions.Synchronized)]
    public Wrappers_Compile._IResult<software.amazon.cryptography.materialproviders.internaldafny.types._IGetCacheEntryOutput, software.amazon.cryptography.materialproviders.internaldafny.types._IError> GetCacheEntry(software.amazon.cryptography.materialproviders.internaldafny.types._IGetCacheEntryInput input)
    {
      return GetCacheEntry(input);
    }
    [System.Runtime.CompilerServices.MethodImpl(System.Runtime.CompilerServices.MethodImplOptions.Synchronized)]
    public Wrappers_Compile._IResult<_System._ITuple0, software.amazon.cryptography.materialproviders.internaldafny.types._IError> DeleteCacheEntry(software.amazon.cryptography.materialproviders.internaldafny.types._IDeleteCacheEntryInput input)
    {
      return DeleteCacheEntry(input);
    }
    [System.Runtime.CompilerServices.MethodImpl(System.Runtime.CompilerServices.MethodImplOptions.Synchronized)]
    public Wrappers_Compile._IResult<software.amazon.cryptography.materialproviders.internaldafny.types._IGetCacheEntryOutput, software.amazon.cryptography.materialproviders.internaldafny.types._IError> GetCacheEntry_k(software.amazon.cryptography.materialproviders.internaldafny.types._IGetCacheEntryInput input)
    {
      return wrapped.GetCacheEntry_k(input);
    }
    [System.Runtime.CompilerServices.MethodImpl(System.Runtime.CompilerServices.MethodImplOptions.Synchronized)]
    public Wrappers_Compile._IResult<_System._ITuple0, software.amazon.cryptography.materialproviders.internaldafny.types._IError> PutCacheEntry_k(software.amazon.cryptography.materialproviders.internaldafny.types._IPutCacheEntryInput input)
    {
      return wrapped.PutCacheEntry_k(input);
    }
    [System.Runtime.CompilerServices.MethodImpl(System.Runtime.CompilerServices.MethodImplOptions.Synchronized)]
    public Wrappers_Compile._IResult<_System._ITuple0, software.amazon.cryptography.materialproviders.internaldafny.types._IError> DeleteCacheEntry_k(software.amazon.cryptography.materialproviders.internaldafny.types._IDeleteCacheEntryInput input)
    {
      return wrapped.DeleteCacheEntry_k(input);
    }
    [System.Runtime.CompilerServices.MethodImpl(System.Runtime.CompilerServices.MethodImplOptions.Synchronized)]
    public Wrappers_Compile._IResult<_System._ITuple0, software.amazon.cryptography.materialproviders.internaldafny.types._IError> UpdaterUsageMetadata_k(software.amazon.cryptography.materialproviders.internaldafny.types._IUpdaterUsageMetadataInput input)
    {
      return UpdaterUsageMetadata_k(input);
    }
  }
}
