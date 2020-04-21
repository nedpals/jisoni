module jisoni

import strings

pub fn encode(f Field) string {
    mut g := strings.new_builder(2000)

    match f {
        Object {
            obj := f as Object
            if !obj.key.starts_with('Object_') && obj.key.len > 2 {
                g.write('"${obj.key}":')
            }
            g.write(f.str())
        }
        Array {
            arr := f as Array
            if !arr.key.starts_with('Array_') && arr.key.len > 2 {
                g.write('"${arr.key}":')
            }
            g.write(f.str())
        }
        else {
            g.write(f.json_str())
        }
    }

    return g.str()
}