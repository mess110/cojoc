turnNotificationTest = ->
  scene = SceneManager.currentScene()

  Helper.orbitControls(engine)

  scene.turnNotification = new TurnNotification()
  scene.scene.add scene.turnNotification.mesh

  scene.afterCinematic = (tpf) ->
    scene.turnNotification.animate()
