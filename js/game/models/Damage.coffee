class Damage extends BoxedModel
  ANIMATION_DURATION = 500

  constructor: ->
    super()
    @animating = false

    width = 3.14
    height = 3.10
    scale = 0.7
    geom = new THREE.PlaneBufferGeometry(width * scale, height * scale)
    material = new THREE.MeshBasicMaterial(
      map: TextureManager.get().items['damage']
      side: THREE.DoubleSide
      transparent: true
    )
    @mesh = new THREE.Mesh(geom, material)
    @mesh.renderOrder = 0

    @box = new THREE.Mesh(
      new THREE.BoxGeometry(width * scale, height * scale, 0.1),
      @_boxMaterial()
    )
    @mesh.add @box

    @text = new BigText('center')
    @text.mesh.renderOrder = 1
    @text.mesh.position.set -0.1, -1.5, 0.01
    @mesh.add @text.mesh
    @setText(-1)

  setOpacity: (i) ->
    super(i)
    @text.setOpacity(i)

  setText: (text) ->
    text = text.toString()
    if !text.startsWith('-') or !text.startsWith('+')
      if text.startsWith('-')
        # do nothing
      else
        text = "+#{text}"
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
      PoolManager.release(@)
    , ANIMATION_DURATION * 4
    return
