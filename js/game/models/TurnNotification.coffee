class TurnNotification extends BaseModel
  ANIMATION_DURATION = 500

  constructor: ->
    super()
    @animating = false

    geom = new THREE.PlaneBufferGeometry(6.71, 5.64)
    material = new THREE.MeshBasicMaterial(
      map: TextureManager.get().items['turn-notification']
      side: THREE.DoubleSide
      transparent: true
    )
    @mesh = new THREE.Mesh(geom, material)
    @mesh.renderOrder = 0

    @text = new BigText()
    @text.mesh.position.set -1, -3.5, 0.05
    @text.mesh.renderOrder = 1
    @mesh.add @text.mesh
    @setText('Rândul tău')

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
