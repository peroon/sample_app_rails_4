window.MYTHREE = window.MYTHREE || {}

MYTHREE.W = window.innerWidth;
MYTHREE.H = window.innerHeight;

#グリッド線
MYTHREE.getGrid = ->
  size = 500
  step = 50
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
  plane = new THREE.Mesh( new THREE.PlaneGeometry( 1000, 1000 ), new THREE.MeshBasicMaterial() );
  plane.rotation.x = - Math.PI / 2;
  plane.visible = false;
  plane

#レンダラー
MYTHREE.getRenderer = ->
  renderer = new THREE.CanvasRenderer;
  canvas = {};
  canvas.W = MYTHREE.W;

  #canvas.H = MYTHREE.H;
  canvas.H = MYTHREE.W * (800/1280);

  renderer.setSize(canvas.W, canvas.H);
  renderer

#平行光源
MYTHREE.getDirectionalLight = ->
  renderer = new THREE.CanvasRenderer
  canvas = {};
  canvas.W = 600;
  canvas.H = 400;
  renderer.setSize(canvas.W, canvas.H)
  renderer

MYTHREE.global = {}