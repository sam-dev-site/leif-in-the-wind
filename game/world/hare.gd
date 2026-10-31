class_name Hare
extends Node2D

## Arctic hare on the moss. Look, do not hunt.

const HOP_SPEED := 90.0
const FLEE_SPEED := 160.0
const WALK_SPOOK_TILES := 2.0
const JOG_SPOOK_TILES := 4.0
const TOWARD_DOT := 0.15
const ARRIVE := 2.0
const HOP_BURST := 0.55
const SIT_HOLD := 2.0
const SPRITE_SCALE := 0.5
const FEET_OFFSET_Y := -12.0
const HOP_FPS := 8.0
const FLEE_FPS := 14.0
const WALK_FRAME_COUNT := 4
const HARE_COUNT := 3
const MIN_SPREAD_TILES := 12

const DIR_NAMES := [
	"east", "south-east", "south", "south-west",
	"west", "north-west", "north", "north-east",
]

var world: World
var _facing := "south"
var _fleeing := false
var _sit_left := 0.0
var _hop_acc := 0.0
var _hop_target := Vector2.ZERO
var _hopping := false
var _hop_salt := 0
var _sprite: Sprite2D
var _frames: Dictionary = {}
var _walk: Dictionary = {}
var _walk_time := 0.0
var _chunk_key := Vector2i(9999, 9999)


func _ready() -> void:
	y_sort_enabled = true
	set_meta("kind", "hare")
	set_meta("species", "arctic_hare")
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


func setup_at(cell: Vector2i) -> void:
	_place_at(cell)
	_facing = "south"
	_sit_left = SIT_HOLD * 0.5
	_hopping = false
	_fleeing = false
	_apply_facing()


func is_fleeing() -> bool:
	return _fleeing


func is_sitting() -> bool:
	return _sit_left > 0.0 and not _fleeing and not _hopping


func hold_sit(seconds: float = SIT_HOLD) -> void:
	_sit_left = seconds
	_fleeing = false
	_hopping = false
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
	if should_spook(global_position, player_px, move_dir, jogging):
		_fleeing = true
		_sit_left = 0.0
		_hopping = false
	elif _fleeing:
		_fleeing = false
		_hop_acc = 0.0
		_sit_left = SIT_HOLD * 0.4
	if _fleeing:
		_run_away(delta, player_px)
		_notify_chunk()
		return
	if _sit_left > 0.0:
		_sit_left -= delta
		_walk_time = 0.0
		_apply_facing()
		return
	_hop_along(delta)
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


func _hop_along(delta: float) -> void:
	if not _hopping:
		_hop_target = _pick_hop_target()
		if _hop_target.distance_to(global_position) < 0.5:
			_sit_left = SIT_HOLD
			_walk_time = 0.0
			_apply_facing()
			return
		_hopping = true
		_hop_acc = 0.0
	_face_point(_hop_target)
	_step_toward(_hop_target, HOP_SPEED, delta)
	_walk_time += delta
	_hop_acc += delta
	_apply_facing()
	if global_position.distance_to(_hop_target) <= ARRIVE or _hop_acc >= HOP_BURST:
		_hopping = false
		_hop_acc = 0.0
		_sit_left = SIT_HOLD
		_walk_time = 0.0
		_apply_facing()


func _run_away(delta: float, leif: Vector2) -> void:
	var target := pick_away(global_position, leif, _neighbor_options(true))
	if target.distance_to(global_position) < 0.5:
		_walk_time = 0.0
		_apply_facing()
		return
	_face_point(target)
	_step_toward(target, FLEE_SPEED, delta)
	_walk_time += delta
	_apply_facing()


func _pick_hop_target() -> Vector2:
	var options := _neighbor_options(false)
	if options.is_empty():
		return global_position
	_hop_salt += 1
	return options[_hop_salt % options.size()]


func _neighbor_options(allow_trail: bool) -> Array[Vector2]:
	var options: Array[Vector2] = []
	var cell := ChunkGenerator.world_cell_at(global_position)
	var neighbors: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	for n in neighbors:
		var next := cell + n
		var px := ChunkGenerator.cell_center(next)
		if _blocked(px):
			continue
		if not allow_trail and world != null and world.is_trail_cell(next):
			continue
		options.append(px)
	if options.is_empty() and not allow_trail:
		return _neighbor_options(true)
	return options


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
	world.reparent_hare(self)


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
		var fps := FLEE_FPS if _fleeing else HOP_FPS
		var idx := int(_walk_time * fps) % steps.size()
		_sprite.texture = steps[idx]
		return
	if _frames.has(_facing):
		_sprite.texture = _frames[_facing]


func _load_frames() -> void:
	for name in DIR_NAMES:
		var idle_path := "res://art/coastal_north/hare/%s.png" % name
		if ResourceLoader.exists(idle_path):
			_frames[name] = load(idle_path) as Texture2D
		var steps: Array[Texture2D] = []
		for i in WALK_FRAME_COUNT:
			var step_path := "res://art/coastal_north/hare/walk/%s_%d.png" % [name, i]
			if ResourceLoader.exists(step_path):
				steps.append(load(step_path) as Texture2D)
		if not steps.is_empty():
			_walk[name] = steps


func _make_placeholder() -> void:
	var body := ColorRect.new()
	body.size = Vector2(8, 6)
	body.position = Vector2(-4, -9)
	body.color = Color(0.90, 0.88, 0.82)
	add_child(body)
	var ear_a := ColorRect.new()
	ear_a.size = Vector2(2, 5)
	ear_a.position = Vector2(-3, -13)
	ear_a.color = Color(0.86, 0.84, 0.78)
	add_child(ear_a)
	var ear_b := ColorRect.new()
	ear_b.size = Vector2(2, 5)
	ear_b.position = Vector2(1, -13)
	ear_b.color = Color(0.86, 0.84, 0.78)
	add_child(ear_b)
	var leg := ColorRect.new()
	leg.size = Vector2(3, 3)
	leg.position = Vector2(-1, -3)
	leg.color = Color(0.78, 0.76, 0.70)
	add_child(leg)
