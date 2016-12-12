handTest = ->
  # Helper.orbitControls(engine)
  scene = SceneManager.currentScene()

  scene.redraw = (count) ->
    scene.drawCard()

  scene.addCard = ->
    card = new Card()
    card.impersonate(Cards.shuffle().first())
    card.mesh.position.set 5, -4, -10
    card.mesh.rotation.set Math.PI / 2, 0, 0
    scene.scene.add card.mesh
    scene.deck.add card

  scene.removeCard = ->
    card = scene.deck.remove scene.deck.cards.first()
    card.move(
      { x: 5, y: -4, z: -10 }
      { x: Math.PI / 2, 0, 0 }
    )

  scene.deck = new Deck()
  scene.scene.add scene.deck.mesh
  scene.addCard()
  scene.addCard()
  scene.addCard()

  scene.afterCinematic = (tpf) ->
    scene.deck.tick(tpf)

  scene.doMouseEvent = (event, raycaster) ->
    scene.deck.doMouseEvent(event, raycaster)
