server = require('../../bower_components/coffee-engine/src/server/server.coffee')

ArenaReferee = require('./ArenaReferee.coffee').ArenaReferee unless ArenaReferee?
GameInstance = server.GameInstance unless GameInstance?

class Game extends GameInstance
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
    @socket1.emit('serverTick', data)
    @socket2.emit('serverTick', data)

  join: (socket, data) ->
    console.log "#{socket.id} joined #{data.id}"

  gameInput: (socket, data) ->
    console.log "game input from #{socket.id} for #{data.id}"
    @referee.gameInput(data)

  # ------------------------------- #
  # Methods used only on the client #
  # ------------------------------- #

  doIt: (scene, data) ->
    @referee.doIt(scene, data)

exports.Game = Game
