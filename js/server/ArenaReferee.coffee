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
      gameType: Constants.GameType.ARENA
      phase: Constants.Phase.Arena.HERO_SELECT
      actions: []
      player1: {}
      player2: {}
      cards: Cards.heroes().shuffle().concat(Cards.heroes().shuffle()).concat(allCards)

    @inputs = [
      { type: 'gameInput', processed: false, action: Constants.Input.START_GAME }
    ]

  # processes one input per tick
  # only valid inputs are processed
  tick: ->
    return if @processing
    input = @findInput()
    return unless input?

    console.ce "Processing input: #{JSON.stringify(input)}"

    @processing = true
    input.processed = true

    switch input.action
      when Constants.Input.START_GAME
        @addAction { duration: 200, playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 0 }
        @addAction { duration: 350, playerIndex: 'player1', action: Constants.Action.HOLD_CARD, cardId: 0 }
        @addAction { duration: 200, playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 3 }
        @addAction { duration: 350, playerIndex: 'player2', action: Constants.Action.HOLD_CARD, cardId: 3 }
        @addAction { duration: 200, playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 1 }
        @addAction { duration: 350, playerIndex: 'player1', action: Constants.Action.HOLD_CARD, cardId: 1 }
        @addAction { duration: 200, playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 4 }
        @addAction { duration: 350, playerIndex: 'player2', action: Constants.Action.HOLD_CARD, cardId: 4 }
        @addAction { duration: 200, playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 2 }
        @addAction { duration: 350, playerIndex: 'player1', action: Constants.Action.HOLD_CARD, cardId: 2 }
        @addAction { duration: 200, playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 5 }
        @addAction { duration: 350, playerIndex: 'player2', action: Constants.Action.HOLD_CARD, cardId: 5 }
      when Constants.Input.SELECT_CARD
        card = @findCard(input.cardId)
        @json[input.playerIndex].hero = input.cardId
        console.log input
        console.log card
      else
        console.ce "Unknown input action #{input.action}"

    @processing = false

  addAction: (action) ->
    if action.action == Constants.Action.DRAW_CARD
      card = @findCard(action.cardId)
      card.playerIndex = action.playerIndex
    super(action)

  addInput: (input) ->
    if @isPhase(Constants.Phase.Arena.HERO_SELECT)
      card = @findCard(input.cardId)
      if card.playerIndex == input.playerIndex
        super(input)

exports.ArenaReferee = ArenaReferee
