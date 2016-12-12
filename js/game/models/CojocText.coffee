class CojocText extends BaseText
  constructor: () ->
    options =
      font: 'bolder 60px Pirata One'
      strokeStyle: 'black'
      fillStyle: 'white'
      text: 'hello'
      # align: 'center'
      w: 1.25
      h: 1.25
      y: 10
      canvasW: 256
      canvasH: 256
    super(options)

class BigText extends BaseText
  constructor: () ->
    options =
      font: 'bolder 50px Pirata One'
      strokeStyle: 'black'
      strokeLineWidth: 10
      fillStyle: 'white'
      text: 'hello'
      w: 4
      h: 4
      canvasW: 256
      canvasH: 256
    super(options)
