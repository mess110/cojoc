Constants = require('../../game/Constants.coffee').Constants unless Constants?

class ArenaBot
  constructor: (referee) ->
    @referee = referee
    @enabled = @referee.botEnabled

  addEndTurnAction: (input) ->
    return unless @isEnabled()
    otherIndex = @referee._getOtherPlayerIndex(input.playerIndex)
    # only do it on bot turn
    return unless @referee.isTurn(otherIndex)
    if !@referee.hasMaxCardsInHand(otherIndex)
      @_selectCard(input)

    for card in @referee.findCards(playerIndex: otherIndex, status: Constants.CardStatus.HELD)
      if @referee.hasManaFor(otherIndex, card.cardId)
        @_playMinion(input, card)
    @referee.addEndTurnAction()

  addSelectHeroAction: (input) ->
    return unless @isEnabled()
    return unless @referee.isPhase(Constants.Phase.Arena.HERO_SELECT)
    @_selectCard(input)

  _selectCard: (input) ->
    inputCopy = JSON.parse(JSON.stringify(input))
    otherIndex = @referee._getOtherPlayerIndex(input.playerIndex)
    inputCopy.playerIndex = otherIndex
    inputCopy.cardId = @referee.findCards(playerIndex: otherIndex, status: Constants.CardStatus.DISCOVERED).shuffle().first().cardId
    @referee.addSelectCardAction(inputCopy)

  _playMinion: (input, card) ->
    inputCopy = JSON.parse(JSON.stringify(input))
    otherIndex = @referee._getOtherPlayerIndex(input.playerIndex)
    inputCopy.playerIndex = otherIndex
    inputCopy.cardId = card.cardId
    @referee.addPlayCardAction(inputCopy)

  isEnabled: ->
    @enabled

exports.ArenaBot = ArenaBot
