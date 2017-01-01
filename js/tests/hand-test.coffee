handTest = ->
  # Helper.orbitControls(engine)
  engine.camera.position.set 0, 0, 20

  scene = SceneManager.currentScene()
  allCards = []

  scene.redraw = (count) ->
    scene.drawCard()

  scene.addCard = ->
    card = new Card()
    card.impersonate(Cards.shuffle().first())
    card.mesh.position.set 5, -4, -10
    card.mesh.rotation.set Math.PI / 2, 0, 0
    scene.scene.add card.mesh
    scene.hand.add card
    allCards.push card

  scene.removeCard = ->
    toRemove = scene.hand.cards.first()
    console.log toRemove.indexInHand
    card = scene.hand.remove toRemove
    card.move(
      target:
        x: 5
        y: -4
        z: -10
        rX: Math.PI / 2
        rY: 0
        rZ: 0
    )

  scene.hand = new Hand()
  scene.hand.customPosition(1)
  scene.scene.add scene.hand.mesh
  scene.addCard()
  setTimeout =>
    scene.addCard()
  , 1000
  setTimeout =>
    scene.addCard()
  , 2000

  scene.afterCinematic = (tpf) ->
    scene.hand.tick(tpf)
    for card in allCards
      card.dissolveTick(tpf)

  scene.doMouseEvent = (event, raycaster) ->
    scene.hand.doMouseEvent(event, raycaster)
