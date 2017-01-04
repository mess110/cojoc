# class responsible for figuring out which card the player is hovering
# and sending it the server
class HoverMasta
  constructor: (scene, mover) ->
    @scene = scene
    @mover = mover
    @lastHoveredCard = undefined
    @lastUiHoveredCard = undefined # refers to the card hovered by the enemy

  tick: (tpf) ->
    myIndex = @mover._getMyPlayerIndex()
    opponentIndex = @mover._getOpponentPlayerIndex()

    myDiscover = @mover._findDiscoverFor(myIndex)
    myDiscoverHover = myDiscover.selectedCard if myDiscover? and myDiscover.toggleButton.isFaceUp()

    myHeroHover = @mover._findHeroFor(myIndex).selectedCard
    opponentHeroHover = @mover._findHeroFor(opponentIndex).selectedCard

    myHandHover = @mover._findHandFor(myIndex).selectedCard

    myMinionsHover = @mover._findMinionsFor(myIndex).selectedCard
    opponentMinionsHover = @mover._findMinionsFor(opponentIndex).selectedCard

    @checkHovered(myHandHover or myDiscoverHover or myHeroHover or opponentHeroHover or opponentMinionsHover or myMinionsHover)

  changeHovered: (newHovered) ->
    @lastHoveredCard = newHovered
    # TODO: emit
    toSendId = if newHovered? then newHovered.id else undefined
    @scene._emit(
      type: 'highlight'
      cardId: toSendId
    )

  checkHovered: (newHovered) ->
    if newHovered?
      if @lastHoveredCard?
        if @lastHoveredCard.id != newHovered.id
          @changeHovered(newHovered)
      else
        @changeHovered(newHovered)
    else
      if @lastHoveredCard != undefined
        @changeHovered(newHovered)

  highlight: (data) ->
    unless data.cardId?
      if @lastUiHoveredCard?
        @lastUiHoveredCard.glow.none()
        @lastUiHoveredCard = undefined
    else
      if @lastUiHoveredCard? and @lastUiHoveredCard.id != data.cardId
        @lastUiHoveredCard.glow.none()
      card = @mover._findCard(data.cardId)
      @lastUiHoveredCard = card
      card.glow.red()
