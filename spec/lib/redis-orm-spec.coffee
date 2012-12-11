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
    (expect redisORM).to.exist
    done()

  ###
  #   Public Instance methods
  ###
  it '@save'
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
  