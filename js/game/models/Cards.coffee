Constants = require('../Constants.coffee').Constants unless Constants?

Cards = [
  # ------------------------ #
  #        Minions           #
  # ------------------------ #
  {
    key: 'viespe'
    name: 'Viespe'
    type: Constants.CardType.MINION
    charge: true
    nameX: 105
    defaults:
      cost: 1
      attack: 2
      health: 1
  }
  {
    key: 'corb'
    name: 'Corb'
    type: Constants.CardType.MINION
    nameX: 120
    defaults:
      cost: 1
      attack: 1
      health: 2
  }
  {
    key: 'calulNazdravan'
    name: 'Calul Năzdrăvan'
    nameCurve: Constants.NameCurve.SNAKE
    nameX: 15
    nameFontSize: 45
    nameLetterPadding: 5
    nameAddY: 5
    type: Constants.CardType.MINION
    windfury: true
    defaults:
      cost: 2
      attack: 3
      health: 2
  }
  {
    key: 'zorila'
    name: 'Zorilă'
    nameX: 110
    type: Constants.CardType.MINION
    defaults:
      cost: 2
      attack: 2
      health: 3
  }
  {
    key: 'muma'
    name: 'Muma Pădurii'
    type: Constants.CardType.MINION
    nameCurve: Constants.NameCurve.SAD_MOUTH
    nameFontSize: 40
    nameX: 30
    nameAddY: 9
    defaults:
      cost: 3
      attack: 4
      health: 3
  }
  {
    key: 'sanziene'
    name: 'Sânziene'
    nameX: 90
    type: Constants.CardType.MINION
    defaults:
      cost: 3
      attack: 3
      health: 4
  }
  {
    key: 'pasareaMaiastra'
    name: 'Pasărea Măiastră'
    taunt: true
    nameX: 20
    nameAddY: 0
    nameLetterPadding: 4
    nameFontSize: 35
    nameCurve: Constants.NameCurve.SNAKE
    type: Constants.CardType.MINION
    defaults:
      cost: 4
      attack: 2
      health: 6
  }
  {
    key: 'spiridus'
    name: 'Spiriduș'
    nameX: 90
    type: Constants.CardType.MINION
    defaults:
      cost: 4
      attack: 2
      health: 6
  }
  {
    key: 'capcaun'
    name: 'Căpcăun'
    taunt: true
    nameX: 90
    type: Constants.CardType.MINION
    defaults:
      cost: 4
      attack: 2
      health: 6
  }

  # ------------------------ #
  #         Spells           #
  # ------------------------ #
  {
    key: 'fireember'
    name: 'Jar'
    nameX: 135
    type: Constants.CardType.SPELL
    defaults:
      cost: 1
    onPlay: [
      { dmg: -2, enemyMinions: true, enemyHero: true }
    ]
  }
  {
    key: 'fireball'
    name: 'Foc'
    nameX: 135
    type: Constants.CardType.SPELL
    defaults:
      cost: 2
    onPlay: [
      { target: true, dmg: -4 }
    ]
  }
  {
    key: 'pyroblast'
    name: 'Meteorit'
    nameX: 90
    type: Constants.CardType.SPELL
    defaults:
      cost: 1
    onPlay: [
      { target: false, dmg: -2, ownMinions: true, enemyMinions: true }
    ]
  }
  {
    key: 'lesserHeal'
    name: 'Fașă'
    nameX: 115
    type: Constants.CardType.SPELL
    defaults:
      cost: 1
    onPlay: [
      { dmg: 2, ownMinions: true, ownHero: true }
      { dmg: -2, enemyMinions: true, enemyHero: true }
    ]
  }
  {
    key: 'heal'
    name: 'Trusă Medicală'
    nameX: 25
    nameFontSize: 45
    nameLetterPadding: 5
    nameCurve: Constants.NameCurve.SNAKE
    type: Constants.CardType.SPELL
    defaults:
      cost: 2
    onPlay: [
      { target: false, dmg: 4, ownMinions: true }
    ]
  }
  {
    key: 'greaterHeal'
    name: 'Țuică'
    nameX: 110
    type: Constants.CardType.SPELL
    defaults:
      cost: 1
    onPlay: [
      { target: true, dmg: 6 }
    ]
  }

  # ------------------------ #
  #         Heroes           #
  # ------------------------ #
  {
    key: 'babaDochia'
    name: 'Baba Dochia'
    nameX: 60
    type: Constants.CardType.HERO
    defaults:
      health: 21
  }
  {
    key: 'ileanaCosanzeana'
    name: 'Ileana Cosânzeana'
    type: Constants.CardType.HERO
    nameX: 20
    nameAddY: 0
    nameLetterPadding: 4
    nameFontSize: 35
    nameCurve: Constants.NameCurve.SNAKE
    defaults:
      health: 21
  }
  {
    key: 'zalmoxis'
    name: 'Zalmoxis'
    type: Constants.CardType.HERO
    nameLetterPadding: 7.5
    nameX: 90
    defaults:
      health: 21
  }
]

Cards.random = (count = 1) ->
  array = []
  for i in [0...count]
    array.push Cards.minions().concat(Cards.spells()).shuffle().shallowClone().first()
  array

Cards.minions = ->
  Cards.where(type: Constants.CardType.MINION).shallowClone()
  # @spells()

Cards.heroes = ->
  Cards.where(type: Constants.CardType.HERO).shallowClone()

Cards.spells = ->
  Cards.where(type: Constants.CardType.SPELL).shallowClone()
  # @minions()

Cards.randomMinion = ->
  @minions().shuffle().first()

Cards.randomHero = ->
  @heroes().shuffle().first()

Cards.randomSpell = ->
  @spells().shuffle().first()

for pureCard in Cards
  pureCard.stats = JSON.parse(JSON.stringify(pureCard.defaults))
  pureCard.onPlay ?= []

# TODO: make sure there is maximum 1 target onplayeffect per card

exports.Cards = Cards
