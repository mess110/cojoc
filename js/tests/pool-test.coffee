poolTest = ->
  engine.camera.position.z = 100
  Helper.orbitControls(engine)
  scene = SceneManager.currentScene()

  PoolManager.on 'spawn', Card, (item) ->
    pos = Helper.random(-5, 5)
    # textures do not use a pool
    # item.impersonate(Cards.shuffle().first())
    item.mesh.position.set pos, 0, pos
    item.move(target: { y: 15 }, duration: 2000)
    new FadeModifier(item, 0, 1, 500).start()
    new FadeModifier(item, 1, 0, 500).delay(1500).start()
    SceneManager.currentScene().scene.add item.mesh

  PoolManager.onRelease Card, (item) ->
    SceneManager.currentScene().scene.remove item.mesh

  scene.spawn = ->
    item = PoolManager.spawn(Card)

    setTimeout ->
      if SceneManager.currentScene().poolInterval?
        PoolManager.release(item)
    , 2000

  scene.poolInterval = setInterval ->
    console.log PoolManager.get().toString()
    SceneManager.currentScene().spawn()
  , 50

  scene.clearTests = ->
    clearInterval(scene.poolInterval)
    scene.poolInterval = undefined
    PoolManager.releaseAll()

  scene.afterCinematic = (tpf) ->
