module main

type Field = String | Array | Int | Float | Bool | Null | Object | Undefined | ArrayValue
type ArrayValue = string | int | f64 | Object | Array | bool | Null

struct Undefined {
    key string
    undefined bool = true
}

struct String {
    key string
    value string
}

struct Bool {
    key string
    value bool
}

struct Int {
    key string
    value int
}

struct Float {
    key string
    value f64
}

struct Null {
    key string
    value bool = true
}

struct Object {
mut:
    key string = 'Object_0'
    value []Field
}

struct Array {
mut:
    key string
    value []ArrayValue
}

// hacky way to prove string is float or an int or not
fn is_float(s string) bool {
    mut has_notation := false
    mut has_dot := false

    for i, c in s {
        if (c >= `a` && c <= `f`) || (c >= `A` && c <= `F`) || (c == `-` && i != 0) {
            has_notation = true
        }

        if c == `.` {
            has_dot = true
        }
    }

    if has_notation || has_dot {
        return true
    }

    return false
}