Constants = require('../../game/Constants.coffee').Constants unless Constants?
Cards = require('../../game/models/Cards.coffee').Cards unless Cards?
BaseReferee = require('../BaseReferee.coffee').BaseReferee unless BaseReferee?

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
  DRAW_CARD_DURATION = 200
  DISCOVER_CARD_DURATION = 500
  SELECT_CARD_DURATION = 100

  constructor: (bot) ->
    super(bot)
    allCards = Cards.random(60)
    @json =
      gameType: Constants.GameType.ARENA
      phase: Constants.Phase.Arena.HERO_SELECT
      actions: []
      player1: {}
      player2: {}
      cards: Cards.heroes().shuffle().concat(Cards.heroes().shuffle()).concat(allCards)
      turn: 'player1'

    @_assignCardIdToCards()
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
        @addAction { duration: DRAW_CARD_DURATION, playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 0 }
        @addAction { duration: DISCOVER_CARD_DURATION, playerIndex: 'player1', action: Constants.Action.DISCOVER_CARD, cardId: 0 }
        @addAction { duration: DRAW_CARD_DURATION, playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 3 }
        @addAction { duration: DISCOVER_CARD_DURATION, playerIndex: 'player2', action: Constants.Action.DISCOVER_CARD, cardId: 3 }
        @addAction { duration: DRAW_CARD_DURATION, playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 1 }
        @addAction { duration: DISCOVER_CARD_DURATION, playerIndex: 'player1', action: Constants.Action.DISCOVER_CARD, cardId: 1 }
        @addAction { duration: DRAW_CARD_DURATION, playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 4 }
        @addAction { duration: DISCOVER_CARD_DURATION, playerIndex: 'player2', action: Constants.Action.DISCOVER_CARD, cardId: 4 }
        @addAction { duration: DRAW_CARD_DURATION, playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 2 }
        @addAction { duration: DISCOVER_CARD_DURATION, playerIndex: 'player1', action: Constants.Action.DISCOVER_CARD, cardId: 2 }
        @addAction { duration: DRAW_CARD_DURATION, playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 5 }
        @addAction { duration: DISCOVER_CARD_DURATION, playerIndex: 'player2', action: Constants.Action.DISCOVER_CARD, cardId: 5 }
      when Constants.Input.SELECT_CARD
        actionName = if @isPhase(Constants.Phase.Arena.HERO_SELECT) then Constants.Action.SELECT_HERO else Constants.Action.SELECT_CARD

        action = { duration: SELECT_CARD_DURATION, playerIndex: input.playerIndex, action: actionName }
        action.cardId = input.cardId
        @addAction action

        if @bot
          if @json.turn == otherIndex || @isPhase(Constants.Phase.Arena.HERO_SELECT)
            otherIndex = @_getOtherPlayerIndex(input.playerIndex)
            botAction = JSON.parse(JSON.stringify(action))
            botAction.playerIndex = otherIndex
            botAction.cardId = @findCards(playerIndex: otherIndex, status: Constants.CardStatus.DISCOVERED).shuffle().first().cardId
            @addAction botAction

        if @isPhase(Constants.Phase.Arena.HERO_SELECT)
          if @isHeroChosen('player1') and @isHeroChosen('player2')
            @json.phase = Constants.Phase.Arena.BATTLE
            @addAction { duration: 300, playerIndex: @json.turn, action: Constants.Action.UPDATE_END_TURN_BUTTON }

            cards = @findCards(status: undefined)
            @addAction { duration: DRAW_CARD_DURATION, playerIndex: @json.turn, action: Constants.Action.DRAW_CARD, cardId: cards[0].cardId }
            @addAction { duration: DISCOVER_CARD_DURATION, playerIndex: @json.turn, action: Constants.Action.DISCOVER_CARD, cardId: cards[0].cardId }
            @addAction { duration: DRAW_CARD_DURATION, playerIndex: @json.turn, action: Constants.Action.DRAW_CARD, cardId: cards[1].cardId }
            @addAction { duration: DISCOVER_CARD_DURATION, playerIndex: @json.turn, action: Constants.Action.DISCOVER_CARD, cardId: cards[1].cardId }
            @addAction { duration: DRAW_CARD_DURATION, playerIndex: @json.turn, action: Constants.Action.DRAW_CARD, cardId: cards[2].cardId }
            @addAction { duration: DISCOVER_CARD_DURATION, playerIndex: @json.turn, action: Constants.Action.DISCOVER_CARD, cardId: cards[2].cardId }
      when Constants.Input.END_TURN
        @_addEndTurnAction()

        if @bot
          otherIndex = @_getOtherPlayerIndex(input.playerIndex)
          botAction = { duration: SELECT_CARD_DURATION, action: Constants.Action.SELECT_CARD }
          botAction.playerIndex = otherIndex
          botAction.cardId = @findCards(playerIndex: otherIndex, status: Constants.CardStatus.DISCOVERED).shuffle().first().cardId
          @addAction botAction
          @_addEndTurnAction()
      else
        console.log "Unknown input action #{input.action}"

    @processing = false

  _addEndTurnAction: ->
    @json.turn = @_getOtherPlayerIndex(@json.turn)
    @addAction { duration: 300, playerIndex: @json.turn, action: Constants.Action.UPDATE_END_TURN_BUTTON }

    cards = @findCards(status: undefined)
    @addAction { duration: DRAW_CARD_DURATION, playerIndex: @json.turn, action: Constants.Action.DRAW_CARD, cardId: cards[0].cardId }
    @addAction { duration: DISCOVER_CARD_DURATION, playerIndex: @json.turn, action: Constants.Action.DISCOVER_CARD, cardId: cards[0].cardId }
    @addAction { duration: DRAW_CARD_DURATION, playerIndex: @json.turn, action: Constants.Action.DRAW_CARD, cardId: cards[1].cardId }
    @addAction { duration: DISCOVER_CARD_DURATION, playerIndex: @json.turn, action: Constants.Action.DISCOVER_CARD, cardId: cards[1].cardId }
    @addAction { duration: DRAW_CARD_DURATION, playerIndex: @json.turn, action: Constants.Action.DRAW_CARD, cardId: cards[2].cardId }
    @addAction { duration: DISCOVER_CARD_DURATION, playerIndex: @json.turn, action: Constants.Action.DISCOVER_CARD, cardId: cards[2].cardId }

  addAction: (action) ->
    if action.action == Constants.Action.DRAW_CARD
      card = @findCard(action.cardId)
      card.playerIndex = action.playerIndex
      card.status = Constants.CardStatus.DISCOVERED
    if action.action == Constants.Action.SELECT_HERO
      card = @findCard(action.cardId)
      @json[action.playerIndex].hero = action.cardId
      card.status = Constants.CardStatus.HERO
      action.discardIds = []
      for dCard in @findCards(playerIndex: action.playerIndex, status: Constants.CardStatus.DISCOVERED)
        if dCard.cardId != card.cardId
          dCard.status = Constants.CardStatus.DISCARDED
          action.discardIds.push dCard.cardId
    if action.action == Constants.Action.SELECT_CARD
      card = @findCard(action.cardId)
      card.status = Constants.CardStatus.HELD
      action.discardIds = []
      for dCard in @findCards(playerIndex: action.playerIndex, status: Constants.CardStatus.DISCOVERED)
        if dCard.cardId != card.cardId
          dCard.status = Constants.CardStatus.DISCARDED
          action.discardIds.push dCard.cardId
    super(action)

  addInput: (input) ->
    if @isPhase(Constants.Phase.Arena.HERO_SELECT)
      card = @findCard(input.cardId)
      if card.playerIndex == input.playerIndex and !@isHeroChosen(input.playerIndex)
        super(input)

    if @isPhase(Constants.Phase.Arena.BATTLE)
      if input.action == Constants.Input.END_TURN
        if input.playerIndex == @json.turn
          console.log input
          super(input)
      else
        card = @findCard(input.cardId)
        return if card.status == Constants.CardStatus.HERO && input.action == Constants.Action.SELECT_CARD
        if card.playerIndex == input.playerIndex
          super(input)

  isHeroChosen: (playerIndex) ->
    @json[playerIndex].hero?

  _getOtherPlayerIndex: (playerIndex) ->
    return 'player2' if playerIndex == 'player1'
    return 'player1' if playerIndex == 'player2'
    throw "unknown playerIndex #{playerIndex}"

  _assignCardIdToCards: ->
    i = 0
    for card in @json.cards
      card.cardId = i
      i += 1

exports.ArenaReferee = ArenaReferee
