# JISONI
A work-in-progress JSON parser written on pure V. ~~Tested on old compiler (0.1.25) for now.~~

## Proposed API
```v
module main

import jisoni
import http

fn main() {
    // Decoding
    resp := http.get('https://example.com')?
    person := jisoni.decode(resp.text)?

    //Navigating
    name := person.get('name')
    age := person.get('age')

    //Encoding
    me := Jisoni.Object{'0', [
        Jisoni.String{'name', 'Ned Poolz'}
        Jisoni.Int('age', 18)
        Jisoni.Array{'interests', ['rock', 'papers', 'scissors']}
        Jisoni.Object{'Pets', [
            Jisoni.String{'Sam': 'Maltese'}
        ]}
    ]} 
    meJson := jisoni.encode(me)
    prinln(meJson)
    //{"name":"Ned Poolz","age":18,"interests": ["rock", "papers", "scissors"],"pets":{"Sam":"Maltese"}}

}
```

## Demo
![demo](demo.png)

## TODO
- Function Organization
- JSON Tree Navigation
- Encoding
- Performance
- Testing (Especially on JSON Test Suite)
- Parsing errors (Avoid correcting malformed/invalid ones!)

## License
Licensed under [MIT](LICENSE)

## Testing
TODO!

## Copyright
(c) 2020- Ned Palacios