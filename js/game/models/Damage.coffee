class Damage extends BoxedModel
  ANIMATION_DURATION = Constants.Duration.DAMAGE_SIGN / 4

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

    @box = new THREE.Mesh(
      new THREE.BoxGeometry(width * scale, height * scale, 0.1),
      @_boxMaterial()
    )
    @mesh.add @box

    @text = new BigText('center')
    @text.mesh.position.set -0.1, -1.5, 0.01
    @mesh.add @text.mesh
    @setText(-1)

  setOpacity: (i) ->
    super(i)
    @text.setOpacity(i)

  setText: (text) ->
    text = text.toString()
    if text != '0'
      if !text.startsWith('-') or !text.startsWith('+')
        if text.startsWith('-')
          # do nothing
        else
          text = "+#{text}"
    @text.setText(text)

  release: ->
    @s1m.stop() if @s1m?
    @s2m.stop() if @s2m?

  animate: ->
    return if @animating
    @animating = true

    @s1m = new ScaleModifier(@, 0.001, 1, ANIMATION_DURATION)
    @s1m.tween.easing(TWEEN.Easing.Elastic.Out)
    @s1m.start()

    @s2m = new ScaleModifier(@, 1, 0.001, ANIMATION_DURATION).delay(ANIMATION_DURATION * 3)
    @s2m.tween.easing(TWEEN.Easing.Cubic.Out)
    @s2m.start()

    setTimeout =>
      @animating = false
      PoolManager.release(@)
    , ANIMATION_DURATION * 4
    return
