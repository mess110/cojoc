class BaseLine extends BoxedModel
  constructor: ->
    super()

    @maxRotation = 1
    @rotMod = 1
    @mouseDown = false
    @cards = []
    @mesh = new THREE.Object3D()
    @plane = new THREE.Plane(new THREE.Vector3(0, 0, 1), -1)
    @enabled = true
    @holstered = false
    @holsterEnabled = false
    @defaultHolsterAmount = 5.8
    @holsterAmount = @defaultHolsterAmount
    @holsterLock = false

    @direction =
      x: 0
      y: 0

  add: (toAddArray = []) ->
    toAddArray = [].concat(toAddArray)

    for toAdd in toAddArray
      @cards.push toAdd
      toAdd.indexInHand = @cards.indexOf(toAdd)

    @_changeCount()
    @update()
    toAddArray

  remove: (toRemoveArray = []) ->
    toRemoveArray = [].concat(toRemoveArray)

    for toRemove in toRemoveArray
      @cards.remove toRemove
      toRemove.indexInHand = undefined

      @selectedCard == undefined if @selectedCard == toRemove
      @hoveredCard == undefined if @hoveredCard == toRemove

      for card in @cards
        card.indexInHand = @cards.indexOf(card)

    @_changeCount()
    @update()
    toRemoveArray

  _changeCount: ->

  update: (duration) ->
    @curve.scale(@cards.size() / if @holstered then 50 else 10)
    @_drawLine()
    @_moveInPosition(duration)
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

  # Override this where no holstering happnes
  _doHolster: (found, raycaster, pos) ->
    return false unless @holsterEnabled
    if !@holstered and !found? and @_isInPlayArea(pos) and !@takenOut
      @holster(true)
      return true

    if @holstered
      if @isHovered(raycaster) and event.type == 'mouseup' and !@holsterLock
        @holster(false)
      return true

    false

  doMouseEvent: (event, raycaster) ->
    @boxIsHovered = @isHovered(raycaster)
    return unless @enabled

    @_updateMouseStatus(event)
    pos = raycaster.ray.intersectPlane(@plane)

    # Hovered card
    found = @_findHoveredCard(raycaster)
    if found != @hoveredCard
      @_changeHovered(found, @hoveredCard)

    return if @_doHolster(found, raycaster, pos)

    # Selected card
    if event.type == 'mousemove' and @mouseDown
      if @hoveredCard? and found != @selectedCard and !@takenOut
        @_changeSelected(found, @selectedCard, raycaster)

      if !@hoveredCard? and !@takenOut
        @_changeSelected(undefined, @selectedCard, raycaster)

    if event.type == 'mouseup'
      @_doMouseUp(raycaster, pos)
      @_changeSelected(undefined, @selectedCard, raycaster)

    if event.type == 'mousedown' and @hoveredCard?
      @_changeSelected(found, @selectedCard, raycaster)

    @_doAfterMouseEvent(event, raycaster, pos)

    return

  customPosition: ->
    throw 'not implemented'

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

    if event.type == 'mousemove' and @oldEvent?
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
    @line.visible = oldVisible or false

    @mesh.add @line

  _moveInPosition: (duration = 1000) ->
    for card in @cards
      if card == @selectedCard and !@holstered
        continue
      point = @getPoint(card)
      card.move(
        duration: duration
        target:
          x: point.x
          y: point.y
          z: point.z + card.indexInHand * 0.1 * @rotMod
          rX: @mesh.rotation.x
          rY: @mesh.rotation.y
          # rZ depends on the position and extracts the holsteredAmount so the
          # rotation doesn't change when the object is holstered
          rZ: -(point.x - @_getHolsterAmount()) / 20
          sX: @_getHolsterScale()
          sY: @_getHolsterScale()
          sZ: @_getHolsterScale()
      )

  _findHoveredCard: (raycaster) ->
    found = []
    for card in @cards
      if card.isHovered(raycaster)
        found.push card
    found.sort((a,b) -> a.mesh.position.z - b.mesh.position.z).last()

  _changeHovered: (newFound, oldFound)->
    @hoveredCard = newFound

  _getExtraX: (card) ->
    extraX = 0
    if !(@cards.size() % 2 == 1 and parseInt(@cards.size() / 2) == card.indexInHand)
      offset = (@cards.size() / 2 - 0.5)
      extraX -= (card.indexInHand - offset) / 2
    extraX

  _getHolsterAmount: ->
    if @holstered then @holsterAmount else 0

  _getHolsterScale: ->
    if @holstered then 0.3 else 1

  holster: (value) ->
    return unless @holsterEnabled
    @_changeHovered(undefined, @hoveredCard)
    @takenOut = false
    @_doChangeSelected(undefined, @selectedCard)
    @_updateGlow(undefined, @selectedCard)
    @holstered = value
    @mesh.position.x = @_getHolsterAmount()
    @update(200)

  hasCards: ->
    @cards.any()

  hasSelected: ->
    @selectedCard?

  hasHovered: ->
    @hoveredCard?

  hasInteraction: ->
    @hasSelected() || @hasHovered()
