redisDBNum = ORM_ENV.redis.dbNum

global.materializeRedisClient = (callback)->
  redis = REDIS.connect(redisURL)
  unless redis?
    (callback CAN_NOT_CONNECT) if callback?
    throw CAN_NOT_CONNECT
  redis.select redisDBNum, (err, ok)->
    callback(err, redis) if callback? # send redis client back
  redis
