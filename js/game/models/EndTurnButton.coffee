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
    @clickOnlyOnFaceUp = true
    @clickLock = false
    @hovered = false
    @original = { x: 0, y: 0, z: 0 }
    @faceUp = true

  isFaceUp: ->
    @faceUp

  setFaceUp: (faceUp) ->
    if faceUp == true and @isFaceUp()
      return
    if faceUp == false and !@isFaceUp()
      return
    @click(true)

  setOriginalPosition: (x, y, z) ->
    @original.x = x
    @original.y = y
    @original.z = z
    @mesh.position.set x, y, z

  setActionsLeft: (value) ->
    @hasActionsLeft = value

  tick: (tpf) ->
    if @hasActionsLeft
      @glow.yellow()
    else
      @glow.green()

  doMouseEvent: (event, raycaster) ->
    @hovered = @isHovered(raycaster)
    if @hovered and event.type == 'mouseup' and !@clickLock
      @click()
      SceneManager.currentScene()._emit(
        type: 'gameInput'
        action: Constants.Input.END_TURN
      )

  click: (override = false)->
    return if !@faceUp and !override and @clickOnlyOnFaceUp
    if override
      @stop()
    else if @animating
      return

    @faceUp = !@faceUp
    @animating = true
    @_upTween()
    @upTimeout = setTimeout (=> @_downTween()), ANIMATION_DURATION / 3 * 2
    @downTimeout = setTimeout (=> @animating = false), ANIMATION_DURATION
    return

  stop: ->
    clearTimeout(@upTimeout)
    clearTimeout(@downTimeout)
    @up.stop() if @up?
    @down.stop() if @down?

  _upTween: ->
    @up = Helper.tween(
      mesh: @pivot
      target:
        x: @original.x
        y: @original.y + 1
        z: @original.z + 2
        rY: if @faceUp then 0 else -Math.PI
      duration: ANIMATION_DURATION / 3
      kind: 'Exponential'
      direction: 'Out'
    ).start()

  _downTween: ->
    @down = Helper.tween(
      mesh: @pivot
      target:
        x: @original.x
        y: @original.y
        z: @original.z
      duration: ANIMATION_DURATION / 3
      kind: 'Exponential'
      direction: 'Out'
    ).start()
