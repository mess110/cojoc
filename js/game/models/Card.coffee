class Card extends BaseModel
  constructor: (json) ->
    super()

    @cardWidth = 3
    @cardHeight = 4
    @canvasWidth = 336
    @canvasHeight = 452

    @mesh = new THREE.Object3D()

    @art = new ArtGenerator(width: @canvasWidth, height: @canvasHeight)
    material = @mkMaterial(json)

    @front = Helper.plane(material: material, width: @cardWidth, height: @cardHeight)
    @mesh.add @front

    backMaterial = new THREE.MeshBasicMaterial(
      map: TextureManager.get().items['card-bg']
    )
    @back = Helper.plane(material: backMaterial, width: @cardWidth, height: @cardHeight)
    @back.rotation.set Math.PI, 0, Math.PI
    @mesh.add @back

  impersonate: (json) ->
    # TODO: check if it is a card
    @front.material = @mkMaterial(json)

  dissolve: () ->
    # @dm = Helper.dissolveMaterial(@front.material.map)
    @dm = Helper.dissolveMaterial(TextureManager.get().items['card-bg'])
    @dissolved = true
    @front.material = @dm

  foo: (tpf) ->
    return unless @dissolved
    return if @dm.uniforms.dissolve.value > 1.1
    @dm.uniforms.dissolve.value += tpf

  mkMaterial: (json) ->
    @art.clear()
    @art.drawImage(key: 'card-art-bg')
    @art.drawImage(key: json.key)
    @art.drawImage(key: 'card-template')
    @art.drawImage(key: 'heart', x: @canvasWidth - 64, y: @canvasHeight - 64)
    @art.drawImage(key: 'wood-sword', y: @canvasHeight - 64)
    @art.drawImage(key: 'mana-crystal')
    @art.drawText(text: '5', strokeStyle: 'black', x: 20, y: 50, font: '50px Pirata One')
    @art.drawText(text: '4', strokeStyle: 'black', x: 20, y: @canvasHeight - 15, font: '50px Pirata One')
    @art.drawText(text: '2', strokeStyle: 'black', x: @canvasWidth - 40, y: @canvasHeight - 15, font: '50px Pirata One')
    # @art.drawText(text: 'Charge', strokeStyle: 'black', x: @canvasWidth / 2 - 50, y: @canvasHeight / 3 * 2 + 50, font: '40px Pirata One')
    @art.drawBezier(
      curve: '20,157.2,130.02,100.0,190.5,246.2,492,176.3'
      text: json.name
      x: 70, y: 93
      strokeStyle: 'black'
      letterPadding: 6
      font: '50px Pirata One'
    )

    Helper.materialFromCanvas(@art.canvas)
