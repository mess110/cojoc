class EndTurnTimer

  constructor: ->
    @turnDuration = Constants.END_TURN_TIMEOUT * 1000

  start: ->
    @stop()

    console.ce 'turn started'
    @timeout = setTimeout ->
      SceneManager.currentScene()._emit(
        type: 'gameInput'
        action: Constants.Input.END_TURN
      )
    , @turnDuration

    @timeout2 = setTimeout ->
      console.ce 'half time'
    , @turnDuration / 2

  stop: ->
    console.ce 'stopping turn'
    clearTimeout @timeout if @timeout?
    clearTimeout @timeout2 if @timeout2?
