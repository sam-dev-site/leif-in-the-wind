class_name BiomeCatalog
extends RefCounted

const PATHS := {
	&"coastal_north": "res://data/biomes/coastal_north.tres",
	&"river_valley": "res://data/biomes/river_valley.tres",
	&"inland_plains": "res://data/biomes/inland_plains.tres",
	&"bayou": "res://data/biomes/bayou.tres",
	&"river_country": "res://data/biomes/river_country.tres",
}

var _by_id: Dictionary = {}


func load_all() -> void:
	_by_id.clear()
	for biome_id: StringName in PATHS:
		var biome: Biome = load(PATHS[biome_id]) as Biome
		if biome == null:
			push_error("Missing biome resource: %s" % PATHS[biome_id])
			continue
		_by_id[biome_id] = biome


func get_biome(biome_id: StringName) -> Biome:
	return _by_id.get(biome_id) as Biome


## Chunk rows inland of the landing. See docs/LOOP.md. The world still only builds the coast strip.
const COAST_NORTH := -3
const RIVER_NORTH := -7
const PLAINS_NORTH := -11
const BAYOU_NORTH := -15
const RIVER_COUNTRY_NORTH := -19
const WESTERN_NORTH := -23

## Display names for the continent map. The western shore has no biome resource yet.
const LADDER: Array[Dictionary] = [
	{"id": "coastal_north", "name": "Coastal North", "north": -3, "south": 1000000},
	{"id": "river_valley", "name": "River valley", "north": -7, "south": -4},
	{"id": "inland_plains", "name": "Interior", "north": -11, "south": -8},
	{"id": "bayou", "name": "Bayou", "north": -15, "south": -12},
	{"id": "river_country", "name": "River country", "north": -19, "south": -16},
	{"id": "western_shore", "name": "The other sea", "north": -23, "south": -20},
]


static func ladder_row(chunk_y: int) -> Dictionary:
	for row in LADDER:
		if chunk_y <= int(row["south"]) and chunk_y >= int(row["north"]):
			return row
	return {}


static func ladder_id(world_ty: int) -> String:
	var cy := ChunkGenerator.floor_div(world_ty, ChunkGenerator.HEIGHT)
	return str(ladder_row(cy).get("id", ""))


static func ladder_name(id: String) -> String:
	for row in LADDER:
		if str(row["id"]) == id:
			return str(row["name"])
	return ""


## Landing sea (chunk_y > 0) stays coastal_north. The generator paints that as water.
## Past the Connecticut band there is no id yet, so the western shore is not built.
func biome_id_at(_world_tx: int, world_ty: int) -> StringName:
	var cy := ChunkGenerator.floor_div(world_ty, ChunkGenerator.HEIGHT)
	if cy >= COAST_NORTH:
		return &"coastal_north"
	if cy >= RIVER_NORTH:
		return &"river_valley"
	if cy >= PLAINS_NORTH:
		return &"inland_plains"
	if cy >= BAYOU_NORTH:
		return &"bayou"
	if cy >= RIVER_COUNTRY_NORTH:
		return &"river_country"
	return &""
