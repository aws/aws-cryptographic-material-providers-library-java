// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

// array of Auto-initializable type that auto-sizes
module {:options "-functionSyntax:4"} ZVector {
  
  class ZVector<T(0)> {
    var data : array<T>
    var currSize : nat

    constructor(startSize : nat := 0)
      ensures Invariant()
      ensures fresh(data)
      ensures currSize == 0
      ensures data.Length == startSize
    {
      this.data := new T[startSize];
      this.currSize := 0;
    }

    predicate Invariant()
      reads this
    {
      currSize <= data.Length
    }

    predicate IsEmpty()
      reads this
    {
      currSize == 0
    }

    // return length of data
    function Length() : nat
      reads this
    {
      currSize
    }

    // return length of allocation
    function CurrAlloc() : nat
      reads this
    {
      data.Length
    }

    // remove all data
    method Clear()
      modifies this
    {
      currSize := 0;
    }

    // return all data as sequence
    function AsSeq() : seq<T>
      reads this, this.data
      requires Invariant()
    {
      data[..currSize]
    }

    // return sub-sequence
    function SubSeq(start : nat, end : nat) : seq<T>
      reads this, this.data
      requires Invariant()
      requires start <= currSize
      requires end <= currSize
      requires start <= end
    {
      data[start..end]
    }

    // how much unused space
    function FreeSpace() : nat
      reads this
      requires Invariant()
    {
      data.Length - currSize
    }

    // reallocate so that size of allocation matches data used
    method Trim()
      requires Invariant()
      ensures Invariant()
      ensures data[..] == old(data[0..currSize])
      ensures fresh(data)
      ensures data.Length == currSize
      modifies this`data
    {
      Realloc(currSize);
    }

    // reallocate to given size
    method Realloc(newLength : nat)
      requires Invariant()
      ensures Invariant()
      requires newLength >= currSize
      ensures data[0..currSize] == old(data[0..currSize])
      ensures fresh(data)
      ensures data.Length == newLength
      modifies this`data
    {
      var newData := new T[newLength];
      for i := 0 to currSize
        invariant currSize <= data.Length
        invariant newData[..i] == data[..i]
        invariant data == old(data)
      {
        newData[i] := data[i];
      }
      data := newData;
    }

    // reallocate, if necessary, to ensure this amount of free space
    method EnsureFreeSpace(size : nat)
      requires Invariant()
      ensures Invariant()
      ensures FreeSpace() >= size
      ensures data[0..currSize] == old(data[0..currSize])
      ensures AsSeq()[0..currSize] == old(AsSeq()[0..currSize])
      ensures (data == old(data)) || fresh(data)
      ensures data.Length >= currSize + size
      modifies this`data
    {
      if FreeSpace() >= size {
        return;
      }
      var newLength := if data.Length > 0 then data.Length else 1;
      while (newLength - currSize) < size
        decreases size - (newLength - currSize)
      {
        newLength := newLength * 2;
      }
      Realloc(newLength);
    }

    // truncate, or add zeros
    method ResizeBy(num : int)
      requires Invariant()
      ensures Invariant()
      requires num > -(currSize as int)
      modifies this, this.data
      ensures currSize == old(currSize) + num
      ensures num >= 0 ==> data[..old(currSize)] == old(data[..currSize])
      ensures num < 0 ==> AsSeq() == old(AsSeq()[..currSize + num])
      ensures (data == old(data)) || fresh(data)
    {
      if num > 0 {
        EnsureFreeSpace(num);
      }
      currSize := currSize + num;
    }

    // truncate, or add zeros
    method ResizeTo(newSize : nat)
      requires Invariant()
      ensures Invariant()
      modifies this, this.data
      ensures currSize == newSize
      ensures newSize >= old(currSize) ==> data[..old(currSize)] == old(data[..currSize])
      ensures newSize < old(currSize) ==> data[..currSize] == old(data[..newSize])
      ensures newSize >= old(currSize) ==> AsSeq()[..old(currSize)] == old(AsSeq()[..currSize])
      ensures newSize < old(currSize) ==> AsSeq()[..currSize] == old(AsSeq()[..newSize])
      ensures (data == old(data)) || fresh(data)
    {
      if newSize > currSize {
        EnsureFreeSpace(newSize - currSize);
      }
      currSize := newSize;
    }

    // Append sequence to data
    method AppendSeq(newData : seq<T>)
      requires Invariant()
      ensures Invariant()
      modifies this, this.data
      ensures currSize == old(currSize) + |newData|
      ensures data[..currSize] == old(data[..currSize]) + newData
      ensures data[old(currSize)..currSize] == newData
      ensures AsSeq()[..currSize] == old(AsSeq()[..currSize]) + newData
      ensures AsSeq()[old(currSize)..currSize] == newData
      ensures (data == old(data)) || fresh(data)
    {
      EnsureFreeSpace(|newData|);
      ghost var oldData := data;
      for i := 0 to |newData|
        invariant currSize+|newData| <= data.Length
        invariant data[..currSize] == old(data[..currSize])
        invariant data[currSize..currSize+i] == newData[..i]
        invariant data[..currSize+i] == old(data[..currSize]) + newData[..i]
        invariant Invariant()
        invariant data == oldData
      {
        data[currSize + i] := newData[i];
      }
      currSize := currSize + |newData|;
    }

    // Append item to data
    method AppendItem(newData : T)
      requires Invariant()
      ensures Invariant()
      modifies this, this.data
      ensures currSize == old(currSize) + 1
      ensures data[..currSize] == old(data[..currSize]) + [newData]
      ensures (data == old(data)) || fresh(data)
    {
      EnsureFreeSpace(1);
      data[currSize] := newData;
      currSize := currSize + 1;
    }

    lemma SeqIsDataPos(start : nat, end : nat)
      requires Invariant()
      requires start <= currSize
      requires end <= currSize
      requires start <= end
      ensures data[start..end] == AsSeq()[start..end]
    {}
    lemma SeqIsData()
      requires Invariant()
      ensures data[..Length()] == AsSeq()
    {}

    // Replace data[pos..pos+|newData|] with newData
    method AssignSeq(newData : seq<T>, pos : nat)
      requires Invariant()
      ensures Invariant()
      modifies this.data
      requires pos <= currSize - |newData|
      ensures data[..pos] == old(data[..pos])
      ensures data[pos..pos+|newData|] == newData
      ensures data[pos+|newData|..] == old(data[pos+|newData|..])
      ensures AsSeq()[..pos] == old(AsSeq()[..pos])
      ensures AsSeq()[pos..pos+|newData|] == newData
      ensures AsSeq()[pos+|newData|..] == old(AsSeq()[pos+|newData|..])
    {
      SeqIsDataPos(0, pos);
      for i := 0 to |newData|
        invariant data[0..pos] == old(data[0..pos])
        invariant data[pos..pos+i] == newData[..i]
        invariant data[pos+|newData|..] == old(data[pos+|newData|..])
      {
        data[pos + i] := newData[i];
      }
    }

    // Replace data[pos] with newData
    method AssignItem(nameonly item : T, nameonly pos : nat)
      requires Invariant()
      ensures Invariant()
      modifies this.data
      requires pos < currSize
      ensures data[0..pos] == old(data[0..pos])
      ensures data[pos] == item
      ensures data[pos+1..] == old(data[pos+1..])
      ensures AsSeq()[..pos] == old(AsSeq()[..pos])
      ensures AsSeq()[pos] == item
      ensures AsSeq()[pos+1..] == old(AsSeq()[pos+1..])
      ensures AsSeq() == old(AsSeq()[..pos]) + [item] + old(AsSeq()[pos+1..])
    {
      data[pos] := item;
    }

    // delete range
    method DeleteRange(start : nat, end : nat)
      requires Invariant()
      ensures Invariant()
      modifies this`currSize, this.data
      requires start <= end
      requires start <= currSize
      requires end <= currSize
      ensures currSize == old(currSize) - (end - start)
      ensures data[0..start] == old(data[0..start])
      ensures data[start..currSize] == old(data[end..currSize])
      ensures data[start + old(currSize) - end..] == old(data[start + currSize - end..])
      ensures AsSeq()[0..start] == old(AsSeq()[0..start])
      ensures AsSeq()[start..currSize] == old(AsSeq()[end..currSize])
      ensures AsSeq()[start + old(currSize) - end..currSize] == old(AsSeq()[start + currSize - end..currSize - (end - start)])
    {
      for i := 0 to currSize - end
        invariant currSize == old(currSize)
        invariant data[0..start] == old(data[0..start])
        invariant data[start+i..currSize] == old(data[start+i..currSize])
        invariant data[start..start+i] == old(data[end..end+i])
        invariant data[start + currSize - end..] == old(data[start + currSize - end..])
      {
        assert end+i >= start+i;
        assert data[end+i] == old(data[end+i]);
        data[start+i] := data[end+i];
        assert data[start+i] == old(data[end+i]);
      }
      currSize := currSize - (end - start);
      SeqIsDataPos(start + old(currSize) - end, currSize);
    }

    // delete item
    method DeleteItem(pos : nat)
      requires Invariant()
      ensures Invariant()
      modifies this`currSize, this.data
      requires pos < currSize
      ensures currSize == old(currSize) - 1
      ensures data[0..pos] == old(data[0..pos])
      ensures data[pos..currSize] == old(data[pos+1..currSize])
      ensures AsSeq()[0..pos] == old(AsSeq()[0..pos])
      ensures AsSeq()[pos..currSize] == old(AsSeq()[pos+1..currSize])
      ensures AsSeq() == old(AsSeq()[0..pos]) + old(AsSeq()[pos+1..currSize])
    {
      DeleteRange(pos, pos+1);
    }

    // insert sequence before pos
    method InsertSeq(newData : seq<T>, pos : nat)
      requires Invariant()
      ensures Invariant()
      modifies this, this.data
      requires pos <= currSize
      ensures currSize == old(currSize) + |newData|
      ensures data[0..pos] == old(data[0..pos])
      ensures data[pos..pos+|newData|] == newData
      ensures data[pos+|newData|..currSize] == old(data[pos..currSize])
      ensures AsSeq()[0..pos] == old(AsSeq()[0..pos])
      ensures AsSeq()[pos..pos+|newData|] == newData
      ensures AsSeq()[pos+|newData|..currSize] == old(AsSeq()[pos..currSize])
      ensures (data == old(data)) || fresh(data)
    {
      SeqIsDataPos(0, pos);
      if |newData| == 0 {
        return;
      }
      if pos == currSize {
        AppendSeq(newData);
        return;
      }
      EnsureFreeSpace(|newData|);
      assert data.Length >= currSize + |newData|;
      ghost var oldData := data;
      var newSize := currSize + |newData|;
      assert newSize <= data.Length;

      // slide old data to the right
      // must iterate right to left in case of overlap
      for i := currSize downto pos
        invariant i <= currSize
        invariant currSize <= old(data).Length
        invariant data == oldData
        invariant data.Length >= currSize + |newData|
        invariant i - 1 + |newData| >= pos
        invariant data[0..pos] == old(data[0..pos])
        invariant data[pos..i] == old(data[pos..i])
        invariant i < currSize ==> (data[i] == old(data[i]))
        invariant data[i + |newData|..newSize] == old(data[i..currSize])
      {
        assert pos < i+1;
        assert data[i+1 + |newData|..newSize] == old(data[i+1..currSize]);
        assert forall x | pos <= x < i+1 :: data[x] == old(data[x]);
        assert data[i] == old(data[i]);
        data[i + |newData|] := data[i];
        assert forall x | pos <= x < i+1 :: data[x] == old(data[x]);
        assert data[i+1 + |newData|..newSize] == old(data[i+1..currSize]);
        assert data[i + |newData|] == old(data[i]);
        assert data[i + |newData|..newSize] == old(data[i..currSize]);
      }
      assert data[0..pos] == old(data[0..pos]);
      assert data[pos+|newData|..newSize] == old(data[pos..currSize]);

      // assign new data
      assert data.Length >= pos + |newData|;
      var newDataLen := |newData|;
      for i := 0 to newDataLen
        invariant data.Length >= pos+i
        invariant data[0..pos] == old(data[0..pos])
        invariant data[pos..pos+i] == newData[..i]
        invariant data == oldData
        invariant data[pos+newDataLen..newSize] == old(data[pos..currSize])
      {
        data[pos + i] := newData[i];
      }
      assert data[pos..pos+newDataLen] == newData;

      currSize := newSize;
      SeqIsDataPos(pos, pos+|newData|);
      SeqIsDataPos(pos+|newData|, currSize);
    }

    // insert item before pos
    method InsertItem(nameonly item : T, nameonly pos : nat)
      requires Invariant()
      ensures Invariant()
      modifies this, this.data
      requires pos < currSize
      ensures currSize == old(currSize) + 1
      ensures data[0..pos] == old(data[0..pos])
      ensures data[pos] == item
      ensures data[pos+1..currSize] == old(data[pos..currSize])
      ensures AsSeq()[0..pos] == old(AsSeq()[0..pos])
      ensures AsSeq()[pos] == item
      ensures AsSeq()[pos+1..currSize] == old(AsSeq()[pos..currSize])
      ensures (data == old(data)) || fresh(data)
    {
      InsertSeq([item], pos);
    }
  }
}
