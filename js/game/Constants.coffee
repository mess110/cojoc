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

  CardType:
    HERO: 'hero'
    MINION: 'minion'
    SPELL: 'spell'

  CardStatus:
    DISCOVERED: 'discover'
    DISCARDED: 'discarded'
    HERO: 'hero'
    HELD: 'held'

  GameType:
    ARENA: 0

  Phase:
    Arena:
      HERO_SELECT: 0
      BATTLE: 1

  Input:
    START_GAME: 'startGame'
    SELECT_CARD: 'selectCard'
    END_TURN: 'endTurn'

  Action:
    DRAW_CARD: 'drawCard'
    HOLD_CARD: 'holdCard'
    DISCOVER_CARD: 'discoverCard'
    DISCARD_CARD: 'discardCard'
    SELECT_HERO: 'selectHero'
    SELECT_CARD: 'selectCard'
    UPDATE_END_TURN_BUTTON: 'updateEndTurnButton'
    SET_MAX_MANA: 'setMaxMana'
    REPLENISH_MANA: 'replenishMana'

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
    UPDATE_END_TURN: 300

Constants.DEFAULT_TOAST = Constants.ValidToasts.first()

exports.Constants = Constants
