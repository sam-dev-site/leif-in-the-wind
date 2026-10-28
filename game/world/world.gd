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
var _minimap_view := Vector2i(99999, 99999)

const SLEEP_OUT := 0.4
const SLEEP_HOLD := 0.12
const SLEEP_IN := 0.7
const FIRE_WARM_PIXELS := 56.0
const PROP_EDGE := 24.0


func _ready() -> void:
	_fit_play_window()
	y_sort_enabled = true
	catalog.load_all()
	_wang.load_coastal()
	_hud = GameHud.new()
	add_child(_hud)
	_player = Player.new()
	_player.world = self
	_player.y_sort_enabled = true
	_camera = Camera2D.new()
	_camera.position_smoothing_enabled = false
	_player.add_child(_camera)
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
	_interact.world = self
	_interact.acted.connect(_on_acted)
	add_child(_interact)
	_music = AudioStreamPlayer.new()
	_music.bus = "Master"
	_music.volume_db = -4.0
	_music.finished.connect(_on_music_finished)
	add_child(_music)
	rebuild()


func _process(delta: float) -> void:
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
	if key.keycode == KEY_R:
		# New coast. Wood and forage stay in hand. Fires were on the old ground.
		world_seed = (world_seed * 1103515245 + 12345) & 0x7fffffff
		rebuild()
		get_viewport().set_input_as_handled()
	elif key.keycode == KEY_E:
		_try_eat()
		get_viewport().set_input_as_handled()
	elif key.keycode == KEY_F:
		_try_place_campfire()
		get_viewport().set_input_as_handled()
	elif key.keycode == KEY_C:
		_try_sleep()
		get_viewport().set_input_as_handled()
	elif key.keycode == KEY_F11:
		_toggle_fullscreen()
		get_viewport().set_input_as_handled()


func _on_phase_changed(_next: String) -> void:
	_refresh_hud()


func _on_acted(action: String, species: String) -> void:
	if action == "forage":
		_hint = "Picked %s." % species
	elif action == "chop":
		_hint = "Chopped %s. +%s wood." % [species, Supplies.wood_label(Supplies.WOOD_PER_TREE)]
	elif action == "clear":
		_hint = "Cleared a branch. +%s wood." % Supplies.wood_label(Supplies.WOOD_PER_BRANCH)
	_refresh_hud()


func rebuild() -> void:
	if _player.get_parent() != null:
		_player.get_parent().remove_child(_player)
	for key in _chunks.keys():
		var old: MapChunk = _chunks[key]
		if old != null and is_instance_valid(old):
			old.queue_free()
	_chunks.clear()
	_fires.clear()
	_chunk = null
	_build_strip()
	var landing: MapChunk = _chunks.get(Vector2i(0, 0))
	add_child(_player)
	_player.global_position = landing.position + landing.spawn_local()
	_reparent_player()
	_cull_far_chunks()
	_fit_camera()
	_camera.make_current()
	_hint = ""
	_fog.clear()
	_minimap_cell = Vector2i(99999, 99999)
	_minimap_view = Vector2i(99999, 99999)
	_reveal_visible_view()
	_refresh_hud()
	_ensure_music()


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
	var result := supplies.try_eat()
	if result == "eat":
		_hint = "Ate a berry. +%s heart." % Supplies.wood_label(Supplies.HEART_STEP)
	elif result == "empty":
		_hint = "No berries to eat."
	elif result == "full":
		_hint = "Hearts are already full."
	_refresh_hud()


func _try_place_campfire() -> void:
	if _chunk == null or _player == null:
		return
	if supplies.wood < Supplies.CAMPFIRE_WOOD:
		_hint = "Need %s wood for a fire." % Supplies.wood_label(Supplies.CAMPFIRE_WOOD)
		_refresh_hud()
		return
	var world_cell := Interact.tile_ahead(_player.global_position, _player.facing_name())
	var reason := _campfire_block_reason(world_cell)
	if reason != "":
		_hint = reason
		_refresh_hud()
		return
	if not Campfire.try_place(supplies, false, false):
		_hint = "The fire does not catch."
		_refresh_hud()
		return
	var key := ChunkGenerator.chunk_of_cell(world_cell)
	var host := _chunk_at(key)
	if host == null:
		_hint = "Cannot light a fire there."
		_refresh_hud()
		return
	var local := ChunkGenerator.local_of_cell(world_cell)
	var fire := Campfire.new()
	fire.position = MapChunk.anchor_for_cell(local)
	host.add_child(fire)
	host.register_prop(fire)
	fire.expired.connect(_on_fire_expired.bind(fire))
	_fires.append(fire)
	_hint = "Campfire lit."
	_refresh_hud()


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


## Keep 480×270. Size the play window to the largest 16:9 that fits this screen.
## Integer 3× needs 1440px; this Surface's desktop is 1368px, so fractional fill is how F5 gets bigger.
func _fit_play_window() -> void:
	if Engine.is_embedded_in_editor():
		return
	if DisplayServer.get_name() == "headless":
		return
	var win := get_window()
	if win == null:
		return
	if win.mode == Window.MODE_FULLSCREEN or win.mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
		return
	var usable := DisplayServer.screen_get_usable_rect(win.current_screen)
	var scale := minf(float(usable.size.x) / 480.0, float(usable.size.y) / 270.0)
	scale = maxf(scale, 1.0)
	var size := Vector2i(int(480.0 * scale), int(270.0 * scale))
	win.mode = Window.MODE_WINDOWED
	win.size = size
	var extra := usable.size - size
	win.position = usable.position + Vector2i(extra.x / 2, extra.y / 2)


func _toggle_fullscreen() -> void:
	var win := get_window()
	if win == null:
		return
	if win.mode == Window.MODE_FULLSCREEN or win.mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
		win.mode = Window.MODE_WINDOWED
		_fit_play_window()
	else:
		win.mode = Window.MODE_FULLSCREEN


func _fit_camera() -> void:
	# The clear color is not shaded by the night tint. Keep the view on loaded woods.
	if _chunks.is_empty():
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
	if _music == null:
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


func _refresh_hud() -> void:
	var biome_name := "?"
	if _chunk != null and _chunk.biome != null:
		biome_name = _chunk.biome.display_name
	var phase := "day"
	if _clock != null:
		phase = _clock.phase()
	_hud.show_play(world_seed, biome_name, supplies, phase, _hint)


func _reveal_visible_view() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var center := _player.global_position
	if _camera != null and is_instance_valid(_camera):
		center = _camera.get_screen_center_position()
	var rect := FogMap.view_rect(center)
	var opened := _fog.reveal_rect(rect)
	var cell := ChunkGenerator.world_cell_at(_player.global_position)
	if opened or cell != _minimap_cell or rect.position != _minimap_view:
		_minimap_cell = cell
		_minimap_view = rect.position
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


func is_blocked_pixel(global_px: Vector2) -> bool:
	var cell := ChunkGenerator.world_cell_at(global_px)
	var key := ChunkGenerator.chunk_of_cell(cell)
	var host: MapChunk = _chunks.get(key)
	if host == null or not is_instance_valid(host) or host.data.is_empty():
		return true
	var local := ChunkGenerator.local_of_cell(cell)
	if generator.is_blocked(host.tile_kind(local)):
		return true
	return host.cell_blocks_walk(local)


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
