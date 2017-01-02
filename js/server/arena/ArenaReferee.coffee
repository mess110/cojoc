Constants = require('../../game/Constants.coffee').Constants unless Constants?
Cards = require('../../game/models/Cards.coffee').Cards unless Cards?
BaseReferee = require('../BaseReferee.coffee').BaseReferee unless BaseReferee?
ArenaBot = require('./ArenaBot.coffee').ArenaBot unless ArenaBot?

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
  constructor: (botEnabled) ->
    super(botEnabled)
    @bot = new ArenaBot(@)
    allCards = Cards.random(60)
    @json =
      maxCardsInHand: 10
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
        @_addStartGameActions()
      when Constants.Input.SELECT_CARD
        @addSelectCardAction(input)
        @bot.addSelectHeroAction(input)
        @_addBothHeroesChosenActions()
        @bot.addEndTurnAction(input)
      when Constants.Input.END_TURN
        @addEndTurnAction()
        @bot.addEndTurnAction(input)
      else
        console.log "Unknown input action #{input.action}"

    @processing = false

  addSelectCardAction: (input) ->
    actionName = if @isPhase(Constants.Phase.Arena.HERO_SELECT) then Constants.Action.SELECT_HERO else Constants.Action.SELECT_CARD
    action = { duration: Constants.Duration.SELECT_CARD, playerIndex: input.playerIndex, action: actionName }
    action.cardId = input.cardId
    @addAction action

  _addBothHeroesChosenActions: ->
    return unless @isPhase(Constants.Phase.Arena.HERO_SELECT)
    if @isHeroChosen('player1') and @isHeroChosen('player2')
      @json.phase = Constants.Phase.Arena.BATTLE
      @addAction { duration: Constants.Duration.UPDATE_END_TURN, playerIndex: @json.turn, action: Constants.Action.UPDATE_END_TURN_BUTTON }
      @_addDiscoverActions()

  _addStartGameActions: ->
    @addAction { duration: Constants.Duration.DRAW_CARD, playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 0 }
    @addAction { duration: Constants.Duration.DISCOVER_CARD, playerIndex: 'player1', action: Constants.Action.DISCOVER_CARD, cardId: 0 }
    @addAction { duration: Constants.Duration.DRAW_CARD, playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 3 }
    @addAction { duration: Constants.Duration.DISCOVER_CARD, playerIndex: 'player2', action: Constants.Action.DISCOVER_CARD, cardId: 3 }
    @addAction { duration: Constants.Duration.DRAW_CARD, playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 1 }
    @addAction { duration: Constants.Duration.DISCOVER_CARD, playerIndex: 'player1', action: Constants.Action.DISCOVER_CARD, cardId: 1 }
    @addAction { duration: Constants.Duration.DRAW_CARD, playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 4 }
    @addAction { duration: Constants.Duration.DISCOVER_CARD, playerIndex: 'player2', action: Constants.Action.DISCOVER_CARD, cardId: 4 }
    @addAction { duration: Constants.Duration.DRAW_CARD, playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 2 }
    @addAction { duration: Constants.Duration.DISCOVER_CARD, playerIndex: 'player1', action: Constants.Action.DISCOVER_CARD, cardId: 2 }
    @addAction { duration: Constants.Duration.DRAW_CARD, playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 5 }
    @addAction { duration: Constants.Duration.DISCOVER_CARD, playerIndex: 'player2', action: Constants.Action.DISCOVER_CARD, cardId: 5 }

  addEndTurnAction: ->
    @json.turn = @_getOtherPlayerIndex(@json.turn)
    @addAction { duration: Constants.Duration.UPDATE_END_TURN, playerIndex: @json.turn, action: Constants.Action.UPDATE_END_TURN_BUTTON }
    @_addDiscoverActions()

  _addDiscoverActions: ->
    cards = @findCards(status: undefined)
    @addAction { duration: Constants.Duration.DRAW_CARD, playerIndex: @json.turn, action: Constants.Action.DRAW_CARD, cardId: cards[0].cardId }
    @addAction { duration: Constants.Duration.DISCOVER_CARD, playerIndex: @json.turn, action: Constants.Action.DISCOVER_CARD, cardId: cards[0].cardId }
    @addAction { duration: Constants.Duration.DRAW_CARD, playerIndex: @json.turn, action: Constants.Action.DRAW_CARD, cardId: cards[1].cardId }
    @addAction { duration: Constants.Duration.DISCOVER_CARD, playerIndex: @json.turn, action: Constants.Action.DISCOVER_CARD, cardId: cards[1].cardId }
    @addAction { duration: Constants.Duration.DRAW_CARD, playerIndex: @json.turn, action: Constants.Action.DRAW_CARD, cardId: cards[2].cardId }
    @addAction { duration: Constants.Duration.DISCOVER_CARD, playerIndex: @json.turn, action: Constants.Action.DISCOVER_CARD, cardId: cards[2].cardId }

    # Discard discover cards if the player has max cards in hand
    if @hasMaxCardsInHand(@json.turn)
      @addAction {
        duration: Constants.Duration.DISCARD_CARD
        playerIndex: @json.turn
        action: Constants.Action.DISCARD_CARD
        cardIds: [cards[0].cardId, cards[1].cardId, cards[2].cardId]
      }

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

    if action.action == Constants.Action.DISCARD_CARD
      for discardId in action.cardIds
        card = @findCard(discardId)
        card.status = Constants.CardStatus.DISCARDED

    super(action)

  addInput: (input) ->
    if @isPhase(Constants.Phase.Arena.HERO_SELECT)
      card = @findCard(input.cardId)
      if card.playerIndex == input.playerIndex and !@isHeroChosen(input.playerIndex)
        return if card.status == Constants.CardStatus.DISCARDED
        super(input)

    if @isPhase(Constants.Phase.Arena.BATTLE)
      if input.action == Constants.Input.END_TURN
        if input.playerIndex == @json.turn
          super(input)
      else
        card = @findCard(input.cardId)
        return if card.status == Constants.CardStatus.HERO and input.action == Constants.Action.SELECT_CARD
        return if card.status == Constants.CardStatus.DISCARDED
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