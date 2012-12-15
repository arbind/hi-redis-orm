class A
  a: [8.9, 9.8]

class B extends A
  b:  {f:34, g: 55}

class C extends B
  c: true

a = new A
b = new B
c = new C

D = { d:'d' }

arr = [2,4,5]

console.log 'a', c.a
console.log 'b', c.b
console.log 'c', c.c
console.log 'D', D.d
console.log 'arr', arr.d

c.x = 1
D.y = 7
arr.z = 3

console.log 'c ---'
console.log typeof c
console.log Object is c.constructor
console.log c

console.log 'D ---'
console.log typeof D
console.log Object is D.constructor
console.log D

console.log 'Array ---'
console.log typeof arr
console.log Array is arr.constructor
console.log arr

console.log 'for own ---'
console.log k for own k, v of c

console.log 'xfor ---'

console.log "c c:", c.constructor
console.log "d d:", D.constructor

for own k, v of D
  console.log k,v 


console.log '----'
ref = new RORMRef 'rorm:B:44'

console.log ref
console.log JSON.stringify ref
