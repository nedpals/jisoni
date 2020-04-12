module main

import net.http
import os

fn main() {
    // Usage: ./[exec name] <url with json content>
    resp := http.get(os.args[1])?
    mod := decode(resp.text)
    println(mod)

    // me := Object{'0', [
    //     Field(String{'name', 'Ned Poolz'}),
    //     Field(Int{'age', 18}),
    //     Field(Object{'Pets', [
    //         Field(String{'Sam', 'Maltese'})
    //     ]})
    // ]} 
    // me_json := encode(me)
    // println(me_json)
}