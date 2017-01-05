class Deck extends Card
  ANIMATION_DURATION = 500

  constructor: (maxCards = 66)->
    super()

    @cardCount = maxCards
    @text = new BigText('center')
    @text.mesh.position.set 0, -1.35, 0
    @text.setText(@cardCount)
    @text.setVisible(false)
    @mesh.add @text.mesh
    @hovered = false

  drawCard: (scene) ->
    return if @cardCount <= 0

    card = PoolManager.spawn(Card)
    card.mesh.position.set @mesh.position.x, @mesh.position.y, @mesh.position.z - 0.1
    card.mesh.rotation.set 0, Math.PI, 0
    scene.add card.mesh

    @cardCount -= 1
    @text.setText(@cardCount)
    card.move(
      target:
        x: 2
        y: 0.2
      relative: true
      kind: 'Quadratic'
      direction: 'Out'
      duration: ANIMATION_DURATION
    )

    card

  doMouseEvent: (event, raycaster) ->
    isHovered = @isHovered(raycaster)
    @_updateHovered(isHovered, @hovered) if @hovered != isHovered

  _alwaysReadablePanel: ->
    @text.mesh.rotation.x = -@mesh.rotation.x
    @text.mesh.rotation.y = -@mesh.rotation.y
    @text.mesh.rotation.z = -@mesh.rotation.z

  _updateHovered: (newHovered, oldHovered) ->
    @hovered = newHovered
    if @hovered
      @_alwaysReadablePanel()
      @glow.green()
      @text.setVisible(true)
    else
      @glow.none()
      @text.setVisible(false)
