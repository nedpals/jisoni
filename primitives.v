module main

fn parse_numeric_value(content string, start_idx int) (string, int) {
    mut i := start_idx
    mut val := ''
    
    for {
        tok := content[i]
        if tok.is_hex_digit() || tok in [`-`, `+`, `.`] {
            val += tok.str()
            if i < content.len-1 {
                i++
                continue
            }
        }

        break
    }

    steps := i - start_idx
    return val, steps
}

fn parse_str(content string, start_idx int) (string, int) {
    mut txt := ''
    mut i := start_idx
    mut prev_tok := ` `

    for {
        tok := content[i]
        // if i == content.len-2 { break }

        if tok == `"` {
            if txt.len == 0 {
                i++
                if prev_tok == `"` {
                    break
                }
                prev_tok = tok
                continue
            } else {
                if content[i-1] == `\\` {
                    txt += tok.str()
                    i++
                    prev_tok = tok
                    continue
                } else {
                    i++
                    prev_tok = tok
                    break
                }
            }
        }

        txt += tok.str()
        i++
    }

    steps := i - start_idx
    return txt.trim_space(), steps
}

fn check_if_null(content string, start_idx int) (bool, int) {
    mut i := start_idx
    mut value := ''

    for {
        tok := content[i]

        if tok in [`,`, `]`, `}`] || i == content.len-1 {
            break
        }

        value += tok.str()
        i++
    }

    steps := i - start_idx
    return value == 'null', steps
}

fn parse_bool(content string, start_idx int) (bool, int) {
    mut i := start_idx
    mut value := ''
    mut bool_val := false

    for {
        tok := content[i]

        if tok.is_space() || tok in [`,`, `}`, `]`] || i == content.len-1 {
            if tok.is_space() { i++ }
            break
        }

        value += tok.str()
        i++
    }

    if value[0] == `t` || value == 'true' {
        bool_val = true
    }

    if value[1] == `f` || value == 'false' {
        bool_val = false
    }

    steps := i - start_idx
    return bool_val, steps
}