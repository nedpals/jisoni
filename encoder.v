module main
import strings

pub fn (x Field) str() string {
    match x {
        String { return it.value }
        Bool { return it.value.str() }
        Object { return it.str() }
        Int { return it.value.str() }
        Array { return it.str() }
        Null { return 'null' }
        ArrayValue { return it.str() }
        Float { return it.value.strlong() }
        Undefined { return 'undefined' }
    }
}

pub fn (arr Array) str() string {
    return arr.values.str()
}

pub fn (x Field) json_str() string {
    mut out := '"' + x.key() + '": '

    match x {
        String { out += '"${it.value}"' }
        Object { out += it.str() }
        Array { out += ' ${it.values.str()}' }
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
            g.write(line)
        }
        if i < obj_keys.len-1 { g.write(', ') }
    }
    g.write('}')
    return g.str()
}

pub fn (x ArrayValue) str() string {
    match x {
        string { return '"$it"' }
        int { return it.str() }
        f64 { return it.strlong() }
        Object { return it.str() }
        Array { return it.values.str() }
        bool { return it.str() }
        Null { return 'null' }
    }
}

pub fn (av []ArrayValue) str() string {
    mut g := strings.new_builder(20000)
    g.write('[')

    for i, x in av {
        str := x.str()
        lines := str.split_into_lines()
        for li, line in lines {
            g.write(line)
            if li == lines.len-1 && i < av.len-1 { g.write(', ') }
        }
    }

    g.write(']')

    return g.str()
}

pub fn (xs []Field) str() string {
    mut g := strings.new_builder(20000)
    g.write('[')

    for i, x in xs {
        g.write(x.str())
        if i < xs.len-1 {
            g.write(', ')
        }
    }

    g.write(']')

    return g.str()
}