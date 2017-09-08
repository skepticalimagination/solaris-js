###
# Adapted from https://github.com/mrdoob/three.js/blob/master/examples/js/controls/OrbitControls.js
#
# This set of controls performs orbiting, dollying (zooming), and panning.
# Unlike TrackballControls, it maintains the "up" direction object.up (+Y by default).
#
#    Orbit - left mouse / touch: one finger move
#    Zoom - middle mouse, or mousewheel / touch: two finger spread or squish
#    Pan - right mouse, or arrow keys / touch: three finger swipe
###

import * as THREE from 'three'

Controls = (object, domElement, options) ->
  ##################
  # public variables
  ##################

  @object = object

  @domElement = domElement ? document

  @enabled = true # Set to false to disable this control

  # "target" sets the location of focus, where the object orbits around
  @target = new THREE.Vector3

  # How far you can dolly in and out (PerspectiveCamera only)
  @minDistance = options?.minDistance ? 0
  @maxDistance = options?.maxDistance ? Infinity

  # How far you can zoom in and out (OrthographicCamera only)
  @minZoom = 0
  @maxZoom = Infinity

  # How far you can orbit vertically, upper and lower limits.
  # Range is 0 to Math.PI radians.
  @minPolarAngle = 0 # radians
  @maxPolarAngle = Math.PI # radians
  
  # How far you can orbit horizontally, upper and lower limits.
  # If set, must be a sub-interval of the interval [ - Math.PI, Math.PI ].
  @minAzimuthAngle = -Infinity # radians
  @maxAzimuthAngle = Infinity # radians

  # Set to true to enable damping (inertia)
  # If damping is enabled, you must call controls.update() in your animation loop
  @enableDamping = false
  @dampingFactor = 0.25

  # This option actually enables dollying in and out; left as "zoom" for backwards compatibility.
  @enableZoom = true # Set to false to disable zooming
  @zoomSpeed = 1.0

  @enableRotate = true # Set to false to disable rotating
  @rotateSpeed = 1.0
  
  @enablePan = true # Set to false to disable panning
  @keyPanSpeed = 7.0 # pixels moved per arrow key push
  
  @enableKeys = true # Set to false to disable use of the keys
  
  @keys = {LEFT: 37, UP: 38, RIGHT: 39, BOTTOM: 40}
  @mouseButtons = {ORBIT: THREE.MOUSE.LEFT, ZOOM: THREE.MOUSE.MIDDLE, PAN: THREE.MOUSE.RIGHT}
  
  # for reset
  @target0 = @target.clone()
  @position0 = @object.position.clone()
  @zoom0 = @object.zoom

  ###################
  # private variables
  ###################

  changeEvent = {type: 'change'}
  startEvent = {type: 'start'}
  endEvent = {type: 'end'}
  
  STATE =
    NONE: -1, ROTATE: 0, DOLLY: 1, PAN: 2
    TOUCH_ROTATE: 3, TOUCH_DOLLY: 4, TOUCH_PAN: 5
  
  state = STATE.NONE
  
  EPS = 0.000001
  
  # current position in spherical coordinates
  spherical = new THREE.Spherical
  sphericalDelta = new THREE.Spherical
  
  scale = 1
  panOffset = new THREE.Vector3
  zoomChanged = false
  
  rotateStart = new THREE.Vector2
  rotateEnd = new THREE.Vector2
  rotateDelta = new THREE.Vector2
  
  panStart = new THREE.Vector2
  panEnd = new THREE.Vector2
  panDelta = new THREE.Vector2
  
  dollyStart = new THREE.Vector2
  dollyEnd = new THREE.Vector2
  dollyDelta = new THREE.Vector2

  updateState =
    offset: new THREE.Vector3
    lastPosition: new THREE.Vector3
    lastQuaternion: new THREE.Quaternion
    quat: new THREE.Quaternion().setFromUnitVectors object.up, new THREE.Vector3(0, 1, 0)

  updateState.quatInverse = updateState.quat.clone().inverse()

  panState =
    left: new THREE.Vector3
    up: new THREE.Vector3
    offset: new THREE.Vector3

  ####################
  # public methods
  ####################

  @getPolarAngle = -> spherical.phi
  @getAzimuthalAngle = -> spherical.theta

  @saveState = =>
    @target0.copy @target
    @position0.copy @object.position
    @zoom0 = @object.zoom

  @reset = =>
    @target.copy @target0
    @object.position.copy @position0
    @object.zoom = @zoom0
    @object.updateProjectionMatrix()
    @dispatchEvent changeEvent
    @update()
    state = STATE.NONE

  # this method is exposed, but perhaps it would be better if we can make it private...
  @update = =>
    {offset, quat, quatInverse, lastPosition, lastQuaternion} = updateState
    
    position = @object.position
    
    offset.copy(position).sub @target
    
    # rotate offset to "y-axis-is-up" space
    offset.applyQuaternion quat
    
    # angle from z-axis around y-axis
    spherical.setFromVector3 offset
    
    spherical.theta += sphericalDelta.theta
    spherical.phi += sphericalDelta.phi
    
    # restrict theta to be between desired limits
    spherical.theta = Math.max(@minAzimuthAngle, Math.min(@maxAzimuthAngle, spherical.theta))
    
    # restrict phi to be between desired limits
    spherical.phi = Math.max(@minPolarAngle, Math.min(@maxPolarAngle, spherical.phi))
    
    spherical.makeSafe()
    
    spherical.radius *= scale
    
    # restrict radius to be between desired limits
    spherical.radius = Math.max(@minDistance, Math.min(@maxDistance, spherical.radius))
    
    # move target to panned location
    @target.add panOffset
    
    offset.setFromSpherical spherical
    
    # rotate offset back to "camera-up-vector-is-up" space
    offset.applyQuaternion quatInverse
    
    position.copy(@target).add offset
    
    @object.lookAt @target
    
    if @enableDamping
      sphericalDelta.theta *= 1 - @dampingFactor
      sphericalDelta.phi *= 1 - @dampingFactor
    else
      sphericalDelta.set 0, 0, 0
    
    scale = 1
    panOffset.set 0, 0, 0
    
    # update condition is:
    # min(camera displacement, camera rotation in radians)^2 > EPS
    # using small-angle approximation cos(x/2) = 1 - x^2 / 8
    if zoomChanged or
    lastPosition.distanceToSquared(@object.position) > EPS or
    8 * (1 - lastQuaternion.dot(@object.quaternion)) > EPS
      @dispatchEvent changeEvent
    
      lastPosition.copy @object.position
      lastQuaternion.copy @object.quaternion
      zoomChanged = false
    
      return true
    
    false

  @dispose = =>
    @domElement.removeEventListener 'contextmenu', onContextMenu, false
    @domElement.removeEventListener 'mousedown', onMouseDown, false
    @domElement.removeEventListener 'wheel', onMouseWheel, false
    @domElement.removeEventListener 'touchstart', onTouchStart, false
    @domElement.removeEventListener 'touchend', onTouchEnd, false
    @domElement.removeEventListener 'touchmove', onTouchMove, false
    document.removeEventListener 'mousemove', onMouseMove, false
    document.removeEventListener 'mouseup', onMouseUp, false
    window.removeEventListener 'keydown', onKeyDown, false

  #################
  # private methods
  #################

  getZoomScale = => 0.95 ** @zoomSpeed

  rotateLeft = (angle) -> sphericalDelta.theta -= angle
  rotateUp = (angle) -> sphericalDelta.phi -= angle

  panLeft = (distance, objectMatrix) ->
    v = panState.left
    v.setFromMatrixColumn objectMatrix, 0 # get X column of objectMatrix
    v.multiplyScalar -distance
    panOffset.add v

  panUp = (distance, objectMatrix) ->
    v = panState.up
    v.setFromMatrixColumn objectMatrix, 1 # get Y column of objectMatrix
    v.multiplyScalar distance
    panOffset.add v

  # deltaX and deltaY are in pixels; right and down are positive
  pan = (deltaX, deltaY) =>
    offset = panState.offset
    element = if @domElement is document then @domElement.body else @domElement
    
    if @object instanceof THREE.PerspectiveCamera
      position = @object.position
      offset.copy(position).sub @target
      targetDistance = offset.length()
      
      # half of the fov is center to top of screen
      targetDistance *= Math.tan(@object.fov / 2 * Math.PI / 180.0)
      
      # we actually don't use screenWidth, since perspective camera is fixed to screen height
      panLeft(2 * deltaX * targetDistance / element.clientHeight, @object.matrix)
      panUp(2 * deltaY * targetDistance / element.clientHeight, @object.matrix)

    else if @object instanceof THREE.OrthographicCamera
      panLeft(deltaX * (@object.right - @object.left) / @object.zoom / element.clientWidth, @object.matrix)
      panUp(deltaY * (@object.top - @object.bottom) / @object.zoom / element.clientHeight, @object.matrix)

  dollyIn = (dollyScale) =>
    if @object instanceof THREE.PerspectiveCamera then scale /= dollyScale
    else if @object instanceof THREE.OrthographicCamera
      @object.zoom = Math.max(@minZoom, Math.min(@maxZoom, @object.zoom * dollyScale))
      @object.updateProjectionMatrix()
      zoomChanged = true

  dollyOut = (dollyScale) =>
    if @object instanceof THREE.PerspectiveCamera then scale *= dollyScale
    else if @object instanceof THREE.OrthographicCamera
      @object.zoom = Math.max(@minZoom, Math.min(@maxZoom, @object.zoom / dollyScale))
      @object.updateProjectionMatrix()
      zoomChanged = true

  # event callbacks - update the object state

  handleMouseDownRotate = (event) -> rotateStart.set event.clientX, event.clientY
  handleMouseDownDolly = (event) -> dollyStart.set event.clientX, event.clientY
  handleMouseDownPan = (event) -> panStart.set event.clientX, event.clientY

  handleMouseMoveRotate = (event) =>
    rotateEnd.set event.clientX, event.clientY
    rotateDelta.subVectors rotateEnd, rotateStart

    element = if @domElement is document then @domElement.body else @domElement
    
    # rotating across whole screen goes 360 degrees around
    rotateLeft 2 * Math.PI * rotateDelta.x / element.clientWidth * @rotateSpeed
    
    # rotating up and down along whole screen attempts to go 360, but limited to 180
    rotateUp 2 * Math.PI * rotateDelta.y / element.clientHeight * @rotateSpeed
    
    rotateStart.copy rotateEnd
    
    @update()

  handleMouseMoveDolly = (event) =>
    dollyEnd.set event.clientX, event.clientY
    dollyDelta.subVectors dollyEnd, dollyStart
    
    if dollyDelta.y > 0 then dollyIn getZoomScale()
    else if dollyDelta.y < 0 then dollyOut getZoomScale()
    
    dollyStart.copy(dollyEnd)

    @update()

  handleMouseMovePan = (event) =>
    panEnd.set event.clientX, event.clientY
    panDelta.subVectors panEnd, panStart
    pan panDelta.x, panDelta.y
    panStart.copy panEnd

    @update()

  handleMouseWheel = (event) =>
    if event.deltaY < 0 then dollyOut getZoomScale()
    else if event.deltaY > 0 then dollyIn getZoomScale()

    @update()

  handleKeyDown = (event) =>
    {UP, BOTTOM, LEFT, RIGHT} = @keys

    switch event.keyCode
      when UP then pan 0, @keyPanSpeed
      when BOTTOM then pan 0, -@keyPanSpeed
      when LEFT then pan @keyPanSpeed, 0
      when RIGHT then pan -@keyPanSpeed, 0

    @update() if event.keyCode in [UP, BOTTOM, LEFT, RIGHT]

  handleTouchStartRotate = (event) ->
    rotateStart.set event.touches[0].pageX, event.touches[0].pageY

  handleTouchStartDolly = (event) ->
    dx = event.touches[0].pageX - (event.touches[1].pageX)
    dy = event.touches[0].pageY - (event.touches[1].pageY)
    
    distance = Math.sqrt(dx * dx + dy * dy)
    
    dollyStart.set 0, distance

  handleTouchStartPan = (event) ->
    panStart.set event.touches[0].pageX, event.touches[0].pageY

  handleTouchMoveRotate = (event) =>
    rotateEnd.set event.touches[0].pageX, event.touches[0].pageY
    rotateDelta.subVectors rotateEnd, rotateStart
    
    element = if @domElement is document then @domElement.body else @domElement
    
    # rotating across whole screen goes 360 degrees around
    rotateLeft 2 * Math.PI * rotateDelta.x / element.clientWidth * @rotateSpeed
    
    # rotating up and down along whole screen attempts to go 360, but limited to 180
    rotateUp 2 * Math.PI * rotateDelta.y / element.clientHeight * @rotateSpeed
    
    rotateStart.copy rotateEnd

    @update()

  handleTouchMoveDolly = (event) =>
    dx = event.touches[0].pageX - (event.touches[1].pageX)
    dy = event.touches[0].pageY - (event.touches[1].pageY)
    
    distance = Math.sqrt(dx * dx + dy * dy)
    
    dollyEnd.set 0, distance
    
    dollyDelta.subVectors dollyEnd, dollyStart
    
    if dollyDelta.y > 0 then dollyOut getZoomScale()
    else if dollyDelta.y < 0 then dollyIn getZoomScale()
    
    dollyStart.copy dollyEnd
    
    @update()

  handleTouchMovePan = (event) =>
    panEnd.set event.touches[0].pageX, event.touches[0].pageY
    panDelta.subVectors panEnd, panStart
    pan panDelta.x, panDelta.y
    panStart.copy panEnd

    @update()

  # event handlers - FSM: listen for events and reset state

  onMouseDown = (event) =>
    return unless @enabled

    event.preventDefault()
    switch event.button
      when @mouseButtons.ORBIT
        return unless @enableRotate
        handleMouseDownRotate event
        state = STATE.ROTATE
      when @mouseButtons.ZOOM
        return unless @enableZoom
        handleMouseDownDolly event
        state = STATE.DOLLY
      when @mouseButtons.PAN
        return unless @enablePan
        handleMouseDownPan event
        state = STATE.PAN

    if state isnt STATE.NONE
      document.addEventListener 'mousemove', onMouseMove, false
      document.addEventListener 'mouseup', onMouseUp, false
      @dispatchEvent startEvent

  onMouseMove = (event) =>
    return unless @enabled

    event.preventDefault()

    switch state
      when STATE.ROTATE
        return unless @enableRotate
        handleMouseMoveRotate event
      when STATE.DOLLY
        return unless @enableZoom
        handleMouseMoveDolly event
      when STATE.PAN
        return unless @enablePan
        handleMouseMovePan event

  onMouseUp = (event) =>
    return unless @enabled

    document.removeEventListener 'mousemove', onMouseMove, false
    document.removeEventListener 'mouseup', onMouseUp, false
    @dispatchEvent endEvent
    state = STATE.NONE

  onMouseWheel = (event) =>
    return unless @enabled and @enableZoom and state in [STATE.NONE, STATE.ROTATE]

    event.preventDefault()
    event.stopPropagation()
    handleMouseWheel event
    @dispatchEvent startEvent
    
    # not sure why these are here...
    @dispatchEvent endEvent

  onKeyDown = (event) =>
    return unless @enabled and @enableKeys and @enablePan
    handleKeyDown event

  onTouchStart = (event) =>
    return unless @enabled

    switch event.touches.length
      when 1 # one-fingered touch: rotate
        return unless @enableRotate
        handleTouchStartRotate event
        state = STATE.TOUCH_ROTATE
      when 2 # two-fingered touch: dolly
        return unless @enableZoom
        handleTouchStartDolly event
        state = STATE.TOUCH_DOLLY
      when 3 # three-fingered touch: pan
        return unless @enablePan
        handleTouchStartPan event
        state = STATE.TOUCH_PAN
      else
        state = STATE.NONE
    
    if state isnt STATE.NONE
      @dispatchEvent startEvent

  onTouchMove = (event) =>
    return unless @enabled

    event.preventDefault()
    event.stopPropagation()

    switch event.touches.length
      when 1 # one-fingered touch: rotate
        return unless @enableRotate
        return unless state is STATE.TOUCH_ROTATE
        handleTouchMoveRotate event
      when 2 # two-fingered touch: dolly
        return unless @enableZoom
        return unless state is STATE.TOUCH_DOLLY
        handleTouchMoveDolly event
      when 3 # three-fingered touch: pan
        return unless @enablePan
        return unless state is STATE.TOUCH_PAN
        handleTouchMovePan event
      else
        state = STATE.NONE

  onTouchEnd = (event) =>
    return unless @enabled

    @dispatchEvent endEvent
    state = STATE.NONE

  onContextMenu = (event) =>
    return unless @enabled

    event.preventDefault()

  init = =>
    @domElement.addEventListener 'contextmenu', onContextMenu, false
    @domElement.addEventListener 'mousedown', onMouseDown, false
    @domElement.addEventListener 'wheel', onMouseWheel, false
    @domElement.addEventListener 'touchstart', onTouchStart, false
    @domElement.addEventListener 'touchend', onTouchEnd, false
    @domElement.addEventListener 'touchmove', onTouchMove, false
    window.addEventListener 'keydown', onKeyDown, false
    @update() # force an update at start

  init()
  
  this

Controls.prototype = Object.create(THREE.EventDispatcher.prototype)
Controls::constructor = Controls
export default Controls
