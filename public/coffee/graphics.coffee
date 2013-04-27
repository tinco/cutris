class Graphics
  WIDTH = 800
  HEIGHT = 600
  VIEW_ANGLE = 45
  ASPECT = WIDTH / HEIGHT
  NEAR = 0.1
  FAR = 10000

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

    @drawLshape()
    @addLight()
    @drawPlayingField()
    @render()

  render: ->
    @renderer.render(@scene,@camera)

  drawCube: (size, position)->
    width = height = depth = size
    widthSegments = depthSegments = heightSegments = 1

    cubeMaterial =
      new THREE.MeshLambertMaterial(color: 0x0033FF)

    cubeMaterial.opacity = 0.8

    cube = new THREE.Mesh(
      new THREE.CubeGeometry(width,width,width,1,1,1),
      cubeMaterial
    )

    cube.position = position

    @scene.add(cube)

  drawLshape: ->
    @drawCube(50, x: 0, y: 0, z:0)
    @drawCube(50, x: 50, y: 0, z:0)
    @drawCube(50, x: -50, y: 0, z:0)
    @drawCube(50, x: -50, y: -50, z:0)

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
