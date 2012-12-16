# class RedisDelegate
#   constructor: (@redis)->

#   invoke: (opCode, callback)->
#     method = opCode.method
#     args = opCode.argsArray
#     cb = callback || opCode.callback
#     @redis[method] args..., cb

# module.exports = RedisDelegate
