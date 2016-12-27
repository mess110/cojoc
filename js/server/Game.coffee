server = require('../../bower_components/coffee-engine/src/server/server.coffee')

ArenaReferee = require('./ArenaReferee.coffee').ArenaReferee unless ArenaReferee?
GameInstance = server.GameInstance unless GameInstance?

class Game extends GameInstance
  constructor: (config, socket1, socket2) ->
    super(config)
    @bot = !socket2?
    @socket1 = socket1
    @socket2 = socket2

    @socket1.emit('startGame', { id: @id }) unless @bot
    @socket2.emit('startGame', { id: @id }) unless @bot

    @referee = new ArenaReferee(@bot)

  tick: =>
    data = @referee.tick()
    @afterServerTick(data)

  afterServerTick: (data) ->
    @socket1.emit('serverTick', data)
    @socket2.emit('serverTick', data)

  join: (socket, data) ->
    id = if @bot then 'bot' else socket.id
    console.log "#{id} joined #{data.id}"

  gameInput: (socket, data) ->
    console.log "game input from #{socket.id} for #{data.id}"
    @referee.gameInput(data)

  # ------------------------------- #
  # Methods used only on the client #
  # ------------------------------- #

  doIt: (scene, data) ->
    @referee.doIt(scene, data)

  toJson: ->
    {
      id: @id
      bot: @bot
      referee: @referee.toJson()
    }

exports.Game = Game
