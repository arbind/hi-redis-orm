REDIS = require 'redis-url'

# hiRedisORM = require './hiRedisORM'

class hiModelBase
  @configuration:
    redisURL: process.env.REDIS_URL || process.env.REDISTOGO_URL || 'redis://127.0.0.1:6379/'
    dbNumber:
      switch node_env
        when  'production' then 0
        when  'development' then 1
        when  'test' then 2
        else 3

# make this base class available globally
module.exports = global.hiModelBase = hiModelBase
