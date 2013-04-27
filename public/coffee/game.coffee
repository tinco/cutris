class Game
  DEPTH : 12
  WIDTH : 5
  HEIGHT: 5

  constructor: ->
    @playingField = []
    for i in [0..@DEPTH]
      @playingField[i] = {}
      @playingField[i].blocks = []
      for j in [0..@HEIGHT]
        @playingField[i].blocks[j] = []
      @playingField[i].objects = {}

window.Game = Game
