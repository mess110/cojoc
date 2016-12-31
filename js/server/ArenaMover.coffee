# Holds the game elements (cards, decks etc) and handles each tick sent
# by the server
#
# Think of it has responsible for what is visible and happening on the player's
# screen
class ArenaMover
  constructor: (scene) ->
    throw 'scene missing' unless scene?

    @scene = scene
    @referee = scene.game.referee
    @lastProcessedAction = -1
    @uiCards = []
    @processing = false
    @mirroredUI = false

    @deck = new Deck(@referee.json.cards.length)
    @deck.mesh.position.set -12, 0, 0
    @scene.scene.add @deck.mesh

    @endTurn = new EndTurnButton()
    @endTurn.mesh.position.set 12, 0, 0
    @endTurn.setFaceUp(false)
    @scene.scene.add @endTurn.mesh

    @player1Discover = new Discover()
    @player1Discover.customDiscoverPosition(0)
    @scene.scene.add @player1Discover.mesh

    @player2Discover = new Discover()
    @player2Discover.customDiscoverPosition(1)
    @scene.scene.add @player2Discover.mesh

    @player1Hero = new Discover()
    @player1Hero.customHeroPosition(0)
    @scene.scene.add @player1Hero.mesh

    @player2Hero = new Discover()
    @player2Hero.customHeroPosition(1)
    @scene.scene.add @player2Hero.mesh

  uiServerTick: (data) ->
    @setData(data)

    return if @processing
    action = @referee.findAction(@lastProcessedAction + 1)
    return unless action?

    console.ce "Processing action: #{JSON.stringify(action)}"
    @lastProcessedAction = action.index
    @setProcessing(true)

    duration = action.duration
    switch action.action
      when Constants.Action.DRAW_CARD
        card = @deck.drawCard(@scene.scene)
        card.id = action.cardId
        card.playerIndex = action.playerIndex
        @uiCards.push card
        duration /= 3
      when Constants.Action.HOLD_CARD
        card = @_findCard(action.cardId)
        if card.playerIndex == @_getMyPlayerIndex()
          card.impersonate(@referee.findCard(action.cardId))
        @_findDiscoverFor(card.playerIndex).add card
        duration /= 5
      when Constants.Action.DISCARD_CARD
        card = @_findCard(action.cardId)
        @_findDiscoverFor(card.playerIndex).remove card
        card.dissolve()
      when Constants.Action.SELECT_HERO
        toRemove = []
        heroCard = @_findCard(action.cardId)
        toRemove.push heroCard
        for discardId in action.discardIds
          card = @_findCard(discardId)
          toRemove.push card
          card.dissolve()

        @_findDiscoverFor(card.playerIndex).remove toRemove
        heroCard.minion(@referee.findCard(action.cardId))
        @_findHeroFor(card.playerIndex).add heroCard
      else
        console.log "Unknown action #{action.action}"

    setTimeout ->
      SceneManager.currentScene().mover.setProcessing(false)
    , duration

  uiTick: (tpf) ->
    @endTurn.tick(tpf)
    for card in @uiCards
      card.dissolveTick(tpf)

  uiKeyboardEvent: (event) ->

  uiMouseEvent: (event, raycaster) ->
    @deck.doMouseEvent(event, raycaster)
    @endTurn.doMouseEvent(event, raycaster)
    @player1Discover.doMouseEvent(event, raycaster)
    @player2Discover.doMouseEvent(event, raycaster)
    @player1Hero.doMouseEvent(event, raycaster)
    @player2Hero.doMouseEvent(event, raycaster)

  # Populates the json data and takes care of reversing the position
  # so the current player is always game.player1 on the client
  setData: (data) ->
    @referee.json = data.referee
    @referee.inputs = data.referee.inputs
    @scene.game.player1 = data.player1
    @scene.game.player2 = data.player2

    # switch board position from player2's perspective
    # all ids remain unchanged, only the mesh positions change
    if data.player2.owner == @scene.myId && !@mirroredUI
      @mirroredUI = true
      @player1Discover.customDiscoverPosition(1)
      @player2Discover.customDiscoverPosition(0)
      @player1Hero.customHeroPosition(1)
      @player2Hero.customHeroPosition(0)

  _getMyPlayerIndex: ->
    return 'player1' if @scene.game.player1.owner == @scene.myId
    return 'player2' if @scene.game.player2.owner == @scene.myId
    throw "unknown playerIndex for #{@scene.myId}"

  _findDiscoverFor: (playerIndex) ->
    return @player1Discover if playerIndex == 'player1'
    return @player2Discover if playerIndex == 'player2'
    throw 'invalid player index'

  _findHeroFor: (playerIndex) ->
    return @player1Hero if playerIndex == 'player1'
    return @player2Hero if playerIndex == 'player2'
    throw 'invalid player index'

  _findCard: (cardId) ->
    @uiCards.where(id: cardId).first()

  _findCards: (hash) ->
    @uiCards.where(hash)

  setProcessing: (bool) ->
    @processing = bool

exports.ArenaMover = ArenaMover
