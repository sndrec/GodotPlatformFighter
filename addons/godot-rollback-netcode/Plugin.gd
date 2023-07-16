@tool
extends EditorPlugin


func _enter_tree() -> void:
	var project_settings_node = load("res://addons/godot-rollback-netcode/ProjectSettings.gd").new()
	project_settings_node.add_project_settings()
	project_settings_node.free()
	
	add_autoload_singleton("SyncManager", "res://addons/godot-rollback-netcode/SyncManager.gd")
	
	
	if not ProjectSettings.has_setting("input/sync_debug"):
		var sync_debug = InputEventKey.new()
		sync_debug.keycode = KEY_F11
		
		ProjectSettings.set_setting("input/sync_debug", {
			deadzone = 0.5,
			events = [
				sync_debug,
			],
		})
		
		# Cause the ProjectSettingsEditor to reload the input map from the
		# ProjectSettings.
		get_tree().root.get_child(0).propagate_notification(EditorSettings.NOTIFICATION_EDITOR_SETTINGS_CHANGED)
