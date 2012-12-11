# hi Redis ORM

## Easily store complex javascript objects to redis
Store and retrieve a graph of inter-dependent objects to redis.

## Status
Initial commit: this is an 'empty' repo at the moment!

Specs are in progress.


## Installation

    [not published]

## Usage

### Make sure redis is running:

The lib defaults to using redis running on localhost

### Open a terminal windows and fire up node:
    $ node
    Animal = require ('Animal')

    donatello = new Animal({'name': 'Donatallo', type:'turtle', mutant:true})
    donatello.save()

    raphael   = new Animal({'name': 'Raphael', type:'turtle', mutant:true})
    raphael.save()

    sensei    = new Animal({'name': 'Splinter',  type:'rat', mutant:false}))
    sensei.save()

    donatello.setMaster(sensei)
    raphael.setMaster(sensei)

    sensei.students() // returns: [donatello, raphael]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
