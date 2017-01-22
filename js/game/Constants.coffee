Constants =
  Errors:
    CONNECTION_REFUSED: 1
    MISSING_GAME_ID: 2
    GAME_NOT_FOUND: 3

  ValidToasts: [
    'success'
    'info'
    'warning'
    'error'
  ]

  Storage:
    PREFIX: 'cojoc'
    SOUND: 'sound'
    BOT: 'bot'
    VOLUME: 'volume'
    CURRENT_ID: 'currentId'
    TMP_USER: 'tmpUser'

  MINION_SCALE: 0.8

  TEXT_COLOR: '#f9f9f9'
  TEXT_DAMAGED_COLOR: 'red'
  TEXT_BUFFED_COLOR: 'green'

  STROKE_COLOR: 'black'

  FLAVOR_FONT: '35px Pirata One'
  FLAVOR_TEXT_COLOR: '#f9f9f9'
  FLAVOR_STROKE_COLOR: 'black'

  MINION_STAT_FONT: '100px Pirata One'
  CARD_STAT_FONT: '50px Pirata One'

  END_TURN_TIMEOUT: 75 # seconds

  NameCurve:
    DEFAULT: '0,0,100,0,200,0,300,0'
    SAD_MOUTH: '20,0,84,-30,168,-30,276,0'
    HAPPY_MOUTH: '20,0,84,30,168,30,276,0'
    SNAKE: '20,0,104,-40,188,40,296,-20'

  CardType:
    HERO: 'hero'
    MINION: 'minion'
    SPELL: 'spell'

  CardStatus:
    DISCOVERED: 'discover'
    DISCARDED: 'discarded'
    HERO: 'hero'
    HELD: 'held'
    PLAYED: 'played'

  GameType:
    ARENA: 0

  Phase:
    Arena:
      HERO_SELECT: 0
      BATTLE: 1
      FINISHED: 2

  Input:
    START_GAME: 'startGame'
    SELECT_CARD: 'selectCard'
    END_TURN: 'endTurn'
    PLAY_CARD: 'playCard'
    ATTACK: 'attack'
    TARGET_SPELL: 'targetSpell'

  Action:
    DRAW_CARD: 'drawCard'
    HOLD_CARD: 'holdCard'
    DISCOVER_CARD: 'discoverCard'
    DISCARD_CARD: 'discardCard'
    SELECT_HERO: 'selectHero'
    SELECT_CARD: 'selectCard'
    UPDATE_END_TURN_BUTTON: 'updateEndTurnButton'
    SET_MANA: 'setMana'
    SET_MAX_MANA: 'setMaxMana'
    REPLENISH_MANA: 'replenishMana'
    SUMMON_MINION: 'summonMinion'
    AUTO_SELECT_CARD: 'autoSelectCard'
    ATTACK: 'attack'
    DIE: 'die'
    FINISH: 'finish'
    FATIGUE: 'fatigue'
    SUMMON_SPELL: 'summonSpell'
    TARGET_SPELL: 'targetSpell'
    AOE_SPELL: 'aoeSpell'

  Position:
    Strategy:
      RANDOM: 'random'
      QUEUE: 'queue'
      STACK: 'stack'
    Player:
      SELF: 0
      OPPONENT: 1

  Duration:
    DEFAULT: 200
    DRAW_CARD: 200
    DISCOVER_CARD: 200
    DISCARD_CARD: 300
    SELECT_CARD: 100
    UPDATE_END_TURN: 600
    SUMMON_MINION: 1000
    ATTACK: 1500
    DISSOLVE: 1000
    DAMAGE_SIGN: 2000

  Targeting:
    ALL: { ownMinions: true, enemyMinions: true, ownHero: true, enemyHero: true }
    ENEMY_MINIONS: { ownMinions: false, enemyMinions: true, ownHero: false, enemyHero: false }
    OWN_MINIONS: { ownMinions: true, enemyMinions: false, ownHero: false, enemyHero: false }
    ALL_MINIONS: { ownMinions: true, enemyMinions: true, ownHero: false, enemyHero: false }

Constants.DEFAULT_TOAST = Constants.ValidToasts.first()

exports.Constants = Constants
