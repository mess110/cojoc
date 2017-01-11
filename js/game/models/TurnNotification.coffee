class TurnNotification extends BaseModel
  ANIMATION_DURATION = 500

  constructor: ->
    super()
    @animating = false

    geom = new THREE.PlaneBufferGeometry(6.71, 5.64)
    material = Helper.basicMaterial('turn-notification')
    @mesh = new THREE.Mesh(geom, material)

    @text = new BigText('center')
    @text.mesh.position.set 0, -3.5, 0.075
    @mesh.add @text.mesh
    @setText('Rândul tău')

  setOpacity: (i) ->
    super(i)
    @text.setOpacity(i)

  setText: (text) ->
    @text.setText(text)

  animate: ->
    return if @animating
    @animating = true

    new FadeModifier(@, 0, 1, ANIMATION_DURATION / 5).start()
    new ScaleModifier(@, 0.001, 1, ANIMATION_DURATION).tween.easing(TWEEN.Easing.Elastic.Out).start()
    new ScaleModifier(@, 1, 0.001, ANIMATION_DURATION).delay(ANIMATION_DURATION * 3).tween.easing(TWEEN.Easing.Cubic.Out).start()
    new FadeModifier(@, 1, 0, ANIMATION_DURATION / 5).delay(ANIMATION_DURATION * 4 - ANIMATION_DURATION / 5).start()

    setTimeout =>
      @animating = false
    , ANIMATION_DURATION * 4
    return
