# describe 'hiModelBase', ->
#   ###
#   #   instance variables shared by specs
#   ###
#   @subject = null

#   ###
#   #   setup and teardown
#   #   start and end with an empty db in a test environment
#   ###
#   before (done)=>
#     materializeRedisClient (err, client)=>
#       @redis = client
#       clearRedisTestEnv(@redis, "before specs:", done)

#   after (done)=>
#     clearRedisTestEnv(@redis, "after specs:", done)

#   it 'exists', (done)=>
#     (expect ModelBase).to.exist
#     done()

#   it '@constructor'
#   it '@className'
#   it '@id'
#   it '@set/get primitives'
#   it '@set/get array of primitives'
#   it '@set/get hash'
#   it '@set/get array of hashes'
#   it '@set/get model (ref)'
#   it '@set/get array of model (refs)'
#   it '@setFields'
#   it '@toJSON'
#   it '@toEvent'
#   it '@emitTo'