class_name NightField
extends RefCounted

## What the cold night adds on this coast. Seeded, gone by dawn.
## Pitch glints, rime, and the caribou's bed. Not a new biome.

const GLINT_CAP := 5
const RIME_GAP := 4
const BED_MIN := 3
const BED_MAX := 6
const NO_CELL := 2147483647

static func night_index(elapsed: float, cycle: float) -> int:
	if cycle <= 0.0:
		return 0
	return int(floor(elapsed / cycle))


## Half a campfire's light. The gradient texture is 64px; scale is half of Campfire.LIGHT_SCALE.
static func torch_pool_pixels() -> float:
	return 32.0 * Campfire.LIGHT_SCALE * 0.5


static func in_torch_pool(from_px: Vector2, tree_px: Vector2) -> bool:
	return from_px.distance_to(tree_px) <= torch_pool_pixels()


static func pick_glints(world_seed: int, night_i: int, cells: Array[Vector2i]) -> Array[Vector2i]:
	var ranked := _ranked(cells, world_seed, night_i, 9100)
	var picked: Array[Vector2i] = []
	for cell in ranked:
		if not _apart(cell, picked, 2):
			continue
		picked.append(cell)
		if picked.size() >= GLINT_CAP:
			break
	return picked


static func pick_rime(world_seed: int, night_i: int, cells: Array[Vector2i], forbidden: Vector2i) -> Array[Vector2i]:
	var ranked := _ranked(cells, world_seed, night_i, 9200)
	var picked: Array[Vector2i] = []
	for cell in ranked:
		if cell == forbidden:
			continue
		if not _apart(cell, picked, RIME_GAP):
			continue
		picked.append(cell)
	return picked


## A moss or peat cell 3–6 tiles off the trail. open_cell says whether that tile can hold him.
static func pick_bed(world_seed: int, night_i: int, trail: Array[Vector2i], open_cell: Callable) -> Vector2i:
	var candidates: Array[Vector2i] = []
	var offsets: Array[int] = [3, -3, 4, -4, 5, -5, 6, -6]
	for base in trail:
		for ox in offsets:
			var cell := Vector2i(base.x + ox, base.y)
			if open_cell.call(cell):
				candidates.append(cell)
	if candidates.is_empty():
		return Vector2i(NO_CELL, NO_CELL)
	var ranked := _ranked(candidates, world_seed, night_i, 9300)
	return ranked[0]


static func chebyshev(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))


static func _apart(cell: Vector2i, picked: Array[Vector2i], gap: int) -> bool:
	for other in picked:
		if chebyshev(cell, other) < gap:
			return false
	return true


static func _ranked(cells: Array[Vector2i], world_seed: int, night_i: int, salt: int) -> Array[Vector2i]:
	var ranked: Array[Vector2i] = []
	for cell in cells:
		ranked.append(cell)
	var use_salt := salt + night_i * 17
	ranked.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var ha := _hash(world_seed, a.x, a.y, use_salt)
		var hb := _hash(world_seed, b.x, b.y, use_salt)
		if ha == hb:
			if a.x == b.x:
				return a.y < b.y
			return a.x < b.x
		return ha < hb
	)
	return ranked


static func _hash(world_seed: int, x: int, y: int, salt: int) -> int:
	var h := world_seed
	h = (h * 374761393 + x * 668265263) ^ (y * 1274126177) ^ salt
	h = (h ^ (h >> 13)) * 1274126177
	return h & 0x7fffffff
