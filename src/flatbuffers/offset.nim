# add required operations to the offset types
# code is taken directly from docs:
# https://nim-lang.org/docs/manual.html#distinct-type-modeling-currencies

# type
#     uoffset* = uint32 ## offset in to the buffer
#     soffset* = int32 ## offset from start of table, to a vtable
#     voffset* = uint16 ## offset from start of table to value

# type Offsets* = uoffset | soffset | voffset


template makeAdditive(typ: typedesc) =
    proc `+`*(x, y: typ): typ {.borrow.}
    proc `-`*(x, y: typ): typ {.borrow.}
    proc `+=`*(x: var typ, y: typ) {.borrow.}
    proc `-=`*(x: var typ, y: typ) {.borrow.}
    proc `+`*(x: typ, y: int): typ = x + typ(y)
    proc `+`*(x: int, y: typ): typ = typ(x) + y
    proc `-`*(x: typ, y: int): typ = x - typ(y)
    proc `-`*(x: int, y: typ): typ = typ(x) - y
    proc `+=`*(x: var typ, y: int) = x += typ(y)
    proc `+=`*(x: var int, y: typ) = x += y.int
    proc `-=`*(x: var typ, y: int) = x -= typ(y)
    proc `-=`*(x: var int, y: typ) = x -= y.int
    
    # unary operators:
    # proc `+`*(x: typ): typ {.borrow.}
    # proc `-`*(x: typ): typ {.borrow.}

template makeMultiplicative(typ, base: typedesc) =
    proc `*`*(x: typ, y: base): typ {.borrow.}
    proc `*`*(x: base, y: typ): typ {.borrow.}
    proc `div`*(x: typ, y: base): typ {.borrow.}
    proc `mod`*(x: typ, y: base): typ {.borrow.}
    proc `*`*(x: typ, y: typ): typ = x * y.base

template makeComparable(typ: typedesc) =
    proc `<`*(x, y: typ): bool {.borrow.}
    proc `<=`*(x, y: typ): bool {.borrow.}
    proc `==`*(x, y: typ): bool {.borrow.}
    # proc `!=`*(x, y: typ): bool {.borrow.}
    proc `<`*(x: typ, y: int): bool = x < typ(y)
    proc `<=`*(x: typ, y: int): bool = x <= typ(y)
    proc `==`*(x: typ, y: int): bool = x == typ(y)
    proc `!=`*(x: typ, y: int): bool = x != typ(y)

template defineDistinctInt(typ, base: untyped) =
    type
        typ* = distinct base
    makeAdditive(typ)
    makeMultiplicative(typ, base)
    makeComparable(typ)


defineDistinctInt(uoffset, uint32)
defineDistinctInt(soffset, int32)
defineDistinctInt(voffset, uint16)

proc `+`*(x: uoffset, y: soffset): uoffset = x + uoffset(y)
proc `+`*(x: soffset, y: uoffset): uoffset = uoffset(x) + y
proc `+`*(x: uoffset, y: voffset): uoffset = x + uoffset(y)
proc `+`*(x: voffset, y: uoffset): uoffset = uoffset(x) + y
proc `+`*(x: soffset, y: voffset): soffset = x + soffset(y)
proc `+`*(x: voffset, y: soffset): soffset = soffset(x) + y
proc `-`*(x: uoffset, y: soffset): uoffset = x - uoffset(y)
proc `-`*(x: soffset, y: uoffset): uoffset = uoffset(x) - y
proc `-`*(x: uoffset, y: voffset): uoffset = x - uoffset(y)
proc `-`*(x: voffset, y: uoffset): uoffset = uoffset(x) - y
proc `-`*(x: soffset, y: voffset): soffset = x - soffset(y)
proc `-`*(x: voffset, y: soffset): soffset = soffset(x) - y

type Offsets* = uoffset | soffset | voffset