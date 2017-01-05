BaseModel::shake = (from = 1, to = 0.5) ->
  return if @shaking
  @shaking = true
  new NoticeMeModifier(@, from, to, 500).delay(0).start()
  new NoticeMeModifier(@, from, to, 500).delay(500).start()
  setTimeout =>
    @shaking = false
  , 500 * 2

class BoxedModel extends BaseModel

  isHovered: (raycaster) ->
    raycaster.intersectObject(@box).length > 0

  getIntersection: (raycaster) ->
    raycaster.intersectObject(@box).first()

  toggleWireframe: ->
    @box.material.opacity = if @box.material.opacity == 0 then 0.4 else 0

  setWireframe: (bool) ->
    @box.material.opacity = if !bool then 0.4 else 0

  _boxMaterial: ->
    new THREE.MeshNormalMaterial(
      transparent: true
      opacity: 0
      wireframe: true
      # needed because opacity: 0 wireframe: true is shown on top of another
      # transparent material
      depthWrite: false
    )
