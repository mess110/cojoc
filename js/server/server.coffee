#!/usr/bin/env coffee

server = require('../../bower_components/coffee-engine/src/server/server.coffee')
PlayerQueue = require('./PlayerQueue').PlayerQueue

config =
  pod:
    id: server.Utils.guid()
    dirname: __dirname
    version: 1
    port: process.env.COJOC_PORT || 1337
  gameServer:
    ticksPerSecond: 10
    ioMethods: ['join', 'gameInput', 'leaveQueue']

class GameServer extends server.GameServer

  constructor: (config) ->
    super(config)
    @queue = new PlayerQueue(@)

  connect: (socket) ->
    socket.emit('connected', config.gameServer)

  disconnect: (socket) ->
    @queue.leave(socket)

  join: (socket, data) ->
    if data.id?
      game = @getGame(data.id)
      unless game?
        console.log "ERROR: game #{data.id} not found"
        socket.emit('goToMenu', data)
        return
      game.join(socket, data)
    else
      @queue.push(socket)

  leaveQueue: (socket, data) ->
    @queue.leave(socket)

  gameInput: (socket, data) ->
    game = @getGame(data.id)
    game.gameInput(socket, data)

  _newGame: (game) ->
    @games.push game


gameServer = new GameServer(config.gameServer)
pod = new server.Pod(config.pod, gameServer)

pod.app.get '/info', (req, res) ->
  hash =
    pod: config.pod
    keys: pod.keys()

  res.send hash

pod.listen()
