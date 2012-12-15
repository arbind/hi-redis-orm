global.objSubset = (hash, fnSelectKeyValue)->
  h = {}
  for k,v of hash
    h[k] = v if fnSelectKeyValue(k,v) 
  h

global.objMap = (hash, fnMapKeyValue)->
  h = {}
  for k,v of hash
    [mappedKey, mappedValue]= fnMapKeyValue(k,v)
    console.log 'mapping:', "#{k}:#{v} to #{mappedKey}:#{mappedValue}"
    h[mappedKey] = mappedValue
  h
