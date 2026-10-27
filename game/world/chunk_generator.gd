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

const WATER_ROWS := 6
const SHORE_ROWS := 2


func generate(world_seed: int, chunk_x: int, chunk_y: int, biome: Biome) -> Dictionary:
	var tiles := PackedInt32Array()
	tiles.resize(WIDTH * HEIGHT)
	var trees: Array[String] = []
	trees.resize(WIDTH * HEIGHT)
	var forage: Array[String] = []
	forage.resize(WIDTH * HEIGHT)
	for i in WIDTH * HEIGHT:
		trees[i] = TREE_NONE
		forage[i] = FORAGE_NONE

	for ty in HEIGHT:
		for tx in WIDTH:
			var i := _idx(tx, ty)
			tiles[i] = _ground_tile(world_seed, chunk_x, chunk_y, tx, ty)

	_carve_caribou_trail(world_seed, chunk_x, chunk_y, tiles)

	if biome != null and not biome.tree_species.is_empty():
		_scatter_trees(world_seed, chunk_x, chunk_y, tiles, trees, biome)
	if biome != null and not biome.forage_species.is_empty():
		_scatter_forage(world_seed, chunk_x, chunk_y, tiles, trees, forage, biome)

	var spawn := _spawn_on_shore(tiles)
	return {
		"tiles": tiles,
		"trees": trees,
		"forage": forage,
		"spawn": spawn,
		"biome_id": biome.id if biome else &"",
	}


func is_blocked(tile_kind: int) -> bool:
	return tile_kind == TILE_WATER


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
	# +Y is south in Godot. Water on the south edge of chunk (0,0) so inland is north.
	if chunk_x == 0 and chunk_y == 0:
		if ty >= HEIGHT - WATER_ROWS:
			return TILE_WATER
		if ty >= HEIGHT - WATER_ROWS - SHORE_ROWS:
			return TILE_SHORE

	var n := _rand01(world_seed, chunk_x * WIDTH + tx, chunk_y * HEIGHT + ty, 11)
	if n < 0.08:
		return TILE_GRANITE
	if n < 0.28:
		return TILE_PEAT
	return TILE_MOSS


func _carve_caribou_trail(world_seed: int, chunk_x: int, chunk_y: int, tiles: PackedInt32Array) -> void:
	if chunk_x != 0 or chunk_y != 0:
		return
	var tx := WIDTH / 2 + (_hash(world_seed, 0, 0, 99) % 7) - 3
	var ty := HEIGHT - WATER_ROWS - SHORE_ROWS - 1
	while ty >= 2:
		if tx >= 1 and tx < WIDTH - 1 and ty < HEIGHT - WATER_ROWS:
			tiles[_idx(tx, ty)] = TILE_TRAIL
			if tx + 1 < WIDTH - 1:
				tiles[_idx(tx + 1, ty)] = TILE_TRAIL
		var wiggle := _hash(world_seed, tx, ty, 77) % 3
		if wiggle == 0 and tx > 2:
			tx -= 1
		elif wiggle == 2 and tx < WIDTH - 4:
			tx += 1
		ty -= 1


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
			if kind == TILE_WATER or kind == TILE_SHORE or kind == TILE_TRAIL or kind == TILE_GRANITE:
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
