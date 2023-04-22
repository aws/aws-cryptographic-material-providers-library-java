// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
// Do not modify this file. This file is machine generated, and any changes to it will be overwritten.
using System;
 using AWS.Cryptography.MaterialProviders.Wrapped.Keys; namespace AWS.Cryptography.MaterialProviders.Wrapped.Keys {
 public class KeyDescription {
 private AWS.Cryptography.MaterialProviders.Wrapped.Keys.KMSInfo _kms ;
 private AWS.Cryptography.MaterialProviders.Wrapped.Keys.KmsMrkAware _kmsMrk ;
 private AWS.Cryptography.MaterialProviders.Wrapped.Keys.KmsMrkAwareDiscovery _kmsMrkDiscovery ;
 private AWS.Cryptography.MaterialProviders.Wrapped.Keys.RawRSA _rSA ;
 private AWS.Cryptography.MaterialProviders.Wrapped.Keys.RawAES _aES ;
 private AWS.Cryptography.MaterialProviders.Wrapped.Keys.InvalidKeyring _invalid ;
 public AWS.Cryptography.MaterialProviders.Wrapped.Keys.KMSInfo Kms {
 get { return this._kms; }
 set { this._kms = value; }
}
 public bool IsSetKms () {
 return this._kms != null;
}
 public AWS.Cryptography.MaterialProviders.Wrapped.Keys.KmsMrkAware KmsMrk {
 get { return this._kmsMrk; }
 set { this._kmsMrk = value; }
}
 public bool IsSetKmsMrk () {
 return this._kmsMrk != null;
}
 public AWS.Cryptography.MaterialProviders.Wrapped.Keys.KmsMrkAwareDiscovery KmsMrkDiscovery {
 get { return this._kmsMrkDiscovery; }
 set { this._kmsMrkDiscovery = value; }
}
 public bool IsSetKmsMrkDiscovery () {
 return this._kmsMrkDiscovery != null;
}
 public AWS.Cryptography.MaterialProviders.Wrapped.Keys.RawRSA RSA {
 get { return this._rSA; }
 set { this._rSA = value; }
}
 public bool IsSetRSA () {
 return this._rSA != null;
}
 public AWS.Cryptography.MaterialProviders.Wrapped.Keys.RawAES AES {
 get { return this._aES; }
 set { this._aES = value; }
}
 public bool IsSetAES () {
 return this._aES != null;
}
 public AWS.Cryptography.MaterialProviders.Wrapped.Keys.InvalidKeyring Invalid {
 get { return this._invalid; }
 set { this._invalid = value; }
}
 public bool IsSetInvalid () {
 return this._invalid != null;
}
 public void Validate() {
 var numberOfPropertiesSet = Convert.ToUInt16(IsSetKms()) +
 Convert.ToUInt16(IsSetKmsMrk()) +
 Convert.ToUInt16(IsSetKmsMrkDiscovery()) +
 Convert.ToUInt16(IsSetRSA()) +
 Convert.ToUInt16(IsSetAES()) +
 Convert.ToUInt16(IsSetInvalid()) ;
 if (numberOfPropertiesSet == 0) throw new System.ArgumentException("No union value set");

 if (numberOfPropertiesSet > 1) throw new System.ArgumentException("Multiple union values set");

}
}
}
