extends Control

func _ready() -> void:
	show()

func _process(_delta: float) -> void:
	var xy = $"../../players/self".position
	var xy_text = "		X: "+str(int(xy.x))+"	Y: "+str(int(xy.y))
	$PanelContainer/HBoxContainer/xy.text = xy_text
	
	if Input.is_action_just_pressed("quit"):
		MainScript.is_drive["is"] = false
		MainScript.is_drive["who"] = ""
		get_tree().call_deferred("change_scene_to_file", "res://node/start/#.tscn")
