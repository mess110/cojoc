class Card extends BoxedModel
  constructor: () ->
    super()

    @cardWidth = 3
    @cardHeight = 4
    @canvasWidth = 336
    @canvasHeight = 452

    @mesh = new THREE.Object3D()
    @pivot = new THREE.Object3D()
    @mesh.add @pivot

    @art = new ArtGenerator(width: @canvasWidth, height: @canvasHeight)

    frontMat = Helper.basicMaterial('card-bg')
    @front = Helper.plane(material: frontMat, width: @cardWidth, height: @cardHeight)
    @pivot.add @front

    backMat = Helper.basicMaterial('card-bg')
    @back = Helper.plane(material: backMat, width: @cardWidth, height: @cardHeight)
    @back.rotation.set Math.PI, 0, Math.PI
    @pivot.add @back

    @glow = new Glow()
    @glow.mesh.position.set 0, 0, -0.01
    @pivot.add @glow.mesh

    @box = new THREE.Mesh(
      new THREE.BoxGeometry(@cardWidth, @cardHeight, 0.1),
      @_boxMaterial()
    )
    @mesh.add @box

  setOpacity: (value) ->
    @front.material.opacity = value if @front?
    @back.material.opacity = value if @back?

  impersonate: (json) ->
    # TODO: check if it is a card
    @front.material = @mkMaterial(json)

  dissolve: (r=0, g=0, b=0) ->
    dm = Helper.dissolveMaterial(@front.material.clone().map)
    @dm = Helper.setDissolveMaterialColor(dm, r, g, b)
    # @dm = Helper.dissolveMaterial(TextureManager.get().items['card-bg'])
    @front.material = @dm
    @dissolved = true
    return

  cancelMove: ->
    @tween.stop() if @tween?

  move: (position, rotation, duration = 1000) ->
    @cancelMove()

    @tween = Helper.tween(
      mesh: @mesh
      duration: duration
      target:
        x: position.x
        y: position.y
        z: position.z
        rX: rotation.x
        rY: rotation.y
        rZ: rotation.z
    )
    @tween.start()

  dissolveTick: (tpf) ->
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