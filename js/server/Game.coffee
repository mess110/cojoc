server = require('../../bower_components/coffee-engine/src/server/server.coffee')

arenaRef = require('./ArenaReferee.coffee').ArenaReferee
ArenaReferee = arenaRef if arenaRef?

gameInst = server.GameInstance
gameInst = GameInstance unless gameInst?

class Game extends gameInst
  constructor: (config, socket1, socket2) ->
    super(config)
    @socket1 = socket1
    @socket2 = socket2

    @socket1.emit('startGame', { id: @id }) if @socket1
    @socket2.emit('startGame', { id: @id }) if @socket2

    @referee = new ArenaReferee()

  tick: =>
    data = @referee.tick()
    @afterServerTick(data)

  afterServerTick: (data) ->
    # send output to clients

  join: (socket, data) ->
    console.log "#{socket.id} joined #{data.id}"

  gameInput: (socket, data) ->
    console.log "game input from #{socket.id} for #{data.id}"
    @referee.gameInput(data)

exports.Game = Game
