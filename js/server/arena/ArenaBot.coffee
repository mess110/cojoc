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
    return if @referee.addFinishedAction()
    if !@referee.hasMaxCardsInHand(otherIndex)
      @_selectCard(input)

    for card in @referee.findCards(playerIndex: otherIndex, status: Constants.CardStatus.HELD)
      if @referee.hasManaFor(otherIndex, card.cardId)
        @_playCard(input, card)

    for minion in @referee.findCards(playerIndex: otherIndex, status: Constants.CardStatus.PLAYED)
      if @referee.hasTauntMinions(input.playerIndex)
        playerAttackableCards = @referee.findCards(playerIndex: input.playerIndex, taunt: true, status: Constants.CardStatus.PLAYED).shuffle()
      else
        playerAttackableCards = @referee.findCards(playerIndex: input.playerIndex, status: Constants.CardStatus.PLAYED)
        playerAttackableCards = playerAttackableCards.concat(@referee.findCards(playerIndex: input.playerIndex, status: Constants.CardStatus.HERO)).shuffle()
      while minion.attacksLeft > 0 and playerAttackableCards.any()
        @referee.addAttackAction { action: Constants.Action.ATTACK, playerIndex: otherIndex, cards: [minion.cardId, playerAttackableCards.first().cardId] }
        return if @referee.addFinishedAction()
    @referee.addEndTurnAction()

  addSelectHeroAction: (input) ->
    return unless @isEnabled()
    return unless @referee.isPhase(Constants.Phase.Arena.HERO_SELECT)
    @_selectCard(input)

  _selectCard: (input) ->
    inputCopy = JSON.parse(JSON.stringify(input))
    otherIndex = @referee._getOtherPlayerIndex(input.playerIndex)
    inputCopy.playerIndex = otherIndex
    possibleCards = @referee.findCards(playerIndex: otherIndex, status: Constants.CardStatus.DISCOVERED)
    if possibleCards.any()
      inputCopy.cardId = possibleCards.shuffle().first().cardId
      @referee.addSelectCardAction(inputCopy)
    return

  _playCard: (input, card) ->
    inputCopy = JSON.parse(JSON.stringify(input))
    otherIndex = @referee._getOtherPlayerIndex(input.playerIndex)
    inputCopy.playerIndex = otherIndex
    inputCopy.cardId = card.cardId
    @referee.addPlayCardAction(inputCopy)
    if @referee.hasOnPlayTarget(card)
      # TODO: this is how we allow spell casting on certain cards. probably need to do this for target
      castableCards = @referee.getSpellTargets('player1', Constants.Targeting.ALL)
      targetInput =
        playerIndex: otherIndex
        cardId: card.cardId
        targetId: castableCards.shuffle().first().cardId
      @referee.addTargetSpell targetInput

  isEnabled: ->
    @enabled

exports.ArenaBot = ArenaBot
