class Hero extends BaseLine
  constructor: ->
    super()

    @box = new THREE.Mesh(new THREE.BoxGeometry(6, 2, 0.1), @_boxMaterial())
    @mesh.add @box

    @curve = new DiscoverCurve()

  tick: (tpf) ->

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

  _doAfterMouseEvent: (event, raycaster, pos) ->

  _doChangeSelected: (newSelected, oldSelected, raycaster, pos) ->

  customPosition: (i = 0) ->
    if i == 0
      @mesh.position.set 0, -6, 0
      @mesh.rotation.set 0, 0, 0
    else
      @mesh.position.set 0, 6, 0
      @mesh.rotation.set 0, 0, 0
