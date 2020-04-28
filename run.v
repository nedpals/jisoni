module main

import os

fn main() {
    // Usage: ./[exec name] <url with json content>
    url := os.args[1]
    resp := os.read_file(url) or { panic('error') }
    mod := decode(resp) or { panic('error') }
    println(mod)
    exit(0)
}