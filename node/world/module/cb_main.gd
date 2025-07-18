@tool
extends StaticBody2D

@onready var polygon: Polygon2D = $polygon
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon
@onready var light_occluder: LightOccluder2D = $LightOccluder
@onready var random: RandomNumberGenerator = RandomNumberGenerator.new()

# 可调节参数
@export var color: Color = Color(1, 1, 1)  # 基础颜色
@export var radius: float = 500.0  # 基础半径
@export var seed_: int = 42  # 随机种子
@export var frequency: float = 1.0  # 噪声频率
@export var density: float = 1.0  # 密度
@export var count: int = 1024 # 细致度

var gravity: float = 0.0  # 重力
var mass: float = 0.0  # 质量

var visualization := false #可视化

# 森林分布参数
var tree_scene: PackedScene = preload("res://node/res/tree/tree.tscn") # 用于实例化树的场景
@export var forest_ratio: float = 0.2 # 森林占表面比例
@export var base_tree_density: float = 0.0022 # 每单位周长的树密度（可调节）
@export var tree_offset: float = 120.0 # 树浮在表面距离
@export var plain_color: Color = Color(1, 1, 0.9) # 平原区域色
@export var forest_color: Color = Color(0.8, 1.0, 0.86) # 森林区域色


func _ready() -> void:
	found()

func found() -> void:
	var noise: FastNoiseLite = FastNoiseLite.new()
	noise.seed = seed_
	noise.frequency = frequency
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 3
	noise.fractal_lacunarity = 0.05
	noise.fractal_gain = 0.5
	updata_for_noise(noise)
	mass = (density / 100) * 4/3 * PI * (radius ** 3)
	gravity = mass / (radius ** 2)
	$cb_area/CollisionShape.shape.radius = radius * gravity
	$cb_area.gravity_point_unit_distance = gravity
	$cb_area.gravity = gravity
	match get_meta("plant_type"):
		"tp":
			var _color = [Color.FOREST_GREEN, Color.GREEN_YELLOW, Color.LIME_GREEN, Color.DARK_SEA_GREEN][randi() % 4]
			color = _color
			spawn_forest_and_plain()
		"gas":
			var _color = [Color.GOLD - Color(0, 0, 0, 0.5), Color.DARK_SALMON - Color(0, 0, 0, 0.5), Color.ORANGE - Color(0, 0, 0, 0.5), Color.KHAKI - Color(0, 0, 0, 0.5)][randi() % 4]
			color = _color
			$CollisionPolygon.polygon = PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])
			$LightOccluder.occluder.set_polygon(PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]))
		"ice":
			var _color = [Color.POWDER_BLUE, Color.DEEP_SKY_BLUE, Color.ALICE_BLUE, Color.CORNFLOWER_BLUE][randi() % 4]
			color = _color
		"rock":
			var _color = [Color.CHOCOLATE, Color.DARK_GOLDENROD, Color.GOLDENROD, Color.PERU, Color.FIREBRICK][randi() % 5]
			color = _color
	$polygon.color = color

func updata_for_noise(noise: FastNoiseLite):
	var points: Array = []
	for i in range(count):
		var t = float(i) / count
		var noise_value = noise.get_noise_2d(cos(t * 2 * PI), sin(t * 2 * PI)) # 2D环形采样
		var percent = 0.2
		var current_radius = radius * (1.0 + percent * noise_value)
		var angle = t * 2 * PI
		var x = current_radius * cos(angle)
		var y = current_radius * sin(angle)
		points.append(Vector2(x, y))
	points.append(points[0]) # 闭合
	# 更新多边形
	polygon.set("polygon", points)
	polygon.set("color", color)
	collision_polygon.set("polygon", points)
	light_occluder.occluder.set_polygon(points)

func spawn_forest_and_plain():
	if not tree_scene or polygon.polygon.size() < 2:
		return
	# 清理旧树和平原/森林标记
	for child in get_children():
		if child.name.begins_with("PlanetTree_") or child.name.begins_with("SurfaceMark_"):
			child.queue_free()
	var points: Array = polygon.polygon
	var surface_len = 0.0
	for i in range(points.size()-1):
		surface_len += points[i].distance_to(points[i+1])
	# 自动按星球周长调整树数量
	var tree_count = int(surface_len * base_tree_density)
	if tree_count < 2:
		tree_count = 2
	# 随机森林起点
	var forest_start = random.randi_range(0, points.size()-1)
	var forest_span = int(points.size() * forest_ratio)
	# 标记森林和平原区域（可视化，仅装饰）
	var forest_indices = []
	for i in range(points.size()-1):
		var in_forest = (i >= forest_start and i < forest_start + forest_span) or ((forest_start + forest_span) > points.size()-1 and i < (forest_start + forest_span) % points.size())
		if visualization:
			var mark = ColorRect.new()
			mark.name = "SurfaceMark_%d" % i
			mark.color = forest_color if in_forest else plain_color
			# 用小圆点标记（或可换成Polygon2D）
			mark.size = Vector2(8,8)
			mark.position = points[i] - Vector2(4,4)
			mark.z_index = -5
			add_child(mark)
		if in_forest:
			forest_indices.append(i)
	# 在森林区域均匀分布树
	var tree_indices = []
	if forest_indices.size() > 0:
		var step = forest_indices.size() / float(tree_count)
		for n in range(tree_count):
			var idx = int(forest_indices[ int(n * step) % forest_indices.size() ])
			tree_indices.append(idx)
	else:
		# 极端情况全部是平原，树分布在整个表面
		var step = (points.size()-1) / float(tree_count)
		for n in range(tree_count):
			var idx = int(n * step)
			tree_indices.append(idx)
	for t in range(tree_indices.size()):
		var idx = tree_indices[t]
		var vertex = points[idx]
		var normal = (vertex).normalized()
		var tree_pos = vertex + normal * tree_offset
		var tree = tree_scene.instantiate()
		tree.name = "PlanetTree_%d" % t
		tree.position = tree_pos
		# 让树竖直于星球表面：法线方向+PI/2
		tree.rotation = normal.angle() + PI/2
		add_child(tree)

#func _draw():
	## 获取遮罩的多边形顶点
	#var occluder_shape = light_occluder.occluder
	#var vertices = occluder_shape.polygon
	## 绘制多边形
	#draw_colored_polygon(vertices, Color(1, 0, 0, 0.5))  # 半透明红色
