class_name World
extends Node2D

@export var world_seed: int = 11

const STRIP_WEST := -1
const STRIP_EAST := 1
const STRIP_SOUTH := 0
const STRIP_NORTH := -3

var catalog: BiomeCatalog = BiomeCatalog.new()
var generator: ChunkGenerator = ChunkGenerator.new()
var supplies: Supplies = Supplies.new()
var skills: Skills = Skills.new()
var _wang := WangTiles.new()
var _chunks: Dictionary = {}
var _chunk: MapChunk
var _player: Player
var _hud: GameHud
var _camera: Camera2D
var _interact: Interact
var _clock: DayClock
var _night: CanvasModulate
var _music: AudioStreamPlayer
var _hint := ""
var _fires: Array[Node2D] = []
var _sleep_phase := ""
var _sleep_t := 0.0
var _fog := FogMap.new()
var _minimap_cell := Vector2i(99999, 99999)
var _staged := false
var _stage_keys: Array[Vector2i] = []
var _stage_index := 0
var _stage_phase := 0
var _slot := -1
var _save_name := ""
var _pending_snapshot: Dictionary = {}
var _naming := false
var _quit_ask := false
var _quit_layer: CanvasLayer
var _opened := false
var _caribou: Caribou

const SLEEP_OUT := 0.4
const SLEEP_HOLD := 0.12
const SLEEP_IN := 0.7
const FIRE_WARM_PIXELS := 56.0
const PROP_EDGE := 24.0
const TITLE_SCENE := "res://title/title.tscn"
const PLATE_COLOR := Color(0.24, 0.36, 0.2, 1)
const CREAM := Color(0.95, 0.93, 0.86)


func _ready() -> void:
	open_play()


## Headless tests add the world before the tree is ready, so _ready has not run yet.
## Opening twice would stack a second Leif.
func open_play() -> void:
	if _opened:
		return
	_opened = true
	PlayWindow.fit(get_window())
	y_sort_enabled = true
	catalog.load_all()
	_wang.load_coastal()
	_hud = GameHud.new()
	add_child(_hud)
	# Tests add the world before it is inside the tree, so the hud's _ready has not run.
	if _hud.get_node_or_null("SaveFloppy") == null:
		_hud._build()
	_hud.save_pressed.connect(_on_save_pressed)
	_hud.name_submitted.connect(submit_save_name)
	_hud.name_cancelled.connect(cancel_save_name)
	_player = Player.new()
	_player.world = self
	_player.y_sort_enabled = true
	# Leif is restacked among the trees when his height changes. A camera on him
	# hitches up, down, and on a diagonal. Left and right do not change that order.
	if is_inside_tree():
		attach_camera(get_tree().root)
	_night = CanvasModulate.new()
	add_child(_night)
	_clock = DayClock.new()
	_clock.supplies = supplies
	_clock.modulate = _night
	_clock.phase_changed.connect(_on_phase_changed)
	add_child(_clock)
	_night.color = _clock.modulate_color()
	_interact = Interact.new()
	_interact.player = _player
	_interact.supplies = supplies
	_interact.skills = skills
	_interact.world = self
	_interact.acted.connect(_on_acted)
	add_child(_interact)
	_music = AudioStreamPlayer.new()
	_music.bus = "Master"
	_music.volume_db = -4.0
	_music.finished.connect(_on_music_finished)
	add_child(_music)
	if _staged and not _chunks.is_empty():
		_finish_arrival()
	else:
		rebuild()


func _exit_tree() -> void:
	if _camera != null and is_instance_valid(_camera):
		_camera.queue_free()
		_camera = null


func attach_camera(viewport_root: Node) -> void:
	_camera = Camera2D.new()
	_camera.position_smoothing_enabled = false
	_camera.top_level = true
	viewport_root.add_child(_camera)


func stick_camera() -> void:
	if _camera == null or _player == null:
		return
	if not is_instance_valid(_camera) or not is_instance_valid(_player):
		return
	_camera.global_position = _player.global_position


func camera_is_outside_the_woods() -> bool:
	if _camera == null or _player == null or not is_instance_valid(_camera):
		return false
	return _camera.top_level and _camera.get_parent() != _player


func _process(delta: float) -> void:
	if _naming or _quit_ask:
		return
	if _player == null or _clock == null:
		return
	if _sleep_phase != "":
		_tick_sleep(delta)
		return
	var warm := is_near_fire(_player.global_position)
	var change := supplies.tick_vitals(_clock.is_night(), warm, delta)
	if change == "cold":
		_hint = "The night is cold. Get to a fire."
		_refresh_hud()
	elif change == "heal":
		_refresh_hud()
	_reveal_visible_view()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key := event as InputEventKey
	if not key.pressed or key.echo:
		return
	if _naming:
		if key.keycode == KEY_ESCAPE:
			cancel_save_name()
			_mark_handled()
		return
	if _quit_ask:
		if key.keycode == KEY_Y:
			press_quit_yes()
			_mark_handled()
		elif key.keycode == KEY_N or key.keycode == KEY_ESCAPE:
			press_quit_no()
			_mark_handled()
		return
	if key.keycode == KEY_ESCAPE:
		# Sleep blink ignores Escape until he is awake again.
		if _sleep_phase != "":
			_mark_handled()
			return
		open_quit_ask()
		_mark_handled()
		return
	if key.keycode == KEY_R:
		# New seed. Wood, forage, and skills stay. Fires were on the old ground.
		world_seed = (world_seed * 1103515245 + 12345) & 0x7fffffff
		rebuild()
		_mark_handled()
	elif key.keycode == KEY_E:
		_try_eat()
		_mark_handled()
	elif key.keycode == KEY_F:
		_try_place_campfire()
		_mark_handled()
	elif key.keycode == KEY_C:
		_try_sleep()
		_mark_handled()
	elif key.keycode == KEY_F11:
		_toggle_fullscreen()
		_mark_handled()


func _mark_handled() -> void:
	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()


func _on_phase_changed(_next: String) -> void:
	_refresh_hud()


func _on_acted(action: String, species: String) -> void:
	if action == "forage":
		if _interact != null and _interact.last_levels > 0:
			_hint = "Foraging is now %d." % skills.forage_level()
			_spawn_leaves()
		else:
			var pay := skills.forage_pay()
			if _interact != null:
				pay = _interact.last_forage
			_hint = "Picked %s. +%d forage." % [species, pay]
	elif action == "bite":
		_hint = "The tree holds."
	elif action == "chop":
		if _interact != null and _interact.last_levels > 0:
			_hint = "Woodcutting is now %d." % skills.level()
			_spawn_leaves()
		else:
			var pay := skills.wood_at()
			if _interact != null:
				pay = _interact.last_wood
			_hint = "Chopped %s. +%s wood." % [species, Supplies.wood_label(pay)]
	elif action == "clear":
		_hint = "Cleared a branch. +%s wood." % Supplies.wood_label(Supplies.WOOD_PER_BRANCH)
	_refresh_hud()


func rebuild() -> void:
	# R is a new coast. Do not drop him back on the shore he had saved.
	_pending_snapshot = {}
	_drop_caribou()
	if _player.get_parent() != null:
		_player.get_parent().remove_child(_player)
	for key in _chunks.keys():
		var old: MapChunk = _chunks[key]
		if old != null and is_instance_valid(old):
			old.queue_free()
	_chunks.clear()
	_fires.clear()
	_chunk = null
	_staged = false
	_build_strip()
	_finish_arrival()


## Build the strip a slice at a time so the title walk can play while the coast loads.
func begin_staged_boot() -> void:
	if _staged:
		return
	_staged = true
	catalog.load_all()
	if not _wang.ready():
		_wang.load_coastal()
	_stage_keys.clear()
	for cy in range(STRIP_NORTH, STRIP_SOUTH + 1):
		for cx in range(STRIP_WEST, STRIP_EAST + 1):
			_stage_keys.append(Vector2i(cx, cy))
	_stage_index = 0
	_stage_phase = 0


func stage_boot_step() -> bool:
	if not _staged or _stage_phase > 2:
		return true
	if _stage_index >= _stage_keys.size():
		_stage_phase += 1
		_stage_index = 0
		return _stage_phase > 2
	var key := _stage_keys[_stage_index]
	if _stage_phase == 0:
		_make_chunk(key)
		_stage_index += 1
	elif _stage_phase == 1:
		var baking: MapChunk = _chunks[key]
		if baking.bake_floor_step(8):
			_stage_index += 1
	else:
		var spawning: MapChunk = _chunks[key]
		spawning.spawn_interactive()
		_stage_index += 1
	return false


func boot_chunk_count() -> int:
	return _chunks.size()


func _finish_arrival() -> void:
	var landing: MapChunk = _chunks.get(Vector2i(0, 0))
	if _player.get_parent() != self:
		add_child(_player)
	if landing != null:
		_player.global_position = landing.position + landing.spawn_local()
	_reparent_player()
	_spawn_caribou()
	_fog.clear()
	_minimap_cell = Vector2i(99999, 99999)
	var snapshot := _pending_snapshot
	_pending_snapshot = {}
	if snapshot.is_empty():
		_hint = ""
	else:
		apply_walk(snapshot)
	_cull_far_chunks()
	_fit_camera()
	stick_camera()
	if _camera != null and _camera.is_inside_tree():
		_camera.make_current()
	if snapshot.is_empty():
		_reveal_visible_view()
		_refresh_hud()
	_ensure_music()


## Slot is claimed by New Game. The snapshot is a Continue file, or empty for a new shore.
## Seed is set here, before the coast is built.
func prepare_run(slot: int, snapshot: Dictionary = {}) -> void:
	_slot = slot
	_save_name = ""
	_pending_snapshot = snapshot.duplicate(true)
	if snapshot.is_empty():
		skills.woodcutting_xp = 0
		skills.firemaking_xp = 0
		skills.forage_xp = 0
		var h := float(AdminSettings.hearts)
		supplies.hearts = h
		supplies.hearts_max = h
	else:
		skills.woodcutting_xp = int(snapshot.get("woodcutting_xp", 0))
		skills.firemaking_xp = int(snapshot.get("firemaking_xp", 0))
		skills.forage_xp = int(snapshot.get("forage_xp", 0))
	if snapshot.has("name"):
		_save_name = ShoreSave.clean_name(str(snapshot["name"]))
	if snapshot.has("seed"):
		world_seed = int(snapshot["seed"])


func run_slot() -> int:
	return _slot


func save_name() -> String:
	return _save_name


func is_naming() -> bool:
	return _naming


func is_quit_ask() -> bool:
	return _quit_ask


func open_quit_ask() -> void:
	if _quit_ask or _naming or _sleep_phase != "":
		return
	_quit_ask = true
	if _clock != null:
		_clock.set_process(false)
	_build_quit_ask()


func press_quit_no() -> void:
	if not _quit_ask:
		return
	_quit_ask = false
	if _quit_layer != null:
		_quit_layer.queue_free()
		_quit_layer = null
	if _clock != null:
		_clock.set_process(true)


func press_quit_yes() -> void:
	if not _quit_ask:
		return
	# Same landing as change_scene_to_file(TITLE_SCENE). Swap under the same
	# parent so Play and headless -s tests agree. _exit_tree frees the camera.
	var host := get_parent()
	if host == null:
		return
	var packed := load(TITLE_SCENE) as PackedScene
	var title: Node = packed.instantiate() if packed != null else TitleMenu.new()
	_quit_ask = false
	if _quit_layer != null and is_instance_valid(_quit_layer):
		_quit_layer.queue_free()
		_quit_layer = null
	host.remove_child(self)
	host.add_child(title)
	if title is TitleMenu:
		(title as TitleMenu).assemble()
	var loop := Engine.get_main_loop()
	if loop != null:
		loop.set("current_scene", title)
	queue_free()


func capture_walk() -> Dictionary:
	var fog_cells: Array = []
	for key in _fog.revealed:
		fog_cells.append([int(key.x), int(key.y)])
	var pos := Vector2.ZERO
	var facing := "south"
	if _player != null and is_instance_valid(_player):
		pos = _player.global_position
		facing = _player.facing_name()
	var elapsed := 0.0
	if _clock != null:
		elapsed = _clock.elapsed
	var caribou_px := Vector2.ZERO
	var caribou_facing := "north"
	var caribou_dir := 1
	if _caribou != null and is_instance_valid(_caribou):
		caribou_px = _caribou.global_position
		caribou_facing = _caribou.facing_name()
		caribou_dir = _caribou.travel_dir
	return {
		"version": 1,
		"name": _save_name,
		"seed": world_seed,
		"x": pos.x,
		"y": pos.y,
		"facing": facing,
		"wood": supplies.wood,
		"forage": supplies.forage,
		"hearts": supplies.hearts,
		"hearts_max": supplies.hearts_max,
		"cold_acc": supplies.cold_acc,
		"heal_acc": supplies.heal_acc,
		"woodcutting_xp": skills.woodcutting_xp,
		"firemaking_xp": skills.firemaking_xp,
		"forage_xp": skills.forage_xp,
		"elapsed": elapsed,
		"fog": fog_cells,
		"fires": _capture_fires(),
		"caribou_x": caribou_px.x,
		"caribou_y": caribou_px.y,
		"caribou_facing": caribou_facing,
		"caribou_dir": caribou_dir,
	}


## Puts the saved walk back on a coast that was already built from that seed.
func apply_walk(data: Dictionary) -> void:
	if data.is_empty():
		return
	if data.has("seed"):
		world_seed = int(data["seed"])
	if data.has("name"):
		_save_name = ShoreSave.clean_name(str(data["name"]))
	supplies.wood = float(data.get("wood", supplies.wood))
	supplies.forage = int(data.get("forage", supplies.forage))
	# File hearts first, then admin max, then clamp so a lower QC max does not overfill.
	supplies.hearts = float(data.get("hearts", supplies.hearts))
	supplies.hearts_max = float(AdminSettings.hearts)
	supplies.hearts = snappedf(minf(supplies.hearts, supplies.hearts_max), Supplies.HEART_STEP)
	supplies.cold_acc = float(data.get("cold_acc", 0.0))
	supplies.heal_acc = float(data.get("heal_acc", 0.0))
	skills.woodcutting_xp = int(data.get("woodcutting_xp", 0))
	skills.firemaking_xp = int(data.get("firemaking_xp", 0))
	skills.forage_xp = int(data.get("forage_xp", 0))
	if _clock != null and data.has("elapsed"):
		_clock.elapsed = float(data["elapsed"])
		DayClock.darkness_now = _clock.darkness()
		if _night != null:
			_night.color = _clock.modulate_color()
	if _player != null and is_instance_valid(_player):
		if data.has("x") and data.has("y"):
			_player.global_position = Vector2(float(data["x"]), float(data["y"]))
		if data.has("facing"):
			_player.set_facing(str(data["facing"]))
		_reparent_player()
		stick_camera()
	_fog.clear()
	var cells: Variant = data.get("fog", [])
	if cells is Array:
		for item in cells:
			if item is Array and item.size() >= 2:
				_fog.reveal(Vector2i(int(item[0]), int(item[1])))
	_minimap_cell = Vector2i(99999, 99999)
	if data.has("fires") and data["fires"] is Array:
		_restore_fires(data["fires"])
	_apply_caribou(data)
	_reveal_visible_view()
	_refresh_hud()


func try_save() -> void:
	if _naming or is_sleeping() or _slot < 0:
		return
	if _save_name == "":
		_set_naming(true)
		if _hud != null:
			_hud.show_name_prompt()
		return
	_commit_save()


func submit_save_name(raw: String) -> bool:
	var cleaned := ShoreSave.clean_name(raw)
	if cleaned == "":
		return false
	_save_name = cleaned
	_set_naming(false)
	if _hud != null:
		_hud.hide_name_prompt()
	return _commit_save()


func cancel_save_name() -> void:
	_set_naming(false)
	if _hud != null:
		_hud.hide_name_prompt()


func _on_save_pressed() -> void:
	try_save()


func _set_naming(active: bool) -> void:
	_naming = active
	if _clock != null:
		_clock.set_process(not active)


func _build_quit_ask() -> void:
	if _quit_layer != null:
		return
	_quit_layer = CanvasLayer.new()
	_quit_layer.name = "QuitAsk"
	_quit_layer.layer = 40
	var root := Control.new()
	root.name = "Root"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	_quit_layer.add_child(root)
	var plate := Panel.new()
	plate.name = "Plate"
	plate.position = Vector2(100, 90)
	plate.size = Vector2(280, 88)
	var style := StyleBoxFlat.new()
	style.bg_color = PLATE_COLOR
	style.set_border_width_all(2)
	style.border_color = Color(0.55, 0.66, 0.42, 1)
	plate.add_theme_stylebox_override("panel", style)
	plate.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(plate)
	var prompt := Label.new()
	prompt.name = "Prompt"
	prompt.text = "Quit to the main menu?"
	prompt.position = Vector2(12, 10)
	prompt.size = Vector2(256, 28)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.modulate = CREAM
	prompt.add_theme_font_size_override("font_size", 12)
	prompt.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	prompt.add_theme_constant_override("outline_size", 4)
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(prompt)
	var row := HBoxContainer.new()
	row.name = "Buttons"
	row.position = Vector2(40, 48)
	row.size = Vector2(200, 28)
	row.add_theme_constant_override("separation", 8)
	plate.add_child(row)
	row.add_child(_quit_button("Yes", press_quit_yes))
	row.add_child(_quit_button("No", press_quit_no))
	add_child(_quit_layer)


func _quit_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(96, 24)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_hover_color", CREAM)
	button.add_theme_color_override("font_pressed_color", CREAM)
	button.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	button.add_theme_constant_override("outline_size", 4)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.05, 0.07, 0.04, 0.78)
	normal.set_border_width_all(1)
	normal.border_color = Color(CREAM.r, CREAM.g, CREAM.b, 0.35)
	normal.set_content_margin_all(4)
	var lit := StyleBoxFlat.new()
	lit.bg_color = Color(0.05, 0.07, 0.04, 0.78)
	lit.set_border_width_all(1)
	lit.border_color = Color(CREAM.r, CREAM.g, CREAM.b, 0.9)
	lit.set_content_margin_all(4)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", lit)
	button.add_theme_stylebox_override("pressed", lit)
	button.add_theme_stylebox_override("focus", normal)
	button.pressed.connect(callback)
	return button


func _commit_save() -> bool:
	if _slot < 0 or _save_name == "":
		return false
	var data := capture_walk()
	data["name"] = _save_name
	data["saved_unix"] = ShoreSave.now_unix()
	if not ShoreSave.write_slot(_slot, data):
		return false
	_hint = "Saved."
	_refresh_hud()
	return true


func nearby_props() -> Array:
	var found: Array = []
	if _chunk == null or not is_instance_valid(_chunk):
		return found
	found.append_array(_chunk.prop_nodes())
	if _player == null:
		return found
	var local := _player.position
	var width := float(ChunkGenerator.WIDTH * ChunkGenerator.TILE)
	var height := float(ChunkGenerator.HEIGHT * ChunkGenerator.TILE)
	var home := Vector2i(_chunk.chunk_x, _chunk.chunk_y)
	if local.x < PROP_EDGE:
		_append_chunk_props(found, home + Vector2i(-1, 0))
	if local.x > width - PROP_EDGE:
		_append_chunk_props(found, home + Vector2i(1, 0))
	if local.y < PROP_EDGE:
		_append_chunk_props(found, home + Vector2i(0, -1))
	if local.y > height - PROP_EDGE:
		_append_chunk_props(found, home + Vector2i(0, 1))
	return found


func _append_chunk_props(found: Array, key: Vector2i) -> void:
	var other: MapChunk = _chunks.get(key)
	if other != null and is_instance_valid(other):
		found.append_array(other.prop_nodes())


func is_sleeping() -> bool:
	return _sleep_phase != ""


func leif() -> Player:
	return _player


func caribou() -> Caribou:
	return _caribou


func on_entered_chunk(_world_px: Vector2) -> void:
	_reparent_player()
	_cull_far_chunks()
	_sync_interact()


func _cull_far_chunks() -> void:
	var home := Vector2i(0, 0)
	if _chunk != null:
		home = Vector2i(_chunk.chunk_x, _chunk.chunk_y)
	for key: Vector2i in _chunks.keys():
		var chunk: MapChunk = _chunks[key]
		if chunk == null or not is_instance_valid(chunk):
			continue
		chunk.visible = absi(key.x - home.x) <= 1 and absi(key.y - home.y) <= 1


func _build_strip() -> void:
	for cy in range(STRIP_NORTH, STRIP_SOUTH + 1):
		for cx in range(STRIP_WEST, STRIP_EAST + 1):
			_make_chunk(Vector2i(cx, cy))
	for chunk: MapChunk in _chunks.values():
		if chunk != null and is_instance_valid(chunk):
			chunk.bake_floor()
			chunk.spawn_interactive()


func _make_chunk(key: Vector2i) -> MapChunk:
	if _chunks.has(key) and is_instance_valid(_chunks[key]):
		return _chunks[key]
	var biome := catalog.get_biome(catalog.biome_id_at(key.x * ChunkGenerator.WIDTH, key.y * ChunkGenerator.HEIGHT))
	var chunk := MapChunk.new()
	chunk.y_sort_enabled = true
	chunk.world_sample = _sample_world_tile
	chunk.use_wang(_wang)
	chunk.foreign_grid = _adjust_foreign_cell
	chunk.setup(world_seed, key.x, key.y, biome, false)
	add_child(chunk)
	move_child(chunk, 0)
	_chunks[key] = chunk
	return chunk


func _chunk_at(key: Vector2i) -> MapChunk:
	var chunk: MapChunk = _chunks.get(key)
	if chunk != null and is_instance_valid(chunk):
		return chunk
	return null


func _reparent_player() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var key := ChunkGenerator.chunk_of_cell(ChunkGenerator.world_cell_at(_player.global_position))
	var host := _chunk_at(key)
	if host == null:
		return
	if _player.get_parent() == host:
		_chunk = host
		return
	var keep := _player.global_position
	if _player.get_parent() != null:
		_player.get_parent().remove_child(_player)
	host.add_child(_player)
	_player.global_position = keep
	_chunk = host
	stick_camera()


func reparent_caribou() -> void:
	_reparent_actor(_caribou)


func _spawn_caribou() -> void:
	_drop_caribou()
	var trail := generator.caribou_trail_cells(world_seed, STRIP_NORTH)
	if trail.is_empty():
		return
	_caribou = Caribou.new()
	_caribou.world = self
	add_child(_caribou)
	var start := generator.caribou_seed_index(trail)
	_caribou.setup(trail, start)
	_caribou.global_position = ChunkGenerator.cell_center(trail[start])
	_reparent_actor(_caribou)


func _apply_caribou(data: Dictionary) -> void:
	if _caribou == null or not is_instance_valid(_caribou):
		return
	if not data.has("caribou_x") or not data.has("caribou_y"):
		return
	_caribou.global_position = Vector2(float(data["caribou_x"]), float(data["caribou_y"]))
	if data.has("caribou_facing"):
		_caribou.set_facing(str(data["caribou_facing"]))
	if data.has("caribou_dir"):
		_caribou.travel_dir = 1 if int(data["caribou_dir"]) >= 0 else -1
	_reparent_actor(_caribou)


func _drop_caribou() -> void:
	if _caribou != null and is_instance_valid(_caribou):
		var host := _caribou.get_parent()
		if host != null:
			host.remove_child(_caribou)
		_caribou.queue_free()
	_caribou = null


func _reparent_actor(actor: Node2D) -> void:
	if actor == null or not is_instance_valid(actor):
		return
	var key := ChunkGenerator.chunk_of_cell(ChunkGenerator.world_cell_at(actor.global_position))
	var host := _chunk_at(key)
	if host == null:
		return
	if actor.get_parent() == host:
		return
	var keep := actor.global_position
	if actor.get_parent() != null:
		actor.get_parent().remove_child(actor)
	host.add_child(actor)
	actor.global_position = keep


func _sync_interact() -> void:
	if _interact == null:
		return
	_interact.chunk = _chunk
	if _chunk != null:
		_interact.biome = _chunk.biome


func _sample_world_tile(world_tx: int, world_ty: int) -> int:
	var cell := Vector2i(world_tx, world_ty)
	var key := ChunkGenerator.chunk_of_cell(cell)
	var chunk: MapChunk = _chunks.get(key)
	if chunk != null and is_instance_valid(chunk):
		return chunk.tile_kind(ChunkGenerator.local_of_cell(cell))
	if key.y > 0:
		return ChunkGenerator.TILE_WATER
	if key.y == 0:
		var local_y := posmod(world_ty, ChunkGenerator.HEIGHT)
		if local_y >= ChunkGenerator.HEIGHT - ChunkGenerator.WATER_ROWS:
			return ChunkGenerator.TILE_WATER
		if local_y >= ChunkGenerator.HEIGHT - ChunkGenerator.WATER_ROWS - ChunkGenerator.SHORE_ROWS:
			return ChunkGenerator.TILE_SHORE
	return ChunkGenerator.TILE_MOSS


func _try_eat() -> void:
	if _sleep_phase != "":
		return
	var cost := skills.eat_cost()
	var result := supplies.try_eat(cost)
	if result == "eat":
		_hint = "Ate. +%s heart." % Supplies.wood_label(Supplies.HEART_STEP)
	elif result == "short":
		_hint = "Need %d forage to eat." % cost
	elif result == "full":
		_hint = "Hearts are already full."
	_refresh_hud()


func _try_place_campfire() -> void:
	if _chunk == null or _player == null:
		return
	var cost := skills.fire_cost()
	if supplies.wood < cost:
		_hint = "Need %s wood for a fire." % Supplies.wood_label(cost)
		_refresh_hud()
		return
	var world_cell := Interact.tile_ahead(_player.global_position, _player.facing_name())
	var reason := _campfire_block_reason(world_cell)
	if reason != "":
		_hint = reason
		_refresh_hud()
		return
	if not Campfire.try_place(supplies, false, false, cost):
		_hint = "Need %s wood for a fire." % Supplies.wood_label(cost)
		_refresh_hud()
		return
	if not skills.roll_catch():
		_hint = "The fire does not catch."
		_refresh_hud()
		return
	if place_saved_fire(world_cell, DayClock.cold_seconds()):
		var gained := skills.add_firemaking_xp(Skills.XP_PER_LIGHT)
		if gained > 0:
			_hint = "Fire-making is now %d." % skills.firemaking_level()
			_spawn_leaves()
		else:
			_hint = "Campfire lit."
	else:
		supplies.wood = snappedf(supplies.wood + cost, 0.1)
		_hint = "Cannot light a fire there."
	_refresh_hud()


## A fire already paid for, or one the save froze mid-burn. burn_left is the time left.
func place_saved_fire(world_cell: Vector2i, burn_left: float) -> bool:
	if burn_left <= 0.0 or _campfire_block_reason(world_cell) != "":
		return false
	var host := _chunk_at(ChunkGenerator.chunk_of_cell(world_cell))
	if host == null:
		return false
	var fire := Campfire.new()
	fire.burn_left = burn_left
	fire.lifetime = DayClock.cold_seconds()
	fire.position = MapChunk.anchor_for_cell(ChunkGenerator.local_of_cell(world_cell))
	fire.build_visual()
	host.add_child(fire)
	host.register_prop(fire)
	fire.expired.connect(_on_fire_expired.bind(fire))
	_fires.append(fire)
	return true


func _capture_fires() -> Array:
	var stored: Array = []
	for fire in _fires:
		if fire == null or not is_instance_valid(fire) or not fire is Campfire:
			continue
		var camp := fire as Campfire
		if not camp.lit or camp.burn_left <= 0.0:
			continue
		var cell := _fire_world_cell(camp)
		stored.append([cell.x, cell.y, camp.burn_left])
	return stored


func _fire_world_cell(fire: Node2D) -> Vector2i:
	var host := fire.get_parent()
	if host is MapChunk:
		var chunk := host as MapChunk
		var local := chunk.cell_of_prop(fire)
		return Vector2i(
			chunk.chunk_x * ChunkGenerator.WIDTH + local.x,
			chunk.chunk_y * ChunkGenerator.HEIGHT + local.y
		)
	return ChunkGenerator.world_cell_at(fire.global_position)


func _restore_fires(entries: Array) -> void:
	_drop_fires()
	for item in entries:
		if item is Array and item.size() >= 3:
			place_saved_fire(Vector2i(int(item[0]), int(item[1])), float(item[2]))


func _drop_fires() -> void:
	var held: Array[Node2D] = []
	held.append_array(_fires)
	for fire in held:
		_expire_fire(fire, false)


func _campfire_block_reason(world_cell: Vector2i) -> String:
	var host := _chunk_at(ChunkGenerator.chunk_of_cell(world_cell))
	if host == null:
		return "Cannot light a fire there."
	var local := ChunkGenerator.local_of_cell(world_cell)
	if generator.is_blocked(host.tile_kind(local)):
		return "Cannot light a fire in the water."
	if host.cell_occupied(local):
		return "That spot is taken."
	return ""


func _toggle_fullscreen() -> void:
	var win := get_window()
	if win == null:
		return
	if win.mode == Window.MODE_FULLSCREEN or win.mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
		win.mode = Window.MODE_WINDOWED
		PlayWindow.fit(win)
	else:
		win.mode = Window.MODE_FULLSCREEN


func _fit_camera() -> void:
	# The clear color is not shaded by the night tint. Keep the view on loaded woods.
	if _camera == null or _chunks.is_empty():
		return
	var min_x := 1000000
	var min_y := 1000000
	var max_x := -1000000
	var max_y := -1000000
	var width := ChunkGenerator.WIDTH * ChunkGenerator.TILE
	var height := ChunkGenerator.HEIGHT * ChunkGenerator.TILE
	for chunk: MapChunk in _chunks.values():
		if chunk == null or not is_instance_valid(chunk):
			continue
		min_x = mini(min_x, int(chunk.position.x))
		min_y = mini(min_y, int(chunk.position.y))
		max_x = maxi(max_x, int(chunk.position.x) + width)
		max_y = maxi(max_y, int(chunk.position.y) + height)
	_camera.limit_left = min_x
	_camera.limit_top = min_y
	_camera.limit_right = max_x
	_camera.limit_bottom = max_y


func _ensure_music() -> void:
	if _music == null or not is_inside_tree():
		return
	var path := ""
	if _chunk != null and _chunk.biome != null:
		path = _chunk.biome.music_path
	if path.is_empty() or not ResourceLoader.exists(path):
		_music.stop()
		_music.stream = null
		return
	if _music.stream != null and _music.playing and _music.stream.resource_path == path:
		return
	var stream := load(path)
	if stream == null or not stream is AudioStream:
		return
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	_music.stream = stream
	_music.play()


func _on_music_finished() -> void:
	if _music != null and _music.stream != null:
		_music.play()


func _spawn_leaves() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	_player.add_child(LeafBurst.new())


func _refresh_hud() -> void:
	var biome_name := "?"
	if _chunk != null and _chunk.biome != null:
		biome_name = _chunk.biome.display_name
	var phase := "day"
	if _clock != null:
		phase = _clock.phase()
	_hud.show_play(world_seed, biome_name, supplies, phase, _hint, skills)


func _reveal_visible_view() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var cell := ChunkGenerator.world_cell_at(_player.global_position)
	var opened := _fog.reveal_circle(cell)
	if opened or cell != _minimap_cell:
		_minimap_cell = cell
		_refresh_minimap()


func _refresh_minimap() -> void:
	if _hud == null:
		return
	_hud.show_minimap(_fog.paint(_minimap_sample, _minimap_color, _minimap_cell))


func _minimap_sample(cell: Vector2i) -> int:
	return _sample_world_tile(cell.x, cell.y)


func _minimap_color(kind: int) -> Color:
	var biome: Biome = null
	if _chunk != null and _chunk.biome != null:
		biome = _chunk.biome
	else:
		biome = catalog.get_biome(&"coastal_north")
	if biome == null:
		return Color(0.24, 0.36, 0.20)
	match kind:
		ChunkGenerator.TILE_WATER:
			return biome.water_color
		ChunkGenerator.TILE_SHORE:
			return biome.shore_color
		ChunkGenerator.TILE_PEAT:
			return biome.peat_color
		ChunkGenerator.TILE_GRANITE:
			return biome.granite_color
		ChunkGenerator.TILE_TRAIL:
			return biome.trail_color
		_:
			return biome.moss_color


func is_blocked_pixel(global_px: Vector2, mover: Node2D = null) -> bool:
	var cell := ChunkGenerator.world_cell_at(global_px)
	var key := ChunkGenerator.chunk_of_cell(cell)
	var host: MapChunk = _chunks.get(key)
	if host == null or not is_instance_valid(host) or host.data.is_empty():
		return true
	var local := ChunkGenerator.local_of_cell(cell)
	if generator.is_blocked(host.tile_kind(local)):
		return true
	if host.cell_blocks_walk(local):
		return true
	if _caribou != null and is_instance_valid(_caribou) and mover != _caribou:
		if ChunkGenerator.world_cell_at(_caribou.global_position) == cell:
			return true
	if mover == _caribou and _player != null and is_instance_valid(_player):
		if ChunkGenerator.world_cell_at(_player.global_position) == cell:
			return true
	return false


func _adjust_foreign_cell(world_cell: Vector2i, delta: int, walk: bool, occupy: bool) -> void:
	var host := _chunk_at(ChunkGenerator.chunk_of_cell(world_cell))
	if host == null:
		return
	host.adjust_cell(ChunkGenerator.local_of_cell(world_cell), delta, walk, occupy)


func _burn_fires(seconds: float) -> void:
	if seconds <= 0.0:
		return
	var dead: Array[Node2D] = []
	for fire in _fires:
		if fire == null or not is_instance_valid(fire):
			continue
		if fire is Campfire and (fire as Campfire).consume(seconds):
			dead.append(fire)
	for fire in dead:
		_expire_fire(fire, false)


func _on_fire_expired(fire: Node2D) -> void:
	_expire_fire(fire, _sleep_phase == "")


func _expire_fire(fire: Node2D, tell: bool) -> void:
	if fire == null:
		return
	_fires.erase(fire)
	if not is_instance_valid(fire):
		return
	var host := fire.get_parent()
	if host is MapChunk:
		(host as MapChunk).unregister_prop(fire)
	if fire.get_parent() != null:
		fire.get_parent().remove_child(fire)
	fire.queue_free()
	if tell:
		_hint = "The fire burned out."
		_refresh_hud()


func is_near_fire(world_px: Vector2) -> bool:
	for fire in _fires:
		if fire == null or not is_instance_valid(fire):
			continue
		if fire.global_position.distance_to(world_px) <= FIRE_WARM_PIXELS:
			return true
	return false


func _try_sleep() -> void:
	if _player == null or _clock == null or _sleep_phase != "":
		return
	if not is_near_fire(_player.global_position):
		_hint = "Sleep by a fire."
		_refresh_hud()
		return
	if not _clock.can_sleep():
		_hint = "Sleep when it is dark."
		_refresh_hud()
		return
	_sleep_phase = "out"
	_sleep_t = 0.0
	_clock.set_process(false)


func _tick_sleep(delta: float) -> void:
	_sleep_t += delta
	if _sleep_phase == "out":
		_hud.set_fade(clampf(_sleep_t / SLEEP_OUT, 0.0, 1.0))
		if _sleep_t >= SLEEP_OUT:
			_clock.set_process(true)
			var skipped := _clock.seconds_until_dawn()
			if not _clock.sleep_to_dawn():
				_sleep_phase = ""
				_hud.set_fade(0.0)
				_hint = "Sleep when it is dark."
				_refresh_hud()
				return
			_burn_fires(skipped)
			supplies.cold_acc = 0.0
			supplies.heal_acc = 0.0
			_sleep_phase = "hold"
			_sleep_t = 0.0
			if is_near_fire(_player.global_position):
				_hint = "Slept by the fire."
			else:
				_hint = "Slept by the fire. It burned out."
			_refresh_hud()
	elif _sleep_phase == "hold":
		_hud.set_fade(1.0)
		if _sleep_t >= SLEEP_HOLD:
			_sleep_phase = "in"
			_sleep_t = 0.0
	elif _sleep_phase == "in":
		_hud.set_fade(1.0 - clampf(_sleep_t / SLEEP_IN, 0.0, 1.0))
		if _sleep_t >= SLEEP_IN:
			_sleep_phase = ""
			_hud.set_fade(0.0)
