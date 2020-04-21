module jisoni

import net.http
import os

fn main() {
    // Usage: ./[exec name] <url with json content>
    url := 'https://vpkg-project.github.io/registry/registry.json'
    resp := http.get(url) or { panic('Error') }
    mod := decode(resp.text) or { panic('Error') }

    // TODO: Better API for retrieving array values
    packages := mod.get('packages') as Array
    pkg := packages.values[0] as Object

    println(pkg.get('name'))
}