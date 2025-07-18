extends Camera2D

var mode: bool = true

func _process(_delta: float) -> void:
	if mode:
		if Input.is_action_just_pressed("mos_down"):
			if zoom.x > 0.002 and zoom.y > 0.002:
				zoom /= 1.1
		elif Input.is_action_just_pressed("mos_up"):
			if zoom.x < 3 and zoom.y < 3:
				zoom *= 1.1
