global.node_env ||= process.env.NODE_ENV || global.localEnvironment || 'development'

global.ALL_ORM_ENV_SETTINGS  = 
  production:
    redis:
      dbNum: 0
  development:
    redis:
      dbNum: 1
  test:
    redis:
      dbNum: 2

global.ORM_ENV = ALL_ORM_ENV_SETTINGS[node_env]
