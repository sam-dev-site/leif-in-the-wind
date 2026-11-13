class_name Deer
extends Node2D

## One white-tailed deer on the intervale trail. Look, do not hunt.

const WALK_SPEED := 40.0
const ARRIVE := 2.0
const WALK_BURST := 4.0
const GRAZE_HOLD := 3.5

var world: World
var path: Array[Vector2i] = []
var path_index := 0
var travel_dir := 1
var _facing := "north"
var _fleeing := false
var _graze_left := 0.0
var _walk_acc := 0.0


func _ready() -> void:
	y_sort_enabled = true
	set_meta("kind", "deer")
	set_meta("species", "white_tailed_deer")
	var body := ColorRect.new()
	body.size = Vector2(10, 6)
	body.position = Vector2(-5, -8)
	body.color = Color(0.45, 0.32, 0.18)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(body)


func setup(trail: Array[Vector2i], start_index: int, start_dir: int = 1) -> void:
	path = trail
	if path.is_empty():
		return
	path_index = clampi(start_index, 0, path.size() - 1)
	travel_dir = 1 if start_dir >= 0 else -1
	global_position = ChunkGenerator.cell_center(path[path_index])
	_facing = "north" if travel_dir > 0 else "south"


func is_fleeing() -> bool:
	return _fleeing


func is_grazing() -> bool:
	return _graze_left > 0.0 and not _fleeing


func facing_name() -> String:
	return _facing


func hold_graze(seconds: float = GRAZE_HOLD) -> void:
	_graze_left = seconds
	_fleeing = false


func tick_with(delta: float, player_px: Vector2, move_dir: Vector2, jogging: bool) -> void:
	if path.is_empty():
		return
	if Caribou.should_spook(global_position, player_px, move_dir, jogging):
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
		return
	_walk_along(delta)
	_notify_chunk()


func _process(delta: float) -> void:
	if world == null or not is_inside_tree():
		return
	if world.is_sleeping() or world.is_naming() or world.is_quit_ask():
		return
	var leif := world.leif()
	if leif == null or not is_instance_valid(leif):
		return
	tick_with(delta, leif.global_position, leif.move_vector(), leif.is_jogging())


func _walk_along(delta: float) -> void:
	_walk_acc += delta
	if _walk_acc < WALK_BURST:
		var goal := ChunkGenerator.cell_center(path[path_index])
		if global_position.distance_to(goal) > ARRIVE:
			_step_toward(goal, WALK_SPEED, delta)
		return
	_walk_acc = 0.0
	var next := path_index + travel_dir
	if next < 0 or next >= path.size():
		travel_dir *= -1
		_graze_left = GRAZE_HOLD
		return
	path_index = next
	_step_toward(ChunkGenerator.cell_center(path[path_index]), WALK_SPEED, delta)


func _run_away(delta: float, leif: Vector2) -> void:
	var cell := ChunkGenerator.world_cell_at(global_position)
	var options: Array[Vector2] = []
	for n in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
		var px := ChunkGenerator.cell_center(cell + n)
		if world != null and world.is_blocked_pixel(px, self):
			continue
		options.append(px)
	var away := Caribou.pick_away(global_position, leif, options)
	_step_toward(away, Caribou.FLEE_SPEED, delta)


func _step_toward(target: Vector2, speed: float, delta: float) -> void:
	var offset := target - global_position
	if offset.length() <= ARRIVE:
		return
	var next := global_position + offset.normalized() * speed * delta
	if world != null and world.is_blocked_pixel(next, self):
		return
	global_position = next
	if offset.y < 0.0:
		_facing = "north"
	elif offset.y > 0.0:
		_facing = "south"


func _notify_chunk() -> void:
	if world != null:
		world.reparent_deer()
