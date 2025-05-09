extends RefCounted

static func LoadFromPath(path: String) -> Variant:
	'''
	:return: ArrayMesh or Error
	'''
	# first thing is to find wether we're loading text or a binary
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.is_empty():
		return FileAccess.get_open_error()

	var load_result: Variant = LoadFromBytes(bytes)
	if STLIO.IsError(load_result):
		return load_result as Error

	var mesh: ArrayMesh = load_result
	if mesh == null:
		# if it wasn't an error it should be an ArrayMesh
		return ERR_BUG

	mesh.surface_set_name(0, path.get_file())
	return mesh

static func LoadFromBytes(bytes :PackedByteArray) -> Variant:
	var text_header := bytes.slice(0, 80).get_string_from_ascii().strip_edges()
	var load_result: Variant
	if text_header.begins_with('solid '):
		load_result = LoadAsciiFromBuffer(bytes)
	else:
		load_result = LoadBinaryFromBuffer(bytes)

	if STLIO.IsError(load_result):
		return load_result as Error

	var mesh: ArrayMesh = load_result
	if mesh == null:
		# if it wasn't an error it should be an ArrayMesh
		return ERR_BUG

	# polish
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.WHITE
	mat.vertex_color_use_as_albedo = true
	mesh.surface_set_material(0, mat)
	return mesh

enum ASCII {
	LINE_BREAK = 10 # \n
}
enum ASCII_PARSING_MODE {
	SOLID_HEADER = 0,
	FACET = 1,
	OUTER_LOOP = 2,
	VERTEX = 3,
	END_LOOP = 4,
	END_FACET = 5,
	END_SOLID = 6,
}
#static func _GetNextLineOffset(bytes :PackedByteArray, offset :int) -> int:

static func LoadAsciiFromBuffer(bytes :PackedByteArray) -> Variant:
	var mesh := ArrayMesh.new()
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var line := ''
	var offset = 0
	var tokens :PackedStringArray
	var normal :Vector3
	var facet := PackedVector3Array()

	# pump lines
	var parsing_mode := ASCII_PARSING_MODE.SOLID_HEADER
	while offset < bytes.size():
		var next_line_break_index := bytes.find(ASCII.LINE_BREAK, offset)
		line = bytes.slice(offset, next_line_break_index).get_string_from_ascii().strip_edges()
		# jump to next line
		offset = next_line_break_index+1
		match parsing_mode:
			ASCII_PARSING_MODE.SOLID_HEADER:
				var header := line.substr('solid '.length())
				mesh.set_meta('header', header)
				parsing_mode = ASCII_PARSING_MODE.FACET

			ASCII_PARSING_MODE.FACET:
				if line.begins_with('endsolid'):
					parsing_mode = ASCII_PARSING_MODE.END_SOLID
					continue

				tokens = line.split(' ', false)
				if tokens.size() != 5:
					return ERR_FILE_CORRUPT
				normal = Vector3(
					tokens[2].to_float(),
					tokens[3].to_float(),
					tokens[4].to_float(),
				)
				normals.append_array([normal, normal, normal])
				parsing_mode = ASCII_PARSING_MODE.OUTER_LOOP

			ASCII_PARSING_MODE.OUTER_LOOP:
				parsing_mode = ASCII_PARSING_MODE.VERTEX

			ASCII_PARSING_MODE.VERTEX:
				tokens = line.split(' ', false)
				if tokens.size() != 4:
					return ERR_FILE_CORRUPT
				facet.append(Vector3(
					tokens[1].to_float(),
					tokens[2].to_float(),
					tokens[3].to_float(),
				))
				if facet.size() == 3:
					# facet is full but may not be oriented right
					if Plane(facet[0], facet[1], facet[2]).normal.dot(normal) > 0:
						vertices.append_array(facet)
					else:
						vertices.append_array([facet[2], facet[1], facet[0]])
					facet.clear()
					parsing_mode = ASCII_PARSING_MODE.END_LOOP

			ASCII_PARSING_MODE.END_LOOP:
				parsing_mode = ASCII_PARSING_MODE.END_FACET

			ASCII_PARSING_MODE.END_FACET:
				parsing_mode = ASCII_PARSING_MODE.FACET

			ASCII_PARSING_MODE.END_SOLID:
				break

	mesh.set_meta('triangle_count', int(vertices.size()/3))
	var arrays := Array()
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

const BYTES_PER_TRIANGLE :int = 50
static func LoadBinaryFromBuffer(bytes :PackedByteArray) -> Variant:
	var mesh := ArrayMesh.new()
	var offset := 0
	mesh.set_meta('header', bytes.slice(0, 80).get_string_from_ascii())
	offset+=80
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var triangle_count := bytes.decode_u32(offset)
	offset+=4
	if offset+triangle_count*BYTES_PER_TRIANGLE > bytes.size():
		return ERR_FILE_CORRUPT

	mesh.set_meta('triangle_count', triangle_count)
	for triangle_index in range(triangle_count):
		var normal := Vector3(
			bytes.decode_float(offset),
			bytes.decode_float(offset+4),
			bytes.decode_float(offset+8),
		)
		normals.append_array([normal, normal, normal])
		offset+=12
		var v1 := Vector3(
			bytes.decode_float(offset),
			bytes.decode_float(offset+4),
			bytes.decode_float(offset+8),
		)
		offset+=12
		var v2 := Vector3(
			bytes.decode_float(offset),
			bytes.decode_float(offset+4),
			bytes.decode_float(offset+8),
		)
		offset+=12
		var v3 := Vector3(
			bytes.decode_float(offset),
			bytes.decode_float(offset+4),
			bytes.decode_float(offset+8),
		)
		offset += 12
		if Plane(v1, v2, v3).normal.dot(normal) > 0:
			vertices.append_array([v1, v2, v3])
		else:
			vertices.append_array([v3, v2, v1])
		var attribute := bytes.decode_u16(offset)
		offset += 2

	var arrays := Array()
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
