Constants = require('../../game/Constants.coffee').Constants unless Constants?

class ArenaBot
  constructor: (referee) ->
    @referee = referee
    @enabled = @referee.botEnabled

  addEndTurnAction: (input) ->
    return unless @isEnabled()
    otherIndex = @referee._getOtherPlayerIndex(input.playerIndex)
    # only do it on bot turn
    if otherIndex == @referee.json.turn
      @_selectCard(input)
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

  isEnabled: ->
    @enabled

exports.ArenaBot = ArenaBot
