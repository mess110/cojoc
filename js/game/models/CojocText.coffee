class CojocText extends BaseText
  constructor: (align = undefined) ->
    options =
      font: 'bolder 60px Pirata One'
      strokeStyle: 'black'
      fillStyle: 'white'
      text: 'hello'
      align: align
      w: 1.25
      h: 1.25
      y: 10
      canvasW: 256
      canvasH: 256
    super(options)

class BigText extends BaseText
  constructor: (align = undefined) ->
    options =
      font: 'bolder 50px Pirata One'
      strokeStyle: 'black'
      strokeLineWidth: 10
      fillStyle: 'white'
      align: align
      text: 'hello'
      w: 4
      h: 4
      canvasW: 256
      canvasH: 256
    super(options)

class BigText2 extends BaseText
  constructor: (align = undefined) ->
    options =
      font: 'bolder 50px Pirata One'
      strokeStyle: 'black'
      strokeLineWidth: 10
      fillStyle: 'white'
      align: align
      text: 'hello'
      w: 4
      h: 4
      y: 20
      canvasW: 256
      canvasH: 256
    super(options)
