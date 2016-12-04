class MenuScene extends BaseScene
  init: (options) ->
    @landingModel = new LandingModel()
    @scene.add @landingModel.model

    Helper.orbitControls(engine)

    engine.camera.position.set 0, 0, 10
    engine.camera.lookAt Helper.zero.clone()

    @scene.add Helper.ambientLight()
    @scene.add Helper.ambientLight()

    item =
      type: 'particle'
      key: 'fireflies-1'

    @fireflies = Helper.particle(item)
    @scene.add @fireflies.mesh

    light = new (THREE.SpotLight)
    light.position.copy new THREE.Vector3(0, 0, 10)
    light.intensity = 1.25
    light.lookAt(@landingModel.mesh)
    @scene.add light

  tick: (tpf) ->
    @landingModel.tick(tpf)
    @fireflies.tick(tpf)

  doKeyboardEvent: (event) ->

  doMouseEvent: (event, raycaster) ->
