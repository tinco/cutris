class Graphics
  WIDTH = window.innerWidth
  HEIGHT = window.innerHeight
  VIEW_ANGLE = 45
  ASPECT = WIDTH / HEIGHT
  NEAR = 0.1
  FAR = 10000

  @BLOCK_SIZE = 50

  constructor: (game)->
    @game = game
    @renderer = new THREE.WebGLRenderer()
    @camera =
      new THREE.PerspectiveCamera(
        VIEW_ANGLE,
        ASPECT,
        NEAR,
        FAR
      )

    @scene = new THREE.Scene()
    @scene.add(@camera)
    @camera.position.z = 300
    @renderer.setSize(WIDTH,HEIGHT)

    container = document.getElementById('cutris')
    container.appendChild(@renderer.domElement)

    @objects = {}

    @addLight()
    @drawPlayingField()
    @render()

  watchWindow: ->
    resized = =>
      @renderer.setSize(window.innerWidth, window.innerHeight)
      @camera.aspect = window.innerWidth / window.innerHeight
      @camera.updateProjectionMatrix()
    window.addEventListener('resize', resized, false)

  animate: () ->
    @render()
    requestAnimationFrame => @animate()

  render: ->
    @renderer.render(@scene,@camera)

  nextStep: ->
    # I want.. that every next step, we check wether
    # there are any new objects, and we add them to the scene
    # then we check if there are any objects no longer in the game
    # and we remove them from the scene.
    # So first we store our previous objects
    previous = @objects

    # Then we build our current objects
    @objects = {}
    for object in @game.playingField
      @objects[object.id] = object

    # Then we check if any of them are new
    for k,object of @objects
      if not previous[object.id]?
        object.addToScene(@scene)
    # Then we iterate over the old ones, to see if they're still there
    for k,object of previous
      if not @objects[object.id]?
        object.removeFromScene(@scene)
    # Done for now

  addLight: ->
    pointLight = new THREE.PointLight(0xFFFFFF)
    pointLight.position.x = 10
    pointLight.position.y = 50
    pointLight.position.z = 130

    @scene.add(pointLight)

  drawPlayingField: ->
    playingFieldMaterial =
      new THREE.MeshBasicMaterial(
        color: 0x229999
        linewidth: 2
        wireframe: true
      )
    widthSegments = @game.WIDTH
    width = 55 * widthSegments
    heightSegments = @game.HEIGHT
    height = 55 * heightSegments
    depthSegments = @game.DEPTH
    depth = 55 * depthSegments

    geometry = new THREE.PlayingFieldGeometry(
      width,height,depth,widthSegments,heightSegments,depthSegments)
    playingField = new THREE.Mesh(geometry, playingFieldMaterial)
    playingField.position.z = -(depth / 2)

    @scene.add(playingField)

window.Graphics = Graphics
