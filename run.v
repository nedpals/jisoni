module main

import os

// struct Person {
// mut:
//     name string
//     age  int = 20
//     pets []string
// }

// fn (mut p Person) from_json(f Field) Person {
//     obj := f.as_map()
//     for k, v in obj {
//         match k {
//             'name' { p.name = v.as_str() }
//             'age' { p.age = v.as_int() }
//             'pets' { p.pets = v.as_arr().map(it.as_str()) }
//             else {}
//         }
//     }
//     return p
// }

fn main() {
    // Usage: ./[exec name] <url with json content>
    url := os.args[1]
    resp := os.read_file(url) or { panic('error') }
    res := raw_decode(resp) or {
        eprintln(err)
        exit(1)
    }
    println(res)
    exit(0)
}