manaBarTest = ->
  Helper.orbitControls(engine)
  engine.camera.position.z = 20
  scene = SceneManager.currentScene()

  # scene.card = new Card()
  # scene.card.mesh.position.set 0, 0, -2
  # scene.scene.add scene.card.mesh

  scene.manaBar = new ManaBar()
  scene.manaBar.customPosition(Constants.Position.Player.SELF)
  scene.manaBar.update(3, 8)
  scene.manaBar.toggleWireframe()
  scene.scene.add scene.manaBar.mesh

  scene.doMouseEvent = (event, raycaster) ->
    return unless scene.manaBar?

    scene.manaBar.doMouseEvent(event, raycaster)

  scene.afterCinematic = (tpf) ->
    return unless scene.manaBar?
