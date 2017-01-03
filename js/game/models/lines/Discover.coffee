class Discover extends BaseLine
  constructor: ->
    super()

    @box = new THREE.Mesh(new THREE.BoxGeometry(6, 2, 0.1), @_boxMaterial())
    @mesh.add @box

    @viewingBoard = false

    @text = new CojocText('center')
    @text.mesh.position.set 3.2, 2, 0
    @text.setText('Ascunde')
    @mesh.add @text.mesh

    @curve = new DiscoverCurve()

  tick: (tpf) ->
    # this prob needs a better implementation. move it to something which
    # doesn't happen at every tick
    return unless @mine
    currScene = SceneManager.currentScene()
    if @cards.size() == 3 and currScene.game?
      card = currScene.game.referee.findCard(@cards.first().id)
      isHoldingNonHeroes = card.type != Constants.CardType.HERO
    @text.setVisible(isHoldingNonHeroes or false)

  _moveInPosition: () ->
    for card in @cards
      point = @getPoint(card)

      card.move(
        target:
          x: point.x
          y: point.y
          z: point.z
          rX: @mesh.rotation.x
          rY: @mesh.rotation.y
          rZ: @mesh.rotation.z
        duration: 400
      )

  _doMouseUp: (raycaster, pos) ->
    return unless @selectedCard?
    return if @viewingBoard
    SceneManager.currentScene()._emit(
      type: 'gameInput'
      action: Constants.Input.SELECT_CARD
      cardId: @selectedCard.id
    )

  _doAfterMouseEvent: (event, raycaster, pos) ->
    if @text.isHovered(raycaster) and event.type == 'mouseup'
      @viewingBoard = !@viewingBoard
      if @viewingBoard
        @text.setText('Arată')
      else
        @text.setText('Ascunde')
      for card in @cards
        card.mesh.visible = !@viewingBoard

  _doChangeSelected: (newSelected, oldSelected, raycaster, pos) ->

  customPosition: (i) ->
    switch i
      when Constants.Position.Player.SELF
        @mine = true
        @mesh.position.set 0, 0, 12
        @mesh.rotation.set 0, 0, 0
      when Constants.Position.Player.OPPONENT
        @mine = false
        @mesh.position.set 0, 4, 6
        @mesh.rotation.set 0, Math.PI , 0
      else
        throw "invalid customPosition #{i}"
