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

  GameType:
    ARENA: 0

  Phase:
    Arena:
      HERO_SELECT: 0

  Input:
    START_GAME: 'startGame'
    SELECT_CARD: 'selectCard'

  Action:
    DRAW_CARD: 'drawCard'
    HOLD_CARD: 'holdCard'
    DISCARD_CARD: 'discardCard'
    SELECT_HERO: 'selectHero'

Constants.DEFAULT_TOAST = Constants.ValidToasts.first()

exports.Constants = Constants
