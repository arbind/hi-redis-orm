describe 'String', ->

  ###
  #   setup and teardown
  ###
  before (done)=> done()
  after (done)=> done()

  it 'exists', (done)=> 
    (expect String).to.exist
    done()

  it '@upcase'
  it '@trim'
  it '@ltrim'
  it '@rtrim'
  it '@tokens'
  it '@toCamel'
  it '@toDash'
  it '@toUnderscore'
  it '@toTitleCase'
  it '@toClassName'
