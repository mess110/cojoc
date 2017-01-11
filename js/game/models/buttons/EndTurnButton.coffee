# Use setPosition to also set the original position
class EndTurnButton extends ToggleButton
  ANIMATION_DURATION = 1500

  constructor: ->
    super()

    @front.material = Helper.basicMaterial('end-turn-front')
    @back.material = Helper.basicMaterial('end-turn-bg')
    @animating = false
    @hasActionsLeft = true
    @clickOnlyOnFaceUp = true
    @hovered = false
    @noGlow = false
    @hideTutorial = false

    @panel = new EndTurnPanel()
    @panel.mesh.rotation.set 0, 0, -Math.PI * 2
    @panel.mesh.position.set 2.5, 0, 0
    @mesh.add @panel.mesh

  setActionsLeft: (value) ->
    @hasActionsLeft = value

  tick: (tpf) ->
    if @noGlow
      @glow.none()
    else if @hasActionsLeft
      @glow.yellow()
    else
      @glow.green()

    @panel.setVisible(!@hasActionsLeft and !@hideTutorial)

  _getSize: ->
    { width: 3, height: 4 }

  doMouseEvent: (event, raycaster, override=false) ->
    @hovered = @isHovered(raycaster)
    if @hovered and event.type == 'mouseup' and !@clickLock
      @click(override)
      @hideTutorial = true
      currScene = SceneManager.currentScene()
      currScene._emit(
        type: 'gameInput'
        action: Constants.Input.END_TURN
      ) if currScene._emit?

  click: (override = false) ->
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
