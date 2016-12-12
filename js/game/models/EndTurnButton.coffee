# Use setPosition to also set the original position
class EndTurnButton extends Card
  ANIMATION_DURATION = 1500

  constructor: ->
    super()

    @front.material = Helper.basicMaterial('end-turn-front')
    @back.material = Helper.basicMaterial('end-turn-bg')
    @mesh.rotation.z = Math.PI / 2
    @animating = false
    @hasActionsLeft = true
    @hovered = false
    @original = { x: 0, y: 0, z: 0 }
    @faceUp = true

  isFaceUp: ->
    @faceUp

  setPosition: (x, y, z) ->
    @original.x = x
    @original.y = y
    @original.z = z
    @mesh.position.set x, y, z

  setActionsLeft: (value) ->
    @hasActionsLeft = value
    if value
      if @hovered
        @glow.yellow()
      else
        @glow.none()
    else
      @glow.green()

  hover: (event, raycaster) ->
    if !@hasActionsLeft
      @glow.green()
      if event.type == 'mousedown'
        if event.button == 0
          @click()
        else
          @click(true)
      return

    @hovered = @isHovered(raycaster)
    if @hovered
      if event.type == 'mousedown'
        @glow.yellow()
        if event.button == 0
          @click()
        else
          @click(true)
      if event.type == 'mousemove'
        @glow.yellow()
    else
      @glow.none()

  setFaceUp: (faceUp) ->
    if faceUp == true && @isFaceUp()
      return
    if faceUp == false && !@isFaceUp()
      return

    @click(true)

  click: (override = false)->
    if override
      @stop()
    else if @animating
      return

    @faceUp = !@faceUp
    @animating = true

    @up = Helper.tween(
      mesh: @mesh
      target:
        x: @original.x
        y: @original.y
        z: @original.z + 2
        rX: if @faceUp then 0 else Math.PI
      duration: ANIMATION_DURATION / 3
      kind: 'Exponential'
      direction: 'Out'
    ).start()
    @downTimeout = setTimeout =>
      @down = Helper.tween(
        mesh: @mesh
        target:
          x: @original.x
          y: @original.y
          z: @original.z
        duration: ANIMATION_DURATION / 3
        kind: 'Exponential'
        direction: 'Out'
      ).start()
    , ANIMATION_DURATION / 3 * 2

    @endTimeout = setTimeout =>
      @animating = false
    , ANIMATION_DURATION
    console.log @faceUp
    return

  stop: ->
    clearTimeout(@downTimeout)
    clearTimeout(@endTimeout)
    @up.stop() if @up?
    @down.stop() if @down?
