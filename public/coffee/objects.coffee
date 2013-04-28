class Cube
  @MaterialForDepth = []
  @ActiveMaterialForDepth = []
  @Colors = []

  for h in [0...5]
    @Colors[h] = new THREE.Color()
    @Colors[h].setHSL(h/5,0.85,0.5)

  for depth in [0..Game.DEPTH]
    @MaterialForDepth[depth] = new THREE.MeshLambertMaterial(
      color: @Colors[depth % @Colors.length]
      wireframe: false
    )
    @ActiveMaterialForDepth[depth] = @MaterialForDepth[depth].clone()
    @ActiveMaterialForDepth[depth].transparent = true
    @ActiveMaterialForDepth[depth].opacity = 0.8


  constructor: (@active)->
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

  updateMeshPosition: ->
    DX = -(2 * Graphics.BLOCK_SIZE)
    DY = (2 * Graphics.BLOCK_SIZE)
    DZ = -((Game.DEPTH - 1) * Graphics.BLOCK_SIZE)

    @mesh.position.x = DX + @position.x * Graphics.BLOCK_SIZE
    @mesh.position.y = DY + @position.y * -Graphics.BLOCK_SIZE
    @mesh.position.z = DZ + @position.z * Graphics.BLOCK_SIZE
    if @active
      @mesh.material = Cube.ActiveMaterialForDepth[@position.z]
    else
      @mesh.material = Cube.MaterialForDepth[@position.z]

window.Cube = Cube

class Shape
  size: 3
  constructor: (@position,@field,@active) ->
    @blockShape = []
    for row,i in @originalShape()
      @blockShape[i] = []
      for bit,j in row
        if bit == 1
          @blockShape[i][j] = [0, new Cube(@active),0]
        else
          @blockShape[i][j] = [0,0,0]

    @tryPosition(@position)
    @updateMeshPositions()

  isNew: true
  tryPosition: (position) ->
    unless @isNew
      for block in @blocks()
        p = block.position
        @field[p.x][p.y][p.z] = null
    @isNew = false

    trySpace = =>
      for row,i in @blockShape
        for line,j in row
          for cube,k in line
            if cube != 0
              p = {}
              p.x = position.x + j
              p.y = position.y + i
              p.z = position.z - k

              if p.x == -1 ||
                 p.y == -1 ||
                 p.z == -1 ||
                 p.x == Game.WIDTH  ||
                 p.y == Game.HEIGHT ||
                 p.z == Game.DEPTH
                return false

              if @field[p.x][p.y][p.z]?
                return false
      return true

    if !trySpace()
      for block in @blocks()
        p = block.position
        @field[p.x][p.y][p.z] = block
      return false

    for row,i in @blockShape
      for line,j in row
        for cube,k in line
          if cube != 0
            p = cube.position
            p.x = position.x + j
            p.y = position.y + i
            p.z = position.z - k
            @field[p.x][p.y][p.z] = cube
    @position = position
    true

  updatePosition: ->
    for row,i in @blockShape
      for line,j in row
        for cube,k in line
          if cube != 0
            p = cube.position
            unless @isNew
              @field[p.x]?[p.y]?[p.z] = null
            p.x = @position.x + j
            p.y = @position.y + i
            p.z = @position.z - k
    @isNew = false

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
    @_yaw()
    if !@updatePosition()
      @_yaw() for [0..2]
      @updatePosition()
      return false
    else
      return true

  pitch: ->
    @_yaw()
    @_rollBack() for [0...3]
    if !@updatePosition()
      @_rollBack()
      @_yaw() for [0...3]
      @updatePosition()
      return false
    else
      return true

  roll: ->
    @_rollBack() for [0...3]
    if !@updatePosition()
      @_rollBack()
      @updatePosition()
      return false
    else
      return true

  rollBack: ->
    @_rollBack()
    if !@updatePosition()
      @_rollBack() for [0..2]
      @updatePosition()
      return false
    else
      return true

  _yaw: ->
     rotated = []
     for i in [0...@size]
       rotated[i] = []
       for j in [0...@size]
         rotated[i][j] = @blockShape[@size - j - 1][i]
     @blockShape = rotated

  _rollBack: ->
    rotated = []

    for k in [0...@size]
      face = @blockShape[k]
      for i in [0...@size]
        rotated[i] = [] if not rotated[i]?
        for j in [0...@size]
          rotated[i][j] = [] if not rotated[i][j]?
          rotated[i][j][k] = face[j][@size - i - 1]
    @blockShape = rotated

  updateMeshPositions: () ->
    for block in @blocks()
      block.active = @active
      block.updateMeshPosition()

  _blocks: null
  blocks: ->
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
