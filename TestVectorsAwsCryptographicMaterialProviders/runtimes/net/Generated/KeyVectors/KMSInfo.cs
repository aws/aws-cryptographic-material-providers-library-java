// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
// Do not modify this file. This file is machine generated, and any changes to it will be overwritten.
using System;
 using AWS.Cryptography.MaterialProviders.Wrapped.Keys; namespace AWS.Cryptography.MaterialProviders.Wrapped.Keys {
 public class KMSInfo {
 private string _keyId ;
 public string KeyId {
 get { return this._keyId; }
 set { this._keyId = value; }
}
 public bool IsSetKeyId () {
 return this._keyId != null;
}
 public void Validate() {
 if (!IsSetKeyId()) throw new System.ArgumentException("Missing value for required property 'KeyId'");

}
}
}
