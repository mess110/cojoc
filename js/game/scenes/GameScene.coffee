# Each game scene has a game and a mover.
#
# The mover needs to correspond to the game.referee because a certain game type
# can only be handled by a certain mover. Example: ArenaReferee is compatible
# with ArenaMover
class GameScene extends BaseScene
  init: (options) ->
    engine.camera.position.set 0, 0, 20
    @options = options
    console.ce "#{@options.id} game"

    @game = new Game(id: @options.id, autoStart: false)
    @mover = new ArenaMover(@)

    if Persist.get(Constants.Storage.TMP_USER)?
      @myId = Persist.get(Constants.Storage.TMP_USER)
    else
      @myId = Persist.sessionStorage().get(Constants.Storage.CURRENT_ID)

    if @game.isBotGame()
      @game.afterServerTick = afterServerTick
      @game.startTicking()

    @_emit(type: 'join', id: @options.id)

  uninit: ->
    super()
    @game.stopTicking() if @game?

  afterServerTick: (data) ->
    # TODO: if @game/@mover is not defined, create it according to the
    # game type
    @mover.uiServerTick(data) if @mover?

  tick: (tpf) ->
    @mover.uiTick(tpf) if @mover?

  doKeyboardEvent: (event) ->
    @mover.uiKeyboardEvent(event) if @mover?

  doMouseEvent: (event, raycaster) ->
    @mover.uiMouseEvent(event, raycaster) if @mover?

  _emit: (data) ->
    throw new Error('type missing from data') unless data.type?
    data.id = @options.id
    data.owner = @myId
    if @game.isBotGame()
      @game[data.type]({}, NetworkManager.fake(data))
    else
      NetworkManager.emit(data)

  toJson: ->
    @game.toJson()

  # This is used to test the client reconnect feature.
  # Call it from DevConsole
  saveTmpUser: ->
    Persist.set(Constants.Storage.TMP_USER, @myId)

  clearTmpUser: ->
    Persist.rm(Constants.Storage.TMP_USER)
