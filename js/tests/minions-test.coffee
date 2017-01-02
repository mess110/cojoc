minionsTest = ->
  # Helper.orbitControls(engine)
  scene = SceneManager.currentScene()
  allCards = []

  scene.redraw = (count) ->
    scene.drawCard()

  scene.addCard = ->
    card = new Card()
    card.minion(Cards.shuffle().first())
    card.mesh.position.set 5, -4, -10
    card.mesh.rotation.set Math.PI / 2, 0, 0
    scene.scene.add card.mesh
    scene.minions.add card
    allCards.push card

  scene.removeCard = ->
    toRemove = scene.minions.cards.first()
    card = scene.minions.remove toRemove
    card.move(
      target:
        x: 5
        y: -4
        z: -10
        rX: Math.PI / 2
        rY: 0
        rZ: 0
    )

  scene.minions = new Minions()
  scene.minions.customPosition(Constants.Position.Player.OPPONENT)
  scene.scene.add scene.minions.mesh
  scene.addCard()
  scene.addCard()
  scene.addCard()
  scene.addCard()
  scene.addCard()
  setTimeout =>
    scene.addCard()
  , 1000
  setTimeout =>
    scene.addCard()
  , 2000

  scene.afterCinematic = (tpf) ->
    scene.minions.tick(tpf)
    for card in allCards
      card.dissolveTick(tpf)

  scene.doMouseEvent = (event, raycaster) ->
    scene.minions.doMouseEvent(event, raycaster)
