class_name TitleMenu
extends Control

## Launch menu. New Game or Continue. A filled box is a shore saved from the woods.

enum Screen { CHOOSE, SLOTS, OVERWRITE_ASK, OVERWRITE_PICK, DELETE_ASK }

const SLOT_COUNT := 3
const NEW_GAME_SCENE := "res://world/world.tscn"
const SLOT_EMPTY := "No save file"

const ART_LEIF := "res://art/leif/south.png"
const ART_LEIF_NORTH := "res://art/leif/north.png"
const ART_FIR := "res://art/coastal_north/tree_fir.png"
const ART_SPRUCE := "res://art/coastal_north/tree_spruce.png"
const ART_ROCK := "res://art/coastal_north/rock_granite.png"
const ART_BAKEAPPLE := "res://art/coastal_north/forage_bakeapple.png"
const ART_BLUEBERRY := "res://art/coastal_north/forage_blueberry.png"
const ART_MOSS := "res://art/coastal_north/clutter_sphagnum.png"
const ART_NEEDLES := "res://art/coastal_north/clutter_needles.png"
const ART_BRANCH := "res://art/coastal_north/clutter_fir_branch.png"
const ART_FALLEN := "res://art/coastal_north/fallen_fir.png"

const VIEW_W := 480
const VIEW_H := 270
const BAND_ROWS := 17
const BAND_TOP := VIEW_H - BAND_ROWS * ChunkGenerator.TILE
const PLATE_W := 280
const PLATE_COLOR := Color(0.24, 0.36, 0.2, 1)
const FADE_SEC := 0.4
## Slower than his woods walk (70). The stroll should still be going when the seed is ready.
const DEPART_SPEED := 52.0
## Above this, his feet have left the top of the screen. The woods open once he is past it and the seed is ready.
const OFF_SCREEN_Y := -16.0
const LOAD_SLICE_USEC := 12000

const CREAM := Color(0.95, 0.93, 0.86)

var screen: Screen = Screen.CHOOSE
var _delete_slot := -1
var _delete_return: Screen = Screen.SLOTS

var _menu: Control
var _buttons: VBoxContainer
var _plate: Panel
var _title: Label
var _prompt: Label
var _leif: Sprite2D
var _built := false
var _departing := false
var _phase := ""
var _fade_t := 0.0
var _walk_t := 0.0
var _booted := false
var _north: Array[Texture2D] = []
var _world: World


func _ready() -> void:
	assemble()


## Safe to call from a test before the tree finishes booting. _ready uses this too.
func assemble() -> void:
	if _built:
		return
	_built = true
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	PlayWindow.fit(get_window())
	_build_picture()
	_build_ui()
	_show_screen()


func _process(delta: float) -> void:
	if not _departing:
		return
	_pump_world()
	if _phase == "fade":
		_fade_t += delta
		var alpha := 1.0 - clampf(_fade_t / FADE_SEC, 0.0, 1.0)
		if _menu != null:
			_menu.modulate.a = alpha
		if _fade_t < FADE_SEC:
			return
		if _menu != null:
			_menu.visible = false
		_turn_leif_north()
		_phase = "walk"
		_walk_t = 0.0
		return
	if _leif == null or _phase != "walk":
		return
	_walk_t += delta
	if not _north.is_empty():
		var idx := int(_walk_t * Player.WALK_FPS) % _north.size()
		_leif.texture = _north[idx]
	# North is up the screen, inland, away from the water. He keeps going past the top.
	_leif.position.y -= DEPART_SPEED * delta
	if _booted and _leif.position.y <= OFF_SCREEN_Y:
		_enter_world()


func _unhandled_input(event: InputEvent) -> void:
	if _departing:
		return
	if not event is InputEventKey:
		return
	var key := event as InputEventKey
	if not key.pressed or key.echo:
		return
	if key.keycode != KEY_ESCAPE:
		return
	press_back()
	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()


func _exit_tree() -> void:
	if _world != null and is_instance_valid(_world) and _world.get_parent() == null:
		_world.free()
		_world = null


func press_continue() -> void:
	screen = Screen.SLOTS
	_show_screen()


func press_back() -> void:
	if _departing:
		return
	if screen == Screen.SLOTS or screen == Screen.OVERWRITE_ASK:
		screen = Screen.CHOOSE
		_show_screen()
	elif screen == Screen.OVERWRITE_PICK:
		screen = Screen.OVERWRITE_ASK
		_show_screen()
	elif screen == Screen.DELETE_ASK:
		press_delete_no()


func press_new_game() -> void:
	if _departing:
		return
	var slot := ShoreSave.first_empty()
	if slot < 0:
		screen = Screen.OVERWRITE_ASK
		_show_screen()
		return
	_begin_departure(slot, {})


func press_overwrite_no() -> void:
	if _departing:
		return
	screen = Screen.CHOOSE
	_show_screen()


func press_overwrite_yes() -> void:
	if _departing:
		return
	screen = Screen.OVERWRITE_PICK
	_show_screen()


func press_overwrite_slot(index: int) -> void:
	if _departing:
		return
	if index < 0 or index >= SLOT_COUNT:
		return
	if not can_load_slot(index):
		return
	# The old file stays until this run's first floppy.
	_begin_departure(index, {})


func press_delete(index: int) -> void:
	if _departing:
		return
	if index < 0 or index >= SLOT_COUNT:
		return
	if not can_load_slot(index):
		return
	_delete_slot = index
	_delete_return = screen
	screen = Screen.DELETE_ASK
	_show_screen()


func press_delete_yes() -> void:
	if _departing:
		return
	ShoreSave.delete_slot(_delete_slot)
	_delete_slot = -1
	screen = _delete_return
	_show_screen()


func press_delete_no() -> void:
	if _departing:
		return
	_delete_slot = -1
	screen = _delete_return
	_show_screen()


func press_slot(index: int) -> void:
	if index < 0 or index >= SLOT_COUNT:
		return
	if not can_load_slot(index):
		return
	# A real file leaves the same way New Game does.
	_begin_departure(index, ShoreSave.read_slot(index))


func departing_slot() -> int:
	if _world == null:
		return -1
	return _world.run_slot()


func booting_world() -> World:
	return _world


func _begin_departure(slot: int, snapshot: Dictionary) -> void:
	if _departing:
		return
	_departing = true
	_phase = "fade"
	_fade_t = 0.0
	_booted = false
	_world = World.new()
	_world.prepare_run(slot, snapshot)
	_world.begin_staged_boot()


func _pump_world() -> void:
	if _world == null or _booted:
		return
	var start := Time.get_ticks_usec()
	var done := false
	while not done and Time.get_ticks_usec() - start < LOAD_SLICE_USEC:
		done = _world.stage_boot_step()
	if done:
		_booted = true


func is_departing() -> bool:
	return _departing


func new_game_scene() -> String:
	return NEW_GAME_SCENE


func slot_count() -> int:
	return SLOT_COUNT


func slot_label(index: int) -> String:
	return ShoreSave.label(index)


func can_load_slot(index: int) -> bool:
	return ShoreSave.has_slot(index)


func _turn_leif_north() -> void:
	_north.clear()
	for i in Player.WALK_FRAME_COUNT:
		var path := "res://art/leif/walk/north_%d.png" % i
		if not ResourceLoader.exists(path):
			continue
		var tex := load(path) as Texture2D
		if tex != null:
			_north.append(tex)
	if _leif == null:
		return
	if _north.is_empty():
		if ResourceLoader.exists(ART_LEIF_NORTH):
			var idle := load(ART_LEIF_NORTH) as Texture2D
			if idle != null:
				_leif.texture = idle
		return
	_leif.texture = _north[0]


func _enter_world() -> void:
	var tree := get_tree()
	var world := _world
	_world = null
	_departing = false
	if tree == null or world == null:
		return
	tree.root.remove_child(self)
	tree.root.add_child(world)
	tree.current_scene = world
	queue_free()


func _build_picture() -> void:
	var band := ShoreBand.new()
	band.name = "Shore"
	band.position = Vector2(0, BAND_TOP)
	band.size = Vector2(VIEW_W, BAND_ROWS * ChunkGenerator.TILE)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(band)
	var picture := Node2D.new()
	picture.name = "Picture"
	picture.y_sort_enabled = true
	picture.z_index = 1
	add_child(picture)
	# Woods run to the top of the screen, left and right of the menu box.
	_add_prop(picture, ART_SPRUCE, 28, 52)
	_add_prop(picture, ART_FIR, 78, 36)
	_add_prop(picture, ART_FIR, 36, 110)
	_add_prop(picture, ART_SPRUCE, 92, 96)
	_add_prop(picture, ART_FIR, 24, 168)
	_add_prop(picture, ART_SPRUCE, 84, 156)
	_add_prop(picture, ART_FIR, 452, 44)
	_add_prop(picture, ART_SPRUCE, 400, 32)
	_add_prop(picture, ART_SPRUCE, 444, 108)
	_add_prop(picture, ART_FIR, 392, 100)
	_add_prop(picture, ART_FIR, 456, 170)
	_add_prop(picture, ART_SPRUCE, 396, 162)
	# Trees behind the menu. They show once the box fades, and he walks up between them.
	_add_prop(picture, ART_FIR, 168, 78)
	_add_prop(picture, ART_SPRUCE, 312, 64)
	_add_prop(picture, ART_FIR, 196, 140)
	_add_prop(picture, ART_SPRUCE, 292, 128)
	_add_prop(picture, ART_MOSS, 48, 130, false, "", MapChunk.SPHAGNUM_SCALE)
	_add_prop(picture, ART_NEEDLES, 430, 124)
	_add_prop(picture, ART_BRANCH, 120, 150)
	# The shore in front of the menu.
	_add_prop(picture, ART_FIR, 42, 214)
	_add_prop(picture, ART_SPRUCE, 438, 216)
	_add_prop(picture, ART_FIR, 118, 200)
	_add_prop(picture, ART_SPRUCE, 360, 198)
	_add_prop(picture, ART_ROCK, 86, 206)
	_add_prop(picture, ART_ROCK, 390, 208)
	_add_prop(picture, ART_BAKEAPPLE, 150, 204)
	_add_prop(picture, ART_BLUEBERRY, 318, 206)
	_add_prop(picture, ART_MOSS, 186, 212, false, "", MapChunk.SPHAGNUM_SCALE)
	_add_prop(picture, ART_NEEDLES, 286, 214)
	_add_prop(picture, ART_BRANCH, 200, 218)
	_add_prop(picture, ART_FALLEN, 130, 210)
	_add_prop(picture, ART_LEIF, 240, 190, true, "Leif")


func _add_prop(parent: Node2D, path: String, x: float, y: float, player_scale: bool = false, node_name: String = "", draw_scale: float = 1.0) -> void:
	if not ResourceLoader.exists(path):
		return
	var tex := load(path) as Texture2D
	if tex == null:
		return
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = true
	if player_scale:
		sprite.scale = Vector2(Player.SPRITE_SCALE, Player.SPRITE_SCALE)
		sprite.offset = Vector2(0, Player.FEET_OFFSET_Y)
		_leif = sprite
	else:
		sprite.scale = Vector2(draw_scale, draw_scale)
		sprite.offset = Vector2(0, -float(tex.get_height()) * 0.5)
	sprite.position = Vector2(x, y)
	if node_name != "":
		sprite.name = node_name
	parent.add_child(sprite)


func _build_ui() -> void:
	_menu = Control.new()
	_menu.name = "Menu"
	_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_menu.z_index = 3
	add_child(_menu)
	_plate = Panel.new()
	_plate.name = "MenuPlate"
	var plate_style := StyleBoxFlat.new()
	plate_style.bg_color = PLATE_COLOR
	plate_style.set_border_width_all(2)
	plate_style.border_color = Color(0.55, 0.66, 0.42, 1)
	_plate.add_theme_stylebox_override("panel", plate_style)
	_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plate.focus_mode = Control.FOCUS_NONE
	_menu.add_child(_plate)
	_title = Label.new()
	_title.name = "TitleLabel"
	_title.text = "Leif in the Wind"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title.focus_mode = Control.FOCUS_NONE
	_title.modulate = CREAM
	_title.add_theme_font_size_override("font_size", 18)
	_title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_title.add_theme_constant_override("outline_size", 5)
	_menu.add_child(_title)
	_prompt = Label.new()
	_prompt.name = "Prompt"
	_prompt.visible = false
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.autowrap_mode = TextServer.AUTOWRAP_WORD
	_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prompt.focus_mode = Control.FOCUS_NONE
	_prompt.modulate = CREAM
	_prompt.add_theme_font_size_override("font_size", 12)
	_prompt.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_prompt.add_theme_constant_override("outline_size", 4)
	_menu.add_child(_prompt)
	_buttons = VBoxContainer.new()
	_buttons.name = "Buttons"
	_buttons.add_theme_constant_override("separation", 4)
	_buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_menu.add_child(_buttons)


func _show_screen() -> void:
	if _buttons == null:
		return
	# The click is still emitting. free() here locks the button and crashes.
	while _buttons.get_child_count() > 0:
		var child := _buttons.get_child(0)
		_buttons.remove_child(child)
		child.queue_free()
	var wide := false
	_prompt.visible = false
	_prompt.text = ""
	match screen:
		Screen.CHOOSE:
			_add_action("New Game", press_new_game)
			_add_action("Continue", press_continue)
		Screen.SLOTS:
			wide = true
			for i in SLOT_COUNT:
				_add_save_row(i, press_slot.bind(i))
			_add_action("Back", press_back, true)
		Screen.OVERWRITE_ASK:
			_prompt.text = "Starting a new game will overwrite an existing save. Do you want to continue?"
			_prompt.visible = true
			_add_action("Yes", press_overwrite_yes)
			_add_action("No", press_overwrite_no)
		Screen.OVERWRITE_PICK:
			wide = true
			_prompt.text = "Choose which save to overwrite."
			_prompt.visible = true
			for i in SLOT_COUNT:
				_add_save_row(i, press_overwrite_slot.bind(i))
			_add_action("Back", press_back, true)
		Screen.DELETE_ASK:
			_prompt.text = "Are you sure you want to delete this save?"
			_prompt.visible = true
			_add_action("Yes", press_delete_yes)
			_add_action("No", press_delete_no)
	_layout_menu(wide)


func _layout_menu(wide: bool) -> void:
	if _plate == null or _buttons == null or _title == null:
		return
	var button_w := 248.0 if wide else 168.0
	var prompt_h := 0.0
	if _prompt != null and _prompt.visible:
		if screen == Screen.OVERWRITE_ASK:
			prompt_h = 48.0
		elif screen == Screen.DELETE_ASK:
			prompt_h = 40.0
		else:
			prompt_h = 20.0
		_prompt.position = Vector2((VIEW_W - (PLATE_W - 24)) / 2.0, 40)
		_prompt.size = Vector2(PLATE_W - 24, prompt_h)
	var buttons_y := 42.0 + prompt_h
	var content_h := 0.0
	var n := _buttons.get_child_count()
	for i in n:
		var child := _buttons.get_child(i) as Control
		content_h += child.custom_minimum_size.y
	if n > 1:
		content_h += float(n - 1) * 4.0
	var x := (VIEW_W - PLATE_W) / 2.0
	_plate.position = Vector2(x, 12)
	_plate.size = Vector2(PLATE_W, buttons_y + content_h + 10.0 - 12.0)
	_title.position = Vector2(x, 16)
	_title.size = Vector2(PLATE_W, 24)
	_buttons.position = Vector2((VIEW_W - button_w) / 2.0, buttons_y)
	_buttons.size = Vector2(button_w, content_h)


func _add_save_row(index: int, on_pick: Callable) -> void:
	if not can_load_slot(index):
		_add_action(slot_label(index), on_pick, true)
		return
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.custom_minimum_size = Vector2(248, 40)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_make_button(slot_label(index), on_pick, Vector2(222, 40)))
	var delete := _make_button("x", press_delete.bind(index), Vector2(22, 40))
	delete.name = "Delete"
	row.add_child(delete)
	_buttons.add_child(row)


func _add_action(text: String, callback: Callable, wide: bool = false) -> void:
	var size := Vector2(248, 40) if wide else Vector2(168, 22)
	_buttons.add_child(_make_button(text, callback, size))


func _make_button(text: String, callback: Callable, size: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.custom_minimum_size = size
	# Hover lights the box. Nothing is lit just because it is first.
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_hover_color", CREAM)
	button.add_theme_color_override("font_pressed_color", CREAM)
	button.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	button.add_theme_constant_override("outline_size", 4)
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
	box.set_content_margin_all(4)
	return box


class ShoreBand extends Control:
	var tiles: WangTiles

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		focus_mode = Control.FOCUS_NONE
		tiles = WangTiles.new()
		tiles.load_coastal()
		queue_redraw()

	func _draw() -> void:
		if tiles == null or not tiles.ready():
			return
		var cols := int(TitleMenu.VIEW_W / ChunkGenerator.TILE)
		for ty in TitleMenu.BAND_ROWS:
			for tx in cols:
				tiles.blit(self, tx, ty, _kind_at)

	func _kind_at(tx: int, ty: int) -> int:
		# Water along the bottom, a shore, moss inland, and a trail leading up
		# into the trees. ty below 0 stays moss so the top edge is not a trail.
		if ty >= 14:
			return ChunkGenerator.TILE_WATER
		if ty >= 12:
			return ChunkGenerator.TILE_SHORE
		if tx == 15 and ty >= 4 and ty < 12:
			return ChunkGenerator.TILE_TRAIL
		if ty >= 0 and (tx * 3 + ty * 5) % 9 == 0:
			return ChunkGenerator.TILE_PEAT
		return ChunkGenerator.TILE_MOSS
