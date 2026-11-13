class_name BiomeCatalog
extends RefCounted

const PATHS := {
	&"coastal_north": "res://data/biomes/coastal_north.tres",
	&"river_valley": "res://data/biomes/river_valley.tres",
	&"inland_plains": "res://data/biomes/inland_plains.tres",
	&"bayou": "res://data/biomes/bayou.tres",
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


## Landing sea (chunk_y > 0) stays coastal_north. The generator paints that as water.
## Past the bayou band there is no id yet, so nothing there can be built.
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
	return &""
