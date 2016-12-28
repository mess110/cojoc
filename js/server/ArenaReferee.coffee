Constants = require('../game/Constants.coffee').Constants unless Constants?
Cards = require('../game/models/Cards.coffee').Cards unless Cards?
BaseReferee = require('./BaseReferee.coffee').BaseReferee unless BaseReferee?

class ArenaReferee extends BaseReferee
  constructor: (bot) ->
    super()
    @lastProcessedAction = -1
    @uiCards = []
    @json =
      bot: bot
      gameType: Constants.GameType.Arena
      phase: Constants.Phase.Arena.HeroSelect
      actions: []
      player1Heroes: Cards.heroes().shuffle()
      player2Heroes: Cards.heroes().shuffle()
      player1Hero: undefined
      player2Hero: undefined
    @inputs = [
      { type: 'gameInput', processed: false, action: 'startGame' }
    ]

  tick: ->
    return @json if @processing
    input = @inputs.where(processed: false).first()
    return @json unless input?

    console.log "Processing input:"
    console.log input

    @processing = true
    input.processed = true

    if input.action == 'startGame'
      @_addAction { duration: 200, owner: 'player1', action: 'drawCard', cardId: 0 }
      @_addAction { duration: 350, owner: 'player1', action: 'holdCard', cardId: 0, impersonate: @json.player1Heroes[0] }
      @_addAction { duration: 200, owner: 'player2', action: 'drawCard', cardId: 3 }
      @_addAction { duration: 350, owner: 'player2', action: 'holdCard', cardId: 3, impersonate: @json.player1Heroes[0] }
      @_addAction { duration: 200, owner: 'player1', action: 'drawCard', cardId: 1 }
      @_addAction { duration: 350, owner: 'player1', action: 'holdCard', cardId: 1, impersonate: @json.player1Heroes[1] }
      @_addAction { duration: 200, owner: 'player2', action: 'drawCard', cardId: 4 }
      @_addAction { duration: 350, owner: 'player2', action: 'holdCard', cardId: 4, impersonate: @json.player1Heroes[1] }
      @_addAction { duration: 200, owner: 'player1', action: 'drawCard', cardId: 2 }
      @_addAction { duration: 350, owner: 'player1', action: 'holdCard', cardId: 2, impersonate: @json.player1Heroes[2] }
      @_addAction { duration: 200, owner: 'player2', action: 'drawCard', cardId: 5 }
      @_addAction { duration: 350, owner: 'player2', action: 'holdCard', cardId: 5, impersonate: @json.player1Heroes[2] }

    if input.action == 'selectCard'
      card = @cards.where(id: input.cardId).first()
      # TODO: add action to selectCard
      console.log card

    @processing = false
    @json

  _addAction: (action) ->
    if action.action == 'drawCard'
      @cards.push { id: action.cardId, owner: action.owner }

    action.index = @json.actions.length
    @json.actions.push action

  # ------------------------------- #
  # Methods used only on the client #
  # ------------------------------- #

  uiAdd: (gameScene) ->
    throw 'scene param missing' unless gameScene?
    @scene = gameScene

    @deck = new Deck(66)
    @deck.mesh.position.set -10, 0, 0
    @scene.scene.add @deck.mesh

    @endTurn = new EndTurnButton()
    @endTurn.mesh.position.set 10, 0, 0
    @scene.scene.add @endTurn.mesh

    @ownDiscover = new Discover()
    @ownDiscover.mesh.position.set 0, 0, 8
    @scene.scene.add @ownDiscover.mesh

    @enemyDiscover = new Discover()
    @enemyDiscover.mesh.position.set 0, 6, 3
    @enemyDiscover.mesh.rotation.set 0, Math.PI, 0
    @scene.scene.add @enemyDiscover.mesh

    @uiAdded = true

  uiServerTick: (data) ->
    @json = data
    return if @processing
    action = @json.actions.where(index: @lastProcessedAction + 1).first()
    return unless action?
    @lastProcessedAction = action.index
    console.log 'Processing action:'
    console.log action
    @processing = true

    if action.action == 'drawCard'
      card = @deck.drawCard(@scene.scene)
      card.id = action.cardId
      card.owner = action.owner
      @uiCards.push card

    if action.action == 'holdCard'
      card = @uiCards.where(id: action.cardId).first()
      card.impersonate(action.impersonate)
      if card.owner == 'player1'
        @ownDiscover.add card
      else
        @enemyDiscover.add card

    setTimeout ->
      SceneManager.currentScene().game.referee.processing = false
    , action.duration

  uiTick: (tpf) ->

  uiKeyboardEvent: (event) ->

  uiMouseEvent: (event, raycaster) ->
    @deck.doMouseEvent(event, raycaster)
    @endTurn.hover(event, raycaster)
    @ownDiscover.doMouseEvent(event, raycaster)
    @enemyDiscover.doMouseEvent(event, raycaster)

exports.ArenaReferee = ArenaReferee
