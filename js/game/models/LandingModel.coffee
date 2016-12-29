class LandingModel extends BaseModel
  constructor: (index)->
    super()

    allModels = [
      {
        key: 'putinei'
        position: new THREE.Vector3(1.2, -1, 6)
        rotation: new THREE.Euler(0, 0, -0.2)
        scale: new THREE.Vector3(2, 2, 2)
        animate: 0
      }
      {
        key: 'chest'
        position: new THREE.Vector3(3, -2, 0)
        rotation: new THREE.Euler(0.3, 0, 0)
        animate: 0
      }
    ]
    if index?
      selected = allModels[index]
    else
      selected = allModels.shuffle().first()

    @model = new THREE.Object3D()
    @model.position.copy selected.position if selected.position?
    @model.rotation.copy selected.rotation if selected.rotation?
    @model.scale.copy selected.scale if selected.scale?
    @mesh = JsonModelManager.get().clone(selected.key)
    @model.add @mesh
    if selected.animate?
      @animate(selected.animate)

  tick: (tpf) ->
    @mesh.rotation.y += tpf / 2
