module main

fn get(f Field, key string) Field {
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

            for kv in obj.value {
                k := get_key(kv)
                if (k != key) { continue }
                return kv
            }
        }
        Array {
            arr := f as Array
            if key[0].is_digit() {
                idx := key.int()

                if idx < 0 && idx >= arr.value.len { return undef }
                return arr.value[idx]
            }

            return arr.value.get(key)
        }
        else {
            return undef
        }
    }

    return undef
}

fn get_key(f Field) string {
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
                return get(arr, key)
            }
            Object {
                obj := x as Object
                return get(obj, key)
            }
            else {
                return Undefined{key: key}
            }
        }
    }

    return Undefined{key: key}
}