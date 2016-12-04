Helper.fade(type: 'in', duration: 0)

Utils.FADE_DEFAULT_DURATION = 250

config = Config.get()
config.fillWindow()
config.transparentBackground = true
# config.toggleStats()

LoadingScene.prototype.preStart = ->

nm = NetworkManager.get()
nm.connect()

nm.on 'error', (data) ->
  scope = getScope()
  scope.game.connected = false

nm.on 'connected', (data) ->
  scope = getScope()
  scope.game.connected = true
  scope.start()

nm.on 'join', (data) ->

nm.on 'disconnect', (data) ->
  gameScene.disconnect(data)

engine = new Engine3D()
Helper.fancyShadows(engine.renderer)

class GameScene extends BaseScene
  init: (options) ->

  tick: (tpf) ->

  doKeyboardEvent: (event) ->

  doMouseEvent: (event, raycaster) ->

class MenuScene extends BaseScene
  init: (options) ->
    @landingModel = new LandingModel()
    @scene.add @landingModel.model

    @scene.add Helper.ambientLight()
    @scene.add Helper.ambientLight()

    light = new (THREE.SpotLight)
    light.position.copy new THREE.Vector3(0, 0, 10)
    light.intensity = 1.25
    light.lookAt(@landingModel.mesh)
    @scene.add light

  tick: (tpf) ->
    @landingModel.tick(tpf)

  doKeyboardEvent: (event) ->

  doMouseEvent: (event, raycaster) ->

gameScene = new GameScene()
engine.addScene(gameScene)

menuScene = new MenuScene()
engine.addScene(menuScene)

Engine3D.scenify(engine, ->
  document.getElementById("loading").style.opacity = 0
  scope = getScope()
  scope.game.loaded = true
  scope.start()
)

engine.render()
