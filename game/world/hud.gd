class_name GameHud
extends CanvasLayer

signal save_pressed
signal name_submitted(save_name: String)
signal name_cancelled

const FLOPPY := "res://art/ui/save_floppy.png"
const CREAM := Color(0.95, 0.93, 0.86)
const _SAVE_DIM := Color(0.72, 0.7, 0.64)
const _SAVE_LIT := Color(1.45, 1.35, 1.1)
const PLATE_COLOR := Color(0.24, 0.36, 0.2, 1)

var _label: Label
var _shadow: Label
var _fade: ColorRect
var _pips: Array[ColorRect] = []
var _minimap: TextureRect
var _minimap_tex: ImageTexture
var _floppy: TextureButton
var _name_box: Control
var _name_line: LineEdit


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
	_shadow.size = Vector2(430, 140)
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
	_label.size = Vector2(430, 140)
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
	_build_floppy()


func _paint_hearts(supplies: Supplies) -> void:
	var slots := maxi(1, int(round(supplies.hearts_max)))
	_ensure_pips(slots * 2)
	if _fade != null:
		move_child(_fade, get_child_count() - 1)
	if _name_box != null and _name_box.visible:
		move_child(_name_box, get_child_count() - 1)
	if _floppy != null:
		move_child(_floppy, get_child_count() - 1)
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


func lines() -> String:
	if _label == null:
		return ""
	return _label.text


func is_naming() -> bool:
	return _name_box != null and _name_box.visible


func show_name_prompt() -> void:
	_ensure_name_box()
	_name_line.text = ""
	_name_box.visible = true
	move_child(_name_box, get_child_count() - 1)
	if _name_line.is_inside_tree():
		_name_line.grab_focus()


func hide_name_prompt() -> void:
	if _name_box == null:
		return
	_name_box.visible = false
	if _name_line != null and _name_line.is_inside_tree():
		_name_line.release_focus()


func _build_floppy() -> void:
	if _floppy != null:
		return
	_floppy = TextureButton.new()
	_floppy.name = "SaveFloppy"
	# The bars are only a few pixels wide. The clickable square is the whole corner,
	# including the gap, so a click on the mark still saves.
	_floppy.position = Vector2(448, 2)
	_floppy.custom_minimum_size = Vector2(28, 28)
	_floppy.size = Vector2(28, 28)
	_floppy.ignore_texture_size = true
	_floppy.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
	_floppy.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_floppy.focus_mode = Control.FOCUS_NONE
	_floppy.mouse_filter = Control.MOUSE_FILTER_STOP
	_floppy.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_floppy.modulate = _SAVE_DIM
	if ResourceLoader.exists(FLOPPY):
		var tex := load(FLOPPY) as Texture2D
		_floppy.texture_normal = tex
	_floppy.mouse_entered.connect(func() -> void: _floppy.modulate = _SAVE_LIT)
	_floppy.mouse_exited.connect(func() -> void: _floppy.modulate = _SAVE_DIM)
	_floppy.pressed.connect(func() -> void: save_pressed.emit())
	add_child(_floppy)
	_floppy.size = Vector2(28, 28)


func _ensure_name_box() -> void:
	if _name_box != null:
		return
	var box := Control.new()
	box.name = "SaveName"
	box.visible = false
	box.mouse_filter = Control.MOUSE_FILTER_STOP
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	var plate := Panel.new()
	plate.position = Vector2(100, 78)
	plate.size = Vector2(280, 108)
	plate.mouse_filter = Control.MOUSE_FILTER_STOP
	var plate_style := StyleBoxFlat.new()
	plate_style.bg_color = PLATE_COLOR
	plate_style.set_border_width_all(2)
	plate_style.border_color = Color(0.55, 0.66, 0.42, 1)
	plate.add_theme_stylebox_override("panel", plate_style)
	box.add_child(plate)
	var title := Label.new()
	title.text = "Enter save name."
	title.position = Vector2(112, 86)
	title.size = Vector2(256, 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.modulate = CREAM
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	title.add_theme_constant_override("outline_size", 4)
	box.add_child(title)
	_name_line = LineEdit.new()
	_name_line.position = Vector2(116, 112)
	_name_line.size = Vector2(248, 22)
	_name_line.max_length = ShoreSave.NAME_LIMIT
	_name_line.focus_mode = Control.FOCUS_ALL
	_name_line.add_theme_font_size_override("font_size", 12)
	_name_line.add_theme_color_override("font_color", CREAM)
	_name_line.text_submitted.connect(func(text: String) -> void: name_submitted.emit(text))
	box.add_child(_name_line)
	var save := Button.new()
	save.text = "Save"
	save.position = Vector2(196, 142)
	save.custom_minimum_size = Vector2(88, 22)
	save.focus_mode = Control.FOCUS_NONE
	save.add_theme_font_size_override("font_size", 12)
	save.add_theme_color_override("font_color", CREAM)
	save.add_theme_color_override("font_hover_color", CREAM)
	save.pressed.connect(func() -> void: name_submitted.emit(_name_line.text))
	box.add_child(save)
	box.set_process_unhandled_input(true)
	add_child(box)
	_name_box = box


func _input(event: InputEvent) -> void:
	if not is_naming():
		return
	if not event is InputEventKey:
		return
	var key := event as InputEventKey
	if not key.pressed or key.echo or key.keycode != KEY_ESCAPE:
		return
	name_cancelled.emit()
	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()
