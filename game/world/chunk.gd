class_name MapChunk
extends Node2D

var chunk_x: int = 0
var chunk_y: int = 0
var data: Dictionary = {}
var biome: Biome
var generator: ChunkGenerator = ChunkGenerator.new()


func setup(world_seed: int, cx: int, cy: int, biome_data: Biome) -> void:
	chunk_x = cx
	chunk_y = cy
	biome = biome_data
	data = generator.generate(world_seed, cx, cy, biome_data)
	position = Vector2(cx * ChunkGenerator.WIDTH * ChunkGenerator.TILE, cy * ChunkGenerator.HEIGHT * ChunkGenerator.TILE)
	queue_redraw()
	_spawn_props()


func spawn_local() -> Vector2:
	var cell: Vector2i = data.get("spawn", Vector2i.ZERO)
	return Vector2(
		(cell.x + 0.5) * ChunkGenerator.TILE,
		(cell.y + 0.5) * ChunkGenerator.TILE
	)


func tile_at_local_pixel(local: Vector2) -> int:
	return tile_kind(cell_at_point(local))


func tile_kind(cell: Vector2i) -> int:
	if data.is_empty():
		return ChunkGenerator.TILE_WATER
	if cell.x < 0 or cell.y < 0 or cell.x >= ChunkGenerator.WIDTH or cell.y >= ChunkGenerator.HEIGHT:
		return ChunkGenerator.TILE_WATER
	return (data["tiles"] as PackedInt32Array)[cell.y * ChunkGenerator.WIDTH + cell.x]


## Player feet and other free points sit in the middle of a tile.
static func cell_at_point(point: Vector2) -> Vector2i:
	var tile := float(ChunkGenerator.TILE)
	return Vector2i(int(floor(point.x / tile)), int(floor(point.y / tile)))


## Trees, bushes, stumps, and fires are anchored on the bottom edge of their tile.
static func cell_at_prop(prop_position: Vector2) -> Vector2i:
	var tile := float(ChunkGenerator.TILE)
	var tx := int(floor(prop_position.x / tile))
	var ty := int(round(prop_position.y / tile)) - 1
	return Vector2i(tx, ty)


static func anchor_for_cell(cell: Vector2i) -> Vector2:
	var tile := float(ChunkGenerator.TILE)
	return Vector2((float(cell.x) + 0.5) * tile, (float(cell.y) + 1.0) * tile)


func cell_of_prop(node: Node2D) -> Vector2i:
	return cell_at_prop(node.position)


func prop_nodes() -> Array[Node2D]:
	var found: Array[Node2D] = []
	for child in get_children():
		if not child is Node2D:
			continue
		var node := child as Node2D
		if node.is_queued_for_deletion():
			continue
		if not node.has_meta("kind") or not node.has_meta("species"):
			continue
		var kind := str(node.get_meta("kind"))
		if kind != "tree" and kind != "forage":
			continue
		if bool(node.get_meta("harvested", false)):
			continue
		found.append(node)
	return found


func cell_occupied(cell: Vector2i) -> bool:
	for child in get_children():
		if not child is Node2D:
			continue
		var node := child as Node2D
		if node.is_queued_for_deletion() or not node.has_meta("kind"):
			continue
		var kind := str(node.get_meta("kind"))
		if kind != "tree" and kind != "forage" and kind != "campfire" and kind != "stump":
			continue
		if cell_of_prop(node) == cell:
			return true
	return false


func release_prop(node: Node2D) -> void:
	if node == null or not is_instance_valid(node):
		return
	var kind := str(node.get_meta("kind", ""))
	var at := node.position
	_clear_prop_cell(node)
	if node.get_parent() == self:
		remove_child(node)
	node.queue_free()
	if kind == "tree":
		add_child(_make_stump(at))


func _clear_prop_cell(node: Node2D) -> void:
	if data.is_empty():
		return
	var cell := cell_of_prop(node)
	if cell.x < 0 or cell.y < 0 or cell.x >= ChunkGenerator.WIDTH or cell.y >= ChunkGenerator.HEIGHT:
		return
	var i := cell.y * ChunkGenerator.WIDTH + cell.x
	var trees: Array = data["trees"]
	var forage: Array = data["forage"]
	trees[i] = ChunkGenerator.TREE_NONE
	forage[i] = ChunkGenerator.FORAGE_NONE


func _draw() -> void:
	if data.is_empty() or biome == null:
		return
	var tiles: PackedInt32Array = data["tiles"]
	for ty in ChunkGenerator.HEIGHT:
		for tx in ChunkGenerator.WIDTH:
			var kind := tiles[ty * ChunkGenerator.WIDTH + tx]
			var rect := Rect2(tx * ChunkGenerator.TILE, ty * ChunkGenerator.TILE, ChunkGenerator.TILE, ChunkGenerator.TILE)
			draw_rect(rect, _color_for(kind))


func _color_for(kind: int) -> Color:
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


func _spawn_props() -> void:
	var trees: Array = data["trees"]
	var forage: Array = data["forage"]
	for ty in ChunkGenerator.HEIGHT:
		for tx in ChunkGenerator.WIDTH:
			var i := ty * ChunkGenerator.WIDTH + tx
			var origin := Vector2((tx + 0.5) * ChunkGenerator.TILE, (ty + 1) * ChunkGenerator.TILE)
			if trees[i] != ChunkGenerator.TREE_NONE:
				add_child(_make_tree(trees[i], origin))
			elif forage[i] != ChunkGenerator.FORAGE_NONE:
				add_child(_make_forage(forage[i], origin))


func _make_tree(species: String, origin: Vector2) -> Node2D:
	var node := Node2D.new()
	node.position = origin
	var trunk := ColorRect.new()
	trunk.size = Vector2(3, 8)
	trunk.position = Vector2(-1, -8)
	trunk.color = Color(0.28, 0.18, 0.10)
	node.add_child(trunk)
	var crown := ColorRect.new()
	crown.size = Vector2(10, 12)
	crown.position = Vector2(-5, -20)
	crown.color = Color(0.12, 0.24, 0.14) if species == "fir" else Color(0.16, 0.28, 0.16)
	node.add_child(crown)
	node.y_sort_enabled = true
	node.set_meta("species", species)
	node.set_meta("kind", "tree")
	return node


func _make_forage(species: String, origin: Vector2) -> Node2D:
	var node := Node2D.new()
	node.position = origin
	var bush := ColorRect.new()
	bush.size = Vector2(6, 4)
	bush.position = Vector2(-3, -4)
	bush.color = Color(0.18, 0.32, 0.16)
	node.add_child(bush)
	var berry := ColorRect.new()
	berry.size = Vector2(2, 2)
	berry.position = Vector2(-1, -5)
	berry.color = Color(0.78, 0.42, 0.16) if species == "bakeapple" else Color(0.22, 0.22, 0.48)
	node.add_child(berry)
	node.y_sort_enabled = true
	node.set_meta("species", species)
	node.set_meta("kind", "forage")
	return node


func _make_stump(origin: Vector2) -> Node2D:
	var node := Node2D.new()
	node.position = origin
	node.y_sort_enabled = true
	var stump := ColorRect.new()
	stump.size = Vector2(4, 3)
	stump.position = Vector2(-2, -3)
	stump.color = Color(0.32, 0.20, 0.12)
	stump.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_child(stump)
	node.set_meta("kind", "stump")
	return node
