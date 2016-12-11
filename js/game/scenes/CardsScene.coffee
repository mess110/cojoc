class CardsScene extends BaseScene
  init: (options) ->
    @cards = new CyclicArray(Cards)
    @cards.index = -1

    @card1 = new Card(@cards.next())
    @card1.mesh.position.x -= 4
    @scene.add @card1.mesh

    @card2 = new Card(@cards.next())
    @scene.add @card2.mesh

    @card3 = new Card(@cards.next())
    @card3.mesh.position.x += 4
    @scene.add @card3.mesh

  tick: (tpf) ->

  doKeyboardEvent: (event) ->

  doMouseEvent: (event, raycaster) ->

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
