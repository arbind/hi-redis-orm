global.localEnvironment = 'test' 

// default redis url and client
global.redisURL=  process.env.REDIS_URL || process.env.REDISTOGO_URL || 'redis://127.0.0.1:6379/'

require('coffee-script')  // switch to coffee-script
require('../index')       // load this lib
require ('./test-env')    // setup an env for testing
