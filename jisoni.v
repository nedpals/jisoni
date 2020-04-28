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
        else { return Undefined{ key: key } }
    }
}

fn (av ArrayValue) get(key string) Field {
    match av {
        Object { return it.get(key) }
        Array { return it.get(key.int()) }
        else { return Undefined{ key: key } }
    }
}

fn (f Field) key() string {
    match f {
        String {            
            str := f as String
            return str.key
        }
        Int {
            num := f as Int
            return num.key
        }
        Bool {
            bol := f as Bool
            return bol.key
        }
        Null {
            nul := f as Null
            return nul.key
        }
        Object {
            obj := f as Object
            return obj.key
        }
        Array {
            arr := f as Array
            return arr.key
        }
        else { return 'undefined' }
    }
}