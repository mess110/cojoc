Constants = require('../game/Constants.coffee').Constants unless Constants?
Cards = require('../game/models/Cards.coffee').Cards unless Cards?
BaseReferee = require('./BaseReferee.coffee').BaseReferee unless BaseReferee?

# The referee class has 2 main responsabilities. Even writing this screams
# split in 2 classes.
#
# The class stores the game state. Each input in the state is processed by
# the tick method, one by one. Each input can generate one or more actions
# which are in turn processed one by one.
#
# The actions are processed on the client while the inputs are only processed
# on the server. They can also be processed on the client if it is a bot game
#
# The referee should not know any information about who the player is, instead
# it should rely on the playerIndex
class ArenaReferee extends BaseReferee
  constructor: () ->
    super()
    allCards = Cards.random(60)
    @json =
      gameType: Constants.GameType.Arena
      phase: Constants.Phase.Arena.HeroSelect
      actions: []
      player1: {}
      player2: {}
      cards: Cards.heroes().shuffle().concat(Cards.heroes().shuffle()).concat(allCards)

    @inputs = [
      { type: 'gameInput', processed: false, action: Constants.Input.START_GAME }
    ]

  tick: ->
    return if @processing
    input = @inputs.where(processed: false).first()
    return unless input?

    console.ce "Processing input: #{JSON.stringify(input)}"

    @processing = true
    input.processed = true

    if input.action == Constants.Input.START_GAME
      @_addAction { duration: 200, playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 0 }
      @_addAction { duration: 350, playerIndex: 'player1', action: Constants.Action.HOLD_CARD, cardId: 0 }
      @_addAction { duration: 200, playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 3 }
      @_addAction { duration: 350, playerIndex: 'player2', action: Constants.Action.HOLD_CARD, cardId: 3 }
      @_addAction { duration: 200, playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 1 }
      @_addAction { duration: 350, playerIndex: 'player1', action: Constants.Action.HOLD_CARD, cardId: 1 }
      @_addAction { duration: 200, playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 4 }
      @_addAction { duration: 350, playerIndex: 'player2', action: Constants.Action.HOLD_CARD, cardId: 4 }
      @_addAction { duration: 200, playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 2 }
      @_addAction { duration: 350, playerIndex: 'player1', action: Constants.Action.HOLD_CARD, cardId: 2 }
      @_addAction { duration: 200, playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 5 }
      @_addAction { duration: 350, playerIndex: 'player2', action: Constants.Action.HOLD_CARD, cardId: 5 }

    if input.action == Constants.Input.SELECT_CARD
      card = @json.cards[input.cardId]
      @json[input.playerIndex].hero = input.cardId
      console.log card

    @processing = false

  _addAction: (action) ->
    if action.action == Constants.Action.DRAW_CARD
      card = @json.cards[action.cardId]
      card.playerIndex = action.playerIndex

    action.index = @json.actions.length
    @json.actions.push action

exports.ArenaReferee = ArenaReferee
