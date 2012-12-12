redisDBNum = ORM_ENV.redis.dbNum

global.materializeRedisClient = (callback)->
  redis = REDIS.connect(redisURL)
  unless redis?
    (callback CAN_NOT_CONNECT) if callback?
    throw CAN_NOT_CONNECT
  redis.select redisDBNum, (err, ok)->
    callback(err, redis) if callback? # send redis client back
  redis


# mixin support
mixinKeywords = ['extended', 'included']

global.extendMixin = (klazz, mixin) ->
  klazz[key] = value for key, value of mixin when key not in mixinKeywords
  mixin.extended?.apply(klazz)
  klazz

global.includeMixin = (klazz, mixin) -> # Assign properties to the prototype
  klazz::[key] = value for key, value of mixin when key not in mixinKeywords
  mixin.included?.apply(klazz)
  klazz
