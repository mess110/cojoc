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

  tick: ->
    throw 'not implemented'

exports.BaseReferee = BaseReferee
