class Minions extends BaseLine
  constructor: ->
    super()

    @box = new THREE.Mesh(new THREE.BoxGeometry(6, 2, 0.1), @_boxMaterial())
    @mesh.add @box

    @curve = new MinionsCurve()

  tick: (tpf) ->

  _moveInPosition: () ->
    for card in @cards
      point = @getPoint(card)
      if card == @selectedCard
        point.x += @_getExtraX(card)
        point.z += 4

      card.move(
        target:
          x: point.x
          y: point.y
          z: point.z
          rX: 0
          rY: 0
          rZ: 0
      )

  _doMouseUp: (raycaster, pos) ->
    # console.log @selectedCard

  _doAfterMouseEvent: (event, raycaster, pos) ->

  _doChangeSelected: (newSelected, oldSelected, raycaster, pos) ->
    if oldSelected?
      @takenOut = false
      point = @getPoint(oldSelected)
      if point?
        oldSelected.move(
          target:
            x: point.x
            y: point.y
            z: point.z
            rX: 0
            rY: 0
            rZ: 0
          duration: 200
          kind: 'Cubic', direction: 'In'
        )

    if newSelected?
      @takenOut = true
      point = @getPoint(@selectedCard)

      @selectedCard.move(
        target:
          x: point.x + @_getExtraX(@selectedCard)
          y: point.y
          z: point.z + 4
          rX: 0
          rY: 0
          rZ: 0
        duration: 200
        kind: 'Cubic', direction: 'Out'
      )
