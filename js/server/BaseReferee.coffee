class BaseReferee
  constructor: () ->
    @inputs = []
    @json = {}
    @processing = false
    @uiAdded = false

  toJson: ->
    json = JSON.parse(JSON.stringify(@json))
    json.inputs = @inputs
    json.processing = @processing
    json.uiAdded = @uiAdded
    json

  gameInput: (data) ->
    data.processed = false
    @inputs.push data

  # ------------------------------- #
  # Methods used only on the client #
  # ------------------------------- #

  # This method is responsible for updating the server json object
  # input by input
  #
  # This is called by the ticker, before the ui calls doIt
  # it is called on the server if not bot game
  # it is also called on the client if bot game
  #
  # Result is used as param for uiServerTick
  tick: ->
    throw 'not implemented'

  # called only once
  uiAdd: (scene) ->
    throw 'not implemented'

  # This method is responsible for updating the UI action by action
  #
  # This is called after the referee processed tick only on the client
  uiServerTick: (data) ->
    throw 'not implemented'

  uiTick: (tpf) ->
    throw 'not implemented'

  uiKeyboardEvent: (event) ->
    throw 'not implemented'

  uiMouseEvent: (event, raycaster) ->
    throw 'not implemented'

  _isUiAdded: ->
    @uiAdded

exports.BaseReferee = BaseReferee
