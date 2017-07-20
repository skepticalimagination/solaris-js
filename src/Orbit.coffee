import publicize from './helpers/publicizer'

import {Geometry, LineBasicMaterial, Line, Vector3} from 'three'

class $Orbit
  constructor: (vertices, color, @scale) ->
    geometry = new Geometry
    geometry.vertices = @convertVertices(vertices)

    material = new LineBasicMaterial {color}

    @line = new Line(geometry, material)

  convertVertices: (vertices) ->
    (new Vector3().fromArray(@scale.convert(v)) for v in vertices)

  update: (vertices) ->
    @line.geometry.vertices = @convertVertices(vertices)
    @line.geometry.verticesNeedUpdate = true

export default class Orbit extends publicize $Orbit,
  properties: ['line']
  methods: ['update']
