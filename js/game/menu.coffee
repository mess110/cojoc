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
  ).when('/games',
    templateUrl: 'views/games.html'
    controller: 'GamesController'
  ).when('/games/new',
    templateUrl: 'views/new-game.html'
    controller: 'NewGameController'
  ).when('/games/:id',
    templateUrl: 'views/game.html'
    controller: 'GameController'
  ).otherwise redirectTo: '/'
  return

app.controller 'MainController', ($scope, $location, toastr) ->
  $scope.game =
    loaded: false
    connected: false

  $scope.play = ->
    toastr.success('Not implemented')

  $scope.cards = ->
    engine.initScene(cardsScene, {}, true)
    $scope.goTo('/cards')

  $scope.options = ->
    $scope.goTo('/settings')

  $scope.home = ->
    if SceneManager.get().currentScene() != menuScene
      engine.initScene(menuScene, {}, true)
    $scope.goTo('/')

  $scope.goTo = (url) ->
    $location.path(url)

  $scope.start = () ->
    return if !($scope.game.loaded && $scope.game.connected)
    if $location.path() == '/cards'
      scene = cardsScene
    else
      scene = menuScene

    engine.initScene(scene, {}, false)

app.controller 'LandingController', ($scope) ->
  document.getElementById("back-button").style.opacity = 0

app.controller 'CardsController', ($scope) ->
  document.getElementById("back-button").style.opacity = 1

app.controller 'LeaderboardsController', ($scope) ->

app.controller 'GamesController', ($scope) ->

app.controller 'GameController', ($scope) ->

app.controller 'NewGameController', ($scope) ->

app.controller 'SettingsController', ($scope) ->
  document.getElementById("back-button").style.opacity = 1

getScope = ->
  angular.element(document.body).scope()
