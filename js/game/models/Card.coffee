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

  getOpacity: ->
    @front.material.opacity

  impersonate: (json) ->
    @_validateJsonCard(json)
    @front.material = @mkCardMaterial(json)
    @

  minion: (json) ->
    @_validateJsonCard(json)
    @front.material = @mkMinionMaterial(json)
    @

  cancelMove: ->
    @tween.stop() if @tween?

  move: (options = {}) ->
    @cancelMove()
    options.mesh = @mesh
    @tween = Helper.tween(options)
    @tween.start()
    @tween

  dissolve: (r=0, g=0, b=0) ->
    fdm = Helper.dissolveMaterial(@front.material.clone().map)
    @fdm = Helper.setDissolveMaterialColor(fdm, r, g, b)
    bdm = Helper.dissolveMaterial(@back.material.clone().map)
    @bdm = Helper.setDissolveMaterialColor(bdm, r, g, b)
    @front.material = @fdm
    @back.material = @bdm
    @dissolved = true
    return

  dissolveTick: (tpf) ->
    return unless @dissolved
    return if @fdm.uniforms.dissolve.value > 1.1
    @fdm.uniforms.dissolve.value += tpf
    @bdm.uniforms.dissolve.value += tpf

  mkMinionMaterial: (json) ->
    @art.clear()
    @art.drawImage(key: 'card-art-bg')
    @art.drawImage(key: json.key)
    @art.drawImage(key: 'card-template')

    padding = 5
    @art.ctx.drawImage(@art.canvas, 107, 25, 123, 168, padding, padding, @canvasWidth - padding * 2, @canvasHeight - padding * 2)
    @art.drawImage(key: 'minion-template')
    if json.defaults.attack
      @art.drawImage(key: 'wood-sword', y: @canvasHeight - 64)
      @art.drawText(text: json.defaults.attack, strokeStyle: 'black', x: 20, y: @canvasHeight - 15, font: '50px Pirata One')
    if json.defaults.health
      @art.drawImage(key: 'heart', x: @canvasWidth - 64, y: @canvasHeight - 64)
      @art.drawText(text: json.defaults.health, strokeStyle: 'black', x: @canvasWidth - 40, y: @canvasHeight - 15, font: '50px Pirata One')

    Helper.materialFromCanvas(@art.canvas)

  mkCardMaterial: (json) ->
    @art.clear()
    @art.drawImage(key: 'card-art-bg')
    @art.drawImage(key: json.key)
    @art.drawImage(key: 'card-template')
    if json.defaults.cost
      @art.drawImage(key: 'mana-crystal')
      @art.drawText(text: json.defaults.cost, strokeStyle: 'black', x: 20, y: 50, font: '50px Pirata One')
    if json.defaults.attack
      @art.drawImage(key: 'wood-sword', y: @canvasHeight - 64)
      @art.drawText(text: json.defaults.attack, strokeStyle: 'black', x: 20, y: @canvasHeight - 15, font: '50px Pirata One')
    if json.defaults.health
      @art.drawImage(key: 'heart', x: @canvasWidth - 64, y: @canvasHeight - 64)
      @art.drawText(text: json.defaults.health, strokeStyle: 'black', x: @canvasWidth - 40, y: @canvasHeight - 15, font: '50px Pirata One')
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

  toJson: ->
    {
      id: @id
      owner: @owner
      status: @status
    }

  _validateJsonCard: (json) ->
    throw 'key missing' unless json.key?
    throw 'name missing' unless json.name?
    throw 'defaults missing' unless json.defaults?
