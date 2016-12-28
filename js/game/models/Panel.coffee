class Panel extends BoxedModel
  constructor: ->
    super()

    @width = 5
    @height = 1
    @mesh = new THREE.Object3D()

    @text = new BigText()
    @mesh.add @text.mesh

    @box = new THREE.Mesh(
      new THREE.BoxGeometry(@width, @height, 0.1),
      @_boxMaterial()
    )
    @mesh.add @box

  setText: (s) ->
    @text.setText(s)
