class CardsScene extends BaseScene
  init: (options) ->
    @card = new Card()
    @scene.add @card.mesh

    Helper.orbitControls(engine)


  tick: (tpf) ->

  doKeyboardEvent: (event) ->

  doMouseEvent: (event, raycaster) ->
