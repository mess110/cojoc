server = require('../../bower_components/coffee-engine/src/server/server.coffee')
common = require('../game/common.coffee')
ArenaReferee = require('./ArenaReferee.coffee').ArenaReferee

class Game extends server.Game
  constructor: (config, socket1, socket2) ->
    super(config)
    @socket1 = socket1
    @socket2 = socket2

    @socket1.emit('startGame', { id: @id })
    @socket2.emit('startGame', { id: @id })

    @referee = new ArenaReferee()

  tick: =>
    @referee.tick()

  join: (socket, data) ->
    console.log "#{socket.id} joined #{data.id}"

  gameInput: (socket, data) ->
    console.log "game input from #{socket.id} for #{data.id}"
    @referee.gameInput(data)

exports.Game = Game
