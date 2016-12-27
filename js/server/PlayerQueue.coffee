server = require('../../bower_components/coffee-engine/src/server/server.coffee')
Game = require('./Game.coffee').Game

class PlayerQueue extends server.GameInstance
  constructor: (gameServer) ->
    super(tickPerSecond: 1)
    @gameServer = gameServer
    @queue = []

  enter: (socket) ->
    @queue.push(socket)
    socket

  leave: (socket) ->
    target = @queue.where(id: socket.id).first()
    @queue.remove(target) if target?
    socket

  tick: =>
    return if @queue.isEmpty()
    if @queue.size() >= 2
      socket1 = @queue.shift()
      socket2 = @queue.shift()

      game = new Game(@gameServer.config, socket1, socket2)
      @gameServer._newGame(game)

exports.PlayerQueue = PlayerQueue
