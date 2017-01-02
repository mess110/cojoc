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

  hasMaxCardsInHand: (playerIndex) ->
    cards = @findCards(status: Constants.CardStatus.HELD, playerIndex: playerIndex)
    cards.size() == @json.maxCardsInHand

  hasManaFor: (playerIndex, cardId) ->
    card = @findCard(cardId)
    card.defaults.cost <= @getMana(playerIndex)

  isDiscovering: (playerIndex) ->
    @findCards(playerIndex: playerIndex, status: Constants.CardStatus.DISCOVERED).any()

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

  # TODO: should not find by index, instead by id
  findCard: (index) ->
    @json.cards[index]

  findCards: (hash) ->
    @json.cards.where(hash)

  tick: ->
    throw 'not implemented'

exports.BaseReferee = BaseReferee
