class BaseReferee
  constructor: () ->
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

  addAction: (action) ->
    action.index = @json.actions.length
    @json.actions.push action

  addInput: (data) ->
    data.processed = false
    @inputs.push data

  findAction: (index) ->
    @json.actions.where(index: index).first()

  findInput: ->
    @inputs.where(processed: false).first()

  findCard: (index) ->
    @json.cards[index]

  findCards: (hash) ->
    @json.cards.where(hash)

  tick: ->
    throw 'not implemented'

exports.BaseReferee = BaseReferee
