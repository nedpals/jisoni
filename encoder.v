module main
import strings

pub fn (flds map[string]Field) str() string {
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

pub fn (flds []Field) str() string {
	mut wr := strings.new_builder(200)
	wr.write('[')
	for i, v in flds {
		wr.write(v.str())
		if i < flds.len-1 { wr.write(', ') }
	}
	wr.write(']')
	return wr.str()
}

pub fn (f Field) str() string {
	match f {
		string {
			str := *it
			return '"$str"'
		}
		int {
			return (*it).str()
		}
		f64 {
			return (*it).str()
		}
		bool {
			return (*it).str()
		}
		map[string]Field {
			return (*it).str()
		}
		Null {
			return 'null'
		}
		else {
			if typeof(f) == 'array_Field' {
				arr := f as []Field
				return (*arr).str()
			}
			return 'undefined'
		}
	}
}