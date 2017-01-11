cubeTest = ->
  Helper.orbitControls(engine)
  scene = SceneManager.currentScene()

  PoolManager.onRelease Card, (item) ->
    SceneManager.currentScene().scene.remove item.mesh
    # SceneManager.currentScene().mover.uiCards.remove item
    item.dissolving = false
    item.dissolved = false
    item.glow.original()
    item.front.material = item.ofm
    item.back.material = item.obm
    item.fdm.uniforms.dissolve.value = 0
    item.bdm.uniforms.dissolve.value = 0

  scene.card = PoolManager.spawn(Card)
  info = Cards[0] # Cards.randomMinion()
  scene.card.impersonate(info)
  scene.scene.add scene.card.mesh

  scene.doKeyboardEvent = (event) ->
    if event.type == 'keyup'
      scene.card.impersonate(scene.card.json)
