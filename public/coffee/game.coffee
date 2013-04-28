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
 
  activeObject: undefined

  playSound: (name) ->
    new Audio('sound/' + name + '.ogg').play()

  nextStep: (placing) ->
    if not @activeObject?
      shapeClass = Shapes[Math.floor(Math.random() * Shapes.length)]
      newObject = new shapeClass({x: 1, y: 1, z: 12}, @blocks,true)
      newObject.id = @lastObjectId
      @lastObjectId += 1
      @activeObject = newObject
      @playingField[newObject.id] = newObject
      @playSound('beep')
    else
      p = @activeObject.position
      if not @activeObject.tryPosition({x: p.x, y: p.y, z: p.z-1})
        @activeObject.active = false
        @activeObject.updateMeshPositions()
        @score += @activeObject.blocks().length
        @activeObject = undefined
        @playSound('thump')
        if p.z == Game.DEPTH - 1
          @gameOver = true
      else
        @playSound('beep') unless placing
        @activeObject.updateMeshPositions()

  score: 0
  resolveScore: () ->
    isScore = (depth) =>
      for x in [0...@WIDTH]
        for y in [0...@HEIGHT]
          if not @blocks[x][y][depth]?
            return false
      return true

    decreaseDepth = (depth) =>
      for x in [0...@WIDTH]
        for y in [0...@HEIGHT]
          cube = @blocks[x][y][depth]
          @graphics.scene.remove(cube.mesh)
          @blocks[x][y][depth] = undefined

          for z in [(depth+1)...@DEPTH]
            cube = @blocks[x][y][z]
            if cube?
              cube.position.z -= 1
              cube.updateMeshPosition()
              @blocks[x][y][z] = undefined
              @blocks[x][y][z-1] = cube

    for depth in [0...@DEPTH]
      if isScore(depth)
        @playSound('bump')
        @score += @WIDTH * @HEIGHT * 2
        decreaseDepth(depth)

  place: ->
    return if @gameOver
    while @activeObject?
      @nextStep(true)
    @resolveScore()
    @updateScoreBoard()

  start: ->
    @nextStep()
    @resolveScore()
    @updateScoreBoard()
    @graphics.nextStep()


    delay = 900
    if @score > 100
      delay *= 0.8
    if @score > 200
      delay *= 0.8
    if @score > 400
      delay *= 0.8
    if @score > 600
      delay *= 0.8
    if @score > 800
      delay *= 0.8

    setTimeout((=> @start()),delay) unless @gameOver

  updateScoreBoard: () ->
    document.getElementById('score').innerHTML = @score

  move: (direction) ->
    return if @gameOver
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
    p = @activeObject.position
    position = {x: p.x, y: p.y, z: p.z}
    position[key] += value
    if @activeObject.tryPosition(position)
      @activeObject.updateMeshPositions()

  rotate: (direction) ->
    return if @gameOver
    return if not @activeObject?
    if @activeObject.rotate(direction)
      @activeObject.updateMeshPositions()

window.Game = Game
