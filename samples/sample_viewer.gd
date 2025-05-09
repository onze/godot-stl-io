extends Control

# registers the STL loader
const RegisterLoader = preload('res://addons/stl-io/register_loader.gd')

@onready var mesh_instance: MeshInstance3D = %mesh_instance

func _init() -> void:
	print('Supported ArrayMesh Formats: %s'%[ResourceLoader.get_recognized_extensions_for_type('ArrayMesh')])

func _ready() -> void:
	mesh_instance.mesh = STLIO.Importer.LoadFromPath('res://samples/bottle.stl')
