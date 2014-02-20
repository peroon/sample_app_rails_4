window.MYTHREE = window.MYTHREE || {}

#定数
MYTHREE.const = {}
MYTHREE.const.W = window.innerWidth;
MYTHREE.const.H = MYTHREE.const.W * (800/1280);
MYTHREE.cubeColor = 0xff0000

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
  light = new THREE.DirectionalLight( 0xffffff, 1 ); 
  light

#cube with wireframe
MYTHREE.createCube = (pos, color) ->
  console.log color
  geometry = MYTHREE.getCubeGeometry()
  #material = new THREE.MeshLambertMaterial(vertexColors: THREE.FaceColors)
  material = new THREE.MeshLambertMaterial( { color: color} )
  material_edge = new THREE.MeshBasicMaterial( { color: 0x222222, wireframe: true} )
  #voxel = new THREE.Mesh(geometry, material)
  voxel = new THREE.SceneUtils.createMultiMaterialObject( geometry, [material, material_edge])
  voxel.position.x = pos.x
  voxel.position.y = pos.y
  voxel.position.z = pos.z
  voxel.matrixAutoUpdate = false
  voxel.updateMatrix()
  voxel

#cube
MYTHREE.createTransparentCube = (pos, color) ->
  geometry = MYTHREE.getCubeGeometry()
  material = new THREE.MeshLambertMaterial( { color: color, opacity: 0.5, transparent: true} )
  voxel = new THREE.Mesh(geometry, material)
  voxel.position.x = pos.x
  voxel.position.y = pos.y
  voxel.position.z = pos.z
  voxel.matrixAutoUpdate = true
  voxel.updateMatrix()
  voxel

MYTHREE.getCubeGeometry = ->
  geometry = new THREE.CubeGeometry(1,1,1)
  i = 0
  while i < geometry.faces.length
    geometry.faces[i].color.setHex MYTHREE.cubeColor
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
  oldmouse2D = null
  cubeColor = 0x00ff00
  mouse3D = null
  raycaster = null
  rollOverCube = null
  phi = 170
  theta = 70
  isShiftDown = false
  isCtrlDown = false
  isRightClickDown = false
  origin = new THREE.Vector3( 0, 0, 0 )
  voxelPos = {}
  normalMatrix = new THREE.Matrix3()
  ROLLOVERED = null
  voxelBase = new THREE.Object3D()
  voxelData = {};
  #色選択時
  $(".color-palette").click ->
    colorVal = parseInt($(this).attr("data-colorval"))
    MYTHREE.cubeColor = colorVal
    color0xStr = '#' + colorVal.toString(16)
    $("#selected-color-viewer").css("background-color", color0xStr)
    console.log rollOverCube.material.color.setHex(colorVal)

  if $("#auto_rotate").length!=0 
    auto_rotate = true
  else
    auto_rotate = false

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
    oldmouse2D = new THREE.Vector3( 0, 10000, 0.5 )
    scene.add( new THREE.AmbientLight( 0x808080 ))
    scene.add( MYTHREE.getDirectionalLight() )
    axis = new THREE.AxisHelper(10);
    scene.add(axis);
    scene.add(voxelBase)
    renderer = new MYTHREE.getRenderer()
    if container
      container.appendChild(renderer.domElement); #<canvas>
    $canvas = $('canvas')
    $canvas.attr('id', 'canvas_id')
    document.addEventListener( 'mousemove', onDocumentMouseMove, false )
    #document.addEventListener( 'mousedown', onDocumentMouseDown, true) #マウスクリック
    $canvas.click(onDocumentMouseDown)

    #rollover cube
    rollOverCube = MYTHREE.createTransparentCube(new THREE.Vector3(0,0,0), MYTHREE.cubeColor)
    rollOverCube.is_rollover = true
    scene.add(rollOverCube)

    #disable right click
    $canvas.bind "contextmenu", (e) ->
      false
    $canvas.mousedown (e) ->
      if e.button is 2
        isRightClickDown = true
      true
    $canvas.mouseup (e) ->
      if e.button is 2
        isRightClickDown = false
      true

    document.addEventListener( 'keydown', onDocumentKeyDown, false )
    document.addEventListener( 'keyup', onDocumentKeyUp, false )
    if($("#method").text()=="show")
      initShow()

  initShow = ->
    voxelData = JSON.parse($("#voxeljson_text").text())
    redrawVoxelAll()

  #フォームにデータコピー
  writeToForm = ->
    $('#voxel_user_id').val(1)
    $('#voxel_title').val('ここに作品名を入れてほしいな ^^/')
    $('#voxel_voxeljson').text( JSON.stringify(voxelData) )

  resetVoxelAll = ->
    scene.remove(voxelBase)
    voxelBase = new THREE.Object3D()
    scene.add voxelBase

  redrawVoxelAll = ->
    for key of voxelData
      color = voxelData[key]
      pos = JSON.parse(key)
      voxel = MYTHREE.createCube(pos, color)
      voxelBase.add voxel

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
    #if intersects.length > 0
    #  ROLLOVERED = getColoredIntersect(intersects)
    #  ROLLOVERED.color.setHex( 0xff8000 )
    #右クリック&ドラッグで回転
    if isRightClickDown
      diffX = (oldmouse2D.x - mouse2D.x) * 200 * -1
      phi += diffX
      diffY = (oldmouse2D.y - mouse2D.y) * 200 * -1
      theta += diffY
    oldmouse2D.x = mouse2D.x
    oldmouse2D.y = mouse2D.y
    #キューブ配置位置
    intersects = raycaster.intersectObjects(scene.children)
    intersects = faceIntersectOnly(intersects)

    if intersects.length > 0
      intersect = getRealIntersect(intersects)
      #交差点から描画位置決定
      if intersect.object
        normalMatrix.getNormalMatrix intersect.object.matrixWorld
        normal = intersect.face.normal.clone()
        normal.applyMatrix3(normalMatrix).normalize()
        #position = new THREE.Vector3().addVectors(intersect.point, normal)
        position = intersect.point.clone()
        voxelPos = {}
        voxelPos.x = Math.floor(position.x) + 0.5
        voxelPos.y = Math.floor(position.y) + 0.5
        voxelPos.z = Math.floor(position.z) + 0.5

  faceIntersectOnly = (intersects) ->
    _arr = []
    for key,intersect of intersects
      if intersect.object instanceof THREE.Mesh
        _arr.push(intersect)
    _arr

  onDocumentMouseDown = (event) ->
    event.preventDefault()
    intersects = raycaster.intersectObjects(scene.children)
    if intersects.length > 0
      #レイとの交差点
      intersect = getRealIntersect(intersects)
      if isCtrlDown
        #remove voxel from scene
        scene.remove intersect.object unless intersect.object is plane
      else
        #save 
        pos = JSON.stringify(voxelPos)
        voxelData[pos] = MYTHREE.cubeColor
        #draw to scene
        voxel = MYTHREE.createCube(voxelPos, MYTHREE.cubeColor)
        scene.add voxel
        writeToForm()

  #複数の交差点からfaceがセットされているものを返す
  getRealIntersect = (intersects) ->
    console.log intersects
    for intersect in intersects
      if intersect.face? && !intersect.is_rollover
        return intersect

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

  #rolloverキューブではなく、faceを持っているもの
  getRealIntersector = (intersects) ->
    for key,intersector of intersects
      if intersector.face and intersector.object != rollOverCube
        return intersector
    null

  render = ->
    phi += mouse2D.x * 3  if isShiftDown
    if auto_rotate
      phi += 1
    R = 40
    camera.position.x = R * Math.sin(theta * Math.PI / 360) * Math.cos(phi* Math.PI / 360)
    camera.position.z = R * Math.sin(theta * Math.PI / 360) * Math.sin(phi * Math.PI / 360)
    camera.position.y = R * Math.cos(theta * Math.PI / 360)
    camera.lookAt origin
    raycaster = projector.pickingRay(mouse2D.clone(), camera) #ray from 2D to 3D
    #rollover pos
    intersects = raycaster.intersectObjects(scene.children)
    if intersects.length > 0
      intersector = getRealIntersector(intersects)
      if intersector
        rollOverCube.position.x = voxelPos.x
        rollOverCube.position.y = voxelPos.y
        rollOverCube.position.z = voxelPos.z
    #final render
    renderer.render scene, camera


  #main
  init()
  animate()
