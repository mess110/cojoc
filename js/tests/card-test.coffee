cubeTest = ->
  Helper.orbitControls(engine)
  scene = SceneManager.currentScene()

  scene.card = new Card(Cards.first())
  scene.scene.add scene.card.mesh

  scene.afterCinematic = (tpf) ->
    scene.card.dissolveTick(tpf)
