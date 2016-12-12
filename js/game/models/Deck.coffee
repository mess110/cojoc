class Deck extends BoxedModel
  constructor: () ->
    super()

    @cards = []
    @mesh = new THREE.Object3D()

    @box = new THREE.Mesh(new THREE.BoxGeometry(6, 2, 0.1), @_boxMaterial())
    @mesh.add @box

    @curve = new HandCurve()

  add: (card) ->
    @cards.push card
    @update()
    card

  remove: (card) ->
    @cards.remove card
    @update()
    card

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
    @geometry.vertices = @curve.findPoints(@cards.size())
    @geometry.computeLineDistances()
    material = new (THREE.LineDashedMaterial)(
      color: 'yellow', transparent: true, dashSize: 0.1, gapSize: 0.1
    )
    @line = new (THREE.Line)(@geometry, material)
    @line.visible = oldVisible || false

    @mesh.add @line

  _moveInPosition: () ->
    points = @curve.findPoints(@cards.size())
    i = 0
    for card in @cards
      point = points[i]
      card.move(
        { x: point.x, y: point.y, z: i * 0.005 }
        { x: 0, y: 0, z: -point.x / 20}
      )
      i += 1

  tick: (tpf) ->

  changed: (newFound, oldFound)->
    points = @curve.findPoints(@cards.size())
    @dragging = false

    if newFound?
      i = @cards.indexOf(newFound)
      point = points[i]
      newFound.move(
        { x: point.x, y: 1, z: i * 0.005 + 0.5 },
        { x: 0, y: 0, z: 0 },
        200
      )
      newFound.glow.green()
    if oldFound?
      i = @cards.indexOf(oldFound)
      point = points[i]
      oldFound.move(
        { x: point.x, y: point.y, z: i * 0.005 },
        { x: 0, y: 0, z: -point.x / 20},
        200
      )
      oldFound.glow.none()

    @found = newFound

  doMouseEvent: (event, raycaster) ->
    found = []
    for card in @cards
      if card.isHovered(raycaster)
        found.push card

    newFound = found.last()
    if newFound != @found
      @changed(newFound, @found)

    if newFound?
      if event.type == 'mousedown'
        @dragging = true
      if event.type == 'mouseup'
        @dragging = false
      console.log @dragging
      # TODO: if dragging, add an intersection plane and move the card accordingly

    found
