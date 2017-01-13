class Card extends BoxedModel
  constructor: () ->
    super()

    size = @_getSize()
    @cardWidth = size.width
    @cardHeight = size.height
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

  _getSize: ->
    { width: 3, height: 4 }

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

  entrance: (json, duration, point) ->
    @cancelMove()
    @mesh.position.set point.x, point.y, point.z
    @mesh.rotation.set 0, 0, 0
    @pivot.rotation.set 0, 0, 0
    @minion(json)
    new FadeModifier(@, 0, 1, duration / 3 * 2).start()
    new ScaleModifier(@, 0.001, Constants.MINION_SCALE, duration / 2).start()
    @setOpacity(1)
    duration

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

    tween = new TWEEN.Tween(value: 0).to(value: 1, Constants.Duration.DISSOLVE)
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
    fillStyle = Constants.TEXT_COLOR
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
      @art.drawText(text: json.stats.attack, fillStyle: fillStyle, strokeStyle: Constants.STROKE_COLOR, strokeLineWidth: strokeLineWidth, x: @_getStatsAttackX(json), y: @canvasHeight - 20, font: Constants.MINION_STAT_FONT)
    if json.stats.health?
      @art.drawImage(key: 'health', x: @canvasWidth - 121, y: @canvasHeight - 115)
      @art.drawText(text: json.stats.health, fillStyle: fillStyle, strokeStyle: Constants.STROKE_COLOR, strokeLineWidth: strokeLineWidth, x: @_getStatsHealthX(json), y: @canvasHeight - 20, font: Constants.MINION_STAT_FONT)

    if json.taunt
      @art.drawImage(key: 'taunt', x: @canvasWidth - 128)

    Helper.materialFromCanvas(@art.canvas)

  mkCardMaterial: (json) ->
    fillStyle = Constants.TEXT_COLOR
    @art.clear()
    @art.drawImage(key: 'card-art-bg')
    @art.drawImage(key: json.key)
    @art.drawImage(key: 'card-template')
    if json.defaults.cost?
      @art.drawImage(key: 'mana-small')
      @art.drawText(text: json.defaults.cost, fillStyle: fillStyle, strokeStyle: Constants.STROKE_COLOR, x: @_getDefaultCostX(json), y: 50, font: Constants.CARD_STAT_FONT)
    if json.defaults.attack?
      @art.drawImage(key: 'attack-small', y: @canvasHeight - 64)
      @art.drawText(text: json.defaults.attack, fillStyle: fillStyle, strokeStyle: Constants.STROKE_COLOR, x: @_getDefaultAttackX(json), y: @canvasHeight - 14, font: Constants.CARD_STAT_FONT)
    if json.defaults.health?
      @art.drawImage(key: 'health-small', x: @canvasWidth - 64, y: @canvasHeight - 64)
      @art.drawText(text: json.defaults.health, fillStyle: fillStyle, strokeStyle: Constants.STROKE_COLOR, x: @_getDefaultHealthX(json), y: @canvasHeight - 14, font: Constants.CARD_STAT_FONT)

    lineCount = 0
    if json.charge
      @art.drawText(text: 'Charge', strokeLineWidth: 3, strokeStyle: Constants.FLAVOR_STROKE_COLOR, fillStyle: Constants.FLAVOR_TEXT_COLOR, x: @canvasWidth / 2 - 50, y: @canvasHeight / 3 * 2 + @_getLineOffset(json, lineCount), font: Constants.FLAVOR_FONT)
      lineCount += 1

    if json.taunt
      @art.drawText(text: 'Scut', strokeLineWidth: 3, strokeStyle: Constants.FLAVOR_STROKE_COLOR, fillStyle: Constants.FLAVOR_TEXT_COLOR, x: @canvasWidth / 2 - 30, y: @canvasHeight / 3 * 2 + @_getLineOffset(json, lineCount), font: Constants.FLAVOR_FONT)
      lineCount += 1

    if json.windfury
      @art.drawText(text: 'Windfury', strokeLineWidth: 3, strokeStyle: Constants.FLAVOR_STROKE_COLOR, fillStyle: Constants.FLAVOR_TEXT_COLOR, x: @canvasWidth / 2 - 50, y: @canvasHeight / 3 * 2 + @_getLineOffset(json, lineCount), font: Constants.FLAVOR_FONT)
      lineCount += 1

    for onPlayEffect in json.onPlay
      s = '?'
      if onPlayEffect.dmg?
        s = onPlayEffect.dmg.toString()
        s = "+#{s}" if onPlayEffect.dmg > 0
        s += " viață"

      s += @_flavorTextTarget(onPlayEffect)

      lineCountOffset = @_getLineOffset(json, lineCount)
      cw = s.size()
      @art.drawText(text: s, strokeLineWidth: 3, strokeStyle: Constants.FLAVOR_STROKE_COLOR, fillStyle: Constants.FLAVOR_TEXT_COLOR, x: @canvasWidth / 2 - cw / 2 * 10 - 10, y: @canvasHeight / 3 * 2 + lineCountOffset, font: Constants.FLAVOR_FONT)
      lineCount += 1

    nameType = if json.nameCurve? then 'drawBezier' else 'drawText'
    @art[nameType](
      curve: json.nameCurve
      text: json.name
      x: json.nameX || 0, y: (json.nameY || @canvasHeight / 2 + 22) + (json.nameAddY || 0)
      fillStyle: fillStyle
      strokeStyle: Constants.STROKE_COLOR
      letterPadding: json.nameLetterPadding || 6
      font: "#{json.nameFontSize || 50}px Pirata One"
    )

    Helper.materialFromCanvas(@art.canvas)

  _getLineOffset: (json, lineCount) ->
    totalLineCount = @_countFlavorTextLines(json)

    lineCountOffset = switch totalLineCount
      when 1
        50 + lineCount * 40
      when 2
        30 + lineCount * 40
      when 3
        10 + lineCount * 40
      else
        0
    lineCountOffset

  _countFlavorTextLines: (json) ->
    totalLineCount = 0
    for onPlayEffect in json.onPlay
      totalLineCount += 1 if onPlayEffect.dmg?
    totalLineCount += 1 if json.charge
    totalLineCount += 1 if json.windfury
    totalLineCount += 1 if json.taunt
    totalLineCount

  _flavorTextTarget: (onPlayEffect) ->
    return '' if onPlayEffect.target
    return ' la toți' if onPlayEffect.ownMinions and onPlayEffect.ownHero and onPlayEffect.enemyMinions and onPlayEffect.enemyHero
    return ' la aliați' if onPlayEffect.ownMinions and onPlayEffect.ownHero and !onPlayEffect.enemyMinions and !onPlayEffect.enemyHero
    return ' la inamici' if !onPlayEffect.ownMinions and !onPlayEffect.ownHero and onPlayEffect.enemyMinions and onPlayEffect.enemyHero
    return ' la eroul tău' if !onPlayEffect.ownMinions and onPlayEffect.ownHero and !onPlayEffect.enemyMinions and !onPlayEffect.enemyHero
    return ' la eroul inamic' if !onPlayEffect.ownMinions and !onPlayEffect.ownHero and !onPlayEffect.enemyMinions and onPlayEffect.enemyHero
    return ' la minionii tăi' if onPlayEffect.ownMinions and !onPlayEffect.ownHero and !onPlayEffect.enemyMinions and !onPlayEffect.enemyHero
    return ' la minionii inamici' if !onPlayEffect.ownMinions and !onPlayEffect.ownHero and onPlayEffect.enemyMinions and !onPlayEffect.enemyHero
    return ' la eroi' if !onPlayEffect.ownMinions and onPlayEffect.ownHero and !onPlayEffect.enemyMinions and onPlayEffect.enemyHero
    return ' la minioni' if onPlayEffect.ownMinions and !onPlayEffect.ownHero and onPlayEffect.enemyMinions and !onPlayEffect.enemyHero
    '!'

  _iconTextHelper: (json, which, attr, start, offset) ->
    def = start - offset

    i = 0
    s = json[which][attr].toString()
    while i < s.length # 1 is shorter in width
      def += 9 if s[i] == '1'
      i++

    if json[which][attr] == 1
      def -= 6
    if json[which][attr] >= 10 or json[which][attr] <= -10 # length
      def -= 15
    if json[which][attr] < 0 # minus
      def -= 10
    def

  _getStatsHealthX: (json) ->
    @_iconTextHelper(json, 'stats', 'health', @canvasWidth, 80)

  _getDefaultHealthX: (json) ->
    @_iconTextHelper(json, 'defaults', 'health', @canvasWidth, 40)

  _getStatsAttackX: (json) ->
    @_iconTextHelper(json, 'stats', 'attack', 34, 0)

  _getDefaultAttackX: (json) ->
    @_iconTextHelper(json, 'defaults', 'attack', 22, 0)

  _getDefaultCostX: (json) ->
    @_iconTextHelper(json, 'defaults', 'cost', 18, 0)


  release: ->
    @mesh.scale.set 1, 1, 1
    @pivot.rotation.set 0, 0, 0
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
