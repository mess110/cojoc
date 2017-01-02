class CardPreview extends Card
  ANIMATION_DURATION = 500

  constructor: ->
    super()
    @setOpacity(0)

  animate: (card) ->
    extraDelay = 0
    if @animating
      extraDelay = 200
      @f1t.stop() if @f1t?
      @s1t.stop() if @s1t?
      @f2t.stop() if @f2t?
      @s2t.stop() if @s2t?
      @et.stop() if @et?
      clearTimeout(@zeTime)
      clearTimeout(@impersonateTimeout)

      @et = new FadeModifier(@, @getOpacity(), 0, extraDelay)
      @et.start()

    @animating = true

    @impersonateTimeout = setTimeout =>
      @impersonate(card)
    , extraDelay

    @f1t = new FadeModifier(@, 0, 1, ANIMATION_DURATION / 5).delay(extraDelay)
    @f1t.start()
    @s1t = new ScaleModifier(@, 0.001, 1, ANIMATION_DURATION).delay(extraDelay)
    @s1t.tween.easing(TWEEN.Easing.Elastic.Out)
    @s1t.start()
    @s2t = new ScaleModifier(@, 1, 0.001, ANIMATION_DURATION).delay(extraDelay + ANIMATION_DURATION * 3)
    @s2t.tween.easing(TWEEN.Easing.Cubic.Out)
    @s2t.start()
    @f2t = new FadeModifier(@, 1, 0, ANIMATION_DURATION / 5).delay(extraDelay + ANIMATION_DURATION * 4 - ANIMATION_DURATION / 5)
    @f2t.start()

    @zeTime = setTimeout =>
      @animating = false
    , extraDelay + ANIMATION_DURATION * 4
    return
