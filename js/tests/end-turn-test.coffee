endTurnTest = ->
  Helper.orbitControls(engine)
  scene = SceneManager.currentScene()

  scene.endTurn = new EndTurnButton()
  scene.endTurn.mesh.position.set 0, 2, 0
  # scene.endTurn.toggleWireframe()
  scene.scene.add scene.endTurn.mesh

  scene.toggleButton = new ToggleButton().discover()
  scene.toggleButton.mesh.scale.set 0.3, 0.3, 0.3
  scene.toggleButton.mesh.position.set 0, -2, 0
  # scene.toggleButton.toggleWireframe()
  scene.scene.add scene.toggleButton.mesh
  scene.toggleButton.setFaceUp(false)

  scene.finishedButton = new FinishedButton()
  scene.finishedButton.mesh.position.set 3, -1, 0
  scene.finishedButton.animate()
  scene.finishedButton.setText('Victorie')
  scene.scene.add scene.finishedButton.mesh

  scene.doMouseEvent = (event, raycaster) ->
    scene.endTurn.doMouseEvent(event, raycaster, true)
    scene.toggleButton.doMouseEvent(event, raycaster, true)

  scene.afterCinematic = (tpf) ->
    scene.endTurn.tick(tpf)
