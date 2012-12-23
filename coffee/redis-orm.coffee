async = require 'async'
global.rorm_redisClients ||= {}

###
#   Some Constants
###
TYPE_FUNCTION = 'function'

###
#   Some Error Constants
###

NO_ID =        new Error "No id!"
NOT_A_MODEL =  new Error "Object is not a Redis ORM model!"
NO_REDIS_URL = new Error "No url configured for RedisORM mixin!"


###
#   Resolve JSON Functor
#   Convert redis value (stored as json) into js attribute, array, hash, or model
#   obj: The object that will have its key set to the resolved value
###
resolveJSONFunctorFor = (klazz, val, obj, key)->
  (cb)-> klazz.rorm_resolveJSONValue val, (err, resolvedValue)->
    obj[key] = resolvedValue if obj? and key?
    cb(null, resolvedValue)

###
#   Resolve Value Functor
#   Convert a js value into js attribute, array, hash, or model
#   obj: The object that will have its key set to the resolved value
#   optionally sets the val to the specified key on object (if obj and key are given)
#   otherwise, this functor is expected to run in an async call, and will receive an array of results when complete 
###
resolveValueFunctorFor = (klazz, val, obj, key)->
  (cb)-> klazz.rorm_resolveValue val, (err, resolvedValue)->
    obj[key] = resolvedValue if obj? and key?
    cb(null, resolvedValue)


class RedisORM extends Mixin

  @addTheseToClass:
    ###
    #   Some Constants
    ###
    rorm_delim:         ':'
    rorm_prefix:        'orm:'

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

    field: (name, options) ->
      return unless isHash(options)
      @dbFieldList(name, options) if (options.list? or options.type?.downcase() is 'list')
      @dbFieldHash(name, options) if (options.hash? or options.type?.downcase() is 'hash')
      @dbFieldSortedSet(name, options) if ( (options.set? and options.sorted?) or options.type?.downcase() is 'sortedset')
      @dbFieldSet(name, options) if ( (options.set? and not options.sorted?) or  options.type?.downcase() is 'set')

    dbFieldList: (name, options)-> console.log 'definging dbFieldList called ', name
    dbFieldHash: (name, options)-> console.log 'definging dbFieldHash called ', name
    dbFieldSet: (name, options)-> console.log 'definging dbFieldSet called ', name
    dbFieldSortedSet: (name, options)-> console.log 'definging dbFieldSortedSet called ', name

    materialize: (idOrHash, callback) ->
      return callback(NO_ID) unless idOrHash?
      id = idOrHash.id? || idOrHash.toString?()
      return callback(NO_ID) unless id?
      @find id, (err, obj)=>
        return callback(err) if err?
        if obj?
          obj.initializeFields idOrHash
          return callback(null, obj) if obj
        item = new @
        item.initializeFields(idOrHash)
        return callback(null, item)

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
        @rorm_resolveHashJSONValues(klazz, x, data, callback)

    rorm_resolveHashJSONValues: (klazz, targetHashObj, unresolvedHash, callback)->
      resolvers = []
      resolvers.push resolveJSONFunctorFor(klazz, v, targetHashObj, k) for own k,v of unresolvedHash
      async.series resolvers, (err, results)-> callback(err, targetHashObj)

    rorm_resolveJSONValue:(val, callback)->
      v = undefined
      try # convert json value back to js value (also handles null values)
        v = JSON.parse val
      catch e # or properly convert it to undefined
        v = undefined
      @rorm_resolveValue v, callback

    rorm_resolveValue:(val, callback)->
      if 'string' is typeof val and val.startsWith(@rorm_prefix)
        @rorm_findByRefKey val, callback
      else if val instanceof Array
        @rorm_deepLookupRefsInArray val, callback
      else if isHash(val)
        @rorm_deepLookupRefsInHash val, callback
      else
        callback(null, val)

    rorm_deepLookupRefsInHash: (unresolvedHash, callback)->
      targetHashObj = {}
      resolvers = []
      resolvers.push resolveValueFunctorFor(@, v, targetHashObj, k) for own k,v of unresolvedHash
      async.series resolvers, (err, results)-> callback(err, targetHashObj)

    rorm_deepLookupRefsInArray: (unresolvedArray, callback)->
      resolvers = []
      resolvers.push resolveValueFunctorFor(@, v) for v in unresolvedArray
      async.series resolvers, (err, results)-> callback(err, results)

    rorm_save: (model, expire, callback)->
      throw NO_ID unless model.id

      if not callback? and typeof expire is TYPE_FUNCTION
        callback = expire
        expire = -1

      seconds = parseInt(expire)
      @rorm_deepSaveAtts model, (err, key)=>
        if 0 < seconds
          @rorm_expire model, seconds, (err, ok)=>
            callback(err, key) if callback?
        else
          callback(err, key) if callback?

    rorm_expire: (model, seconds, callback)->
      key = @rorm_refKeyForModel(model)
      @rorm_redis().expire key, seconds, callback
      key

    rorm_persist: (model, callback)->
      key = @rorm_refKeyForModel(model)
      @rorm_redis().persist key, callback
      key

    rorm_destroy: (model, callback) ->
      throw NO_ID unless model.id
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
      redisAtts = @rorm_deepSaveHashValues atts # save any values as reference
      redisArgs = @rorm_argsForHMSET model.rorm_refKey(), redisAtts
      @rorm_redis().hmset redisArgs..., (err, ok)=>
        callback(err, redisArgs[0]) if callback?
      redisArgs[0] # return the redis key

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
        !(key.startsWith 'rorm_') and (typeof value isnt TYPE_FUNCTION)

    rorm_deepSaveHashValues: (atts)->
      mapOfHash atts, (key, val)=>
        throw NOT_A_MODEL if typeof val is TYPE_FUNCTION # ideally, this won't happen
        return [key, null] if val is null # properly preserve null value
        return [key, undefined] if val is undefined  # properly preserve undefined value
        if val instanceof Array
          mappedValue = @rorm_deepSaveArrayValues val
        else if (isHash val)
          mappedValue = @rorm_deepSaveHashValues val
        else
          mappedValue = val.save?() || val
        [key, mappedValue]

    rorm_deepSaveArrayValues: (array)->
      for val in array
        throw NOT_A_MODEL if typeof val is TYPE_FUNCTION # ideally, this won't happen
        item = null if val is null # properly preserve null value
        item = undefined if val is undefined  # properly preserve undefined value
        if val instanceof Array
          item = @rorm_deepSaveArrayValues val
          item
        else if (isHash val)
          item = @rorm_deepSaveHashValues val
        else
          item = val.save?() || val

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
    save: (expireInSeconds, callback)->
      @rorm_class().rorm_save(@, expireInSeconds, callback)

    initializeFields: (fieldsHash)->
      return unless fieldsHash? and isHash(fieldsHash)
      @[key] = val for own key, val of fieldsHash

    expire: (seconds, callback)->
      @rorm_class().rorm_expire(@, seconds, callback)

    persist: (callback)-> @rorm_class().rorm_persist(@, callback)

    destroy: (callback)->
      @rorm_class().rorm_destroy(@, callback)

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
