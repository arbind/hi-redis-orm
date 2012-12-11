describe 'Object', ->

  ###
  #   setup and teardown
  ###
  before (done)=> done()
  after (done)=> done()

  it 'exists', (done)=> 
    (expect Object).to.exist
    done()

  it 'isPresent'
  it 'isEmpty'
  it 'isString'
  it 'isNumber'

  it 'merge'

  it '@inject'
  it '@keys'
  it '@isHash'
  it '@contains'
