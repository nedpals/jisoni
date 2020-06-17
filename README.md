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
    person := jisoni.raw_decode(resp.text)?

    // to a type
    person2 := jisoni.decode<Person>(resp.text)?

    //Navigating
    name := person.as_map()['name']
    age := person.as_map()['age']

    //Encoding
    mut me := map[string]Field
    me['name'] = 'Ned Poolz'
    me['age'] = 18

    mut arr := []Field{}
    arr << 'rock'
    arr << 'papers'
    arr << Null{}
    arr << 12

    me['interests'] = arr

    mut pets := map[string]Field
    pets['Sam'] = 'Maltese Shitzu' 
    me['pets'] = pets

    println(me.str())
    //{"name":"Ned Poolz","age":18,"interests": ["rock", "papers", "scissors"],"pets":{"Sam":"Maltese"}}

}
```

## Demo
![demo](demo.png)

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