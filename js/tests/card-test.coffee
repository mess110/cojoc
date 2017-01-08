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
  info = Cards.randomMinion()
  console.log info
  info.stats = JSON.parse(JSON.stringify(info.defaults))
  info.stats.health -= 1
  scene.card.impersonate(info)
  scene.scene.add scene.card.mesh
