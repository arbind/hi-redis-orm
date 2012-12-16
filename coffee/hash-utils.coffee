global.subsetOfHash = (hash, fnSelectKeyValue)->
  h = {}
  for k,v of hash
    h[k] = v if fnSelectKeyValue(k,v) 
  h

global.mapOfHash = (hash, fnMapKeyValue)->
  h = {}
  for own k,v of hash
    [mappedKey, mappedValue]= fnMapKeyValue(k,v)
    h[mappedKey] = mappedValue
  h
