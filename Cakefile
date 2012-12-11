{exec} = require 'child_process'

fmt = 'spec'

task 'spec', 'Run the specs', ->
  exec "./node_modules/.bin/mocha -R #{fmt} --require spec/spec-helper --colors spec/lib/*-spec.coffee", (err, stdout, stderr) ->
    console.log stdout if stdout
    console.log stderr if stderr
    throw err if err

task 'test', 'Run the specs', -> invoke 'spec'
