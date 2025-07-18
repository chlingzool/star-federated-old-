extends Control

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		MainScript.is_drive["is"] = false
		MainScript.is_drive["who"] = ""
		get_tree().call_deferred("change_scene_to_file", "res://node/start/#.tscn")
