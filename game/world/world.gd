class_name World
extends Node2D

@export var world_seed: int = 11

var catalog: BiomeCatalog = BiomeCatalog.new()
var generator: ChunkGenerator = ChunkGenerator.new()
var _chunk: MapChunk
var _player: Player
var _hud: GameHud
var _camera: Camera2D


func _ready() -> void:
	y_sort_enabled = true
	catalog.load_all()
	_hud = GameHud.new()
	add_child(_hud)
	_player = Player.new()
	_player.world = self
	_camera = Camera2D.new()
	_camera.position_smoothing_enabled = false
	_player.add_child(_camera)
	rebuild()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		world_seed = (world_seed * 1103515245 + 12345) & 0x7fffffff
		rebuild()


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
	_camera.make_current()
	_hud.show_status(world_seed, biome.display_name if biome else "?")


func is_blocked_pixel(global_px: Vector2) -> bool:
	if _chunk == null:
		return true
	var local := global_px - _chunk.position
	return generator.is_blocked(_chunk.tile_at_local_pixel(local))
