class BackDrop extends BaseModel

  constructor: ->
    material = new (THREE.MeshBasicMaterial)(
      color: 'black'
      transparent: true
    )
    geometry = new (THREE.PlaneBufferGeometry)(500, 500)
    @mesh = new (THREE.Mesh)(geometry, material)

    @setOpacity(0)
    @active = false

  fadeIn: ->
    return if @active
    @fade.stop() if @fade?
    @fade = @animate(@getOpacity(), 0.6)
    @active = true

  fadeOut: ->
    return unless @active
    @fade.stop() if @fade?
    @fade = @animate(@getOpacity(), 0)
    @active = false

  animate: (from, to)->
    new FadeModifier(@, from, to, 1000).start()
