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
    idx int = 0
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

fn (p mut Parser) parse_number_field(key string) Field {
    value, steps := parse_numeric_value(p.content, p.idx)
    p.idx += (steps-1)

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

fn (p mut Parser) parse_object(key string) ?Object {
    mut curr_null_id := 0
    mut cur_key := ''
    mut key_set := false
    mut has_closed := false
    mut prev_tok := ` `
    mut obj := Object {key: key, fields: map[string]Field}
    content := p.content

    for {
        tok := content[p.idx]
        if p.idx == p.content.len-1 && tok != `}` {
            println('json: expected "}", found "${tok.str()}"')
            exit(1)
        }

        if tok.is_space() || (tok == `{` && !key_set) {
            if tok == `{` { prev_tok = tok }
            p.idx++
            continue
        }

        if tok == `}` {
            prev_tok = tok 
            // TODO detect later
            has_closed = true
            if p.idx < content.len {
                p.idx++
            }
            break
        }

        if tok == `/` && p.content[p.idx+1] == `*` {
            println('json: comments are not allowed.')
            exit(1)
        }

        if !key_set {
            if tok == `"` {
                o_key, steps := parse_str(content, p.idx)
                if o_key.len == 0 {
                    println('json: object with empty key is not allowed.')
                    exit(1)
                }
                cur_key = o_key
                key_set = true
                p.idx += steps
                if content[p.idx] != `:` {
                    println('json: missing colon')
                    exit(1)
                }
                continue
            } else {
                println('json: invalid "${tok.str()}", expected \'"\'')
                exit(1)
            }
        }

        if key_set {
            if tok == `"` {
                prev_tok = tok
                obj.fields[cur_key] = p.parse_string_field(cur_key)
                continue
            }

            if tok.is_letter() {
                if p.is_true(p.idx) || p.is_false(p.idx) {
                    prev_tok = tok
                    obj.fields[cur_key] = p.parse_bool_field(cur_key)
                    continue
                }

                if p.is_null(p.idx) {
                    nul := p.parse_null_field('Null_${curr_null_id}')
                    obj.fields['Null_${curr_null_id}'] = nul
                    curr_null_id++
                    prev_tok = content[p.idx]
                    continue
                }

                continue
            }

            if tok.is_digit() && prev_tok == `:` {
                obj.fields[cur_key] = p.parse_number_field(cur_key) 
                prev_tok = content[p.idx]
                continue
            }

            if tok == `,` {
                if content[p.idx-1] != `,` || prev_tok != `,` {
                    cur_key = ''
                    key_set = false
                } else {
                    println('json: trailing comma')
                    exit(1)
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
                nobj := p.parse_object(cur_key) or { return error(err) }
                obj.fields[cur_key] = nobj
                prev_tok = content[p.idx-1]
                continue
            }

            if tok == `[` {
                arr := p.parse_array(cur_key) or { return error(err) }
                obj.fields[cur_key] = arr
                prev_tok = content[p.idx-1]
                continue
            } 
        }
        p.idx++
    }

    return obj
}

fn (p mut Parser) parse_array(key string) ?Array {
    mut curr_idx := 0
    mut prev_tok := ` `
    mut arr := Array{key: key, values: []}
    content := p.content

    if p.empty_nested_array_count > 501 {
        // test Optional
        return error('json: maximum number of empty nested arrays is 500.')
        // exit(1)
    }

    for {
        tok := content[p.idx]
        // println(tok)
        if p.idx == content.len-1 && tok != `]` {
            println('json: unterminated array')
            exit(1)
        }

        if tok == `:` {
            println('json: colons are not allowed inside arrays.')
            exit(1)
        }

        if tok == `[` && prev_tok in [`[`, `,`] {
            if arr.values.len == 0 { p.empty_nested_array_count++ }
            arr2 := p.parse_array(curr_idx.str()) or { return error(err) }
            arr.values << arr2
            curr_idx++
            continue
        }

        if tok == `/` && p.content[p.idx+1] == `*` {
            println('json: comments are not allowed.')
            exit(1)
        }

        if tok == `]` {
            prev_tok = tok 
            if p.idx < content.len { p.idx++ }
            if p.idx+1 < p.content.len && p.content[p.idx+1] == `]` {
                println('json: extra closing bracket found')
                exit(1)
            }
            break
        }

        if tok.is_space() || tok in [`[`, `:`] {
            if tok == `[` { prev_tok = tok }
            if tok.is_space() {
                if prev_tok.is_digit() || prev_tok == `"` || prev_tok.is_letter() {
                    println('json: missing comma')
                    exit(1)
                }

                if p.idx == p.content.len-1 {
                    println('json: expected "]", found space')
                    exit(1)
                }
            }
            p.idx++
            continue
        }

        if tok == `,` {
            if prev_tok == `,` {
                println('json: invalid placement of comma')
                exit(1)
            }
            if (arr.values.len == 0 || prev_tok == `[`) || p.content[p.idx+1] == `]` {
                println('json: invalid comma')
                exit(1)
            }
            if p.idx == content.len-1 || (content[p.idx-1].is_space() && prev_tok in [`,`,`[`])  { 
                println('json: trailing comma')
                exit(1)
            }
            prev_tok = tok
            p.idx++
            continue
        }

        if tok == `{` {
            obj := p.parse_object(curr_idx.str()) or { return error(err) }
            arr.values << obj
            prev_tok = content[p.idx]
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
                println('json: number not allowed')
                exit(1)
            }

            if is_float(val) {
                arr.values << val.f64()
            } else {
                arr.values << val.int()
            }
            p.idx += steps
            prev_tok = content[p.idx]
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

            if p.is_true(p.idx) || p.is_false(p.idx) {
                bol, steps := parse_bool(content, p.idx)
                arr.values << bol
                p.idx += steps
                prev_tok = content[p.idx]
                curr_idx++
                continue
            }
        }

        println('json: invalid character from array')
        exit(1)
        
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
                    if p.is_true(p.idx) || p.is_false(p.idx) { 
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
            p.parsed = obj
        }
        .array {
            arr := p.parse_array('') or { return error(err) }
            p.parsed = arr
        }
        .number { p.parsed = p.parse_number_field('Number_0') }
        .string { p.parsed = p.parse_string_field('String_0') }
        .bool { p.parsed = p.parse_bool_field('Bool_0') }
        .null { p.parsed = p.parse_null_field('Null_0') }
        .invalid {
            println('invalid JSON.')
            exit(1)
        }
    }

    return p.parsed
}

pub fn decode(content string) ?Field {
    mut p := new_parser(content)
    p.parse() or { return error('Error decoding JSON') }

    return p.parsed
}