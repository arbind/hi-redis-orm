# Move these into its own hi-coffee-can module and require it !

global.isPresent ||= (obj)->
  return false unless obj?
  return true for own key, val of obj # hasOwnProperty of any key?
  return false

global.isEmpty = (obj)-> not isPresent(obj)


global.isString = (thing)-> 'string' is typeof thing or thing instanceof String
global.isNumber = (thing)-> 'number' is typeof thing or thing instanceof Number


# Object class methods
# Put these into Util, instead of extending Object!

Object.merge ||= (targetHash, hashList...)->
  for hash in hashList
    targetHash[key] = val for own key, val of hash
  targetHash

# Object prototype method extentions
Object::inject ||= (hashList...)->
  for hash in hashList
    @[key] = val for own key, val of hash
  @

Object::select ||= (fnSelect)->
  h = {}
  k[k] = val if fnSelect(k,val) for k,v in @
  h
  
Object::keys ||= ()-> key for own key, val of @

Object::isHash ||= ()->
  ok = true
  ok = false unless Object is @constructor
  ok = false unless 'string' is typeof @[key] for own key, val of @
  ok

Object::contains ||= (obj)->
  return false unless obj? and obj.isHash?()
  ok = true
  ok &&= @[key] is obj[key] for own key of obj
  ok

###
Sources:
http://jamesroberts.name/blog/2010/02/22/string-functions-for-javascript-trim-to-camel-case-to-dashed-and-to-underscore/
###

# Object prototype method extentions
String::upcase ||= -> @toUpperCase()
String::trim   ||= ()-> @replace /^\s+|\s+$/g, ""
String::ltrim  ||= ()-> @replace /^\s+/g, ""
String::rtrim  ||= ()-> @replace /\s+$/g, ""

String::tokens ||= (delim) ->
  list = @split(delim)
  list = (item.trim() for item in list)
  
String::startsWith ||= (needle)->
  0 is @indexOf(needle)

String::toCamel ||= ()->
  @replace /(\-[a-z,A-Z])/g, ($1)->
    $1.toUpperCase().replace('-','')

String::toDash ||= ()->
  @replace /([A-Z])/g, ($1)->
    return "-"+$1.toLowerCase()

String::toUnderscore ||= ()-> 
  @replace /([A-Z])/g, ($1)->
    "_"+$1.toLowerCase()

String::toTitleCase ||= ()->
  @replace /(?:^|\s)\w/g, ($1)->
    $1.toUpperCase()

# class-name -> ClassName
String::toClassName ||= ()-> @toCamel().toTitleCase()
