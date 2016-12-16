class Curve extends THREE.CatmullRomCurve3
  constructor: (points) ->
    super(points)
    @modifier = 1

    @original = Helper.shallowClone(points)

  scale: (amount) ->
    maxY = 0
    i = 0
    for point in @points
      point.x = @original[i].x * amount
      point.y = @original[i].y * amount
      maxY = point.y if maxY < point.y
      i += 1

    for point in @points
      point.y -= maxY

  findPoints: (count) ->
    return [] if count == 0
    return [new THREE.Vector3(0, 0, 0)] if count == 1
    @getPoints(count - 1)

class HandCurve extends Curve
  constructor: ->
    super([
      new (THREE.Vector3)(-6, 0, 0)
      new (THREE.Vector3)(-2, 1, 0)
      new (THREE.Vector3)(2, 1, 0)
      new (THREE.Vector3)(6, 0, 0)
    ])

class MinionsCurve extends Curve
  constructor: ->
    super([
      new (THREE.Vector3)(-15, 0, 0)
      new (THREE.Vector3)(-5, 0, 0)
      new (THREE.Vector3)(5, 0, 0)
      new (THREE.Vector3)(15, 0, 0)
    ])
