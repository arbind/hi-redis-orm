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
  circumfrence:()-> 2 * (@length + @width)

global.Rectangle = class Rectangle extends Shape
  constructor: (@id, @length, @width)->

global.Square = class Square extends Rectangle
  constructor: (@id, @side)-> (super @side, @side)

global.Circle = class Circle extends Shape
  @pi = 3.14
  constructor: (@id, @radius)->

  area: ()-> Circle.pi * @radius *@radius
  circumfrence: ()-> 2 * @Circle.pi * @radius


global.Container = class Container
  RedisORM.mixinTo @
  constructor: (@id)->

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
      Container.configureRedisORM client: redisClient
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
            # console.log "---parent", objParent
            (expect objParent.area()).to.equal parentL * parentW
            (expect objParent.button).to.exist
            (expect objParent.button.area()).to.equal childL * childW
            parent.destroy()
            child.destroy()
            done()

  it '@save complex model with refs mixed into arrays', (done)=>
    @id = 'r5'
    @cid = 'c1'
    boxL = 18
    boxW = 20
    box = new Rectangle @id, boxL, boxW

    bucket = new Container @cid
    bucket.list = []
    bucket.list.push box
    bucket.save (err, ok) =>
      Container.find @cid, (err, cntnr)=>
        # console.log cntnr
        (expect err).not.to.exist
        (expect cntnr).to.be.ok
        (expect cntnr.list).to.be.ok
        (expect cntnr.list.length).to.equal 1
        b = cntnr.list[0]

        (expect b.area()).to.equal boxL * boxW
        b.destroy()
        cntnr.destroy()
        done()

  it '@save complex model with refs mixed into hashes', (done)=>
    @id = 'r6'
    @cid = 'c2'
    boxL = 12
    boxW = 14
    box = new Rectangle @id, boxL, boxW

    bucket = new Container @cid
    bucket.hash = {}
    bucket.hash.box = box
    bucket.save (err, ok) =>
      Container.find @cid, (err, cntnr)=>
        # console.log cntnr
        (expect err).not.to.exist
        (expect cntnr).to.be.ok
        (expect cntnr.hash.box).be.ok
        b = cntnr.hash.box

        (expect b.area()).to.equal boxL * boxW
        b.destroy()
        cntnr.destroy()
        done()    

  it '@save complex model with deep refs mixed into arrays', (done)=>
    @id = 'r5'
    @cid = 'c1'

    ###
    Prepare 3 models and place them deep into an array hierarchy:
    ContainerModel > list > sublist > BoxModel > list > sublist > CircleModel
    ###

    #prepare a top-level bucket to put everything in
    bucket = new Container @cid 
    bucketList = [0,1,2,4,5] # prepare a bucket list
    bucket.list = bucketList # set the bucket list
    bucketSubList = ['a', 'b', 'c', 'd'] # prepare a bucket subList
    idxSubList = 3 # insert a bucketSubList into the bucket list
    bucketList.splice(idxSubList, 0, bucketSubList)
    boxL = 18 
    boxW = 20 # prepare a box to put deep into the sublist
    box = new Rectangle @id, boxL, boxW    
    idxBox = 2 # insert the box into the bucket subList
    bucketSubList.splice(idxBox, 0, box)

    # put a circle into deep into a sublis in the box
    boxList = [0,2,3,4,5] # prepare a box list
    box.list = boxList # set the box list
    boxSubList = ['l', 'm', 'n', 'o', 'p', 'q', 'r'] # prepare a bucket subList
    idxBoxSubList = 1 # insert a boxSubList into the box list
    boxList.splice(idxBoxSubList, 0, boxSubList)
    circleID = 'o8'
    circleR = 8 # prepare a circle to put deep into the box
    circle = new Circle circleID, circleR
    idxCircle = 4 # insert the box into the bucket subList
    boxSubList.splice(idxCircle, 0, circle)


    bucket.save (err, ok) =>
      Container.find @cid, (err, cntnr)=>
        (expect err).not.to.exist
        (expect cntnr).to.be.ok
        (expect cntnr.list).to.be.ok
        (expect cntnr.list.length).to.equal 6
        embeddedList = cntnr.list[idxSubList]
        (expect embeddedList).to.be.ok
        b = embeddedList[idxBox]
        (expect b).to.be.ok
        (expect b.area()).to.equal boxL * boxW

        embeddedList = b.list[idxBoxSubList]
        (expect embeddedList).to.be.ok
        c = embeddedList[idxCircle]
        (expect c).to.be.ok
        (expect c.area()).to.equal Circle.pi * circleR * circleR

        cntnr.destroy()
        b.destroy()
        c.destroy()
        done()

  it '@save complex model with deep refs mixed into hashes', (done)=>
    @id = 'r5'
    @cid = 'c1'

    ###
    Prepare 3 models and place them deep into an array hierarchy:
    ContainerModel > list > sublist > BoxModel > list > sublist > CircleModel
    ###

    #prepare a top-level bucket to put everything in
    bucket = new Container @cid 
    bucket.hash = {a:1, b:2} # set the bucket hash
    bucket.hash.subHash = {c:3, d:4}
    boxL = 9
    boxW = 10 # prepare a box to put deep into the sublist
    box = new Rectangle @id, boxL, boxW    
    bucket.hash.subHash.box = box

    # put a circle into deep into a sublis in the box
    box.hash = {e:5, g:6} # set the box list
    box.hash.hashLevel2 = {h:7, i:8}
    circleID = 'c0'
    circleR = 20 # prepare a circle to put deep into the box
    circle = new Circle circleID, circleR
    box.hash.hashLevel2.circle = circle

    bucket.save (err, ok) =>
      Container.find @cid, (err, cntnr)=>
        (expect err).not.to.exist
        (expect cntnr).to.be.ok
        (expect cntnr.hash).to.be.ok
        (expect cntnr.hash.a).to.equal 1
        (expect cntnr.hash.b).to.equal 2
        embeddedHash = cntnr.hash.subHash
        (expect embeddedHash).to.be.ok
        (expect embeddedHash.c).to.to.equal 3
        (expect embeddedHash.d).to.to.equal 4
        (expect embeddedHash.e).to.to.be.undefined
        b = embeddedHash.box
        (expect b).to.be.ok
        (expect b.area()).to.equal boxL * boxW

        (expect b.hash).to.be.ok
        (expect b.hash.e).to.be.equal 5
        (expect b.hash.g).to.be.equal 6
        embeddedHash = b.hash.hashLevel2
        (expect embeddedHash.h).to.to.equal 7
        (expect embeddedHash.i).to.to.equal 8
        (expect embeddedHash).to.be.ok
        c = embeddedHash.circle
        (expect c).to.be.ok
        (expect c.area()).to.equal  Circle.pi * circleR * circleR

        cntnr.destroy()
        b.destroy()
        c.destroy()
        done()

  it '@save handles cycle'

  ###
  #   Public Class methods
  ###
  it '@@materialize new instance', (done)=>
    @id = 55
    @cool = 'super cool'
    circleR = 55
    hash = {id: @id, radius:circleR, severity: @cool }
    Circle.materialize hash, (err, c)=>
      (expect err).not.to.exist
      (expect c).to.exist
      (expect c.radius).to.equal circleR
      (expect c.severity).to.equal @cool
      Circle.find @id, (err, noobj)=>
        (expect err).not.to.exist
        (expect noobj).to.not.exist
        done()

  it '@@materialize existing instance', (done)=>
    @id = 77
    @cool = 'super nice'
    circleR = 77
    circle = new Circle
    hash = {id: @id, radius:circleR, severity: @cool }
    circle.initializeFields hash
    circle.save (err, ok) =>
      Circle.materialize @id, (err, c)=>
        (expect err).not.to.exist
        (expect c).to.exist
        (expect c.radius).to.equal circleR
        (expect c.severity).to.equal @cool
        c.destroy()
        done()

  it '@@findAll'

  ###
  #   model representations
  ###
  it '@toHash'
  it '@toJSON'
  it '@toEvent'
  it '@emitTo'
