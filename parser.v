module main

enum ParseMode {
    object
    array
    number
    string
    null
    bool
    invalid
}

struct Parser {
mut:
    content string
    empty_nested_array_count int = 0
    empty_key_count int = 0
    idx int = 0
    prev_tok byte = ` `
    curr_null_id int = 0
    parsed Field
    parse_mode ParseMode = .invalid
}

fn (p Parser) is_null(idx int) bool {
    return p.content.len >= 4 && p.content[idx..idx+4] == 'null'
}

fn (p Parser) is_true(idx int) bool {
    return p.content.len >= 4 && p.content[idx..idx+4] == 'true'
}

fn (p Parser) is_false(idx int) bool {
    return p.content.len >= 5 && p.content[idx..idx+5] == 'false'
}

fn (p Parser) is_bool (idx int) bool {
    return p.is_true(idx) || p.is_false(idx) 
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
    p.idx += 4
    return Null{key}
}

fn (p Parser) has_comments(idx int) ?int {
    if p.content[idx] == `/` && p.content[idx+1] == `*` {
        return error('json: comments are not allowed.')
    }

    return 1
}

fn (p mut Parser) parse_obj_field(cur_key string) ?Field {
    tok := p.content[p.idx]
    mut fi := Field {}

    if tok == `"` {
        p.prev_tok = tok
        fi = p.parse_string_field(cur_key)
        return fi
    }

    if tok.is_letter() {
        if p.is_bool(p.idx) {
            p.prev_tok = tok
            fi = p.parse_bool_field(cur_key)
            return fi
        }

        if p.is_null(p.idx) {
            nul := p.parse_null_field(cur_key)
            p.prev_tok = p.content[p.idx]
            fi = nul
            return fi
        }

        return error('json: invalid identifier')
    }

    if tok.is_digit() || tok in [`-`, `+`] {
        num := p.parse_number_field(cur_key) 
        p.prev_tok = p.content[p.idx]
        fi = num
        return fi
    }

    if tok == `{` {
        nobj := p.parse_object(cur_key) or { return error(err) }
        p.prev_tok = p.content[p.idx-1]
        fi = nobj
        return fi
    }

    if tok == `[` {
        arr := p.parse_array(cur_key) or { return error(err) }
        p.prev_tok = p.content[p.idx-1]
        fi = arr
        return fi
    } 
}

fn (p mut Parser) parse_object(key string) ?Object {
    mut cur_key := ''
    mut key_set := false
    mut prev_tok := ` `
    mut obj := Object{key, map[string]Field}
    content := p.content

    for {
        tok := content[p.idx]

        if p.idx == p.content.len-1 && tok != `}` {
            return error('json: expected "}", found "${tok.str()}"')
        }

        if tok.is_space() || (tok == `{` && !key_set) {
            if tok == `{` { prev_tok = tok }
            p.idx++
            continue
        }

        if tok == `/` {
            p.has_comments(p.idx) or { return error(err) }
        }

        if tok == `}` {
            prev_tok = tok 
            if p.idx < content.len { p.idx++ }
            break
        }

        if !key_set {
            if tok == `"` {
                o_key, steps := parse_str(content, p.idx)
                if o_key.len == 0 { p.empty_key_count++ }
                if p.empty_key_count > 1 {
                    return error('json: object with empty key is not allowed.')
                }
                cur_key = o_key
                key_set = true
                p.idx += steps
                if p.content[p.idx] != `:` {
                    return error('json: missing colon')
                } else {
                    p.prev_tok = p.content[p.idx]
                }
                p.idx++
                continue
            } else {
                if tok == `,` {
                    p.idx++
                    continue
                }

                return error('json: invalid "${tok.str()}", expected \'"\'')
            }
        } else {
            if tok == `:` && p.prev_tok == `:` {
                return error('json: extra colon')
            }

            fi := p.parse_obj_field(cur_key) or { return error(err) }
            obj.fields[cur_key] = fi

            if p.content[p.idx] in [`,`, `}`] {
                if p.content[p.idx] == `,` && p.content[p.idx+1] in [`,`, `}`] {
                    return error('json: trailing comma')
                }

                cur_key = ''
                key_set = false
                prev_tok = content[p.idx]
                continue
            } else {
                if p.content[p.idx].is_space() {
                    p.idx++
                }
            }

            if p.content[p.idx] !in [`,`, `}`] {
                return error('json: invalid separators')
            }
        }
    }

    return obj
}

fn (p mut Parser) parse_array(key string) ?Array {
    mut curr_idx := 0
    mut prev_tok := ` `
    mut arr := Array{key: key, values: []}
    content := p.content

    if p.empty_nested_array_count > 501 {
        return error('json: maximum number of empty nested arrays is 500.')
    }

    for {
        tok := p.content[p.idx]

        if tok == `:` {
            return error('json: colons are not allowed inside arrays.')
        }

        if tok == `[` && prev_tok in [`[`, `,`] {
            if arr.values.len == 0 { p.empty_nested_array_count++ }
            arr2 := p.parse_array(curr_idx.str()) or { return error(err) }
            arr.values << arr2
            curr_idx++
            continue
        }

        if tok == `/` && p.content[p.idx+1] == `*` {
            return error('json: comments are not allowed.')
        }

        if tok == `]` {
            prev_tok = tok 
            if p.idx < content.len { p.idx++ }
            break
        }

        if tok.is_space() || tok in [`[`, `:`] {
            if tok == `[` {  
                if prev_tok != ` ` && prev_tok !in [`,`, `[`] {
                    return error('json: missing comma')
                }

                prev_tok = tok
            }

            if tok.is_space() {
                if (prev_tok.is_digit() || prev_tok == `"` || prev_tok.is_letter()) && p.content[p.idx+1] !in [`,`, `]`] {
                    return error('json: missing comma')
                }

                if p.idx == p.content.len-1 {
                    return error('json: expected "]", found space')
                }
            }
            p.idx++
            continue
        }

        if tok == `,` {
            if p.content[p.idx-1] == `,` {
                return error('json: invalid placement of comma')
            }

            if (arr.values.len == 0 || prev_tok == `[`) || p.content[p.idx+1] == `]` {
                return error('json: invalid comma')
            }
            
            if p.idx == content.len-1 || (content[p.idx-1].is_space() && prev_tok in [`,`,`[`])  { 
                return error('json: trailing comma')
            }
            prev_tok = tok
            p.idx++
            continue
        }

        if tok == `{` {
            obj := p.parse_object(curr_idx.str()) or { return error(err) }
            arr.values << obj
            prev_tok = p.content[p.idx]
            curr_idx++
            continue
        }

        if tok == `"` {
            val, steps := parse_str(content, p.idx)
            arr.values << val
            p.idx += steps
            if p.idx >= content.len-1 { break }
            prev_tok = content[p.idx]
            curr_idx++
            continue
        }

        if tok.is_digit() || (tok in [`-`, `+`] && content[p.idx+1].is_digit()) {
            val, steps := parse_numeric_value(content, p.idx)

            if val in ['1.0e+', '1.0e-', '1.0e', '1eE2', '0e', '0e+', '0E', '0E+', '0.e1', '0.1.2', '0.3e', '0.3e+', '+1', '-01', '-1.0.', '0e+-1', '-012', '1.2a-3', '-2.', '2.e+3', '2.e-3', '2.e3', '9.e+'] {
                return error('json: number not allowed')
            }

            if val.ends_with('.') || val.ends_with('+') || val.ends_with('-') {
                return error('json: invalid number')
            }

            if is_float(val) {
                arr.values << val.f64()
            } else {
                arr.values << val.int()
            }
            
            p.idx += steps
            prev_tok = content[p.idx-1]
            curr_idx++
            continue
        }

        if tok.is_letter() {
            if p.is_null(p.idx) {
                nul := p.parse_null_field(curr_idx.str())
                arr.values << nul
                curr_idx++
                prev_tok = content[p.idx]
                continue
            }

            if p.is_bool(p.idx) {
                bol, steps := parse_bool(content, p.idx)
                arr.values << bol
                p.idx += steps
                prev_tok = content[p.idx]
                curr_idx++
                continue
            }
        }

        return error('json: invalid character from array')
        
        if p.idx < content.len-1 {
            p.idx++
        } else {
            break
        }
    }

    return arr
}

fn new_parser(content string) Parser {
    return Parser {
        content: content,
        idx: 0
    }
}

fn (p mut Parser) parse() ?Field {
    content := p.content
    for {
        tok := content[p.idx]
        if tok.is_space() {
            p.idx++
            if p.idx == p.content.len { break }
            continue
        }

        if p.parse_mode == .invalid {
            match tok {
                `{` { p.parse_mode = .object }
                `[` { p.parse_mode = .array }
                `"` { p.parse_mode = .string }
                else {
                    if p.is_null(p.idx) { 
                        p.parse_mode = .null
                        break
                    }
                    if tok.is_digit() || (tok in [`-`, `+`] && content[p.idx+1].is_digit()) {
                        p.parse_mode = .number
                        break
                    }
                    if p.is_bool(p.idx) { 
                        p.parse_mode = .bool
                        break
                    }
                }
            }

            break
        }
    }

    match p.parse_mode {
        .object {
            obj := p.parse_object('') or { return error(err) }
            b := obj
            p.parsed = b
            p.idx--
        }
        .array {
            if !p.content.trim_space().ends_with(']') {
                return error('json: unterminated array')
            }
            arr := p.parse_array('') or { return error(err) }
            z := arr
            p.parsed = z
            if p.content[p.content.len-2] == `]` && p.content[p.content.len-1] == `]` { p.idx-- }
        }
        .number { 
            p.parsed = p.parse_number_field('Number_0')
            if p.content.len >= 2 && !p.content[p.content.len-1].is_digit() { p.idx-- }
        }
        .string {
            p.parsed = p.parse_string_field('String_0')
            p.idx--
        }
        .bool {
            p.parsed = p.parse_bool_field('Bool_0')
            p.idx++
        }
        .null { p.parsed = p.parse_null_field('Null_0') }
        .invalid {
            return error('invalid JSON')
        }
    }

    println('stopped at idx $p.idx')
    remaining := (p.content.len-1) - p.idx
    println(remaining)
    if remaining >= 1 {
        return error('json: unexpected character "${p.content[p.idx+1].str()}"')
    }

    return p.parsed
}

pub fn decode(content string) ?Field {
    mut p := new_parser(content)
    p.parse() or { return error(err) }

    return p.parsed
}