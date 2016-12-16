Cards = [
  {
    key: 'calulNazdravan'
    name: 'Calul Năzdrăvan'
    type: Constants.CardTypes.MINION
    defaults:
      cost: 4
      attack: 6
      health: 2
  }
  {
    key: 'corb'
    name: 'Corb'
    type: Constants.CardTypes.MINION
    defaults:
      cost: 1
      attack: 2
      health: 1
  }
  {
    key: 'muma'
    name: 'Muma Pădurii'
    type: Constants.CardTypes.MINION
    defaults:
      cost: 3
      attack: 3
      health: 3
  }
  {
    key: 'sanziene'
    name: 'Sânziene'
    type: Constants.CardTypes.MINION
    defaults:
      health: 30
  }
  {
    key: 'babaDochia'
    name: 'Baba Dochia'
    type: Constants.CardTypes.HERO
    defaults:
      health: 30
  }
  {
    key: 'ileanaCosanzeana'
    name: 'Ileana Cosânzeana'
    type: Constants.CardTypes.HERO
    defaults:
      health: 30
  }
  {
    key: 'zalmoxis'
    name: 'Zalmoxis'
    type: Constants.CardTypes.HERO
    defaults:
      health: 30
  }
]

Cards.minions = ->
  Cards.where(type: Constants.CardTypes.MINION)

Cards.heroes = ->
  Cards.where(type: Constants.CardTypes.HERO)

Cards.spells = ->
  Cards.where(type: Constants.CardTypes.SPELL)

Cards.randomMinion = ->
  @minions().shuffle().first()

Cards.randomHero = ->
  @heroes().shuffle().first()

Cards.randomSpell = ->
  @spells().shuffle().first()
