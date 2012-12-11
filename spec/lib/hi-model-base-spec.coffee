describe 'hiModelBase', ->
  ###
  #   instance variables shared by specs
  ###
  @subject = null

  ###
  #   setup and teardown
  #   start and end with an empty db in a test environment
  ###
  # before (done)=> ensureClearRedisTestEnvironment("before Streamer specs:", done)
  # after (done)=> ensureClearRedisTestEnvironment("after Streamer specs:", done)

  it 'exists', (done)=> 
    (expect hiModelBase).to.exist
    done()

  # it 'database is empty', (done)->
  #   Streamer.findAll (err, list)->
  #     (expect err).not.to.exist
  #     (expect list).to.exist
  #     (expect list).to.be.empty
  #     done()

  # it 'save', (done)=>
  #   atts = StreamerFactory.make()
  #   s = new Streamer atts
  #   count = 0
  #   Streamer.findAll (err, listBefore)->
  #     count = listBefore.length if isPresent(listBefore)
  #     s.save()
  #     @savedStreamer = s
  #     Streamer.findAll (err, listAfter)->
  #       (expect listAfter).to.exist
  #       (expect listAfter.length).to.equal count+1
  #       done()

  # it 'find', (done)=>
  #   Streamer.find @savedStreamer.id(), (err, obj)->
  #     (expect err).not.to.exist
  #     (expect obj).to.exist
  #     (expect obj.screenName()).to.equal @savedStreamer.screenName()
  #     (expect obj.oauthAccess().access_token_secret).to.equal @savedStreamer.oauthAccess().access_token_secret
  #     done()

  # it 'destroy', (done)=>
  #   count = 9999
  #   Streamer.findAll (err, listBefore)->
  #     count = listBefore.length if isPresent(listBefore)
  #     @savedStreamer.destroy()
  #     @savedStreamer = null
  #     Streamer.findAll (err, listAfter)->
  #       (expect listAfter).to.exist
  #       (expect listAfter.length).to.equal count-1
  #       done()

  # it 'findAll', (done) =>
  #   count = 0
  #   Streamer.findAll (err, listBefore)->
  #     count = listBefore.length if isPresent(listBefore)
  #     more = 8
  #     addMore = more
  #     newStreamers = []
  #     while addMore--
  #       h = StreamerFactory.make()
  #       s = new Streamer h
  #       s.save()
  #       newStreamers.push s
  #     Streamer.findAll (err, listAfter)->
  #       (expect listAfter).to.exist
  #       (expect listAfter.length).to.equal count + more
  #       s.destroy() for s in newStreamers # clear the newly created streamers
  #       done()

  # describe 'materialize', ->

  #   before (done) =>
  #     @atts = StreamerFactory.make()
  #     @oauth = @atts.oauth_access
  #     delete @atts.oauth_access
  #     @consumerApp = 'streamersApp'
  #     @consumer = TwitterConsumers[@consumerApp]
  #     (expect @consumer).to.be.ok
  #     done()

  #   describe 'new with oauth credentials', ->
  #     before (done) => 
  #       uidString = "00#{@uid}"
  #       Streamer.materialize @atts, @consumerApp, @oauth.token, @oauth.secret, (err, streamer)->
  #         (expect err).to.be.null
  #         (expect streamer).to.be.ok
  #         @streamer = streamer
  #         done()

  #     it 'instance has relevant attributes', (done) =>
  #       @streamer.id().should.equal @atts.id
  #       @streamer.screenName().should.equal @atts.screen_name
  #       @streamer.description().should.equal @atts.description
  #       @streamer.location().should.equal @atts.location
  #       @streamer.language().should.equal @atts.lang
  #       @streamer.followersCount().should.equal @atts.followers_count
  #       @streamer.friendsCount().should.equal @atts.friends_count
  #       @streamer.timeZone().should.equal @atts.time_zone
  #       @streamer.utcOffset().should.equal @atts.utc_offset
  #       done()

  #     it 'intance has oauth credentials including consumer app and access token', (done) =>
  #       oauth = @streamer.oauthAccess()
  #       (expect oauth).to.exist
  #       (expect oauth.consumer_key).to.equal @consumer.key
  #       (expect oauth.consumer_secret).to.equal @consumer.secret
  #       (expect oauth.access_token_key).to.equal @oauth.token
  #       (expect oauth.access_token_secret).to.equal @oauth.secret
  #       done()

  #     it '.toJSON has relevant attributes', (done) =>
  #       jsonValue = @streamer.toJSON()
  #       jsonValue.should.be.a('string')
  #       jsonStreamer = JSON.parse(jsonValue)
  #       jsonStreamer.should.be.an('object')
  #       (expect jsonStreamer.contains @atts).to.be.true # streamer contains all the original atts
  #       (expect @atts.contains jsonStreamer).to.be.false # streamer contains more than the original atts
  #       done()

  #     it '.toEvent has relevant attributes', (done) =>
  #       ev = @streamer.toEvent()
  #       (expect ev.contains @atts).to.be.true # streamer contains all the original atts
  #       (expect @atts.contains ev).to.be.true # streamer contains more than the original atts
  #       done()

  #     it '.toJSON shows oauth_access', (done)=>
  #       jsonValue = @streamer.toJSON()
  #       jsonStreamer = JSON.parse(jsonValue)
  #       oauth = jsonStreamer.oauth_access
  #       (expect oauth).to.exist
  #       (expect oauth.token)
  #       (expect oauth.app).to.equal @consumerApp
  #       (expect oauth.token).to.equal @oauth.token
  #       (expect oauth.secret).to.equal @oauth.secret
  #       done()

  #     it '.toEvent hides oauth_access', (done)=>
  #       ev = @streamer.toEvent()
  #       (expect ev.oauth_access).not.to.exist
  #       done()

  #     it.skip '.emit to socket sends only attributes'
  #     it.skip '.emit to EventMachine sends the instance obj'

  #   describe 'existing', ->
  #     before (done) => 
  #       @savedAtts = StreamerFactory.make()
  #       @consumerApp = 'streamersApp'
  #       @consumer = TwitterConsumers[@consumerApp]
  #       @savedStreamer = new Streamer @savedAtts
  #       @savedStreamer.save done

  #     after (done) => 
  #       @savedStreamer.destroy done

  #     it 'from db with string id ', (done)=>
  #       idString = "00#{@savedAtts.id}"
  #       Streamer.materialize idString, (err, obj)->
  #         (expect err).to.be.falsy
  #         (expect obj).to.be.ok
  #         (expect obj.id() ).to.equal @savedAtts.id
  #         (expect obj.screenName() ).to.equal @savedAtts.screen_name
  #         (expect obj.description() ).to.equal @savedAtts.description
  #         (expect obj.location() ).to.equal @savedAtts.location
  #         (expect obj.language() ).to.equal @savedAtts.lang
  #         (expect obj.followersCount() ).to.equal @savedAtts.followers_count
  #         (expect obj.friendsCount() ).to.equal @savedAtts.friends_count
  #         (expect obj.timeZone() ).to.equal @savedAtts.time_zone
  #         (expect obj.utcOffset() ).to.equal @savedAtts.utc_offset
  #         oauth = obj.oauthAccess()
  #         (expect oauth.consumer_key).to.equal @consumer.key
  #         (expect oauth.consumer_secret).to.equal @consumer.secret
  #         (expect oauth.access_token_key).to.equal @savedAtts.oauth_access.token
  #         (expect oauth.access_token_secret).to.equal @savedAtts.oauth_access.secret
  #         done()

  #     it 'from db with numeric id ', (done)=>
  #       idNumber = parseInt @savedAtts.id, 10
  #       Streamer.materialize idNumber, (err, obj)->
  #         (expect err).to.be.falsy
  #         (expect obj).to.be.ok
  #         (expect obj.id() ).to.equal @savedAtts.id
  #         (expect obj.screenName() ).to.equal @savedAtts.screen_name
  #         (expect obj.description() ).to.equal @savedAtts.description
  #         (expect obj.location() ).to.equal @savedAtts.location
  #         (expect obj.language() ).to.equal @savedAtts.lang
  #         (expect obj.followersCount() ).to.equal @savedAtts.followers_count
  #         (expect obj.friendsCount() ).to.equal @savedAtts.friends_count
  #         (expect obj.timeZone() ).to.equal @savedAtts.time_zone
  #         (expect obj.utcOffset() ).to.equal @savedAtts.utc_offset
  #         oauth = obj.oauthAccess()
  #         (expect oauth.consumer_key).to.equal @consumer.key
  #         (expect oauth.consumer_secret).to.equal @consumer.secret
  #         (expect oauth.access_token_key).to.equal @savedAtts.oauth_access.token
  #         (expect oauth.access_token_secret).to.equal @savedAtts.oauth_access.secret
  #         done()

  # describe.skip 'twitter API', (done) ->

  #   it 'fetchUser', (done) =>
  #   it 'fetchFriends', (done) =>
  #   it 'fetchHomeTimeline', (done) =>
  #   it 'fetchNewTweets', (done) =>
  #   it 'pull', (done) =>

  # describe.skip 'streaming', (done) ->
  #   it 'saveTweets', (done) =>    
  #   it 'startStreaming', (done) =>    
  #   it 'stopStreaming', (done) =>
