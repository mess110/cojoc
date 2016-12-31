endTurnTest = ->
  # Helper.orbitControls(engine)
  scene = SceneManager.currentScene()

  scene.endTurn = new EndTurnButton()
  scene.scene.add scene.endTurn.mesh

  scene.doMouseEvent = (event, raycaster) ->
    scene.endTurn.doMouseEvent(event, raycaster)

  scene.afterCinematic = (tpf) ->
    scene.endTurn.tick(tpf)
