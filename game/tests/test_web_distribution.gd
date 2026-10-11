extends SceneTree
## Validate the real export, including complete notices rather than file names alone.

var checks := 0
var failed := false

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failed = true
		push_error(message)

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size()!=1:
		push_error("Pass one exported Web directory")
		quit(1)
		return
	var directory := args[0]
	for name in ["index.html","index.js","index.wasm","index.pck"]:
		check(not FileAccess.get_file_as_bytes(directory.path_join(name)).is_empty(),"Missing Web export: " + name)
	check(FileAccess.file_exists(directory.path_join(".nojekyll")),"Missing Pages marker")
	var root := ProjectSettings.globalize_path("res://")
	for pair in [["LICENSE.txt",root.path_join("../LICENSE").simplify_path()],["FONT_LICENSE.txt","res://assets/fonts/LICENSE.txt"]]:
		var source := FileAccess.get_file_as_bytes(pair[1])
		var bundled := FileAccess.get_file_as_bytes(directory.path_join(pair[0]))
		check(not source.is_empty() and bundled==source,"Missing or changed full license: " + pair[0])
	var notices := FileAccess.get_file_as_string(directory.path_join("ENGINE_NOTICES.txt"))
	check(notices.begins_with("GODOT ENGINE\n\n"),"Missing Godot notice heading")
	check(notices.contains(Engine.get_license_text()),"Missing full Godot license text")
	var copyright_json := notices.get_slice("THIRD-PARTY COPYRIGHT INFORMATION\n\n",1).get_slice("\n\nTHIRD-PARTY LICENSE TEXTS\n\n",0)
	check(JSON.parse_string(copyright_json)==Engine.get_copyright_info(),"Missing full third-party copyright information")
	var licenses := Engine.get_license_info()
	for name in licenses:
		check(notices.contains(str(name)+"\n\n"+str(licenses[name])+"\n\n"),"Missing full third-party license: " + str(name))
	if not failed:print("PASS: %d Web distribution checks, complete game/font/Godot/third-party notices" % checks)
	quit(1 if failed else 0)
