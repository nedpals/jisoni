module jisoni
import strings
// String representation of the `map[string]Any`.
pub fn (flds map[string]Any) str() string {
	mut wr := strings.new_builder(200)
	wr.write('{')
	mut i := 0
	for k, v in flds {
		wr.write('"$k": ')
		wr.write(v.str())
		if i < flds.size-1 { wr.write(', ') }
		i++
	}
	wr.write('}')
	return wr.str()
}
// String representation of the `[]Any`.
pub fn (flds []Any) str() string {
	mut wr := strings.new_builder(200)
	wr.write('[')
	for i, v in flds {
		wr.write(v.str())
		if i < flds.len-1 { wr.write(', ') }
	}
	wr.write(']')
	return wr.str()
}
// String representation of the `Any` type.
pub fn (f Any) str() string {
	match f {
		string {
			str := *f
			return '"$str"'
		}
		int {
			return (*f).str()
		}
		f64 {
			return (*f).str()
		}
		any_int {
			return (*f).str()
		}
		any_float {
			return (*f).str()
		}
		bool {
			return (*f).str()
		}
		map[string]Any {
			return (*f).str()
		}
		Null {
			return 'null'
		}
		else {
			if typeof(f) == 'array_Any' {
				arr := f as []Any
				return (*arr).str()
			}
			return ''
		}
	}
}