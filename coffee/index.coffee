global.REDIS = (require 'redis-url')

require './environment'
require './extentions'
require './utils'

module.exports = require './hi-model-base'
