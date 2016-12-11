app = angular.module('app', ['ngRoute', 'ngAnimate', 'toastr'])

app.config ($routeProvider) ->
  $routeProvider.when('/',
    templateUrl: 'views/landing.html'
    controller: 'LandingController'
  ).when('/cards',
    templateUrl: 'views/cards.html'
    controller: 'CardsController'
  ).when('/leaderboards',
    templateUrl: 'views/leaderboards.html'
    controller: 'LeaderboardsController'
  ).when('/settings',
    templateUrl: 'views/settings.html'
    controller: 'SettingsController'
  ).when('/waiting',
    templateUrl: 'views/waiting.html'
    controller: 'WaitingController'
  ).when('/games',
    templateUrl: 'views/games.html'
    controller: 'GamesController'
  ).when('/games/new',
    templateUrl: 'views/new-game.html'
    controller: 'NewGameController'
  ).when('/game/:id',
    templateUrl: 'views/game.html'
    controller: 'GameController'
  ).otherwise redirectTo: '/'
  return

app.controller 'MainController', ($scope, $location, $routeParams, $timeout, toastr) ->
  $scope.inputDisabled = false
  $scope.game =
    loaded: false
    connected: false

  $scope.play = ->
    return if $scope.inputDisabled
    $scope.inputDisabled = true
    $scope.goTo('/waiting')

  $scope.cards = ->
    return if $scope.inputDisabled
    $scope.inputDisabled = true
    engine.initScene(cardsScene, {}, true)
    $timeout ->
      $scope.goTo('/cards')
    , Utils.FADE_DEFAULT_DURATION / 2

  $scope.options = ->
    return if $scope.inputDisabled
    $scope.inputDisabled = true
    $scope.goTo('/settings')

  $scope.home = ->
    return if $scope.inputDisabled
    $scope.inputDisabled = true
    if $location.path() == '/waiting'
      NetworkManager.emit(type: 'leaveQueue')
    if SceneManager.currentScene() != menuScene
      engine.initScene(menuScene, {}, true)
    $timeout ->
      $scope.goTo('/')
    , Utils.FADE_DEFAULT_DURATION / 2

  $scope.$watch 'inputDisabled', (newValue, oldValue) ->
    return unless newValue
    $timeout ->
      $scope.inputDisabled = false
    , Utils.FADE_DEFAULT_DURATION

  $scope.toastr = (data={}) ->
    unless Constants.ValidToasts.includes(data.type)
      data.type = Constants.DEFAULT_TOAST
    console.ce "Toastr: #{data.code} - #{data.message} - #{data.type}"
    toastr[data.type](data.message) if data.message?

  $scope.goTo = (url) ->
    $location.path(url)

  $scope.game = (data) ->
    toastr.clear()
    $scope.goTo("/game/#{data.id}")
    engine.initScene(gameScene, data, true)

  $scope.prev = ->
    if SceneManager.currentScene() == cardsScene
      cardsScene.prev()

  $scope.next = ->
    if SceneManager.currentScene() == cardsScene
      cardsScene.next()

  $scope.start = () ->
    return if !($scope.game.loaded && $scope.game.connected)
    path = $location.path()
    options = {}

    if path == '/cards'
      scene = cardsScene
    else if path == '/waiting'
      return
    else if path.startsWith('/game')
      scene = gameScene
      options.id = $routeParams.id
    else
      scene = menuScene

    engine.initScene(scene, options, false)

app.controller 'LandingController', ($scope) ->
  document.getElementById("back-button").style.opacity = 0
  document.getElementById("prev").style.opacity = 0
  document.getElementById("next").style.opacity = 0

app.controller 'CardsController', ($scope) ->
  document.getElementById("back-button").style.opacity = 1
  document.getElementById("prev").style.opacity = 1
  document.getElementById("next").style.opacity = 1

app.controller 'LeaderboardsController', ($scope) ->

app.controller 'GamesController', ($scope) ->

app.controller 'WaitingController', ($scope, $interval, toastr) ->
  document.getElementById("back-button").style.opacity = 1
  if Persist.get(Constants.Storage.BOT)
    $scope.game(id: 'bot')
  else
    $scope.toastr(message: 'You are queued')
    NetworkManager.emit(type: 'joinQueue')

app.controller 'GameController', ($scope) ->
  document.getElementById("back-button").style.opacity = 1

app.controller 'NewGameController', ($scope) ->

app.controller 'SettingsController', ($scope) ->
  document.getElementById("back-button").style.opacity = 1
  $scope.sound = Persist.get(Constants.Storage.SOUND)
  $scope.bot = Persist.get(Constants.Storage.BOT)
  $scope.volume = Persist.get(Constants.Storage.VOLUME)

  $scope.$watch 'bot', (newValue, oldValue) ->
    Persist.set(Constants.Storage.BOT, newValue)

  $scope.$watch 'volume', (newValue, oldValue) ->
    Persist.set(Constants.Storage.VOLUME, newValue)
    SoundManager.volumeAll(newValue)

  $scope.$watch 'sound', (newValue, oldValue) ->
    return unless SoundManager.get().has('prologue')
    return if oldValue == newValue
    Persist.set(Constants.Storage.SOUND, newValue)
    if newValue
      SoundManager.get().play('prologue')
    else
      SoundManager.get().stop('prologue')

getScope = ->
  angular.element(document.body).scope()
