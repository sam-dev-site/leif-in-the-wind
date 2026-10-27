class_name World
extends Node2D

@export var world_seed: int = 11

var catalog: BiomeCatalog = BiomeCatalog.new()
var generator: ChunkGenerator = ChunkGenerator.new()
var supplies: Supplies = Supplies.new()
var _chunk: MapChunk
var _player: Player
var _hud: GameHud
var _camera: Camera2D
var _interact: Interact
var _clock: DayClock
var _night: CanvasModulate
var _hint := ""


func _ready() -> void:
	y_sort_enabled = true
	catalog.load_all()
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
	_interact.acted.connect(_on_acted)
	add_child(_interact)
	rebuild()


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
	elif key.keycode == KEY_F:
		_try_place_campfire()
		get_viewport().set_input_as_handled()


func _on_phase_changed(_next: String) -> void:
	_refresh_hud()


func _on_acted(action: String, species: String) -> void:
	if action == "forage":
		_hint = "Picked %s." % species
	elif action == "chop":
		_hint = "Chopped %s. +%d wood." % [species, Supplies.WOOD_PER_TREE]
	_refresh_hud()


func rebuild() -> void:
	if _player.get_parent() != null:
		_player.get_parent().remove_child(_player)
	if _chunk != null:
		_chunk.queue_free()
		_chunk = null
	_chunk = MapChunk.new()
	_chunk.y_sort_enabled = true
	var biome := catalog.get_biome(catalog.biome_id_at(0, 0))
	_chunk.setup(world_seed, 0, 0, biome)
	add_child(_chunk)
	move_child(_chunk, 0)
	_chunk.add_child(_player)
	_player.position = _chunk.spawn_local()
	_fit_camera()
	_camera.make_current()
	_interact.chunk = _chunk
	_interact.biome = biome
	_hint = ""
	_refresh_hud()


func _try_place_campfire() -> void:
	if _chunk == null or _player == null:
		return
	if supplies.wood < Supplies.CAMPFIRE_WOOD:
		_hint = "Need %d wood for a fire." % Supplies.CAMPFIRE_WOOD
		_refresh_hud()
		return
	var cell := Interact.tile_ahead(_player.position, _player.facing_name())
	var reason := _campfire_block_reason(cell)
	if reason != "":
		_hint = reason
		_refresh_hud()
		return
	if not Campfire.try_place(supplies, false, false):
		_hint = "The fire does not catch."
		_refresh_hud()
		return
	var fire := Campfire.new()
	fire.position = MapChunk.anchor_for_cell(cell)
	_chunk.add_child(fire)
	_hint = "Campfire lit."
	_refresh_hud()


func _campfire_block_reason(cell: Vector2i) -> String:
	if _chunk == null:
		return "Cannot light a fire there."
	if cell.x < 0 or cell.y < 0 or cell.x >= ChunkGenerator.WIDTH or cell.y >= ChunkGenerator.HEIGHT:
		return "Cannot light a fire there."
	if generator.is_blocked(_chunk.tile_kind(cell)):
		return "Cannot light a fire in the water."
	if _chunk.cell_occupied(cell):
		return "That spot is taken."
	return ""


func _fit_camera() -> void:
	# The clear color is not shaded by the night tint. Keep the view on the chunk.
	var origin := _chunk.position
	var width := ChunkGenerator.WIDTH * ChunkGenerator.TILE
	var height := ChunkGenerator.HEIGHT * ChunkGenerator.TILE
	_camera.limit_left = int(origin.x)
	_camera.limit_top = int(origin.y)
	_camera.limit_right = int(origin.x) + width
	_camera.limit_bottom = int(origin.y) + height


func _refresh_hud() -> void:
	var biome_name := "?"
	if _chunk != null and _chunk.biome != null:
		biome_name = _chunk.biome.display_name
	var phase := "day"
	if _clock != null:
		phase = _clock.phase()
	_hud.show_play(world_seed, biome_name, supplies, phase, _hint)


func is_blocked_pixel(global_px: Vector2) -> bool:
	if _chunk == null:
		return true
	var local := global_px - _chunk.position
	return generator.is_blocked(_chunk.tile_at_local_pixel(local))
