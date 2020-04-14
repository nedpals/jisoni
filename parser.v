module main

enum StartParseMode {
    object
    array
    number
    string
    null
    bool
}

struct Parser {
mut:
    content string
    idx int = 0
    parsed Field
    valid_start_json bool = false
    start_parse_mode StartParseMode
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
        tok := content[p.idx]
        if tok.is_space() || (tok == `{` && !key_set) {
            if tok == `{` { prev_tok = tok }
            p.idx++
            continue
        }

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
                obj.value << p.parse_string_field(cur_key)
                continue
            }

            if tok.is_letter() {
                if tok == `t` || tok == `f` {
                    prev_tok = tok
                    obj.value << p.parse_bool_field(cur_key)
                    continue
                }

                if tok == `n` {
                    nul := p.parse_null_field('Null_${curr_null_id}')
                    if nul.value == true {
                        obj.value << nul
                        curr_null_id++
                    }
                    prev_tok = content[p.idx]
                    continue
                }

                continue
            }

            if tok.is_digit() && prev_tok == `:` {
                obj.value << p.parse_number_field(cur_key) 
                prev_tok = content[p.idx]
                continue
            }

            if tok == `,` {
                if content[p.idx-1] != `,` || prev_tok != `,` {
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
                obj.value << p.parse_object(cur_key)
                prev_tok = content[p.idx-1]
                continue
            }

            if tok == `[` {
                obj.value << p.parse_array(cur_key)
                prev_tok = content[p.idx-1]
                continue
            } 
        }
        p.idx++
    }

    return obj
}

fn (p mut Parser) parse_array(key string) Array {
    mut curr_null_id := 0
    mut curr_obj_id := 0
    mut curr_arr_id := 0
    mut prev_tok := ` `
    mut arr := Array{key: key, value: []}
    content := p.content

    // println('parsing a new array, start_idx: ' + p.idx.str())
    for {
        tok := content[p.idx]

        if tok == `[` && prev_tok in [`[`, `,`] {
            arr.value << p.parse_array('Array_${curr_arr_id}')
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
            arr.value << p.parse_object('Object_${curr_obj_id}')
            curr_obj_id++
            prev_tok = content[p.idx]
            continue
        }

        if tok == `"` {
            val, steps := parse_str(content, p.idx)
            arr.value << val
            p.idx += steps
            if p.idx >= content.len-1 { break }
            prev_tok = content[p.idx]
            continue
        }

        if tok.is_digit() || (tok in [`-`, `+`] && content[p.idx+1].is_digit()) {
            val, steps := parse_numeric_value(content, p.idx)
            if is_float(val) {
                arr.value << val.f64()
            } else {
                arr.value << val.int()
            }
            p.idx += steps
            prev_tok = content[p.idx]
            continue
        }

        if tok.is_letter() && (tok == `t` || tok == `f`) {
            bol, steps := parse_bool(content, p.idx)
            arr.value << bol
            p.idx += steps
            prev_tok = content[p.idx]
            continue
        }

        if tok.is_letter() && tok == `n` {
            nul := p.parse_null_field('Null_${curr_null_id}')
            if nul.value == true {
                arr.value << nul
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

fn new_parser(content string) Parser {
    return Parser {
        content: content,
        idx: 0
    }
}

fn (p mut Parser) parse() Field {
    content := p.content

    for {
        tok := content[p.idx]
        // println('[main] ' + tok.str() + ' ' + p.idx.str())

        if tok.is_space() {
            p.idx++
            if p.idx == p.content.len { break }
            continue
        }

        if !p.valid_start_json {
            if tok == `{` { p.start_parse_mode = .object }
            if tok == `[` { p.start_parse_mode = .array }
            if tok.is_digit() || (tok in [`-`, `+`] && content[p.idx+1].is_digit()) {
                p.start_parse_mode = .number
            }
            if tok in [`t`, `f`] { p.start_parse_mode = .bool }
            if tok == `n` && content.len == 4 { p.start_parse_mode = .null }
            if tok == `"` { p.start_parse_mode = .string }

            p.valid_start_json = true
            continue
        } else {
            match p.start_parse_mode {
                .object { p.parsed = p.parse_object('') }
                .array { p.parsed = p.parse_array('') }
                .number { p.parsed = p.parse_number_field('Number_0') }
                .string { p.parsed = p.parse_string_field('String_0') }
                .bool { p.parsed = p.parse_bool_field('Bool_0') }
                .null { p.parsed = p.parse_null_field('Null_0') }
                else {}
            }

            break
        }
    }

    return p.parsed
}

fn decode(content string) Field {
    mut p := new_parser(content)
    p.parse()

    return p.parsed
}