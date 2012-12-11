# environment (selects different redis db)
global.node_env ||= process.env.NODE_ENV || global.localEnvironment || 'development'

# module
module.exports = require './hi-model-base'
