Constants = require('../Constants.coffee').Constants unless Constants?

Cards = [
  {
    key: 'calulNazdravan'
    name: 'Calul Năzdrăvan'
    type: Constants.CardType.MINION
    defaults:
      cost: 4
      attack: 6
      health: 2
  }
  {
    key: 'corb'
    name: 'Corb'
    type: Constants.CardType.MINION
    defaults:
      cost: 1
      attack: 2
      health: 1
  }
  {
    key: 'muma'
    name: 'Muma Pădurii'
    type: Constants.CardType.MINION
    defaults:
      cost: 3
      attack: 3
      health: 3
  }
  {
    key: 'sanziene'
    name: 'Sânziene'
    type: Constants.CardType.MINION
    defaults:
      health: 30
  }
  {
    key: 'babaDochia'
    name: 'Baba Dochia'
    type: Constants.CardType.HERO
    defaults:
      health: 30
  }
  {
    key: 'ileanaCosanzeana'
    name: 'Ileana Cosânzeana'
    type: Constants.CardType.HERO
    defaults:
      health: 30
  }
  {
    key: 'zalmoxis'
    name: 'Zalmoxis'
    type: Constants.CardType.HERO
    defaults:
      health: 30
  }
]

Cards.random = (count = 1) ->
  array = []
  for i in [0...count]
    array.push Cards.randomMinion()
  array

Cards.minions = ->
  Cards.where(type: Constants.CardType.MINION).shallowClone()

Cards.heroes = ->
  Cards.where(type: Constants.CardType.HERO).shallowClone()

Cards.spells = ->
  Cards.where(type: Constants.CardType.SPELL).shallowClone()

Cards.randomMinion = ->
  @minions().shuffle().first()

Cards.randomHero = ->
  @heroes().shuffle().first()

Cards.randomSpell = ->
  @spells().shuffle().first()

exports.Cards = Cards
