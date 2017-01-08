class FinishedButton extends BoxedModel
  ANIMATION_DURATION = 3000

  constructor: ->
    super()

    width = 2.80 * 1.4
    height = 0.89 * 1.4

    frontMat = Helper.basicMaterial('wood')
    @mesh = Helper.plane(material: frontMat, width: width, height: height)

    @box = new THREE.Mesh(
      new THREE.BoxGeometry(width, height, 0.1),
      @_boxMaterial()
    )
    @mesh.add @box

    @text = new BigText2('center')
    @text.mesh.position.set -0.05, -1.22, 0.05
    @mesh.add @text.mesh

  setText: (s) ->
    @text.setText(s)

  animate: ->
    return if @animating
    @animating = true

    new FadeModifier(@, 0, 1, ANIMATION_DURATION / 5).start()
    new ScaleModifier(@, 0.001, 1, ANIMATION_DURATION).tween.easing(TWEEN.Easing.Elastic.Out).start()

    setTimeout =>
      @animating = false
    , ANIMATION_DURATION
    return
