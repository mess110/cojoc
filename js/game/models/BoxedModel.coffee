class BoxedModel extends BaseModel

  isHovered: (raycaster) ->
    raycaster.intersectObject(@box).length > 0

  toggleWireframe: ->
    @box.material.opacity = if @box.material.opacity == 0 then 0.4 else 0

  _boxMaterial: ->
    new THREE.MeshNormalMaterial(
      transparent: true
      opacity: 0
      wireframe: true
      # needed because opacity: 0 wireframe: true is shown on top of another
      # transparent material
      depthWrite: false
    )
