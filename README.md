# Solaris.js

A reusable component for interactive visualization of the Solar System.

- WebGL-based: uses three.js for rendering
- Mobile-friendly: mouse and touch controls supported
- Framework-agnostic: no dependency on jQuery or other major libraries apart from three.js
- Customizable styles for the rendering of planets, moons, orbits, etc

The goal is to have something like a Google Maps or [Cesium](https://github.com/AnalyticalGraphicsInc/cesium/) for the Solar System, making it easier to build apps and games depicting it.

This is a **work in progress**: the basics are there but many areas, especially satellites, still need a lot of work.

Corrections and bug reports [are welcome](https://github.com/skepticalimagination/solaris-js/issues).

**Model / custom rendering**: all astronomical data and orbital calculations are encapsulated in the [solaris-model](https://github.com/skepticalimagination/solaris-model) module. You can use it directly if you'd like to implement your own rendering of the Solar System.

## Install

### From npm

```
npm install solaris-js
```

CommonJS:

```javascript
let Solaris = require('solaris-js')
```

It's also available as an ES6 module (using [`pkg.module`](https://github.com/rollup/rollup/wiki/pkg.module)):

```javascript
import Solaris from 'solaris-js'
```

The CSS is declared in [`pkg.style`](https://stackoverflow.com/questions/32037150/style-field-in-package-json), so you can get it from npm too:

```css
@import "solaris-js";
```

To use the default assets (planet textures etc), serve the folder `node_modules/solaris/dist`, by copying it to your public root or mounting it in your application. Ex.:

```
cp node_modules/solaris/dist public/solaris
```

Or mounting it in express:

```javascript
app.use('/solaris', express.static(__dirname + '/node_modules/solaris/dist'))
```

### Manual installation

If you prefer to install it the old-fashioned way, download the [tarball](https://registry.npmjs.org/solaris-js/-/solaris-js-0.1.0.tgz) and copy the `dist` folder to your public root, renaming it `solaris`.

```html
<link rel="stylesheet" href="solaris/solaris.css">
<script src="solaris/solaris.min.js"></script> <!-- sets window.Solaris -->
```

### Custom path for assets

Using either method above, if you wish to put the assets in a path other than the default `solaris`, just pass your custom path during initialization:

```javascript
let solaris = new Solaris(element, {root: 'path/to/wisdom'})
```

## Usage

Just give it an element id and you'll get a Solar System view with the default settings and theme:

```javascript
let solaris = new Solaris('elementId')
```

You can also pass it an element reference:

```javascript
let solaris = new Solaris(document.querySelector('.solaris'))
```

By default, the date/time used for the calculation of positions will be the system's local.

To set a specific date/time, you can either give it a date string:

```javascript
solaris.setTime('1961-04-12') // will be parsed to 1961-04-12T12:00:00Z (UTC)
```

Or a javascript `Date` object:

```javascript
solaris.setTime(new Date('1969-07-20T20:17:43Z'))
```

You can customize the appearance of celestial bodies and orbits by using the `styles` param:

```javascript
let solaris = new Solaris(elementId, {
  styles: {
    types: {
      planet: {color: 0xFFFFFF, orbit: 0xFFFFFF},
      dwarfPlanet: {color: 0x666666, orbit: 0x666666},
      moon: {color: 0x666666, orbit: 0x666666},
      spacecraft: {color: 0x666666, orbit: 0x666666}
    }

    bodies: {
      sun: {color: 0xFFFFFF, light: 0xFFFFFF},
      mercury: {texture: true, orbit: 0xD2D0D3},
      venus: {color: 0xFFFFFF, orbit: 0xFFFF99},
      earth: {texture: true, orbit: 0x659EC1},
      moon: {texture: true},
      iss: {orbit: 0x0000FF},
      mars: {texture: true, orbit: 0xCC0000},
      ceres: {texture: true}
    }
  }
})
```

By default, each celestial body will be rendered according to the styles defined for their `type` (`star`, `planet`, `dwarfPlanet`, `moon` or `spacecraft`).

These can be selectively overriden by the individually-targeted styles defined in the `bodies` section.

To get the complete list of objects you can style:

```javascript
Object.keys(solaris.model.bodies)
// => ["sun", "mercury", "venus", "earth", "moon", "iss", "mars", "phobos", "deimos", "ceres", "jupiter", "io", "europa", "ganymede", "callisto", "saturn", "mimas", "enceladus", "tethys", "dione", "rhea", "titan", "hyperion", "iapetus", "phoebe", "uranus", "titania", "neptune", "triton", "pluto", "eris", "sedna"]
```

### Available styles

#### `color`

The sphere's surface color, as a number. Ex.: `0xFFFFFF`.

#### `texture`

Instead of a color, use a texture for the sphere's surface.

If set to `true`, the corresponding image will be expected at `{root}/img/{bodyKey}.jpg`.

If given a string, it will be interpreted as the full relative path to the image.

#### `light`

Color of the emitted light, only used for orbiters of type `star`.

#### `orbit`

Color of the line showing the orbit's path.

### Other options
#### `fastclickElement`

The [FastClick](https://github.com/ftlabs/fastclick) library is used to eliminate tap delay on touch-based devices, and by default it is restricted to the element you supplied Solaris with.

You can use this option to attach FastClick to a different element, for example if you wish it to apply to the whole document:

```javascript
let solaris = new Solaris('elementId', {fastClickElement: document.body})
```

## To-do list

- Camera positioning and direction

- Emit events: onLoad, onBodyClicked, etc

- Show message when WebGL is not available

- Add Electron-based tests.

- The milky way [should be inclined 63 degrees](http://curious.astro.cornell.edu/about-us/159-our-solar-system/the-sun/the-solar-system/236-are-the-planes-of-solar-systems-aligned-with-the-plane-of-the-galaxy-intermediate) to the plane of the ecliptic.

- Add a "classic" theme (yellow sun, infrared venus). The current one depicts celestial bodies as close as possible to what they would look like to the human eye in space (white sun, white venus).

Check [solaris-model](https://github.com/skepticalimagination/solaris-model) for issues not related to presentation.

## License

MIT
