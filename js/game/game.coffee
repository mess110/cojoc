Helper.fade(type: 'in', duration: 0)

config = Config.get()
config.fillWindow()
config.transparentBackground = true
# config.toggleStats()

LoadingScene.prototype.preStart = ->

nm = NetworkManager.get()
nm.connect()

nm.on 'connected', (data) ->
  console.log data

nm.on 'join', (data) ->

nm.on 'disconnect', (data) ->
  gameScene.disconnect(data)

engine = new Engine3D()
# engine.setClearColor(0x000000, 0)

class GameScene extends BaseScene
  init: (options) ->

  tick: (tpf) ->

  doKeyboardEvent: (event) ->

  doMouseEvent: (event, raycaster) ->

Engine3D.scenify(engine, ->
)

engine.render()
