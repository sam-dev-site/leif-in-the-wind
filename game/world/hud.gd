class_name GameHud
extends CanvasLayer

var _label: Label
var _shadow: Label
var _fade: ColorRect
var _pips: Array[ColorRect] = []
var _minimap: TextureRect
var _minimap_tex: ImageTexture


func _ready() -> void:
	_build()


func show_play(world_seed: int, biome_name: String, supplies: Supplies, phase: String, hint: String) -> void:
	if _label == null:
		_build()
	_paint_hearts(supplies)
	var body := status_text(world_seed, biome_name, supplies, phase, hint)
	_label.text = body
	_shadow.text = body


func set_fade(alpha: float) -> void:
	if _fade == null:
		_build()
	_fade.color.a = clampf(alpha, 0.0, 1.0)


func show_minimap(img: Image) -> void:
	if img == null:
		return
	if _minimap == null:
		_build()
	if _minimap_tex == null:
		_minimap_tex = ImageTexture.create_from_image(img)
	else:
		_minimap_tex.update(img)
	_minimap.texture = _minimap_tex


static func status_text(world_seed: int, biome_name: String, supplies: Supplies, phase: String, hint: String) -> String:
	var lines := (
		"hearts %s/%s   wood %s   forage %d   %s\n"
		+ "seed %d   %s\n"
		+ "Space pick, chop, or clear    E eat (%d forage)    F campfire (%s wood)    C sleep    R new woods\n"
		+ "WASD walk    double-tap a key to jog\n"
		+ "Water behind you. The trail leads inland."
	) % [
		Supplies.wood_label(supplies.hearts),
		Supplies.wood_label(supplies.hearts_max),
		Supplies.wood_label(supplies.wood),
		supplies.forage,
		phase,
		world_seed,
		biome_name,
		Supplies.EAT_FORAGE,
		Supplies.wood_label(Supplies.CAMPFIRE_WOOD),
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
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.size = Vector2(480, 270)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.focus_mode = Control.FOCUS_NONE
	add_child(_fade)
	_build_minimap()


func _paint_hearts(supplies: Supplies) -> void:
	var slots := maxi(1, int(round(supplies.hearts_max)))
	_ensure_pips(slots * 2)
	if _fade != null:
		move_child(_fade, get_child_count() - 1)
	var on := Color(0.75, 0.18, 0.16)
	var off := Color(0.28, 0.16, 0.16)
	for i in _pips.size():
		var heart_i := int(i / 2)
		var half := float(i % 2) * 0.5
		_pips[i].visible = heart_i < slots
		_pips[i].color = on if supplies.hearts + 0.001 >= float(heart_i) + 0.5 + half else off


func _ensure_pips(count: int) -> void:
	while _pips.size() < count:
		var pip := ColorRect.new()
		var i := _pips.size()
		var heart_i := int(i / 2)
		var half_i := i % 2
		pip.size = Vector2(4, 8)
		pip.position = Vector2(8 + heart_i * 12 + half_i * 5, 6)
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pip.focus_mode = Control.FOCUS_NONE
		add_child(pip)
		_pips.append(pip)


func _build_minimap() -> void:
	if _minimap != null:
		return
	_minimap = TextureRect.new()
	_minimap.position = Vector2(4, 270 - FogMap.VIEW - 4)
	_minimap.size = Vector2(FogMap.VIEW, FogMap.VIEW)
	_minimap.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_minimap.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_minimap.stretch_mode = TextureRect.STRETCH_KEEP
	_minimap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_minimap.focus_mode = Control.FOCUS_NONE
	add_child(_minimap)
