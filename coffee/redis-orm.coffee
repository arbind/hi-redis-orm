async = require 'async'
global.rorm_redisClients ||= {}

# class RORMRef
#   constructor: (@rorm_ref)->

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
    #   Some Error Constants
    ###
    rorm_NO_ID: new Error "No id"

    ###
    #   db
    #   returns a redis client bound to redisURL:dbNum
    #   the redis client can is cached globally by redisURL:dbNum
    #   defaults redisURL to redis::localhost:6379
    #   defaults dbNum to 0
    ###
    rorm_redis: ()->
      return @mixinConfig.client if @mixinConfig.client?
      url = @mixinConfig.url || global.redisURL || global.REDIS_URL || process.env.REDIS_URL || process.env.REDISTOGO_URL || 'redis://127.0.0.1:6379/'
      dbNum = @mixinConfig.dbNum || global.dbNum || 0

      lookup = "#{url}[#{dbNum}]"
      # create a new client unless another class has already made a connection
      rorm_redisClients[lookup] ||= (require 'redis-url').connect(url).select(dbNum)

    configureRedisORM: (configs)-> @mixinConfig[key] = val for own key, val of configs

    materialize: (id, callback) ->
      # return from ref table
      # return from redis
      # return create new

    find: (id, callback)->
      refKey = @rorm_refKeyForID id
      @rorm_findByRefKey refKey, callback

    rorm_classForRefKey: (key)->
      className = key.split(':')[1]
      global[className]

    rorm_findByRefKey: (key, callback)->
      @rorm_redis().hgetall key, (err, data)=>
        return (callback err, null) unless data?
        klazz = @rorm_classForRefKey key
        x  = new klazz
        resolvers = []
        resolveFunctorFor = (x, k, v)->
          (cb)->x.rorm_resolveJSONValue k, v, cb
        
        resolvers.push resolveFunctorFor(x,k,v) for own k,v of data
        async.series resolvers, (err, results)-> callback(err, x)


    save: (model, callback)->
      throw @rorm_NO_ID unless model.id
      @rorm_deepSaveAtts(model, callback)      

    destroy: (model, callback) ->
      throw @rorm_NO_ID unless model.id
      key = model.rorm_refKey()
      @rorm_redis().del key, (err, ok)=>
        callback(err, key) if callback
      key

    ###
    #   deepSaveAtts
    #   deeply stores the all object atts to redis using:
    #   REDIS.HMSET key, att1, val1 [,att2, val2 ...]
    #   return: redis key
    ###
    rorm_deepSaveAtts: (model, callback)->
      atts = @rorm_attsForModel(model)  # grab the relevant atts to be saved
      redisAtts = @rorm_deepSaveRefs atts # save any values that reference other models
      redisArgs = @rorm_argsForHMSET model.rorm_refKey(), redisAtts
      @rorm_redis().hmset redisArgs..., (err, ok)=>
        callback(err, redisArgs[0]) if callback?
      redisArgs[0] # return the redis key

    rorm_deepSaveArrayValues: (array)-> (item = x.save?() || x) for x in array

    rorm_deepSaveHashValues: (hash)-> mapOfHash hash, (key, val)=> [key, val.save?() || val]

    ### 
    #   rorm_argsForHMSET
    #   prepars an argument array for call to:
    #   REDIS.HMSET key field value [field value ...]
    ###
    rorm_argsForHMSET: (redisKey, atts)-> 
      args = []
      args.push redisKey  # key for this object: 1st arg
      args.push k, JSON.stringify(v) for own k,v of atts
      args

    rorm_refKeyForModel: (model)-> @rorm_refKeyForID model.id, model.constructor.name

    rorm_refKeyForID: (id, className)-> 
      className ||= @name # use the name of this class, if none is given
      @rorm_prefix + className + @rorm_delim + id

    rorm_attsForModel: (model)->
      subsetOfHash model, (key,value)=>
        !(key.startsWith 'rorm_') and (typeof value isnt @rorm_TYPE_FUNCTION)

    rorm_deepSaveRefs: (atts)->
      mapOfHash atts, (key, val)=>
        return [key, null] if val is null # properly preserve null value
        return [key, undefined] if val is undefined  # properly preserve undefined value
        if val instanceof Array
          mappedValue = @rorm_deepSaveArrayValues val
        # if val is a hash +++ TODO
        #   mappedValue = @rorm_deepSaveHashValues val
        else
          mappedValue = val.save?() || val
        [key, mappedValue]

  @addTheseToInstance:
    rorm_class: ()-> @constructor
    rorm_refKey: ()-> @rorm_class().rorm_refKeyForModel(@)
    rorm_resolveJSONValue:(key, val, callback)->
      v = undefined
      try # convert json value back to js value (also handles null)
        v = JSON.parse val
      catch e # or properly convert it to undefined
        v = undefined

      if 'string' is typeof v and v.startsWith('rorm')
        console.log "-- looking up ref:", v
        @rorm_class().rorm_findByRefKey v, (err, ref)=>
          @[key] = ref           
          callback(null, @[key])
      else
        @[key] =  v
        console.log 'set', key, v
        callback(null, @[key])

    ###
    #   save
    #   stores the object's state in redis
    #   an @id is auto generated if one isn't set already
    #   return: redis key
    #   creates a key based on @id, and saves the object into redis
    #   values are saved as json
    #   refs as redis keys to the object (which all start with the rorm_prefix)
    ###
    save: (callback)-> @rorm_class().save(@, callback)

    destroy: (callback)-> @rorm_class().destroy(@, callback)



    ###
    #   toHash
    #   copy of all the model's attributes
    ###
    toHash: ()-> @rorm_class().rorm_attsForModel(@)

    toJSON: () -> JSON.stringify @toHash()

    toEvent: () -> 
      atts = @toHash() # copy of atts for modification
      delete atts[fieldName] for fieldName in @privateFields if @privateFields?
      atts

    emitTo: (channel) ->
      if channel.manager?.settings?.transports? # send attributes when emitting over socket.io
        channel.emit @className(), @toEvent()
      else                                      # send model object when emitting through EventEmitter
        channel.emit @className(), @

global.RedisORM = RedisORM
