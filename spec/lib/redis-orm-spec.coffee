testDBNum = ORM_ENV.redis.dbNum
redisClient = null


###
#   Shape 
#   | < Rectangle < Square
#   | < Circle
#   Some test classes which include the mixin:
###
global.Shape = class Shape
  RedisORM.mixinTo @
  area: ()-> @length * @width
  circumfrence: ()-> 2 * (@length + @width)

global.Rectangle = class Rectangle extends Shape
  constructor: (@id, @length, @width)->

global.Square = class Square extends Rectangle
  constructor: (@id, @side)-> (super @side, @side)

global.Circle = class Circle extends Shape
  @pi = 3.14
  constructor: (@id, @radius)->

  area: ()-> Circle.pi * @radius *@radius
  circumfrence: ()-> 2 * @Circle.pi * @radius


describe 'redisORM', ->
  ###
  #   instance variables shared by specs
  ###
  @id
  @idChild
  @key
  @cool
  @subject

  ###
  #   setup and teardown
  #   start and end with an empty db in a test environment
  ###
  before (done)=>
    @id = 1
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
    good = new Circle @id, 5
    good.severity = @cool
    ex = null
    Circle.find @id, (err, noobj)=>
      (expect err).not.to.exist
      (expect noobj).to.not.exist
      redisClient.keys '*', (err, keys)=>
        count = keys.length
        good.save (err, ok)=>
          redisClient.keys '*', (err, keys)=>
            (expect keys.length).to.equal (count+1)
            done()

  it '2-@find returns a model from the db', (done)=>
    Circle.find @id, (err, obj)=>
      (expect err).not.to.exist
      (expect obj).to.be.ok
      (expect obj.severity).to.equal @cool
      done()

  it '3-@destroy removes a key from the db', (done)=>
    Circle.find @id, (err, c)=>
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

  it '@save simple model with primitives', (done)=>
    @id = 'r1'
    Rectangle.find @id, (err, noobj)=>
      (expect err).not.to.exist
      (expect noobj).to.be.null # verify that r1ID doesn't exist in DB
      l = 8
      w = 10
      r = new Rectangle @id, l, w
      r.save (err, ok)=>
        Rectangle.find @id, (err, obj)=>
          (expect err).not.to.exist
          (expect obj).to.be.ok
          (expect obj.length).to.equal l
          (expect obj.width).to.equal w
          (expect obj.area()).to.equal l*w
          obj.destroy()
          done()

  it '@save simple model with arrays', (done)=>
    @id = 'r2'
    l = 2 
    w = 3
    colors = ['red', 'blue', 'green']

    r = new Rectangle @id, l, w
    r.colors = colors
    r.save (err, ok)=>
      Rectangle.find @id, (err, obj)=>
        (expect err).not.to.exist
        (expect obj).to.be.ok
        (expect obj.colors).to.be.ok
        (expect obj.colors.length).to.equal colors.length
        (expect obj.colors[idx]).to.equal color for color, idx in colors
        obj.destroy()
        done()

  it '@save simple model with hashes', (done)=>
    @id = 'r3'
    l = 3
    w = 4
    x = 22
    y = 88
    z = 33

    origin = { x:x, y:y, z:z }

    r = new Rectangle @id, l, w
    r.origin = origin
    r.save (err, ok)=>
      Rectangle.find @id, (err, obj)=>
        (expect err).not.to.exist
        (expect obj).to.be.ok
        (expect obj.area()).to.equal l*w
        (expect obj.origin).to.be.ok
        (expect obj.origin[key]).to.equal val for key, val of origin
        (expect obj.origin.x).to.equal x
        (expect obj.origin.y).to.equal y
        (expect obj.origin.z).to.equal z
        obj.destroy()
        done()

  it '@save complex model with refs', (done)=>
    @id = 'r4'
    @idChild = @id+@id
    Rectangle.find @id, (err, noobj)=>
      (expect err).not.to.exist
      (expect noobj).to.be.null # verify that r1ID doesn't exist in DB
      Rectangle.find @idChild, (err, noobj)=>
        (expect err).not.to.exist
        (expect noobj).to.be.null # verify that r1ID doesn't exist in DB
        parentL = 8
        parentW = 10
        parent = new Rectangle @id, parentL, parentW

        childL = 2
        childW = 3
        child = new Rectangle @idChild, childL, childW

        parent.button = child
        parent.save (err, ok)=>
          Rectangle.find @id, (err, objParent)=>
            (expect err).not.to.exist
            (expect objParent).to.be.ok
            console.log "---parent", objParent
            (expect objParent.area()).to.equal parentL * parentW
            (expect objParent.button).to.exist
            (expect objParent.button.area()).to.equal childL * childW
            parent.destroy()
            child.destroy()
            done()

          # console.log "---- finding ", @idChild
          # Rectangle.find @idChild, (err, objChild)=>
          #   (expect err).not.to.exist
          #   (expect objChild).to.be.ok
          #   console.log "---- child", objChild            
          #   (expect objChild.area()).to.equal childL * childW
          #   console.log "---- finding ", @id

  it '@save complex model with refs mixed into arrays'
  it '@save complex model with refs mixed into hashes'

  it '@save complex model with deep refs'
  it '@save complex model with deep refs mixed into arrays'
  it '@save complex model with deep refs mixed into hashes'

  it '@save handles cycle'

  ###
  #   Public Class methods
  ###
  it '@@materialize new instance'
  it '@@materialize existing instance'

  it '@@findAll'

  ###
  #   model representations
  ###
  it '@toHash'
  it '@toJSON'
  it '@toEvent'
  it '@emitTo'
