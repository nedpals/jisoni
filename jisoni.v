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
                return get(kv, key)
            }
        }
        Array {
            arr := f as Array
            if key[0].is_digit() {
                idx := key.int()

                if idx >= 0 && idx < arr.value.len {
                    return arr.value[idx]
                }
            } else {
                return arr.value.get(key)
            }
        }
        else {
            return undef
        }
    }

    return undef
}

fn (xs []ArrayValue) get(key string) Field {
    // mut curr_arr_id := 0
    // mut curr_obj_id := 0
    // mut curr_null_id := 0

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