@tool
extends RefCounted
## The same full notices are used by editor/CLI exports and the standalone writer.

static func engine_notice_text() -> String:
	var text := "GODOT ENGINE\n\n" + Engine.get_license_text() + "\n\nTHIRD-PARTY COPYRIGHT INFORMATION\n\n"
	text += JSON.stringify(Engine.get_copyright_info(),"  ") + "\n\nTHIRD-PARTY LICENSE TEXTS\n\n"
	var licenses := Engine.get_license_info()
	for name in licenses:
		text += str(name) + "\n\n" + str(licenses[name]) + "\n\n"
	return text

static func write_to(directory: String) -> Error:
	var root := ProjectSettings.globalize_path("res://")
	var files := {
		"LICENSE.txt":FileAccess.get_file_as_bytes(root.path_join("../LICENSE").simplify_path()),
		"FONT_LICENSE.txt":FileAccess.get_file_as_bytes("res://assets/fonts/LICENSE.txt"),
		"ENGINE_NOTICES.txt":engine_notice_text().to_utf8_buffer()
	}
	for bytes in files.values():
		if bytes.is_empty():return ERR_FILE_CORRUPT
	var error := DirAccess.make_dir_recursive_absolute(directory)
	if error!=OK:return error
	files[".nojekyll"] = PackedByteArray()
	for name in files:
		var output := FileAccess.open(directory.path_join(name),FileAccess.WRITE)
		if output==null:return FileAccess.get_open_error()
		output.store_buffer(files[name])
		error = output.get_error()
		output.close()
		if error!=OK:return error
	return OK
