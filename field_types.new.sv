module main

type Field = String | Arr | Int | Float | Bool | Null | Object | Undefined | ArrValue
type ArrValue = string | int | f64 | Object | Arr | bool | Null

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
    key string
    value []Field
}

struct Arr {
mut:
    key string
    value []ArrValue
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

fn (p mut Parser) parse_number_field(key string) Field {
    value, steps := parse_numeric_value(p.content, p.idx)
    p.idx += steps

    // check if int
    if is_float(value) {
        return Float{key, value.f64()}
    } else {
        return Int{key, value.int()}
    }
}

fn (p mut Parser) parse_string_field(key string) String {
    value, steps := parse_str(p.content, p.idx)

    fi := String{key, value}
    p.idx += steps
    return fi
}

fn (p mut Parser) parse_bool_field(key string) Bool {
    value, steps := parse_bool(p.content, p.idx)

    fi := Bool{key, value}
    p.idx += steps
    return fi
}

fn (p mut Parser) parse_null_field(key string) Null {
    is_null, steps := check_if_null(p.content, p.idx)
    p.idx += steps

    if !is_null {
        return Null{key, false}
    }

    return Null{key: key} 
}

fn (p mut Parser) parse_object(key string) Object {
    mut curr_null_id := 0
    mut cur_key := ''
    mut key_set := false
    mut prev_tok := ` `
    mut obj := Object {key: key, value: []}
    content := p.content

    for {
        mut field := Field{}
        tok := content[p.idx]
        // println(tok.str() + ' ' + p.idx.str())

        if tok.is_space() || (tok == `{` && !key_set) {
            if tok == `{` { prev_tok = tok }
            p.idx++
            continue
        }

        // println('cur len: ' + cur_key.len.str())

        if tok == `}` {
            prev_tok = tok 
            if p.idx < content.len {
                p.idx++
            }
            break
        }

        if tok == `"` && !key_set {
            o_key, steps := parse_str(content, p.idx)
            cur_key = o_key
            key_set = true
            p.idx += steps
            continue
        }

        if key_set {
            if tok == `"` {
                prev_tok = tok
                field = p.parse_string_field(cur_key)
                obj.value << field
                continue
            }

            if tok.is_letter() {
                if tok == `t` || tok == `f` {
                    prev_tok = tok
                    field = p.parse_bool_field(cur_key)
                    obj.value << field
                    continue
                }

                if tok == `n` {
                    field = p.parse_null_field('Null_${curr_null_id}')
                    if field.value == true {
                        obj.value << field
                        curr_null_id++
                    }
                    prev_tok = content[p.idx]
                    continue
                }

                continue
            }

            if tok.is_digit() && prev_tok == `:` {
                field = p.parse_number_field(cur_key) 
                obj.value << field
                prev_tok = content[p.idx]
                continue
            }

            if tok == `,` {
                if prev_tok != `,` {
                    cur_key = ''
                    key_set = false
                }
                prev_tok = content[p.idx]
                if p.idx == content.len-1 { break }
                p.idx++
                continue
            }

            if tok == `:` {
                prev_tok = tok 
                p.idx++
                continue
            }

            if tok == `{` {
                field = p.parse_object(cur_key)
                obj.value << field
                prev_tok = content[p.idx-1]
                continue
            }

            if tok == `[` {
                field = p.parse_array(cur_key)
                obj.value << field
                prev_tok = content[p.idx-1]
                continue
            } 
        }
        p.idx++
    }

    return obj
}

fn (p mut Parser) parse_array(key string) Arr {
    mut curr_null_id := 0
    mut curr_obj_id := 0
    mut curr_arr_id := 0
    mut prev_tok := ` `
    mut arr := Arr{key: key, value: []}
    content := p.content

    // println('parsing a new array, start_idx: ' + p.idx.str())
    for {
        mut arrval := ArrValue{}
        tok := content[p.idx]

        if tok == `[` && prev_tok in [`[`, `,`] {
            arrval = p.parse_array('Array_${curr_arr_id}')
            arr.value << arrval
            curr_arr_id++
            continue
        }

        if tok == `]` {
            prev_tok = tok 
            if p.idx < content.len { p.idx++ }
            break
        }

        if tok.is_space() || tok in [`[`, `:`] {
            if tok == `[` { prev_tok = tok }
            p.idx++
            continue
        }

        if tok == `,` {
            prev_tok = tok
            if p.idx == content.len-1 || (content[p.idx-1].is_space() && prev_tok in [`,`,`[`])  { 
                break
            }
            p.idx++
            continue
        }

        if tok == `{` {
            arrval = p.parse_object('Object_${curr_obj_id}')
            arr.value << arrval
            curr_obj_id++
            prev_tok = content[p.idx]
            continue
        }

        if tok == `"` {
            val, steps := parse_str(content, p.idx)
            arrval = val
            arr.value << arrval
            p.idx += steps
            if p.idx >= content.len-1 { break }
            prev_tok = content[p.idx]
            continue
        }

        if tok.is_digit() {
            val, steps := parse_numeric_value(content, p.idx)
            if is_float(val) {
                arrval = val.f64()
            } else {
                arrval = val.int()
            }
            arr.value << arrval
            p.idx += steps
            prev_tok = content[p.idx]
            continue
        }

        if tok.is_letter() && (tok == `t` || tok == `f`) {
            bol, steps := parse_bool(content, p.idx)
            arrval = bol
            arr.value << arrval
            p.idx += steps
            prev_tok = content[p.idx]
            continue
        }

        if tok.is_letter() && tok == `n` {
            arrval = p.parse_null_field('Null_${curr_null_id}')
            if arrval.value == true {
                arr.value << arrval
                curr_null_id++
            }
            prev_tok = content[p.idx]
            continue
        }
        if p.idx < content.len-1 {
            p.idx++
        } else {
            break
        }
    }

    // println('done parsing, index now at: ' + p.idx.str())

    return arr
}