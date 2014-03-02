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

#キューブ作成
MYTHREE.createCube = (pos, color) ->
  console.log 'col'
  console.log color
  texture_path = "../assets/cube_texture.png"
  param = 
    wireframe: false
    color: color
    #ambient: color
    shading: THREE.FlatShading
    #map: THREE.ImageUtils.loadTexture( texture_path )
  #material = new THREE.MeshLambertMaterial( param )
  material = new THREE.MeshPhongMaterial( param )
  #material.ambient = material.color
  #material.ambient = 0xff0000
  #material.color = 0xff0000
  geometry = new THREE.CubeGeometry(1, 1, 1)
  voxel = new THREE.Mesh(geometry, material)
  #ワイヤフレーム表示
  #geometry = MYTHREE.getCubeGeometry()
  #material = new THREE.MeshLambertMaterial( { color: color} )
  #material_edge = new THREE.MeshBasicMaterial( { color: 0x222222, wireframe: true} )
  #voxel = new THREE.SceneUtils.createMultiMaterialObject( geometry, [material, material_edge])

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