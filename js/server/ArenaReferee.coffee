Constants = require('../game/Constants.coffee').Constants unless Constants?
Cards = require('../game/models/Cards.coffee').Cards unless Cards?

class ArenaReferee
  constructor: (bot) ->
    @processing = false
    @json =
      bot: bot
      gameType: Constants.GameType.Arena
      phase: Constants.Phase.Arena.HeroSelect
      cards: []
      inputs: []
      actions: []
      player1Heroes: Cards.heroes().shuffle()
      player2Heroes: Cards.heroes().shuffle()
      player1Hero: undefined
      player2Hero: undefined

  # This is called by the ticker, before the ui calls doIt
  # it is called on the server if not bot game
  # it is also called on the client if bot game
  tick: ->
    # process the first unprocessed input
    # and add actions accordignly
    @json

  gameInput: (data) ->
    data.processed = false
    @json.inputs.push data

  toJson: ->
    @json

  # ------------------------------- #
  # Methods used only on the client #
  # ------------------------------- #

  # This is called after the referee processed tick only on the client
  doIt: (scene, data) ->
    # if phase == CardSelect
    #   if hero selected
    #     if hero init?
    #       do nothing
    #     else
    #       init hero
    #       processing = true
    #       set not processing timeout 1000
    #   else
    #     if cards moved in position
    #       do nothing
    #     else
    #       move select hero cards in position
    #       processing = true
    #       set not processing timeout 1000
    #
    # return if processing
    # find first unprocessed action
    # return if no action to process
    # processing = true
    # set not processing timeout to the action duration
    # process it

exports.ArenaReferee = ArenaReferee
