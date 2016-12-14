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
    scene.hand.add card

  scene.removeCard = ->
    toRemove = scene.hand.cards.first()
    console.log toRemove.indexInHand
    card = scene.hand.remove toRemove
    card.move(
      { x: 5, y: -4, z: -10 }
      { x: Math.PI / 2, 0, 0 }
    )

  scene.hand = new Hand()
  scene.hand.mesh.position.y = -3
  scene.scene.add scene.hand.mesh
  scene.addCard()
  scene.addCard()
  scene.addCard()

  scene.afterCinematic = (tpf) ->
    scene.hand.tick(tpf)

  scene.doMouseEvent = (event, raycaster) ->
    scene.hand.doMouseEvent(event, raycaster)
