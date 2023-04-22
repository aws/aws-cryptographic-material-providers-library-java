// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
// Do not modify this file. This file is machine generated, and any changes to it will be overwritten.
using System;
 using AWS.Cryptography.MaterialProviders.Wrapped.Keys; namespace AWS.Cryptography.MaterialProviders.Wrapped.Keys {
 public class SerializeKeyDescriptionInput {
 private AWS.Cryptography.MaterialProviders.Wrapped.Keys.KeyDescription _keyDescription ;
 public AWS.Cryptography.MaterialProviders.Wrapped.Keys.KeyDescription KeyDescription {
 get { return this._keyDescription; }
 set { this._keyDescription = value; }
}
 public bool IsSetKeyDescription () {
 return this._keyDescription != null;
}
 public void Validate() {
 if (!IsSetKeyDescription()) throw new System.ArgumentException("Missing value for required property 'KeyDescription'");

}
}
}
