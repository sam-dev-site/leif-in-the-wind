class_name AdminPanel
extends Control

## Title-only QC overlay. Knobs are a data list so a later one is one more entry.

const PLATE_COLOR := Color(0.24, 0.36, 0.2, 1)
const CREAM := Color(0.95, 0.93, 0.86)
const BORDER := Color(0.55, 0.66, 0.42, 1)
const PANEL_W := 400.0
const PANEL_H := 230.0
const VIEW_W := 480.0
const VIEW_H := 270.0

## Each row: label, AdminSettings field, min, max, step, is_int
const KNOBS: Array = [
	{"label": "Day length (s)", "field": "day_seconds", "min": 15.0, "max": 180.0, "step": 1.0, "int": false},
	{"label": "Night length (s)", "field": "night_seconds", "min": 10.0, "max": 180.0, "step": 1.0, "int": false},
	{"label": "Hearts", "field": "hearts", "min": 1.0, "max": 10.0, "step": 1.0, "int": true},
	{"label": "XP curve", "field": "xp_scale", "min": 0.25, "max": 2.0, "step": 0.05, "int": false},
	{"label": "Foliage / ground stuff (%)", "field": "foliage_percent", "min": AdminSettings.FOLIAGE_MIN, "max": AdminSettings.FOLIAGE_MAX, "step": 1.0, "int": true},
	{"label": "Walk", "field": "walk_speed", "min": 30.0, "max": 150.0, "step": 1.0, "int": false},
	{"label": "Run", "field": "run_speed", "min": 40.0, "max": 200.0, "step": 1.0, "int": false},
]

signal closed

var _built := false
var _path_label: Label
var _xp_hint: Label
var _sliders: Dictionary = {}
var _value_labels: Dictionary = {}


func _ready() -> void:
	assemble()


func assemble() -> void:
	if _built:
		return
	_built = true
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 20
	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.35)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	var plate := Panel.new()
	plate.name = "Plate"
	plate.position = Vector2((VIEW_W - PANEL_W) / 2.0, (VIEW_H - PANEL_H) / 2.0)
	plate.size = Vector2(PANEL_W, PANEL_H)
	var style := StyleBoxFlat.new()
	style.bg_color = PLATE_COLOR
	style.set_border_width_all(2)
	style.border_color = BORDER
	plate.add_theme_stylebox_override("panel", style)
	plate.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(plate)
	var title := Label.new()
	title.name = "Title"
	title.text = "Admin"
	title.position = Vector2(12, 6)
	title.size = Vector2(PANEL_W - 24, 18)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.modulate = CREAM
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	title.add_theme_constant_override("outline_size", 4)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(title)
	var y := 26.0
	for knob in KNOBS:
		y = _add_row(plate, knob, y)
	_xp_hint = Label.new()
	_xp_hint.name = "XpHint"
	_xp_hint.position = Vector2(12, y)
	_xp_hint.size = Vector2(PANEL_W - 24, 14)
	_xp_hint.modulate = CREAM
	_xp_hint.add_theme_font_size_override("font_size", 9)
	_xp_hint.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_xp_hint.add_theme_constant_override("outline_size", 3)
	_xp_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(_xp_hint)
	y += 16.0
	_path_label = Label.new()
	_path_label.name = "PathLabel"
	_path_label.position = Vector2(12, y)
	_path_label.size = Vector2(PANEL_W - 24, 20)
	_path_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_path_label.modulate = CREAM
	_path_label.add_theme_font_size_override("font_size", 8)
	_path_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_path_label.add_theme_constant_override("outline_size", 3)
	_path_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(_path_label)
	var row := HBoxContainer.new()
	row.name = "Buttons"
	row.position = Vector2(12, PANEL_H - 28)
	row.size = Vector2(PANEL_W - 24, 22)
	row.add_theme_constant_override("separation", 6)
	plate.add_child(row)
	row.add_child(_make_button("Save", _on_save))
	row.add_child(_make_button("Reset", _on_reset))
	row.add_child(_make_button("Close", close_panel))
	_sync_from_settings()


func is_open() -> bool:
	return visible


func open_panel() -> void:
	assemble()
	visible = true
	_sync_from_settings()
	_path_label.text = ""


func close_panel() -> void:
	visible = false
	closed.emit()


func _add_row(plate: Panel, knob: Dictionary, y: float) -> float:
	var field: String = str(knob["field"])
	var label := Label.new()
	label.text = str(knob["label"])
	label.position = Vector2(12, y)
	label.size = Vector2(150, 14)
	label.modulate = CREAM
	label.add_theme_font_size_override("font_size", 9)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("outline_size", 3)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(label)
	var slider := HSlider.new()
	slider.name = "Slider_%s" % field
	slider.min_value = float(knob["min"])
	slider.max_value = float(knob["max"])
	slider.step = float(knob["step"])
	slider.position = Vector2(164, y)
	slider.size = Vector2(170, 14)
	slider.focus_mode = Control.FOCUS_NONE
	_connect_knob(slider, field, bool(knob["int"]))
	plate.add_child(slider)
	_sliders[field] = slider
	var value := Label.new()
	value.name = "Value_%s" % field
	value.position = Vector2(340, y)
	value.size = Vector2(48, 14)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.modulate = CREAM
	value.add_theme_font_size_override("font_size", 9)
	value.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	value.add_theme_constant_override("outline_size", 3)
	value.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(value)
	_value_labels[field] = value
	return y + 18.0


func _connect_knob(slider: HSlider, field: String, as_int: bool) -> void:
	slider.value_changed.connect(func(value: float) -> void:
		_on_slider(value, field, as_int)
	)


func _on_slider(value: float, field: String, as_int: bool) -> void:
	match field:
		"day_seconds":
			AdminSettings.day_seconds = value
		"night_seconds":
			AdminSettings.night_seconds = value
		"hearts":
			AdminSettings.hearts = int(round(value))
		"xp_scale":
			AdminSettings.xp_scale = value
		"foliage_percent":
			AdminSettings.foliage_percent = int(round(value))
		"walk_speed":
			AdminSettings.walk_speed = value
			if AdminSettings.run_speed < AdminSettings.walk_speed:
				AdminSettings.run_speed = AdminSettings.walk_speed
				_set_slider("run_speed", AdminSettings.run_speed, false)
		"run_speed":
			AdminSettings.run_speed = value
			if AdminSettings.run_speed < AdminSettings.walk_speed:
				AdminSettings.run_speed = AdminSettings.walk_speed
				_set_slider("run_speed", AdminSettings.run_speed, false)
	AdminSettings.clamp_live()
	_paint_value(field, as_int)
	_paint_xp_hint()


func _on_save() -> void:
	if AdminSettings.save_file():
		_path_label.text = AdminSettings.absolute_path()
	else:
		_path_label.text = "Save failed."


func _on_reset() -> void:
	AdminSettings.reset_to_defaults()
	_sync_from_settings()
	_path_label.text = ""


func _sync_from_settings() -> void:
	_set_slider("day_seconds", AdminSettings.day_seconds, false)
	_set_slider("night_seconds", AdminSettings.night_seconds, false)
	_set_slider("hearts", float(AdminSettings.hearts), true)
	_set_slider("xp_scale", AdminSettings.xp_scale, false)
	_set_slider("foliage_percent", float(AdminSettings.foliage_percent), true)
	_set_slider("walk_speed", AdminSettings.walk_speed, false)
	_set_slider("run_speed", AdminSettings.run_speed, false)
	_paint_xp_hint()


func _set_slider(field: String, value: float, as_int: bool) -> void:
	var slider: HSlider = _sliders.get(field)
	if slider == null:
		return
	slider.set_value_no_signal(value)
	_paint_value(field, as_int)


func _paint_value(field: String, as_int: bool) -> void:
	var label: Label = _value_labels.get(field)
	if label == null:
		return
	var value := _field_value(field)
	if as_int:
		label.text = str(int(round(value)))
	elif field == "xp_scale":
		label.text = "%.2f×" % value
	else:
		label.text = "%.0f" % value


func _field_value(field: String) -> float:
	match field:
		"day_seconds":
			return AdminSettings.day_seconds
		"night_seconds":
			return AdminSettings.night_seconds
		"hearts":
			return float(AdminSettings.hearts)
		"xp_scale":
			return AdminSettings.xp_scale
		"foliage_percent":
			return float(AdminSettings.foliage_percent)
		"walk_speed":
			return AdminSettings.walk_speed
		"run_speed":
			return AdminSettings.run_speed
	return 0.0


func _paint_xp_hint() -> void:
	if _xp_hint == null:
		return
	var need := Skills.xp_for_level(2)
	_xp_hint.text = "Level 2 needs %d XP" % need


func _make_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(72, 20)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_hover_color", CREAM)
	button.add_theme_color_override("font_pressed_color", CREAM)
	button.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	button.add_theme_constant_override("outline_size", 3)
	var normal := _box(Color(CREAM.r, CREAM.g, CREAM.b, 0.35))
	var lit := _box(Color(CREAM.r, CREAM.g, CREAM.b, 0.9))
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", lit)
	button.add_theme_stylebox_override("pressed", lit)
	button.add_theme_stylebox_override("focus", normal)
	button.pressed.connect(callback)
	return button


func _box(border: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.05, 0.07, 0.04, 0.78)
	box.set_border_width_all(1)
	box.border_color = border
	box.set_content_margin_all(3)
	return box
