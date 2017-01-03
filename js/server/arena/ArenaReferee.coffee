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
    allCards = Cards.random(30 * 3 * 2)
    @json =
      maxCardsInHand: 10
      maxMinionsPlayed: 7
      maxMana: 10
      gameType: Constants.GameType.ARENA
      phase: Constants.Phase.Arena.HERO_SELECT
      actions: []
      player1:
        mana: 0
        maxMana: 0
      player2:
        mana: 0
        maxMana: 0
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

    loop
      input = @findInput()
      break unless input?
      @processOne(input)

    @processing = false

  processOne: (input) ->
    @processing = true
    console.ce "Processing input: #{JSON.stringify(input)}"
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
      when Constants.Input.PLAY_CARD
        @addPlayCardAction(input)
      else
        console.log "Unknown input action #{input.action}"
    input

  addPlayCardAction: (input) ->
    if @hasMinionSpace(input.playerIndex)
      @addAction { duration: 1000, playerIndex: input.playerIndex, action: Constants.Action.SET_MANA, cardId: input.cardId }
      @addAction { playerIndex: input.playerIndex, action: Constants.Action.SUMMON_MINION, cardId: input.cardId }
    else
      console.log 'too many minions in play'

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
      @addAction { playerIndex: @json.turn, action: Constants.Action.SET_MAX_MANA, to: @getMaxMana(@json.turn) + 1 }
      @addAction { playerIndex: @json.turn, action: Constants.Action.REPLENISH_MANA }

      cards = @findCards(status: undefined)
      otherIndex = @_getOtherPlayerIndex(@json.turn)
      @addAction { duration: Constants.Duration.SELECT_CARD, playerIndex: @json.turn, action: Constants.Action.AUTO_SELECT_CARD, cardId: cards[0].cardId }
      @addAction { duration: Constants.Duration.SELECT_CARD, playerIndex: otherIndex, action: Constants.Action.AUTO_SELECT_CARD, cardId: cards[1].cardId }
      @addAction { duration: Constants.Duration.SELECT_CARD, playerIndex: @json.turn, action: Constants.Action.AUTO_SELECT_CARD, cardId: cards[2].cardId }
      @addAction { duration: Constants.Duration.SELECT_CARD, playerIndex: otherIndex, action: Constants.Action.AUTO_SELECT_CARD, cardId: cards[3].cardId }
      @addAction { duration: Constants.Duration.SELECT_CARD, playerIndex: @json.turn, action: Constants.Action.AUTO_SELECT_CARD, cardId: cards[4].cardId }
      @addAction { duration: Constants.Duration.SELECT_CARD, playerIndex: otherIndex, action: Constants.Action.AUTO_SELECT_CARD, cardId: cards[5].cardId }

      @_addDiscoverActions()

  _addStartGameActions: ->
    @addAction { playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 0 }
    @addAction { playerIndex: 'player1', action: Constants.Action.DISCOVER_CARD, cardId: 0 }
    @addAction { playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 3 }
    @addAction { playerIndex: 'player2', action: Constants.Action.DISCOVER_CARD, cardId: 3 }
    @addAction { playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 1 }
    @addAction { playerIndex: 'player1', action: Constants.Action.DISCOVER_CARD, cardId: 1 }
    @addAction { playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 4 }
    @addAction { playerIndex: 'player2', action: Constants.Action.DISCOVER_CARD, cardId: 4 }
    @addAction { playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 2 }
    @addAction { playerIndex: 'player1', action: Constants.Action.DISCOVER_CARD, cardId: 2 }
    @addAction { playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 5 }
    @addAction { playerIndex: 'player2', action: Constants.Action.DISCOVER_CARD, cardId: 5 }

  addEndTurnAction: ->
    @json.turn = @_getOtherPlayerIndex(@json.turn)
    @addAction { duration: Constants.Duration.UPDATE_END_TURN, playerIndex: @json.turn, action: Constants.Action.UPDATE_END_TURN_BUTTON }
    @addAction { playerIndex: @json.turn, action: Constants.Action.SET_MAX_MANA, to: @getMaxMana(@json.turn) + 1 }
    @addAction { playerIndex: @json.turn, action: Constants.Action.REPLENISH_MANA }
    @_addDiscoverActions()

  _addDiscoverActions: ->
    cards = @findCards(status: undefined)
    @addAction { playerIndex: @json.turn, action: Constants.Action.DRAW_CARD, cardId: cards[0].cardId }
    @addAction { playerIndex: @json.turn, action: Constants.Action.DISCOVER_CARD, cardId: cards[0].cardId }
    @addAction { playerIndex: @json.turn, action: Constants.Action.DRAW_CARD, cardId: cards[1].cardId }
    @addAction { playerIndex: @json.turn, action: Constants.Action.DISCOVER_CARD, cardId: cards[1].cardId }
    @addAction { playerIndex: @json.turn, action: Constants.Action.DRAW_CARD, cardId: cards[2].cardId }
    @addAction { playerIndex: @json.turn, action: Constants.Action.DISCOVER_CARD, cardId: cards[2].cardId }

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
      action.duration ?= Constants.Duration.DRAW_CARD
      card = @findCard(action.cardId)
      card.playerIndex = action.playerIndex
      card.status = Constants.CardStatus.DISCOVERED

    if action.action == Constants.Action.DISCOVER_CARD
      action.duration ?= Constants.Duration.DISCOVER_CARD

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

    if action.action == Constants.Action.AUTO_SELECT_CARD
      card = @findCard(action.cardId)
      card.playerIndex = action.playerIndex
      card.status = Constants.CardStatus.HELD

    if action.action == Constants.Action.DISCARD_CARD
      for discardId in action.cardIds
        card = @findCard(discardId)
        card.status = Constants.CardStatus.DISCARDED

    if action.action == Constants.Action.SET_MANA
      card = @findCard(action.cardId)
      @json[action.playerIndex].mana -= card.defaults.cost
      action.mana = @json[action.playerIndex].mana

    if action.action == Constants.Action.SET_MAX_MANA
      throw 'to param missing' unless action.to?
      action.to = if action.to > @json.maxMana then @json.maxMana else action.to
      @json[action.playerIndex].maxMana = action.to
      action.mana = @json[action.playerIndex].mana
      action.maxMana = @json[action.playerIndex].maxMana

    if action.action == Constants.Action.REPLENISH_MANA
      @json[action.playerIndex].mana = @getMaxMana(action.playerIndex)
      action.mana = @json[action.playerIndex].mana
      action.maxMana = @json[action.playerIndex].maxMana

    if action.action == Constants.Action.SUMMON_MINION
      action.duration = Constants.Duration.SUMMON_MINION
      card = @findCard(action.cardId)
      card.status = Constants.CardStatus.PLAYED

    super(action)

  addInput: (input) ->
    if @isPhase(Constants.Phase.Arena.HERO_SELECT)
      card = @findCard(input.cardId)
      if card.playerIndex == input.playerIndex and !@isHeroChosen(input.playerIndex)
        return if card.status == Constants.CardStatus.DISCARDED
        super(input)

    if @isPhase(Constants.Phase.Arena.BATTLE)
      switch input.action
        when Constants.Input.END_TURN
          if @isTurn(input.playerIndex) and !@isDiscovering(input.playerIndex)
            super(input)
        when Constants.Input.SELECT_CARD
          # TODO: find out if we need double select protection
          card = @findCard(input.cardId)
          return if card.status != Constants.CardStatus.DISCOVERED
          return if card.playerIndex != input.playerIndex
          return unless @isTurn(input.playerIndex)
          super(input)
        when Constants.Input.PLAY_CARD
          card = @findCard(input.cardId)
          return if card.status == Constants.CardStatus.HERO
          return if card.status == Constants.CardStatus.DISCARDED
          return if card.playerIndex != input.playerIndex
          return unless @isTurn(input.playerIndex)
          return unless @hasManaFor(input.playerIndex, input.cardId)
          return unless @hasMinionSpace(input.playerIndex)
          super(input)
        else
          console.log "not adding, unknown input action #{input.action}"

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
