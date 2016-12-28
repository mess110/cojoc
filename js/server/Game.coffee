server = require('../../bower_components/coffee-engine/src/server/server.coffee')

ArenaReferee = require('./ArenaReferee.coffee').ArenaReferee unless ArenaReferee?
GameInstance = server.GameInstance unless GameInstance?

class Game extends GameInstance
  constructor: (config, socket1, socket2) ->
    super(config)
    @bot = !socket2?
    @referee = new ArenaReferee(@bot)

    unless @bot
      @player1 = { id: socket1.id }
      @socket1 = socket1
      socket1.emit('startGame', @toJson())

      @player2 = { id: socket2.id }
      @socket2 = socket2
      socket2.emit('startGame', @toJson())

  tick: =>
    data = @referee.tick()
    @afterServerTick(data)

  # Overriden in the case of a bot game
  afterServerTick: (data) ->
    @socket1.emit('serverTick', data)
    @socket2.emit('serverTick', data)

  join: (socket, data) ->
    console.ce "owner #{data.owner} joined #{data.id} with socket #{socket.id}"
    if @bot
      @player1 = { id: Constants.Storage.BOT }
      @player2 = { id: data.owner }

  gameInput: (socket, data) ->
    console.ce "game input from #{socket.id} for #{data.id}"
    @referee.gameInput(data)

  toJson: ->
    {
      id: @id
      bot: @bot
      player1: @player1
      player2: @player2
      referee: @referee.toJson()
    }

exports.Game = Game
