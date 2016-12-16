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

  CardTypes:
    HERO: 'hero'
    MINION: 'minion'
    SPELL: 'spell'

Constants.DEFAULT_TOAST = Constants.ValidToasts.first()

exports.Constants = Constants
