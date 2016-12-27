class GameScene extends BaseScene
  init: (options) ->
    @options = options
    console.ce "#{@options.id} game"

    @game = new Game(autoStart: false)
    if @_isBotGame()
      @game.afterServerTick = afterServerTick
      @game.startTicking()

    @_emit(type: 'join', id: @options.id)

  uninit: ->
    super()
    @game.stopTicking() if @game?

  afterServerTick: (data) ->
    @game.doIt(@scene, data)

  tick: (tpf) ->

  doKeyboardEvent: (event) ->

  doMouseEvent: (event, raycaster) ->

  _isBotGame: ->
    @options.id == 'bot'

  _emit: (data) ->
    throw new Error('type missing from data') unless data.type?
    if @_isBotGame()
      @game[data.type]({}, data)
    else
      NetworkManager.emit(data)
