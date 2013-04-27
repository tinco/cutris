class Cube
  constructor: ->
    size = Graphics.BLOCK_SIZE

    cubeMaterial =
      new THREE.MeshLambertMaterial(color: 0x0033FF, wireframe: false)

    cubeMaterial.opacity = 1

    @mesh = new THREE.Mesh(
      new THREE.CubeGeometry(size,size,size,1,1,1),
      cubeMaterial
    )
    @mesh.cube = @
    @position = {}

  updatePosition: () ->
    @mesh.position = @position

window.Cube = Cube

class Shape
  constructor: (@position) ->
    for row in @blockShape
      for bit,i in row
        if bit == 1
          row[i] = new Cube()
    @updatePosition()

  updatePosition: () ->
    DX = -(2 * Graphics.BLOCK_SIZE)
    DY = (2 * Graphics.BLOCK_SIZE)
    DZ = -((Game.DEPTH - 1) * Graphics.BLOCK_SIZE)

    for row,i in @blockShape
      for cube,j in row
        if cube != 0
          cube.position.x = DX + Graphics.BLOCK_SIZE * j + @position.x * Graphics.BLOCK_SIZE
          cube.position.y = DY + Graphics.BLOCK_SIZE * -i + @position.y * -Graphics.BLOCK_SIZE
          cube.position.z = DZ + @position.z * Graphics.BLOCK_SIZE
          cube.updatePosition()

  addToScene: (@scene) ->
    for row in @blockShape
      for cube in row
        if cube != 0
          @scene.add(cube.mesh)

  removeFromScene: (@scene) ->
    for row in @blockShape
      for cube in row
        if cube != 0
          @scene.remove(cube.mesh)

window.Shape = Shape

class LShape extends Shape
  blockShape: [
      [1,1,1]
      [1,0,0]
    ]

window.LShape = LShape
