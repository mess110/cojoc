assert = (condition, message) ->
  if !condition
    message = message or 'Assertion failed'
    if typeof Error != 'undefined'
      throw new Error(message)
    throw message
    # Fallback
  console.log '.'
  return

scenify = (func) ->
  Engine3D.scenify(engine, func)

scene = () ->
  SceneManager.currentScene()

Helper.fade(type: 'in', duration: 0)
config = Config.get()
config.transparentBackground = true
config.toggleStats()

engine = new Engine3D()
engine.setWidthHeight(window.innerWidth / 2, window.innerHeight)
scenify(cubeTest)
engine.render()
