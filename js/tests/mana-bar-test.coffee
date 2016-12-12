manaBarTest = ->
  scene = SceneManager.currentScene()

  Helper.orbitControls(engine)

  scene.manaBar = new ManaBar()
  scene.manaBar.mesh.position.x = -2
  scene.manaBar.update(3, 8)
  scene.scene.add scene.manaBar.mesh
