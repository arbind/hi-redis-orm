class RedisDelegate
  constructor: (@redis)->

  invoke: (opCode, callback)->
    method = opCode.method
    args = opCode.argsArray
    callback = opCode.callback
    @redis[method] args..., callback

module.exports = RedisDelegate
