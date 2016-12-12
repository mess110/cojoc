class CardsScene extends BaseScene
  init: (options) ->
    @cards = new CyclicArray(Cards)
    @cards.index = -1

    @card1 = new Card()
    @card1.mesh.position.x -= 4
    @scene.add @card1.mesh

    @card2 = new Card()
    @scene.add @card2.mesh

    @card3 = new Card()
    @card3.mesh.position.x += 4
    @scene.add @card3.mesh

    @next()

  tick: (tpf) ->

  doKeyboardEvent: (event) ->

  doMouseEvent: (event, raycaster) ->
    if event.type == 'mousemove'
      for card in [@card1, @card2, @card3]
        if card.isHovered(raycaster)
          card.glow.green()
        else
          card.glow.none()

  next: ->
    @card1.impersonate(@cards.next())
    @card2.impersonate(@cards.next())
    @card3.impersonate(@cards.next())

  prev: ->
    @cards.prev()
    @cards.prev()

    @card1.impersonate(@cards.next())
    @card2.impersonate(@cards.next())
    @card3.impersonate(@cards.next())
