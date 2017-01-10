class Card extends BoxedModel
  constructor: () ->
    super()

    @cardWidth = 3
    @cardHeight = 4
    @canvasWidth = 336
    @canvasHeight = 452

    @json = {}
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
    @glow.original()
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

  dissolve: (release=true) ->
    obj = @
    obj.front.material = @_dissolveColor(@front)
    obj.back.material = @_dissolveColor(@back)

    tween = new TWEEN.Tween(value: 0).to(value: 1, 1000)
    tween.easing(TWEEN.Easing.Cubic.In)
    tween.onUpdate(->
      obj.front.material.uniforms.dissolve.value = @value
      obj.back.material.uniforms.dissolve.value = @value
      return
    )
    if release
      tween.onComplete(->
        PoolManager.release(obj)
        return
      )
    tween.start()
    tween

  mkMinionMaterial: (json) ->
    fillStyle = '#f9f9f9'
    strokeLineWidth = 14
    @art.clear()
    @art.drawImage(key: 'card-art-bg')
    @art.drawImage(key: json.key)
    @art.drawImage(key: 'card-template')

    padding = 5
    @art.ctx.drawImage(@art.canvas, 107, 25, 123, 168, padding, padding, @canvasWidth - padding * 2, @canvasHeight - padding * 2)
    @art.drawImage(key: 'minion-template')
    if json.stats.attack?
      @art.drawImage(key: 'attack', x: 1, y: @canvasHeight - 115)
      @art.drawText(text: json.stats.attack, fillStyle: fillStyle, strokeStyle: 'black', strokeLineWidth: strokeLineWidth, x: 32, y: @canvasHeight - 20, font: '100px Pirata One')
    if json.stats.health?
      @art.drawImage(key: 'health', x: @canvasWidth - 121, y: @canvasHeight - 115)
      @art.drawText(text: json.stats.health, fillStyle: fillStyle, strokeStyle: 'black', strokeLineWidth: strokeLineWidth, x: @canvasWidth - 80, y: @canvasHeight - 20, font: '100px Pirata One')

    Helper.materialFromCanvas(@art.canvas)

  mkCardMaterial: (json) ->
    fillStyle = '#f9f9f9'
    @art.clear()
    @art.drawImage(key: 'card-art-bg')
    @art.drawImage(key: json.key)
    @art.drawImage(key: 'card-template')
    if json.defaults.cost
      @art.drawImage(key: 'mana-small')
      @art.drawText(text: json.defaults.cost, fillStyle: fillStyle, strokeStyle: 'black', x: 20, y: 50, font: '50px Pirata One')
    if json.defaults.attack
      @art.drawImage(key: 'attack-small', y: @canvasHeight - 64)
      @art.drawText(text: json.defaults.attack, fillStyle: fillStyle, strokeStyle: 'black', x: 20, y: @canvasHeight - 15, font: '50px Pirata One')
    if json.defaults.health
      # fillStyle = if json.stats.health == json.defaults.health then '#f9f9f9' else 'red'
      @art.drawImage(key: 'health-small', x: @canvasWidth - 64, y: @canvasHeight - 64)
      @art.drawText(text: json.defaults.health, fillStyle: fillStyle, strokeStyle: 'black', x: @canvasWidth - 40, y: @canvasHeight - 15, font: '50px Pirata One')
    # @art.drawText(text: 'Charge', strokeStyle: 'black', x: @canvasWidth / 2 - 50, y: @canvasHeight / 3 * 2 + 50, font: '40px Pirata One')
    @art.drawBezier(
      curve: '20,157.2,130.02,100.0,190.5,246.2,492,176.3'
      text: json.name
      x: 70, y: 93
      fillStyle: fillStyle
      strokeStyle: 'black'
      letterPadding: 6
      font: '50px Pirata One'
    )

    Helper.materialFromCanvas(@art.canvas)

  release: ->
    @mesh.scale.set 1, 1, 1
    @glow.original()
    @front.material = Helper.basicMaterial('card-bg')
    @back.material = Helper.basicMaterial('card-bg')

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
    @json = json

  _dissolveColor: (mesh) ->
    dm = Helper.dissolveMaterial(mesh.material.clone().map)
    Helper.setDissolveMaterialColor(dm, 0, 0, 0)
