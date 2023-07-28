// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
include "../src/ZVector.dfy"

module TestZVector {
  import opened ZVector

  method {:test} TestBasic() {
    var vec := new ZVector<int>();
    assert vec.AsSeq() == [];
    assert vec.IsEmpty();
    vec.AppendSeq([1,2]);
    assert vec.AsSeq() == [1,2];
    vec.AppendItem(3);
    assert vec.AsSeq() == [1,2,3];
    vec.InsertItem(item := 0, pos := 0);
    assert vec.AsSeq() == [0,1,2,3];
    vec.ResizeBy(1);
    vec.AssignItem(item := 4, pos := 4);
    assert vec.AsSeq() == [0,1,2,3,4];
    vec.DeleteItem(1);
    assert vec.AsSeq() == [0,2,3,4];
    vec.AssignItem(item := 1, pos := 1);
    assert vec.AsSeq() == [0,1,3,4];
    vec.DeleteRange(0,4);
    assert vec.IsEmpty();
    assert vec.AsSeq() == [];
  }
  method {:test} TestBasic2() {
    var vec := new ZVector<int>();
    TestBasic2Inner(vec);
  }

  method TestBasic2Inner(vec : ZVector<int>)
    requires vec.Invariant()
    requires vec.Length() == 0
    ensures vec.Invariant()
    modifies vec, vec.data
  {
    assert vec.AsSeq() == [];
    vec.AppendSeq([1,2]);
    assert vec.AsSeq() == [1,2];
    vec.AppendItem(3);
    assert vec.AsSeq() == [1,2,3];
    vec.InsertItem(item := 0, pos := 0);
    assert vec.AsSeq() == [0,1,2,3];
    vec.ResizeBy(1);
    vec.AssignItem(item := 4, pos := 4);
    assert vec.AsSeq() == [0,1,2,3,4];
    vec.DeleteItem(1);
    assert vec.AsSeq() == [0,2,3,4];
    vec.AssignItem(item := 1, pos := 1);
    assert vec.AsSeq() == [0,1,3,4];
  }

  method {:test} TestBasic3() {
    var vec := new ZVector<int>();
    assert vec.AsSeq() == [];
    vec.AppendSeq([1,2]);
    assert vec.AsSeq() == [1,2];
    vec.AppendItem(3);
    assert vec.AsSeq() == [1,2,3];
    vec.InsertSeq(newData := [0], pos := 0);
    assert vec.AsSeq() == [0,1,2,3];
    vec.ResizeBy(1);
    vec.AssignSeq(newData := [4], pos := 4);
    assert vec.AsSeq() == [0,1,2,3,4];
    vec.DeleteRange(1, 2);
    assert vec.AsSeq() == [0,2,3,4];
    vec.AssignSeq(newData := [1], pos := 1);
    assert vec.AsSeq() == [0,1,3,4];
  }

}
