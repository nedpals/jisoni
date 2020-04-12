module main

import strings

pub fn encode(f Field) string {
    mut g := strings.new_builder(2000)

    match f {
        Object {
            obj := f as Object
            if !obj.key.starts_with('Object_') && obj.key.len > 2 {
                g.write('"${obj.key}":')
            }
            g.write('{')
            for i, fl in obj.value {
                g.write(encode(fl))
                if i < obj.value.len-1 {g.write(', ')}
            }
            g.write('}')
        }
        Array {
            arr := f as Array
            if !arr.key.starts_with('Array_') && arr.key.len > 2 {
                g.write('"${arr.key}":')
            }
            g.write('[')
            for i, fl in arr.value {
                g.write(fl.str())
                if i < arr.value.len-1 {g.write(', ')}
            }
            g.write(']')
        }
        String {
            str := f as String
            g.write('"${str.key}":"${str.value}"')
        }
        Int {
            num := f as Int
            g.write('"${num.key}":${num.value.str()}')
        }
        Float {
            num := f as Float
            g.write('"${num.key}":${num.value.str()}')
        }
        Null {
            nul := f as Null
            g.write('"${nul.key}":null')
        }
        Bool {
            bol := f as Bool
            g.write('"${bol.key}":${bol.value.str()}')
        }
        else {}
    }

    return g.str()
}