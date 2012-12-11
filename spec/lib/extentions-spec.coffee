describe 'Object', ->

  ###
  #   setup and teardown
  ###
  before (done)=> done()
  after (done)=> done()

  it 'exists', (done)=> 
    (expect Object).to.exist
    done()

