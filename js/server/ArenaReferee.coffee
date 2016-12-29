Constants = require('../game/Constants.coffee').Constants unless Constants?
Cards = require('../game/models/Cards.coffee').Cards unless Cards?
BaseReferee = require('./BaseReferee.coffee').BaseReferee unless BaseReferee?

class ArenaReferee extends BaseReferee
  constructor: (bot) ->
    super()
    @lastProcessedAction = -1
    @uiCards = []
    allCards = Cards.random(60)
    @json =
      bot: bot
      gameType: Constants.GameType.Arena
      phase: Constants.Phase.Arena.HeroSelect
      actions: []
      player1: {}
      player2: {}
      cards: Cards.heroes().shuffle().concat(Cards.heroes().shuffle()).concat(allCards)

    @inputs = [
      { type: 'gameInput', processed: false, action: Constants.Input.START_GAME }
    ]

  tick: ->
    return @json if @processing
    input = @inputs.where(processed: false).first()
    return @json unless input?

    console.log "Processing input: #{JSON.stringify(input)}"

    @processing = true
    input.processed = true

    if input.action == Constants.Input.START_GAME
      @_addAction { duration: 200, playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 0 }
      @_addAction { duration: 350, playerIndex: 'player1', action: Constants.Action.HOLD_CARD, cardId: 0 }
      @_addAction { duration: 200, playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 3 }
      @_addAction { duration: 350, playerIndex: 'player2', action: Constants.Action.HOLD_CARD, cardId: 3 }
      @_addAction { duration: 200, playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 1 }
      @_addAction { duration: 350, playerIndex: 'player1', action: Constants.Action.HOLD_CARD, cardId: 1 }
      @_addAction { duration: 200, playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 4 }
      @_addAction { duration: 350, playerIndex: 'player2', action: Constants.Action.HOLD_CARD, cardId: 4 }
      @_addAction { duration: 200, playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 2 }
      @_addAction { duration: 350, playerIndex: 'player1', action: Constants.Action.HOLD_CARD, cardId: 2 }
      @_addAction { duration: 200, playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 5 }
      @_addAction { duration: 350, playerIndex: 'player2', action: Constants.Action.HOLD_CARD, cardId: 5 }

    if input.action == Constants.Input.SELECT_CARD
      card = @json.cards[input.cardId]
      # TODO: add action to selectCard
      console.log card

    @processing = false
    @json

  _addAction: (action) ->
    if action.action == Constants.Action.DRAW_CARD
      card = @json.cards[action.cardId]
      card.playerIndex = action.playerIndex

    action.index = @json.actions.length
    @json.actions.push action

  _getDiscoverFor: (playerIndex) ->
    return @player1Discover if playerIndex == 'player1'
    return @player2Discover if playerIndex == 'player2'
    throw 'invalid player index'

  # ------------------------------- #
  # Methods used only on the client #
  # ------------------------------- #

  uiAdd: (gameScene) ->
    throw 'scene param missing' unless gameScene?
    @scene = gameScene

    @deck = new Deck(@json.cards.length)
    @deck.mesh.position.set -10, 0, 0
    @scene.scene.add @deck.mesh

    @endTurn = new EndTurnButton()
    @endTurn.mesh.position.set 10, 0, 0
    @scene.scene.add @endTurn.mesh

    @player1Discover = new Discover()
    @player1Discover.mesh.position.set 0, 0, 8
    @scene.scene.add @player1Discover.mesh

    @player2Discover = new Discover()
    @player2Discover.mesh.position.set 0, 6, 3
    @player2Discover.mesh.rotation.set 0, Math.PI, 0
    @scene.scene.add @player2Discover.mesh

    @uiAdded = true

  uiServerTick: (data) ->
    @json = data

    return if @processing
    action = @json.actions.where(index: @lastProcessedAction + 1).first()
    return unless action?
    @lastProcessedAction = action.index
    console.log "Processing action: #{JSON.stringify(action)}"
    @processing = true

    if action.action == Constants.Action.DRAW_CARD
      card = @deck.drawCard(@scene.scene)
      card.id = action.cardId
      card.playerIndex = action.playerIndex
      @uiCards.push card

    if action.action == Constants.Action.HOLD_CARD
      card = @uiCards.where(id: action.cardId).first()
      card.impersonate(@json.cards[action.cardId])
      @_getDiscoverFor(card.playerIndex).add card

    setTimeout ->
      SceneManager.currentScene().game.referee.processing = false
    , action.duration

  uiTick: (tpf) ->

  uiKeyboardEvent: (event) ->

  uiMouseEvent: (event, raycaster) ->
    @deck.doMouseEvent(event, raycaster)
    @endTurn.hover(event, raycaster)
    @player1Discover.doMouseEvent(event, raycaster)
    @player2Discover.doMouseEvent(event, raycaster)

exports.ArenaReferee = ArenaReferee
