endTurnTest = ->
  scene = SceneManager.currentScene()

  Helper.orbitControls(engine)

  scene.endTurn = new EndTurnButton()
  scene.scene.add scene.endTurn.mesh

  scene.doMouseEvent = (event, raycaster) ->
    scene.endTurn.hover(event, raycaster)
