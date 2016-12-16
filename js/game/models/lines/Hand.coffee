class Hand extends BaseLine
  constructor: () ->
    super()

    @box = new THREE.Mesh(new THREE.BoxGeometry(6, 2, 0.1), @_boxMaterial())
    @mesh.add @box

    @curve = new HandCurve()

  _doAfterMouseEvent: (event, raycaster, pos) ->
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

  _doMouseUp: (raycaster, pos) ->
    if @_isInPlayArea(pos)
      @remove(@selectedCard)
      @selectedCard.dissolve()

  _doChangeSelected: (newSelected, oldSelected, raycaster, pos) ->
    if oldSelected?
      point = @getPoint(oldSelected)
      if point?
        oldSelected.move(
          target:
            x: point.x
            y: point.y
            z: point.z + oldSelected.indexInHand * 0.1
            rX: 0
            rY: 0
            rZ: -point.x / 20
          duration: 200
          kind: 'Cubic', direction: 'In'
        )
        Helper.tween(
          mesh: oldSelected.pivot
          duration: 100
          target: { rX: 0, rY: 0, rZ: 0 }
        ).start()

    if newSelected?
      point = @getPoint(@selectedCard)
      if !@_isInPlayArea(pos)
        point.z += 1
        point.y += 1.6
        @selectedCard.mesh.position.x = point.x
        @selectedCard.mesh.position.y = point.y
        @selectedCard.mesh.position.z = point.z
        @selectedCard.mesh.rotation.set 0, 0, 0
        @selectedCard.move(
          target:
            y: point.y + 0.2
          kind: 'Cubic', direction: 'Out'
        )
