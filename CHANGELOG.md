# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Highlighting selected / centered celestial body.
- `Solaris#reset`: Resets the scene to the default perspective (centered on the sun).

### Changed
- Leaving handling of `DOMContentLoaded` to library consumer.
- Placed limit on zoom out.

### Fixed
- Label flickering when zooming out.

## 0.1.1 - 2017-08-03
### Added
- `fastClickElement` option: allows applying FastClick to document.body or another element.
- `Solaris#center` method: makes a CelestialBody the center of controls and camera.

### Changed
- By default, applying FastClick only to the container element supplied to the constructor.
- When `Solaris#setTime` is used, camera and controls keep centered on the same object.

### Fixed
- Updating orbit paths correctly when time changes.
- Positioning labels correctly (relative to WebGL canvas instead of window).

## 0.1.0 - 2017-07-20
### Added
- Initial release.

[Unreleased]: https://github.com/skepticalimagination/solaris-js/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/skepticalimagination/solaris-js/compare/v0.1.0...v0.1.1
