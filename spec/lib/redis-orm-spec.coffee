testDBNum = ORM_ENV.redis.dbNum
redisClient = null

describe 'redisORM', ->
  ###
  #   instance variables shared by specs
  ###
  @subject = null

  ###
  #   setup and teardown
  #   start and end with an empty db in a test environment
  ###
  before (done)=>
    materializeRedisClient (err, client)=>
      redisClient = client
      clearRedisTestEnv(redisClient, "before specs:", done)

  after (done)=>
    clearRedisTestEnv(redisClient, "after specs:", done)

  it 'exists', (done)=> 
    (expect RedisORM).to.exist
    done()

  it 'can be extended as a mixin', (done)=> 
    class ABC
      RedisORM.mixinTo @

    a = new ABC
    (expect ABC).itself.to.respondTo('find')
    (expect a).to.respondTo('save')
    done()

  ###
  #   Public Instance methods
  ###
  it '@save', (done)=>
    class Shape
      RedisORM.mixinTo @, client: redisClient

    r = new Shape
    r.id = 2
    r.length = 19
    r.width = 20
    r.origin = {x: 8, y:8 }
    r.colors = ['blue', 'green']
    r.center = new Shape
    r.center.id = 4
    r.center.radius = 2

    k = r.save()
    Shape.find 2, (err, s)->
      console.log s
      # (expect r.save()).to.equal 2
      done()


  it '@save throws No Id'

  it '@save simple model with primitives'
  it '@save simple model with arrays'
  it '@save simple model with hashes'

  it '@save complex model with refs'
  it '@save complex model with refs in arrays'
  it '@save complex model with refs in hashes'

  it '@save handles cycle'

  it '@destroy'

  ###
  #   Public Class methods
  ###
  it '@@modelIDFor can be overridden'
  it '@@materialize new instance'
  it '@@materialize existing instance'
  it '@@find'
  it '@@findById'
  it '@@findAll'

  ###
  #   model representations
  ###
  it '@toHash'
  it '@toJSON'
  it '@toEvent'
  it '@emitTo'
