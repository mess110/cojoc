class Hand extends BoxedModel
  MAX_ROTATION = 1

  constructor: () ->
    super()

    @mouseDown = false
    @cards = []
    @mesh = new THREE.Object3D()

    @box = new THREE.Mesh(new THREE.BoxGeometry(6, 2, 0.1), @_boxMaterial())
    @mesh.add @box

    @curve = new HandCurve()
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
      if @hoveredCard? && found != @selectedCard
        @_changeSelected(found, @selectedCard, raycaster)

      if !@hoveredCard? && !@takenOut
        @_changeSelected(undefined, @selectedCard, raycaster)

    if event.type == 'mouseup'
      if @_isInPlayArea(pos)
        @remove(@selectedCard)
        @selectedCard.dissolve()
      @_changeSelected(undefined, @selectedCard, raycaster)

    if event.type == 'mousedown' && @hoveredCard?
      @_changeSelected(found, @selectedCard, raycaster)

    # handle dragging
    if @selectedCard?
      if @takenOut
        @_moveWithDiff(@selectedCard, pos)
      else if @_isInPlayArea(pos)
        # happens only once
        @takenOut = true
        @diff =
          x: @selectedCard.mesh.position.x - pos.x
          y: @selectedCard.mesh.position.y - pos.y

        @selectedCard.cancelMove()
        @_moveWithDiff(@selectedCard, pos)

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

    if oldSelected?
      point = @getPoint(oldSelected)
      if point?
        oldSelected.move(
          { x: point.x, y: point.y, z: point.z + oldSelected.indexInHand * 0.1 }
          { x: 0, y: 0, z: -point.x / 20 }
          200
        )
        Helper.tween(
          mesh: oldSelected.pivot
          duration: 100
          target: { rX: 0, rY: 0, rZ: 0 }
        ).start()

    if newSelected?
      point = @getPoint(@selectedCard.indexInHand)
      if !@_isInPlayArea(pos)
        point.z += 1
        point.y += 1.6
        @selectedCard.mesh.position.x = point.x
        @selectedCard.mesh.position.y = point.y
        @selectedCard.mesh.position.z = point.z
        @selectedCard.mesh.rotation.set 0, 0, 0
        @selectedCard.move({ y: point.y + 0.2 })

    @_updateGlow(newSelected, oldSelected)

  _updateMouseStatus: (event) ->
    @mouseDown = true if event.type == 'mousedown'
    @mouseDown = false if event.type == 'mouseup'

    if event.type == 'mousemove' && @oldEvent?
      if @oldEvent.pageX != event.pageX
        amount = if event.pageX < @oldEvent.pageX then -0.01 else 0.01
        @direction.x = Helper.addWithMinMax(@direction.x, amount, -MAX_ROTATION, MAX_ROTATION)
      if @oldEvent.pageY != event.pageY
        amount = if event.pageY < @oldEvent.pageY then 0.01 else -0.01
        @direction.y = Helper.addWithMinMax(@direction.y, amount, -MAX_ROTATION, MAX_ROTATION)

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
    points = @getPoints()
    i = 0
    for card in @cards
      # if card == @hoveredCard || card == @selectedCard
      if card == @selectedCard
        i += 1
        continue
      point = points[i]
      card.move(
        { x: point.x, y: point.y, z: i * 0.1 }
        { x: 0, y: 0, z: -point.x / 20 }
      )
      i += 1

  _findHoveredCard: (raycaster) ->
    found = []
    for card in @cards
      if card.isHovered(raycaster)
        found.push card
    found.sort((a,b) -> a.mesh.position.z - b.mesh.position.z).last()

  _changeHovered: (newFound, oldFound)->
    points = @getPoints()
    @hoveredCard = newFound
