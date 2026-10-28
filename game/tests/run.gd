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
	_test_picture_stays_a_scaled_pixel_view()
	_test_camera_is_not_stacked_with_the_trees()
	_test_facing_gates_the_tile_in_front()
	_test_pick_forage_in_front()
	_test_chop_tree_in_front()
	_test_verbs_honor_biome_lists()
	_test_campfire_spends_wood_and_lights()
	_test_campfire_on_open_ground_only()
	_test_night_falls_without_freezing()
	_test_hud_shows_hearts_wood_forage()
	_test_eat_forage_heals_half_a_heart()
	_test_wang_corners()
	_test_wang_sheets_load()
	_test_granite_is_a_rock_not_a_floor()
	_test_fallen_tree_gives_wood()
	_test_branch_gives_half_wood()
	_test_trail_is_a_game_path()
	_test_coast_runs_east_west()
	_test_inland_chunk_continues_the_trail()
	_test_world_cells_cross_chunks()
	_test_peek_ground_matches_sea_and_woods()
	_test_rocks_and_logs_block_walking()
	_test_night_is_cold_away_from_fire()
	_test_sleep_jumps_to_dawn()
	_test_night_costs_six_hearts()
	_test_fallen_log_blocks_its_length()
	_test_campfire_burns_one_night()
	_test_coastal_north_has_grove_music()
	_test_fog_reveals_the_visible_view()
	_test_minimap_paints_revealed_tiles()
	_test_chop_leaves_named_stump()
	_test_title_menu()
	_test_world_loads_in_slices()
	_test_sphagnum_cushion_is_whole()
	_test_sphagnum_is_smaller_than_leif()
	if _failed > 0:
		print("FAILED %d" % _failed)
		quit(1)
		return
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
	_expect(a["rocks"] == b["rocks"], "rocks match")
	_expect(a["clutter"] == b["clutter"], "clutter match")
	_expect(a["fallen"] == b["fallen"], "fallen match")
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


func _test_picture_stays_a_scaled_pixel_view() -> void:
	print("picture stays a scaled pixel view")
	_expect(Player.WALK_SPEED == 70.0, "walk stays 70")
	_expect(Player.RUN_SPEED == 100.0, "jog stays 100")
	_expect(
		str(ProjectSettings.get_setting("display/window/stretch/mode")) == "viewport",
		"the woods are a 480×270 picture scaled up"
	)
	_expect(
		str(ProjectSettings.get_setting("display/window/stretch/aspect")) == "keep",
		"the picture keeps its shape"
	)
	_expect(
		str(ProjectSettings.get_setting("display/window/stretch/scale_mode")) == "fractional",
		"the picture fills the window"
	)


func _test_camera_is_not_stacked_with_the_trees() -> void:
	print("camera is not stacked with the trees")
	var world := World.new()
	world._player = Player.new()
	world.attach_camera(root)
	_expect(world.camera_is_outside_the_woods(), "the view follows him from outside the tree stack")
	world._camera.free()
	world._player.free()
	world.free()


func _test_facing_gates_the_tile_in_front() -> void:
	print("Space uses the tile in front")
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
		var stump := _stump_at(chunk, cell)
		_expect(stump != null, "%s left a stump node" % species)
		if stump != null:
			_expect(str(stump.get_meta("species")) == species, "%s stump is named for that tree" % species)
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
	chunk.register_prop(fire)
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
	clock.elapsed = DayClock.DAY_SECONDS + DayClock.NIGHT_SECONDS - DayClock.DAWN_SECONDS - 0.1
	_expect(clock.is_night(), "the end of the night is still night")
	_expect(supplies.wood == 0 and supplies.forage == 0, "night does not spend the pack")
	clock.elapsed = DayClock.DAY_SECONDS + DayClock.NIGHT_SECONDS - DayClock.DAWN_SECONDS * 0.5
	_expect(clock.phase() == "dawn", "dawn is the fade back to day")
	_expect(is_equal_approx(clock.darkness(), 0.5), "dawn is halfway light")
	_expect(not clock.is_night(), "dawn is no longer night")
	clock.elapsed = DayClock.DAY_SECONDS + DayClock.NIGHT_SECONDS
	_expect(clock.phase() == "day", "dawn comes back so the walk can continue")
	_expect(clock.darkness() == 0.0, "day after dawn is full daylight")
	clock.free()


func _test_hud_shows_hearts_wood_forage() -> void:
	print("hud shows hearts wood forage")
	var supplies := Supplies.new()
	supplies.wood = 3
	supplies.forage = 2
	var text := GameHud.status_text(11, "Coastal North", supplies, "night", "Campfire lit.")
	_expect(text.contains("hearts 3/3"), "hearts are on the hud")
	_expect(text.contains("wood 3"), "wood count is on the hud")
	supplies.hearts = 2.5
	text = GameHud.status_text(11, "Coastal North", supplies, "night", "Campfire lit.")
	_expect(text.contains("hearts 2.5/3"), "half a heart shows as a decimal")
	supplies.hearts = 3.0
	supplies.wood = 0.5
	text = GameHud.status_text(11, "Coastal North", supplies, "night", "Campfire lit.")
	_expect(text.contains("wood 0.5"), "half a wood shows as a decimal")
	_expect(text.contains("forage 2"), "forage count is on the hud")
	_expect(text.contains("night"), "the phase is on the hud")
	_expect(text.contains("Space pick, chop, or clear"), "pick, chop, and clear are labeled")
	_expect(text.contains("E eat (3 forage)"), "eat costs 3 forage")
	_expect(text.contains("F campfire"), "the campfire key is labeled")
	_expect(text.contains("C sleep"), "sleep is labeled")
	_expect(text.contains("Campfire lit."), "the last action is on the hud")
	_expect(supplies.hearts == 3, "the hud line does not spend hearts")


func _test_eat_forage_heals_half_a_heart() -> void:
	print("eat forage heals half a heart")
	var supplies := Supplies.new()
	supplies.forage = 3
	supplies.hearts = 2.0
	supplies.wood = 1.5
	supplies.cold_acc = 1.5
	supplies.heal_acc = 2.0
	_expect(supplies.try_eat() == "eat", "three berries are eaten")
	_expect(supplies.forage == 0, "eating spends three forage")
	_expect(is_equal_approx(supplies.hearts, 2.5), "eating heals half a heart")
	_expect(is_equal_approx(supplies.wood, 1.5), "eating does not spend wood")
	_expect(is_equal_approx(supplies.cold_acc, 1.5), "eating does not reset the night")
	_expect(is_equal_approx(supplies.heal_acc, 2.0), "eating does not reset day heal")
	supplies.forage = 2
	supplies.hearts = 1.0
	_expect(supplies.try_eat() == "short", "two berries are short of a heal")
	_expect(supplies.forage == 2, "a short handful is not spent")
	_expect(is_equal_approx(supplies.hearts, 1.0), "a short handful does not heal")
	supplies.forage = 3
	supplies.hearts = supplies.hearts_max
	_expect(supplies.try_eat() == "full", "full hearts refuse the berries")
	_expect(supplies.forage == 3, "a full heart keeps the forage")
	_expect(is_equal_approx(supplies.hearts, supplies.hearts_max), "hearts stay at max")
	supplies.forage = 0
	supplies.hearts = 1.0
	_expect(supplies.try_eat() == "short", "empty hands refuse")
	_expect(supplies.forage == 0, "empty forage stays empty")
	_expect(is_equal_approx(supplies.hearts, 1.0), "refusing does not heal")
	supplies.forage = 4
	supplies.hearts = 2.5
	_expect(supplies.try_eat() == "eat", "a short heart still takes three berries")
	_expect(is_equal_approx(supplies.hearts, 3.0), "the bite stops at max hearts")
	_expect(supplies.forage == 1, "one berry is left, short of another heal")
	_expect(supplies.try_eat() == "short", "the leftover berry is not eaten")
	supplies.forage = 3
	supplies.hearts = 2.0
	_expect(supplies.try_eat() == "eat", "three berries before the cold")
	_expect(supplies.tick_vitals(true, false, Supplies.COLD_SECONDS) == "cold", "night cold still spends a heart")
	_expect(is_equal_approx(supplies.hearts, 2.0), "cold still takes half a heart after eating")


func _test_wang_corners() -> void:
	print("wang corners")
	_expect(WangTiles.index(false, false, false, false) == 0, "all lower is wang 0")
	_expect(WangTiles.index(true, true, true, true) == 15, "all upper is wang 15")
	_expect(WangTiles.index(false, false, false, true) == 1, "SE is bit 1")
	_expect(WangTiles.index(false, false, true, false) == 2, "SW is bit 2")
	_expect(WangTiles.index(false, true, false, false) == 4, "NE is bit 4")
	_expect(WangTiles.index(true, false, false, false) == 8, "NW is bit 8")
	_expect(not WangTiles.is_upper(WangTiles.PAIR_WATER_SHORE, ChunkGenerator.TILE_WATER), "water is the lower terrain")
	_expect(WangTiles.is_upper(WangTiles.PAIR_WATER_SHORE, ChunkGenerator.TILE_SHORE), "shore is the upper terrain on the water sheet")
	_expect(WangTiles.is_upper(WangTiles.PAIR_MOSS_TRAIL, ChunkGenerator.TILE_TRAIL), "trail is the upper terrain")
	_expect(not WangTiles.is_upper(WangTiles.PAIR_MOSS_TRAIL, ChunkGenerator.TILE_MOSS), "moss is the lower terrain on the trail sheet")
	_expect(WangTiles.pick_pair(ChunkGenerator.TILE_WATER, []) == WangTiles.PAIR_WATER_SHORE, "water uses the water sheet")
	_expect(WangTiles.pick_pair(ChunkGenerator.TILE_TRAIL, []) == WangTiles.PAIR_MOSS_TRAIL, "trail uses the trail sheet")
	var moss_next_trail: Array[int] = [ChunkGenerator.TILE_TRAIL]
	_expect(WangTiles.pick_pair(ChunkGenerator.TILE_MOSS, moss_next_trail) == WangTiles.PAIR_MOSS_TRAIL, "moss beside a trail uses the trail sheet")


func _test_wang_sheets_load() -> void:
	print("wang sheets load")
	var wang := WangTiles.new()
	wang.load_coastal()
	_expect(wang.ready(), "the four coastal sheets load")


func _test_granite_is_a_rock_not_a_floor() -> void:
	print("granite is a rock object")
	var data := _gen(11)
	var tiles: PackedInt32Array = data["tiles"]
	var rocks: Array = data["rocks"]
	var clutter: Array = data["clutter"]
	var has_rock := false
	var has_clutter := false
	var granite_tiles := 0
	for i in tiles.size():
		if tiles[i] == ChunkGenerator.TILE_GRANITE:
			granite_tiles += 1
		if rocks[i] == "granite":
			has_rock = true
		if clutter[i] != ChunkGenerator.CLUTTER_NONE:
			has_clutter = true
	_expect(granite_tiles == 0, "no granite baked into the floor")
	_expect(has_rock, "seed 11 has at least one granite boulder")
	_expect(has_clutter, "seed 11 has forest-floor clutter")
	var chunk := _chunk(11)
	var occupied := 0
	for child in chunk.get_children():
		if child is Node2D and str((child as Node2D).get_meta("kind", "")) == "clutter":
			if chunk.cell_occupied(chunk.cell_of_prop(child)):
				occupied += 1
	_expect(occupied == 0, "clutter does not take the tile")
	chunk.free()


func _test_fallen_tree_gives_wood() -> void:
	print("fallen tree gives wood")
	var interact := Interact.new()
	interact.biome = _coast()
	interact.supplies = Supplies.new()
	var log := _prop(Vector2i(4, 4), "fallen", "fir")
	_expect(interact.use_on(log) == "chop", "Space on a fallen fir gives wood")
	_expect(interact.supplies.wood == Supplies.WOOD_PER_TREE, "a fallen tree pays like a standing one")
	_expect(interact.use_on(log) == "", "a fallen tree is not chopped twice")
	var rock := _prop(Vector2i(5, 5), "rock", "granite")
	_expect(interact.use_on(rock) == "", "rocks do nothing yet")
	_expect(interact.supplies.wood == Supplies.WOOD_PER_TREE, "a rock adds no wood")
	interact.free()
	log.free()
	rock.free()


func _test_branch_gives_half_wood() -> void:
	print("fallen branch gives half wood")
	var interact := Interact.new()
	interact.biome = _coast()
	interact.supplies = Supplies.new()
	var twig := _prop(Vector2i(3, 3), "branch", "fir_branch")
	_expect(interact.use_on(twig) == "clear", "Space clears a fir branch")
	_expect(is_equal_approx(interact.supplies.wood, Supplies.WOOD_PER_BRANCH), "a branch is half a wood")
	_expect(interact.use_on(twig) == "", "a branch is not cleared twice")
	var moss := _prop(Vector2i(3, 4), "clutter", "sphagnum")
	_expect(interact.use_on(moss) == "", "sphagnum is not firewood")
	var needles := _prop(Vector2i(3, 5), "clutter", "needles")
	_expect(interact.use_on(needles) == "", "needles are not firewood")
	_expect(is_equal_approx(interact.supplies.wood, Supplies.WOOD_PER_BRANCH), "litter does not add wood")
	var tree := _prop(Vector2i(4, 3), "tree", "fir")
	_expect(interact.use_on(tree) == "chop", "a standing tree still chops")
	_expect(is_equal_approx(interact.supplies.wood, Supplies.WOOD_PER_BRANCH + Supplies.WOOD_PER_TREE), "tree wood stays 3")
	interact.free()
	twig.free()
	moss.free()
	needles.free()
	tree.free()


func _test_trail_is_a_game_path() -> void:
	print("trail is a game path")
	var data := _gen(11)
	var tiles: PackedInt32Array = data["tiles"]
	var wide := 0
	for ty in ChunkGenerator.HEIGHT:
		var run := 0
		for tx in ChunkGenerator.WIDTH:
			if tiles[ty * ChunkGenerator.WIDTH + tx] == ChunkGenerator.TILE_TRAIL:
				run += 1
				if run > 1:
					wide += 1
			else:
				run = 0
	_expect(wide == 0, "the caribou trail is one tile wide")


func _test_coast_runs_east_west() -> void:
	print("coast runs east-west")
	var gen := ChunkGenerator.new()
	var east := gen.generate(11, 1, 0, _coast())
	var sea := gen.generate(11, 0, 1, _coast())
	var inland := gen.generate(11, 0, -1, _coast())
	var east_tiles: PackedInt32Array = east["tiles"]
	var sea_tiles: PackedInt32Array = sea["tiles"]
	var inland_tiles: PackedInt32Array = inland["tiles"]
	var east_water := 0
	var sea_water := 0
	var inland_water := 0
	var south := ChunkGenerator.HEIGHT - 1
	for tx in ChunkGenerator.WIDTH:
		if east_tiles[south * ChunkGenerator.WIDTH + tx] == ChunkGenerator.TILE_WATER:
			east_water += 1
	for i in sea_tiles.size():
		if sea_tiles[i] == ChunkGenerator.TILE_WATER:
			sea_water += 1
		if inland_tiles[i] == ChunkGenerator.TILE_WATER:
			inland_water += 1
	_expect(east_water == ChunkGenerator.WIDTH, "the shore continues east of the landing")
	_expect(sea_water == sea_tiles.size(), "south of the landing is sea")
	_expect(inland_water == 0, "north of the landing is woods, not sea")


func _test_inland_chunk_continues_the_trail() -> void:
	print("inland chunk continues the trail")
	var gen := ChunkGenerator.new()
	var land := gen.generate(11, 0, 0, _coast())
	var inland := gen.generate(11, 0, -1, _coast())
	var again := gen.generate(11, 0, -1, _coast())
	_expect(inland["tiles"] == again["tiles"], "the inland woods are stable")
	var land_tiles: PackedInt32Array = land["tiles"]
	var inland_tiles: PackedInt32Array = inland["tiles"]
	var north_tx := -1
	var south_tx := -1
	for tx in ChunkGenerator.WIDTH:
		if land_tiles[tx] == ChunkGenerator.TILE_TRAIL:
			north_tx = tx
		if inland_tiles[(ChunkGenerator.HEIGHT - 1) * ChunkGenerator.WIDTH + tx] == ChunkGenerator.TILE_TRAIL:
			south_tx = tx
	_expect(north_tx >= 0, "the trail reaches the north edge of the landing")
	_expect(south_tx >= 0, "the trail enters the next woods")
	_expect(absi(north_tx - south_tx) <= 1, "the trail meets across the seam")


func _test_world_cells_cross_chunks() -> void:
	print("world cells cross chunks")
	_expect(ChunkGenerator.chunk_of_cell(Vector2i(0, -1)) == Vector2i(0, -1), "a cell north of the origin is the north chunk")
	_expect(ChunkGenerator.local_of_cell(Vector2i(0, -1)) == Vector2i(0, ChunkGenerator.HEIGHT - 1), "negative y wraps to the south edge of the north chunk")
	_expect(ChunkGenerator.world_cell_at(Vector2(8, -8)) == Vector2i(0, -1), "pixels just north of the landing are the next cell")


func _test_peek_ground_matches_sea_and_woods() -> void:
	print("peek ground does not need a built chunk")
	var gen := ChunkGenerator.new()
	_expect(gen.peek_ground(11, 24, ChunkGenerator.HEIGHT + 2) == ChunkGenerator.TILE_WATER, "south of the landing is sea without building a chunk")
	_expect(gen.peek_ground(11, 24, -2) != ChunkGenerator.TILE_WATER, "north of the landing is walkable without building a chunk")


func _test_rocks_and_logs_block_walking() -> void:
	print("rocks and logs block walking")
	var chunk := MapChunk.new()
	var rock := _prop(Vector2i(4, 4), "rock", "granite")
	var log := _prop(Vector2i(5, 5), "fallen", "fir")
	var tree := _prop(Vector2i(6, 6), "tree", "fir")
	var bush := _prop(Vector2i(7, 7), "forage", "bakeapple")
	var twig := _prop(Vector2i(8, 8), "branch", "fir_branch")
	chunk.add_child(rock)
	chunk.add_child(log)
	chunk.add_child(tree)
	chunk.add_child(bush)
	chunk.add_child(twig)
	chunk.register_prop(rock)
	chunk.register_prop(log)
	chunk.register_prop(tree)
	chunk.register_prop(bush)
	chunk.register_prop(twig)
	_expect(chunk.cell_blocks_walk(Vector2i(4, 4)), "a granite rock blocks the path")
	_expect(chunk.cell_blocks_walk(Vector2i(5, 5)), "a fallen log blocks the path")
	_expect(chunk.cell_blocks_walk(Vector2i(6, 6)), "a standing tree blocks the path")
	_expect(not chunk.cell_blocks_walk(Vector2i(7, 7)), "a berry bush does not block the path")
	_expect(not chunk.cell_blocks_walk(Vector2i(8, 8)), "a fallen branch does not block the path")
	_expect(not chunk.cell_blocks_walk(Vector2i(3, 3)), "empty moss does not block")
	chunk.free()


func _test_night_costs_six_hearts() -> void:
	print("night costs six hearts of cold")
	var dark := DayClock.cold_seconds()
	var drain := dark / Supplies.COLD_SECONDS * Supplies.HEART_STEP
	_expect(is_equal_approx(dark, 60.0), "the cold night is sixty seconds")
	_expect(is_equal_approx(drain, 6.0), "standing the night is six hearts")
	var clock := DayClock.new()
	clock.elapsed = DayClock.DAY_SECONDS
	_expect(clock.is_night(), "night has started")
	clock.elapsed = DayClock.DAY_SECONDS + dark - 0.01
	_expect(clock.is_night(), "the last moment of night is still cold")
	clock.elapsed = DayClock.DAY_SECONDS + dark
	_expect(clock.phase() == "dawn", "dawn starts after the cold night")
	clock.free()


func _test_fallen_log_blocks_its_length() -> void:
	print("fallen log blocks its length")
	var chunk := MapChunk.new()
	var log := _prop(Vector2i(10, 10), "fallen", "fir")
	log.set_meta("span_x", 2)
	chunk.add_child(log)
	chunk.register_prop(log)
	_expect(chunk.cell_blocks_walk(Vector2i(8, 10)), "the left end of the log blocks")
	_expect(chunk.cell_blocks_walk(Vector2i(9, 10)), "the left of the log blocks")
	_expect(chunk.cell_blocks_walk(Vector2i(10, 10)), "the middle of the log blocks")
	_expect(chunk.cell_blocks_walk(Vector2i(11, 10)), "the right of the log blocks")
	_expect(chunk.cell_blocks_walk(Vector2i(12, 10)), "the right end of the log blocks")
	_expect(not chunk.cell_blocks_walk(Vector2i(7, 10)), "past the left end is open")
	_expect(not chunk.cell_blocks_walk(Vector2i(13, 10)), "past the right end is open")
	_expect(not chunk.cell_blocks_walk(Vector2i(10, 9)), "north of the log is open")
	chunk.release_prop(log)
	_expect(not chunk.cell_blocks_walk(Vector2i(10, 10)), "chopping the log opens the middle")
	_expect(not chunk.cell_blocks_walk(Vector2i(8, 10)), "chopping the log opens the ends")
	chunk.free()


func _test_campfire_burns_one_night() -> void:
	print("campfire burns one night")
	var fire := Campfire.new()
	fire.build_visual()
	_expect(is_equal_approx(fire.lifetime, DayClock.cold_seconds()), "a fire is built for one night")
	_expect(not fire.consume(DayClock.cold_seconds() - 0.1), "almost a night still burns")
	_expect(fire.lit, "the fire is still lit")
	_expect(fire.consume(0.2), "one night puts it out")
	_expect(not fire.lit, "the fire is out")
	_expect(not fire.consume(1.0), "a dead fire does not expire twice")
	var clock := DayClock.new()
	clock.elapsed = DayClock.DAY_SECONDS
	_expect(is_equal_approx(clock.seconds_until_dawn(), DayClock.cold_seconds()), "sleep at nightfall spends one night of fire")
	clock.free()
	fire.free()


func _test_night_is_cold_away_from_fire() -> void:
	print("night is cold away from a fire")
	var supplies := Supplies.new()
	_expect(supplies.tick_vitals(true, true, Supplies.COLD_SECONDS) == "", "a fire keeps the night")
	_expect(supplies.hearts == 3, "warmth spends no hearts")
	_expect(supplies.tick_vitals(true, false, Supplies.COLD_SECONDS) == "cold", "cold night spends half a heart")
	_expect(is_equal_approx(supplies.hearts, 2.5), "half a heart is gone")
	_expect(supplies.tick_vitals(false, false, Supplies.HEAL_SECONDS) == "heal", "day heals slowly")
	_expect(is_equal_approx(supplies.hearts, 3.0), "half a heart came back")
	supplies.hearts = 2.5
	_expect(supplies.tick_vitals(true, false, Supplies.COLD_SECONDS) == "cold", "the next chill is another half")
	_expect(is_equal_approx(supplies.hearts, 2.0), "a full heart is two chills")
	supplies.hearts = 0.5
	_expect(supplies.tick_vitals(true, false, Supplies.COLD_SECONDS) == "", "the last half-heart stays")
	_expect(is_equal_approx(supplies.hearts, 0.5), "night does not kill him this slice")


func _test_sleep_jumps_to_dawn() -> void:
	print("sleep jumps to dawn")
	var clock := DayClock.new()
	clock.elapsed = 10.0
	_expect(not clock.can_sleep(), "day is too bright to sleep")
	_expect(not clock.sleep_to_dawn(), "day sleep is refused")
	clock.elapsed = DayClock.DAY_SECONDS + 5.0
	_expect(clock.can_sleep(), "night can sleep")
	_expect(clock.sleep_to_dawn(), "night sleep is taken")
	_expect(clock.phase() == "dawn", "sleep wakes at dawn")
	_expect(not clock.is_night(), "dawn is not night")
	clock.free()


func _test_coastal_north_has_grove_music() -> void:
	print("coastal north has grove music")
	var coast := _coast()
	_expect(coast.music_path == "res://art/coastal_north/the_first_grove.mp3", "the first grove is the coastal bed")
	_expect(FileAccess.file_exists(coast.music_path), "the grove track is in the project")
	if ResourceLoader.exists(coast.music_path):
		var stream := load(coast.music_path)
		_expect(stream is AudioStream, "the grove track loads")
	else:
		_expect(true, "the grove track loads after Godot imports it")
	var valley := BiomeCatalog.new()
	valley.load_all()
	_expect(valley.get_biome(&"river_valley").music_path == "", "river valley has no music yet")


func _test_fog_reveals_the_visible_view() -> void:
	print("fog reveals the visible view")
	var fog := FogMap.new()
	_expect(not fog.is_revealed(Vector2i(0, 0)), "new fog is closed")
	var rect := FogMap.view_rect(Vector2(240, 135))
	_expect(rect.position == Vector2i(0, 0), "the play view starts at the top-left tile")
	_expect(rect.size.x == 30, "the play view is thirty tiles wide")
	_expect(rect.size.y >= 16 and rect.size.y <= 17, "the play view is about seventeen tiles tall")
	_expect(fog.reveal_rect(rect), "the screen opens")
	_expect(fog.is_revealed(Vector2i(0, 0)), "the near corner of the view is open")
	_expect(fog.is_revealed(Vector2i(29, 0)), "the far edge of the view is open")
	_expect(fog.is_revealed(Vector2i(15, 8)), "the middle of the view is open")
	_expect(not fog.is_revealed(Vector2i(30, 0)), "past the screen stays fog")
	_expect(not fog.is_revealed(Vector2i(0, rect.position.y + rect.size.y)), "past the bottom of the screen stays fog")
	_expect(not fog.reveal_rect(rect), "the same view does not open again")
	fog.clear()
	_expect(not fog.is_revealed(Vector2i(0, 0)), "new woods wipe the walk")
	_expect(fog.reveal(Vector2i(4, 6)), "a single cell still works")
	_expect(not fog.is_revealed(Vector2i(5, 6)), "reveal() alone is still one cell")
	_expect(FogMap.VIEW == FogMap.RADIUS * 2 + 1, "the circle is centered on an odd canvas")
	_expect(FogMap.PLAY_SIZE == Vector2(480, 270), "fog uses the play view size")


func _test_minimap_paints_revealed_tiles() -> void:
	print("minimap paints only a local circle")
	var fog := FogMap.new()
	var player_cell := Vector2i(10, 10)
	var trail_cell := player_cell + Vector2i(1, 0)
	var moss_cell := player_cell + Vector2i(0, 1)
	var far_cell := player_cell + Vector2i(FogMap.RADIUS + 4, 0)
	var trail_color := Color8(204, 102, 51, 255)
	var moss_color := Color8(51, 102, 51, 255)
	var sample := func(cell: Vector2i) -> int:
		if cell == trail_cell:
			return ChunkGenerator.TILE_TRAIL
		return ChunkGenerator.TILE_MOSS
	var color_of := func(kind: int) -> Color:
		if kind == ChunkGenerator.TILE_TRAIL:
			return trail_color
		return moss_color
	var closed := fog.paint(sample, color_of, player_cell)
	_expect(closed.get_width() == FogMap.VIEW, "minimap width is the circle")
	_expect(closed.get_height() == FogMap.VIEW, "minimap height is the circle")
	_expect(closed.get_pixel(0, 0).a == 0.0, "outside the circle is clear")
	_expect(closed.get_pixel(FogMap.RADIUS, FogMap.RADIUS) == FogMap.LEIF_COLOR, "leif is the center pip")
	var east := fog.map_pixel(trail_cell, player_cell)
	_expect(closed.get_pixel(east.x, east.y) == FogMap.FOG_COLOR, "an unwalked neighbor stays fog")
	fog.reveal(player_cell)
	fog.reveal(trail_cell)
	fog.reveal(moss_cell)
	fog.reveal(far_cell)
	_expect(fog.is_revealed(far_cell), "a far step is still remembered")
	_expect(not fog.in_view(far_cell, player_cell), "a far step is outside this circle")
	var open := fog.paint(sample, color_of, player_cell)
	_expect(open.get_pixel(east.x, east.y) == trail_color, "a walked neighbor in view shows trail")
	var south := fog.map_pixel(moss_cell, player_cell)
	_expect(open.get_pixel(south.x, south.y) == moss_color, "a walked neighbor in view shows moss")
	_expect(open.get_pixel(FogMap.RADIUS, FogMap.RADIUS) == FogMap.LEIF_COLOR, "leif stays the center pip")
	_expect(open.get_pixel(0, 0).a == 0.0, "the corner stays outside the circle")


func _test_chop_leaves_named_stump() -> void:
	print("chop leaves a named stump")
	_expect(FileAccess.file_exists("res://art/coastal_north/stump_fir.png"), "fir stump art is in the project")
	_expect(FileAccess.file_exists("res://art/coastal_north/stump_spruce.png"), "spruce stump art is in the project")
	var chunk := _chunk(11)
	var interact := Interact.new()
	interact.biome = _coast()
	interact.supplies = Supplies.new()
	var tree: Node2D = null
	for node in chunk.prop_nodes():
		if str(node.get_meta("kind")) == "tree" and str(node.get_meta("species")) == "fir":
			tree = node
			break
	_expect(tree != null, "seed 11 has a fir to chop")
	if tree != null:
		var cell := chunk.cell_of_prop(tree)
		_expect(interact.use_on(tree) == "chop", "chop the fir")
		chunk.release_prop(tree)
		var stump := _stump_at(chunk, cell)
		_expect(stump != null, "the fir left a stump")
		if stump != null:
			_expect(str(stump.get_meta("species")) == "fir", "the leftover is a fir stump")
			var sprite: Sprite2D = null
			for child in stump.get_children():
				if child is Sprite2D:
					sprite = child
			_expect(sprite != null and sprite.texture != null, "the fir stump uses the named PNG")
			if sprite != null and sprite.texture != null:
				_expect(sprite.texture.resource_path.ends_with("stump_fir.png"), "the leftover is the fir stump")
				_expect(sprite.texture.get_width() == 32 and sprite.texture.get_height() == 32, "the stump keeps the ringed 32 source")
				_expect(is_equal_approx(sprite.scale.x, MapChunk.STUMP_SCALE), "the stump is drawn smaller than the source")
	chunk.free()
	interact.free()


func _stump_at(chunk: MapChunk, cell: Vector2i) -> Node2D:
	for child in chunk.get_children():
		if not child is Node2D:
			continue
		var node := child as Node2D
		if str(node.get_meta("kind", "")) != "stump":
			continue
		if chunk.cell_of_prop(node) == cell:
			return node
	return null


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


func _test_title_menu() -> void:
	print("title menu")
	var menu := TitleMenu.new()
	root.add_child(menu)
	menu.assemble()
	_expect(ProjectSettings.get_setting("application/run/main_scene") == "res://title/title.tscn", "play opens on the title")
	_expect(menu.screen == TitleMenu.Screen.CHOOSE, "title opens on New Game and Continue")
	_expect(menu.get_node_or_null("Shore") != null, "the coast fills the title")
	_expect(menu.get_node_or_null("Menu/MenuPlate") != null, "the menu is a green box on the coast")
	var opening := menu.get_node("Menu/Buttons")
	_expect(opening.get_child_count() == 2, "there is no Start button")
	_expect((opening.get_child(0) as Button).text == "New Game", "New Game is on the title")
	_expect((opening.get_child(1) as Button).text == "Continue", "Continue is on the title")
	var picture := menu.get_node_or_null("Picture")
	_expect(picture != null and picture.get_node_or_null("Leif") != null, "leif stands on the coast")
	_expect(picture != null and picture.get_child_count() > 3, "the coast has trees and ground junk")
	_expect(FileAccess.file_exists(TitleMenu.ART_LEIF), "leif south sprite is in the project")
	_expect(FileAccess.file_exists(TitleMenu.ART_FIR), "fir sprite is in the project")
	_expect(FileAccess.file_exists(TitleMenu.ART_SPRUCE), "spruce sprite is in the project")
	menu.press_back()
	_expect(menu.screen == TitleMenu.Screen.CHOOSE, "Escape on the title stays there")
	var first := menu.get_node("Menu/Buttons").get_child(0) as Button
	_expect(first != null and not first.has_focus(), "new game is not highlighted until the pointer is on it")
	_click_title(menu, "Continue")
	_expect(menu.screen == TitleMenu.Screen.SLOTS, "Continue opens the slots")
	_expect(menu.slot_count() == 3, "three save slots")
	for i in 3:
		_expect(menu.slot_label(i) == "No save file", "slot says No save file")
		_expect(not menu.can_load_slot(i), "empty slot cannot load")
	_click_title(menu, "No save file")
	_expect(menu.screen == TitleMenu.Screen.SLOTS, "an empty slot stays on the menu")
	_expect(menu.new_game_scene() == "res://world/world.tscn", "New Game opens the woods")
	_click_title(menu, "Back")
	_expect(menu.screen == TitleMenu.Screen.CHOOSE, "Back from the files returns to New Game and Continue")
	_click_title(menu, "New Game")
	_expect(menu.is_departing(), "new game starts loading at once")
	var leif := menu.get_node("Picture/Leif") as Sprite2D
	_expect(leif != null and leif.position.y <= 190.0, "leif stands on the bank, not in the water")
	_expect(TitleMenu.DEPART_SPEED < Player.WALK_SPEED, "the loading stroll is slower than his woods walk")
	_expect(leif != null and str(leif.texture.resource_path).find("north") < 0, "leif still faces you while the menu fades")
	_expect(menu.get_node("Menu").visible, "the menu is still up at the start of the fade")
	menu._process(TitleMenu.FADE_SEC)
	_expect(str(leif.texture.resource_path).find("north") >= 0, "after the fade, leif turns his back and walks")
	_expect(not menu.get_node("Menu").visible, "the menu box is gone once he walks")
	_expect(menu.is_departing(), "he keeps walking while the woods are still loading")
	menu._process(6.0)
	_expect(leif.position.y < 0.0, "leif walks off the top instead of stopping there")
	_expect(menu.is_departing(), "walking off does not open the woods before the seed is ready")
	menu.free()


func _test_sphagnum_cushion_is_whole() -> void:
	print("sphagnum cushion keeps its bottom-right")
	var tex := load("res://art/coastal_north/clutter_sphagnum.png") as Texture2D
	_expect(tex != null, "sphagnum picture loads")
	if tex == null:
		return
	var img := tex.get_image()
	_expect(img != null, "sphagnum picture can be read")
	if img == null:
		return
	var whole := true
	for px in [Vector2i(20, 22), Vector2i(16, 24), Vector2i(12, 25)]:
		if img.get_pixel(px.x, px.y).a <= 0.5:
			whole = false
	_expect(whole, "the bottom-right of the cushion is part of the plant")


func _test_sphagnum_is_smaller_than_leif() -> void:
	print("sphagnum is smaller than leif")
	var source := load("res://art/coastal_north/clutter_sphagnum.png") as Texture2D
	_expect(source != null and source.get_width() == 32 and source.get_height() == 32, "the cushion picture stays 32")
	var chunk := MapChunk.new()
	var stamp := chunk._stamp_image("clutter", "sphagnum")
	_expect(stamp != null, "sphagnum stamps onto the ground")
	if stamp != null and source != null:
		var drawn := int(round(float(source.get_width()) * MapChunk.SPHAGNUM_SCALE))
		_expect(stamp.get_width() == drawn and stamp.get_height() == drawn, "the cushion is stamped at half size")
		_expect(stamp.get_width() <= ChunkGenerator.TILE, "a cushion fits on one tile")
		_expect(stamp.get_height() < int(64.0 * Player.SPRITE_SCALE), "a cushion is shorter than leif")
		_expect(stamp.get_pixel(10, 11).a > 0.5, "the bottom-right of the small cushion is still the plant")
	var needles := chunk._stamp_image("clutter", "needles")
	_expect(needles != null and needles.get_width() == 32, "needles keep their own size")
	chunk.free()


func _test_world_loads_in_slices() -> void:
	print("world loads in slices")
	var world := World.new()
	world.begin_staged_boot()
	var done := false
	for _i in 16:
		done = world.stage_boot_step()
	_expect(not done, "a few slices are not the whole coast")
	_expect(world.boot_chunk_count() > 0, "a slice builds a chunk")
	world.free()


func _click_title(menu: TitleMenu, text: String) -> void:
	var column := menu.get_node("Menu/Buttons")
	for child in column.get_children():
		var button := child as Button
		if button != null and button.text == text:
			button.pressed.emit()
			return
	_expect(false, "no title button %s" % text)
