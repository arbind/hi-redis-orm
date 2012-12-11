describe 'hiModelBase', ->
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
    (expect hiModelBase).to.exist
    done()
