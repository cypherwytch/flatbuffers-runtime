import endian
import offset


type Vtable* = object
    Bytes*: seq[byte]
    Pos*: uoffset


using this: Vtable


func GetVal*[T](b: ptr seq[byte]): T {.inline.} =
    when T is float64:
        result = cast[T](GetVal[uint64](b))
    elif T is float32:
        result = cast[T](GetVal[uint32](b))
    elif T is string:
        result = cast[T](b[])
    else:
        if b[].len < T.sizeof:
            b[].setLen T.sizeof
        result = cast[ptr T](unsafeAddr b[][0])[]


template Get*[T](this; off: uoffset): T =
    var seq = this.Bytes[off..^1]
    GetVal[T](addr seq)

template Get*[T](this; off: soffset): T =
    var seq = this.Bytes[off..^1]
    GetVal[T](addr seq)

template Get*[T](this; off: voffset): T =
    var seq = this.Bytes[off..^1]
    GetVal[T](addr seq)

func WriteVal*[T: not SomeFloat](b: var openArray[byte]; off: uoffset;
        n: T) {.inline.} =
    when sizeof(T) == 8:
        littleEndianX(addr b[off], unsafeAddr n, T.sizeof)
    elif sizeof(T) == 4:
        littleEndianX(addr b[off], unsafeAddr n, T.sizeof)
    elif sizeof(T) == 2:
        littleEndianX(addr b[off], unsafeAddr n, T.sizeof)
    elif sizeof(T) == 1:
        b[off] = n.uint8
    else:
        discard
        #littleEndianX(addr b[off], unsafeAddr n, T.sizeof)
        #{.error:"shouldnt appear".}

func WriteVal*[T: not SomeFloat](b: var seq[byte]; off: uoffset;
        n: T) {.inline.} =
    when sizeof(T) == 8:
        littleEndianX(addr b[off.uint32], unsafeAddr n, T.sizeof)
    elif sizeof(T) == 4:
        littleEndianX(addr b[off.uint32], unsafeAddr n, T.sizeof)
    elif sizeof(T) == 2:
        littleEndianX(addr b[off.uint32], unsafeAddr n, T.sizeof)
    elif sizeof(T) == 1:
        b[off.uint32] = n.uint8
    else:
        discard
        #littleEndianX(addr b[off], unsafeAddr n, T.sizeof)
        #{.error:"shouldnt appear".}

func WriteVal*[T: SomeFloat](b: var openArray[byte]; off: uoffset;
        n: T) {.inline.} =
    when T is float64:
        WriteVal(b, off, cast[uint64](n))
    elif T is float32:
        WriteVal(b, off, cast[uint32](n))

func WriteVal*[T: SomeFloat](b: var seq[byte]; off: uoffset; n: T) {.inline.} =
    when T is float64:
        WriteVal(b, off, cast[uint64](n))
    elif T is float32:
        WriteVal(b, off, cast[uint32](n))

func Offset*(this; off: voffset): voffset =
    let vtable = (this.Pos - this.Get[:uoffset](this.Pos)).voffset
    let vtableEnd = this.Get[:voffset](vtable)
    if off < vtableEnd:
        return this.Get[:voffset](vtable + off)
    return 0.voffset

template Offset*(this; off: int): voffset =
    this.Offset(off.voffset)

func Indirect*(this; off: uoffset): uoffset =
    result = off + this.Get[:uoffset](off)

template Indirect*(this; off: int): uoffset =
    this.Indirect(off.uoffset)

func VectorLen*(this; off: uoffset): int =
    var newoff: uoffset = off + this.Pos
    newoff += this.Get[:uoffset](newoff)
    return this.Get[:uoffset](newoff).int

template VectorLen*(this; off: int): int =
    this.VectorLen(off.uoffset)

template VectorLen*(this; off: voffset): int =
    this.VectorLen(off.uoffset)

func Vector*(this; off: uoffset): uoffset =
    let newoff: uoffset = off + this.Pos
    var x: uoffset = newoff + this.Get[:uoffset](newoff)
    x += (uoffset.sizeof).uoffset
    result = x

template Vector*(this; off: int): uoffset =
    this.Vector(off.uoffset)

template Vector*(this; off: voffset): uoffset =
    this.Vector(off.uoffset)

func Union*(this; off: uoffset): Vtable =
    let newoff: uoffset = off + this.Pos
    result.Pos = newoff + this.Get[:uoffset](newoff)
    result.Bytes = this.Bytes

template Union*(this; off: int): Vtable =
    this.Union(off.uoffset)

template Union*(this; off: voffset): Vtable =
    this.Union(off.uoffset)

func GetSlot*[T](this; slot: voffset; d: T): T =
    let off = this.Offset(slot)
    if off == 0:
        return d
    return this.Get[T](this.Pos + off)

template GetSlot*[T](this; slot: int; d: T): T =
    this.GetSlot(slot.voffset, d)

func GetOffsetSlot*[T: Offsets](this; slot: voffset; d: T): T =
    let off = this.Offset(slot)
    if off == 0:
        return d
    return off

template GetOffsetSlot*[T: Offsets](this; slot: int; d: T): T =
    this.GetOffsetSlot(slot.voffset, d)

func ByteVector*(this; off: uoffset): seq[byte] =
    let
        newoff: uoffset = off + this.Get[:uoffset](off)
        start = newoff + (uoffset.sizeof).uoffset
    var newseq = this.Bytes[newoff..^1]
    let
        length = GetVal[uoffset](addr newseq)
    result = this.Bytes[start..<start+length]

func String*(this; off: uoffset): string =
    var byte_seq = this.ByteVector(off)
    result = GetVal[string](addr byte_seq)

using this: var Vtable

proc Mutate*[T](this; off: uoffset; n: T): bool =
    WriteVal(this.Bytes, off, n)
    return true

func MutateSlot*[T](this; slot: voffset; n: T): bool =
    let off: voffset = this.Offset(slot)
    if off != 0:
        return this.Mutate(this.Pos + off.uoffset, n)
    return false

template MutateSlot*[T](this; slot: int; n: T): bool =
    this.MutateSlot(slot.voffset, n)