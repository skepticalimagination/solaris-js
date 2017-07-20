import publicize from './helpers/publicizer'

defaultRules =
  types:
    planet: {color: 0xFFFFFF, orbit: 0xFFFFFF}
    dwarfPlanet: {color: 0x666666, orbit: 0x666666}
    moon: {color: 0x666666, orbit: 0x666666}
    spacecraft: {color: 0x666666, orbit: 0x666666}

  bodies:
    sun: {color: 0xFFFFFF, light: 0xFFFFFF}
    mercury: {texture: yes, orbit: 0xD2D0D3}
    venus: {color: 0xFFFFFF, orbit: 0xFFFF99} # 0xECEEE3
    earth: {texture: yes, orbit: 0x659EC1}
    moon: {texture: yes}
    mars: {texture: yes, orbit: 0xCC0000} # 0xC18B50
    ceres: {texture: yes}
    jupiter: {texture: yes, orbit: 0xBA6222} # 0xA58671
    saturn: {texture: yes, orbit: 0xE5C57B}
    uranus: {texture: yes, orbit: 0x15D7DD}
    neptune: {texture: yes, orbit: 0x4D7EFF}
    pluto: {texture: yes}

class $Styles
  constructor: (@rules = defaultRules, @root) ->

  compute: (body, type) ->
    props = {}
    getProp = (key) => @rules.bodies?[body]?[key] ? @rules.types?[type]?[key]
    (props[key] = getProp(key)) for key in ['color', 'orbit', 'light', 'texture']
    
    props.texture = "#{@root}/img/#{body}.jpg" if props.texture is yes
    props.orbit = props.color if not props.orbit

    props

export default class Styles extends publicize $Styles,
  methods: ['compute']
