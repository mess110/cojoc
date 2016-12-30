# Holds the game elements (cards, decks etc) and handles each tick sent
# by the server
#
# Think of it has responsible for what is visible and happening on the player's
# screen
class ArenaMover
  constructor: (referee, scene) ->
    throw 'referee missing' unless referee?
    throw 'scene missing' unless scene?

    @scene = scene
    @referee = referee
    @lastProcessedAction = -1
    @uiCards = []

    @deck = new Deck(@referee.json.cards.length)
    @deck.mesh.position.set -10, 0, 0
    @scene.scene.add @deck.mesh

    @endTurn = new EndTurnButton()
    @endTurn.mesh.position.set 10, 0, 0
    @scene.scene.add @endTurn.mesh

    @player1Discover = new Discover()
    @player1Discover.customPosition(0)
    @scene.scene.add @player1Discover.mesh

    @player2Discover = new Discover()
    @player2Discover.customPosition(1)
    @scene.scene.add @player2Discover.mesh

  uiServerTick: (data) ->
    @setData(data)

    return if @processing
    action = @referee.json.actions.where(index: @lastProcessedAction + 1).first()
    return unless action?

    console.log @_getMyPlayerIndex()

    @lastProcessedAction = action.index
    console.ce "Processing action: #{JSON.stringify(action)}"
    @processing = true

    if action.action == Constants.Action.DRAW_CARD
      card = @deck.drawCard(@scene.scene)
      card.id = action.cardId
      card.playerIndex = action.playerIndex
      @uiCards.push card

    if action.action == Constants.Action.HOLD_CARD
      card = @uiCards.where(id: action.cardId).first()
      if card.playerIndex == @_getMyPlayerIndex()
        card.impersonate(@referee.json.cards[action.cardId])
      @_getDiscoverFor(card.playerIndex).add card

    setTimeout ->
      SceneManager.currentScene().mover.processing = false
    , action.duration

  uiTick: (tpf) ->

  uiKeyboardEvent: (event) ->

  uiMouseEvent: (event, raycaster) ->
    @deck.doMouseEvent(event, raycaster)
    @endTurn.hover(event, raycaster)
    @player1Discover.doMouseEvent(event, raycaster)
    @player2Discover.doMouseEvent(event, raycaster)

  # Populates the json data and takes care of reversing the position
  # so the current player is always game.player1 on the client
  setData: (data) ->
    @referee.json = data.referee
    @referee.inputs = data.referee.inputs
    @scene.game.player1 = data.player1
    @scene.game.player2 = data.player2

    # switch board position from player2's perspective
    # all ids remain unchanged, only the mesh positions change
    if data.player2.owner == @scene.myId
      @player1Discover.customPosition(1)
      @player2Discover.customPosition(0)

  _getMyPlayerIndex: ->
    return 'player1' if @scene.game.player1.owner == @scene.myId
    return 'player2' if @scene.game.player2.owner == @scene.myId
    throw "unknown playerIndex for #{@scene.myId}"

  _getDiscoverFor: (playerIndex) ->
    return @player1Discover if playerIndex == 'player1'
    return @player2Discover if playerIndex == 'player2'
    throw 'invalid player index'

exports.ArenaMover = ArenaMover
