# class ModelBase extends Mixin
#   @configuration:
#     redisURL: process.env.REDIS_URL || process.env.REDISTOGO_URL || 'redis://127.0.0.1:6379/'
#     dbNumber: ORM_ENV.redis.dbNum

#   _attributes: null
#   _refs: null

#   @extend: (module) ->
#     @[key] = value for key, value of module when key not in mixinKeywords
#     module.extended?.apply(@)
#     @

#   @include: (module) -> # Assign properties to the prototype
#     @::[key] = value for key, value of module when key not in mixinKeywords
#     module.included?.apply(@)
#     @

#   # BaseClass class methods
#   constructor: (attributes) ->
#     @_attributes = attributes || {}
#     @_refs = {}
#     @_loadRefs()
#     throw "These attributes must be a hash not #{@_attributes.constructor.name}" unless @_attributes.isHash()
#     return unless attributes? and isPresent(attributes)
#     @setFields attributes

#   # BaseClass instance methods
#   className: ()=> @constructor.name

#   id: ()=> @get('id')

#   get: (attName) =>
#     @_attributes[attName] || @_getRef(attName) || null

#   set: (attName, value) => 
#     @_set attName, value

#   dbGet: (attName, callback) =>
#     @_attributes[attName] || @_getRef(attName) || null

#   dbSet: (attName, value, callback) => 
#     return unless attName? and 'function' is typeof callback
#     if value instanceof ModelBase
#       @_setRefORM(attName, value, callback)
#     else
#       @_setAttORM(attName, value, callback)

#   setFields: (atts) =>
#     (@_set field, atts[field] if atts[field]?) for field in @classFieldNames if atts?

#   _set: (attName, value) => 
#     return unless attName?
#     if value instanceof ModelBase
#       @_setRefORM(attName, value, null)
#       @_setRef(attName, value)
#     else
#       @_setAttORM(attName, value, null)
#       @_setAtt(attName, value)

#   _setAtt: (attName, value) => 
#       @_attributes[attName] = value

#   _setRef: (name, obj)=>
#     @_attributes._refIds ||= {}
#     @_attributes._refIds[name] = obj.id()
#     @_refs[name] = obj

#   _getRef: (name)=>
#     return @_refs[name] if @_refs[name]?        # return the object if it is already loaded
#     return null unless @_attributes._refIds?[name]?          # return null if there is no object or refId for this name
#     @_refs[name] = @_loadRef(name, @_attributes._refIds[name]) # load the actual object if there is a refId

#   _setAttORM: (attName, value, callback) => 
#   _setRefORM: (attName, value, callback) => 

#   _loadRefs: ()=> # recursively load all refs
#     return unless @_attributes._refIds # nothing to load if there are no refIds
#     return if @_attributes._refIds.keys().length is @_refs.keys().length  # return if refs are already loaded
#     nextRef = null # find the next ref that needs to be loaded:
#     (nextRef ||= refName unless @_refs[refName]?) for refName, refId in @_attributes._refIds
#     @_loadRef name, @_attributes._refIds[name], (err, obj) =>
#       @_refs[name] = obj || null
#       @_loadRefs() # recursively load all refs

#   _loadRef: (name, id, callback)=>
#     svcClassName = name.toTitleCase()+"Service"
#     svcClass = global[svcClassName]  
#     svcClass.find id, callback

#   toJSON: () => 
#     JSON.stringify @_attributes

#   toEvent: () => 
#     atts = Object.merge {}, @_attributes # copy for modification

#     # remove private fields
#     delete atts[fieldName] for fieldName in @privateFields if @privateFields?

#     # add object relationships
#     delete atts['_refIds']
#     (atts[objName] = obj.toEvent() if obj?.toEvent?() ) for own objName, obj of @_refs
#     atts

#   emitTo: (channel) =>
#     if channel.manager?.settings?.transports? # send attributes when emitting over socket.io
#       channel.emit @className(), @toEvent()
#     else                                      # send model object when emitting through EventEmitter
#       channel.emit @className(), @

# # make this base class available globally
# module.exports = global.ModelBase = ModelBase
