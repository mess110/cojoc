class BaseLine extends BoxedModel
  constructor: ->
    super()

    @maxRotation = 1
    @mouseDown = false
    @cards = []
    @mesh = new THREE.Object3D()
    @plane = new THREE.Plane(new THREE.Vector3(0, 0, 1), -1)

    @direction =
      x: 0
      y: 0

  add: (card) ->
    @cards.push card
    card.indexInHand = @cards.indexOf(card)
    @update()
    card

  remove: (toRemove) ->
    return unless toRemove?

    @cards.remove toRemove
    toRemove.indexInHand = undefined

    @selectedCard == undefined if @selectedCard == @toRemove
    @hoveredCard == undefined if @hoveredCard == @toRemove

    for card in @cards
      card.indexInHand = @cards.indexOf(card)

    @update()
    toRemove

  update: ->
    @curve.scale(@cards.size() / 10)
    @_drawLine()
    @_moveInPosition()
    @cards.size()

  toggleWireframe: ->
    super()
    @_drawLine() unless @line?
    @line.visible = !@line.visible
    for card in @cards
      card.setWireframe(!@line.visible)

  getPoints: ->
    points = @curve.findPoints(@cards.size())
    for point in points
      point.x += @mesh.position.x
      point.y += @mesh.position.y
      point.z += @mesh.position.z
    points

  getPoint: (i) ->
    if isNumeric(i)
      @getPoints()[i]
    else
      @getPoints()[@cards.indexOf(i)]

  tick: (tpf) ->
    amount = tpf
    @direction.x = Helper.tendToZero(@direction.x, amount)
    @direction.y = Helper.tendToZero(@direction.y, amount)

    # TODO: maybe move this to hand
    if @selectedCard? && @takenOut
      @selectedCard.pivot.rotation.x = -@direction.y / 2
      @selectedCard.pivot.rotation.y = @direction.x / 2

  doMouseEvent: (event, raycaster) ->
    @_updateMouseStatus(event)
    pos = raycaster.ray.intersectPlane(@plane)

    # Hovered card
    found = @_findHoveredCard(raycaster)
    if found != @hoveredCard
      @_changeHovered(found, @hoveredCard)

    # Selected card
    if event.type == 'mousemove' && @mouseDown
      if @hoveredCard? && found != @selectedCard && !@takenOut
        @_changeSelected(found, @selectedCard, raycaster)

      if !@hoveredCard? && !@takenOut
        @_changeSelected(undefined, @selectedCard, raycaster)

    if event.type == 'mouseup'
      @_doMouseUp(raycaster, pos)
      @_changeSelected(undefined, @selectedCard, raycaster)

    if event.type == 'mousedown' && @hoveredCard?
      @_changeSelected(found, @selectedCard, raycaster)

    @_doAfterMouseEvent(event, raycaster, pos)

    return

  _updateGlow: (newFound, oldFound) ->
    if newFound?
      newFound.glow.green()

    if oldFound?
      oldFound.glow.none()

  _moveWithDiff: (card, pos) ->
    @selectedCard.mesh.position.x = pos.x + @diff.x
    @selectedCard.mesh.position.y = pos.y + @diff.y

  _isInPlayArea: (pos) ->
    pos.y > -1

  _changeSelected: (newSelected, oldSelected, raycaster) ->
    @takenOut = false
    pos = raycaster.ray.intersectPlane(@plane)
    @selectedCard = newSelected
    @_doChangeSelected(newSelected, oldSelected, raycaster, pos)
    @_updateGlow(newSelected, oldSelected)

  _updateMouseStatus: (event) ->
    @mouseDown = true if event.type == 'mousedown'
    @mouseDown = false if event.type == 'mouseup'

    if event.type == 'mousemove' && @oldEvent?
      if @oldEvent.pageX != event.pageX
        amount = if event.pageX < @oldEvent.pageX then -0.01 else 0.01
        @direction.x = Helper.addWithMinMax(@direction.x, amount, -@maxRotation, @maxRotation)
      if @oldEvent.pageY != event.pageY
        amount = if event.pageY < @oldEvent.pageY then 0.01 else -0.01
        @direction.y = Helper.addWithMinMax(@direction.y, amount, -@maxRotation, @maxRotation)

    @oldEvent = event

  _drawLine: ->
    if @line?
      oldVisible = @line.visible
      @mesh.remove @line

    @geometry = new (THREE.Geometry)
    @geometry.vertices = @getPoints()
    @geometry.computeLineDistances()
    material = new (THREE.LineDashedMaterial)(
      color: 'yellow', transparent: true, dashSize: 0.1, gapSize: 0.1
    )
    @line = new (THREE.Line)(@geometry, material)
    @line.visible = oldVisible || false

    @mesh.add @line

  _moveInPosition: () ->
    for card in @cards
      if card == @selectedCard
        continue
      point = @getPoint(card)
      card.move(
        target:
          x: point.x
          y: point.y
          z: point.z + card.indexInHand * 0.1
          rX: 0
          rY: 0
          rZ: -point.x / 20
      )

  _findHoveredCard: (raycaster) ->
    found = []
    for card in @cards
      if card.isHovered(raycaster)
        found.push card
    found.sort((a,b) -> a.mesh.position.z - b.mesh.position.z).last()

  _changeHovered: (newFound, oldFound)->
    @hoveredCard = newFound
