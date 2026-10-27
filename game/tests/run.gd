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
	_test_player_reports_facing()
	_test_facing_gates_the_tile_in_front()
	_test_pick_forage_in_front()
	_test_chop_tree_in_front()
	_test_verbs_honor_biome_lists()
	_test_campfire_spends_wood_and_lights()
	_test_campfire_on_open_ground_only()
	_test_night_falls_without_freezing()
	_test_hud_shows_hearts_wood_forage()
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


func _coast() -> Biome:
	var catalog := BiomeCatalog.new()
	catalog.load_all()
	return catalog.get_biome(&"coastal_north")


func _chunk(world_seed: int) -> MapChunk:
	var chunk := MapChunk.new()
	chunk.setup(world_seed, 0, 0, _coast())
	return chunk


func _test_player_reports_facing() -> void:
	print("player facing contract")
	var player := Player.new()
	_expect(player.facing_name() == "south", "leif starts facing south")
	_expect(not player.is_jogging(), "leif starts at a walk")
	player.free()


func _test_facing_gates_the_tile_in_front() -> void:
	print("E uses the tile in front")
	var interact := Interact.new()
	var tile := float(ChunkGenerator.TILE)
	var origin := Vector2((4.0 + 0.5) * tile, (6.0 + 0.5) * tile)
	var north := _prop(Vector2i(4, 5), "forage", "bakeapple")
	_expect(interact.best_target(origin, "north", [north]) == north, "facing north selects the north bush")
	_expect(interact.best_target(origin, "south", [north]) == null, "facing away does not select it")
	var far := _prop(Vector2i(4, 3), "forage", "blueberry")
	_expect(interact.best_target(origin, "north", [far]) == null, "two tiles away is out of reach")
	var beside := _prop(Vector2i(5, 6), "tree", "fir")
	_expect(interact.best_target(origin, "north", [beside]) == null, "a tree beside him is not in front")
	_expect(interact.best_target(origin, "east", [beside]) == beside, "facing east selects that tree")
	var diagonal := _prop(Vector2i(5, 5), "tree", "spruce")
	_expect(interact.best_target(origin, "north", [diagonal]) == diagonal, "a diagonal step still counts as in front")
	var under := _prop(Vector2i(4, 6), "forage", "blueberry")
	_expect(interact.best_target(origin, "west", [under]) == under, "standing on a bush still picks it")
	_expect(interact.best_target(origin, "north", [under, north]) == north, "the bush he faces wins over the one underfoot")
	var south_edge := Vector2((4.0 + 0.9) * tile, (6.0 + 0.95) * tile)
	_expect(Interact.tile_ahead(south_edge, "north") == Vector2i(4, 5), "the tile ahead is one step, not two")
	_expect(Interact.tile_ahead(origin, "south-east") == Vector2i(5, 7), "a diagonal face is one tile")
	north.free()
	far.free()
	beside.free()
	diagonal.free()
	under.free()
	interact.free()


func _test_pick_forage_in_front() -> void:
	print("pick bakeapple and blueberry")
	var chunk := _chunk(11)
	var interact := Interact.new()
	interact.biome = _coast()
	interact.supplies = Supplies.new()
	var picks: Array[Node2D] = []
	var seen := {}
	for node in chunk.prop_nodes():
		if str(node.get_meta("kind")) != "forage":
			continue
		var species := str(node.get_meta("species"))
		if seen.has(species):
			continue
		seen[species] = true
		picks.append(node)
	_expect(seen.has("bakeapple") and seen.has("blueberry"), "seed 11 grows both forage species")
	for node in picks:
		var species := str(node.get_meta("species"))
		var before: int = interact.supplies.forage
		var cell := chunk.cell_of_prop(node)
		_expect(interact.use_on(node) == "forage", "pick %s" % species)
		_expect(interact.use_on(node) == "", "%s cannot be picked twice" % species)
		_expect(interact.supplies.forage == before + 1, "%s adds one forage" % species)
		chunk.release_prop(node)
		var i := cell.y * ChunkGenerator.WIDTH + cell.x
		_expect(str(chunk.data["forage"][i]) == "", "%s bush is gone" % species)
		_expect(not chunk.cell_occupied(cell), "%s tile is empty" % species)
	_expect(interact.supplies.forage == 2, "forage count is both bushes")
	_expect(interact.supplies.wood == 0, "picking does not give wood")
	_expect(interact.supplies.hearts == 3, "picking does not spend hearts")
	chunk.free()
	interact.free()


func _test_chop_tree_in_front() -> void:
	print("chop fir and spruce")
	var chunk := _chunk(11)
	var interact := Interact.new()
	interact.biome = _coast()
	interact.supplies = Supplies.new()
	var trees_before := 0
	for node in chunk.prop_nodes():
		if str(node.get_meta("kind")) == "tree":
			trees_before += 1
	var chops: Array[Node2D] = []
	var seen := {}
	for node in chunk.prop_nodes():
		if str(node.get_meta("kind")) != "tree":
			continue
		var species := str(node.get_meta("species"))
		if seen.has(species):
			continue
		seen[species] = true
		chops.append(node)
	_expect(seen.has("fir") and seen.has("spruce"), "seed 11 grows fir and spruce")
	for node in chops:
		var species := str(node.get_meta("species"))
		var cell := chunk.cell_of_prop(node)
		var before: int = interact.supplies.wood
		_expect(interact.use_on(node) == "chop", "chop %s" % species)
		_expect(interact.supplies.wood == before + Supplies.WOOD_PER_TREE, "%s adds wood" % species)
		chunk.release_prop(node)
		var i := cell.y * ChunkGenerator.WIDTH + cell.x
		_expect(str(chunk.data["trees"][i]) == "", "%s is gone from the woods" % species)
		_expect(chunk.cell_occupied(cell), "%s leaves a stump" % species)
	var trees_after := 0
	for node in chunk.prop_nodes():
		if str(node.get_meta("kind")) == "tree":
			trees_after += 1
	_expect(trees_after == trees_before - chops.size(), "chopped trees are not still standing")
	_expect(interact.supplies.wood == Supplies.WOOD_PER_TREE * 2, "two trees of wood")
	_expect(interact.supplies.forage == 0, "chopping does not give forage")
	_expect(interact.supplies.hearts == interact.supplies.hearts_max, "chopping does not spend hearts")
	chunk.free()
	interact.free()


func _test_verbs_honor_biome_lists() -> void:
	print("verbs follow the biome list")
	var coast := _coast()
	var supplies := Supplies.new()
	_expect(not supplies.pick_forage("grape", coast), "grapes are not coastal forage")
	_expect(not supplies.pick_forage("cranberry", coast), "cranberry stays off the slice 0 list")
	_expect(not supplies.chop_tree("butternut", coast), "butternut is not a coastal tree")
	_expect(not supplies.chop_tree("tamarack", coast), "tamarack stays off the slice 0 list")
	_expect(supplies.forage == 0 and supplies.wood == 0, "rejected species add nothing")
	var narrow := Biome.new()
	narrow.tree_species = PackedStringArray(["spruce"])
	narrow.forage_species = PackedStringArray(["blueberry"])
	_expect(not supplies.chop_tree("fir", narrow), "fir is absent from this biome list")
	_expect(supplies.chop_tree("spruce", narrow), "spruce is on this biome list")
	_expect(supplies.wood == Supplies.WOOD_PER_TREE, "wood comes from the listed tree")
	_expect(not supplies.pick_forage("bakeapple", narrow), "bakeapple is absent from this biome list")
	_expect(supplies.pick_forage("blueberry", narrow), "blueberry is on this biome list")
	_expect(Supplies.WOOD_PER_TREE == Supplies.CAMPFIRE_WOOD, "one tree pays for one fire")
	var interact := Interact.new()
	interact.biome = coast
	interact.supplies = Supplies.new()
	var fake := _prop(Vector2i(1, 1), "tree", "butternut")
	_expect(interact.use_on(fake) == "", "a butternut prop is not chopped")
	_expect(not bool(fake.get_meta("harvested", false)), "a rejected tree stays standing")
	_expect(interact.supplies.wood == 0, "a rejected chop adds no wood")
	fake.free()
	interact.free()


func _test_campfire_spends_wood_and_lights() -> void:
	print("campfire spends wood and is the warm light")
	var supplies := Supplies.new()
	supplies.wood = 2
	_expect(not Campfire.try_place(supplies, false, false), "two wood is short of a fire")
	_expect(supplies.wood == 2, "short wood is not spent")
	supplies.wood = Supplies.CAMPFIRE_WOOD
	_expect(not Campfire.try_place(supplies, true, false), "water refuses the fire")
	_expect(supplies.wood == Supplies.CAMPFIRE_WOOD, "water does not spend wood")
	_expect(not Campfire.try_place(supplies, false, true), "occupied ground refuses the fire")
	_expect(supplies.wood == Supplies.CAMPFIRE_WOOD, "occupied ground does not spend wood")
	_expect(Campfire.try_place(supplies, false, false), "three wood lights a fire")
	_expect(supplies.wood == 0, "the fire spent the wood")
	var fire := Campfire.new()
	fire.build_visual()
	var light := fire.warm_light()
	_expect(light != null, "the campfire has a light")
	_expect(light.color == Campfire.LIGHT_COLOR, "the light uses the warm color")
	_expect(Campfire.LIGHT_COLOR.r > Campfire.LIGHT_COLOR.b, "fire light is warm")
	_expect(fire.lit, "the fire is lit")
	fire.set_darkness(0.0)
	_expect(not light.enabled, "daylight does not wash the ground with the fire")
	fire.set_darkness(1.0)
	_expect(light.enabled, "night turns the warm light on")
	_expect(is_equal_approx(light.energy, Campfire.NIGHT_ENERGY), "the night pool is fully lit")
	_expect(str(fire.get_meta("kind")) == "campfire", "the fire is not a tree or a bush")
	fire.free()


func _test_campfire_on_open_ground_only() -> void:
	print("campfire sits on open coastal ground")
	var chunk := _chunk(11)
	var supplies := Supplies.new()
	supplies.wood = Supplies.CAMPFIRE_WOOD * 2
	var water := Vector2i(4, ChunkGenerator.HEIGHT - 1)
	_expect(ChunkGenerator.new().is_blocked(chunk.tile_kind(water)), "south edge tile is water")
	var open := _open_cell(chunk)
	_expect(open.x >= 0, "seed 11 has an open land tile")
	_expect(Campfire.try_place(supplies, false, chunk.cell_occupied(open)), "open ground accepts a fire")
	var fire := Campfire.new()
	fire.position = MapChunk.anchor_for_cell(open)
	fire.build_visual()
	chunk.add_child(fire)
	_expect(chunk.cell_of_prop(fire) == open, "the fire sits on that tile")
	_expect(chunk.cell_occupied(open), "the tile is now taken")
	var left := supplies.wood
	_expect(not Campfire.try_place(supplies, false, true), "a second fire does not stack")
	_expect(supplies.wood == left, "a refused fire keeps the wood")
	chunk.free()


func _test_night_falls_without_freezing() -> void:
	print("night falls and hearts stay")
	var clock := DayClock.new()
	var supplies := Supplies.new()
	_expect(clock.phase() == "day", "a new walk starts in daylight")
	_expect(clock.darkness() == 0.0, "day is full daylight")
	clock.elapsed = DayClock.DAY_SECONDS - DayClock.DUSK_SECONDS * 0.5
	_expect(clock.phase() == "dusk", "dusk is the end of the day")
	_expect(is_equal_approx(clock.darkness(), 0.5), "dusk is halfway dark")
	clock.elapsed = DayClock.DAY_SECONDS
	_expect(clock.is_night(), "night falls")
	_expect(is_equal_approx(clock.darkness(), 1.0), "night is fully dark")
	var night := clock.modulate_color()
	_expect(night == DayClock.NIGHT_COLOR, "night tint is the cold color")
	_expect(DayClock.NIGHT_COLOR.b > DayClock.NIGHT_COLOR.r, "night tint is cold")
	_expect(Campfire.LIGHT_COLOR.r > DayClock.NIGHT_COLOR.r, "the fire is warmer than the night")
	var hearts := supplies.hearts
	supplies.tick_night(true)
	clock.elapsed = DayClock.DAY_SECONDS + DayClock.NIGHT_SECONDS - 0.1
	supplies.tick_night(clock.is_night())
	_expect(clock.is_night(), "the end of the night is still night")
	_expect(supplies.hearts == hearts, "a full night does not take hearts")
	_expect(supplies.hearts == supplies.hearts_max, "hearts stay full")
	_expect(supplies.wood == 0 and supplies.forage == 0, "night does not spend the pack")
	clock.elapsed = DayClock.DAY_SECONDS + DayClock.NIGHT_SECONDS
	_expect(clock.phase() == "day", "dawn comes back so the walk can continue")
	clock.free()


func _test_hud_shows_hearts_wood_forage() -> void:
	print("hud shows hearts wood forage")
	var supplies := Supplies.new()
	supplies.wood = 3
	supplies.forage = 2
	var text := GameHud.status_text(11, "Coastal North", supplies, "night", "Campfire lit.")
	_expect(text.contains("hearts 3/3"), "hearts are on the hud")
	_expect(text.contains("wood 3"), "wood count is on the hud")
	_expect(text.contains("forage 2"), "forage count is on the hud")
	_expect(text.contains("night"), "the phase is on the hud")
	_expect(text.contains("E pick or chop"), "pick and chop are labeled")
	_expect(text.contains("F campfire"), "the campfire key is labeled")
	_expect(text.contains("Campfire lit."), "the last action is on the hud")
	_expect(supplies.hearts == 3, "the hud line does not spend hearts")


func _prop(cell: Vector2i, kind: String, species: String) -> Node2D:
	var node := Node2D.new()
	node.position = MapChunk.anchor_for_cell(cell)
	node.set_meta("kind", kind)
	node.set_meta("species", species)
	return node


func _open_cell(chunk: MapChunk) -> Vector2i:
	var tiles: PackedInt32Array = chunk.data["tiles"]
	var gen := ChunkGenerator.new()
	for ty in ChunkGenerator.HEIGHT:
		for tx in ChunkGenerator.WIDTH:
			var kind: int = tiles[ty * ChunkGenerator.WIDTH + tx]
			if gen.is_blocked(kind):
				continue
			var cell := Vector2i(tx, ty)
			if chunk.cell_occupied(cell):
				continue
			return cell
	return Vector2i(-1, -1)
