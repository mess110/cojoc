class Glow extends BaseModel
  constructor: ->
    super()

    @cardWidth = 3
    @cardHeight = 4
    @defaultOpacity = 0.75

    @redMaterial = @mkMaterial('glowRed')
    @greenMaterial = @mkMaterial('glowGreen')
    @blueMaterial = @mkMaterial('glowBlue')
    @yellowMaterial = @mkMaterial('glowYellow')

    extra = 0.5
    @mesh = Helper.plane(material: @greenMaterial, width: @cardWidth + extra, height: @cardHeight + extra)
    @none()

  isGlowing: ->
    @mesh.visible

  none: ->
    return unless @mesh.visible
    @setVisible(false)

  red: ->
    return if @_isSame(@redMaterial)
    @setVisible(true)
    @mesh.material = @redMaterial

  green: ->
    return if @_isSame(@greenMaterial)
    @setVisible(true)
    @mesh.material = @greenMaterial

  blue: ->
    return if @_isSame(@blueMaterial)
    @setVisible(true)
    @mesh.material = @blueMaterial

  yellow: ->
    return if @_isSame(@yellowMaterial)
    @setVisible(true)
    @mesh.material = @yellowMaterial

  original: ->
    @mesh.position.z = -0.01
    @mesh.rotation.x = 0

  flip: ->
    @mesh.position.z *= -1
    @mesh.rotation.x = if @mesh.rotation.x == 0 then Math.PI else 0

  _isSame: (material) ->
    @mesh.material == material and @mesh.visible

  _funkyAnimation: ->
    @funkyScale = 1
    setInterval =>
      step = 0.002
      rand = Math.random()
      if rand > 0.5
        @funkyScale += step
      else
        @funkyScale -= step

      if @funkyScale > 1.06
        if rand > 0.5
          @funkyScale -= step
        else
          @funkyScale += step
      if @funkyScale < 0.98
        if rand > 0.5
          @funkyScale -= step
        else
          @funkyScale += step

      @mesh.scale.set @funkyScale, @funkyScale, @funkyScale
    , 20

  mkMaterial: (key) ->
    material = Helper.basicMaterial(key)
    material.opacity = @defaultOpacity
    material
