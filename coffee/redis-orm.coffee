class RedisORM extends Mixin

  @addTheseToClass:
    find: (info)->
    XYZ: 'statix'

  @addTheseToInstance:
    save: ()->
    data: {a:2}

global.RedisORM = RedisORM