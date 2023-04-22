// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
// Do not modify this file. This file is machine generated, and any changes to it will be overwritten.
using System;
 using System.IO;
 using System.Collections.Generic;
 using AWS.Cryptography.MaterialProviders.Wrapped.Keys;
 using Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types; namespace AWS.Cryptography.MaterialProviders.Wrapped.Keys {
 public class KeyVectors {
 private readonly Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types.IKeyVectorsClient _impl;
 public KeyVectors(AWS.Cryptography.MaterialProviders.Wrapped.Keys.KeyVectorsConfig input)
 {
 Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types._IKeyVectorsConfig internalInput = TypeConversion.ToDafny_N3_aws__N12_cryptography__N17_materialProviders__N7_wrapped__N4_keys__S16_KeyVectorsConfig(input);
 var result = Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.__default.KeyVectors(internalInput);
 if (result.is_Failure) throw TypeConversion.FromDafny_CommonError(result.dtor_error);
 this._impl = result.dtor_value;
}
 public AWS.Cryptography.MaterialProviders.IKeyring CreateTestVectorKeyring(AWS.Cryptography.MaterialProviders.Wrapped.Keys.TestVectorKeyringInput input) {
 Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types._ITestVectorKeyringInput internalInput = TypeConversion.ToDafny_N3_aws__N12_cryptography__N17_materialProviders__N7_wrapped__N4_keys__S22_TestVectorKeyringInput(input);
 Wrappers_Compile._IResult<Dafny.Aws.Cryptography.MaterialProviders.Types.IKeyring, Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types._IError> result = _impl.CreateTestVectorKeyring(internalInput);
 if (result.is_Failure) throw TypeConversion.FromDafny_CommonError(result.dtor_error);
 return TypeConversion.FromDafny_N3_aws__N12_cryptography__N17_materialProviders__S19_CreateKeyringOutput(result.dtor_value);
}
 public AWS.Cryptography.MaterialProviders.IKeyring CreateWappedTestVectorKeyring(AWS.Cryptography.MaterialProviders.Wrapped.Keys.TestVectorKeyringInput input) {
 Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types._ITestVectorKeyringInput internalInput = TypeConversion.ToDafny_N3_aws__N12_cryptography__N17_materialProviders__N7_wrapped__N4_keys__S22_TestVectorKeyringInput(input);
 Wrappers_Compile._IResult<Dafny.Aws.Cryptography.MaterialProviders.Types.IKeyring, Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types._IError> result = _impl.CreateWappedTestVectorKeyring(internalInput);
 if (result.is_Failure) throw TypeConversion.FromDafny_CommonError(result.dtor_error);
 return TypeConversion.FromDafny_N3_aws__N12_cryptography__N17_materialProviders__S19_CreateKeyringOutput(result.dtor_value);
}
 public AWS.Cryptography.MaterialProviders.Wrapped.Keys.GetKeyDescriptionOutput GetKeyDescription(AWS.Cryptography.MaterialProviders.Wrapped.Keys.GetKeyDescriptionInput input) {
 Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types._IGetKeyDescriptionInput internalInput = TypeConversion.ToDafny_N3_aws__N12_cryptography__N17_materialProviders__N7_wrapped__N4_keys__S22_GetKeyDescriptionInput(input);
 Wrappers_Compile._IResult<Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types._IGetKeyDescriptionOutput, Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types._IError> result = _impl.GetKeyDescription(internalInput);
 if (result.is_Failure) throw TypeConversion.FromDafny_CommonError(result.dtor_error);
 return TypeConversion.FromDafny_N3_aws__N12_cryptography__N17_materialProviders__N7_wrapped__N4_keys__S23_GetKeyDescriptionOutput(result.dtor_value);
}
 public AWS.Cryptography.MaterialProviders.Wrapped.Keys.SerializeKeyDescriptionOutput SerializeKeyDescription(AWS.Cryptography.MaterialProviders.Wrapped.Keys.SerializeKeyDescriptionInput input) {
 Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types._ISerializeKeyDescriptionInput internalInput = TypeConversion.ToDafny_N3_aws__N12_cryptography__N17_materialProviders__N7_wrapped__N4_keys__S28_SerializeKeyDescriptionInput(input);
 Wrappers_Compile._IResult<Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types._ISerializeKeyDescriptionOutput, Dafny.Aws.Cryptography.MaterialProviders.Wrapped.Keys.Types._IError> result = _impl.SerializeKeyDescription(internalInput);
 if (result.is_Failure) throw TypeConversion.FromDafny_CommonError(result.dtor_error);
 return TypeConversion.FromDafny_N3_aws__N12_cryptography__N17_materialProviders__N7_wrapped__N4_keys__S29_SerializeKeyDescriptionOutput(result.dtor_value);
}
}
}
