class ManaCrystal extends BaseModel
  ANIMATION_DURATION = 500

  constructor: ->
    super()
    size = 0.75
    @material = new (THREE.MeshBasicMaterial)(
      map: TextureManager.get().items['mana-crystal']
      side: THREE.DoubleSide
      transparent: true
    )
    @mesh = new THREE.Mesh(new THREE.PlaneBufferGeometry(size, size), @material)
    @material.opacity = 0
    @shaking = false

  shake: () ->
    return if @shaking
    @shaking = true
    new NoticeMeModifier(@, 1, 0.5, ANIMATION_DURATION).delay(0).start()
    new NoticeMeModifier(@, 1, 0.5, ANIMATION_DURATION).delay(ANIMATION_DURATION).start()
    setTimeout =>
      @shaking = false
    , ANIMATION_DURATION * 2

  replenish: ->
    new FadeModifier(@, @mesh.material.opacity, 1, ANIMATION_DURATION).start()

  consume: ->
    new FadeModifier(@, @mesh.material.opacity, 0.4, ANIMATION_DURATION).start()

  hide: ->
    new FadeModifier(@, @mesh.material.opacity, 0, ANIMATION_DURATION).start()

class ManaBar extends BoxedModel
  constructor: () ->
    super()
    @cubes = []
    @maxManaAllowed = 10
    @maxMana = 0
    @currentMana = 0
    @distanceBetweenCrystals = 0.75

    @mesh = new THREE.Object3D()

    @box = new THREE.Mesh(
      new THREE.BoxGeometry(@distanceBetweenCrystals * @maxManaAllowed, 1, 0.1),
      @_boxMaterial()
    )
    @box.position.x = @distanceBetweenCrystals * @maxManaAllowed / 2 - @distanceBetweenCrystals / 2
    @box.position.y = 0
    # @box.position.z = -0.1
    @mesh.add @box

    @manaText = new BigText()
    @manaText.mesh.position.set 1.4, -0.75, -0.01
    @manaText.setText(@toString())
    @manaText.setVisible(false)
    @mesh.add @manaText.mesh

    for i in [0...@maxManaAllowed] by 1
      cube = new ManaCrystal()
      @cubes.push cube
      @mesh.add cube.mesh

    @setGrowDirection()

  setGrowDirection: (left = true) ->
    for i in [0...@maxManaAllowed] by 1
      cube = @cubes[i]
      x = i * @distanceBetweenCrystals
      unless left
        x *= -1
        x += (@maxManaAllowed - 1) * @distanceBetweenCrystals
      cube.mesh.position.set x, 0, 0

  update: (currentMana, maxMana) ->
    return if maxMana == @maxMana and currentMana == @currentMana
    @maxMana = maxMana if maxMana?
    @currentMana = currentMana if currentMana?

    for i in [0...@maxManaAllowed] by 1
      cube = @cubes[i]

      if i < @currentMana
        cube.replenish()
      else if i < @maxMana
        cube.consume()
      else
        cube.hide()

    @manaText.setText(@toString())
    return

  shake: ->
    for cube in @cubes
      cube.shake()
    return

  toString: ->
    @currentMana.toString() + " / " + @maxMana.toString()

  doMouseEvent: (event, raycaster) ->
    hovered = @isHovered(raycaster)
    if hovered != @hovered
      @hovered = hovered
      @manaText.setVisible(@hovered)

  customPosition: (i) ->
    switch i
      when Constants.Position.Player.SELF
        @mesh.position.set -9.1, -7.5, 0
        @mesh.rotation.set 0, 0, 0
        @manaText.mesh.position.set 7.65, -0.5, -0.01
        @setGrowDirection(false)
      when Constants.Position.Player.OPPONENT
        @mesh.position.set 2.25, 7.5, 0
        @mesh.rotation.set 0, 0, 0
        @manaText.mesh.position.set 1.4, -2.5, -0.01
        @setGrowDirection(true)
      else
        throw "invalid customPosition #{i}"
