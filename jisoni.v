module jisoni

pub fn raw_decode(src string) ?Any {
	mut p := new_parser(src)
	p.detect_parse_mode()

	if p.mode == .invalid {
		return error('jisoni: invalid JSON.')
	}

	fi := p.decode_value() or {
		return error('jisoni: ' + err)
	}

	if p.tok.kind != .eof {
		return error('jisoni: [raw_decode] unknown token `$p.tok.kind`')
	}

	return fi
}

pub fn decode<T>(src string) T {
	res := raw_decode(src) or {
		panic(err)
	}

	mut typ := T{}
	return typ.from_json(res)
}

pub fn (f Field) as_map() map[string]Field {
	mut mp := map[string]Field

pub fn (f Any) as_map() map[string]Any {
	mut mp := map[string]Any

	match f {
		map[string]Any {
			return it
		}
		string {
			mp['0'] = it
			return mp
		}
		int {
			mp['0'] = it
			return mp
		}
		bool {
			mp['0'] = it
			return mp
		}
		f64 {
			mp['0'] = it
			return mp
		}
		Null {
			mp['0'] = it
			return mp
		}
		else {
			if typeof(f) == 'array_Field' {
				arr := f as []Any
				for i, fi in arr {
					mp[i.str()] = fi
				} 

				return mp
			}

			return mp
		}
	}
}

pub fn (f Any) as_str() string {
	match f {
		string {
			return f.str().trim_left('"').trim_right('"')
		}
		else {
			return f.str()
		}
	}
}

pub fn (f Any) as_int() int {
	match f {
		int {
			return *it
		}
		f64 {
			return f.str().int()
		}
		else {
			return 0
		}
	}
}

pub fn (f Any) as_f() f64 {
	match f {
		int {
			return f.str().f64()
		}
		f64 {
			return *it
		}
		else {
			return 0.0
		}
	}
}

pub fn (f Any) as_arr() []Any {
	if typeof(f) == 'array_Field' {
		arr := f as []Any
		return *arr
	}

	if f is map[string]string {
		mut arr := []Any{}
		mp := *(f as map[string]Any)
		for _, v in mp {
			arr << v
		}
		return arr
	}

	return [f]
}