RedisDelegate = require '../../lib/redis-delegate'
# Scratch = require '../../lib/scratch'

describe 'Scratch', ->
  ###
  #   instance variables shared by specs
  ###
  @redisClient = null
  @redisDelegate = null

  ###
  #   setup and teardown
  #   start and end with an empty db in a test environment
  ###
  # before (done)=>
  #   materializeRedisClient (err, client)=>
  #     @redisClient = client
  #     @redisDelegate = new RedisDelegate @redisClient
  #     clearRedisTestEnv(@redisClient, "before specs:", done)

  # after (done)=>
  #   clearRedisTestEnv(@redisClient, "after specs:", done)

  # it 'exists', (done)=> 
  #   (expect RedisDelegate).to.exist
  #   done()

  # # Strings Values
  # it '@set', (done) =>
  #   key = 'xyz'
  #   val =  (new Date).toString()
  #   @redisDelegate.set key, val
  #   x = @redisDelegate.get key
  #   (expect x).to.be.ok
  #   console.log x
  #   (expect x).to.equal val

