server = require('../../bower_components/coffee-engine/src/server/server.coffee')

Constants = require('../game/Constants.coffee').Constants unless Constants?
ArenaReferee = require('./arena/ArenaReferee.coffee').ArenaReferee unless ArenaReferee?
GameInstance = server.GameInstance unless GameInstance?

class Game extends GameInstance
  constructor: (config, socket1, socket2) ->
    super(config)
    @playerPositionStrategy = Constants.Position.Strategy.QUEUE
    @referee = new ArenaReferee(@isBotGame())

    if socket1? and socket2?
      @_setRealPlayers(socket1, socket2)
      @socket1.emit('startGame', @toJson())
      @socket2.emit('startGame', @toJson())

  tick: =>
    @referee.tick()
    @afterServerTick(@toJson())

  # Overriden in the case of a bot game
  afterServerTick: (data) ->
    @socket1.emit('serverTick', data)
    @socket2.emit('serverTick', data)

  # Sets the owner of the player to the guid the player sent
  # For non-bot games, it checks with the socket.id
  join: (socket, data) ->
    joined = true
    if @isBotGame()
      @_setBotPlayers(data)
    else
      @_setPlayerIndex(data)
      if data.playerIndex?
        @_reinitSocket(socket, data)
        @[data.playerIndex].owner = data.owner
      else
        joined = false

    if joined
      console.ce "owner #{data.owner} joined #{data.id} as #{data.playerIndex} with socket #{socket.id}"

  # player index is always calculated on the server depending on the owner
  # because a client might have the ui reversed
  gameInput: (socket, data) ->
    @_setPlayerIndex(data)
    if data.owner? and data.playerIndex?
      console.ce "game input from #{socket.id} for #{data.id}"
      @referee.addInput(data)
    else
      console.ce "missing owner or playerIndex"
      console.ce data

  toJson: ->
    {
      id: @id
      isBotGame: @isBotGame()
      player1: @player1
      player2: @player2
      referee: @referee.toJson()
    }

  isBotGame: ->
    @id == Constants.Storage.BOT

  # Sets the playerIndex on the input data
  # If the code is running on the server, we first check if the user joined
  # the game previously because that means he wants to reconnect and we need to
  # ignore the socket.id
  _setPlayerIndex: (data) ->
    if @player1.socketId?
      # running on the server
      if @player1.owner?
        data.playerIndex = 'player1' if @player1.owner == data.owner
      else
        data.playerIndex = 'player1' if @player1.socketId == data.ownerId

      if @player2.owner?
        data.playerIndex = 'player2' if @player2.owner == data.owner
      else
        data.playerIndex = 'player2' if @player2.socketId == data.ownerId
    else
      # running on the client
      data.playerIndex = 'player1' if @player1.owner == data.owner
      data.playerIndex = 'player2' if @player2.owner == data.owner

    data

  # if the user reconnects with a different socket, we need to override the
  # used socket
  _reinitSocket: (socket, data) ->
    return if @[data.playerIndex].socketId == socket.id
    @[data.playerIndex].socketId = socket.id
    if data.playerIndex == 'player1'
      @socket1 = socket
    else
      @socket2 = socket

  _setBotPlayers: (data) ->
    randSockets = @_randomStrategy(Constants.Storage.BOT, data.owner)
    @player1 = { owner: randSockets[0] }
    @player2 = { owner: randSockets[1] }
    data.playerIndex = if @player1.owner == Constants.Storage.bot then 'player2' else 'player1'

  _setRealPlayers: (socket1, socket2)->
    randSockets = @_randomStrategy(socket1, socket2)
    @player1 = { socketId: randSockets[0].id }
    @socket1 = randSockets[0]

    @player2 = { socketId: randSockets[1].id }
    @socket2 = randSockets[1]

  _randomStrategy: (first, last)->
    tmp = [first, last]
    strategy = @playerPositionStrategy
    switch strategy
      when Constants.Position.Strategy.RANDOM
        tmp.shuffle()
      when Constants.Position.Strategy.STACK
        tmp.reverse()
      when Constants.Position.Strategy.QUEUE
        tmp
      else
        throw "unknown strategy #{strategy}"

exports.Game = Game
