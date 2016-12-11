Helper.fade(type: 'in', duration: 0)

Utils.FADE_DEFAULT_DURATION = 500

Persist.PREFIX = Constants.Storage.PREFIX
Persist.default(Constants.Storage.SOUND, false)
Persist.default(Constants.Storage.BOT, false)
Persist.default(Constants.Storage.VOLUME, 0.75)

config = Config.get()
config.fillWindow()
config.transparentBackground = true
config.debug = false

nm = NetworkManager.get()
nm.connect()

nm.on 'error', (data) ->
  scope = getScope()
  scope.toastr(data)
  if data? && data.code?
    scope.home()
  else
    scope.game.connected = false

nm.on 'connected', (data) ->
  scope = getScope()
  scope.game.connected = true
  scope.start()

nm.on 'startGame', (data) ->
  scope = getScope()
  scope.game(data)

nm.on 'disconnect', (data) ->

engine = new Engine3D()
# Helper.fancyShadows(engine.renderer)

gameScene = new GameScene()
engine.addScene(gameScene)

menuScene = new MenuScene()
engine.addScene(menuScene)

cardsScene = new CardsScene()
engine.addScene(cardsScene)

Engine3D.scenify(engine, ->
  document.getElementById("loading").style.opacity = 0
  scope = getScope()
  scope.game.loaded = true
  scope.start()

  SoundManager.volumeAll(Persist.get(Constants.Storage.VOLUME))
  if SoundManager.get().has('prologue') and Persist.get(Constants.Storage.SOUND) == true
    SoundManager.get().play('prologue')
)

engine.render()
