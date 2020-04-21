module jisoni

import strings

pub fn (x Field) str() string {
    match x {
        String {
            txt := x as String
            return txt.value
        }
        Bool {
            bol := x as Bool
            return bol.value.str()
        }
        Object {
            obj := x as Object
            return obj.str()
        }
        Int {
            num := x as Int
            return num.value.str()
        }
        Array {
            arr := x as Array
            return arr.str()
        }
        Null { return 'null' }
        Undefined { return 'undefined' }
        else { return 'Unknown' }
    }
}

pub fn (arr Array) str() string {
    return arr.values.str()
}

pub fn (x Field) json_str() string {
    mut out := '"' + x.key() + '": '

    match x {
        String {
            txt := x as String
            out += '"${txt.value}"'
        }
        Object {
            obj := x as Object
            out += obj.str()
        }
        Array {
            arr := x as Array
            out += ' ${arr.values.str()}'
        }
        else { out += x.str() }
    }

    return out
}

pub fn (obj Object) str() string {
    mut g := strings.new_builder(20000)
    g.write('{')
    obj_keys := obj.fields.keys()
    for i, k in obj_keys {
        f := obj.fields[k]
        str := f.json_str()
        for line in str.split_into_lines() {
            g.write('\n    ' + line)
        }
        if i < obj_keys.len-1 { g.write(', ') }
    }
    g.write('\n}')
    return g.str()
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
            obj := x as Object
            return obj.str()
        }
        Array {
            arr := x as Array
            return arr.values.str()
        }
        bool {
            bol := x as bool
            return bol.str()
        }
        Null { return 'null' }
        else { return 'null' }
    }
}

pub fn (av []ArrayValue) str() string {
    mut g := strings.new_builder(20000)
    g.writeln('[')

    for i, x in av {
        str := x.str()
        lines := str.split_into_lines()
        for li, line in lines {
            g.write('    ' + line)
            if li == lines.len-1 && i < av.len-1 { g.write(', ') }
            g.write('\n')
        }
        // g.write('\n')
    }

    g.writeln(']')

    return g.str()
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