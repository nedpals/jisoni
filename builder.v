module jisoni

// for map[string]Any
pub fn (mut obj map[string]Any) insert_str(key string, val string) {
	mut fi := Any{}
	fi = val
	obj[key] = fi
}

pub fn (mut obj map[string]Any) insert_int(key string, val int) {
	obj[key] = Any(val)
}

pub fn (mut obj map[string]Any) insert_f(key string, val f64) {
	obj[key] = Any(val)
}

pub fn (mut obj map[string]Any) insert_null(key string) {
	obj[key] = Any(Null{})
}

pub fn (mut obj map[string]Any) insert_bool(key string, val bool) {
	obj[key] = Any(val)
}

pub fn (mut obj map[string]Any) insert_map(key string, val map[string]Any) {
	obj[key] = Any(val)
}

pub fn (mut obj map[string]Any) insert_arr(key string, val []Any) {
	obj[key] = Any(val)
}

// For []Any
pub fn (mut arr []Any) insert_str(val string) {
	mut fi := Any{}
	fi = val
	arr << fi
}

pub fn (mut arr []Any) insert_int(val int) {
	arr << Any(val)
}

pub fn (mut arr []Any) insert_f(val f64) {
	arr << Any(val)
}

pub fn (mut arr []Any) insert_null() {
	arr << Any(Null{})
}

pub fn (mut arr []Any) insert_bool(val bool) {
	arr << Any(val)
}

pub fn (mut arr []Any) insert_map(val map[string]Any) {
	arr << Any(val)
}

pub fn (mut arr []Any) insert_arr(val []Any) {
	arr << Any(val)
}