class_name Player
extends Node2D

const WALK_SPEED := 70.0
const RUN_SPEED := 100.0
## Second press of the same move key within this window, then hold, is a run.
const TAP_WINDOW_MSEC := 300
## PixelLab canvas is 64×64 with ~34×57 of Leif. Half-size keeps him ~2 tiles tall.
const SPRITE_SCALE := 0.5
const FEET_OFFSET_Y := -28.0
const WALK_FPS := 7.0
const JOG_FPS := 10.0
const WALK_FRAME_COUNT := 6

const DIR_NAMES := [
	"east", "south-east", "south", "south-west",
	"west", "north-west", "north", "north-east",
]

var world: World
var _sprite: Sprite2D
var _facing := "south"
var _frames: Dictionary = {}
var _walk: Dictionary = {}
var _walk_time := 0.0
var _run_keycode := 0
var _last_tap_keycode := 0
var _last_tap_msec := 0


func _ready() -> void:
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


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if key_event.echo or not _is_move_key(key_event.keycode):
		return
	if key_event.pressed:
		var now := Time.get_ticks_msec()
		if key_event.keycode == _last_tap_keycode and (now - _last_tap_msec) <= TAP_WINDOW_MSEC:
			_run_keycode = key_event.keycode
		_last_tap_keycode = key_event.keycode
		_last_tap_msec = now
	elif key_event.keycode == _run_keycode:
		_run_keycode = 0


func _process(delta: float) -> void:
	var dir := _read_dir()
	if dir == Vector2.ZERO:
		_walk_time = 0.0
		_apply_facing()
		return
	_walk_time += delta
	_face(dir)
	var speed := RUN_SPEED if _is_running() else WALK_SPEED
	var next := global_position + dir * speed * delta
	if world != null and world.is_blocked_pixel(next):
		var slide_x := Vector2(next.x, global_position.y)
		var slide_y := Vector2(global_position.x, next.y)
		if not world.is_blocked_pixel(slide_x):
			global_position = slide_x
		elif not world.is_blocked_pixel(slide_y):
			global_position = slide_y
		return
	global_position = next


func facing_name() -> String:
	return _facing


func is_jogging() -> bool:
	return _is_running()


func _is_running() -> bool:
	return _run_keycode != 0 and Input.is_key_pressed(_run_keycode)


func _is_move_key(code: Key) -> bool:
	return code == KEY_W or code == KEY_A or code == KEY_S or code == KEY_D \
		or code == KEY_LEFT or code == KEY_RIGHT or code == KEY_UP or code == KEY_DOWN


func _make_placeholder() -> void:
	var body := ColorRect.new()
	body.size = Vector2(10, 14)
	body.position = Vector2(-5, -14)
	body.color = Color(0.72, 0.42, 0.28)
	add_child(body)
	var helm := ColorRect.new()
	helm.size = Vector2(10, 4)
	helm.position = Vector2(-5, -18)
	helm.color = Color(0.55, 0.55, 0.52)
	add_child(helm)


func _load_frames() -> void:
	for name in DIR_NAMES:
		var path := "res://art/leif/%s.png" % name
		if ResourceLoader.exists(path):
			_frames[name] = load(path) as Texture2D
		var steps: Array[Texture2D] = []
		for i in WALK_FRAME_COUNT:
			var step_path := "res://art/leif/walk/%s_%d.png" % [name, i]
			if ResourceLoader.exists(step_path):
				steps.append(load(step_path) as Texture2D)
		if not steps.is_empty():
			_walk[name] = steps


func _face(dir: Vector2) -> void:
	var octant := int(round(dir.angle() / (PI / 4.0)))
	if octant < 0:
		octant += 8
	_facing = DIR_NAMES[octant]
	_apply_facing()


func _apply_facing() -> void:
	if _sprite == null:
		return
	if _walk.has(_facing) and _walk_time > 0.0:
		var steps: Array = _walk[_facing]
		var fps := JOG_FPS if _is_running() else WALK_FPS
		var idx := int(_walk_time * fps) % steps.size()
		_sprite.texture = steps[idx]
		return
	if _frames.has(_facing):
		_sprite.texture = _frames[_facing]


func _read_dir() -> Vector2:
	var x := 0.0
	var y := 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		y += 1.0
	return Vector2(x, y).normalized()
