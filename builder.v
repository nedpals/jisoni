module jisoni

// for map[string]Field
pub fn (mut obj map[string]Field) insert_str(key string, val string) {
	mut fi := Field{}
	fi = val
	obj[key] = fi
}

pub fn (mut obj map[string]Field) insert_int(key string, val int) {
	obj[key] = Field(val)
}

pub fn (mut obj map[string]Field) insert_f(key string, val f64) {
	obj[key] = Field(val)
}

pub fn (mut obj map[string]Field) insert_null(key string) {
	obj[key] = Field(Null{})
}

pub fn (mut obj map[string]Field) insert_bool(key string, val bool) {
	obj[key] = Field(val)
}

pub fn (mut obj map[string]Field) insert_map(key string, val map[string]Field) {
	obj[key] = Field(val)
}

pub fn (mut obj map[string]Field) insert_arr(key string, val []Field) {
	obj[key] = Field(val)
}

// For []Field
pub fn (mut arr []Field) insert_str(val string) {
	mut fi := Field{}
	fi = val
	arr << fi
}

pub fn (mut arr []Field) insert_int(val int) {
	arr << Field(val)
}

pub fn (mut arr []Field) insert_f(val f64) {
	arr << Field(val)
}

pub fn (mut arr []Field) insert_null() {
	arr << Field(Null{})
}

pub fn (mut arr []Field) insert_bool(val bool) {
	arr << Field(val)
}

pub fn (mut arr []Field) insert_map(val map[string]Field) {
	arr << Field(val)
}

pub fn (mut arr []Field) insert_arr(val []Field) {
	arr << Field(val)
}