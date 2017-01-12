class Discover extends BaseLine
  constructor: ->
    super()

    @box = new THREE.Mesh(new THREE.BoxGeometry(6, 2, 0.1), @_boxMaterial())
    @mesh.add @box

    @viewingBoard = false
    @flipGlow = true

    @curve = new DiscoverCurve()

    @toggleButton = new ToggleButton().discover()
    @toggleButton.mesh.position.set 3.2, 2.6, 0
    @mesh.add @toggleButton.mesh

    @panel = new ChooseCardPanel()
    @panel.mesh.position.set 0, 2.6, 0
    @panel.setVisible(false)
    @mesh.add @panel.mesh

  tick: (tpf) ->
    # this prob needs a better implementation. move it to something which
    # doesn't happen at every tick
    return unless @mine
    currScene = SceneManager.currentScene()
    if @cards.size() == 3 and currScene.game?
      card = currScene.game.referee.findCard(@cards.first().id)
      isHoldingNonHeroes = card.type != Constants.CardType.HERO
    @toggleButton.setVisible(isHoldingNonHeroes or false)
    @panel.setVisible(currScene.game.referee.isDiscovering(currScene.mover._getMyPlayerIndex()) and @cards.size() == 3 and @toggleButton.faceUp)

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
    return unless @mine
    if @toggleButton.isHovered(raycaster) and event.type == 'mouseup' and @toggleButton.visible
      @viewingBoard = !@viewingBoard
      @toggleButton.click(true)
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
