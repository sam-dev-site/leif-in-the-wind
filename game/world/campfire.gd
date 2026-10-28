class_name Campfire
extends Node2D

## A lit fire built from carried wood. The warm pool is the night light.
## Colored boxes until the art lane replaces them. Not a species.

const LIGHT_COLOR := Color(1.0, 0.68, 0.32)
const LIGHT_SCALE := 2.4
const NIGHT_ENERGY := 1.45

signal expired

var lit: bool = true
var lifetime := DayClock.cold_seconds()
var burn_left := DayClock.cold_seconds()

var _built := false
var _flame: ColorRect
var _core: ColorRect
var _flicker := 0.0


static func try_place(supplies: Supplies, tile_blocked: bool, occupied: bool) -> bool:
	if supplies == null or tile_blocked or occupied:
		return false
	return supplies.try_spend_wood(Supplies.CAMPFIRE_WOOD)


func _ready() -> void:
	build_visual()


func _process(delta: float) -> void:
	if consume(delta):
		return
	if _flame != null:
		_flicker += delta
		_flame.position.y = -8.0 + sin(_flicker * 9.0) * 0.6
	set_darkness(DayClock.darkness_now)


## One night of wood. Sleeping the night away spends the same time.
func consume(seconds: float) -> bool:
	if not lit or seconds <= 0.0:
		return false
	burn_left = maxf(0.0, burn_left - seconds)
	_refresh_flame()
	if burn_left > 0.0:
		return false
	lit = false
	expired.emit()
	return true


func fuel() -> float:
	if lifetime <= 0.0:
		return 0.0
	return clampf(burn_left / lifetime, 0.0, 1.0)


## Full day keeps the pixel flame only. The warm pool fades in with dusk.
func set_darkness(amount: float) -> void:
	var light := warm_light()
	if light == null:
		return
	var dark := clampf(amount, 0.0, 1.0)
	var fade := _fuel_fade()
	light.energy = NIGHT_ENERGY * dark * fade
	light.enabled = dark > 0.02 and fade > 0.02


func _fuel_fade() -> float:
	var left := fuel()
	if left >= 0.25:
		return 1.0
	return clampf(left / 0.25, 0.0, 1.0)


func _refresh_flame() -> void:
	var fade := _fuel_fade()
	if _flame != null:
		_flame.modulate.a = fade
	if _core != null:
		_core.modulate.a = fade


func build_visual() -> void:
	if _built:
		return
	_built = true
	y_sort_enabled = true
	set_meta("kind", "campfire")
	var stones := ColorRect.new()
	stones.size = Vector2(10, 4)
	stones.position = Vector2(-5, -3)
	stones.color = Color(0.45, 0.42, 0.38)
	stones.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stones)
	_flame = ColorRect.new()
	_flame.size = Vector2(4, 6)
	_flame.position = Vector2(-2, -8)
	_flame.color = Color(0.93, 0.48, 0.14)
	_flame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flame)
	_core = ColorRect.new()
	_core.size = Vector2(2, 3)
	_core.position = Vector2(-1, -6)
	_core.color = Color(1.0, 0.86, 0.42)
	_core.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_core)
	var light := PointLight2D.new()
	light.color = LIGHT_COLOR
	light.energy = 0.0
	light.enabled = false
	light.blend_mode = Light2D.BLEND_MODE_ADD
	light.texture = _radial_texture()
	light.texture_scale = LIGHT_SCALE
	light.position = Vector2(0, -6)
	light.shadow_enabled = false
	add_child(light)


func warm_light() -> PointLight2D:
	for child in get_children():
		if child is PointLight2D:
			return child as PointLight2D
	return null


func _radial_texture() -> Texture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.set_offset(0, 0.15)
	gradient.set_color(1, Color(1, 1, 1, 0))
	gradient.set_offset(1, 1.0)
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 64
	tex.height = 64
	return tex
