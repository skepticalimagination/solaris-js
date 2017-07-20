import publicize from './helpers/publicizer'

# Based on RadialRingGeometry.js by Sander Blue:
# https://github.com/sanderblue/solar-system-threejs/blob/gh-pages/src/app/Extensions/RadialRingGeometry.js
import {
  Vector3, Vector2, Face3, Sphere, Geometry
  MeshLambertMaterial, TextureLoader, Mesh, DoubleSide
} from 'three'
{cos, sin, PI} = Math

PlanetaryRingGeometry = (iRadius = 0, oRadius = 50, thetaSegments = 8) ->
  Geometry.call(this)

  for i in [0...thetaSegments] # One "rectangle" (trapezoid) per ring segment
    circle = PI * 2 # Complete revolution in radians
    ccwEdge = circle * (i / thetaSegments) # Counter-clockwise border angle
    cwEdge = circle * ((i + 1) / thetaSegments) # Clockwise border angle
    
    @vertices.push tl = new Vector3(iRadius * cos(ccwEdge), iRadius * sin(ccwEdge), 0) # "top left"
    @vertices.push tr = new Vector3(oRadius * cos(ccwEdge), oRadius * sin(ccwEdge), 0) # "top right"
    @vertices.push bl = new Vector3(iRadius * cos(cwEdge), iRadius * sin(cwEdge), 0) # "bottom left"
    @vertices.push br = new Vector3(oRadius * cos(cwEdge), oRadius * sin(cwEdge), 0) # "bottom right"

    # The two triangular faces that make up the "rectangle"
    @faces.push new Face3(@vertices.indexOf(tl), @vertices.indexOf(tr), @vertices.indexOf(bl))
    @faces.push new Face3(@vertices.indexOf(bl), @vertices.indexOf(tr), @vertices.indexOf(br))
    @computeFaceNormals()
    
    # Map triangle corners to (rectangular) texture corners
    @faceVertexUvs[0].push [new Vector2(0, 0), new Vector2(1, 0), new Vector2(0, 1)] # tl, tr, bl
    @faceVertexUvs[0].push [new Vector2(0, 1), new Vector2(1, 0), new Vector2(1, 1)] # bl, tr, br

  return

PlanetaryRingGeometry.prototype = Object.create(Geometry.prototype)

class $Ring
  constructor: (model, key, root, @scale) ->
    innerRadius = @scale.convert(model.innerRadius)
    outerRadius = @scale.convert(model.outerRadius)

    geometry = new PlanetaryRingGeometry innerRadius, outerRadius, 64, 64

    material = new MeshLambertMaterial
      side: DoubleSide
      transparent: yes
      map: new TextureLoader().load("#{root}/img/#{key}-rings.png")

    @mesh = new Mesh(geometry, material)

    @mesh.rotation.x = -Math.PI / 2

    @mesh

export default class Ring extends publicize $Ring,
  properties: ['mesh']
