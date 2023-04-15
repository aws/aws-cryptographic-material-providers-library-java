// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

include "../Model/AwsCryptographyMaterialProvidersTypesWrapped.dfy"

module {:options "-functionSyntax:4"} JSONHelpers {
  import JSON.API
  import JSON.Utils.Unicode
  import BoundedInts
  import opened JSON.AST
  import opened Wrappers

  function BvToBytes(bits: seq<bv8>): seq<BoundedInts.uint8>
  {
    seq(|bits|, i requires 0 <= i < |bits| => bits[i] as BoundedInts.byte)
  }

  function Get(key: string, obj: seq<(string, JSON)>)
    : Result<AST.JSON, string>
  {
    if |obj| == 0 then
      Failure("Key: " + key + " does not exist")
    else if obj[0].0 == key then
      Success(obj[0].1)
    else
      Get(key, obj[1..])
  }

  function GetString(key: string, obj: seq<(string, JSON)>)
    : Result<string, string>
  {
    var obj :- Get(key, obj);
    :- Need(obj.String?, "Not a string");
    Success(obj.str)
  }

  function GetBool(key: string, obj: seq<(string, JSON)>)
    : Result<bool, string>
  {
    var obj :- Get(key, obj);
    :- Need(obj.Bool?, "Not a bool");
    Success(obj.b)
  }

  function GetNat(key: string, obj: seq<(string, JSON)>)
    : Result<nat, string>
  {
    var obj :- Get(key, obj);
    :- Need(obj.Number?, "Not a number");
    :- Need(0 < obj.num.n, "Not a nat");
    // This may not be adequate 
    Success(obj.num.n)
  }

  function GetOptionalString(key: string, obj: seq<(string, JSON)>)
    : Result<Option<string>, string>
  {
    var obj := Get(key, obj).ToOption();
    if obj.Some? then
      :- Need(obj.value.String?, "Not a string");
      Success(Some(obj.value.str))
    else
      Success(None)
  }

  function GetObject(key: string, obj: seq<(string, JSON)>)
    : Result<seq<(string, JSON)>, string>
  {
    var obj :- Get(key, obj);
    :- Need(obj.Object?, "Not an object");
    Success(obj.obj)
  }

  function GetArray(key: string, obj: seq<(string, JSON)>)
    : Result<seq<JSON>, string>
  {
    var obj :- Get(key, obj);
    :- Need(obj.Array?, "Not an array");
    Success(obj.arr)
  }

  function GetArrayString(key: string, obj: seq<(string, JSON)>)
    : Result<seq<string>, string>
  {
    var obj :- Get(key, obj);
    :- Need(obj.Array? && forall s <- obj.arr :: s.String?, "Not an array of strings");
    var arr := obj.arr;
    Success(seq(|arr|, n requires 0 <= n < |arr| => arr[n].str))
  }

  function GetArrayObject(key: string, obj: seq<(string, JSON)>)
    : Result<seq<seq<(string, JSON)>>, string>
  {
    var obj :- Get(key, obj);
    :- Need(obj.Array? && forall s <- obj.arr :: s.Object?, "Not an array of objects");
    var arr := obj.arr;
    Success(seq(|arr|, n requires 0 <= n < |arr| => arr[n].obj))
  }

  function SmallObjectToStringStringMap(key: string, obj: seq<(string, JSON)>)
    : Result<map<string, string>, string>
  {
    var item :- Get(key, obj);
    :- Need(item.Object?, "Not an object");
    var obj := item.obj;
    :- Need(forall t <- obj :: t.1.String?, "Not a string string object");
    // This is an expensive check for large objects.
    :- Need(forall i,j | 0 <= i < j < |obj| :: obj[i].0 != obj[j].0,
      "JSON serialization Error");
    Success(map t <- obj :: t.0 := t.1.str)
  }
}