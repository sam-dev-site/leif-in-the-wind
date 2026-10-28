class_name ChunkGenerator
extends RefCounted

## Deterministic chunk fill from a world seed. Same seed + coords = same woods.

const TILE := 16
const WIDTH := 48
const HEIGHT := 48

const TILE_WATER := 0
const TILE_SHORE := 1
const TILE_MOSS := 2
const TILE_PEAT := 3
const TILE_GRANITE := 4
const TILE_TRAIL := 5

const TREE_NONE := ""
const FORAGE_NONE := ""
const ROCK_NONE := ""
const CLUTTER_NONE := ""
const FALLEN_NONE := ""

const WATER_ROWS := 6
const SHORE_ROWS := 2
## 64px fir log, centered: home tile plus two on each side.
const FALLEN_HALF := 2


func generate(world_seed: int, chunk_x: int, chunk_y: int, biome: Biome) -> Dictionary:
	var tiles := PackedInt32Array()
	tiles.resize(WIDTH * HEIGHT)
	var trees: Array[String] = []
	trees.resize(WIDTH * HEIGHT)
	var forage: Array[String] = []
	forage.resize(WIDTH * HEIGHT)
	var rocks: Array[String] = []
	rocks.resize(WIDTH * HEIGHT)
	var clutter: Array[String] = []
	clutter.resize(WIDTH * HEIGHT)
	var fallen: Array[String] = []
	fallen.resize(WIDTH * HEIGHT)
	for i in WIDTH * HEIGHT:
		trees[i] = TREE_NONE
		forage[i] = FORAGE_NONE
		rocks[i] = ROCK_NONE
		clutter[i] = CLUTTER_NONE
		fallen[i] = FALLEN_NONE

	for ty in HEIGHT:
		for tx in WIDTH:
			var i := _idx(tx, ty)
			tiles[i] = _ground_tile(world_seed, chunk_x, chunk_y, tx, ty)

	_carve_caribou_trail(world_seed, chunk_x, chunk_y, tiles)

	if biome != null and not biome.tree_species.is_empty():
		_scatter_trees(world_seed, chunk_x, chunk_y, tiles, trees, biome)
	if biome != null and not biome.forage_species.is_empty():
		_scatter_forage(world_seed, chunk_x, chunk_y, tiles, trees, forage, biome)
	_scatter_rocks(world_seed, chunk_x, chunk_y, tiles, trees, forage, rocks)
	_scatter_fallen(world_seed, chunk_x, chunk_y, tiles, trees, forage, rocks, fallen, biome)
	_scatter_clutter(world_seed, chunk_x, chunk_y, tiles, trees, forage, rocks, fallen, clutter)

	var spawn := _spawn_on_shore(tiles)
	return {
		"tiles": tiles,
		"trees": trees,
		"forage": forage,
		"rocks": rocks,
		"clutter": clutter,
		"fallen": fallen,
		"spawn": spawn,
		"biome_id": biome.id if biome else &"",
	}


func is_blocked(tile_kind: int) -> bool:
	return tile_kind == TILE_WATER


## Cheap walk-check when the chunk is not built yet. No nodes, no sprites.
func peek_ground(world_seed: int, world_tx: int, world_ty: int) -> int:
	var cx := floor_div(world_tx, WIDTH)
	var cy := floor_div(world_ty, HEIGHT)
	return _ground_tile(world_seed, cx, cy, posmod(world_tx, WIDTH), posmod(world_ty, HEIGHT))


static func floor_div(value: int, size: int) -> int:
	return int(floor(float(value) / float(size)))


static func chunk_of_cell(cell: Vector2i) -> Vector2i:
	return Vector2i(floor_div(cell.x, WIDTH), floor_div(cell.y, HEIGHT))


static func local_of_cell(cell: Vector2i) -> Vector2i:
	return Vector2i(posmod(cell.x, WIDTH), posmod(cell.y, HEIGHT))


static func world_cell_at(px: Vector2) -> Vector2i:
	var tile := float(TILE)
	return Vector2i(int(floor(px.x / tile)), int(floor(px.y / tile)))


func _idx(tx: int, ty: int) -> int:
	return ty * WIDTH + tx


func _hash(world_seed: int, x: int, y: int, salt: int) -> int:
	var h := world_seed
	h = (h * 374761393 + x * 668265263) ^ (y * 1274126177) ^ salt
	h = (h ^ (h >> 13)) * 1274126177
	return h & 0x7fffffff


func _rand01(world_seed: int, x: int, y: int, salt: int) -> float:
	return float(_hash(world_seed, x, y, salt) % 10000) / 10000.0


func _ground_tile(world_seed: int, chunk_x: int, chunk_y: int, tx: int, ty: int) -> int:
	# +Y is south in Godot. The Vinland shore runs east-west; sea is south of every landing chunk.
	if chunk_y > 0:
		return TILE_WATER
	if chunk_y == 0:
		if ty >= HEIGHT - WATER_ROWS:
			return TILE_WATER
		if ty >= HEIGHT - WATER_ROWS - SHORE_ROWS:
			return TILE_SHORE

	var n := _rand01(world_seed, chunk_x * WIDTH + tx, chunk_y * HEIGHT + ty, 11)
	if n < 0.22:
		return TILE_PEAT
	return TILE_MOSS


func _carve_caribou_trail(world_seed: int, chunk_x: int, chunk_y: int, tiles: PackedInt32Array) -> void:
	if chunk_x != 0 or chunk_y > 0:
		return
	var tx := WIDTH / 2 + (_hash(world_seed, 0, 0, 99) % 7) - 3
	var shore_wy := HEIGHT - WATER_ROWS - SHORE_ROWS - 1
	var min_wy := chunk_y * HEIGHT
	var max_wy := chunk_y * HEIGHT + HEIGHT - 1
	var wy := shore_wy
	while wy >= min_wy:
		if wy <= max_wy:
			var lty := wy - chunk_y * HEIGHT
			if tx >= 1 and tx < WIDTH - 1 and tiles[_idx(tx, lty)] != TILE_WATER:
				var gap := _hash(world_seed, tx, wy, 81) % 6
				var on_seam := lty == 0 or lty == HEIGHT - 1 or wy == shore_wy
				if gap != 0 or on_seam:
					tiles[_idx(tx, lty)] = TILE_TRAIL
		if wy == min_wy:
			break
		var wiggle := _hash(world_seed, tx, wy, 77) % 5
		if wiggle == 0 and tx > 2:
			tx -= 1
		elif wiggle == 1 and tx < WIDTH - 3:
			tx += 1
		wy -= 1


func _scatter_trees(
	world_seed: int,
	chunk_x: int,
	chunk_y: int,
	tiles: PackedInt32Array,
	trees: Array[String],
	biome: Biome,
) -> void:
	var species := biome.tree_species
	for ty in HEIGHT:
		for tx in WIDTH:
			var i := _idx(tx, ty)
			var kind := tiles[i]
			if kind == TILE_WATER or kind == TILE_SHORE or kind == TILE_TRAIL:
				continue
			var chance := 0.16 if kind == TILE_MOSS else 0.07
			if _rand01(world_seed, chunk_x * WIDTH + tx, chunk_y * HEIGHT + ty, 21) > chance:
				continue
			var pick := _hash(world_seed, tx, ty, 33) % species.size()
			trees[i] = species[pick]


func _scatter_forage(
	world_seed: int,
	chunk_x: int,
	chunk_y: int,
	tiles: PackedInt32Array,
	trees: Array[String],
	forage: Array[String],
	biome: Biome,
) -> void:
	var species := biome.forage_species
	for ty in HEIGHT:
		for tx in WIDTH:
			var i := _idx(tx, ty)
			if trees[i] != TREE_NONE:
				continue
			var kind := tiles[i]
			if kind != TILE_MOSS and kind != TILE_PEAT:
				continue
			var chance := 0.05 if kind == TILE_PEAT else 0.03
			if _rand01(world_seed, chunk_x * WIDTH + tx, chunk_y * HEIGHT + ty, 44) > chance:
				continue
			# Peat/bog prefers bakeapple; moss prefers blueberry when both exist.
			var name := species[0]
			if species.size() > 1:
				var names := Array(species)
				if kind == TILE_PEAT:
					name = "bakeapple" if names.has("bakeapple") else species[0]
				else:
					name = "blueberry" if names.has("blueberry") else species[1]
			forage[i] = name


func _scatter_rocks(
	world_seed: int,
	chunk_x: int,
	chunk_y: int,
	tiles: PackedInt32Array,
	trees: Array[String],
	forage: Array[String],
	rocks: Array[String],
) -> void:
	for ty in HEIGHT:
		for tx in WIDTH:
			var i := _idx(tx, ty)
			if trees[i] != TREE_NONE or forage[i] != FORAGE_NONE:
				continue
			var kind := tiles[i]
			if kind != TILE_MOSS and kind != TILE_PEAT:
				continue
			if _rand01(world_seed, chunk_x * WIDTH + tx, chunk_y * HEIGHT + ty, 55) > 0.045:
				continue
			rocks[i] = "granite"


func _scatter_fallen(
	world_seed: int,
	chunk_x: int,
	chunk_y: int,
	tiles: PackedInt32Array,
	trees: Array[String],
	forage: Array[String],
	rocks: Array[String],
	fallen: Array[String],
	biome: Biome,
) -> void:
	var species: PackedStringArray = PackedStringArray()
	if biome != null:
		species = biome.tree_species
	if species.is_empty():
		return
	for ty in HEIGHT:
		for tx in WIDTH:
			var i := _idx(tx, ty)
			if trees[i] != TREE_NONE or forage[i] != FORAGE_NONE or rocks[i] != ROCK_NONE:
				continue
			var kind := tiles[i]
			if kind != TILE_MOSS and kind != TILE_PEAT:
				continue
			if _rand01(world_seed, chunk_x * WIDTH + tx, chunk_y * HEIGHT + ty, 66) > 0.012:
				continue
			if not _fallen_span_clear(tx, ty, tiles, trees, forage, rocks, fallen):
				continue
			var pick := _hash(world_seed, tx, ty, 67) % species.size()
			fallen[i] = species[pick]


func _fallen_span_clear(
	tx: int,
	ty: int,
	tiles: PackedInt32Array,
	trees: Array[String],
	forage: Array[String],
	rocks: Array[String],
	fallen: Array[String],
) -> bool:
	for dx in range(-FALLEN_HALF, FALLEN_HALF + 1):
		var x := tx + dx
		if x < 0 or x >= WIDTH:
			continue
		var j := _idx(x, ty)
		if trees[j] != TREE_NONE or forage[j] != FORAGE_NONE or rocks[j] != ROCK_NONE:
			return false
		if tiles[j] == TILE_WATER:
			return false
	for dx in range(-FALLEN_HALF * 2, FALLEN_HALF * 2 + 1):
		var x := tx + dx
		if x < 0 or x >= WIDTH:
			continue
		if fallen[_idx(x, ty)] != FALLEN_NONE:
			return false
	return true


func _scatter_clutter(
	world_seed: int,
	chunk_x: int,
	chunk_y: int,
	tiles: PackedInt32Array,
	trees: Array[String],
	forage: Array[String],
	rocks: Array[String],
	fallen: Array[String],
	clutter: Array[String],
) -> void:
	var names: PackedStringArray = ["sphagnum", "needles", "fir_branch"]
	for ty in HEIGHT:
		for tx in WIDTH:
			var i := _idx(tx, ty)
			if trees[i] != TREE_NONE or forage[i] != FORAGE_NONE:
				continue
			if rocks[i] != ROCK_NONE or fallen[i] != FALLEN_NONE:
				continue
			var kind := tiles[i]
			if kind != TILE_MOSS and kind != TILE_PEAT:
				continue
			if _rand01(world_seed, chunk_x * WIDTH + tx, chunk_y * HEIGHT + ty, 77) > 0.22:
				continue
			clutter[i] = names[_hash(world_seed, tx, ty, 78) % names.size()]


func _spawn_on_shore(tiles: PackedInt32Array) -> Vector2i:
	var ty := HEIGHT - WATER_ROWS - SHORE_ROWS
	if ty < 0:
		ty = 0
	var tx := WIDTH / 2
	for x in WIDTH:
		var candidate := WIDTH / 2 + ((x / 2 + 1) * (1 if x % 2 == 0 else -1))
		if candidate < 0 or candidate >= WIDTH:
			continue
		if tiles[_idx(candidate, ty)] != TILE_WATER:
			tx = candidate
			break
	return Vector2i(tx, ty)
