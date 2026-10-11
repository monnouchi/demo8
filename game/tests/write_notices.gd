extends SceneTree
## Preserve the engine's own license data with the distributable Web game.
const BUNDLE = preload("res://addons/web_licenses/bundle.gd")
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		push_error("Pass one output path for ENGINE_NOTICES.txt")
		quit(1)
		return
	var output := FileAccess.open(args[0],FileAccess.WRITE)
	if output == null:
		push_error("Cannot write engine notices")
		quit(1)
		return
	output.store_string(BUNDLE.engine_notice_text())
	output.close()
	quit(0)
