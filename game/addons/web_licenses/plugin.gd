@tool
extends EditorPlugin

const BUNDLE = preload("res://addons/web_licenses/bundle.gd")

class WebLicenseExport extends EditorExportPlugin:
	func _get_name() -> String:
		return "WebLicenses"

	func _export_begin(features: PackedStringArray, _is_debug: bool, path: String, _flags: int) -> void:
		if not features.has("web"):return
		var error := BUNDLE.write_to(path.get_base_dir())
		if error!=OK:
			push_error("Cannot bundle Web licenses: " + error_string(error))
		else:
			print("Bundled LICENSE.txt, FONT_LICENSE.txt and ENGINE_NOTICES.txt")

var exporter: EditorExportPlugin

func _enter_tree() -> void:
	exporter = WebLicenseExport.new()
	add_export_plugin(exporter)

func _exit_tree() -> void:
	remove_export_plugin(exporter)
