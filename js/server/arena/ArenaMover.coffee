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
    @multiSelect = []

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

    @player1Mana = new ManaBar()
    @player1Mana.customPosition(Constants.Position.Player.SELF)
    @scene.scene.add @player1Mana.mesh

    @player2Mana = new ManaBar()
    @player2Mana.customPosition(Constants.Position.Player.OPPONENT)
    @scene.scene.add @player2Mana.mesh

    @player1Minions = new Minions()
    @player1Minions.customPosition(Constants.Position.Player.SELF)
    @scene.scene.add @player1Minions.mesh

    @player2Minions = new Minions()
    @player2Minions.customPosition(Constants.Position.Player.OPPONENT)
    @scene.scene.add @player2Minions.mesh

    @cardPreview = new CardPreview()
    @cardPreview.mesh.position.set -3, 1, 12.5
    @scene.scene.add @cardPreview.mesh

    @turnNotification = new TurnNotification()
    @turnNotification.setOpacity(0)
    @turnNotification.mesh.position.set 0, 0.5, 13
    @scene.scene.add @turnNotification.mesh

    @hoverMasta = new HoverMasta(@scene, @)

    PoolManager.onRelease Card, (item) ->
      SceneManager.currentScene().scene.remove item.mesh
      SceneManager.currentScene().mover.uiCards.remove item
      item.mesh.scale.set 1, 1, 1
      item.glow.original()
      item.front.material = Helper.basicMaterial('card-bg')
      item.back.material = Helper.basicMaterial('card-bg')

    PoolManager.onSpawn Card, (item) ->

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
      when Constants.Action.AUTO_SELECT_CARD
        card = @deck.drawCard(@scene.scene)
        card.id = action.cardId
        card.playerIndex = action.playerIndex
        if card.playerIndex == @_getMyPlayerIndex()
          card.impersonate(@referee.findCard(action.cardId))
        @uiCards.push card
        @_findHandFor(action.playerIndex).add card
      when Constants.Action.UPDATE_END_TURN_BUTTON
        isMe = @_isMe(action.playerIndex)
        if isMe
          @turnNotification.animate()
        @endTurn.setFaceUp(isMe)
      when Constants.Action.SET_MAX_MANA, Constants.Action.REPLENISH_MANA, Constants.Action.SET_MANA
        @_findManaFor(action.playerIndex).update(action.mana, action.maxMana)
      when Constants.Action.SUMMON_MINION
        cardData = @referee.findCard(action.cardId)
        @cardPreview.animate(cardData) if !@_isMe(action.playerIndex)
        card = @_findCard(action.cardId)
        card.minion(cardData)
        @_findHandFor(action.playerIndex).remove card
        @_findMinionsFor(action.playerIndex).add card
      when Constants.Action.ATTACK
        attacker = @_findCard(action.attackerId)
        defender = @_findCard(action.defenderId)

        target = defender.mesh.position.clone()
        target.z += 1
        attacker.move(
          target: target
          duration: Constants.Duration.ATTACK / 2
        )
        setTimeout =>
          @moveBackInPosition(action)
        , Constants.Duration.ATTACK / 2
      when Constants.Action.DIE
        for id in action.cardIds
          card = @_findCard(id)
          card.dissolve()
          @_findMinionsFor(card.playerIndex).remove(card)
      else
        console.log "Unknown action #{action.action}"

    # all actions
    if @arePlayersInit()
      @endTurn.hasActionsLeft = @referee.hasActionsLeft(@_getMyPlayerIndex())
      @endTurn.noGlow = @_findDiscoverFor(@_getMyPlayerIndex()).hasCards()

    setTimeout ->
      SceneManager.currentScene().mover.setProcessing(false)
    , duration

  moveBackInPosition: (action) ->
    attacker = @_findCard(action.attackerId)
    defender = @_findCard(action.defenderId)
    attacker.minion(@referee.findCard(action.attackerId))
    defender.minion(@referee.findCard(action.defenderId))
    # TODO: add damage sign
    @_findMinionsFor(action.playerIndex)._moveInPosition(Constants.Duration.ATTACK / 2)

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
    @player1Discover.tick(tpf)
    @player2Discover.tick(tpf)

    if @arePlayersInit()
      @hoverMasta.tick(tpf)

    @hightlightCardsWhichCanAttack()

  hightlightCardsWhichCanAttack: ->
    return unless @arePlayersInit()
    myMinions = @_findMinionsFor(@_getMyPlayerIndex())
    for card in myMinions.cards
      if myMinions.hasSelected()
        continue if card.id == myMinions.selectedCard.id
      if @referee.findCard(card.id).attacksLeft > 0 and @endTurn.faceUp
        card.glow.green()
      else
        card.glow.none()

  highlight: (data) ->
    @hoverMasta.highlight(data) if @arePlayersInit()

  uiKeyboardEvent: (event) ->

  uiMouseEvent: (event, raycaster) ->
    myDiscover = @_findDiscoverFor(@_getMyPlayerIndex())
    myHand = @_findHandFor(@_getMyPlayerIndex())

    @deck.doMouseEvent(event, raycaster)
    @player1Discover.doMouseEvent(event, raycaster)
    @player2Discover.doMouseEvent(event, raycaster)
    @endTurn.clickLock = myDiscover.hasCards() or myHand.hasSelected()
    @endTurn.doMouseEvent(event, raycaster)

    @player1Hand.holsterLock = @player1Discover.hasCards() and !@player1Discover.viewingBoard
    @player1Hand.viewingBoard = @player1Discover.viewingBoard
    @player1Hand.doMouseEvent(event, raycaster)

    @player2Hand.holsterLock = @player2Discover.hasCards() and !@player2Discover.viewingBoard
    @player2Hand.viewingBoard = @player2Discover.viewingBoard
    @player2Hand.doMouseEvent(event, raycaster)

    if !myDiscover.hasInteraction() and !myHand.hasInteraction()
      @player1Hero.doMouseEvent(event, raycaster)
      @player2Hero.doMouseEvent(event, raycaster)

    if !@player1Discover.hasInteraction() and !@player1Discover.hasCards()
      @player1Mana.doMouseEvent(event, raycaster)
    if !@player2Discover.hasInteraction() and !@player2Discover.hasCards()
      @player2Mana.doMouseEvent(event, raycaster)

    lockMinions = myDiscover.hasInteraction() or myHand.hasInteraction() or myDiscover.hasCards()
    @player1Minions.lock = lockMinions
    @player1Minions.doMouseEvent(event, raycaster)
    @player2Minions.lock = lockMinions
    @player2Minions.doMouseEvent(event, raycaster)
    @multiSelect = []

  # Populates the json data and takes care of reversing the position
  # so the current player is always game.player1 on the client
  setData: (data) ->
    @referee.json = data.referee
    @referee.inputs = data.referee.inputs
    @scene.game.player1 = data.player1
    @scene.game.player2 = data.player2

    # switch board position from player2's perspective
    # all ids remain unchanged, only the mesh positions change
    if data.player2.owner == @scene.myId and !@mirroredUI
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
      @player1Mana.customPosition(Constants.Position.Player.OPPONENT)
      @player2Mana.customPosition(Constants.Position.Player.SELF)
      @player1Minions.customPosition(Constants.Position.Player.OPPONENT)
      @player2Minions.customPosition(Constants.Position.Player.SELF)

    # if !@discoverInited
      # @discoverInited = true
      # if @mirroredUI
        # @player2Discover.addToggleButton()
      # else
        # @player1Discover.addToggleButton()

    return

  doMultiSelect: (cardId) ->
    @multiSelect.push cardId
    if @multiSelect.size() == 2
      @scene._emit(
        type: 'gameInput'
        action: Constants.Input.ATTACK
        cards: @multiSelect
      )

  playCard: (card, hand) ->
    throw "card does not have playerIndex" unless card.playerIndex?

    unless @referee.hasManaFor(card.playerIndex, card.id)
      @_findManaFor(card.playerIndex).shake()
      console.ce "not enough mana for #{card.id}"
      return

    unless @referee.hasMinionSpace(card.playerIndex)
      console.ce "too many minions"
      return

    unless @referee.isTurn(card.playerIndex)
      console.ce "not your turn"
      return

    memCard = @referee.findCard(card.id)
    hand.remove(card)
    card.glow.none()
    card.dissolve(false)
    @_findManaFor(card.playerIndex).update(@referee.getMana(card.playerIndex) - memCard.defaults.cost)
    @scene._emit(
      type: 'gameInput'
      action: Constants.Input.PLAY_CARD
      cardId: card.id
    )

  glowHeldCards: (cards) ->
    return unless @arePlayersInit()
    myIndex = @_getMyPlayerIndex()
    for card in cards
      if @referee.hasManaFor(myIndex, card.id) and @referee.isTurn(myIndex) and @endTurn.faceUp
        card.glow.blue()
      else
        card.glow.none()

  _isMe: (playerIndex) ->
    @_getMyPlayerIndex() == playerIndex

  _isBot: (playerIndex) ->
    @scene.game[playerIndex].owner == Constants.Storage.BOT

  arePlayersInit: ->
    @scene.game.player1? and @scene.game.player2? and @scene.game.player1.owner? and @scene.game.player2.owner?

  _getMyPlayerIndex: ->
    return 'player1' if @scene.game.player1.owner == @scene.myId
    return 'player2' if @scene.game.player2.owner == @scene.myId
    throw "unknown playerIndex for #{@scene.myId}"

  _getOpponentPlayerIndex: ->
    @referee._getOtherPlayerIndex(@_getMyPlayerIndex())

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

  _findManaFor: (playerIndex) ->
    return @player1Mana if playerIndex == 'player1'
    return @player2Mana if playerIndex == 'player2'
    throw 'invalid player index'

  _findMinionsFor: (playerIndex) ->
    return @player1Minions if playerIndex == 'player1'
    return @player2Minions if playerIndex == 'player2'
    throw 'invalid player index'

  _findCard: (cardId) ->
    @uiCards.where(id: cardId).first()

  _findCards: (hash) ->
    @uiCards.where(hash)

  setProcessing: (bool) ->
    @processing = bool

exports.ArenaMover = ArenaMover
