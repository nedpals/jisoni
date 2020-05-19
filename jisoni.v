module main

fn (obj Object) get(key string) Field {
    return obj.fields[key]
}

fn (arr Array) get(key int) Field {
    return arr.values[key]
}

fn (xs []ArrayValue) get(key int) ArrayValue {
    return xs[key]
}

fn (f Field) get(key string) Field {
    match f {
        Object { return it.get(key) }
        Array { return it.get(key.int()) }
        ArrayValue { return it.get(key) }
        else { return Undefined{key} }
    }
}

fn (av ArrayValue) get(key string) Field {
    match av {
        Object { return it.get(key) }
        Array { return it.get(key.int()) }
        else { return Undefined{key} }
    }
}

fn (f Field) key() string {
    match f {
        String { return it.key }
        Int { return it.key }
        Bool { return it.key }
        Null { return it.key }
        Object { return it.key }
        Array { return it.key }
        Float { return it.key }
        else { return 'undefined' }
    }
}