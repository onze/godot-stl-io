extends RefCounted

const FLOAT_SIZE :=4
const FACET_SIZE := 50

static func SaveToPath(mesh :Mesh, path :String, header := PackedByteArray()) -> Error:
	var return_value := SaveToBytes(mesh, header)
	if STLIO.IsError(return_value):
		return return_value
	return _SaveBytesToPath(return_value as PackedByteArray, path)

static func SaveToBytes(mesh :Mesh, header := PackedByteArray()) -> Variant:
	var bytes := PackedByteArray()
	var faces := mesh.get_faces()

	# HEADER: 80B
	if header.is_empty():
		header = ('Exported with https://github.com/onze/godot-stl-io on %s'%[
			Time.get_datetime_string_from_system()
		]).to_ascii_buffer()
	bytes.append_array(header.slice(0, 80))
	if bytes.size() < 80:
		bytes.resize(80)

	# add tri count
	bytes.append_array(PackedByteArray([0, 0, 0, 0]))
	bytes.encode_u32(80, int(faces.size()/3))
	# += triangle count * tri size
	bytes.resize(bytes.size()+int(faces.size()/3)*FACET_SIZE)

	var normal :Vector3
	var v0 :Vector3
	var v1 :Vector3
	var v2 :Vector3
	var i := 0
	var base_offset := 84
	while i < faces.size():
		v0 = faces[i]
		v1 = faces[i+1]
		v2 = faces[i+2]
		normal = Plane(v0, v1, v2).normal
		bytes.encode_float(base_offset+FLOAT_SIZE*0, normal.x)
		bytes.encode_float(base_offset+FLOAT_SIZE*1, normal.y)
		bytes.encode_float(base_offset+FLOAT_SIZE*2, normal.z)
		bytes.encode_float(base_offset+FLOAT_SIZE*3, v0.x)
		bytes.encode_float(base_offset+FLOAT_SIZE*4, v0.y)
		bytes.encode_float(base_offset+FLOAT_SIZE*5, v0.z)
		bytes.encode_float(base_offset+FLOAT_SIZE*6, v1.x)
		bytes.encode_float(base_offset+FLOAT_SIZE*7, v1.y)
		bytes.encode_float(base_offset+FLOAT_SIZE*8, v1.z)
		bytes.encode_float(base_offset+FLOAT_SIZE*9, v2.x)
		bytes.encode_float(base_offset+FLOAT_SIZE*10, v2.y)
		bytes.encode_float(base_offset+FLOAT_SIZE*11, v2.z)

		base_offset += FACET_SIZE
		i += 3

	return bytes

static func _SaveBytesToPath(bytes :PackedByteArray, path :String) -> Error:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_buffer(bytes)
	return OK
