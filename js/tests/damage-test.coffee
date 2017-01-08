damageTest = ->
  Helper.orbitControls(engine)
  scene = SceneManager.currentScene()

  # scene.damage = new Damage()
  # scene.scene.add scene.damage.mesh

  PoolManager.onRelease Damage, (item) ->
    SceneManager.currentScene().scene.remove(item.mesh)

  scene.doKeyboardEvent = (event) ->
    if event.type == 'keyup'
      dmg = PoolManager.spawn(Damage)
      dmg.setText(Helper.random(-5, 5))
      dmg.animate()
      scene.scene.add dmg.mesh
