class_name GameHud
extends CanvasLayer

var _label: Label
var _shadow: Label
var _pips: Array[ColorRect] = []


func _ready() -> void:
	_build()


func show_play(world_seed: int, biome_name: String, supplies: Supplies, phase: String, hint: String) -> void:
	if _label == null:
		_build()
	_ensure_pips(supplies.hearts_max)
	for i in _pips.size():
		var filled := i < supplies.hearts
		_pips[i].visible = i < supplies.hearts_max
		_pips[i].color = Color(0.75, 0.18, 0.16) if filled else Color(0.28, 0.16, 0.16)
	var body := status_text(world_seed, biome_name, supplies, phase, hint)
	_label.text = body
	_shadow.text = body


static func status_text(world_seed: int, biome_name: String, supplies: Supplies, phase: String, hint: String) -> String:
	var lines := (
		"hearts %d/%d   wood %d   forage %d   %s\n"
		+ "seed %d   %s\n"
		+ "Space pick or chop    F campfire (%d wood)    R new woods\n"
		+ "WASD walk    double-tap a key to jog\n"
		+ "Water behind you. The trail leads inland."
	) % [
		supplies.hearts,
		supplies.hearts_max,
		supplies.wood,
		supplies.forage,
		phase,
		world_seed,
		biome_name,
		Supplies.CAMPFIRE_WOOD,
	]
	if hint != "":
		lines += "\n" + hint
	return lines


func _build() -> void:
	if _label != null:
		return
	_shadow = Label.new()
	_shadow.position = Vector2(9, 19)
	_shadow.modulate = Color(0, 0, 0, 0.8)
	_shadow.add_theme_font_size_override("font_size", 12)
	_shadow.autowrap_mode = TextServer.AUTOWRAP_WORD
	_shadow.size = Vector2(464, 140)
	_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shadow.focus_mode = Control.FOCUS_NONE
	add_child(_shadow)
	_label = Label.new()
	_label.position = Vector2(8, 18)
	_label.modulate = Color(0.95, 0.93, 0.86)
	_label.add_theme_font_size_override("font_size", 12)
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_label.add_theme_constant_override("outline_size", 4)
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_label.size = Vector2(464, 140)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.focus_mode = Control.FOCUS_NONE
	add_child(_label)


func _ensure_pips(count: int) -> void:
	while _pips.size() < count:
		var pip := ColorRect.new()
		pip.size = Vector2(8, 8)
		pip.position = Vector2(8 + _pips.size() * 11, 6)
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pip.focus_mode = Control.FOCUS_NONE
		add_child(pip)
		_pips.append(pip)
