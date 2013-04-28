class Game
  DEPTH : 12
  WIDTH : 5
  HEIGHT: 5

  @DEPTH : 12
  @WIDTH : 5
  @HEIGHT: 5

  lastObjectId: 0

  constructor: ->
    @playingField = []
    @blocks = []
    for x in [0...@WIDTH]
      @blocks[x] = []
      for y in [0...@HEIGHT]
        @blocks[x][y] = []
 
  activeObject: null

  nextStep: ->
    if not @activeObject?
      newObject = new LShape({x: 1, y: 1, z: 12}, @blocks)
      newObject.id = @lastObjectId
      @lastObjectId += 1
      @activeObject = newObject
      @playingField[newObject.id] = newObject
    else
      @activeObject.position.z -= 1
      if not @activeObject.updatePosition()
        @activeObject.position.z += 1
        @activeObject.updatePosition()
        @activeObject = null
      else
        @activeObject.updateMeshPositions()

  score: 0
  resolveScore: () ->
    isScore = (depth) =>
      result = ""
      for x in [0...@WIDTH]
        for y in [0...@HEIGHT]
          result += if @blocks[x][y][depth]? then 1 else 0
          #if not @blocks[x][y][depth]?
            #return false
        result += "\n"
      console.log result
      return false
      return true

    decreaseDepth = (depth) =>
      for x in [0...@WIDTH]
        for y in [0...@HEIGHT]
          cube = @blocks[x][y][depth]
          @graphics.scene.remove(cube.mesh)
          @blocks[x][y][depth] = null

          for z in [(depth + 1)...@DEPTH]
            if cube = @blocks[x][y][z]
              cube.position.z -= 1
              @blocks[x][y][z] = null
              @blocks[x][y][z-1] = cube

    #
    #for depth in [0...@DEPTH]
    depth = 0
    if isScore(depth)
      console.log 'is SCORE!'
      @score += @WIDTH * @HEIGHT * 2
      decreaseDepth(depth)

  place: ->
    while @activeObject?
      @nextStep()
    @resolveScore()

  start: ->
    @nextStep()
    @resolveScore()
    @graphics.nextStep()
    setTimeout((=> @start()),1000)

  move: (direction) ->
    return if not @activeObject?
    switch direction
      when 'up'
        key = 'y'; value = -1
      when 'down'
        key = 'y'; value = 1
      when 'left'
        key = 'x'; value =  -1
      when 'right'
        key = 'x'; value = 1
    @activeObject.position[key] += value
    if !@activeObject.updatePosition()
      @activeObject.position[key] -= value
      @activeObject.updatePosition()
    @activeObject.updateMeshPositions()

  rotate: (direction) ->
    return if not @activeObject?
    if @activeObject.rotate(direction)
      @activeObject.updateMeshPositions()

window.Game = Game
