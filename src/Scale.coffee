import publicize from './helpers/publicizer'

class $Scale
  constructor: (maxLength) ->
    @factor = 1000 / maxLength
    @sceneSize = @convert(maxLength)

  convert: (v) ->
    if v instanceof Array then v.map (item) => item * @factor
    else v * @factor

export default class Scale extends publicize $Scale,
  methods: ['convert']
  properties: ['sceneSize']
