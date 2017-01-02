class Hand extends BaseLine
  PLANE_Z = 10

  constructor: () ->
    super()

    @holsterEnabled = true

    @box = new THREE.Mesh(new THREE.BoxGeometry(6, 2, 0.1), @_boxMaterial())
    @mesh.add @box

    @curve = new HandCurve()
    @plane = new THREE.Plane(new THREE.Vector3(0, 0, 1), -PLANE_Z - 1)

  tick: (tpf) ->
    amount = tpf
    @direction.x = Helper.tendToZero(@direction.x, amount)
    @direction.y = Helper.tendToZero(@direction.y, amount)

    # rotate the card according to the direction the mouse is going
    if @selectedCard? and @takenOut
      @selectedCard.pivot.rotation.x = -@direction.y / 2
      @selectedCard.pivot.rotation.y = @direction.x / 2

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
    if @_isInPlayArea(pos) and @selectedCard?
      @remove(@selectedCard)
      @selectedCard.dissolve()
      # TODO: playing a card
      @holster(true)

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
            sX: @_getHolsterScale()
            sY: @_getHolsterScale()
            sZ: @_getHolsterScale()
          duration: 200
          kind: 'Cubic', direction: 'In'
        )
        Helper.tween(
          mesh: oldSelected.pivot
          duration: 100
          target:
            rX: 0
            rY: 0
            rZ: 0
            sX: @_getHolsterScale()
            sY: @_getHolsterScale()
            sZ: @_getHolsterScale()
        ).start()

    if newSelected?
      point = @getPoint(@selectedCard)
      if !@_isInPlayArea(pos)
        point.z += 1
        point.y = -1.9
        @selectedCard.mesh.position.x = point.x
        @selectedCard.mesh.position.y = point.y
        @selectedCard.mesh.position.z = point.z
        @selectedCard.mesh.rotation.set 0, 0, 0
        @selectedCard.move(
          target:
            y: point.y + 0.2
          kind: 'Cubic', direction: 'Out'
        )

  customPosition: (i) ->
    switch i
      when Constants.Position.Player.SELF
        @curve = new HandCurve()
        @holsterAmount = @defaultHolsterAmount
        @rotMod = 1
        @mesh.position.set 0, -3.5, PLANE_Z
        @mesh.rotation.set 0, 0, 0
      when Constants.Position.Player.OPPONENT
        @curve = new EnemyHandCurve()
        @holsterAmount = -@defaultHolsterAmount
        @rotMod = -1
        @mesh.position.set 0, 3.5, PLANE_Z
        @mesh.rotation.set 0, Math.PI, 0
      else
        throw "invalid customPosition #{i}"
