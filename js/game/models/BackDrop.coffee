class BackDrop extends BaseModel

  constructor: ->
    material = new (THREE.MeshBasicMaterial)(
      color: 'black'
      # side: THREE.DoubleSide,
      transparent: true
    )
    geometry = new (THREE.PlaneBufferGeometry)(500, 500)
    @mesh = new (THREE.Mesh)(geometry, material)

    @setOpacity(0)

  animate: ->
    new FadeModifier(@, 0, 0.6, 1000).start()
