fs = require 'fs'

{print} = require 'sys'
{exec}  = require 'child_process'
{spawn} = require 'child_process'


fmt = 'spec'


build = (watch, callback) ->
  cmdLineArgs = ['-c', '-o', 'lib', 'coffee']
  cmdLineArgs.unshift '-w' if watch?
  coffee = spawn 'coffee', cmdLineArgs
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) =>
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?() if code is 0

task 'build', 'Build lib/ from coffee/', ->
  build()

task 'build:watch', 'Watch coffee/ for changes and build into lib/', ->
  build(true)

task 'spec', 'Run the specs', ->
  exec "./node_modules/.bin/mocha -R #{fmt} --require spec/spec-helper --colors spec/lib/*-spec.coffee", (err, stdout, stderr) ->
    console.log stdout if stdout
    console.log stderr if stderr
    console.log err if err

task 'spec:watch', 'Run the specs whenever the code changes', ->
  mocha = spawn './node_modules/.bin/mocha', ['-w', '-R', 'min', '--compilers', 'coffee:coffee-script', '--require', 'spec/spec-helper', '--colors', 'spec/lib'], { cwd: process.cwd(), env: process.env }
  mocha.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  mocha.stdout.on 'data', (data) =>
    print data.toString()
  mocha.on 'exit', (code) ->
    callback?() if code is 0

task 'test', 'Run the specs', -> invoke 'spec'

