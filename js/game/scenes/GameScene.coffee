# Each game scene has a game and a mover.
#
# The mover needs to correspond to the game.referee because a certain game type
# can only be handled by a certain mover. Example: ArenaReferee is compatible
# with ArenaMover
class GameScene extends BaseScene
  init: (options) ->
    engine.camera.position.set 0, 0, 15
    @options = options
    console.ce "#{@options.id} game"

    @game = new Game(id: @options.id, autoStart: false)
    @mover = new ArenaMover(@)

    persist = Persist.sessionStorage()
    @myId = persist.get(Constants.Storage.CURRENT_ID)

    if @game.isBotGame()
      @game.afterServerTick = afterServerTick
      @game.startTicking()

    @_emit(type: 'join', id: @options.id)

  uninit: ->
    super()
    @game.stopTicking() if @game?

  afterServerTick: (data) ->
    @mover.uiServerTick(data) if @mover?

  tick: (tpf) ->
    @mover.uiTick(tpf) if @mover?

  doKeyboardEvent: (event) ->
    @mover.uiKeyboardEvent(event) if @mover?

  doMouseEvent: (event, raycaster) ->
    @mover.uiMouseEvent(event, raycaster) if @mover?

  toJson: ->
    @game.toJson()

  _emit: (data) ->
    throw new Error('type missing from data') unless data.type?
    data.id = @options.id
    data.owner = @myId
    if @game.isBotGame()
      @game[data.type]({}, NetworkManager.fake(data))
    else
      NetworkManager.emit(data)
