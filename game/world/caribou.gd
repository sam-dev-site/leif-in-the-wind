class_name Caribou
extends Node2D

## One woodland caribou on the coastal trail. Look, do not hunt.

const WALK_SPEED := 40.0
const FLEE_SPEED := 130.0
const WALK_SPOOK_TILES := 2.0
const JOG_SPOOK_TILES := 4.0
const TOWARD_DOT := 0.15
const ARRIVE := 2.0
const WALK_BURST := 4.0
const GRAZE_HOLD := 3.5
const SPRITE_SCALE := 0.5
const FEET_OFFSET_Y := -24.0
const WALK_FPS := 6.0
const FLEE_FPS := 12.0
const WALK_FRAME_COUNT := 8

const DIR_NAMES := [
	"east", "south-east", "south", "south-west",
	"west", "north-west", "north", "north-east",
]

var world: World
var path: Array[Vector2i] = []
var path_index := 0
var travel_dir := 1
var _facing := "north"
var _fleeing := false
var _graze_left := 0.0
var _walk_acc := 0.0
var _sprite: Sprite2D
var _frames: Dictionary = {}
var _walk: Dictionary = {}
var _walk_time := 0.0
var _chunk_key := Vector2i(9999, 9999)


func _ready() -> void:
	y_sort_enabled = true
	set_meta("kind", "caribou")
	set_meta("species", "caribou")
	_load_frames()
	if _frames.is_empty():
		_make_placeholder()
		return
	_sprite = Sprite2D.new()
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.centered = true
	_sprite.offset = Vector2(0, FEET_OFFSET_Y)
	_sprite.scale = Vector2(SPRITE_SCALE, SPRITE_SCALE)
	add_child(_sprite)
	_apply_facing()


func setup(trail: Array[Vector2i], start_index: int, start_dir: int = 1) -> void:
	path = trail
	if path.is_empty():
		return
	path_index = clampi(start_index, 0, path.size() - 1)
	travel_dir = 1 if start_dir >= 0 else -1
	_place_at(path[path_index])
	_facing = "north" if travel_dir > 0 else "south"
	_apply_facing()


func is_fleeing() -> bool:
	return _fleeing


func is_grazing() -> bool:
	return _graze_left > 0.0 and not _fleeing


func hold_graze(seconds: float = GRAZE_HOLD) -> void:
	_graze_left = seconds
	_fleeing = false
	_walk_time = 0.0
	_apply_facing()


func facing_name() -> String:
	return _facing


func set_facing(dir_name: String) -> void:
	if not DIR_NAMES.has(dir_name):
		dir_name = "south"
	_facing = dir_name
	_apply_facing()


static func spook_range_tiles(jogging: bool) -> float:
	return JOG_SPOOK_TILES if jogging else WALK_SPOOK_TILES


static func should_spook(self_px: Vector2, player_px: Vector2, move_dir: Vector2, jogging: bool) -> bool:
	if move_dir.length() < 0.01:
		return false
	var to_self := self_px - player_px
	var dist_tiles := to_self.length() / float(ChunkGenerator.TILE)
	if dist_tiles > spook_range_tiles(jogging):
		return false
	if to_self.length() < 0.01:
		return true
	return move_dir.normalized().dot(to_self.normalized()) > TOWARD_DOT


static func pick_away(from: Vector2, leif: Vector2, options: Array[Vector2]) -> Vector2:
	if options.is_empty():
		return from
	var best := options[0]
	var best_d := best.distance_squared_to(leif)
	for i in range(1, options.size()):
		var option := options[i]
		var d := option.distance_squared_to(leif)
		if d > best_d:
			best = option
			best_d = d
	return best


func tick_with(delta: float, player_px: Vector2, move_dir: Vector2, jogging: bool) -> void:
	if path.is_empty():
		return
	if should_spook(global_position, player_px, move_dir, jogging):
		_fleeing = true
		_graze_left = 0.0
	elif _fleeing:
		_fleeing = false
		_walk_acc = 0.0
	if _fleeing:
		_run_away(delta, player_px)
		_notify_chunk()
		return
	if _graze_left > 0.0:
		_graze_left -= delta
		_walk_time = 0.0
		_apply_facing()
		return
	_walk_along(delta)
	_notify_chunk()


func _process(delta: float) -> void:
	if world == null:
		return
	if world.is_sleeping() or world.is_naming() or world.is_quit_ask():
		_walk_time = 0.0
		_apply_facing()
		return
	var leif := world.leif()
	var player_px := global_position
	var move_dir := Vector2.ZERO
	var jogging := false
	if leif != null and is_instance_valid(leif):
		player_px = leif.global_position
		move_dir = leif.move_vector()
		jogging = leif.is_jogging()
	tick_with(delta, player_px, move_dir, jogging)


func _walk_along(delta: float) -> void:
	var target := _patrol_target()
	_face_point(target)
	_step_toward(target, WALK_SPEED, delta)
	_walk_time += delta
	_walk_acc += delta
	_apply_facing()
	if global_position.distance_to(target) <= ARRIVE:
		_snap_index_at(target)
	if _walk_acc >= WALK_BURST:
		_walk_acc = 0.0
		_graze_left = GRAZE_HOLD
		_walk_time = 0.0
		_apply_facing()


func _run_away(delta: float, leif: Vector2) -> void:
	var target := pick_away(global_position, leif, _flee_options())
	if target.distance_to(_path_step(1)) < 1.0:
		travel_dir = 1
	elif target.distance_to(_path_step(-1)) < 1.0:
		travel_dir = -1
	if target.distance_to(global_position) < 0.5:
		_walk_time = 0.0
		_apply_facing()
		return
	_face_point(target)
	_step_toward(target, FLEE_SPEED, delta)
	_walk_time += delta
	_apply_facing()
	_snap_index_at(target)


func _patrol_target() -> Vector2:
	var next_i := path_index + travel_dir
	if next_i < 0 or next_i >= path.size():
		travel_dir *= -1
		next_i = path_index + travel_dir
	if next_i < 0 or next_i >= path.size():
		return global_position
	var px := ChunkGenerator.cell_center(path[next_i])
	if _blocked(px):
		var detour := _detour_toward(px)
		if detour == global_position:
			travel_dir *= -1
			return global_position
		return detour
	return px


func _flee_options() -> Array[Vector2]:
	var options: Array[Vector2] = []
	_add_open(options, _path_step(1))
	_add_open(options, _path_step(-1))
	var cell := ChunkGenerator.world_cell_at(global_position)
	var neighbors: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	for n in neighbors:
		_add_open(options, ChunkGenerator.cell_center(cell + n))
	return options


func _path_step(dir: int) -> Vector2:
	var i := path_index + dir
	if i < 0 or i >= path.size():
		return global_position
	return ChunkGenerator.cell_center(path[i])


func _add_open(options: Array[Vector2], px: Vector2) -> void:
	if px.distance_to(global_position) < 0.5:
		return
	if _blocked(px):
		return
	options.append(px)


func _detour_toward(goal: Vector2) -> Vector2:
	var cell := ChunkGenerator.world_cell_at(global_position)
	var options: Array[Vector2] = []
	var neighbors: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	for n in neighbors:
		var px := ChunkGenerator.cell_center(cell + n)
		if not _blocked(px):
			options.append(px)
	if options.is_empty():
		return global_position
	var best := options[0]
	var best_d := best.distance_squared_to(goal)
	for i in range(1, options.size()):
		var d := options[i].distance_squared_to(goal)
		if d < best_d:
			best = options[i]
			best_d = d
	return best


func _step_toward(target: Vector2, speed: float, delta: float) -> void:
	var offset := target - global_position
	if offset.length() <= ARRIVE:
		return
	var next := global_position + offset.normalized() * speed * delta
	if _blocked(next):
		var slide_x := Vector2(next.x, global_position.y)
		var slide_y := Vector2(global_position.x, next.y)
		if not _blocked(slide_x):
			global_position = slide_x
		elif not _blocked(slide_y):
			global_position = slide_y
	else:
		global_position = next


func _blocked(px: Vector2) -> bool:
	if world == null:
		return false
	return world.is_blocked_pixel(px, self)


func _snap_index_at(px: Vector2) -> void:
	if global_position.distance_to(px) > ARRIVE * 2.0:
		_snap_nearest()
		return
	var cell := ChunkGenerator.world_cell_at(px)
	for i in path.size():
		if path[i] == cell:
			path_index = i
			return
	_snap_nearest()


func _snap_nearest() -> void:
	if path.is_empty():
		return
	var best_i := path_index
	var best_d := INF
	for i in path.size():
		var d := ChunkGenerator.cell_center(path[i]).distance_squared_to(global_position)
		if d < best_d:
			best_d = d
			best_i = i
	path_index = best_i


func _place_at(cell: Vector2i) -> void:
	var keep := ChunkGenerator.cell_center(cell)
	if is_inside_tree():
		global_position = keep
	else:
		position = keep


func _notify_chunk() -> void:
	if world == null:
		return
	var key := ChunkGenerator.chunk_of_cell(ChunkGenerator.world_cell_at(global_position))
	if key == _chunk_key:
		return
	_chunk_key = key
	world.reparent_caribou()


func _face_point(target: Vector2) -> void:
	var dir := target - global_position
	if dir.length() < 0.5:
		return
	var octant := int(round(dir.angle() / (PI / 4.0)))
	if octant < 0:
		octant += 8
	_facing = DIR_NAMES[octant]


func _apply_facing() -> void:
	if _sprite == null:
		return
	if _walk.has(_facing) and _walk_time > 0.0:
		var steps: Array = _walk[_facing]
		var fps := FLEE_FPS if _fleeing else WALK_FPS
		var idx := int(_walk_time * fps) % steps.size()
		_sprite.texture = steps[idx]
		return
	if _frames.has(_facing):
		_sprite.texture = _frames[_facing]


func _load_frames() -> void:
	for name in DIR_NAMES:
		var idle_path := "res://art/coastal_north/caribou/%s.png" % name
		if ResourceLoader.exists(idle_path):
			_frames[name] = load(idle_path) as Texture2D
		var steps: Array[Texture2D] = []
		for i in WALK_FRAME_COUNT:
			var step_path := "res://art/coastal_north/caribou/walk/%s_%d.png" % [name, i]
			if ResourceLoader.exists(step_path):
				steps.append(load(step_path) as Texture2D)
		if not steps.is_empty():
			_walk[name] = steps


func _make_placeholder() -> void:
	var body := ColorRect.new()
	body.size = Vector2(14, 10)
	body.position = Vector2(-7, -14)
	body.color = Color(0.52, 0.40, 0.26)
	add_child(body)
	var ruff := ColorRect.new()
	ruff.size = Vector2(8, 5)
	ruff.position = Vector2(-4, -18)
	ruff.color = Color(0.72, 0.64, 0.50)
	add_child(ruff)
	var leg_a := ColorRect.new()
	leg_a.size = Vector2(3, 5)
	leg_a.position = Vector2(-6, -4)
	leg_a.color = Color(0.32, 0.22, 0.14)
	add_child(leg_a)
	var leg_b := ColorRect.new()
	leg_b.size = Vector2(3, 5)
	leg_b.position = Vector2(3, -4)
	leg_b.color = Color(0.32, 0.22, 0.14)
	add_child(leg_b)
