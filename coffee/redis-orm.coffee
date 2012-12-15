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
      url = @mixinConfig.url || global.redisURL || global.REDIS_URL || process.env.REDIS_URL || process.env.REDISTOGO_URL || 'redis://127.0.0.1:6379/'
      dbNum = @mixinConfig.dbNum || global.dbNum || 0

      lookup = "#{url}[#{dbNum}]"
      global.rorm_redisClients ||= {}
      # create a new client unless another class has already made a connection
      rorm_redisClients[lookup] ||= (require 'redis-url').connect(url).select(dbNum)

    find: (info)->

    ###
    #   deepSaveAtts
    #   deeply stores the all object atts to redis using:
    #   REDIS.HMSET key, att1, val1 [,att2, val2 ...]
    #   return: redis key
    ###
    # +++ make this static
    rorm_deepSaveAtts: (model)->
      console.log "888888888888888888"
      atts = @rorm_attsForModel(model)  # grab the relevant atts to be saved
      console.log atts
      redisAtts = @rorm_deepSaveRefs atts # save any values that reference other models
      console.log redisAtts
      redisArgs = @rorm_argsForHMSET model.rorm_refKey(), redisAtts
      console.log redisArgs
      #redis.hmset redisArgs...
      redisArgs[0] # return the redis key

    # +++ make this static
    rorm_deepSaveArrayValues: (array)-> (item = x.save?() || x) for x in array

    # +++ make this static
    rorm_deepSaveHashValues: (hash)-> 
      h = {}
      for k,v in hash
        val = v.save?() || v
        h[k]=val
      h

    ### 
    #   rorm_argsForHMSET
    #   prepars an argument array for call to:
    #   REDIS.HMSET key field value [field value ...]
    ###
    rorm_argsForHMSET: (redisKey, atts)-> 
      args = []
      args.push redisKey  # key for this object: 1st arg
      args.push k, JSON.stringify(v) for k,v of atts
      args

    rorm_refKeyForModel: (model)-> @rorm_prefix + model.constructor.name + @rorm_delim + model.id

    rorm_attsForModel: (model)->
      objSubset model, (key,value)=>
        return false if key.startsWith 'rorm_'
        return false if typeof value is @rorm_TYPE_FUNCTION
        return true

    rorm_deepSaveRefs: (atts)->
      console.log "DEEP SAVE REFS", atts
      objMap atts, (key, val)=>
        if val instanceof Array
          mappedValue = @rorm_deepSaveArrayValues val
        # if val is a hash +++ TODO
        #   mappedValue = @rorm_deepSaveHashValues val
        else
          console.log "SAVINGSAVINGSAVINGSAVING REF", val.id if val.save?
          mappedValue = val.save?() || val
        [key, mappedValue]


  @addTheseToInstance:
    rorm_class: ()-> @constructor
    rorm_refKey: ()-> @rorm_class().rorm_refKeyForModel(@)

    ###
    #   save
    #   stores the object's state in redis
    #   an @id is auto generated if one isn't set already
    #   return: redis key
    #   creates a key based on @id, and saves the object into redis
    #   values are saved as json
    #   refs as redis keys to the object (which all start with the rorm_prefix)
    ###
    save: ()->
      console.log "SAVNGSAVNGSAVNGSAVNG OBJ"
      @id ||= 'generate-a-unique-id-already'
      @rorm_class().rorm_deepSaveAtts(@) # save the atts

    # rorm_valueFor: (typeOfValue, value)->
    #   if typeOfValue is @rorm_class().rorm_TYPE_OBJECT and value.constructor? and Object isnt value.constructor
    #     if @rorm_class().rorm_CLASS_ARRAY is value.constructor.name
    #       v = @rorm_arrayFor(value)
    #     else
    #       v = @rorm_refKeyFor(value)
    #   v ||= value

    # rorm_arrayFor: (array)-> array

global.RedisORM = RedisORM
