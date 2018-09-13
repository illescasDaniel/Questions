//
//  main.swift
//  DynamicClass
//
//  Created by Daniel Illescas Romero on 05/09/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import Foundation

var daniel = Person()

print(daniel)

daniel.name = "personaje"
print(daniel.name!)

daniel.name = "cosa"
print(daniel.name!)

(daniel.m_run as! Method).call()

let result = (daniel.m_nameTitle as! Method).withResult(parameter: ["test", "lol"])
print(result!)

daniel.m_run = Method({
	print("loooooool")
})

(daniel.m_run as! Method).call()

daniel.m_run = "lol"

(daniel.m_run as! Method).call()

print(daniel.d_otherThing!)
daniel.d_otherThing = [
	"name": "daniel"
]
print(daniel.d_otherThing!)

daniel.d_otherThing = "lol"
print(daniel.d_otherThing!)

daniel.a_numbers = [3,4,5]
print(daniel.a_numbers!)

daniel.a_numbers = "cosa"
print(daniel.a_numbers!)

