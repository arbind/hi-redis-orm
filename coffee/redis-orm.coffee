class RedisORM extends Mixin

  NO_REDIS_URL = new Error "No url configured for RedisORM mixin!"

  @addTheseToClass:

    ###
    #   db
    #   returns a redis client bound to redisURL:dbNum
    #   the redis client can is cached globally by redisURL:dbNum
    #   defaults redisURL to redis::localhost:6379
    #   defaults dbNum to 0
    ###
    rorm_db: ()->
      return @_rorm_db if @_rorm_db?

      url = @mixinConfig.url || global.redisURL || global.REDIS_URL || process.env.REDIS_URL || process.env.REDISTOGO_URL || 'redis://127.0.0.1:6379/'
      dbNum = @mixinConfig.dbNum || global.dbNum || 0

      lookup = "#{url}[#{dbNum}]"
      global.rorm_redisClients ||= {}
      # create a new client unless another class has already made a connection
      rorm_redisClients[lookup] ||= (require 'redis-url').connect(url).select(dbNum)
      @_rorm_db = rorm_redisClients[lookup]

    find: (info)->

  @addTheseToInstance:
    save: ()->

global.RedisORM = RedisORM
