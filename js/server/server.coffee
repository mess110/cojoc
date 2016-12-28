#!/usr/bin/env coffee

server = require('../../bower_components/coffee-engine/src/server/server.coffee')
PlayerQueue = require('./PlayerQueue').PlayerQueue
Constants = require('../game/Constants.coffee').Constants

config =
  pod:
    id: server.Utils.guid()
    dirname: __dirname
    version: 1
    port: process.env.COJOC_PORT || 1337
  gameServer:
    autoStart: true
    ticksPerSecond: 10
    ioMethods: ['join', 'gameInput', 'leaveQueue', 'joinQueue']

class GameServer extends server.GameServer

  constructor: (config) ->
    super(config)
    @queue = new PlayerQueue(@)

  connect: (socket) ->
    socket.emit('connected', config.gameServer)

  disconnect: (socket) ->
    @queue.leave(socket)

  join: (socket, data) ->
    console.log data
    if !(data? && data.id?)
      console.log 'ERROR: data.id missing'
      socket.emit('error', code: Constants.Errors.MISSING_GAME_ID, message: 'Missing game id')
      return

    game = @getGame(data.id)
    unless game?
      console.log "ERROR: game #{data.id} not found"
      socket.emit('error', code: Constants.Errors.GAME_NOT_FOUND, message: "Game with id #{data.id} not found")
      return
    game.join(socket, data)

  joinQueue: (socket, data) ->
    @queue.enter(socket)

  leaveQueue: (socket, data) ->
    @queue.leave(socket)

  gameInput: (socket, data) ->
    console.log data
    game = @getGame(data.id)
    game.gameInput(socket, data)

  _newGame: (game) ->
    @games.push game


gameServer = new GameServer(config.gameServer)
pod = new server.Pod(config.pod, gameServer)

pod.app.get '/info', (req, res) ->
  hash =
    pod:
      id: config.pod.id
      version: config.pod.version
      port: config.pod.port
    sockets:
      count: pod.keys().length
      keys: pod.keys()
    queue:
      count: gameServer.queue.queue.length
      keys: gameServer.queue.queue.map (e) -> e.id
    games:
      count: gameServer.games.length
      keys: gameServer.games.map (g) -> g.id
      urls: gameServer.games.map (g) -> "/games/#{g.id}"

  res.send hash

pod.app.get '/games/:id', (req, res) ->
  hash = gameServer.getGame(req.params.id)
  if hash?
    # res.send hash.json
    res.send hash.toJson()
  else
    res.status(404)
    res.send { code: 404, message: 'game not found' }

pod.listen()
