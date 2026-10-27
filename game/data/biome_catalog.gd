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


## Slice 0: the playable chunk is coastal_north. Later this reads a continent map.
func biome_id_at(_world_tx: int, _world_ty: int) -> StringName:
	return &"coastal_north"
