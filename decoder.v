module main

import v.scanner
import v.token

type Field = string | int | f64 | any_int | any_float | bool | Null | Undefined | []Field | map[string]Field

struct Null {}
struct Undefined {}

enum ParseMode {
    array
    bool
    invalid
    null
    number
    object
    string
}

struct Parser {
mut:
	scanner &scanner.Scanner
	p_tok token.Token
	tok token.Token
	n_tok token.Token
	nn_tok token.Token
	mode ParseMode = .invalid
	ar_n_level int = 0
	ob_n_level int = 0
}

fn (mut p Parser) next() {
	p.p_tok = p.tok
	p.tok = p.n_tok
	p.n_tok = p.nn_tok
	p.nn_tok = p.scanner.scan()
}

fn new_parser(srce string) Parser {
	mut src := srce
	// from v/util/util.v
	if src.len >= 3 {
		c_text := src.str
		if c_text[0] == 0xEF && c_text[1] == 0xBB && c_text[2] == 0xBF {
			// skip three BOM bytes
			offset_from_begin := 3
			src = tos(c_text[offset_from_begin], vstrlen(c_text) - offset_from_begin)
		}
	}
	mut p := Parser{
		scanner: scanner.new_scanner(src, .parse_comments),
	}
	return p
}

fn (p Parser) is_linefeed() ?bool {
	prev_tok_pos := p.p_tok.pos + p.p_tok.len
	if prev_tok_pos < p.scanner.text.len && p.scanner.text[prev_tok_pos] == 0x0c {
		return error('formfeed not allowed.')
	}
}

fn (p Parser) is_singlequote() bool {
	src := p.scanner.text
	prev_tok_pos := p.p_tok.pos + p.p_tok.len
	return src[prev_tok_pos] == `'`
}

fn (mut p Parser) detect_parse_mode() {
	src := p.scanner.text
	if src.len > 1 && src[0].is_digit() && !src[1].is_digit() {
		p.mode == .invalid
		return
	}

	p.tok = p.scanner.scan()
	p.n_tok = p.scanner.scan()
	p.nn_tok = p.scanner.scan()

	if src.len == 1 && p.tok.kind == .string && p.n_tok.kind == .eof {
		p.mode == .invalid
		return
	}

	match p.tok.kind {
		.lcbr { p.mode = .object }
		.lsbr { p.mode = .array }
		.number { p.mode = .number }
		.key_true, .key_false { p.mode = .bool }
		.string { p.mode = .string }
		.name {
			if p.tok.lit == 'null' {
				p.mode = .null
			}
		}
		.minus {
			if p.n_tok.kind == .number {
				p.mode = .number
			}
		}
		else {}
	}
}

fn (mut p Parser) decode_value() ?Field {
	mut fi := Field{}

	if p.tok.kind == .lsbr && p.n_tok.kind == .lcbr {
		p.ar_n_level++
	}

	if p.p_tok.kind == p.tok.kind {
		match p.tok.kind {
			.lsbr {
				p.ar_n_level++
			}
			.rsbr {
				p.ob_n_level++
			}
			else {}
		}
	}

	if p.ar_n_level == 500 || p.ob_n_level == 500 {
		return error('reached max nesting level.')
	}

	match p.tok.kind {
		.lsbr {
			item := p.decode_array() or {
				return error(err)
			}
			fi = item
		}
		.lcbr {
			item := p.decode_object() or {
				return error(err)
			}
			fi = item
		}
		.number {
			item := p.decode_number() or {
				return error(err)
			}
			fi = item
		}
		.key_true {
			fi = Field(true)
		}
		.key_false {
			fi = Field(false)
		}
		.name {
			if p.tok.lit != 'null' {
				return error('unknown identifier `$p.tok.lit`')
			}

			fi = Field(Null{})
		}
		.string {
			if p.is_singlequote() {
				return error('strings must be in double-quotes.')
			}

			item := p.decode_string() or {
				return error(err)
			}

			fi = item
		}
		else {
			if p.tok.kind == .minus && p.n_tok.kind == .number && p.n_tok.pos == p.tok.pos+1 {
				p.next()
				d_num := p.decode_number() or {
					return error(err)
				}
				p.next()
				fi = d_num
				return fi
			}

			return error('[decode_value] unknown token `$p.tok.lit`')
		}
	}
	p.next()

	// p.is_linefeed() or {
	// 	return error(err)
	// }

	return fi
}

fn (mut p Parser) decode_string() ?Field {
	mut fi := Field{}
	for i := 0; i < p.tok.lit.len; i++ {
		// s := p.tok.lit[i].str()
		// println('$i $s')
		if ((i-1 >= 0 && p.tok.lit[i-1] != `/`) || i == 0) && int(p.tok.lit[i]) in [9, 10, 0] {
			return error('must be escaped with a backslash')
		}

		if i == p.tok.lit.len-1 && p.tok.lit[i] == 92 {
			return error('invalid backslash escape')
		}

		if i+1 < p.tok.lit.len && p.tok.lit[i] == 92 {
			peek := p.tok.lit[i+1]
			if peek !in [`b`, `f`, `n`, `r`, `t`, `u`, `\\`, `"`, `/`] {
				return error('invalid backslash escape')
			} else {
				if peek == `u` {
					if i+5 < p.tok.lit.len {
						i += 4
					} else {
						return error('incomplete unicode escape.')
					}
				}

				i++
				continue
			}

			if peek == 85 {
				return error('unicode endpoints must be in lowercase `u`.')
			}

			if int(peek) in [9, 229] {
				return error('unicode endpoint not allowed.')
			}
		}
	}
	fi = p.tok.lit
	return fi
}

fn (mut p Parser) decode_number() ?Field {
	src := p.scanner.text
	mut tl := p.tok.lit
	mut is_fl := false
	sep_by_dot := tl.to_lower().split('.')

	if tl.starts_with('0x') && tl.all_after('0x').len <= 2 {
		return error('hex numbers should not be less than or equal to two digits.')
	}

	if src[p.p_tok.pos + p.p_tok.len] == `0` && src[p.p_tok.pos + p.p_tok.len + 1].is_digit() {
		return error('leading zeroes in integers are not allowed.')
	}

	if tl.starts_with('.') {
		return error('decimals must start with a digit followed by a dot.')
	}

	if tl.ends_with('+') || tl.ends_with('-') {
		return error('exponents must have a digit before the sign.')
	}

	if sep_by_dot.len > 1 {
		// analyze json number structure
		// -[digit][dot][digit][E/e][-/+][digit]
		is_fl = true
		last := sep_by_dot.last()

		if last.starts_with('e') {
			return error('exponents must have a digit before the exponent notation.')
		}
	}

	if p.p_tok.kind == .minus && p.tok.pos == p.p_tok.pos+1 {
		tl = '-' + tl
	}

	return if is_fl { Field(tl.f64()) } else { Field(tl.int()) }
}

fn (mut p Parser) decode_array() ?Field {
	mut items := []Field{}
	p.next()

	// todo
	// if p.n_tok.kind != p.tok.kind {
	// 	p.is_linefeed() or {
	// 		return error(err)
	// 	}
	// }

	for p.tok.kind != .rsbr {
		if p.tok.kind == .eof {
			return error('reached eof. data not closed properly.')
		}

		item := p.decode_value() or {
			return error(err)
		}

		items << item

		// p.is_linefeed() or {
		// 	return error(err)
		// }

		if p.tok.kind == .comma && p.n_tok.kind !in [.rsbr, .comma] {
			p.next()
			continue
		}
		
		if p.tok.kind == .rsbr {
			break
		}

		return error('[decode_array] unknown token `$p.tok.lit`')
	}

	return Field(items)
}

fn (mut p Parser) decode_object() ?Field {
	mut fields := map[string]Field
	mut cur_key := ''

	p.next()

	for p.tok.kind != .rcbr {
		is_key := p.tok.kind == .string && p.n_tok.kind == .colon

		// p.is_linefeed() or {
		// 	return error(err)
		// }

		if p.tok.kind == .eof {
			return error('reached eof. data not closed properly.')
		}

		if p.is_singlequote() {
			return error('object keys must be in single quotes.')
		}

		if !is_key {
			return error('invalid token `$p.tok.lit`, expected `string`')
		}

		cur_key = p.tok.lit
		p.next()
		p.next()
		
		item := p.decode_value() or {
			return error(err)
		}

		fields[cur_key] = item

		if p.tok.kind == .comma && p.n_tok.kind !in [.rcbr, .comma] {
			p.next()
			continue
		}

		if p.tok.kind == .rcbr {
			break
		}

		return error('[decode_object] unknown token `$p.tok.lit`')
	}
	return Field(fields)
}