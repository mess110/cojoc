manaBarTest = ->
  scene = SceneManager.currentScene()

  Helper.orbitControls(engine)

  # scene.card = new Card()
  # scene.card.mesh.position.set 0, 0, -2
  # scene.scene.add scene.card.mesh

  scene.manaBar = new ManaBar()
  scene.manaBar.mesh.position.x = -2
  scene.manaBar.update(3, 8)
  scene.scene.add scene.manaBar.mesh

  scene.doMouseEvent = (event, raycaster) ->
    return unless scene.manaBar?

    console.log scene.manaBar.isHovered(raycaster)

  scene.afterCinematic = (tpf) ->
    return unless scene.manaBar?
