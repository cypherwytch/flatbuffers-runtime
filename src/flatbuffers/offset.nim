# add required operations to the offset types
# code is taken directly from docs:
# https://nim-lang.org/docs/manual.html#distinct-type-modeling-currencies

template makeAdditive(typ: typedesc) =
    proc `+`*(x, y: typ): typ {.borrow.}
    proc `-`*(x, y: typ): typ {.borrow.}
    proc `+=`*(x: var typ, y: typ) {.borrow.}
    proc `-=`*(x: var typ, y: typ) {.borrow.}
    
    # unary operators:
    # proc `+`*(x: typ): typ {.borrow.}
    # proc `-`*(x: typ): typ {.borrow.}

template makeMultiplicative(typ, base: typedesc) =
    proc `*`*(x: typ, y: base): typ {.borrow.}
    proc `*`*(x: base, y: typ): typ {.borrow.}
    proc `div`*(x: typ, y: base): typ {.borrow.}
    proc `mod`*(x: typ, y: base): typ {.borrow.}

template makeComparable(typ: typedesc) =
    proc `<`*(x, y: typ): bool {.borrow.}
    proc `<=`*(x, y: typ): bool {.borrow.}
    proc `==`*(x, y: typ): bool {.borrow.}

template defineDistinctInt(typ, base: untyped) =
    type
        typ* = distinct base
    makeAdditive(typ)
    makeMultiplicative(typ, base)
    makeComparable(typ)


defineDistinctInt(uoffset, uint32)
defineDistinctInt(soffset, int32)
defineDistinctInt(voffset, uint16)

type Offsets* = uoffset | soffset | voffset