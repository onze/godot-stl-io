extends Control

@onready var open_model_btn: Button = %'open-model-btn'
@onready var mesh_instance_import: MeshInstance3D = %mesh_instance_import
@onready var mesh_instance_export: MeshInstance3D = %mesh_instance_export
@onready var model_path_label: Label = %'model-path-label'

var file_dialog :FileDialog

func _init() -> void:
	print('Supported ArrayMesh Formats: %s'%[ResourceLoader.get_recognized_extensions_for_type('ArrayMesh')])

func _ready() -> void:
	open_model_btn.pressed.connect(_on_open_pressed)
	mesh_instance_import.mesh = STLIO.Importer.LoadFromPath('res://samples/bottle.stl')

	# export -- disabled when running in the sample viewer
	if false:
		var export_path := OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS).path_join('output.stl')
		var err := STLIO.Exporter.SaveToPath(mesh_instance_export.mesh, export_path)
		if err == OK:
			print('exported as %s'%export_path)
		else:
			printerr('Could not export model: %s'%error_string(err))
	else:
		mesh_instance_export.hide()

func _on_open_pressed() -> void:
	file_dialog = FileDialog.new()
	file_dialog.name = 'open-model'
	file_dialog.title = 'Open Model'
	file_dialog.size = Vector2(800, 600)
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.filters = PackedStringArray(['*.stl;STL files'])
	file_dialog.ok_button_text = 'Open'
	file_dialog.dialog_hide_on_ok = true
	file_dialog.dialog_close_on_escape = true
	file_dialog.file_selected.connect(_on_file_selected)
	file_dialog.close_requested.connect(file_dialog.queue_free)
	file_dialog.canceled.connect(file_dialog.queue_free)
	get_tree().root.add_child(file_dialog)
	file_dialog.popup_centered()

func _on_file_selected(path :String) -> void:
	model_path_label.text = path
	var result = STLIO.Importer.LoadFromPath(path)
	if STLIO.IsError(result):
		model_path_label.text = 'Could not load model: '%error_string(result)
		return
	mesh_instance_import.mesh = result as ArrayMesh
