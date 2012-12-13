# Fiber = require 'fibers'
# invoke = require 'invoke'
# async = require 'async'

# Future = require 'fibers/future'
# wait = Future.wait

# RedisDelegate = require './redis-delegate'

# class Scratch
#   constructor: (@redisClient)->
#     @redis = new RedisDelegate @redisClient

#   set: (key, val)->
#     @redis.set key, val, (err, result)->
#       console.log result

#   get: (key)=>
#     # rget = Future.wrap(@redis.get);
#     # f = Fiber ()-> answer = (rget key).wait()


#     console.log @redis.sync.get key

#     # u = (data)->
    #   data.redis.get data.key, (err, result)->
    #     console.log 'result u:', result
    #     Fiber.yield(result)

    # opCode = 
    #   redis: @redis
    #   key: key

    # answer = null

    # result = null
    # (invoke (data, cb)->
    #   console.log 'invoking:', opCode.key
    #   opCode.redis.get opCode.key, (err, result)->
    #     console.log "invoke ok:", result
    #     cb(err, result)
    # ).end( (data)-> 
    #   console.log "END: ", data
    #   result = data
    # )
    # u(data)
    # @f = (Fiber u)
    # result = @f.run(data)
    console.log 'result get:', answer
    answer

module.exports = Scratch