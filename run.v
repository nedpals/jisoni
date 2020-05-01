module main

import os

fn main() {
    // Usage: ./[exec name] <url with json content>
    url := os.args[1]
    resp := os.read_file(url) or { panic('error') }
    mod := decode(resp) or {
        eprintln(err)
        exit(1)
    }
    println(mod)
    exit(0)
}