class_name GameHud
extends CanvasLayer

signal save_pressed
signal name_submitted(save_name: String)
signal name_cancelled

const FLOPPY := "res://art/ui/save_floppy.png"
const SKILLS := "res://art/ui/skills.png"
const WOODCUTTING := "res://art/ui/skill_woodcutting.png"
const FIREMAKING := "res://art/ui/skill_firemaking.png"
const FORAGING := "res://art/ui/skill_foraging.png"
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
var _skills_btn: TextureButton
var _skills_shadow: ColorRect
var _skills_panel: Control
var _skill_icon: TextureRect
var _skill_level: Label
var _fire_icon: TextureRect
var _fire_level: Label
var _forage_icon: TextureRect
var _forage_level: Label
var _skill_hover: Label
var _hover_tip := ""
var _name_box: Control
var _name_line: LineEdit


func _ready() -> void:
	_build()


func show_play(world_seed: int, biome_name: String, supplies: Supplies, phase: String, hint: String, skills: Skills = null) -> void:
	if _label == null:
		_build()
	_paint_hearts(supplies)
	_paint_skills(skills)
	var cost := skills.fire_cost() if skills != null else Skills.FIRE_WOOD_START
	var eat := skills.eat_cost() if skills != null else Skills.EAT_FORAGE_START
	var body := status_text(world_seed, biome_name, supplies, phase, hint, cost, eat)
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


static func status_text(
	world_seed: int,
	biome_name: String,
	supplies: Supplies,
	phase: String,
	hint: String,
	fire_cost: float = -1.0,
	eat_cost: int = -1
) -> String:
	var cost := fire_cost if fire_cost >= 0.0 else Skills.FIRE_WOOD_START
	var eat := eat_cost if eat_cost >= 0 else Skills.EAT_FORAGE_START
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
		eat,
		Supplies.wood_label(cost),
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
	_build_skills()


func _paint_hearts(supplies: Supplies) -> void:
	var slots := maxi(1, int(round(supplies.hearts_max)))
	_ensure_pips(slots * 2)
	if _fade != null:
		move_child(_fade, get_child_count() - 1)
	if _name_box != null and _name_box.visible:
		move_child(_name_box, get_child_count() - 1)
	if _floppy != null:
		move_child(_floppy, get_child_count() - 1)
	if _skills_shadow != null:
		move_child(_skills_shadow, get_child_count() - 1)
	if _skills_btn != null:
		move_child(_skills_btn, get_child_count() - 1)
	if _skills_panel != null and _skills_panel.visible:
		move_child(_skills_panel, get_child_count() - 1)
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
	# The floppy mark is a 16×16 disc centered in this holder. The clickable square is
	# the whole 28×28 corner, so a click on the mark still saves.
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


func _build_skills() -> void:
	if _skills_btn != null:
		return
	# 3px right and bottom. The 32×32 tile used to draw past the 28×28 button and hide this.
	_skills_shadow = ColorRect.new()
	_skills_shadow.name = "SkillsMarkShadow"
	_skills_shadow.position = Vector2(416, 2)
	_skills_shadow.size = Vector2(31, 31)
	_skills_shadow.color = Color(0.0, 0.0, 0.0, 0.72)
	_skills_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_skills_shadow)
	_skills_btn = TextureButton.new()
	_skills_btn.name = "SkillsMark"
	_skills_btn.position = Vector2(416, 2)
	_skills_btn.custom_minimum_size = Vector2(28, 28)
	_skills_btn.size = Vector2(28, 28)
	_skills_btn.ignore_texture_size = true
	_skills_btn.stretch_mode = TextureButton.STRETCH_SCALE
	_skills_btn.clip_contents = true
	_skills_btn.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_skills_btn.focus_mode = Control.FOCUS_NONE
	_skills_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_skills_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_skills_btn.modulate = _SAVE_DIM
	if ResourceLoader.exists(SKILLS):
		_skills_btn.texture_normal = load(SKILLS) as Texture2D
	else:
		var mark := ColorRect.new()
		mark.size = Vector2(10, 10)
		mark.position = Vector2(9, 9)
		mark.color = Color(0.55, 0.5, 0.38)
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_skills_btn.add_child(mark)
	_skills_btn.mouse_entered.connect(func() -> void: _skills_btn.modulate = _SAVE_LIT)
	_skills_btn.mouse_exited.connect(func() -> void: _skills_btn.modulate = _SAVE_DIM)
	_skills_btn.pressed.connect(_toggle_skills)
	add_child(_skills_btn)
	_skills_btn.size = Vector2(28, 28)
	# Sit under the skills mark and the floppy (416–476). Skills stack down this column.
	_skills_panel = Panel.new()
	_skills_panel.name = "SkillsPanel"
	_skills_panel.visible = false
	_skills_panel.position = Vector2(382, 32)
	_skills_panel.size = Vector2(96, 58)
	_skills_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_skills_panel.mouse_default_cursor_shape = Control.CURSOR_ARROW
	var plate := StyleBoxFlat.new()
	plate.bg_color = PLATE_COLOR
	plate.set_border_width_all(1)
	plate.border_color = Color(0.55, 0.66, 0.42, 1)
	plate.content_margin_left = 2
	plate.content_margin_top = 2
	plate.content_margin_right = 2
	plate.content_margin_bottom = 2
	_skills_panel.add_theme_stylebox_override("panel", plate)
	_skill_icon = TextureRect.new()
	_skill_icon.name = "WoodcuttingIcon"
	_skill_icon.position = Vector2(2, 3)
	_skill_icon.size = Vector2(16, 16)
	_skill_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_skill_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_skill_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_skill_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(WOODCUTTING):
		_skill_icon.texture = load(WOODCUTTING) as Texture2D
	_skills_panel.add_child(_skill_icon)
	var name_label := Label.new()
	name_label.name = "WoodcuttingName"
	name_label.text = "Woodcutting"
	name_label.position = Vector2(18, 1)
	name_label.size = Vector2(58, 20)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.modulate = CREAM
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	name_label.add_theme_constant_override("outline_size", 2)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_skills_panel.add_child(name_label)
	_skill_level = Label.new()
	_skill_level.name = "WoodcuttingLevel"
	_skill_level.text = "1"
	_skill_level.position = Vector2(74, 1)
	_skill_level.size = Vector2(20, 20)
	_skill_level.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_skill_level.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_skill_level.modulate = CREAM
	_skill_level.add_theme_font_size_override("font_size", 10)
	_skill_level.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_skill_level.add_theme_constant_override("outline_size", 2)
	_skill_level.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_skills_panel.add_child(_skill_level)
	_fire_icon = TextureRect.new()
	_fire_icon.name = "FiremakingIcon"
	_fire_icon.position = Vector2(2, 21)
	_fire_icon.size = Vector2(16, 16)
	_fire_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_fire_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_fire_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_fire_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(FIREMAKING):
		_fire_icon.texture = load(FIREMAKING) as Texture2D
	_skills_panel.add_child(_fire_icon)
	var fire_name := Label.new()
	fire_name.name = "FiremakingName"
	fire_name.text = "Fire-making"
	fire_name.position = Vector2(18, 19)
	fire_name.size = Vector2(58, 20)
	fire_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fire_name.modulate = CREAM
	fire_name.add_theme_font_size_override("font_size", 10)
	fire_name.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	fire_name.add_theme_constant_override("outline_size", 2)
	fire_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_skills_panel.add_child(fire_name)
	_fire_level = Label.new()
	_fire_level.name = "FiremakingLevel"
	_fire_level.text = "1"
	_fire_level.position = Vector2(74, 19)
	_fire_level.size = Vector2(20, 20)
	_fire_level.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_fire_level.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_fire_level.modulate = CREAM
	_fire_level.add_theme_font_size_override("font_size", 10)
	_fire_level.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_fire_level.add_theme_constant_override("outline_size", 2)
	_fire_level.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_skills_panel.add_child(_fire_level)
	_forage_icon = TextureRect.new()
	_forage_icon.name = "ForagingIcon"
	_forage_icon.position = Vector2(2, 39)
	_forage_icon.size = Vector2(16, 16)
	_forage_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_forage_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_forage_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_forage_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(FORAGING):
		_forage_icon.texture = load(FORAGING) as Texture2D
	_skills_panel.add_child(_forage_icon)
	var forage_name := Label.new()
	forage_name.name = "ForagingName"
	forage_name.text = "Foraging"
	forage_name.position = Vector2(18, 37)
	forage_name.size = Vector2(58, 20)
	forage_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	forage_name.modulate = CREAM
	forage_name.add_theme_font_size_override("font_size", 10)
	forage_name.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	forage_name.add_theme_constant_override("outline_size", 2)
	forage_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_skills_panel.add_child(forage_name)
	_forage_level = Label.new()
	_forage_level.name = "ForagingLevel"
	_forage_level.text = "1"
	_forage_level.position = Vector2(74, 37)
	_forage_level.size = Vector2(20, 20)
	_forage_level.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_forage_level.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_forage_level.modulate = CREAM
	_forage_level.add_theme_font_size_override("font_size", 10)
	_forage_level.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_forage_level.add_theme_constant_override("outline_size", 2)
	_forage_level.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_skills_panel.add_child(_forage_level)
	add_child(_skills_panel)
	_skill_hover = Label.new()
	_skill_hover.name = "SkillHover"
	_skill_hover.visible = false
	_skill_hover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_skill_hover.modulate = CREAM
	_skill_hover.add_theme_font_size_override("font_size", 8)
	_skill_hover.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_skill_hover.add_theme_constant_override("outline_size", 2)
	_skill_hover.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_skill_hover.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color(0.05, 0.07, 0.04, 0.88)
	hover_style.set_content_margin_all(2)
	_skill_hover.add_theme_stylebox_override("normal", hover_style)
	add_child(_skill_hover)


func _process(_delta: float) -> void:
	_follow_skill_hover()


func _follow_skill_hover() -> void:
	if _skill_hover == null or _skills_panel == null:
		return
	if not _skills_panel.visible or is_naming():
		_skill_hover.visible = false
		return
	var mouse := get_viewport().get_mouse_position()
	var rect := _skills_panel.get_global_rect()
	if not rect.has_point(mouse):
		_skill_hover.visible = false
		return
	var local_y := mouse.y - rect.position.y
	var parts := _hover_tip.split("|")
	var idx := 0
	if parts.size() >= 3:
		var third := rect.size.y / 3.0
		if local_y >= third * 2.0:
			idx = 2
		elif local_y >= third:
			idx = 1
	elif parts.size() >= 2 and local_y >= rect.size.y * 0.5:
		idx = 1
	_skill_hover.text = parts[idx] if parts.size() > idx else _hover_tip
	_skill_hover.reset_size()
	place_skill_hover(mouse)


func place_skill_hover(mouse: Vector2) -> void:
	if _skill_hover == null:
		return
	_skill_hover.visible = true
	_skill_hover.reset_size()
	var size := _skill_hover.size
	if size.x < 8.0:
		size = Vector2(28, 12)
	var pos := Vector2(mouse.x - size.x * 0.5, mouse.y + 8.0)
	pos.x = clampf(pos.x, 2.0, 480.0 - size.x - 2.0)
	pos.y = clampf(pos.y, 2.0, 270.0 - size.y - 2.0)
	_skill_hover.position = pos
	move_child(_skill_hover, get_child_count() - 1)


func _toggle_skills() -> void:
	if _skills_panel == null:
		_build_skills()
	_skills_panel.visible = not _skills_panel.visible
	if _skills_panel.visible:
		move_child(_skills_panel, get_child_count() - 1)
	elif _skill_hover != null:
		_skill_hover.visible = false


func _paint_skills(skills: Skills) -> void:
	if _skills_panel == null:
		_build_skills()
	if skills == null:
		return
	_skill_level.text = str(skills.level())
	if _fire_level != null:
		_fire_level.text = str(skills.firemaking_level())
	if _forage_level != null:
		_forage_level.text = str(skills.forage_level())
	_hover_tip = "%s|%s|%s" % [
		skills.step_label(),
		skills.firemaking_step_label(),
		skills.forage_step_label(),
	]
	_skills_panel.tooltip_text = ""
	if _skill_hover != null:
		_skill_hover.text = skills.step_label()
		_skill_hover.reset_size()


func _ensure_name_box() -> void:
	if _name_box != null:
		return
	var box := Control.new()
	box.name = "SaveName"
	box.visible = false
	box.mouse_filter = Control.MOUSE_FILTER_STOP
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	var plate := Panel.new()
	plate.name = "SaveNamePlate"
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
	_name_line.name = "SaveNameField"
	_name_line.position = Vector2(116, 112)
	_name_line.custom_minimum_size = Vector2(248, 22)
	_name_line.size = Vector2(248, 22)
	_name_line.max_length = ShoreSave.NAME_LIMIT
	_name_line.focus_mode = Control.FOCUS_ALL
	_name_line.add_theme_font_size_override("font_size", 12)
	_name_line.add_theme_color_override("font_color", CREAM)
	_name_line.add_theme_color_override("font_placeholder_color", Color(CREAM.r, CREAM.g, CREAM.b, 0.45))
	var field_normal := _name_box_style(Color(CREAM.r, CREAM.g, CREAM.b, 0.35))
	var field_focus := _name_box_style(Color(CREAM.r, CREAM.g, CREAM.b, 0.9))
	_name_line.add_theme_stylebox_override("normal", field_normal)
	_name_line.add_theme_stylebox_override("focus", field_focus)
	_name_line.add_theme_stylebox_override("read_only", field_normal)
	_name_line.text_submitted.connect(func(text: String) -> void: name_submitted.emit(text))
	box.add_child(_name_line)
	var save := Button.new()
	save.name = "SaveNameConfirm"
	save.text = "Save"
	save.custom_minimum_size = Vector2(88, 22)
	save.size = Vector2(88, 22)
	save.focus_mode = Control.FOCUS_NONE
	save.add_theme_font_size_override("font_size", 12)
	save.add_theme_color_override("font_color", CREAM)
	save.add_theme_color_override("font_hover_color", CREAM)
	save.add_theme_color_override("font_pressed_color", CREAM)
	save.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	save.add_theme_constant_override("outline_size", 4)
	var save_normal := _name_box_style(Color(CREAM.r, CREAM.g, CREAM.b, 0.35))
	var save_lit := _name_box_style(Color(CREAM.r, CREAM.g, CREAM.b, 0.9))
	save.add_theme_stylebox_override("normal", save_normal)
	save.add_theme_stylebox_override("hover", save_lit)
	save.add_theme_stylebox_override("pressed", save_lit)
	save.add_theme_stylebox_override("focus", save_normal)
	# Keep at least 6px under the field. Center Save on the plate.
	save.position = Vector2(196, _name_line.position.y + _name_line.size.y + 6.0)
	var plate_bottom := save.position.y + save.size.y + 8.0
	if plate_bottom > plate.position.y + plate.size.y:
		plate.size.y = plate_bottom - plate.position.y
	save.pressed.connect(func() -> void: name_submitted.emit(_name_line.text))
	box.add_child(save)
	box.set_process_unhandled_input(true)
	add_child(box)
	_name_box = box


func _name_box_style(border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.07, 0.04, 0.78)
	style.set_border_width_all(1)
	style.border_color = border
	style.set_content_margin_all(2)
	return style


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
