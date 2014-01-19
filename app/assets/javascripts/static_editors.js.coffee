window.MYTHREE = window.MYTHREE || {}

#定数
MYTHREE.const = {}
MYTHREE.const.W = window.innerWidth;
MYTHREE.const.H = MYTHREE.const.W * (800/1280);

#---ヘルパー---

#グリッド線
MYTHREE.getGrid = ->
  size = 10
  step = 1
  geometry = new THREE.Geometry
  for i in [-size..size] by step
    geometry.vertices.push( new THREE.Vector3( - size, 0, i ) )
    geometry.vertices.push( new THREE.Vector3(   size, 0, i ) )
    geometry.vertices.push( new THREE.Vector3( i, 0, - size ) )
    geometry.vertices.push( new THREE.Vector3( i, 0,   size ) )
  material = new THREE.LineBasicMaterial( { color: 0x000000, opacity: 0.2 } )
  line = new THREE.Line( geometry, material )
  line.type = THREE.LinePieces
  line

#ヒット用平面
MYTHREE.getRayHitPlane = ->
  plane = new THREE.Mesh( new THREE.PlaneGeometry( 20, 20 ), new THREE.MeshBasicMaterial() );
  plane.rotation.x = - Math.PI / 2;
  plane.visible = false;
  plane

#レンダラー
MYTHREE.getRenderer = ->
  renderer = new THREE.CanvasRenderer;
  renderer.setSize(MYTHREE.const.W, MYTHREE.const.H)
  renderer

#平行光源
MYTHREE.getDirectionalLight = ->
  light = new THREE.DirectionalLight( 0xffffff, 3 ); 
  light

#cube
MYTHREE.createCube = (pos, color) ->
  geometry = MYTHREE.getCubeGeometry()
  material = new THREE.MeshLambertMaterial(vertexColors: THREE.FaceColors)
  voxel = new THREE.Mesh(geometry, material)
  voxel.position.x = pos.x
  voxel.position.y = pos.y
  voxel.position.z = pos.z
  voxel.matrixAutoUpdate = false
  voxel.updateMatrix()
  voxel

MYTHREE.getCubeGeometry = ->
  geometry = new THREE.CubeGeometry(1,1,1)
  i = 0
  while i < geometry.faces.length
    geometry.faces[i].color.setHex 0x00ff80
    i++
  geometry


#---組み立て---
$ ->
  container = null
  camera = null
  scene = null
  renderer = null
  projector = null
  plane = null
  mouse2D = null
  mouse3D = null
  raycaster = null
  theta = 45
  isShiftDown = false
  isCtrlDown = false
  origin = new THREE.Vector3( 0, 0, 0 )
  normalMatrix = new THREE.Matrix3()
  ROLLOVERED = null
  voxelBase = new THREE.Object3D()
  voxelData = {};
  
  init = -> 
    container = document.getElementById('container')
    $container = $(container)
    camera = new THREE.PerspectiveCamera( 40, MYTHREE.const.W/MYTHREE.const.H, 1, 10000 )
    camera.position.y = 30
    scene = new THREE.Scene
    scene.add( MYTHREE.getGrid() )
    projector = new THREE.Projector()
    scene.add( MYTHREE.getRayHitPlane() )
    mouse2D = new THREE.Vector3( 0, 10000, 0.5 )
    scene.add( new THREE.AmbientLight( 0x606060 ))
    scene.add( MYTHREE.getDirectionalLight() )
    axis = new THREE.AxisHelper(10);
    scene.add(axis);
    scene.add(voxelBase)
    renderer = new MYTHREE.getRenderer()
    container.appendChild(renderer.domElement); #<canvas>
    $('canvas').attr('id', 'canvas_id')
    document.addEventListener( 'mousemove', onDocumentMouseMove, false )
    document.addEventListener( 'mousedown', onDocumentMouseDown, false )
    document.addEventListener( 'keydown', onDocumentKeyDown, false )
    document.addEventListener( 'keyup', onDocumentKeyUp, false )

  onDocumentMouseMove = ( event ) ->
    event.preventDefault()
    #マウス位置補正
    offsetY = $("#header").height() + $("header").height() 
    #ブラウザの左上からのピクセル位置 = event.clientX,Y
    canvasX = event.clientX
    canvasY = event.clientY - offsetY
    mouse2D.x = ( canvasX / MYTHREE.const.W ) * 2 - 1 #-1~+1
    mouse2D.y = - ( canvasY / MYTHREE.const.H ) * 2 + 1 #-1~+1
    intersects = raycaster.intersectObjects( scene.children )
    #ray hit color
    # if intersects.length > 0
    #   ROLLOVERED = getColoredIntersect(intersects)
    #   ROLLOVERED.color.setHex( 0xff8000 )
  
  #複数の交差点からfaceがセットされているものを返す
  getFacedIntersect = (intersects) ->
    for intersect in intersects
      if intersect.face?
        return intersect

  #フォームにデータコピー
  writeToForm = ->
    console.log("writeToForm")
    $('#voxel_user_id').val(1)
    $('#voxel_title').val('dummy title')
    $('#voxel_voxeljson').text('dummy json')

  resetVoxelAll = ->
    scene.remove(voxelBase)
    voxelBase = new THREE.Object3D()
    scene.add voxelBase

  redrawVoxelAll = ->
    for key of voxelData
      color = voxelData[key]
      pos = JSON.parse(key)
      #voxel
      voxel = MYTHREE.createCube(pos, color)
      voxelBase.add voxel

  onDocumentMouseDown = (event) ->
    event.preventDefault()
    intersects = raycaster.intersectObjects(scene.children)
    if intersects.length > 0
      #レイとの交差点
      intersect = getFacedIntersect(intersects)
      if isCtrlDown
        #remove voxel from scene
        scene.remove intersect.object unless intersect.object is plane
      else
        #交差点から描画位置決定
        normalMatrix.getNormalMatrix intersect.object.matrixWorld
        normal = intersect.face.normal.clone()
        normal.applyMatrix3(normalMatrix).normalize()
        position = new THREE.Vector3().addVectors(intersect.point, normal)
        voxelPos = {}
        voxelPos.x = Math.floor(position.x) + 0.5
        voxelPos.y = Math.floor(position.y) + 0.5
        voxelPos.z = Math.floor(position.z) + 0.5
        #save 
        pos = JSON.stringify(voxelPos)
        color = THREE.FaceColors
        voxelData[pos] = color
        #resetVoxelAll()
        #redrawVoxelAll()
        #draw to scene
        voxel = MYTHREE.createCube(voxelPos, '')
        scene.add voxel
        writeToForm()

  onDocumentKeyDown = (event) ->
    switch event.keyCode
      when 16
        isShiftDown = true
      when 17
        isCtrlDown = true

  onDocumentKeyUp = (event) ->
    switch event.keyCode
      when 16
        isShiftDown = false
      when 17
        isCtrlDown = false

  save = ->
    window.open renderer.domElement.toDataURL("image/png"), "mywindow"
    false

  animate = ->
    requestAnimationFrame animate
    render()

  render = ->
    theta += mouse2D.x * 3  if isShiftDown
    camera.position.x = 28 * Math.sin(theta * Math.PI / 360)
    camera.position.z = 28 * Math.cos(theta * Math.PI / 360)
    camera.lookAt origin
    raycaster = projector.pickingRay(mouse2D.clone(), camera) #ray from 2D to 3D
    renderer.render scene, camera

  #main
  init()
  animate()
