@tool
extends ResourceFormatLoader
class_name STLIO

const Exporter = preload('res://addons/stl-io/exporter.gd')
const Importer = preload('res://addons/stl-io/importer.gd')

static func RegisterFormatLoader(at_front := false) -> void:
	var recognized_extensions_for_type := ResourceLoader.get_recognized_extensions_for_type('ArrayMesh')
	if 'stl' in recognized_extensions_for_type or 'stla' in recognized_extensions_for_type:
		return
	ResourceLoader.add_resource_format_loader(STLIO.new(), at_front)

func _exists(path: String) -> bool:
	'''
	Returns whether a recognized resource exists for the given path.
	'''
	return FileAccess.file_exists(path)

func _handles_type(type: StringName) -> bool:
	return type in [&'ArrayMesh', &'Resource']

func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(['stl', 'stla'])

func _get_resource_script_class(_path: String) -> String:
	return 'ArrayMesh'

func _get_resource_type(path: String) -> String:
	if path.get_extension() in _get_recognized_extensions():
		return 'ArrayMesh'
	return ''

func _load(
	path: String,
	_original_path: String,
	_use_sub_threads: bool,
	_cache_mode: int
	) -> Variant:
	return Importer.LoadFromPath(path)
