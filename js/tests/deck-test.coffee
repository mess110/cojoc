deckTest = ->
  Helper.orbitControls(engine)
  scene = SceneManager.currentScene()

  scene.deck = new Deck(5)
  scene.scene.add scene.deck.mesh

  scene.doMouseEvent = (event, raycaster) ->
    scene.deck.doMouseEvent(event, raycaster)

  scene.doKeyboardEvent = (event) ->
    if event.type == 'keyup'
      card = scene.deck.drawCard(scene.scene)
      console.log 'no more cards' unless card?
