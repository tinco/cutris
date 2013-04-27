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
    for x in [0..@WIDTH]
      @blocks[x] = []
      for y in [0..@HEIGHT]
        @blocks[x][y] = []
 
  activeObject: null

  nextStep: ->
    if not @activeObject?
      newObject = new LShape({x: 1, y: 1, z: 12}, @blocks)
      newObject.depth = depth = @DEPTH - 1
      newObject.id = @lastObjectId
      @lastObjectId += 1
      @activeObject = newObject
      @playingField[newObject.id] = newObject
    else
      depth = @activeObject.depth
      @activeObject.position.z -= 1
      
      if not @activeObject.updatePosition()
        console.log "cant go down"
        @activeObject.position.z += 1
        @activeObject.updatePosition()
        @activeObject = null
      else
        @activeObject.depth = depth - 1
        @activeObject.updateMeshPositions()

  start: ->
    @nextStep()
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


  activeObjectIsLegal: ->

window.Game = Game
