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
    @position = {x:0,y:0,z:0}
window.Cube = Cube

class Shape
  size: 3
  constructor: (@position,@field) ->
    @blockShape = []
    for row,i in @originalShape()
      @blockShape[i] = []
      for bit,j in row
        if bit == 1
          @blockShape[i][j] = [0, new Cube(),0]
        else
          @blockShape[i][j] = [0,0,0]

    @updatePosition()
    @updateMeshPositions()

  updatePosition: ->
    for row,i in @blockShape
      for line,j in row
        for cube,k in line
          if cube != 0
            p = cube.position
            @field[p.x]?[p.y]?[p.z] = null
            p.x = @position.x + j
            p.y = @position.y + i
            p.z = @position.z - k

    for block in @blocks()
      position = block.position
      if position.x == -1 ||
         position.y == -1 ||
         position.z == -1 ||
         position.x == Game.WIDTH  ||
         position.y == Game.HEIGHT ||
         position.z == Game.DEPTH
        return false
      if not @field[position.x][position.y][position.z]?
        @field[position.x][position.y][position.z] = cube
      else
        return false
    return true

  rotate: (direction) ->
    @[direction]()

  yaw: ->
    yaw = =>
      rotated = []
      for i in [0..(@size - 1)]
        rotated[i] = []
        for j in [0..(@size - 1)]
          newX = @size - j - 1
          rotated[i][j] = @blockShape[@size - j - 1][i]
      @blockShape = rotated

    yaw()
    if !@updatePosition()
      yaw() for [0..2]
      @updatePosition()
      return false
    else
      return true

  pitch: ->
    pitch = =>
      rotated = []
      for i in [0..(@size - 1)]
        rotated[i] = []
        for j in [0..(@size - 1)]
          newX = @size - j - 1
          rotated[i][j] = @blockShape[@size - j - 1][i]
      @blockShape = rotated

    pitch()
    if !@updatePosition()
      pitch() for [0..2]
      @updatePosition()
      return false
    else
      return true

  updateMeshPositions: () ->
    DX = -(2 * Graphics.BLOCK_SIZE)
    DY = (2 * Graphics.BLOCK_SIZE)
    DZ = -((Game.DEPTH - 1) * Graphics.BLOCK_SIZE)

    for row,i in @blockShape
      for line,j in row
        for cube,k in line
          if cube != 0
            cube.mesh.position.x = DX + Graphics.BLOCK_SIZE * j + @position.x * Graphics.BLOCK_SIZE
            cube.mesh.position.y = DY + Graphics.BLOCK_SIZE * -i + @position.y * -Graphics.BLOCK_SIZE
            cube.mesh.position.z = DZ + Graphics.BLOCK_SIZE * -k + @position.z * Graphics.BLOCK_SIZE

  _blocks: null
  blocks: ->
    return @_blocks if @_blocks?
    @_blocks = []
    for row in @blockShape
      for line in row
        for cube in line
          if cube != 0
            @_blocks.push cube
    @_blocks

  addToScene: (@scene) ->
    for cube in @blocks()
      @scene.add(cube.mesh)

  removeFromScene: (@scene) ->
    for cube in @blocks()
      @scene.remove(cube.mesh)

window.Shape = Shape

class LShape extends Shape
  originalShape: -> [
      [1,1,1]
      [1,0,0]
      [0,0,0]
    ]

window.LShape = LShape
