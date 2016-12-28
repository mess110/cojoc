class GameScene extends BaseScene
  init: (options) ->
    engine.camera.position.set 0, 0, 15
    @options = options
    console.ce "#{@options.id} game"

    @game = new Game(autoStart: false)
    @game.referee.uiAdd(@)

    persist = Persist.sessionStorage()
    console.log NetworkManager.get().socket.socket.sessionid
    @myId = persist.get(Constants.Storage.CURRENT_ID)

    if @_isBotGame()
      @game.afterServerTick = afterServerTick
      @game.startTicking()

    @_emit(type: 'join', id: @options.id)

  uninit: ->
    super()
    @game.stopTicking() if @game?

  afterServerTick: (data) ->
    @game.referee.uiServerTick(data) if @game?

  tick: (tpf) ->
    @game.referee.uiTick(tpf) if @game?

  doKeyboardEvent: (event) ->
    @game.referee.uiKeyboardEvent(event) if @game?

  doMouseEvent: (event, raycaster) ->
    @game.referee.uiMouseEvent(event, raycaster) if @game?

  toJson: ->
    @game.toJson()

  _isBotGame: ->
    @options.id == Constants.Storage.BOT

  _emit: (data) ->
    throw new Error('type missing from data') unless data.type?
    data.id = @options.id
    data.owner = @myId
    if @_isBotGame()
      @game[data.type]({}, data)
    else
      NetworkManager.emit(data)
