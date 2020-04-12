module main

import strings

pub fn typ(x Field) string {
    match x {
        String { return 'string' }
        Bool { return 'bool' }
        Object { return 'object' }
        Array { return 'array' }
        Null { return 'null' }
        Undefined { return 'undefined' }
        else { return 'unknown' }
    }
}

pub fn (x Field) str() string {
    match x {
        String {
            txt := x as String
            return '"${txt.key}": "${txt.value}"'
        }
        Bool {
            bol := x as Bool
            return '"${bol.key}": ${bol.value.str()}'
        }
        Object {
            mut g := strings.new_builder(20000)
            obj := x as Object
            g.write('Object {')
            for i, f in obj.value {
                g.write(f.str())
                if i < obj.value.len-1 { g.write(', ') }
            }
            g.write('}')
            return g.str()
        }
        Int {
            num := x as Int
            return '"${num.key}": ${num.value.str()}'
        }
        Array {
            arr := x as Array
            return '"${arr.key}": ${arr.value.str()}'
        }
        Null {
            nul := x as Null
            return '"${nul.key}": null'
        }
        Undefined {
            return 'undefined'
        }
        else {
            return 'Unknown'
        }
    }
}

pub fn (x ArrayValue) str() string {
    match x {
        string {
            txt := x as string
            return '"$txt"'
        }
        int {
            num := x as int
            return num.str()
        }
        f64 {
            num := x as f64
            return num.strlong()
        }
        Object {
            mut g := strings.new_builder(20000)
            obj := x as Object
            g.write('Object {')
            for i, f in obj.value {
                g.write(f.str())
                if i < obj.value.len-1 { g.write(', ') }
            }
            g.write('}')
            return g.str()
        }
        Array {
            arr := x as Array
            return arr.value.str()
        }
        bool {
            bol := x as bool
            return bol.str()
        }
        Null {
            return 'null'
        }
        else {
            return 'null'
        }
    }
}

pub fn (av []ArrayValue) str() string {
    mut final := '['

    for i, x in av {
        final += x.str()
        if i < av.len-1 {
            final += ', '
        }
    }

    final += ']'

    return final
}

pub fn (xs []Field) str() string {
    mut final := '['

    for i, x in xs {
        final += x.str()
        if i < xs.len-1 {
            final += ', '
        }
    }

    final += ']'

    return final
}