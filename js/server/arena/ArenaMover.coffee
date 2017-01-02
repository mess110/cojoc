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
    @player1Discover.customPosition(Constants.Position.Player.SELF)
    @scene.scene.add @player1Discover.mesh

    @player2Discover = new Discover()
    @player2Discover.customPosition(Constants.Position.Player.OPPONENT)
    @scene.scene.add @player2Discover.mesh

    @player1Hero = new Hero()
    @player1Hero.customPosition(Constants.Position.Player.SELF)
    @scene.scene.add @player1Hero.mesh

    @player2Hero = new Hero()
    @player2Hero.customPosition(Constants.Position.Player.OPPONENT)
    @scene.scene.add @player2Hero.mesh

    @player1Hand = new Hand()
    @player1Hand.customPosition(Constants.Position.Player.SELF)
    @player1Hand.holster(true)
    @scene.scene.add @player1Hand.mesh

    @player2Hand = new Hand()
    @player2Hand.customPosition(Constants.Position.Player.OPPONENT)
    @player2Hand.holster(true)
    @player2Hand.enabled = false
    @scene.scene.add @player2Hand.mesh

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
      when Constants.Action.DISCOVER_CARD
        card = @_findCard(action.cardId)
        if card.playerIndex == @_getMyPlayerIndex()
          card.impersonate(@referee.findCard(action.cardId))
          @_findHandFor(card.playerIndex).holster(true)
        @_findDiscoverFor(card.playerIndex).add card

        # delay if bot is choosing or max cards in hand reached
        if (@_isBot(action.playerIndex) or @referee.hasMaxCardsInHand(action.playerIndex)) and
            @_findDiscoverFor(action.playerIndex).cards.size() == 3 and @referee.isPhase(Constants.Phase.Arena.BATTLE)
          duration += 500
        else
          duration /= 5
      when Constants.Action.DISCARD_CARD
        toDiscard = []
        for cardId in action.cardIds
          card = @_findCard(cardId)
          toDiscard.push card
          card.dissolve()
        @_findDiscoverFor(card.playerIndex).remove toDiscard
      when Constants.Action.SELECT_HERO
        selectCard = @_uiSelectCard(action)
        selectCard.minion(@referee.findCard(action.cardId))
        @_findHeroFor(action.playerIndex).add selectCard
      when Constants.Action.SELECT_CARD
        selectCard = @_uiSelectCard(action)
        @_findHandFor(action.playerIndex).add selectCard
      when Constants.Action.UPDATE_END_TURN_BUTTON
        isMe = @_isMe(action.playerIndex)
        @endTurn.setFaceUp(isMe)
      else
        console.log "Unknown action #{action.action}"

    setTimeout ->
      SceneManager.currentScene().mover.setProcessing(false)
    , duration

  _uiSelectCard: (action) ->
    toRemove = []
    selectCard = @_findCard(action.cardId)
    toRemove.push selectCard
    for discardId in action.discardIds
      card = @_findCard(discardId)
      toRemove.push card
      card.dissolve()
    @_findDiscoverFor(action.playerIndex).remove toRemove
    selectCard

  uiTick: (tpf) ->
    @endTurn.tick(tpf)
    @player1Hand.tick(tpf)
    @player2Hand.tick(tpf)
    for card in @uiCards
      card.dissolveTick(tpf)

  uiKeyboardEvent: (event) ->

  uiMouseEvent: (event, raycaster) ->
    @deck.doMouseEvent(event, raycaster)
    if !@player1Discover.hasCards()
      @endTurn.doMouseEvent(event, raycaster)
    @player1Discover.doMouseEvent(event, raycaster)
    @player2Discover.doMouseEvent(event, raycaster)
    @player1Hand.holsterLock = @player1Discover.hasCards()
    @player1Hand.doMouseEvent(event, raycaster)
    @player2Hand.doMouseEvent(event, raycaster)
    if !@player1Hand.hasInteraction() and !@player1Discover.hasInteraction()
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
      @player1Discover.customPosition(Constants.Position.Player.OPPONENT)
      @player2Discover.customPosition(Constants.Position.Player.SELF)
      @player1Hero.customPosition(Constants.Position.Player.OPPONENT)
      @player2Hero.customPosition(Constants.Position.Player.SELF)
      @player1Hand.customPosition(Constants.Position.Player.OPPONENT)
      @player1Hand.enabled = false
      # if player1 is opponent, move the holder left
      @player1Hand.mesh.position.x -= @player1Hand.defaultHolsterAmount
      @player2Hand.customPosition(Constants.Position.Player.SELF)
      @player2Hand.enabled = true
    return

  _isMe: (playerIndex) ->
    @_getMyPlayerIndex() == playerIndex

  _isBot: (playerIndex) ->
    @scene.game[playerIndex].owner == Constants.Storage.BOT

  _getMyPlayerIndex: ->
    return 'player1' if @scene.game.player1.owner == @scene.myId
    return 'player2' if @scene.game.player2.owner == @scene.myId
    throw "unknown playerIndex for #{@scene.myId}"

  _findDiscoverFor: (playerIndex) ->
    return @player1Discover if playerIndex == 'player1'
    return @player2Discover if playerIndex == 'player2'
    throw 'invalid player index'

  _findHandFor: (playerIndex) ->
    return @player1Hand if playerIndex == 'player1'
    return @player2Hand if playerIndex == 'player2'
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