class Deck extends Card
  ANIMATION_DURATION = 500

  constructor: (maxCards = 66)->
    super()

    @cardCount = maxCards
    @panel = new Panel()
    @panel.mesh.position.set 0.4, -0.2, 0.05
    @panel.setText(@cardCount)
    @panel.setVisible(false)
    @mesh.add @panel.mesh
    @hovered = false

  drawCard: (scene) ->
    return if @cardCount <= 0

    card = new Card()
    card.mesh.position.set @mesh.position.x, @mesh.position.y, @mesh.position.z - 0.1
    card.mesh.rotation.set 0, Math.PI, 0
    scene.add card.mesh

    @cardCount -= 1
    @panel.setText(@cardCount)
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
    @panel.mesh.rotation.x = -@mesh.rotation.x
    @panel.mesh.rotation.y = -@mesh.rotation.y
    @panel.mesh.rotation.z = -@mesh.rotation.z

  _updateHovered: (newHovered, oldHovered) ->
    @hovered = newHovered
    if @hovered
      @_alwaysReadablePanel()
      @glow.green()
      @panel.setVisible(true)
    else
      @glow.none()
      @panel.setVisible(false)
