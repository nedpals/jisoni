module main

import net.http
import os

fn main() {
    // Usage: ./[exec name] <url with json content>
    resp := http.get(os.args[1])?
    println(os.args[1])
    mod := decode(resp.text)
    println(mod)
}