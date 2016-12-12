class Glow extends BaseModel
  constructor: ->
    super()

    @cardWidth = 3
    @cardHeight = 4

    @redMaterial = Helper.basicMaterial('glowRed')
    @greenMaterial = Helper.basicMaterial('glowGreen')
    @blueMaterial = Helper.basicMaterial('glowBlue')
    @yellowMaterial = Helper.basicMaterial('glowYellow')

    extra = 0.5
    @mesh = Helper.plane(material: @greenMaterial, width: @cardWidth + extra, height: @cardHeight + extra)
    @none()
    @setOpacity(0.25)

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

  flip: ->
    @mesh.rotation.x = if @mesh.rotation.x == 0 then Math.PI else 0

  _isSame: (material) ->
    @mesh.material == material && @mesh.visible
