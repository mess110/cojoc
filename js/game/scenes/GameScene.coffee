class GameScene extends BaseScene
  init: (options) ->
    if options.id != 'bot'
      NetworkManager.emit(type: 'join', id: options.id)
      console.ce "#{options.id} game"
    else
      console.ce 'bot game'
      @game = new Game(ticksPerSecond: 10)
      @game.afterServerTick = afterServerTick

  uninit: ->
    super()
    @game.stopTicking() if @game?

  afterServerTick: (output) ->
    console.log output

  tick: (tpf) ->

  doKeyboardEvent: (event) ->

  doMouseEvent: (event, raycaster) ->
