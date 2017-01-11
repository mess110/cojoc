class CardsScene extends BaseScene
  init: (options) ->
    totalCards = [].concat(Cards)
    while totalCards.size() % 3 != 0
      totalCards.push {}

    @cards = new CyclicArray(totalCards)
    @cards.index = -1

    @card1 = new Card()
    @card1.mesh.position.x -= 4
    @scene.add @card1.mesh

    @card2 = new Card()
    @scene.add @card2.mesh

    @card3 = new Card()
    @card3.mesh.position.x += 4
    @scene.add @card3.mesh

    @page = 0
    @text = new BigText('center')
    @text.mesh.position.set 0, -4.5, 0
    @scene.add @text.mesh

    @next()

  tick: (tpf) ->

  doKeyboardEvent: (event) ->

  doMouseEvent: (event, raycaster) ->

  next: ->
    for card in [@card1, @card2, @card3]
      tmp = @cards.next()
      if tmp.key?
        card.impersonate(tmp)
        card.setOpacity(1)
      else
        card.setOpacity(0)

    text = "#{(@cards.index + 1) / 3} / #{@cards.items.size() / 3}"
    @text.setText(text)

  prev: ->
    @cards.prev()
    @cards.prev()
    @cards.prev()

    @cards.prev()
    @cards.prev()
    @cards.prev()

    @next()
