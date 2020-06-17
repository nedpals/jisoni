# JISONI
A work-in-progress JSON parser written on pure V. It aims to [replace CJSON](https://github.com/vlang/v/issues/309) and provides a cleaner and simple-to-use API for encoding and decoding JSON.

## API
```v
module main

import jisoni
import http

fn main() {
    // Decoding
    resp := http.get('https://example.com')?

    // raw decode
    raw_person := jisoni.raw_decode(resp.text)?

    // decode to a type
    person2 := jisoni.decode<Person>(resp.text)?

    //Navigating
    person := raw_person.as_map()
    name := person['name'].as_str() // Bob
    age := person['age'].as_int() // 19
    pi := person['pi'].as_f() // 3.14.... 

    //Encoding
    mut me := map[string]jisoni.Any
    me['name'] = 'Ned Poolz'
    me['age'] = 18

    mut arr := []jisoni.Any{}
    arr << 'rock'
    arr << 'papers'
    arr << jisoni.null()
    arr << 12

    me['interests'] = arr

    mut pets := map[string]jisoni.Any
    pets['Sam'] = 'Maltese Shitzu' 
    me['pets'] = pets

    println(me.str())
    //{"name":"Ned Poolz","age":18,"interests": ["rock", "papers", "scissors"],"pets":{"Sam":"Maltese"}}

}
```
## Using `decode<T>`
In order to use the `decode<T>` function, you need to explicitly define a `from_json` method from that type you're going to target which accepts a `jisoni.Any` argument and map the fields you're going to put into the type.

```v
struct Person {
mut:
    name string
    age  int = 20
    pets []string
}

fn (mut p Person) from_json(f Field) Person {
    obj := f.as_map()
    for k, v in obj {
        match k {
            'name' { p.name = v.as_str() }
            'age' { p.age = v.as_int() }
            'pets' { p.pets = v.as_arr().map(it.as_str()) }
            else {}
        }
    }
    return p
}

fn main() {
    resp := os.read_file('./person.json')?
    person := decode<Person>(resp)
    println(person) // Person{name: 'Bob', age: 28, pets: ['Floof']}
    exit(0)
}
```

## Using struct tags
Jisoni cannot use struct tags just like when you use the `json` module. However, it emits an `Any` type when decoding so it can be flexible on the way you use it.

### Null Values
Jisoni have a `null` value for differentiating an undefined value and a null value. Use `is` for verifying the field you're using is a null.

```v
fn (mut p Person) from_json(f Field) Person {
    obj := f.as_map()
    
    if obj['age'] is jisoni.Null {
        // use a default value
        p.age = 10
    }

    return p
}
```

### Custom Names
In `json`, you can specify the field name you're mapping into the struct field by specifying a `json:` tag. In Jisoni, just simply cast the base field into a map (`as_map()`) and get the value of the field you wish to put into the struct/type.

```
fn (mut p Person) from_json(f Field) Person {
    obj := f.as_map()
    
    p.name = obj['nickname'].as_str()

    return p
}
```

### Undefined Values
Getting undefined values has the same behavior as regular V types. If you're casting a base field into `map[string]Field` and fetch an undefined entry/value, it simply returns empty. As for the `[]Field`, it returns an index error.

## Casting a value to an incompatible type
Jisoni provides methods for turning `Any` types into usable types. The following list shows the possible outputs when casting a value to an incompatible type.

1. Casting non-array values as array (`as_arr()`) will return an array with the value as the content.
2. Casting non-map values as map (`as_map()`) will return a map with the value as the content.
3. Casting non-string values to string (`as_str()`) will return the stringified representation of the value.
4. Casting non-numeric values to int/float (`as_int()`/`as_f()`) will return zero. 

## TODO
- ~~Function Organization~~
- ~~JSON Tree Navigation~~
- ~~Encoding~~
- ~~Performance~~ (Not an important issue for now) 
- ~~Testing (Especially on JSON Test Suite)~~
- Error Messages (adding line numbers to message is WIP)
- ~~Parsing errors (Avoid correcting malformed/invalid ones!)~~

## License
Licensed under [MIT](LICENSE)

## Testing
1. Run `test.sh` (for Unix systems) or `test.bat` (for Windows)
2. Open `parsing.html` inside the `results/` folder of the JSON test suite. 

## Copyright
(c) 2020- Ned Palacios