panelTest = ->
  Helper.orbitControls(engine)
  scene = SceneManager.currentScene()

  scene.panel = new Panel()
  scene.scene.add scene.panel.mesh
