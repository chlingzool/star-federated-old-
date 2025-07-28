extends Node

var is_drive: Dictionary = {"is": false, "who": "", "position": Vector2(0, 0)}
var world_builder_seed: int

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

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r
