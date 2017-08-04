import publicize from './helpers/publicizer'

import fastclick from 'fastclick'

import {Scene, AmbientLight, WebGLRenderer, PerspectiveCamera, Vector3} from 'three'

import Model from 'solaris-model'
import Styles from './Styles'
import Scale from './Scale'
import Loader from './loader/Loader'
import CelestialBody from './CelestialBody'
import Background from './Background'
import Controls from './Controls'
wait = (ms, cb) -> setTimeout(cb, ms)

class $Solaris
  constructor: (element, options) ->
    @root = options?.root ? 'solaris'
    @styles = new Styles(options?.styles, @root)

    # @public
    @model = new Model
    @scale = new Scale(@model.bodies.pluto.elements.base.a * 2)

    @el = if typeof element is 'string' then document.getElementById(element) else element
    @el.classList.add 'solaris'

    @loader = new Loader(@el, @root)

    fastclick(options?.fastClickElement ? @el)

    @scene = new Scene
    @scene.add new AmbientLight(0x222222)

    @createRenderer()

    @background = new Background(@scale.sceneSize, @root)
    @scene.add @background.mesh

    @createCamera()
    @createControls()

    @bodies = Object.create(null)
    @initBodies [@model.bodies.sun]

    window.addEventListener 'resize', @onWindowResize, false

    @animate()

  # @public
  setTime: (time) ->
    @model.setTime(time)
    wait 50, => @center(@target) if @target

  # @public
  center: (@target) ->
    @target = @bodies[@target] if typeof @target is 'string'
    @controls.target.copy(@target.getAbsolutePosition())

  createRenderer: ->
    @renderer = new WebGLRenderer(antialias: yes, alpha: yes)
    @renderer.setSize window.innerWidth, window.innerHeight
    @renderer.setPixelRatio(window.devicePixelRatio)
    @el.appendChild @renderer.domElement

  createCamera: ->
    # fov, aspect, near, far
    @camera = new PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.0001, @scale.sceneSize * 40)
    @camera.up = new Vector3(0, 0, 1)
    @camera.position.set 0, 0, @scale.convert(@model.bodies.mars.elements.base.a * 2.7)

  createControls: ->
    @controls = new Controls(@camera, @renderer.domElement)
    @controls.enableZoom = true
    @controls.target.set(0, 0, 0)

  initBodies: (bodies, parent) ->
    for k, model of bodies
      body = new CelestialBody(model, this, parent, @renderer.domElement)
      @bodies[k] = body
      @initBodies(model.satellites, body) if model.satellites

  updateBodies: ->
    for k, body of @bodies
      body.update()

  animate: =>
    @updateBodies()
    @renderer.render @scene, @camera
    @controls.update()
    window.requestAnimationFrame(@animate)

  onWindowResize: =>
    @camera.aspect = window.innerWidth / window.innerHeight
    @camera.updateProjectionMatrix()

    @renderer.setSize window.innerWidth, window.innerHeight

export default class Solaris extends publicize $Solaris,
  properties: ['model']
  methods: ['setTime', 'center']
