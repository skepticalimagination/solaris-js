import publicize from './helpers/publicizer'

import {
  Group, SphereGeometry, MeshPhongMaterial, MeshBasicMaterial, MeshLambertMaterial
  TextureLoader, Mesh, PointLight, Sprite, SpriteMaterial, AdditiveBlending, Vector3
} from 'three'

import Label from './label/Label'
import Ring from './Ring'
import Orbit from './Orbit'

degreesToRadians = (v) -> v * (Math.PI / 180)

class $CelestialBody
  constructor: (@model, @solaris, @parent) ->
    @styles = @solaris.styles.compute(@model.key, @model.type)

    @container = if not @parent then @solaris.scene
    else $CelestialBody.privateInstances.get(@parent).group

    # @public
    @group = new Group
    @container.add(@group)

    @sphere = @createSphere(@model.radius)
    @group.add(@sphere)

    if @model.ring
      @ring = new Ring(@model.ring, @model.key, @solaris.root, @solaris.scale)
      @sphere.add(@ring.mesh)
    
    if @model.elements
      @orbit = new Orbit(@model.getOrbitPath(), @styles.orbit, @solaris.scale)
      @container.add(@orbit.line)

    @label = new Label @model, @styles.orbit, @solaris.el
    @label.onClick =>
      @solaris.controls.target.copy(@getAbsolutePosition())

  # @public
  update: ->
    if @model.elements
      @group.position.fromArray(@solaris.scale.convert(@model.position))

    if @lastTime isnt @model.time
      @lastTime = @model.time
      @orbit.update(@model.getOrbitPath()) if @orbit

    labelPosition = @getScreenPosition()
    if @lastLabelPosition isnt labelPosition
      @lastLabelPosition = labelPosition
      @label.setPosition(labelPosition)

  createSphere: (radius) ->
    radius = @solaris.scale.convert(radius)

    {color, light, texture} = @styles
    
    geometry = new SphereGeometry(radius, 32, 32) # radius, segments, rings

    material = if texture
      new MeshPhongMaterial {map: new TextureLoader().load(texture)}
    else if light
      new MeshBasicMaterial {color}
    else if color
      new MeshLambertMaterial {color}

    sphere = new Mesh(geometry, material)

    if light
      sphere.add(new PointLight(light))
      sphere.add(@createCorona radius, light)

    sphere.position.set(0, 0, 0)

    if @model.tilt
      sphere.rotation.x = (Math.PI / 2) - degreesToRadians(@model.tilt)

    sphere

  createCorona: (radius, color) ->
    material = new SpriteMaterial
      map: new TextureLoader().load("#{@solaris.root}/img/corona.jpg")
      color: color
      transparent: no
      blending: AdditiveBlending

    mesh = new Sprite(material)
    mesh.scale.multiplyScalar(radius * 4.4)

    mesh

  getAbsolutePosition: ->
    pos = new Vector3
    pos.setFromMatrixPosition(@group.matrixWorld)
    pos

  getScreenPosition: ->
    pos = @getAbsolutePosition()
    pos.project(@solaris.camera)

    w = window.innerWidth
    hw = w / 2

    h = window.innerHeight
    hh = h / 2

    pos.x = (pos.x * hw) + hw
    pos.y = -(pos.y * hh) + hh

    if 0 < pos.z < 1 and
    0 < pos.x < w and
    0 < pos.y < h
      pos
    else # out of screen
      null

export default class CelestialBody extends publicize $CelestialBody,
  methods: ['update']
