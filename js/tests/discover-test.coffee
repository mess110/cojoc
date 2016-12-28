discoverTest = ->
  scene = SceneManager.currentScene()
  allCards = []

  scene.addCard = ->
    card = new Card()
    card.minion(Cards.shuffle().first())
    card.mesh.position.set 5, -4, -10
    card.mesh.rotation.set Math.PI / 2, 0, 0
    scene.scene.add card.mesh
    scene.discover.add card
    allCards.push card

  scene.removeCard = ->
    toRemove = scene.discover.cards.first()
    card = scene.discover.remove toRemove
    card.move(
      target:
        x: 5
        y: -4
        z: -10
        rX: Math.PI / 2
        rY: 0
        rZ: 0
    )

  scene.discover = new Discover()
  scene.scene.add scene.discover.mesh
  scene.addCard()
  scene.addCard()
  scene.addCard()

  scene.afterCinematic = (tpf) ->
    scene.discover.tick(tpf)
    for card in allCards
      card.dissolveTick(tpf)

  scene.doMouseEvent = (event, raycaster) ->
    scene.discover.doMouseEvent(event, raycaster)
