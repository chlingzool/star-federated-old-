extends Node

var is_drive: Dictionary = {"is": false, "who": "", "position": Vector2(0, 0)}

var tween: Tween

func screen_shake(strength: float, time: float) -> void:
	var camera = get_viewport().get_camera_2d()
	if not camera: return
	tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	tween.tween_method(
		func(s: float):
			if not camera: return
			var offset: Vector2 = Vector2.from_angle(randf_range(0, TAU)) * s
			if not camera: return
			camera.offset = offset,
		strength,
		0.0,
		time)
