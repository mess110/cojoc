assert = (condition, message) ->
  if !condition
    message = message or 'Assertion failed'
    if typeof Error != 'undefined'
      throw new Error(message)
    throw message
  console.log '.'
  return

scenify = (funcName) ->
  Persist.set('lastTest', funcName)
  if SceneManager.get().currentSceneIndex? and SceneManager.currentScene().clearTests?
    SceneManager.currentScene().clearTests()
  Engine3D.scenify(engine, eval(funcName))

scene = () ->
  SceneManager.currentScene()

Helper.fade(type: 'in', duration: 0)
config = Config.get()
config.fillWindow()
config.transparentBackground = true
# config.debug = true
config.toggleStats()
Persist.default('lastTest', 'cubeTest')

engine = new Engine3D()
# engine.setWidthHeight(window.innerWidth / 3 * 2, window.innerHeight)
scenify(Persist.get('lastTest'))
engine.render()
