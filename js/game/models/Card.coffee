class Card extends BaseModel
  constructor: ->
    super()

    cardWidth = undefined
    cardHeight = undefined

    @mesh = new THREE.Object3D()

    @art = new ArtGenerator(width: 336, height: 452)
    @art.drawImage(key: 'card-art-bg')
    @art.drawImage(key: 'sanziene')
    @art.drawImage(key: 'card-template')
    @art.drawImage(key: 'heart', x: 336 - 64, y: 452 - 64)
    @art.drawImage(key: 'wood-sword', y: 452 - 64)
    @art.drawImage(key: 'mana-crystal')
    @art.drawText(text: '5', strokeStyle: 'black', x: 25, y: 45, font: '30px Pirata One')
    @art.drawText(text: '4', strokeStyle: 'black', x: 25, y: 452 - 22, font: '30px Pirata One')
    @art.drawText(text: '2', strokeStyle: 'black', x: 336 - 36, y: 452 - 22, font: '30px Pirata One')
    @art.drawText(text: 'Charge', strokeStyle: 'black', x: 336 / 2 - 30, y: 452 / 3 * 2 + 50, font: '20px Pirata One')

    @art.drawBezier(
      curve: '20,157.2,130.02,100.0,150.5,246.2,492,176.3'
      text: 'Sânziene'
      x: 100, y: 90
      strokeStyle: 'black'
      letterPadding: 4
      font: '30px Pirata One'
    )

    material = Helper.materialFromCanvas(@art.canvas)

    @front = Helper.plane(material: material, width: cardWidth, height: cardHeight)
    @mesh.add @front

    backMaterial = new THREE.MeshBasicMaterial(
      map: TextureManager.get().items['card-bg']
    )
    @back = Helper.plane(material: backMaterial, width: cardWidth, height: cardHeight)
    @back.rotation.set Math.PI, 0, Math.PI
    @mesh.add @back
