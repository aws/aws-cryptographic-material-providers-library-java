// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
// Do not modify this file. This file is machine generated, and any changes to it will be overwritten.
using System;
 using AWS.Cryptography.Primitives; namespace AWS.Cryptography.Primitives {
 public class CryptoConfig {
 private AWS.Cryptography.Primitives.HKDFPolicy _hkdfPolicy ;
 public AWS.Cryptography.Primitives.HKDFPolicy HkdfPolicy {
 get { return this._hkdfPolicy; }
 set { this._hkdfPolicy = value; }
}
 public bool IsSetHkdfPolicy () {
 return this._hkdfPolicy != null;
}
 public void Validate() {
 
}
}
}
