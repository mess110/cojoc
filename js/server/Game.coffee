server = require('../../bower_components/coffee-engine/src/server/server.coffee')

Constants = require('../game/Constants.coffee').Constants unless Constants?
ArenaReferee = require('./ArenaReferee.coffee').ArenaReferee unless ArenaReferee?
GameInstance = server.GameInstance unless GameInstance?

class Game extends GameInstance
  constructor: (config, socket1, socket2) ->
    super(config)
    @referee = new ArenaReferee()

    if socket1? && socket2?
      @player1 = { socketId: socket1.id, owner: 'dummy' }
      @socket1 = socket1
      socket1.emit('startGame', @toJson())

      @player2 = { socketId: socket2.id, owner: 'dummy' }
      @socket2 = socket2
      socket2.emit('startGame', @toJson())

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
      @player1 = { owner: Constants.Storage.BOT }
      @player2 = { owner: data.owner }
      data.playerIndex = if @player1.owner == Constants.Storage.bot then 'player2' else 'player1'
    else
      @_setPlayerIndex(data)
      if data.playerIndex?
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
      @referee.gameInput(data)
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
  _setPlayerIndex: (data) ->
    if @player1.socketId?
      if @player1.socketId == data.ownerId
        data.playerIndex = 'player1'
      if @player2.socketId == data.ownerId
        data.playerIndex = 'player2'
    else
      if @player1.owner == data.owner
        data.playerIndex = 'player1'
      if @player2.owner == data.owner
        data.playerIndex = 'player2'

    data

exports.Game = Game
