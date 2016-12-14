class Hand extends BoxedModel
  constructor: () ->
    super()

    @mouseDown = false
    @cards = []
    @mesh = new THREE.Object3D()

    @box = new THREE.Mesh(new THREE.BoxGeometry(6, 2, 0.1), @_boxMaterial())
    @mesh.add @box

    @curve = new HandCurve()
    @plane = new THREE.Plane(new THREE.Vector3(0, 0, 1), -1)

  add: (card) ->
    @cards.push card
    card.indexInHand = @cards.indexOf(card)
    @update()
    card

  remove: (toRemove) ->
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
      card.toggleWireframe()

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
      if card == @hoveredCard || card == @selectedCard
        i += 1
        continue
      point = points[i]
      card.move(
        { x: point.x, y: point.y, z: i * 0.1 }
        { x: 0, y: 0, z: -point.x / 20 }
      )
      i += 1

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
    # for card in @cards
      # card.pivot.rotation.x += tpf

  findHoveredCard: (raycaster) ->
    found = []
    for card in @cards
      if card.isHovered(raycaster)
        found.push card
    # found.last()
    found.sort((a,b) -> a.mesh.position.z - b.mesh.position.z).last()

  changed: (newFound, oldFound)->
    points = @getPoints()
    @hoveredCard = newFound

  updateGlow: (newFound, oldFound) ->
    if newFound?
      newFound.glow.green()

    if oldFound?
      oldFound.glow.none()

  updateMouseStatus: (event) ->
    if event.type == 'mousedown'
      @mouseDown = true
    if event.type == 'mouseup'
      @mouseDown = false

  changeSelected: (newSelected, oldSelected, raycaster) ->
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

    if newSelected?
      point = @getPoint(@selectedCard.indexInHand)
      if pos.y > -1
      else
        point.z += 1
        point.y += 1.6
        @selectedCard.mesh.position.x = point.x
        @selectedCard.mesh.position.y = point.y
        @selectedCard.mesh.position.z = point.z
        @selectedCard.mesh.rotation.set 0, 0, 0
        @selectedCard.move(
          { y: point.y + 0.2 }
          {}
        )

    @updateGlow(newSelected, oldSelected)

  doMouseEvent: (event, raycaster) ->
    @updateMouseStatus(event)

    # Hovered card
    found = @findHoveredCard(raycaster)
    if found != @hoveredCard
      @changed(found, @hoveredCard)

    # Selected card
    if event.type == 'mousemove' && @mouseDown # && @selectedCard?
      if @hoveredCard? && found != @selectedCard
        @changeSelected(found, @selectedCard, raycaster)

      if !@hoveredCard?
        @changeSelected(undefined, @selectedCard, raycaster)

    if event.type == 'mouseup'
      @changeSelected(undefined, @selectedCard, raycaster)

    if event.type == 'mousedown' && @hoveredCard?
      @changeSelected(found, @selectedCard, raycaster)

    # handle dragging
    pos = raycaster.ray.intersectPlane(@plane)
    if @selectedCard?
      if @takenOut
        @moveWithDiff(@selectedCard, pos)
      else if pos.y > -1
        # happens only once
        @takenOut = true
        @diff =
          x: @selectedCard.mesh.position.x - pos.x
          y: @selectedCard.mesh.position.y - pos.y

        @selectedCard.cancelMove()
        @moveWithDiff(@selectedCard, pos)

    return

  moveWithDiff: (card, pos) ->
    @selectedCard.mesh.position.x = pos.x + @diff.x
    @selectedCard.mesh.position.y = pos.y + @diff.y
