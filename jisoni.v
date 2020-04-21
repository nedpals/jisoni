module jisoni

fn (obj Object) get(key string) Field {
    for k, f in obj.fields {
        if k != key { continue }
        return f
    }
}

fn (arr Array) get(key string) Field {
    idx := key.int()
    return arr.values[idx]
}

fn (f Field) get(key string) Field {
    undef := Undefined{ key: key }

    match f {
        String {            
            str := f as String
            if str.key == key { return str }
        }
        Int {
            num := f as Int
            if num.key == key { return num }
        }
        Bool {
            bol := f as Bool
            if bol.key == key { return bol }
        }
        Null {
            nul := f as Null
            if nul.key == key { return nul }
        }
        String {
            str := f as String
            if str.key == key { return str }
        }
        Object {
            obj := f as Object
            return obj.get(key)
        }
        Array {
            arr := f as Array
            return arr.get(key)
        }
        else {
            return undef
        }
    }

    return undef
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
        String {
            str := f as String
            return str.key
        }
        Object {
            obj := f as Object
            return obj.key
        }
        Array {
            arr := f as Array
            return arr.key
        }
        else {
            return 'undefined'
        }
    }
}

fn (xs []ArrayValue) get(key string) Field {
    for x in xs {
        match x {
            Array {
                arr := x as Array
                return arr.get(key)
            }
            Object {
                obj := x as Object
                return obj.get(key)
            }
            else {
                return xs[key.int()]
            }
        }
    }
}