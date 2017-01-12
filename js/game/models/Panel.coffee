class BasePanel extends BoxedModel
  setText: (s) ->
    @text.setText(s)

class ChooseCardPanel extends BasePanel
  constructor: ->
    super()

    @width = 1
    @height = 4

    geom = new THREE.PlaneBufferGeometry(@width, @height)
    material = Helper.basicMaterial('panel2')
    @mesh = new THREE.Mesh(geom, material)
    @mesh.rotation.set 0, 0, Math.PI / 2

    @text = new BigText3('center')
    @mesh.add @text.mesh
    @text.setText('Alege o carte')
    @text.mesh.rotation.set 0, 0, -Math.PI / 2
    @text.mesh.position.x = -1.30

    @box = new THREE.Mesh(
      new THREE.BoxGeometry(@width, @height, 0.1),
      @_boxMaterial()
    )
    @mesh.add @box
    @setScale(0.9)

class PlayCardPanel extends ChooseCardPanel
  constructor: ->
    super()
    @setText('Joacă o carte')
    @setScale(1.1)

class EndTurnPanel extends ChooseCardPanel
  constructor: ->
    super()
    @setText('Termină tura')
    @setScale(2.2)
