Constants = require('../../game/Constants.coffee').Constants unless Constants?
Cards = require('../../game/models/Cards.coffee').Cards unless Cards?
BaseReferee = require('../BaseReferee.coffee').BaseReferee unless BaseReferee?
ArenaBot = require('./ArenaBot.coffee').ArenaBot unless ArenaBot?

# The referee class has 2 main responsabilities. Even writing this screams
# split in 2 classes.
#
# The class stores the game state. Each input in the state is processed by
# the tick method, one by one. Each input can generate one or more actions
# which are in turn processed one by one.
#
# The actions are processed on the client while the inputs are only processed
# on the server. They can also be processed on the client if it is a bot game
#
# The referee should not know any information about who the player is, instead
# it should rely on the playerIndex
class ArenaReferee extends BaseReferee
  constructor: (botEnabled) ->
    super(botEnabled)
    @bot = new ArenaBot(@)
    allCards = Cards.random(3 * 3 * 2)
    @json =
      maxCardsInHand: 10
      maxMinionsPlayed: 7
      maxMana: 10
      gameType: Constants.GameType.ARENA
      phase: Constants.Phase.Arena.HERO_SELECT
      actions: []
      player1:
        mana: 0
        maxMana: 0
        fatigue: 0
      player2:
        mana: 0
        maxMana: 0
        fatigue: 0
      cards: Cards.heroes().shuffle().concat(Cards.heroes().shuffle()).concat(allCards)
      turn: 'player1'

    @_prepareCards()
    @inputs = [
      { type: 'gameInput', processed: false, action: Constants.Input.START_GAME }
    ]

  # processes one input per tick
  # only valid inputs are processed
  tick: ->
    return if @processing

    loop
      input = @findInput()
      break unless input?
      @processOne(input)

    @processing = false

  processOne: (input) ->
    @processing = true
    console.ce "Processing input: #{JSON.stringify(input)}"
    input.processed = true
    switch input.action
      when Constants.Input.START_GAME
        @_addStartGameActions()
      when Constants.Input.SELECT_CARD
        @addSelectCardAction(input)
        @bot.addSelectHeroAction(input)
        @_addBothHeroesChosenActions()
        @bot.addEndTurnAction(input)
      when Constants.Input.END_TURN
        @addEndTurnAction()
        @bot.addEndTurnAction(input)
      when Constants.Input.PLAY_CARD
        @addPlayCardAction(input)
      when Constants.Input.ATTACK
        @addAttackAction(input)
      when Constants.Input.TARGET_SPELL
        @addTargetSpell(input)
      else
        console.log "Unknown input action #{input.action}"

    @addFinishedAction()

    input

  addFinishedAction: ->
    return false if @isPhase(Constants.Phase.Arena.HERO_SELECT)
    return true if @isPhase(Constants.Phase.Arena.FINISHED)
    aliveHeroes = @findCards(type: Constants.CardType.HERO, status: Constants.CardStatus.HERO)
    if aliveHeroes.size() != 2
      @json.phase = Constants.Phase.Arena.FINISHED
      @addAction { action: Constants.Action.FINISH, winners: aliveHeroes.map (e) -> e.playerIndex }
      return true
    false

  addAttackAction: (input) ->
    card1 = @findCard(input.cards[0])
    card2 = @findCard(input.cards[1])
    if card1.playerIndex == input.playerIndex
      attacker = card1
      defender = card2
    else
      attacker = card2
      defender = card1
    @addAction { playerIndex: input.playerIndex, action: Constants.Action.ATTACK, attackerId: attacker.cardId, defenderId: defender.cardId }

    dieIds = []
    if attacker.stats.health < 1
      dieIds.push attacker.cardId
    if defender.stats.health < 1
      dieIds.push defender.cardId
    @addDeadCardsAction(dieIds)

  addDeadCardsAction: (inputIds) ->
    dieIds = [].concat(inputIds)
    if dieIds.any()
      @addAction {
        duration: Constants.Duration.DISCARD_CARD
        action: Constants.Action.DIE
        cardIds: dieIds
      }

      for dieId in dieIds
        card = @findCard(dieId)
        for onDeathEffect in card.onDeath
          if onDeathEffect.drawCards?
            @addDrawCards(card.playerIndex, onDeathEffect.drawCards)

  addPlayCardAction: (input) ->
    card = @findCard(input.cardId)
    if card.type == Constants.CardType.MINION
      if @hasMinionSpace(input.playerIndex)
        @addAction { duration: 1000, playerIndex: input.playerIndex, action: Constants.Action.SET_MANA, cardId: input.cardId }
        @addAction { playerIndex: input.playerIndex, action: Constants.Action.SUMMON_MINION, cardId: input.cardId }
      else
        console.log 'too many minions in play'
    if card.type == Constants.CardType.SPELL
      @addAction { duration: 1000, playerIndex: input.playerIndex, action: Constants.Action.SET_MANA, cardId: input.cardId }
      action = @addAction { playerIndex: input.playerIndex, action: Constants.Action.SUMMON_SPELL, cardId: input.cardId }

      if action.drawCards?
        @addDrawCards(action.playerIndex, action.drawCards)

      unless @hasOnPlayTarget(card)
        @addAction { playerIndex: input.playerIndex, action: Constants.Action.AOE_SPELL, targets: action.targets, cardId: input.cardId }

        deadIds = []
        for target in action.targets
          targetCard = @findCard(target.cardId)
          if targetCard.stats.health < 1
            deadIds.push target.cardId
        @addDeadCardsAction(deadIds)

  addDrawCards: (playerIndex, amount) ->
    count = amount
    while count > 0
      cards = @findCards(status: undefined)
      unless cards.any()
        count -= 1
        @addFatigueAction(playerIndex, Constants.Duration.DAMAGE_SIGN)
        continue
      unless @hasMaxCardsInHand(playerIndex)
        @addAction { duration: Constants.Duration.SELECT_CARD, playerIndex: playerIndex, action: Constants.Action.AUTO_SELECT_CARD, cardId: cards[0].cardId }
      count -= 1

  addTargetSpell: (input) ->
    @addAction { duration: Constants.Duration.DISSOLVE, playerIndex: input.playerIndex, action: Constants.Action.TARGET_SPELL, cardId: input.cardId, targetId: input.targetId }

    target = @findCard(input.targetId)
    if target.stats.health < 1
      @addDeadCardsAction(input.targetId)

  addSelectCardAction: (input) ->
    actionName = if @isPhase(Constants.Phase.Arena.HERO_SELECT) then Constants.Action.SELECT_HERO else Constants.Action.SELECT_CARD
    action = { duration: Constants.Duration.SELECT_CARD, playerIndex: input.playerIndex, action: actionName }
    action.cardId = input.cardId
    @addAction action

  _addBothHeroesChosenActions: ->
    return unless @isPhase(Constants.Phase.Arena.HERO_SELECT)
    if @isHeroChosen('player1') and @isHeroChosen('player2')
      @json.phase = Constants.Phase.Arena.BATTLE
      @addAction { duration: Constants.Duration.UPDATE_END_TURN, playerIndex: @json.turn, action: Constants.Action.UPDATE_END_TURN_BUTTON }
      @addAction { playerIndex: @json.turn, action: Constants.Action.SET_MAX_MANA, to: @getMaxMana(@json.turn) + 1 }
      @addAction { playerIndex: @json.turn, action: Constants.Action.REPLENISH_MANA }

      cards = @findCards(status: undefined)
      otherIndex = @_getOtherPlayerIndex(@json.turn)
      @addAction { duration: Constants.Duration.SELECT_CARD, playerIndex: @json.turn, action: Constants.Action.AUTO_SELECT_CARD, cardId: cards[0].cardId }
      @addAction { duration: Constants.Duration.SELECT_CARD, playerIndex: otherIndex, action: Constants.Action.AUTO_SELECT_CARD, cardId: cards[1].cardId }
      @addAction { duration: Constants.Duration.SELECT_CARD, playerIndex: @json.turn, action: Constants.Action.AUTO_SELECT_CARD, cardId: cards[2].cardId }
      @addAction { duration: Constants.Duration.SELECT_CARD, playerIndex: otherIndex, action: Constants.Action.AUTO_SELECT_CARD, cardId: cards[3].cardId }
      @addAction { duration: Constants.Duration.SELECT_CARD, playerIndex: @json.turn, action: Constants.Action.AUTO_SELECT_CARD, cardId: cards[4].cardId }
      @addAction { duration: Constants.Duration.SELECT_CARD, playerIndex: otherIndex, action: Constants.Action.AUTO_SELECT_CARD, cardId: cards[5].cardId }

      @_addDiscoverActions()

  _addStartGameActions: ->
    @addAction { playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 0 }
    @addAction { playerIndex: 'player1', action: Constants.Action.DISCOVER_CARD, cardId: 0 }
    @addAction { playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 3 }
    @addAction { playerIndex: 'player2', action: Constants.Action.DISCOVER_CARD, cardId: 3 }
    @addAction { playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 1 }
    @addAction { playerIndex: 'player1', action: Constants.Action.DISCOVER_CARD, cardId: 1 }
    @addAction { playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 4 }
    @addAction { playerIndex: 'player2', action: Constants.Action.DISCOVER_CARD, cardId: 4 }
    @addAction { playerIndex: 'player1', action: Constants.Action.DRAW_CARD, cardId: 2 }
    @addAction { playerIndex: 'player1', action: Constants.Action.DISCOVER_CARD, cardId: 2 }
    @addAction { playerIndex: 'player2', action: Constants.Action.DRAW_CARD, cardId: 5 }
    @addAction { playerIndex: 'player2', action: Constants.Action.DISCOVER_CARD, cardId: 5 }

  addEndTurnAction: ->
    if @isDiscovering(@json.turn)
      @addAction { duration: Constants.Duration.SELECT_CARD, playerIndex: @json.turn, action: Constants.Action.SELECT_CARD }
    @json.turn = @_getOtherPlayerIndex(@json.turn)
    @addAction { duration: Constants.Duration.UPDATE_END_TURN, playerIndex: @json.turn, action: Constants.Action.UPDATE_END_TURN_BUTTON }
    @addAction { playerIndex: @json.turn, action: Constants.Action.SET_MAX_MANA, to: @getMaxMana(@json.turn) + 1 }
    @addAction { playerIndex: @json.turn, action: Constants.Action.REPLENISH_MANA }
    @_addDiscoverActions()
    for card in @findCards(status: Constants.CardStatus.PLAYED, playerIndex: @json.turn)
      card.attacksLeft = if card.windfury then 2 else 1

  _addDiscoverActions: ->
    cards = @findCards(status: undefined)
    if cards.any()
      @addAction { playerIndex: @json.turn, action: Constants.Action.DRAW_CARD, cardId: cards[0].cardId }
      @addAction { playerIndex: @json.turn, action: Constants.Action.DISCOVER_CARD, cardId: cards[0].cardId }
      if cards.size() > 1
        @addAction { playerIndex: @json.turn, action: Constants.Action.DRAW_CARD, cardId: cards[1].cardId }
        @addAction { playerIndex: @json.turn, action: Constants.Action.DISCOVER_CARD, cardId: cards[1].cardId }
      if cards.size() > 2
        @addAction { playerIndex: @json.turn, action: Constants.Action.DRAW_CARD, cardId: cards[2].cardId }
        @addAction { playerIndex: @json.turn, action: Constants.Action.DISCOVER_CARD, cardId: cards[2].cardId }
    else
      @addFatigueAction(@json.turn)

    # Discard discover cards if the player has max cards in hand
    if @hasMaxCardsInHand(@json.turn)
      @addAction {
        duration: Constants.Duration.DISCARD_CARD
        playerIndex: @json.turn
        action: Constants.Action.DISCARD_CARD
        cardIds: [cards[0].cardId, cards[1].cardId, cards[2].cardId]
      }

  addFatigueAction: (playerIndex, duration) ->
    @json[playerIndex].fatigue += 1
    fatigueDmg = @json[playerIndex].fatigue
    heroId = @json[playerIndex].hero
    hero = @findCard(heroId)
    hero.stats.health -= fatigueDmg
    @addAction { duration: duration, playerIndex: playerIndex, action: Constants.Action.FATIGUE, amount: fatigueDmg }
    if hero.stats.health < 1
      @addDeadCardsAction(heroId)

  addAction: (action) ->
    if action.action == Constants.Action.DRAW_CARD
      action.duration ?= Constants.Duration.DRAW_CARD
      card = @findCard(action.cardId)
      card.playerIndex = action.playerIndex
      card.status = Constants.CardStatus.DISCOVERED

    if action.action == Constants.Action.DISCOVER_CARD
      action.duration ?= Constants.Duration.DISCOVER_CARD

    if action.action == Constants.Action.SELECT_HERO
      card = @findCard(action.cardId)
      @json[action.playerIndex].hero = action.cardId
      card.status = Constants.CardStatus.HERO
      action.discardIds = []
      for dCard in @findCards(playerIndex: action.playerIndex, status: Constants.CardStatus.DISCOVERED)
        if dCard.cardId != card.cardId
          dCard.status = Constants.CardStatus.DISCARDED
          action.discardIds.push dCard.cardId

    if action.action == Constants.Action.SELECT_CARD
      if action.cardId?
        card = @findCard(action.cardId)
        card.status = Constants.CardStatus.HELD
      action.discardIds = []
      for dCard in @findCards(playerIndex: action.playerIndex, status: Constants.CardStatus.DISCOVERED)
        if dCard.cardId != action.cardId
          dCard.status = Constants.CardStatus.DISCARDED
          action.discardIds.push dCard.cardId

    if action.action == Constants.Action.AUTO_SELECT_CARD
      card = @findCard(action.cardId)
      card.playerIndex = action.playerIndex
      card.status = Constants.CardStatus.HELD

    if action.action == Constants.Action.DISCARD_CARD
      for discardId in action.cardIds
        card = @findCard(discardId)
        card.status = Constants.CardStatus.DISCARDED

    if action.action == Constants.Action.SET_MANA
      card = @findCard(action.cardId)
      @json[action.playerIndex].mana -= card.defaults.cost
      action.mana = @json[action.playerIndex].mana

    if action.action == Constants.Action.SET_MAX_MANA
      throw 'to param missing' unless action.to?
      action.to = if action.to > @json.maxMana then @json.maxMana else action.to
      @json[action.playerIndex].maxMana = action.to
      action.mana = @json[action.playerIndex].mana
      action.maxMana = @json[action.playerIndex].maxMana

    if action.action == Constants.Action.REPLENISH_MANA
      @json[action.playerIndex].mana = @getMaxMana(action.playerIndex)
      action.mana = @json[action.playerIndex].mana
      action.maxMana = @json[action.playerIndex].maxMana

    if action.action == Constants.Action.SUMMON_MINION
      action.duration = Constants.Duration.SUMMON_MINION
      card = @findCard(action.cardId)
      card.status = Constants.CardStatus.PLAYED
      if card.charge
        card.attacksLeft = if card.windfury then 2 else 1
      else
        card.attacksLeft = 0

    if action.action == Constants.Action.ATTACK
      action.duration = Constants.Duration.ATTACK
      attacker = @findCard(action.attackerId)
      defender = @findCard(action.defenderId)
      attacker.attacksLeft -= 1
      attacker.stats.health -= defender.stats.attack || 0
      defender.stats.health -= attacker.stats.attack || 0

    if action.action == Constants.Action.DIE
      for id in action.cardIds
        card = @findCard(id)
        card.status = Constants.CardStatus.DISCARDED

    if action.action == Constants.Action.SUMMON_SPELL
      action.targets = []
      action.duration = Constants.Duration.SUMMON_MINION
      card = @findCard(action.cardId)

      card.status = Constants.CardStatus.DISCARDED
      for onPlayEffect in card.onPlay
        for target in @getSpellTargets(action.playerIndex, onPlayEffect)
          @_handleDmgOnPlay(action, onPlayEffect, target)
        @_handleDrawCards(action, onPlayEffect)

    if action.action == Constants.Action.TARGET_SPELL
      action.targets = []
      action.duration = Constants.Duration.DISSOLVE
      card = @findCard(action.cardId)
      target = @findCard(action.targetId)

      card.status = Constants.CardStatus.DISCARDED
      onPlayEffect = card.onPlay.where(target: true).first()
      @_handleBuffOnPlay(action, onPlayEffect, target)
      @_handleDmgOnPlay(action, onPlayEffect, target)

    super(action)

  _handleDrawCards: (action, onPlayEffect) ->
    if onPlayEffect.drawCards?
      action.drawCards = onPlayEffect.drawCards

  _handleBuffOnPlay: (action, onPlayEffect, target) ->
    if onPlayEffect.buff
      hash = { cardId: target.cardId, buff: true, set: onPlayEffect.set }
      hash.health = onPlayEffect.health if onPlayEffect.health?
      hash.attack = onPlayEffect.attack if onPlayEffect.attack?
      hash.taunt = onPlayEffect.taunt if onPlayEffect.taunt?
      action.targets.push hash
      @_handleBuff(target, onPlayEffect)

  _handleBuff: (target, onPlayEffect) ->
    if onPlayEffect.health?
      if onPlayEffect.set
        target.stats.health = onPlayEffect.health
        target.stats.maxHealth = onPlayEffect.health
      else
        target.stats.health += onPlayEffect.health
        target.stats.maxHealth += onPlayEffect.health
    if onPlayEffect.attack?
      if onPlayEffect.set
        target.stats.attack = onPlayEffect.attack
        target.stats.maxAttack = onPlayEffect.attack
      else
        target.stats.attack += onPlayEffect.attack
        target.stats.maxAttack += onPlayEffect.attack
    target.taunt = onPlayEffect.taunt if onPlayEffect.taunt?

  _handleDmgOnPlay: (action, onPlayEffect, target) ->
    if onPlayEffect.dmg?
      action.targets.push { cardId: target.cardId, dmg: onPlayEffect.dmg }
      @_handleDmg(target, onPlayEffect.dmg)

  _handleDmg: (target, dmg) ->
    target.stats.health += dmg
    if target.stats.health > target.defaults.health
      target.stats.health = target.defaults.health

  hasSpellTargets: (playerIndex, onPlayEffect) ->
    @getSpellTargets(playerIndex, onPlayEffect).any()

  getSpellTargets: (playerIndex, onPlayEffect) ->
    targets = []
    return [] if onPlayEffect.target
    otherIndex = @_getOtherPlayerIndex(playerIndex)
    if onPlayEffect.ownMinions
      targets = targets.concat(@findCards(playerIndex: playerIndex, status: Constants.CardStatus.PLAYED))
    if onPlayEffect.enemyMinions
      targets = targets.concat(@findCards(playerIndex: otherIndex, status: Constants.CardStatus.PLAYED))
    if onPlayEffect.ownHero
      targets = targets.concat(@findCards(playerIndex: playerIndex, status: Constants.CardStatus.HERO))
    if onPlayEffect.enemyHero
      targets = targets.concat(@findCards(playerIndex: otherIndex, status: Constants.CardStatus.HERO))
    targets

  addInput: (input) ->
    if @isPhase(Constants.Phase.Arena.HERO_SELECT)
      card = @findCard(input.cardId)
      if card.playerIndex == input.playerIndex and !@isHeroChosen(input.playerIndex)
        return if card.status == Constants.CardStatus.DISCARDED
        super(input)

    if @isPhase(Constants.Phase.Arena.BATTLE)
      switch input.action
        when Constants.Input.END_TURN
          if @isTurn(input.playerIndex)
            super(input)
        when Constants.Input.SELECT_CARD
          # TODO: find out if we need double select protection
          card = @findCard(input.cardId)
          return if card.status != Constants.CardStatus.DISCOVERED
          return if card.playerIndex != input.playerIndex
          return unless @isTurn(input.playerIndex)
          super(input)
        when Constants.Input.PLAY_CARD
          card = @findCard(input.cardId)
          return if card.status != Constants.CardStatus.HELD
          return if card.playerIndex != input.playerIndex
          return unless @isTurn(input.playerIndex)
          return unless @hasManaFor(input.playerIndex, input.cardId)
          if card.type == Constants.CardType.MINION
            return unless @hasMinionSpace(input.playerIndex)
          if card.type == Constants.CardType.SPELL
            return unless @hasSpellTargets(input.playerIndex, card.validTargets)
          super(input)
        when Constants.Input.ATTACK
          card1 = @findCard(input.cards[0])
          card2 = @findCard(input.cards[1])
          if card1.playerIndex == input.playerIndex
            card = card1
            otherCard = card2
          else if card2.playerIndex == input.playerIndex
            card = card2
            otherCard = card1
          else
            console.log "not valid cards for attack #{input.cards}"
            return

          return if ![Constants.CardStatus.PLAYED, Constants.CardStatus.HERO].includes(card1.status)
          return if ![Constants.CardStatus.PLAYED, Constants.CardStatus.HERO].includes(card2.status)
          return if card.attacksLeft <= 0
          return unless @isTurn(input.playerIndex)
          otherIndex = @_getOtherPlayerIndex(card.playerIndex)
          enemyTauntMinions = @findTauntMinions().map (e) -> e.cardId
          if enemyTauntMinions.any()
            return unless enemyTauntMinions.includes(otherCard.cardId)
          super(input)
        when Constants.Input.TARGET_SPELL
          return unless @isTurn(input.playerIndex)
          return unless input.cardId?
          return unless input.targetId?
          spellCard = @findCard(input.cardId)
          targetCard = @findCard(input.targetId)
          return unless spellCard?
          return unless targetCard?
          validTargets = @getSpellTargets(input.playerIndex, spellCard.validTargets)
          return if validTargets.isEmpty()
          super(input)
        else
          console.log "not adding, unknown input action #{input.action}"

  isHeroChosen: (playerIndex) ->
    @json[playerIndex].hero?

  _getOtherPlayerIndex: (playerIndex) ->
    return 'player2' if playerIndex == 'player1'
    return 'player1' if playerIndex == 'player2'
    throw "unknown playerIndex #{playerIndex}"

  _prepareCards: ->
    i = 0
    for card in @json.cards
      card.cardId = i
      i += 1

exports.ArenaReferee = ArenaReferee
