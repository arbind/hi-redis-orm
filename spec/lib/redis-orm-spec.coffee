
testDBNum = ORM_ENV.redis.dbNum

describe 'redisORM', ->
  ###
  #   instance variables shared by specs
  ###
  @redis = null
  @subject = null

  ###
  #   setup and teardown
  #   start and end with an empty db in a test environment
  ###
  before (done)=>
    materializeRedisClient (err, client)=>
      @redis = client
      clearRedisTestEnv(@redis, "before specs:", done)

  after (done)=>
    clearRedisTestEnv(@redis, "after specs:", done)

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
      RedisORM.mixinTo @

    r = new Shape
    r.length = 19
    r.width = 20
    r.origin = {x: 8, y:8 }
    r.colors = ['blue', 'green']
    r.center = new Shape
    r.center.id = 4
    r.center.radius = 2

    console.log r.save()
    # (expect r.save()).to.equal 2
    done()

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

  # private methods:
  # it '@@findObjectForKey'
  # it '@@findArrayForKey'
  # it '@@saveArrayForKey'
  # it '@@objectFromJSON'
  # it '@@rorm_modelClassName'
  # it '@@rorm_modelClass'
  # it '@@rorm_clazz'
  # it '@@rorm_classNameForKey'
  # it '@@rorm_logError'
  