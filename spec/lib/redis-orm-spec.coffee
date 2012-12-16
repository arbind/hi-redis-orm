testDBNum = ORM_ENV.redis.dbNum
redisClient = null


###
#   Shape 
#   | < Rectangle < Square
#   | < Circle
#   Some test classes which include the mixin:
###
class Shape
  RedisORM.mixinTo @
  area: ()-> @length * @width
  circumfrence: ()-> 2 * (@length + @width)

class Rectangle extends Shape
  constructor: (@length, @width)->

class Square extends Rectangle
  constructor: (@side)-> (super @side, @side)

class Circle extends Shape
  @pi = 3.14
  constructor: (@radius)->

  area: ()-> Circle.pi * @radius *@radius
  circumfrence: ()-> 2 * @Circle.pi * @radius


describe 'redisORM', ->
  ###
  #   instance variables shared by specs
  ###
  @key
  @cool
  @subject

  ###
  #   setup and teardown
  #   start and end with an empty db in a test environment
  ###
  before (done)=>
    @cool = 'super cool'
    materializeRedisClient (err, client)=>
      redisClient = client
      Shape.configureRedisORM client: redisClient
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

  it '@save throws No Id when there is no id', (done)=>
    bad = new Circle
    bad.severity = 'realy, really'
    ex = null
    try
      key = bad.save()
      (expect 'should not reach here').to.equal false
    catch e
      ex = e
    finally
      (expect ex).to.exist
      done()

  it '1-@save adds a key to the db', (done)=>
    good = new Circle
    good.id = 1
    good.severity = @cool
    ex = null
    Circle.find 2, (err, c)=>
      (expect err).not.to.exist
      (expect c).to.not.exist
      redisClient.keys '*', (err, keys)=>
        count = keys.length
        good.save (err, ok)=>
          redisClient.keys '*', (err, keys)=>
            (expect keys.length).to.equal (count+1)
            done()

  it '2-@find returns a model from the db', (done)=>
    Circle.find 1, (err, c)=>
      (expect err).not.to.exist
      (expect c).to.be.ok
      (expect c.severity).to.equal @cool
      done()

  it '3-@destroy removes a key from the db', (done)=>
    Circle.find 1, (err, c)=>
      (expect err).not.to.exist
      (expect c).to.be.ok
      redisClient.keys '*', (err, keys)=>
        count = keys.length
        c.destroy (err, ok)=>
          redisClient.keys '*', (err, keys)=>
            (expect keys.length).to.equal (count-1)
            done()

  # it '@save', (done)=>
  #   r = new Shape
  #   r.id = 2
  #   r.length = 19
  #   r.width = 20
  #   r.origin = {x: 8, y:8 }
  #   r.colors = ['blue', 'green']
  #   r.center = new Shape
  #   r.center.id = 4
  #   r.center.radius = 2

  #   k = r.save()
  #   Shape.find 2, (err, s)->
  #     console.log s
  #     # (expect r.save()).to.equal 2
  #     done()


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
