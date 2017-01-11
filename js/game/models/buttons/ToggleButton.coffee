class ToggleButton extends Card
  ANIMATION_DURATION = 1500

  constructor: ->
    super()
    @faceUp = true
    @clickOnlyOnFaceUp = false
    @clickLock = false
    @mesh.rotation.z = Math.PI / 2
    @original = { x: 0, y: 0, z: 0 }

  _getSize: ->
    { width: 2, height: 4 }

  isFaceUp: ->
    @faceUp

  setFaceUp: (faceUp) ->
    if faceUp == true and @isFaceUp()
      return
    if faceUp == false and !@isFaceUp()
      return
    @click(true)

  # The position of the pivot relative to the mesh
  setOriginalPosition: (x, y, z) ->
    @original = { x: x, y: y, z: z }

  doMouseEvent: (event, raycaster, override) ->
    @hovered = @isHovered(raycaster)
    if @hovered and event.type == 'mouseup' and !@clickLock
      @click(override)

  stop: ->
    clearTimeout(@endTimeout)
    @tween.stop() if @tween?

  click: (override = false) ->
    return if !@faceUp and !override and @clickOnlyOnFaceUp
    if override
      @stop()
    else if @animating
      return

    @faceUp = !@faceUp
    @animating = true
    @tween = Helper.tween(
      mesh: @pivot
      target:
        rY: if @faceUp then 0 else -Math.PI
      duration: ANIMATION_DURATION
      kind: 'Elastic'
      direction: 'Out'
    ).start()
    @endTimeout = setTimeout (=> @animating = false), ANIMATION_DURATION
    return

  discover: ->
    @setScale(0.5)
    @canvasWidth = 200
    @canvasHeight = 400
    @front.material = @mkFront('Ascunde')
    @back.material = @mkBack('Arată')
    @

  mkFront: (text) ->
    @art = new ArtGenerator(width: @canvasWidth, height: @canvasHeight)
    @art.drawImage(key: 'panel-toggle-button')
    @art.drawText(angle: 90, text: text, strokeStyle: 'black', x: @canvasHeight / 2 - 155, y: -@canvasWidth / 2 + 40, font: '110px Pirata One', strokeLineWidth: 20)
    Helper.materialFromCanvas(@art.canvas)

  mkBack: (text) ->
    art = new ArtGenerator(width: @canvasWidth, height: @canvasHeight)
    art.drawImage(key: 'panel-toggle-button')
    art.drawText(angle: 90, text: text, strokeStyle: 'black', x: @canvasHeight / 2 - 120, y: -@canvasWidth / 2 + 50, font: '140px Pirata One', strokeLineWidth: 40)
    Helper.materialFromCanvas(art.canvas)

  setVisible: (value) ->
    @mesh.visible = value
    @visible = value
