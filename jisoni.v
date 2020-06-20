module jisoni
// Decodes a JSON string into an `Any` type. Returns an option.
pub fn raw_decode(src string) ?Any {
	mut p := new_parser(src)
	p.detect_parse_mode()

	if p.mode == .invalid {
		return error('[jisoni] ' + p.emit_error('Invalid JSON.'))
	}

	fi := p.decode_value() or {
		return error('[jisoni] ' + p.emit_error(err))
	}

	if p.tok.kind != .eof {
		return error('[jisoni] ' + p.emit_error('Unknown token `$p.tok.kind`.'))
	}

	return fi
}
// A generic function that decodes a JSON string into the target type.
pub fn decode<T>(src string) T {
	res := raw_decode(src) or {
		panic(err)
	}

	mut typ := T{}
	return typ.from_json(res)
}
// A generic function that encodes a type into a JSON string.
pub fn encode<T>(typ T) string {
	return typ.to_json()
}
// A simple function that returns `Null` struct. For use on constructing an `Any` object.
pub fn null() Null {
	return Null{}
}
// Use `Any` as a map.
pub fn (f Any) as_map() map[string]Any {
	mut mp := map[string]Any

	match f {
		map[string]Any {
			return f
		}
		string {
			mp['0'] = f
			return mp
		}
		int {
			mp['0'] = f
			return mp
		}
		bool {
			mp['0'] = f
			return mp
		}
		f64 {
			mp['0'] = f
			return mp
		}
		Null {
			mp['0'] = f
			return mp
		}
		else {
			if typeof(f) == 'array_Any' {
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
// Use `Any` as a string.
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
// Use `Any` as an integer.
pub fn (f Any) as_int() int {
	match f {
		int {
			return *f
		}
		f64 {
			return f.str().int()
		}
		else {
			return 0
		}
	}
}
// Use `Any` as a float.
pub fn (f Any) as_f() f64 {
	match f {
		int {
			return f.str().f64()
		}
		f64 {
			return *f
		}
		else {
			return 0.0
		}
	}
}
// Use `Any` as an array.
pub fn (f Any) as_arr() []Any {
	if typeof(f) == 'array_Any' {
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