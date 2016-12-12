class GameScene extends BaseScene
  init: (options) ->
    if options.id != 'bot'
      NetworkManager.emit(type: 'join', id: options.id)
      console.ce "#{options.id} game"
    else
      console.ce 'bot game'

    @referee = new ArenaReferee()

    Helper.orbitControls(engine)
    @tree = new Tree()
    @scene.add @tree.mesh
    @wind = 0

  tick: (tpf) ->
    return unless @tree?
    @wind += tpf + Math.random()
    @tree.wind(@wind)

  doKeyboardEvent: (event) ->

  doMouseEvent: (event, raycaster) ->
