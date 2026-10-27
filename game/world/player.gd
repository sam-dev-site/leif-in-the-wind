class_name Player
extends Node2D

const SPEED := 70.0

var world: World
var _body: ColorRect


func _ready() -> void:
	_body = ColorRect.new()
	_body.size = Vector2(10, 14)
	_body.position = Vector2(-5, -14)
	_body.color = Color(0.72, 0.42, 0.28)
	add_child(_body)
	var helm := ColorRect.new()
	helm.size = Vector2(10, 4)
	helm.position = Vector2(-5, -18)
	helm.color = Color(0.55, 0.55, 0.52)
	add_child(helm)


func _process(delta: float) -> void:
	var dir := _read_dir()
	if dir == Vector2.ZERO:
		return
	var next := global_position + dir * SPEED * delta
	if world != null and world.is_blocked_pixel(next):
		var slide_x := Vector2(next.x, global_position.y)
		var slide_y := Vector2(global_position.x, next.y)
		if not world.is_blocked_pixel(slide_x):
			global_position = slide_x
		elif not world.is_blocked_pixel(slide_y):
			global_position = slide_y
		return
	global_position = next


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
