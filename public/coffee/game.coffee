class Game
  DEPTH : 12
  WIDTH : 5
  HEIGHT: 5

  @DEPTH : 12
  @WIDTH : 5
  @HEIGHT: 5

  constructor: ->
    @playingField = []
    for i in [0..@DEPTH]
      @playingField[i] = {}

    newObject = new LShape(x: 1, y: 1, z: 11)
    newObject.depth = depth = @DEPTH - 1
    @playingField[depth][newObject] = newObject

  activeObject: null

  nextStep: ->
    depth = @activeObject.depth
    delete @playingField[depth][@activeObject]
    @activeObject.depth = depth = depth - 1
    @playingField[depth][@activeObject] = @activeObject

window.Game = Game
