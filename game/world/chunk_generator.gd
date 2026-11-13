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
## A brook he can wade. Not the main stem, and not fishable water.
const TILE_BROOK := 6

## Valley band and the six-tile stem centered on the seam between chunk -6 and -5.
const VALLEY_SOUTH := -4
const VALLEY_NORTH := -7
## Bayou band. The plains rows between the valley and this band are not built.
const BAYOU_SOUTH := -12
const BAYOU_NORTH := -15
const BAYOU_TREES: PackedStringArray = ["overcup_oak", "water_hickory"]
## Connecticut band. One tile of stem is the drawing. The research gave no width.
const COUNTRY_SOUTH := -16
const COUNTRY_NORTH := -19
const COUNTRY_STEM_Y := -816
const FLOOD_TREES_CT: PackedStringArray = ["eastern_cottonwood", "american_sycamore"]
const TERRACE_TREES: PackedStringArray = ["american_chestnut", "shagbark_hickory"]
const STEM_NORTH := -243
const STEM_SOUTH := -238
const FLOOD_REACH := 4
## He will not pole a gap wider than this. The stem is 6, so the bank is in reach.
const RAFT_REACH := 24
const UPLAND_TREES: PackedStringArray = [
	"sugar_maple", "yellow_birch", "beech", "red_oak", "white_pine", "hemlock",
]
const FLOOD_TREES: PackedStringArray = [
	"silver_maple", "butternut", "bur_oak", "elm", "green_ash", "basswood",
]
const VALLEY_FORAGE: PackedStringArray = [
	"forage_butternut", "riverbank_grape", "fiddlehead",
]

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

	var valley := biome != null and biome.id == &"river_valley"
	var bayou := biome != null and biome.id == &"bayou"
	var country := biome != null and biome.id == &"river_country"
	if valley:
		_fill_valley(world_seed, chunk_x, chunk_y, tiles, trees, forage)
	elif bayou:
		_fill_bayou(world_seed, chunk_x, chunk_y, tiles, trees, forage)
	elif country:
		_fill_country(world_seed, chunk_x, chunk_y, tiles, trees, forage)
	else:
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
	var local_x := posmod(world_tx, WIDTH)
	var local_y := posmod(world_ty, HEIGHT)
	if cy <= VALLEY_SOUTH and cy >= VALLEY_NORTH:
		return _valley_ground(world_seed, cx, cy, local_x, local_y)
	if cy <= BAYOU_SOUTH and cy >= BAYOU_NORTH:
		return _bayou_ground(world_seed, world_tx, world_ty)
	if cy <= COUNTRY_SOUTH and cy >= COUNTRY_NORTH:
		return _country_ground(world_seed, world_tx, world_ty)
	return _ground_tile(world_seed, cx, cy, local_x, local_y)


static func floor_div(value: int, size: int) -> int:
	return int(floor(float(value) / float(size)))


static func chunk_of_cell(cell: Vector2i) -> Vector2i:
	return Vector2i(floor_div(cell.x, WIDTH), floor_div(cell.y, HEIGHT))


static func local_of_cell(cell: Vector2i) -> Vector2i:
	return Vector2i(posmod(cell.x, WIDTH), posmod(cell.y, HEIGHT))


static func world_cell_at(px: Vector2) -> Vector2i:
	var tile := float(TILE)
	return Vector2i(int(floor(px.x / tile)), int(floor(px.y / tile)))


## Feet sit in the middle of a tile, same as Leif.
static func cell_center(cell: Vector2i) -> Vector2:
	var tile := float(TILE)
	return Vector2((float(cell.x) + 0.5) * tile, (float(cell.y) + 0.5) * tile)


## The walk the carver takes, including moss gaps. Index 0 is the shore; the last cell is inland.
func caribou_trail_cells(world_seed: int, north_chunk_y: int) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	if north_chunk_y > 0:
		return path
	var tx := WIDTH / 2 + (_hash(world_seed, 0, 0, 99) % 7) - 3
	var wy := HEIGHT - WATER_ROWS - SHORE_ROWS - 1
	var min_wy := north_chunk_y * HEIGHT
	while wy >= min_wy:
		if tx >= 1 and tx < WIDTH - 1:
			path.append(Vector2i(tx, wy))
		if wy == min_wy:
			break
		var wiggle := _hash(world_seed, tx, wy, 77) % 5
		if wiggle == 0 and tx > 2:
			tx -= 1
		elif wiggle == 1 and tx < WIDTH - 3:
			tx += 1
		wy -= 1
	return path


## Inland on the path, not on the landing beach.
func caribou_seed_index(path: Array[Vector2i]) -> int:
	if path.is_empty():
		return 0
	var i := int(round(float(path.size()) * 0.55))
	i = clampi(i, 0, path.size() - 1)
	var inland_y := -HEIGHT / 2
	while i < path.size() - 1 and path[i].y > inland_y:
		i += 1
	return i


## Intervale path from the coast seam to the near bank. Same chunk_x as the caribou trail.
func deer_trail_cells(world_seed: int) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var coast := caribou_trail_cells(world_seed, VALLEY_SOUTH + 1)
	if coast.is_empty():
		return path
	var tx := coast[coast.size() - 1].x
	var wy := coast[coast.size() - 1].y - 1
	var bank := STEM_SOUTH + 1
	while wy >= bank:
		if tx >= 1 and tx < WIDTH - 1:
			path.append(Vector2i(tx, wy))
		if wy == bank:
			break
		var wiggle := _hash(world_seed, tx, wy, 91) % 5
		if wiggle == 0 and tx > 2:
			tx -= 1
		elif wiggle == 1 and tx < WIDTH - 3:
			tx += 1
		wy -= 1
	return path


func deer_seed_index(path: Array[Vector2i]) -> int:
	if path.is_empty():
		return 0
	return clampi(int(round(float(path.size()) * 0.35)), 0, path.size() - 1)


static func stem_distance(world_ty: int) -> int:
	if world_ty <= STEM_SOUTH and world_ty >= STEM_NORTH:
		return 0
	if world_ty > STEM_SOUTH:
		return world_ty - STEM_SOUTH
	return STEM_NORTH - world_ty


## Where a pole from origin along step would land.
## sample(world_tx, world_ty) -> tile kind.
## stem, if set, takes a world y and says whether that row is the main stem.
## Reasons: "cross", "wide", "wade", "sea", or "" when he is not facing water.
static func raft_landing(origin: Vector2i, step: Vector2i, sample: Callable, stem: Callable = Callable()) -> Dictionary:
	var none := {"ok": false, "reason": "", "cell": origin}
	if step == Vector2i.ZERO or not sample.is_valid():
		return none
	var cell := origin + step
	var kind := int(sample.call(cell.x, cell.y))
	if kind == TILE_BROOK:
		return {"ok": false, "reason": "wade", "cell": cell}
	if kind != TILE_WATER:
		return none
	if not _raft_on_stem(cell.y, stem):
		if _bayou_row(cell.y):
			return _raft_bayou(cell, step, sample)
		if _country_row(cell.y):
			return _raft_country(cell, step, sample)
		return {"ok": false, "reason": "sea", "cell": cell}
	var crossed := 0
	while crossed < RAFT_REACH and kind == TILE_WATER and _raft_on_stem(cell.y, stem):
		crossed += 1
		cell += step
		kind = int(sample.call(cell.x, cell.y))
	if kind == TILE_WATER and _raft_on_stem(cell.y, stem):
		return {"ok": false, "reason": "wide", "cell": cell}
	if kind == TILE_WATER:
		return {"ok": false, "reason": "wide", "cell": cell}
	return {"ok": true, "reason": "cross", "cell": cell}


static func _country_row(world_ty: int) -> bool:
	var cy := floor_div(world_ty, HEIGHT)
	return cy <= COUNTRY_SOUTH and cy >= COUNTRY_NORTH


## The Connecticut stem is not the valley fishery and not the landing sea.
static func _raft_country(cell: Vector2i, step: Vector2i, sample: Callable) -> Dictionary:
	var crossed := 0
	var kind := TILE_WATER
	while crossed < RAFT_REACH and kind == TILE_WATER and _country_row(cell.y):
		crossed += 1
		cell += step
		kind = int(sample.call(cell.x, cell.y))
	if kind == TILE_WATER:
		return {"ok": false, "reason": "wide", "cell": cell}
	return {"ok": true, "reason": "river", "cell": cell}


static func _bayou_row(world_ty: int) -> bool:
	var cy := floor_div(world_ty, HEIGHT)
	return cy <= BAYOU_SOUTH and cy >= BAYOU_NORTH


## A bayou channel is not the landing sea and not the valley stem. The line does not fish it.
static func _raft_bayou(cell: Vector2i, step: Vector2i, sample: Callable) -> Dictionary:
	var crossed := 0
	var kind := TILE_WATER
	while crossed < RAFT_REACH and kind == TILE_WATER and _bayou_row(cell.y):
		crossed += 1
		cell += step
		kind = int(sample.call(cell.x, cell.y))
	if kind == TILE_WATER:
		return {"ok": false, "reason": "wide", "cell": cell}
	return {"ok": true, "reason": "channel", "cell": cell}


static func _raft_on_stem(world_ty: int, stem: Callable) -> bool:
	if stem.is_valid():
		return bool(stem.call(world_ty))
	return stem_distance(world_ty) == 0


## Moss/peat beside the caribou trail, around the same inland band as the caribou.
## Off the path by 3–6 tiles. At least 12 tiles apart. Extra cells let the woods skip trees.
func hare_seed_cells(world_seed: int, north_chunk_y: int, want: int = 3) -> Array[Vector2i]:
	var picked: Array[Vector2i] = []
	if north_chunk_y > 0:
		return picked
	var path := caribou_trail_cells(world_seed, north_chunk_y)
	if path.is_empty():
		return picked
	var on_trail := {}
	for cell in path:
		on_trail[cell] = true
	var need := maxi(want, 3)
	var origin := caribou_seed_index(path)
	var sides: Array[int] = [4, -4, 5, -5, 3, -3, 6, -6]
	var step := 0
	while picked.size() < need and step < path.size() * 2:
		var k := int((step + 1) / 2)
		var delta := k if (step % 2 == 1) else -k
		step += 1
		var ti := origin + delta
		if ti < 0 or ti >= path.size():
			continue
		var base: Vector2i = path[ti]
		for ox in sides:
			var cell := Vector2i(base.x + ox, base.y)
			if on_trail.has(cell):
				continue
			var kind := peek_ground(world_seed, cell.x, cell.y)
			if kind != TILE_MOSS and kind != TILE_PEAT:
				continue
			var ok := true
			for other: Vector2i in picked:
				if Vector2(cell).distance_to(Vector2(other)) < 12.0:
					ok = false
					break
			if not ok:
				continue
			picked.append(cell)
			break
	return picked


func _idx(tx: int, ty: int) -> int:
	return ty * WIDTH + tx


func _hash(world_seed: int, x: int, y: int, salt: int) -> int:
	var h := world_seed
	h = (h * 374761393 + x * 668265263) ^ (y * 1274126177) ^ salt
	h = (h ^ (h >> 13)) * 1274126177
	return h & 0x7fffffff


func _rand01(world_seed: int, x: int, y: int, salt: int) -> float:
	return float(_hash(world_seed, x, y, salt) % 10000) / 10000.0


func _fill_valley(
	world_seed: int,
	chunk_x: int,
	chunk_y: int,
	tiles: PackedInt32Array,
	trees: Array[String],
	forage: Array[String],
) -> void:
	for ty in HEIGHT:
		for tx in WIDTH:
			tiles[_idx(tx, ty)] = _valley_ground(world_seed, chunk_x, chunk_y, tx, ty)
	_paint_deer_trail(world_seed, chunk_x, chunk_y, tiles)
	_scatter_valley_plants(world_seed, chunk_x, chunk_y, tiles, trees, forage)


func _valley_ground(world_seed: int, chunk_x: int, chunk_y: int, tx: int, ty: int) -> int:
	var wy := chunk_y * HEIGHT + ty
	if stem_distance(wy) == 0:
		return TILE_WATER
	if _is_brook(world_seed, chunk_x, tx):
		return TILE_BROOK
	if stem_distance(wy) <= FLOOD_REACH:
		return TILE_MOSS
	return TILE_PEAT


func _is_brook(world_seed: int, chunk_x: int, tx: int) -> bool:
	var shift := _hash(world_seed, chunk_x, 0, 120) % 5
	return tx == 8 + shift or tx == 36 + shift


func _paint_deer_trail(world_seed: int, chunk_x: int, chunk_y: int, tiles: PackedInt32Array) -> void:
	if chunk_x != 0:
		return
	var bank := STEM_SOUTH + 1
	for cell in deer_trail_cells(world_seed):
		if floor_div(cell.y, HEIGHT) != chunk_y:
			continue
		var lty := posmod(cell.y, HEIGHT)
		if tiles[_idx(cell.x, lty)] == TILE_WATER:
			continue
		var gap := _hash(world_seed, cell.x, cell.y, 93) % 6
		var on_seam := lty == 0 or lty == HEIGHT - 1 or cell.y == bank
		if gap != 0 or on_seam:
			tiles[_idx(cell.x, lty)] = TILE_TRAIL


func _scatter_valley_plants(
	world_seed: int,
	chunk_x: int,
	chunk_y: int,
	tiles: PackedInt32Array,
	trees: Array[String],
	forage: Array[String],
) -> void:
	for ty in HEIGHT:
		for tx in WIDTH:
			var i := _idx(tx, ty)
			var kind := tiles[i]
			if kind == TILE_WATER or kind == TILE_TRAIL or kind == TILE_BROOK:
				continue
			var wy := chunk_y * HEIGHT + ty
			var flood := stem_distance(wy) >= 1 and stem_distance(wy) <= FLOOD_REACH
			var chance := clampf((0.14 if flood else 0.12) * AdminSettings.foliage_multiplier(), 0.0, 1.0)
			if _rand01(world_seed, chunk_x * WIDTH + tx, wy, 21) > chance:
				continue
			var list := FLOOD_TREES if flood else UPLAND_TREES
			trees[i] = list[_hash(world_seed, tx, ty, 33) % list.size()]
	for ty in HEIGHT:
		for tx in WIDTH:
			var i := _idx(tx, ty)
			if trees[i] != TREE_NONE:
				continue
			if tiles[i] != TILE_MOSS:
				continue
			var wy := chunk_y * HEIGHT + ty
			if stem_distance(wy) < 1 or stem_distance(wy) > FLOOD_REACH:
				continue
			var chance := clampf(0.06 * AdminSettings.foliage_multiplier(), 0.0, 1.0)
			if _rand01(world_seed, chunk_x * WIDTH + tx, wy, 44) > chance:
				continue
			forage[i] = VALLEY_FORAGE[_hash(world_seed, tx, ty, 45) % VALLEY_FORAGE.size()]


## Three wandering channels. One tile of open water, one tile of tupelo water beside it,
## one tile of cypress ground on the other side. The research gave no width. This is the drawing.
func channel_x(world_seed: int, which: int, world_ty: int) -> int:
	var base := -20 + which * 36
	var band := floor_div(world_ty, 4)
	var shift := (_hash(world_seed, which, band, 880) % 9) - 4
	return base + shift


func bayou_part(world_seed: int, world_tx: int, world_ty: int) -> String:
	for which in 3:
		var at := channel_x(world_seed, which, world_ty)
		if world_tx == at:
			return "channel"
		if world_tx == at + 1:
			return "slough"
		if world_tx == at - 1:
			return "margin"
	return "high"


func _bayou_ground(world_seed: int, world_tx: int, world_ty: int) -> int:
	var part := bayou_part(world_seed, world_tx, world_ty)
	if part == "channel" or part == "slough":
		return TILE_WATER
	if part == "margin":
		return TILE_MOSS
	return TILE_PEAT


func _fill_bayou(
	world_seed: int,
	chunk_x: int,
	chunk_y: int,
	tiles: PackedInt32Array,
	trees: Array[String],
	forage: Array[String],
) -> void:
	for ty in HEIGHT:
		for tx in WIDTH:
			var wx := chunk_x * WIDTH + tx
			var wy := chunk_y * HEIGHT + ty
			var i := _idx(tx, ty)
			var part := bayou_part(world_seed, wx, wy)
			tiles[i] = _bayou_ground(world_seed, wx, wy)
			if part == "slough":
				trees[i] = "water_tupelo"
			elif part == "margin":
				var chance := clampf(0.28 * AdminSettings.foliage_multiplier(), 0.0, 1.0)
				if _rand01(world_seed, wx, wy, 21) <= chance:
					trees[i] = "baldcypress"
				elif _rand01(world_seed, wx, wy, 46) <= clampf(0.05 * AdminSettings.foliage_multiplier(), 0.0, 1.0):
					forage[i] = "muscadine"
			elif part == "high":
				var chance := clampf(0.1 * AdminSettings.foliage_multiplier(), 0.0, 1.0)
				if _rand01(world_seed, wx, wy, 21) <= chance:
					trees[i] = BAYOU_TREES[_hash(world_seed, tx, ty, 33) % BAYOU_TREES.size()]
				elif _rand01(world_seed, wx, wy, 47) <= clampf(0.04 * AdminSettings.foliage_multiplier(), 0.0, 1.0):
					forage[i] = "pecan"


## One meandering tile. Not the six-tile Saint John, and not a measured mouth.
func country_stem_y(world_seed: int, world_tx: int) -> int:
	var band := floor_div(world_tx, 6)
	var shift := (_hash(world_seed, band, 771, 0) % 9) - 4
	return COUNTRY_STEM_Y + shift


func country_is_brook(world_seed: int, world_tx: int) -> bool:
	for which in 3:
		var at := -36 + which * 48 + ((_hash(world_seed, which, 772, 1) % 5) - 2)
		if world_tx == at:
			return true
	return false


func country_part(world_seed: int, world_tx: int, world_ty: int) -> String:
	if world_ty == country_stem_y(world_seed, world_tx):
		return "stem"
	if country_is_brook(world_seed, world_tx):
		return "brook"
	if absi(world_ty - country_stem_y(world_seed, world_tx)) == 1:
		return "flood"
	return "terrace"


func _country_ground(world_seed: int, world_tx: int, world_ty: int) -> int:
	var part := country_part(world_seed, world_tx, world_ty)
	if part == "stem":
		return TILE_WATER
	if part == "brook":
		return TILE_BROOK
	if part == "flood":
		return TILE_PEAT
	return TILE_MOSS


func _fill_country(
	world_seed: int,
	chunk_x: int,
	chunk_y: int,
	tiles: PackedInt32Array,
	trees: Array[String],
	forage: Array[String],
) -> void:
	for ty in HEIGHT:
		for tx in WIDTH:
			var wx := chunk_x * WIDTH + tx
			var wy := chunk_y * HEIGHT + ty
			var i := _idx(tx, ty)
			var part := country_part(world_seed, wx, wy)
			tiles[i] = _country_ground(world_seed, wx, wy)
			if part == "flood":
				var chance := clampf(0.22 * AdminSettings.foliage_multiplier(), 0.0, 1.0)
				if _rand01(world_seed, wx, wy, 21) <= chance:
					trees[i] = FLOOD_TREES_CT[_hash(world_seed, tx, ty, 34) % FLOOD_TREES_CT.size()]
			elif part == "terrace":
				var chance := clampf(0.1 * AdminSettings.foliage_multiplier(), 0.0, 1.0)
				if _rand01(world_seed, wx, wy, 21) <= chance:
					trees[i] = TERRACE_TREES[_hash(world_seed, tx, ty, 35) % TERRACE_TREES.size()]
				elif _rand01(world_seed, wx, wy, 48) <= clampf(0.04 * AdminSettings.foliage_multiplier(), 0.0, 1.0):
					forage[i] = "chestnut"


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
			var chance := clampf((0.16 if kind == TILE_MOSS else 0.07) * AdminSettings.foliage_multiplier(), 0.0, 1.0)
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
			var chance := clampf((0.05 if kind == TILE_PEAT else 0.03) * AdminSettings.foliage_multiplier(), 0.0, 1.0)
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
			var rock_chance := clampf(0.045 * AdminSettings.foliage_multiplier(), 0.0, 1.0)
			if _rand01(world_seed, chunk_x * WIDTH + tx, chunk_y * HEIGHT + ty, 55) > rock_chance:
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
			var fallen_chance := clampf(0.012 * AdminSettings.foliage_multiplier(), 0.0, 1.0)
			if _rand01(world_seed, chunk_x * WIDTH + tx, chunk_y * HEIGHT + ty, 66) > fallen_chance:
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
			var clutter_chance := clampf(0.22 * AdminSettings.foliage_multiplier(), 0.0, 1.0)
			if _rand01(world_seed, chunk_x * WIDTH + tx, chunk_y * HEIGHT + ty, 77) > clutter_chance:
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
