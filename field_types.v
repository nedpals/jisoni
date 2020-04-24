module jisoni

pub type Field = String | Array | Int | Float | Bool | Null | Object | Undefined | ArrayValue
pub type ArrayValue = string | int | f64 | Object | Array | bool | Null

pub struct Undefined {
    key string
    undefined bool = true
}

pub struct String {
    key string
    value string
}

pub struct Bool {
    key string
    value bool
}

pub struct Int {
    key string
    value int
}

pub struct Float {
    key string
    value f64
}

pub struct Null {
    key string
    value bool = true
}

pub struct Object {
mut:
    key string = 'Object_0'
    fields map[string]Field
}

pub struct Array {
mut:
    key string
    values []ArrayValue
}

// hacky way to prove string is float or an int or not
fn is_float(s string) bool {
    mut has_notation := false
    mut has_dot := false

    for i, c in s {
        if (c >= `a` && c <= `f`) || (c >= `A` && c <= `F`) || (c == `-` && i != 0) {
            has_notation = true
        }

        if c == `.` { has_dot = true }
    }
    
    return has_notation || has_dot
}