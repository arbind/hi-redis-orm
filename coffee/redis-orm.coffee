class RORMRef
  constructor: (@rorm_ref)->


class RedisORM extends Mixin

  NO_REDIS_URL = new Error "No url configured for RedisORM mixin!"

  @addTheseToClass:
    ###
    #   Some Constants
    ###
    rorm_delim:         ':'
    rorm_prefix:        'rorm:'
    rorm_TYPE_OBJECT:   'object'
    rorm_TYPE_FUNCTION: 'function'
    rorm_CLASS_ARRAY:   'Array'

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
    rorm_class: ()-> @constructor
    rorm_refKey: ()-> (rorm_refKeyFor @)
    rorm_refKeyFor: (obj)-> @rorm_class().rorm_prefix + obj.constructor.name + @rorm_class().rorm_delim + obj.id

    save: ()->
      atts = @rorm_atts()

    rorm_atts: ()-> 
      fields = {}
      for k, v of @
        pair = (@rorm_keyValueFor k, v)
        continue unless pair
        fields[pair.key] = pair.value
      fields

    rorm_keyValueFor: (key, value)->
      return null if key.startsWith 'rorm_'
      typeOfVal = typeof value
      return null if typeOfVal is @rorm_class().rorm_TYPE_FUNCTION
      key:key, value:@rorm_valueFor(typeOfVal, value)

    rorm_valueFor: (typeOfValue, value)->
      if typeOfValue is @rorm_class().rorm_TYPE_OBJECT and value.constructor? and Object isnt value.constructor
        if @rorm_class().rorm_CLASS_ARRAY is value.constructor.name
          v = @rorm_arrayFor(value)
        else
          v = @rorm_refKeyFor(value)
      v ||= value

    rorm_arrayFor: (array)-> array

global.RedisORM = RedisORM
