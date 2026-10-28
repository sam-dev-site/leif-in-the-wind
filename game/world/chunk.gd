class_name MapChunk
extends Node2D

var chunk_x: int = 0
var chunk_y: int = 0
var data: Dictionary = {}
var biome: Biome
var generator: ChunkGenerator = ChunkGenerator.new()
var world_sample: Callable = Callable()
var foreign_grid: Callable = Callable()
var _wang := WangTiles.new()
var _baked := false
var _floor_img: Image
var _bake_ty := 0
var _grid_live := false
var _walk_block: Dictionary = {}
var _occupy: Dictionary = {}
var _usable: Array[Node2D] = []
static var _tex_cache: Dictionary = {}
static var _stamp_cache: Dictionary = {}
## Keep the 32×32 ringed stump PNG. Draw it smaller so it fits a tile without flattening the rings.
const STUMP_SCALE := 0.6


func use_wang(shared: WangTiles) -> void:
	if shared != null:
		_wang = shared


func setup(world_seed: int, cx: int, cy: int, biome_data: Biome, spawn_now: bool = true) -> void:
	chunk_x = cx
	chunk_y = cy
	biome = biome_data
	data = generator.generate(world_seed, cx, cy, biome_data)
	position = Vector2(cx * ChunkGenerator.WIDTH * ChunkGenerator.TILE, cy * ChunkGenerator.HEIGHT * ChunkGenerator.TILE)
	if not _wang.ready():
		_wang.load_coastal()
	if spawn_now:
		bake_floor()
		spawn_interactive()


func bake_floor() -> void:
	while not bake_floor_step(ChunkGenerator.HEIGHT):
		pass


## A few tile rows at a time, so the title can keep walking while the coast is built.
func bake_floor_step(rows: int) -> bool:
	if _baked:
		return true
	if data.is_empty() or biome == null:
		_baked = true
		return true
	var w := ChunkGenerator.WIDTH * ChunkGenerator.TILE
	var h := ChunkGenerator.HEIGHT * ChunkGenerator.TILE
	if _floor_img == null:
		_floor_img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var end := mini(_bake_ty + maxi(rows, 1), ChunkGenerator.HEIGHT)
	var tiles: PackedInt32Array = data["tiles"]
	var row_from := _bake_ty
	for ty in range(row_from, end):
		for tx in ChunkGenerator.WIDTH:
			if not _wang.blit_to_image(_floor_img, tx, ty, _sample_ground):
				_floor_img.fill_rect(
					Rect2i(tx * ChunkGenerator.TILE, ty * ChunkGenerator.TILE, ChunkGenerator.TILE, ChunkGenerator.TILE),
					_color_for(tiles[ty * ChunkGenerator.WIDTH + tx])
				)
	for ty in range(row_from, end):
		for tx in ChunkGenerator.WIDTH:
			_stamp_paint_clutter(_floor_img, tx, ty)
	_bake_ty = end
	if _bake_ty < ChunkGenerator.HEIGHT:
		return false
	var floor := Sprite2D.new()
	floor.texture = ImageTexture.create_from_image(_floor_img)
	floor.centered = false
	floor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	floor.z_as_relative = false
	floor.z_index = -20
	add_child(floor)
	move_child(floor, 0)
	_floor_img = null
	_baked = true
	return true


func spawn_interactive() -> void:
	if data.is_empty():
		return
	_grid_live = true
	var n := ChunkGenerator.WIDTH * ChunkGenerator.HEIGHT
	for i in n:
		_spawn_at(i, true)


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


func cells_of_prop(node: Node2D) -> Array[Vector2i]:
	var home := cell_of_prop(node)
	var half_x := 0
	if str(node.get_meta("kind", "")) == "fallen":
		half_x = int(node.get_meta("span_x", ChunkGenerator.FALLEN_HALF))
	var cells: Array[Vector2i] = []
	for dx in range(-half_x, half_x + 1):
		cells.append(home + Vector2i(dx, 0))
	return cells


func prop_nodes() -> Array[Node2D]:
	if _grid_live:
		var live: Array[Node2D] = []
		for node in _usable:
			if node == null or not is_instance_valid(node) or node.is_queued_for_deletion():
				continue
			if bool(node.get_meta("harvested", false)):
				continue
			live.append(node)
		return live
	return _scan_usable()


func cell_blocks_walk(cell: Vector2i) -> bool:
	if _grid_live:
		return int(_walk_block.get(cell, 0)) > 0
	return _scan_kind(cell, true)


func cell_occupied(cell: Vector2i) -> bool:
	if _grid_live:
		return int(_occupy.get(cell, 0)) > 0
	return _scan_kind(cell, false)


func register_prop(node: Node2D) -> void:
	if node == null or not is_instance_valid(node):
		return
	if bool(node.get_meta("_grid", false)):
		return
	_grid_live = true
	node.set_meta("_grid", true)
	var kind := str(node.get_meta("kind", ""))
	var walk := _kind_blocks_walk(kind)
	var occupy := _kind_occupies(kind)
	for cell in cells_of_prop(node):
		_adjust_cell(cell, 1, walk, occupy)
	if _kind_usable(kind, str(node.get_meta("species", ""))):
		_usable.append(node)


func unregister_prop(node: Node2D) -> void:
	if node == null or not bool(node.get_meta("_grid", false)):
		return
	node.set_meta("_grid", false)
	var kind := str(node.get_meta("kind", ""))
	var walk := _kind_blocks_walk(kind)
	var occupy := _kind_occupies(kind)
	for cell in cells_of_prop(node):
		_adjust_cell(cell, -1, walk, occupy)
	_usable.erase(node)


func adjust_cell(cell: Vector2i, delta: int, walk: bool, occupy: bool) -> void:
	_grid_live = true
	if walk:
		_walk_block[cell] = maxi(0, int(_walk_block.get(cell, 0)) + delta)
	if occupy:
		_occupy[cell] = maxi(0, int(_occupy.get(cell, 0)) + delta)


func _adjust_cell(cell: Vector2i, delta: int, walk: bool, occupy: bool) -> void:
	if cell.x >= 0 and cell.y >= 0 and cell.x < ChunkGenerator.WIDTH and cell.y < ChunkGenerator.HEIGHT:
		adjust_cell(cell, delta, walk, occupy)
		return
	if not foreign_grid.is_valid():
		adjust_cell(cell, delta, walk, occupy)
		return
	var world_cell := Vector2i(chunk_x * ChunkGenerator.WIDTH + cell.x, chunk_y * ChunkGenerator.HEIGHT + cell.y)
	foreign_grid.call(world_cell, delta, walk, occupy)


func release_prop(node: Node2D) -> void:
	if node == null or not is_instance_valid(node):
		return
	var kind := str(node.get_meta("kind", ""))
	var species := str(node.get_meta("species", ""))
	var at := node.position
	unregister_prop(node)
	_clear_prop_cell(node)
	if node.get_parent() == self:
		remove_child(node)
	node.queue_free()
	if kind == "tree":
		_place(_make_stump(at, species))


func _place(node: Node2D) -> void:
	add_child(node)
	register_prop(node)


func _kind_blocks_walk(kind: String) -> bool:
	return kind == "tree" or kind == "rock" or kind == "fallen" or kind == "campfire"


func _kind_occupies(kind: String) -> bool:
	return kind == "tree" or kind == "forage" or kind == "campfire" or kind == "stump" or kind == "rock" or kind == "fallen"


func _kind_usable(kind: String, species: String) -> bool:
	if kind == "tree" or kind == "forage" or kind == "fallen" or kind == "branch":
		return true
	return kind == "clutter" and Supplies.is_branch(species)


func _scan_usable() -> Array[Node2D]:
	var found: Array[Node2D] = []
	for child in get_children():
		if not child is Node2D:
			continue
		var node := child as Node2D
		if node.is_queued_for_deletion():
			continue
		if not node.has_meta("kind") or not node.has_meta("species"):
			continue
		if bool(node.get_meta("harvested", false)):
			continue
		if _kind_usable(str(node.get_meta("kind")), str(node.get_meta("species"))):
			found.append(node)
	return found


func _scan_kind(cell: Vector2i, walk: bool) -> bool:
	for child in get_children():
		if not child is Node2D:
			continue
		var node := child as Node2D
		if node.is_queued_for_deletion() or not node.has_meta("kind"):
			continue
		if walk and bool(node.get_meta("harvested", false)):
			continue
		var kind := str(node.get_meta("kind"))
		if walk and not _kind_blocks_walk(kind):
			continue
		if not walk and not _kind_occupies(kind):
			continue
		if cells_of_prop(node).has(cell):
			return true
	return false


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
	if data.has("rocks"):
		(data["rocks"] as Array)[i] = ChunkGenerator.ROCK_NONE
	if data.has("fallen"):
		(data["fallen"] as Array)[i] = ChunkGenerator.FALLEN_NONE
	if data.has("clutter"):
		(data["clutter"] as Array)[i] = ChunkGenerator.CLUTTER_NONE


func _draw() -> void:
	if _baked or data.is_empty() or biome == null:
		return
	var tiles: PackedInt32Array = data["tiles"]
	for ty in ChunkGenerator.HEIGHT:
		for tx in ChunkGenerator.WIDTH:
			var kind := tiles[ty * ChunkGenerator.WIDTH + tx]
			var rect := Rect2(tx * ChunkGenerator.TILE, ty * ChunkGenerator.TILE, ChunkGenerator.TILE, ChunkGenerator.TILE)
			draw_rect(rect, _color_for(kind))


## Prefer the live neighbor chunk. If that is not loaded, sea stays south and forest stays inland.
func _sample_ground(tx: int, ty: int) -> int:
	if world_sample.is_valid():
		return int(world_sample.call(chunk_x * ChunkGenerator.WIDTH + tx, chunk_y * ChunkGenerator.HEIGHT + ty))
	if ty >= ChunkGenerator.HEIGHT:
		return ChunkGenerator.TILE_WATER
	if ty < 0:
		return ChunkGenerator.TILE_MOSS
	if tx < 0:
		return tile_kind(Vector2i(0, ty))
	if tx >= ChunkGenerator.WIDTH:
		return tile_kind(Vector2i(ChunkGenerator.WIDTH - 1, ty))
	return tile_kind(Vector2i(tx, ty))


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


func _is_paint_clutter(species: String) -> bool:
	return species == "sphagnum" or species == "needles"


func _stamp_paint_clutter(img: Image, tx: int, ty: int) -> void:
	var clutter: Array = data.get("clutter", [])
	var i := ty * ChunkGenerator.WIDTH + tx
	if i >= clutter.size():
		return
	var species: String = clutter[i]
	if species == ChunkGenerator.CLUTTER_NONE or not _is_paint_clutter(species):
		return
	var stamp := _stamp_image("clutter", species)
	if stamp == null:
		return
	var dest := Vector2i(
		tx * ChunkGenerator.TILE + (ChunkGenerator.TILE - stamp.get_width()) / 2,
		(ty + 1) * ChunkGenerator.TILE - stamp.get_height()
	)
	if _hash_flip(tx, ty):
		stamp = stamp.duplicate()
		stamp.flip_x()
	img.blend_rect(stamp, Rect2i(0, 0, stamp.get_width(), stamp.get_height()), dest)


func _stamp_image(kind: String, species: String) -> Image:
	var path := "res://art/coastal_north/%s_%s.png" % [kind, species]
	if _stamp_cache.has(path):
		return _stamp_cache[path]
	if not ResourceLoader.exists(path):
		_stamp_cache[path] = null
		return null
	var tex := load(path) as Texture2D
	if tex == null:
		_stamp_cache[path] = null
		return null
	var img := tex.get_image()
	if img != null and img.is_compressed():
		img.decompress()
	_stamp_cache[path] = img
	return img


func _spawn_at(i: int, skip_paint: bool = false) -> bool:
	var trees: Array = data["trees"]
	var forage: Array = data["forage"]
	var rocks: Array = data.get("rocks", [])
	var clutter: Array = data.get("clutter", [])
	var fallen: Array = data.get("fallen", [])
	var tx := i % ChunkGenerator.WIDTH
	var ty := int(i / ChunkGenerator.WIDTH)
	var origin := Vector2((tx + 0.5) * ChunkGenerator.TILE, (ty + 1) * ChunkGenerator.TILE)
	var made := false
	if trees[i] != ChunkGenerator.TREE_NONE:
		_place(_make_tree(trees[i], origin))
		made = true
	elif forage[i] != ChunkGenerator.FORAGE_NONE:
		_place(_make_forage(forage[i], origin))
		made = true
	elif i < fallen.size() and fallen[i] != ChunkGenerator.FALLEN_NONE:
		_place(_make_named_prop("fallen", fallen[i], origin, Color(0.32, 0.20, 0.10), Vector2(14, 4)))
		made = true
	elif i < rocks.size() and rocks[i] != ChunkGenerator.ROCK_NONE:
		_place(_make_named_prop("rock", rocks[i], origin, Color(0.50, 0.50, 0.46), Vector2(8, 6)))
		made = true
	if i < clutter.size() and clutter[i] != ChunkGenerator.CLUTTER_NONE:
		if skip_paint and _is_paint_clutter(clutter[i]):
			return made
		var litter_kind := "branch" if Supplies.is_branch(clutter[i]) else "clutter"
		var litter := _make_named_prop(litter_kind, clutter[i], origin, Color(0.22, 0.28, 0.14), Vector2(6, 3))
		if _hash_flip(tx, ty):
			for child in litter.get_children():
				if child is Sprite2D:
					(child as Sprite2D).flip_h = true
		_place(litter)
		made = true
	return made


func _make_tree(species: String, origin: Vector2) -> Node2D:
	var node := Node2D.new()
	node.position = origin
	node.y_sort_enabled = true
	var sprite := _prop_sprite("tree", species)
	if sprite != null:
		node.add_child(sprite)
	else:
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
	node.set_meta("species", species)
	node.set_meta("kind", "tree")
	return node


func _make_forage(species: String, origin: Vector2) -> Node2D:
	var node := Node2D.new()
	node.position = origin
	node.y_sort_enabled = true
	var sprite := _prop_sprite("forage", species)
	if sprite != null:
		node.add_child(sprite)
	else:
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
	node.set_meta("species", species)
	node.set_meta("kind", "forage")
	return node


func _prop_sprite(kind: String, species: String) -> Sprite2D:
	var path := "res://art/coastal_north/%s_%s.png" % [kind, species]
	if not ResourceLoader.exists(path) and kind == "fallen":
		path = "res://art/coastal_north/fallen_fir.png"
	if not ResourceLoader.exists(path) and kind == "branch":
		path = "res://art/coastal_north/clutter_%s.png" % species
	if not ResourceLoader.exists(path):
		return null
	var tex: Texture2D = _tex_cache.get(path) as Texture2D
	if tex == null:
		tex = load(path) as Texture2D
		if tex != null:
			_tex_cache[path] = tex
	if tex == null:
		return null
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = true
	sprite.offset = Vector2(0, -float(tex.get_height()) * 0.5)
	return sprite


func _make_named_prop(kind: String, species: String, origin: Vector2, fallback: Color, size: Vector2) -> Node2D:
	var node := Node2D.new()
	node.position = origin
	node.y_sort_enabled = true
	var sprite := _prop_sprite(kind, species)
	if sprite != null:
		node.add_child(sprite)
	else:
		var box := ColorRect.new()
		box.size = size
		box.position = Vector2(-size.x * 0.5, -size.y)
		box.color = fallback
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.add_child(box)
	node.set_meta("species", species)
	node.set_meta("kind", kind)
	if kind == "fallen":
		node.set_meta("span_x", _fallen_span_x(sprite, size))
	return node


func _fallen_span_x(sprite: Sprite2D, fallback_size: Vector2) -> int:
	var width := fallback_size.x
	if sprite != null and sprite.texture != null:
		width = float(sprite.texture.get_width())
	var extra := maxf(0.0, width * 0.5 - float(ChunkGenerator.TILE) * 0.5)
	return int(ceil(extra / float(ChunkGenerator.TILE)))


func _hash_flip(tx: int, ty: int) -> bool:
	return ((tx * 13 + ty * 7) & 1) == 1


func _make_stump(origin: Vector2, species: String) -> Node2D:
	var node := Node2D.new()
	node.position = origin
	node.y_sort_enabled = true
	var sprite := _prop_sprite("stump", species)
	if sprite != null:
		sprite.scale = Vector2(STUMP_SCALE, STUMP_SCALE)
		node.add_child(sprite)
	else:
		var stump := ColorRect.new()
		stump.size = Vector2(4, 3)
		stump.position = Vector2(-2, -3)
		stump.color = Color(0.32, 0.20, 0.12)
		stump.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.add_child(stump)
	node.set_meta("kind", "stump")
	node.set_meta("species", species)
	return node
