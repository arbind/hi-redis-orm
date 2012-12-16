# RedisDelegate = require '../../lib/redis-delegate'

# describe 'RedisDelegate', ->
#   ###
#   #   instance variables shared by specs
#   ###
#   @redisDelegate = null
#   @redisClient
#   @subject = null

#   ###
#   #   setup and teardown
#   #   start and end with an empty db in a test environment
#   ###
#   before (done)=>
#     materializeRedisClient (err, client)=>
#       @redisClient = client
#       @redisDelegate = new RedisDelegate @redisClient
#       clearRedisTestEnv(@redisClient, "before specs:", done)

#   after (done)=>
#     clearRedisTestEnv(@redisClient, "after specs:", done)

#   it 'exists', (done)=> 
#     (expect RedisDelegate).to.exist
#     done()

#   # Strings Values
#   it '@set', (done) =>
#     key = 'xyz'
#     val =  (new Date).toString()
#     cb = (err, result)=>
#       @redisClient.get key, (err, val) ->
#         (expect err).to.not.exist
#         (expect val).to.be.ok
#         (expect val).to.equal val
#         done()
#     opCode=
#       method: 'set'
#       argsArray: [key, val]
#       callback: cb
#     @redisDelegate.invoke opCode

#   it '@get', (done) =>
#     key = 'xyz'
#     val =  (new Date).toString()
#     cb = (err, result)=>
#         (expect err).to.not.exist
#         (expect result).to.be.ok
#         (expect result).to.equal val
#         done()
#     opCode=
#       method: 'get'
#       argsArray: [key]

#     @redisDelegate.invoke opCode, cb

#   it '@mset'
#   it '@mget'

#   # keys
#   it '@del'
#   it '@rename'
#   it '@exists'
#   it '@type'
#   it '@keys'
#   it '@ttl'
#   it '@expire'
#   it '@getset'

#   # Hash
#   it '@hset'
#   it '@hget'
#   it '@hgetall'
#   it '@hexists'
#   it '@hdel'
#   it '@hmset'
#   it '@hmget'
#   it '@hkeys'
#   it '@hvals'
#   it '@hlen'

#   # Set
#   it '@SADD'
#   it '@SREM'
#   it '@SCARD'
#   it '@SMEMBERS'
#   it '@SISMEMBER'

#   # Sorted Set
#   it '@ZADD'
#   it '@ZREM'
#   it '@ZCARD'
#   it '@ZRANGE'
#   it '@ZSCORE'
