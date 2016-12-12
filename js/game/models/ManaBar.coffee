class ManaCrystal extends BaseModel
  ANIMATION_DURATION = 500

  constructor: ->
    super()
    size = 0.5
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

class ManaBar extends BaseModel
  constructor: () ->
    super()
    @cubes = []
    @maxManaAllowed = 10
    @maxMana = 0
    @currentMana = 0
    @distanceBetweenCrystals = 0.5

    @mesh = new THREE.Object3D()

    @box = new THREE.Mesh(
      new THREE.BoxGeometry( @distanceBetweenCrystals * @maxManaAllowed, 1, 0.1 ),
      new THREE.MeshNormalMaterial(
        transparent: true
        opacity: 0.4
        wireframe: true
      )
    )
    @box.position.x = @distanceBetweenCrystals * @maxManaAllowed / 2 - @distanceBetweenCrystals / 2
    @box.position.y = 0.2
    @box.visible = false
    @mesh.add @box

    @manaText = new CojocText()
    @manaText.mesh.position.set 0.3, 0, -0.01
    @manaText.setText(@toString())
    @mesh.add @manaText.mesh

    for i in [0...@maxManaAllowed] by 1
      cube = new ManaCrystal()
      cube.mesh.position.set i * @distanceBetweenCrystals, 0, 0

      @cubes.push cube
      @mesh.add cube.mesh

  isHovered: (raycaster) ->
    raycaster.intersectObject(@box).length > 0

  toggleWireframe: ->
    @box.visible = !@box.visible

  update: (currentMana, maxMana) ->
    return if maxMana == @maxMana and currentMana == @currentMana

    for i in [0...@maxManaAllowed] by 1
      cube = @cubes[i]

      if i < currentMana
        cube.replenish()
      else if i < maxMana
        cube.consume()
      else
        cube.hide()

    @maxMana = maxMana
    @currentMana = currentMana
    @manaText.setText(@toString())
    return

  shake: ->
    for cube in @cubes
      cube.shake()
    return

  toString: ->
    @currentMana.toString() + " / " + @maxMana.toString()
