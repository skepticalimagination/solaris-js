import publicize from './helpers/publicizer'
import {ShaderMaterial, TextureLoader, Mesh, SphereGeometry} from 'three'

# Based on Ian Webster's blog post: http://www.ianww.com/blog/2014/02/17/making-a-skydome-in-three-dot-js/
class $Background
  constructor: (sceneSize, root) ->
    material = new ShaderMaterial
      uniforms:
        texture: {type: 't', value: new TextureLoader().load("#{root}/img/background.jpg")}
      vertexShader: '''
        varying vec2 vUV;

        void main() {
          vUV = uv;
          vec4 pos = vec4(position, 1.0);
          gl_Position = projectionMatrix * modelViewMatrix * pos;
        }
      '''
      fragmentShader: '''
        uniform sampler2D texture;
        varying vec2 vUV;

        void main() {
          vec4 sample = texture2D(texture, vUV);
          gl_FragColor = vec4(sample.xyz, sample.w);
        }
      '''

    # @public
    @mesh = new Mesh(new SphereGeometry(sceneSize * 50, 60, 40), material)
    @mesh.scale.set(-1, 1, 1)
    @mesh.rotation.order = 'XZY'
    @mesh.rotation.z = Math.PI / 2
    @mesh.rotation.x = Math.PI
    @mesh.renderDepth = 1000.0

export default class Background extends publicize $Background,
  properties: ['mesh']
