extends SceneTree

## Headless checks for the continent systems. Run:
##   godot --headless --path game -s res://tests/run.gd

var _failed := 0


func _init() -> void:
	_test_same_seed_same_chunk()
	_test_different_seed_changes_woods()
	_test_origin_biome_is_coastal_north()
	_test_shore_south_trail_inland()
	_test_only_researched_species()
	_test_stub_biomes_have_no_spawn_tables()
	if _failed > 0:
		print("FAILED %d" % _failed)
		quit(1)
	print("OK")
	quit(0)


func _expect(cond: bool, msg: String) -> void:
	if cond:
		print("  pass  ", msg)
	else:
		_failed += 1
		print("  FAIL  ", msg)


func _gen(world_seed: int) -> Dictionary:
	var catalog := BiomeCatalog.new()
	catalog.load_all()
	var biome := catalog.get_biome(&"coastal_north")
	var gen := ChunkGenerator.new()
	return gen.generate(world_seed, 0, 0, biome)


func _test_same_seed_same_chunk() -> void:
	print("same seed = same chunk")
	var a := _gen(11)
	var b := _gen(11)
	_expect(a["tiles"] == b["tiles"], "tiles match")
	_expect(a["trees"] == b["trees"], "trees match")
	_expect(a["forage"] == b["forage"], "forage match")
	_expect(a["spawn"] == b["spawn"], "spawn match")


func _test_different_seed_changes_woods() -> void:
	print("different seed changes woods")
	var a := _gen(11)
	var b := _gen(99)
	_expect(a["tiles"] != b["tiles"] or a["trees"] != b["trees"], "seed 11 vs 99 is not identical")


func _test_origin_biome_is_coastal_north() -> void:
	print("origin biome")
	var catalog := BiomeCatalog.new()
	catalog.load_all()
	_expect(catalog.biome_id_at(0, 0) == &"coastal_north", "tile (0,0) is coastal_north")
	_expect(catalog.get_biome(&"coastal_north") != null, "coastal_north resource loads")
	_expect(catalog.get_biome(&"river_valley") != null, "river_valley stub loads")
	_expect(catalog.get_biome(&"inland_plains") != null, "inland_plains stub loads")
	_expect(catalog.get_biome(&"bayou") != null, "bayou stub loads")


func _test_shore_south_trail_inland() -> void:
	print("shore south, trail inland")
	var data := _gen(11)
	var tiles: PackedInt32Array = data["tiles"]
	var south := ChunkGenerator.HEIGHT - 1
	var water_count := 0
	var trail_north := false
	for tx in ChunkGenerator.WIDTH:
		if tiles[south * ChunkGenerator.WIDTH + tx] == ChunkGenerator.TILE_WATER:
			water_count += 1
	for ty in 8:
		for tx in ChunkGenerator.WIDTH:
			if tiles[ty * ChunkGenerator.WIDTH + tx] == ChunkGenerator.TILE_TRAIL:
				trail_north = true
	_expect(water_count > ChunkGenerator.WIDTH / 2, "south edge is mostly water")
	_expect(trail_north, "caribou trail reaches the inland (north) edge")
	var spawn: Vector2i = data["spawn"]
	_expect(spawn.y < south, "spawn is north of the water")


func _test_only_researched_species() -> void:
	print("only researched coastal_north species")
	var data := _gen(11)
	var allowed_trees := { "fir": true, "spruce": true }
	var allowed_forage := { "bakeapple": true, "blueberry": true }
	var tree_ok := true
	var forage_ok := true
	var tree_count := 0
	var forage_count := 0
	for name in data["trees"]:
		if name == "":
			continue
		tree_count += 1
		if not allowed_trees.has(name):
			tree_ok = false
	for name in data["forage"]:
		if name == "":
			continue
		forage_count += 1
		if not allowed_forage.has(name):
			forage_ok = false
	_expect(tree_ok, "trees are only fir/spruce")
	_expect(forage_ok, "forage is only bakeapple/blueberry")
	_expect(tree_count > 0, "at least one tree spawned")
	_expect(forage_count > 0, "at least one forage spawned")


func _test_stub_biomes_have_no_spawn_tables() -> void:
	print("stub biomes do not pretend to have species")
	var catalog := BiomeCatalog.new()
	catalog.load_all()
	for biome_id in [&"river_valley", &"inland_plains", &"bayou"]:
		var biome := catalog.get_biome(biome_id)
		_expect(biome != null and biome.tree_species.is_empty(), "%s has empty trees until researched" % biome_id)
		_expect(biome != null and biome.forage_species.is_empty(), "%s has empty forage until researched" % biome_id)
