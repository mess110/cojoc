class GameScene extends BaseScene
  init: (options) ->
    if options.id != 'bot'
      NetworkManager.emit(type: 'join', id: options.id)
      console.ce "#{options.id} game"
    else
      console.ce 'bot game'

    @referee = new ArenaReferee()

  tick: (tpf) ->

  doKeyboardEvent: (event) ->

  doMouseEvent: (event, raycaster) ->
