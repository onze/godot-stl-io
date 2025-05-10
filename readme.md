<p align="center">
  <img src="stl.png" alt="logo"/>
</p>

# STL-IO
A [Godot](https://godotengine.org/)/GDScript addon to import/export in the STL file format.

[!["Buy Me A Coffee"](https://buymeacoffee.com/assets/img/custom_images/yellow_img.png)](https://www.buymeacoffee.com/valbisson)

# Setup
1. copy the `addons/stl-io` directory into your addons
2. activate it in the plugins settings.

# Overview
This addon is pretty simple with 3 classes:
- `STLIO` has the plumbing to enable the editor
- `STLIO.Importer` for manual imports
- `STLIO.Exporter` for manual exports

# Usage
## In The Editor
STL files should be usable as `ArrayMesh` resources as soon as the addon is activated.

## Import
The importer returns either a `Variant` that is either an `ERROR` or an `ArrayMesh`.
```gdscript
var mesh :ArrayMesh = STLIO.Importer.LoadFromPath('/path/to/file.stl')
```
`STLIO.Importer.LoadFromBytes` is also available for custom use cases.

## Export
The exporter exports all surfaces of an `ArrayMesh` to its destination.
```gdscript
var mesh :ArrayMesh = ...
STLIO.Exporter.SaveToPath(mesh, '/path/to/file.stl')
```
`STLIO.Exporter.SaveToBytes` is also available for custom use cases.

## See Also
For more, check out the sample viewer.

## FAQ
Q: Nice icon!<br>
A: Thanks, it comes from [flaticon.com](https://www.flaticon.com/free-icon/stl_9417765)

Q: Support for colors or unofficial data in the header or the facet attr field?<br>
A: Not in this first version no. Also I lack sample data to test this, please file an issue and I'll be happy to work on it 😃

Q: Any STL resources to share?<br>
A: [STLA Files](https://people.sc.fsu.edu/~jburkardt/data/stla/stla.html), or just [wikipedia](https://en.wikipedia.org/wiki/STL_(file_format)).


## Changelog
### 1.0.0
- importer & exporter ready

<details>
<summary>Previous entries</summary>

### 0.1
- first working version

</details>
