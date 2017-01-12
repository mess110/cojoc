class CojocText extends BaseText
  constructor: (align = undefined) ->
    options =
      font: 'bolder 60px Pirata One'
      strokeStyle: Constants.STROKE_COLOR
      fillStyle: Constants.TEXT_COLOR
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
      strokeStyle: Constants.STROKE_COLOR
      strokeLineWidth: 10
      fillStyle: Constants.TEXT_COLOR
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
      strokeStyle: Constants.STROKE_COLOR
      strokeLineWidth: 10
      fillStyle: Constants.TEXT_COLOR
      align: align
      text: 'hello'
      w: 4
      h: 4
      y: 20
      canvasW: 256
      canvasH: 256
    super(options)

class BigText3 extends BaseText
  constructor: (align = undefined) ->
    options =
      font: 'bolder 90px Pirata One'
      strokeStyle: Constants.STROKE_COLOR
      strokeLineWidth: 10
      fillStyle: Constants.TEXT_COLOR
      align: align
      text: 'hello'
      w: 4
      h: 4
      y: 20
      canvasW: 512
      canvasH: 512
    super(options)
