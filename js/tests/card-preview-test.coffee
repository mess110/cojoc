cardPreviewTest = ->
  Helper.orbitControls(engine)
  scene = SceneManager.currentScene()

  scene.cardPreview = new CardPreview()
  scene.scene.add scene.cardPreview.mesh

  scene.afterCinematic = (tpf) ->

  scene.doKeyboardEvent = (event) ->
    return unless event.type == 'keydown'
    if event.which == 32
      scene.cardPreview.animate(Cards.random().first())
