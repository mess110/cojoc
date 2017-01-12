Constants = require('../game/Constants.coffee').Constants unless Constants?

class BaseReferee
  constructor: (botEnabled) ->
    @botEnabled = botEnabled
    @inputs = []
    @json = {}
    @processing = false

  toJson: ->
    json = JSON.parse(JSON.stringify(@json))
    json.inputs = @inputs
    json.processing = @processing
    json

  isPhase: (phase) ->
    @json.phase == phase

  hasActionsLeft: (playerIndex) ->
    return false if !@isTurn(playerIndex)
    canAttack = false
    canPlayACard = @hasCardsWhichCanBePlayedNow(playerIndex)
    canDiscover = @isDiscovering(playerIndex)
    for card in @findCards(status: Constants.CardStatus.PLAYED, playerIndex: playerIndex)
      canAttack = true if card.attacksLeft > 0
    canPlayACard or canDiscover or canAttack

  hasCardsWhichCanBePlayedNow: (playerIndex) ->
    canPlayACard = false
    for card in @findCards(status: Constants.CardStatus.HELD, playerIndex: playerIndex)
      canPlayACard = true if @hasManaFor(playerIndex, card.cardId)
    canPlayACard

  hasMaxCardsInHand: (playerIndex) ->
    cards = @findCards(status: Constants.CardStatus.HELD, playerIndex: playerIndex)
    cards.size() == @json.maxCardsInHand

  hasManaFor: (playerIndex, cardId) ->
    card = @findCard(cardId)
    card.defaults.cost <= @getMana(playerIndex)

  hasMinionSpace: (playerIndex) ->
    @findCards(playerIndex: playerIndex, status: Constants.CardStatus.PLAYED).size() < @json.maxMinionsPlayed

  isDiscovering: (playerIndex) ->
    @findCards(playerIndex: playerIndex, status: Constants.CardStatus.DISCOVERED).any()

  isTurn: (playerIndex) ->
    @json.turn == playerIndex

  getMana: (playerIndex) ->
    @json[playerIndex].mana

  getMaxMana: (playerIndex) ->
    @json[playerIndex].maxMana

  addAction: (action) ->
    action.duration ?= Constants.Duration.DEFAULT
    action.index = @json.actions.length
    @json.actions.push action

  addInput: (data) ->
    data.processed = false
    @inputs.push data

  findAction: (index) ->
    @json.actions.where(index: index).first()

  findInput: ->
    @inputs.where(processed: false).first()

  findCard: (cardId) ->
    @findCards(cardId: cardId).first()

  findCards: (hash) ->
    @json.cards.where(hash)

  tick: ->
    throw 'not implemented'

exports.BaseReferee = BaseReferee
