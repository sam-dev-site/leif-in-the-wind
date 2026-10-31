extends SceneTree

## Headless checks for the continent systems. Run:
##   godot --headless --path game -s res://tests/run.gd

var _failed := 0


func _init() -> void:
	# Pin admin away from the owner's QC file before anything else reads it.
	_wipe_admin()
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
	_test_woodcutting_skill()
	_test_firemaking_skill()
	_test_forage_skill()
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
	_test_death_and_respawn()
	_test_fallen_log_blocks_its_length()
	_test_campfire_burns_one_night()
	_test_coastal_north_has_grove_music()
	_test_fog_reveals_a_small_circle()
	_test_minimap_paints_revealed_tiles()
	_test_chop_leaves_named_stump()
	_test_title_menu()
	_test_shore_saves()
	_test_world_loads_in_slices()
	_test_sphagnum_cushion_is_whole()
	_test_sphagnum_is_smaller_than_leif()
	_test_fallen_branch_is_smaller_than_the_trees()
	_test_admin_settings()
	_test_quit_to_menu()
	_test_caribou_on_the_trail()
	_test_arctic_hare_on_the_moss()
	_wipe_admin()
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
	interact.skills = Skills.new()
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
		var xp_before := interact.skills.forage_xp
		var cell := chunk.cell_of_prop(node)
		_expect(interact.use_on(node) == "forage", "pick %s" % species)
		_expect(interact.use_on(node) == "", "%s cannot be picked twice" % species)
		_expect(interact.supplies.forage == before + 1, "%s adds one forage" % species)
		_expect(interact.skills.forage_xp == xp_before + Skills.XP_PER_PICK, "%s trains foraging" % species)
		chunk.release_prop(node)
		var i := cell.y * ChunkGenerator.WIDTH + cell.x
		_expect(str(chunk.data["forage"][i]) == "", "%s bush is gone" % species)
		_expect(not chunk.cell_occupied(cell), "%s tile is empty" % species)
	_expect(interact.supplies.forage == 2, "forage count is both bushes")
	_expect(interact.skills.forage_xp == Skills.XP_PER_PICK * 2, "bakeapple and blueberry share the skill")
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
		var before: float = interact.supplies.wood
		_expect(_fell(interact, node) == "chop", "chop %s" % species)
		_expect(is_equal_approx(interact.supplies.wood, before + Skills.new().wood_at(1)), "%s adds wood" % species)
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
	_expect(is_equal_approx(interact.supplies.wood, Skills.new().wood_at(1) * 2.0), "two trees of wood")
	_expect(interact.supplies.forage == 0, "chopping does not give forage")
	_expect(interact.supplies.hearts == interact.supplies.hearts_max, "chopping does not spend hearts")
	chunk.free()
	interact.free()


func _test_woodcutting_skill() -> void:
	print("woodcutting skill")
	var skill := Skills.new()
	_expect(Skills.xp_for_level(1) == 0, "level 1 starts at zero xp")
	_expect(Skills.xp_for_level(2) == 83, "level 2 is the old school step")
	_expect(Skills.xp_for_level(30) == 13363, "level 30 keeps the old school table")
	_expect(skill.wood_at(1) == 0.5, "a first tree is half a wood")
	_expect(skill.wood_at(30) == 3.0, "level 30 pays today's three")
	_expect(skill.wood_at(99) == 10.0, "level 99 pays ten")
	_expect(Skills.chop_range(1) == Vector2i(3, 4), "the first trees take three or four")
	_expect(Skills.chop_range(30) == Vector2i(2, 3), "level 30 still rolls a range")
	_expect(Skills.chop_range(80) == Vector2i(1, 1), "high levels are a sure chop")
	_expect(skill.step_label() == "0/83", "the hover starts empty")
	_expect(skill.add_woodcutting_xp(25) == 0, "one fell is not yet a level")
	_expect(skill.step_label() == "25/83", "the hover counts into the step")
	skill.add_woodcutting_xp(25)
	skill.add_woodcutting_xp(25)
	_expect(skill.level() == 1, "three fells stay level 1")
	_expect(skill.add_woodcutting_xp(25) == 1, "the fourth fell is level 2")
	_expect(skill.level() == 2, "woodcutting is now 2")
	_expect(skill.step_label() == "17/91", "the hover resets into the next step")
	_expect(float(Skills.xp_for_level(92)) / float(Skills.xp_for_level(99)) > 0.75, "92 is not half of 99")
	var interact := Interact.new()
	interact.biome = _coast()
	interact.supplies = Supplies.new()
	interact.skills = Skills.new()
	var fir := _prop(Vector2i(2, 2), "tree", "fir")
	_expect(interact.use_on(fir) == "bite", "the first Space does not fell")
	_expect(interact.supplies.wood == 0.0, "a bite gives no wood")
	_expect(interact.skills.woodcutting_xp == 0, "a bite gives no xp")
	_expect(_fell(interact, fir) == "chop", "the last Space fells the fir")
	_expect(is_equal_approx(interact.supplies.wood, 0.5), "the fall pays half a wood")
	_expect(interact.skills.woodcutting_xp == Skills.XP_PER_FELL, "the fall grants xp")
	var spruce := _prop(Vector2i(3, 2), "tree", "spruce")
	_expect(_fell(interact, spruce) == "chop", "spruce trains the same skill")
	_expect(interact.skills.woodcutting_xp == Skills.XP_PER_FELL * 2, "spruce shares the 25")
	var log := _prop(Vector2i(4, 2), "fallen", "fir")
	_expect(_fell(interact, log) == "chop", "a fallen log trains woodcutting")
	_expect(interact.skills.woodcutting_xp == Skills.XP_PER_FELL * 3, "a log shares the 25")
	var twig := _prop(Vector2i(5, 2), "branch", "fir_branch")
	var xp_before := interact.skills.woodcutting_xp
	_expect(interact.use_on(twig) == "clear", "a branch is still one tap")
	_expect(interact.skills.woodcutting_xp == xp_before, "a branch grants no xp")
	fir.free()
	spruce.free()
	log.free()
	twig.free()
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
	_expect(is_equal_approx(supplies.wood, Supplies.WOOD_PER_TREE), "wood comes from the listed tree")
	_expect(not supplies.pick_forage("bakeapple", narrow), "bakeapple is absent from this biome list")
	_expect(supplies.pick_forage("blueberry", narrow), "blueberry is on this biome list")
	_expect(is_equal_approx(Supplies.CAMPFIRE_WOOD, Skills.FIRE_WOOD_START), "the early fire tax is 7 wood")
	_expect(Supplies.WOOD_PER_TREE < Supplies.CAMPFIRE_WOOD, "one comfortable tree no longer buys a fire alone")
	var interact := Interact.new()
	interact.biome = coast
	interact.supplies = Supplies.new()
	var fake := _prop(Vector2i(1, 1), "tree", "butternut")
	_expect(interact.use_on(fake) == "", "a butternut prop is not chopped")
	_expect(not bool(fake.get_meta("harvested", false)), "a rejected tree stays standing")
	_expect(interact.supplies.wood == 0, "a rejected chop adds no wood")
	fake.free()
	interact.free()


func _test_firemaking_skill() -> void:
	print("firemaking skill")
	_expect(Skills.XP_PER_LIGHT > Skills.XP_PER_FELL, "a light grants more xp than a fell")
	_expect(is_equal_approx(Skills.catch_chance(1), Skills.CATCH_START), "level 1 catch is the start chance")
	_expect(is_equal_approx(Skills.catch_chance(30), Skills.CATCH_SURE), "level 30 catch is sure-ish")
	_expect(is_equal_approx(Skills.catch_chance(99), Skills.CATCH_SURE), "level 99 catch stays at 95%")
	_expect(Skills.catch_chance(15) > Skills.catch_chance(1), "catch climbs before 30")
	_expect(is_equal_approx(Skills.fire_wood_cost(1), 7.0), "level 1 fire costs 7")
	_expect(is_equal_approx(Skills.fire_wood_cost(30), 7.0), "level 30 fire still costs 7")
	_expect(is_equal_approx(Skills.fire_wood_cost(99), 1.0), "level 99 fire costs 1")
	_expect(Skills.fire_wood_cost(50) < 7.0, "past 30 the wood cost drops")
	var skill := Skills.new()
	_expect(skill.firemaking_level() == 1, "fire-making starts at 1")
	_expect(skill.add_firemaking_xp(Skills.XP_PER_LIGHT) == 0, "one light is not yet a level")
	_expect(skill.firemaking_xp == Skills.XP_PER_LIGHT, "the light grants 40")
	skill.add_firemaking_xp(Skills.XP_PER_LIGHT)
	_expect(skill.firemaking_level() == 1, "80 xp is still level 1")
	_expect(skill.add_firemaking_xp(3) == 1, "83 xp is level 2")
	_expect(skill.firemaking_level() == 2, "fire-making is now 2")
	_expect(skill.firemaking_step_label() == "0/91", "level 2 step starts empty")
	skill.catch_override = 0
	_expect(not skill.roll_catch(), "override can force a miss")
	skill.catch_override = 1
	_expect(skill.roll_catch(), "override can force a catch")
	var world := _boot_run(0, {})
	var spot := _open_fire_cell(world)
	_expect(spot.x >= 0, "open ground for a fire attempt")
	_stand_facing_cell(world, spot, "north")
	world.skills.catch_override = 1
	world.supplies.wood = 6.0
	world._try_place_campfire()
	_expect(is_equal_approx(world.supplies.wood, 6.0), "short wood is not spent")
	_expect(_campfire_at(world, spot) == null, "short wood leaves no fire")
	_expect(world._hint == "Need 7 wood for a fire.", "the short-wood hint is set")
	world.skills.catch_override = 0
	world.supplies.wood = 7.0
	world._try_place_campfire()
	_expect(is_equal_approx(world.supplies.wood, 0.0), "a miss still spends the wood")
	_expect(world.skills.firemaking_xp == 0, "a miss grants no xp")
	_expect(_campfire_at(world, spot) == null, "a miss leaves no fire")
	_expect(world._hint == "The fire does not catch.", "the miss hint is set")
	world.skills.catch_override = 1
	world.supplies.wood = 7.0
	world._try_place_campfire()
	_expect(_campfire_at(world, spot) != null, "a catch leaves a fire")
	_expect(world.skills.firemaking_xp == Skills.XP_PER_LIGHT, "a catch grants light xp")
	_expect(is_equal_approx(world.supplies.wood, 0.0), "a catch spends the wood")
	world.free()


func _test_forage_skill() -> void:
	print("forage skill")
	_expect(Skills.forage_at(1) == 1, "level 1 pays one berry")
	_expect(Skills.forage_at(29) == 1, "under 30 still pays one")
	_expect(Skills.forage_at(30) == 2, "level 30 pays two")
	_expect(Skills.forage_at(49) == 2, "under 50 pays two")
	_expect(Skills.forage_at(50) == 3, "level 50 pays three")
	_expect(Skills.forage_at(79) == 3, "under 80 pays three")
	_expect(Skills.forage_at(80) == 4, "level 80 pays four")
	_expect(Skills.forage_at(99) == 4, "level 99 pays four")
	_expect(Skills.eat_forage_cost(1) == 10, "level 1 eat costs 10")
	_expect(Skills.eat_forage_cost(10) == 10, "level 10 eat still costs 10")
	_expect(Skills.eat_forage_cost(11) == 9, "level 11 eat costs 9")
	_expect(Skills.eat_forage_cost(30) == 8, "level 30 eat costs 8")
	_expect(Skills.eat_forage_cost(81) == 2, "level 81 eat costs 2")
	_expect(Skills.eat_forage_cost(99) == 2, "level 99 eat stays at 2")
	var skill := Skills.new()
	_expect(skill.forage_level() == 1, "foraging starts at 1")
	_expect(skill.add_forage_xp(Skills.XP_PER_PICK) == 0, "one pick is not yet a level")
	_expect(skill.forage_xp == Skills.XP_PER_PICK, "the pick grants 10")
	for _i in range(7):
		skill.add_forage_xp(Skills.XP_PER_PICK)
	_expect(skill.forage_level() == 1, "80 xp is still level 1")
	_expect(skill.add_forage_xp(3) == 1, "83 xp is level 2")
	_expect(skill.forage_level() == 2, "foraging is now 2")
	_expect(skill.forage_step_label() == "0/91", "level 2 step starts empty")
	var forage_kept := skill.forage_xp
	_expect(skill.add_woodcutting_xp(Skills.XP_PER_PICK) == 0, "one fell-sized woodcutting bite is not a level")
	_expect(skill.woodcutting_xp == Skills.XP_PER_PICK, "woodcutting keeps its own pool")
	_expect(skill.forage_xp == forage_kept, "woodcutting xp does not write foraging")
	var interact := Interact.new()
	interact.biome = _coast()
	interact.supplies = Supplies.new()
	interact.skills = Skills.new()
	interact.skills.forage_xp = Skills.xp_for_level(30)
	_expect(interact.skills.forage_level() == 30, "seeded xp is level 30")
	var bush := _prop(Vector2i(4, 4), "forage", "bakeapple")
	_expect(interact.use_on(bush) == "forage", "a level-30 pick works")
	_expect(interact.last_forage == 2, "level 30 pays two berries")
	_expect(interact.supplies.forage == 2, "the pack got two")
	_expect(interact.skills.forage_xp == Skills.xp_for_level(30) + Skills.XP_PER_PICK, "the pick grants xp")
	bush.free()
	var supplies := Supplies.new()
	supplies.forage = 10
	supplies.hearts = 2.0
	_expect(supplies.try_eat(Skills.eat_forage_cost(1)) == "eat", "ten berries heal at level 1")
	_expect(supplies.forage == 0, "level 1 spends all ten")
	supplies.forage = 10
	supplies.hearts = 2.0
	_expect(supplies.try_eat(Skills.eat_forage_cost(11)) == "eat", "the same ten heal at level 11")
	_expect(supplies.forage == 1, "level 11 leaves one berry — no stored quality")
	_expect(is_equal_approx(supplies.hearts, 2.5), "the heal is still half a heart")
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
	_expect(Campfire.try_place(supplies, false, false), "seven wood spends for a fire")
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
	_expect(text.contains("E eat (10 forage)"), "eat costs 10 forage at level 1")
	_expect(text.contains("F campfire (7 wood)"), "the campfire key shows the early cost")
	_expect(text.contains("C sleep"), "sleep is labeled")
	_expect(text.contains("Campfire lit."), "the last action is on the hud")
	_expect(supplies.hearts == 3, "the hud line does not spend hearts")
	text = GameHud.status_text(11, "Coastal North", supplies, "night", "", 3.0)
	_expect(text.contains("F campfire (3 wood)"), "the hud uses the live fire cost")
	text = GameHud.status_text(11, "Coastal North", supplies, "night", "", 7.0, 9)
	_expect(text.contains("E eat (9 forage)"), "the hud uses the live eat cost")


func _test_eat_forage_heals_half_a_heart() -> void:
	print("eat forage heals half a heart")
	var supplies := Supplies.new()
	supplies.forage = 10
	supplies.hearts = 2.0
	supplies.wood = 1.5
	supplies.cold_acc = 1.5
	_expect(supplies.try_eat() == "eat", "ten berries are eaten")
	_expect(supplies.forage == 0, "eating spends ten forage")
	_expect(is_equal_approx(supplies.hearts, 2.5), "eating heals half a heart")
	_expect(is_equal_approx(supplies.wood, 1.5), "eating does not spend wood")
	_expect(is_equal_approx(supplies.cold_acc, 1.5), "eating does not reset the night")
	supplies.forage = 9
	supplies.hearts = 1.0
	_expect(supplies.try_eat() == "short", "nine berries are short of a level-1 heal")
	_expect(supplies.forage == 9, "a short handful is not spent")
	_expect(is_equal_approx(supplies.hearts, 1.0), "a short handful does not heal")
	supplies.forage = 10
	supplies.hearts = supplies.hearts_max
	_expect(supplies.try_eat() == "full", "full hearts refuse the berries")
	_expect(supplies.forage == 10, "a full heart keeps the forage")
	_expect(is_equal_approx(supplies.hearts, supplies.hearts_max), "hearts stay at max")
	supplies.forage = 0
	supplies.hearts = 1.0
	_expect(supplies.try_eat() == "short", "empty hands refuse")
	_expect(supplies.forage == 0, "empty forage stays empty")
	_expect(is_equal_approx(supplies.hearts, 1.0), "refusing does not heal")
	supplies.forage = 11
	supplies.hearts = 2.5
	_expect(supplies.try_eat() == "eat", "a short heart still takes ten berries")
	_expect(is_equal_approx(supplies.hearts, 3.0), "the bite stops at max hearts")
	_expect(supplies.forage == 1, "one berry is left, short of another heal")
	_expect(supplies.try_eat() == "short", "the leftover berry is not eaten")
	supplies.forage = 10
	supplies.hearts = 2.0
	_expect(supplies.try_eat() == "eat", "ten berries before the cold")
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
	_expect(_fell(interact, log) == "chop", "Space on a fallen fir gives wood")
	_expect(is_equal_approx(interact.supplies.wood, Skills.new().wood_at(1)), "a fallen tree pays like a standing one")
	_expect(interact.use_on(log) == "", "a fallen tree is not chopped twice")
	var rock := _prop(Vector2i(5, 5), "rock", "granite")
	_expect(interact.use_on(rock) == "", "rocks do nothing yet")
	_expect(is_equal_approx(interact.supplies.wood, Skills.new().wood_at(1)), "a rock adds no wood")
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
	_expect(_fell(interact, tree) == "chop", "a standing tree still chops")
	_expect(is_equal_approx(interact.supplies.wood, Supplies.WOOD_PER_BRANCH + Skills.new().wood_at(1)), "a level-1 tree pays like a branch")
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
	_expect(supplies.tick_vitals(false, false, 10.0) == "", "day does not heal on its own")
	_expect(is_equal_approx(supplies.hearts, 2.5), "day leaves hearts where they are")
	_expect(supplies.tick_vitals(true, true, 10.0) == "", "fire warmth does not heal")
	_expect(is_equal_approx(supplies.hearts, 2.5), "warmth leaves hearts where they are")
	_expect(supplies.tick_vitals(true, false, Supplies.COLD_SECONDS) == "cold", "the next chill is another half")
	_expect(is_equal_approx(supplies.hearts, 2.0), "a full heart is two chills")
	supplies.hearts = 0.5
	_expect(supplies.tick_vitals(true, false, Supplies.COLD_SECONDS) == "die", "the last half-heart is death")
	_expect(is_equal_approx(supplies.hearts, 0.0), "cold takes the last half-heart")
	supplies.wood = 7.0
	supplies.forage = 5
	supplies.take_death_tax()
	_expect(is_equal_approx(supplies.wood, 3.5), "death halves wood to a tenth")
	_expect(supplies.forage == 2, "death halves forage down")


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


func _test_fog_reveals_a_small_circle() -> void:
	print("fog reveals a small circle")
	var fog := FogMap.new()
	var here := Vector2i(10, 10)
	_expect(not fog.is_revealed(here), "new fog is closed")
	_expect(fog.reveal_circle(here), "a look opens the circle")
	_expect(fog.is_revealed(here), "the cell under him is open")
	_expect(fog.is_revealed(here + Vector2i(FogMap.SIGHT, 0)), "the east edge of the look is open")
	_expect(fog.is_revealed(here + Vector2i(0, -FogMap.SIGHT)), "the north edge of the look is open")
	_expect(not fog.is_revealed(here + Vector2i(FogMap.SIGHT + 1, 0)), "past the circle stays fog")
	_expect(not fog.is_revealed(here + Vector2i(FogMap.SIGHT, FogMap.SIGHT)), "the square corner of the look stays fog")
	_expect(not fog.reveal_circle(here), "the same look does not open again")
	var stepped := here + Vector2i(3, 0)
	_expect(fog.reveal_circle(stepped), "a step opens new ground")
	_expect(fog.is_revealed(here + Vector2i(-FogMap.SIGHT, 0)), "the trail stays clear")
	_expect(fog.is_revealed(stepped + Vector2i(FogMap.SIGHT, 0)), "the new edge is open")
	fog.clear()
	_expect(not fog.is_revealed(here), "new woods wipe the walk")
	_expect(FogMap.VIEW == FogMap.RADIUS * 2 + 1, "the circle is centered on an odd canvas")
	_expect(FogMap.SIGHT < FogMap.RADIUS, "a look is smaller than the map")


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
		_expect(_fell(interact, tree) == "chop", "chop the fir")
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


func _fell(interact: Interact, node: Node2D) -> String:
	var last := ""
	for _i in 8:
		last = interact.use_on(node)
		if last != "bite":
			return last
	return last


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
	_use_empty_saves()
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
	_expect(menu.departing_slot() == 0, "new game claims the first empty box")
	_expect(not ShoreSave.has_slot(0), "the box stays empty until the floppy")
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


func _test_fallen_branch_is_smaller_than_the_trees() -> void:
	print("fallen branch is smaller than the trees")
	var source := load("res://art/coastal_north/clutter_fir_branch.png") as Texture2D
	_expect(source != null and source.get_width() == 32 and source.get_height() == 32, "the branch picture stays 32")
	var chunk := MapChunk.new()
	var branch := chunk._make_named_prop("branch", "fir_branch", Vector2.ZERO, Color(0.22, 0.28, 0.14), Vector2(6, 3))
	var sprite: Sprite2D = null
	for child in branch.get_children():
		if child is Sprite2D:
			sprite = child
	_expect(sprite != null and sprite.texture != null, "the branch uses the named PNG")
	if sprite != null and sprite.texture != null:
		_expect(sprite.texture.resource_path.ends_with("clutter_fir_branch.png"), "the woods keep the same branch picture")
		_expect(is_equal_approx(sprite.scale.x, MapChunk.BRANCH_SCALE), "the branch is drawn about 30 percent smaller")
		_expect(float(sprite.texture.get_width()) * sprite.scale.x < 48.0, "the branch is narrower than a standing fir")
	var tree := chunk._make_tree("fir", Vector2.ZERO)
	var tree_sprite: Sprite2D = null
	for child in tree.get_children():
		if child is Sprite2D:
			tree_sprite = child
	if tree_sprite != null and tree_sprite.texture != null:
		_expect(tree_sprite.texture.get_width() == 48 and tree_sprite.texture.get_height() == 64, "standing fir stays 48 by 64")
		_expect(is_equal_approx(tree_sprite.scale.x, 1.0), "a standing tree is still drawn at full size")
	chunk.free()
	var menu := TitleMenu.new()
	root.add_child(menu)
	menu.assemble()
	var picture := menu.get_node_or_null("Picture")
	var title_ok := false
	if picture != null:
		for child in picture.get_children():
			if not child is Sprite2D:
				continue
			var drawn := child as Sprite2D
			if drawn.texture == null or not drawn.texture.resource_path.ends_with("clutter_fir_branch.png"):
				continue
			title_ok = true
			_expect(is_equal_approx(drawn.scale.x, MapChunk.BRANCH_SCALE), "the title draws the branch at the same smaller size")
	_expect(title_ok, "the title still uses the branch picture")
	menu.free()


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


func _use_empty_saves() -> void:
	ShoreSave.use_directory("user://test_saves")
	ShoreSave.wipe()
	ShoreSave.unix_override = -1


func _wipe_admin() -> void:
	AdminSettings.use_path("user://test_admin.json")
	var abs_path := ProjectSettings.globalize_path(AdminSettings.path)
	if FileAccess.file_exists(AdminSettings.path):
		DirAccess.remove_absolute(abs_path)
	AdminSettings.reset_to_defaults()


func _count_trees(data: Dictionary) -> int:
	var trees: Array = data["trees"]
	var n := 0
	for name in trees:
		if str(name) != "" and str(name) != ChunkGenerator.TREE_NONE:
			n += 1
	return n


func _send_key(node: Node, code: Key) -> void:
	var key := InputEventKey.new()
	key.pressed = true
	key.keycode = code
	if node.has_method("_unhandled_input"):
		node._unhandled_input(key)


func _test_admin_settings() -> void:
	print("admin settings")
	_wipe_admin()
	AdminSettings.load_file()
	_expect(is_equal_approx(AdminSettings.day_seconds, 50.0), "missing file uses day default")
	_expect(is_equal_approx(AdminSettings.night_seconds, 60.0), "missing file uses night default")
	_expect(AdminSettings.hearts == 3, "missing file uses hearts default")
	_expect(is_equal_approx(AdminSettings.xp_scale, 1.0), "missing file uses xp default")
	_expect(AdminSettings.foliage_percent == 0, "missing file uses foliage default")
	_expect(is_equal_approx(AdminSettings.walk_speed, 70.0), "missing file uses walk default")
	_expect(is_equal_approx(AdminSettings.run_speed, 100.0), "missing file uses run default")
	_expect(Skills.xp_for_level(2) == 83, "level 2 stays 83 at 1.0x")
	_expect(Player.WALK_SPEED == 70.0, "walk const stays the baked default")
	_expect(Player.RUN_SPEED == 100.0, "run const stays the baked default")
	_expect(is_equal_approx(DayClock.cold_seconds(), 60.0), "cold night stays 60 at defaults")

	AdminSettings.day_seconds = 40.0
	AdminSettings.night_seconds = 45.0
	AdminSettings.hearts = 5
	AdminSettings.xp_scale = 1.5
	AdminSettings.foliage_percent = 25
	AdminSettings.walk_speed = 55.0
	AdminSettings.run_speed = 90.0
	_expect(AdminSettings.save_file(), "save writes the admin file")
	_expect(FileAccess.file_exists(AdminSettings.path), "admin json exists after save")
	AdminSettings.reset_to_defaults()
	_expect(is_equal_approx(AdminSettings.day_seconds, 50.0), "reset restores day in session")
	_expect(AdminSettings.hearts == 3, "reset restores hearts in session")
	AdminSettings.load_file()
	_expect(is_equal_approx(AdminSettings.day_seconds, 40.0), "load restores saved day")
	_expect(is_equal_approx(AdminSettings.night_seconds, 45.0), "load restores saved night")
	_expect(AdminSettings.hearts == 5, "load restores saved hearts")
	_expect(is_equal_approx(AdminSettings.xp_scale, 1.5), "load restores saved xp scale")
	_expect(AdminSettings.foliage_percent == 25, "load restores saved foliage")
	_expect(is_equal_approx(AdminSettings.walk_speed, 55.0), "load restores saved walk")
	_expect(is_equal_approx(AdminSettings.run_speed, 90.0), "load restores saved run")
	_expect(AdminSettings.absolute_path().contains("test_admin.json"), "absolute path helper points at the test file")

	AdminSettings.xp_scale = 2.0
	_expect(Skills.xp_for_level(2) == 166, "xp scale 2.0 doubles level 2")
	AdminSettings.xp_scale = 1.0
	_expect(Skills.xp_for_level(2) == 83, "xp scale 1.0 is 83 again")

	AdminSettings.foliage_percent = 0
	var base := _gen(11)
	var base_trees := _count_trees(base)
	AdminSettings.foliage_percent = AdminSettings.FOLIAGE_MAX
	var thick := _gen(11)
	var thick_trees := _count_trees(thick)
	_expect(thick_trees > base_trees, "foliage at the top plants more trees on the same seed")
	AdminSettings.foliage_percent = AdminSettings.FOLIAGE_MIN
	var thin := _gen(11)
	var thin_trees := _count_trees(thin)
	_expect(thin_trees < base_trees, "foliage at the bottom plants fewer trees on the same seed")
	AdminSettings.foliage_percent = 0

	AdminSettings.walk_speed = 40.0
	var walker := Player.new()
	_expect(is_equal_approx(walker.move_speed(), 40.0), "player walk speed reads AdminSettings")
	walker.free()
	AdminSettings.walk_speed = 70.0

	_wipe_admin()
	var menu := TitleMenu.new()
	root.add_child(menu)
	menu.assemble()
	var cog := menu.get_node_or_null("AdminCog") as TextureButton
	_expect(cog != null, "title has an admin cog")
	if cog != null:
		_expect(cog.position == Vector2(448, 2), "cog sits in the top right")
		_expect(cog.size == Vector2(28, 28), "cog is the same size as the floppy")
		cog.pressed.emit()
	_expect(menu.is_admin_open(), "cog opens the admin panel")
	_expect(menu.get_node_or_null("AdminPanel") != null, "admin panel is on the title")
	var panel := menu.get_node_or_null("AdminPanel") as AdminPanel
	var walk: HSlider = null
	if panel != null:
		walk = panel.get_node_or_null("Plate/Slider_walk_speed") as HSlider
	_expect(walk != null, "admin has a walk slider")
	if walk != null:
		walk.value = 42.0
		walk.value_changed.emit(42.0)
	_expect(is_equal_approx(AdminSettings.walk_speed, 42.0), "dragging walk writes the live setting")
	if panel != null:
		panel._on_save()
	_expect(FileAccess.file_exists(AdminSettings.path), "save writes the admin file")
	menu.close_admin()
	_expect(not menu.is_admin_open(), "close hides the panel")
	_expect(is_equal_approx(AdminSettings.walk_speed, 42.0), "close keeps the saved walk")
	if cog != null:
		cog.pressed.emit()
	_expect(menu.is_admin_open(), "cog opens the panel again")
	_expect(is_equal_approx(AdminSettings.walk_speed, 42.0), "reopen keeps the saved walk")
	if walk != null:
		_expect(is_equal_approx(walk.value, 42.0), "reopen shows the saved walk on the slider")
	AdminSettings.reset_to_defaults()
	AdminSettings.load_file()
	_expect(is_equal_approx(AdminSettings.walk_speed, 42.0), "saved walk survives a reload")
	var opening := menu.get_node("Menu/Buttons")
	_expect(opening.get_child_count() == 2, "admin is an overlay, not a third menu button")
	_expect((opening.get_child(0) as Button).text == "New Game", "New Game stays under the overlay")
	_expect((opening.get_child(1) as Button).text == "Continue", "Continue stays under the overlay")
	_send_key(menu, KEY_ESCAPE)
	_expect(not menu.is_admin_open(), "Escape closes admin")
	_expect(menu.screen == TitleMenu.Screen.CHOOSE, "Escape from admin stays on CHOOSE")
	_expect(menu.get_node("Menu/Buttons").get_child_count() == 2, "CHOOSE still has exactly two buttons")
	_expect(menu.get_node_or_null("AdminCog") != null, "cog is not a Menu/Buttons child")
	menu.free()
	_wipe_admin()


func _test_quit_to_menu() -> void:
	print("quit to the menu")
	_wipe_admin()
	_use_empty_saves()
	var world := _boot_run(0, {})
	current_scene = world
	_expect(not world.is_quit_ask(), "woods start without a quit ask")
	_send_key(world, KEY_ESCAPE)
	_expect(world.is_quit_ask(), "Escape in the woods opens the quit ask")
	var clock := _clock_of(world)
	_expect(clock != null and not clock.is_processing(), "the clock pauses while he decides")
	_expect(world.get_node_or_null("QuitAsk") != null, "the quit plate is on the world")
	world.press_quit_no()
	_expect(not world.is_quit_ask(), "No closes the ask")
	_expect(clock.is_processing(), "the clock runs again after No")
	_expect(current_scene == world, "No stays on the World scene")

	_send_key(world, KEY_ESCAPE)
	_send_key(world, KEY_N)
	_expect(not world.is_quit_ask(), "N closes the ask")
	_expect(current_scene == world, "N stays on the World scene")

	_send_key(world, KEY_ESCAPE)
	_send_key(world, KEY_ESCAPE)
	_expect(not world.is_quit_ask(), "Escape on the ask closes it")
	_expect(current_scene == world, "Escape on the ask stays in the woods")

	world.try_save()
	ShoreSave.unix_override = 9000
	_expect(world.submit_save_name("Kept shore"), "floppy writes a shore before quit")
	_expect(ShoreSave.has_slot(0), "the floppy'd slot is on disk")
	_send_key(world, KEY_ESCAPE)
	_expect(world.is_quit_ask(), "Escape opens the ask before Yes")
	_expect(world.get_parent() != null, "world is still parented before Yes")
	world.press_quit_yes()
	_expect(World.TITLE_SCENE == "res://title/title.tscn", "Yes leaves through the title scene")
	var title := _find_title_menu()
	_expect(title != null, "Yes returns to the title")
	if title != null:
		_expect(title.screen == TitleMenu.Screen.CHOOSE, "title opens on CHOOSE after quit")
		_expect(title.get_node("Menu/Buttons").get_child_count() == 2, "New Game and Continue are back")
		_expect((title.get_node("Menu/Buttons").get_child(0) as Button).text == "New Game", "New Game is on the title after quit")
		_expect((title.get_node("Menu/Buttons").get_child(1) as Button).text == "Continue", "Continue is on the title after quit")
		_expect(title.get_node_or_null("AdminCog") != null, "the cog is on the title after quit")
		_expect(ShoreSave.has_slot(0), "a floppy'd slot is still there after quit")
		title.free()

	_use_empty_saves()
	var fresh := _boot_run(1, {})
	current_scene = fresh
	_expect(not ShoreSave.has_slot(1), "an unsaved New Game has an empty box")
	_send_key(fresh, KEY_ESCAPE)
	_send_key(fresh, KEY_Y)
	title = _find_title_menu()
	_expect(title != null, "Y returns to the title")
	if title != null:
		_expect(not ShoreSave.has_slot(1), "an unsaved New Game still has an empty box after quit")
		_expect(title.get_node_or_null("AdminCog") != null, "cog is there after quitting an unsaved run")
		_expect(title.get_node("Menu/Buttons").get_child_count() == 2, "CHOOSE still has New Game and Continue")
		title.free()
	_wipe_admin()


func _find_title_menu() -> TitleMenu:
	if current_scene is TitleMenu:
		return current_scene as TitleMenu
	for child in root.get_children():
		if child is TitleMenu:
			current_scene = child
			return child as TitleMenu
	return null


func _test_shore_saves() -> void:
	print("shore saves")
	_use_empty_saves()
	var afternoon := int(Time.get_unix_time_from_datetime_dict({
		"year": 2026, "month": 10, "day": 28, "hour": 22, "minute": 57, "second": 0,
	}))
	_expect(ShoreSave.format_cst(afternoon) == "Oct 28, 4:57 PM CST", "a save time reads as Costa Rica CST")
	var midnight := int(Time.get_unix_time_from_datetime_dict({
		"year": 2026, "month": 10, "day": 29, "hour": 6, "minute": 0, "second": 0,
	}))
	_expect(ShoreSave.format_cst(midnight) == "Oct 29, 12:00 AM CST", "Costa Rica midnight is 12 AM")
	_test_chop_grows_back_from_the_seed()
	_test_continue_uses_the_saved_seed()
	_test_floppy_writes_the_walk()
	_test_continue_boxes_and_overwrite()
	_test_delete_save()


func _test_chop_grows_back_from_the_seed() -> void:
	var catalog := BiomeCatalog.new()
	catalog.load_all()
	var biome := catalog.get_biome(&"coastal_north")
	var chunk := MapChunk.new()
	chunk.setup(11, 0, 0, biome, true)
	var tree := _first_tree(chunk)
	_expect(tree != null, "the shore has a tree to chop")
	if tree == null:
		chunk.free()
		return
	var species := str(tree.get_meta("species"))
	var cell := chunk.cell_of_prop(tree)
	chunk.release_prop(tree)
	_expect(_tree_on(chunk, cell) == null, "the chop takes the tree down")
	var again := MapChunk.new()
	again.setup(11, 0, 0, biome, true)
	var back := _tree_on(again, cell)
	_expect(back != null, "the same seed grows that tree again")
	if back != null:
		_expect(str(back.get_meta("species")) == species, "it is the same kind of tree")
	chunk.free()
	again.free()


func _test_continue_uses_the_saved_seed() -> void:
	var world := World.new()
	world.prepare_run(0, {"seed": 21, "name": "Seed"})
	_expect(world.world_seed == 21, "continue picks the saved seed before the coast is built")
	world.begin_staged_boot()
	_expect(world.stage_boot_step() == false, "the first slice makes a chunk")
	var chunk: MapChunk = null
	for child in world.get_children():
		if child is MapChunk:
			chunk = child
			break
	_expect(chunk != null, "a slice has a chunk")
	if chunk == null:
		world.free()
		return
	var catalog := BiomeCatalog.new()
	catalog.load_all()
	var biome := catalog.get_biome(catalog.biome_id_at(chunk.chunk_x * ChunkGenerator.WIDTH, chunk.chunk_y * ChunkGenerator.HEIGHT))
	var gen := ChunkGenerator.new()
	var expected: PackedInt32Array = gen.generate(21, chunk.chunk_x, chunk.chunk_y, biome)["tiles"]
	var other: PackedInt32Array = gen.generate(11, chunk.chunk_x, chunk.chunk_y, biome)["tiles"]
	var tiles: PackedInt32Array = chunk.data["tiles"]
	var matches := true
	var differs := false
	for i in tiles.size():
		if tiles[i] != expected[i]:
			matches = false
		if tiles[i] != other[i]:
			differs = true
	_expect(matches, "the chunk is the saved seed")
	_expect(differs, "seed 11 would have been a different coast")
	world.free()


func _test_floppy_writes_the_walk() -> void:
	var world := _boot_run(0, {})
	var hud := _hud_of(world)
	var clock := _clock_of(world)
	_expect(hud != null and hud.get_node_or_null("SaveFloppy") != null, "the floppy is on the hud")
	if hud == null or clock == null:
		world.free()
		return
	if hud != null:
		var floppy := hud.get_node("SaveFloppy") as Control
		_expect(floppy.position.x >= 440.0 and floppy.position.y <= 8.0, "the floppy sits in the top right")
		_expect(floppy.size.x >= 24.0 and floppy.size.y >= 24.0, "the save mark has a corner-sized click")
		var floppy_click := Rect2(Vector2.ZERO, floppy.size)
		_expect(floppy_click.has_point(Vector2(1, 1)), "the corner of the save mark clicks")
		_expect(floppy_click.has_point(floppy.size * 0.5), "the center of the mark clicks")
		_expect(floppy.mouse_filter == Control.MOUSE_FILTER_STOP, "the save mark takes the click")
		var tex := (floppy as TextureButton).texture_normal
		_expect(tex != null and _is_floppy_mark(tex), "the save mark is a floppy disc")
		var skills_mark := hud.get_node_or_null("SkillsMark") as TextureButton
		_expect(skills_mark != null, "the skills mark is on the hud")
		if skills_mark != null:
			_expect(skills_mark.position.x < floppy.position.x, "the skills mark sits left of the floppy")
			_expect(skills_mark.size.x >= 24.0, "the skills mark has a corner-sized click")
			var shade := hud.get_node_or_null("SkillsMarkShadow") as Control
			_expect(shade != null, "the brown tile has a drop shadow")
			if shade != null:
				_expect((shade.position.x + shade.size.x) - (skills_mark.position.x + skills_mark.size.x) >= 3.0, "the shadow peeks right of the tile")
				_expect((shade.position.y + shade.size.y) - (skills_mark.position.y + skills_mark.size.y) >= 3.0, "the shadow peeks under the tile")
				_expect((skills_mark as TextureButton).stretch_mode == TextureButton.STRETCH_SCALE, "the tile stays inside the holder")
			world.skills.woodcutting_xp = 25
			world.skills.firemaking_xp = 40
			world.skills.forage_xp = 10
			world._refresh_hud()
			skills_mark.pressed.emit()
			var panel := hud.get_node_or_null("SkillsPanel") as Control
			_expect(panel != null and panel.visible, "the skills mark opens a panel")
			_expect(panel.position.y >= 30.0, "the panel sits under the marks")
			_expect(panel.position.x >= 370.0, "the panel stays in the right column")
			_expect(panel.size.x <= 100.0 and panel.size.y <= 64.0, "the panel is three small rows")
			_expect(panel.size.y >= 54.0, "the panel has room for foraging")
			_expect((hud._skill_level as Label).text == "1", "the panel shows woodcutting")
			_expect(hud.get_node_or_null("SkillsPanel/FiremakingLevel") != null, "fire-making has a row")
			_expect((hud._fire_level as Label).text == "1", "the panel shows fire-making")
			_expect(hud.get_node_or_null("SkillsPanel/ForagingLevel") != null, "foraging has a row")
			_expect((hud._forage_level as Label).text == "1", "the panel shows foraging")
			_expect(hud._hover_tip == "25/83|40/83|10/83", "hover keeps three skill steps")
			_expect(str(panel.tooltip_text) == "", "the native tooltip stays off")
			var hover := hud.get_node_or_null("SkillHover") as Label
			_expect(hover != null and hover.text == "25/83", "the hover chip has the woodcutting step")
			if hover != null:
				_expect(hover.get_theme_font_size("font_size") == 8, "the hover chip is small")
				hud.place_skill_hover(Vector2(450, 40))
				_expect(hover.visible, "the chip shows")
				_expect(hover.position.y >= 48.0, "the chip sits under the pointer")
				_expect(hover.position.x >= 420.0, "a right hover stays on the right")
				var right_x := hover.position.x
				hud.place_skill_hover(Vector2(400, 40))
				_expect(hover.position.x < right_x, "the chip follows the pointer across the row")
			skills_mark.pressed.emit()
			_expect(not panel.visible, "the skills mark closes the panel")
			world.skills.woodcutting_xp = 0
			world.skills.firemaking_xp = 0
			world.skills.forage_xp = 0
		floppy.pressed.emit()
		_expect(world.is_naming(), "clicking the floppy asks for a name")
		world.cancel_save_name()
	_expect(not ShoreSave.has_slot(0), "a new shore has no file yet")
	world.try_save()
	_expect(world.is_naming(), "the first floppy asks for a name")
	_expect(clock != null and not clock.is_processing(), "the night waits while he types")
	var name_box := hud.get_node_or_null("SaveName") as Control
	_expect(name_box != null and name_box.visible, "the name box is open")
	if name_box != null:
		var field := name_box.get_node_or_null("SaveNameField") as Control
		var confirm := name_box.get_node_or_null("SaveNameConfirm") as Control
		var plate := name_box.get_node_or_null("SaveNamePlate") as Control
		_expect(field != null and confirm != null and plate != null, "the name box has field, Save, and plate")
		if field != null and confirm != null and plate != null:
			var field_rect := Rect2(field.position, field.size)
			var save_rect := Rect2(confirm.position, confirm.size)
			_expect(not field_rect.intersects(save_rect), "field and Save do not overlap")
			_expect(confirm.position.y >= field.position.y + field.size.y, "Save sits below the field")
			var plate_rect := Rect2(plate.position, plate.size)
			_expect(plate_rect.encloses(field_rect), "the field sits inside the green plate")
			_expect(plate_rect.encloses(save_rect), "Save sits inside the green plate")
			var save_btn := confirm as Button
			var normal := save_btn.get_theme_stylebox("normal") as StyleBoxFlat
			_expect(normal != null and normal.bg_color.a > 0.5, "Save is opaque")
	_expect(not world.submit_save_name("   "), "a blank name does not write")
	_expect(world.is_naming() and not ShoreSave.has_slot(0), "the name box stays open")
	var escape := InputEventKey.new()
	escape.pressed = true
	escape.keycode = KEY_ESCAPE
	hud._input(escape)
	_expect(not world.is_naming(), "escape closes the name")
	_expect(clock.is_processing(), "the night moves again")
	world.try_save()
	ShoreSave.unix_override = 1000
	_expect(world.submit_save_name("North trail"), "the first save keeps the name")
	_expect(not world.is_naming(), "the name box closes")
	var first := ShoreSave.read_slot(0)
	_expect(str(first["name"]) == "North trail", "the file has the name")
	_expect(int(first["saved_unix"]) == 1000, "the file has the first time")
	world.apply_walk({
		"name": "North trail",
		"seed": world.world_seed,
		"x": 200.0,
		"y": 120.0,
		"facing": "north",
		"wood": 1.5,
		"forage": 4,
		"hearts": 2.0,
		"hearts_max": 3.0,
		"cold_acc": 1.25,
		"heal_acc": 0.5,
		"woodcutting_xp": 83,
		"firemaking_xp": 40,
		"forage_xp": 90,
		"elapsed": 55.0,
		"fog": [[3, 4], [3, 5]],
	})
	ShoreSave.unix_override = 2000
	world.try_save()
	_expect(not world.is_naming(), "a later floppy does not ask again")
	var saved := ShoreSave.read_slot(0)
	_expect(str(saved["name"]) == "North trail", "the second save keeps the name")
	_expect(int(saved["saved_unix"]) == 2000, "the second save moves the time")
	_expect(is_equal_approx(float(saved["wood"]), 1.5), "wood is in the file")
	_expect(int(saved["forage"]) == 4, "forage is in the file")
	_expect(is_equal_approx(float(saved["hearts"]), 2.0), "hearts are in the file")
	_expect(is_equal_approx(float(saved["cold_acc"]), 1.25), "a partial cold count is in the file")
	_expect(str(saved["facing"]) == "north", "facing is in the file")
	_expect(is_equal_approx(float(saved["x"]), 200.0), "where he stands is in the file")
	_expect(is_equal_approx(float(saved["elapsed"]), 55.0), "the time of day is in the file")
	_expect(int(saved["woodcutting_xp"]) == 83, "woodcutting is in the file")
	_expect(int(saved["firemaking_xp"]) == 40, "fire-making is in the file")
	_expect(int(saved["forage_xp"]) == 90, "foraging is in the file")
	_expect(world.skills.level() == 2, "the file restores woodcutting")
	_expect(world.skills.firemaking_level() == 1, "the file restores fire-making")
	_expect(world.skills.forage_level() == 2, "the file restores foraging")
	_expect(clock.phase() == "night", "dusk and night come back with the file")
	_expect(not saved.has("harvested"), "the file does not list chopped trees")
	var saw_fog := false
	for cell in saved["fog"]:
		if int(cell[0]) == 3 and int(cell[1]) == 4:
			saw_fog = true
	_expect(saw_fog, "the map he uncovered is in the file")
	_expect(hud.lines().find("Saved.") >= 0, "the woods say Saved")
	var spot := _open_fire_cell(world)
	_expect(spot.x >= 0, "open ground for a fire")
	_expect(world.place_saved_fire(spot, 22.5), "a fire is lit with time left")
	ShoreSave.unix_override = 2001
	world.try_save()
	var with_fire := ShoreSave.read_slot(0)
	var saw_fire := false
	for item in with_fire["fires"]:
		if int(item[0]) == spot.x and int(item[1]) == spot.y and is_equal_approx(float(item[2]), 22.5):
			saw_fire = true
	_expect(saw_fire, "the lit fire is frozen in the file")
	world.apply_walk({"fires": []})
	_expect(_campfire_at(world, spot) == null, "a save with no fire leaves the ground cold")
	world.apply_walk(with_fire)
	var back := _campfire_at(world, spot)
	_expect(back != null and is_equal_approx(back.burn_left, 22.5), "the fire comes back with the time it had left")
	world.apply_walk({
		"name": "North trail",
		"seed": world.world_seed,
		"x": 200.0,
		"y": 120.0,
	})
	_expect(world.skills.woodcutting_xp == 0, "an old file with no skill key is level 1")
	_expect(world.skills.firemaking_xp == 0, "an old file with no fire-making key is level 1")
	_expect(world.skills.forage_xp == 0, "an old file with no foraging key is level 1")
	world.skills.woodcutting_xp = 174
	world.skills.firemaking_xp = 120
	world.skills.forage_xp = 90
	var kept := world.skills.woodcutting_xp
	var kept_fire := world.skills.firemaking_xp
	var kept_forage := world.skills.forage_xp
	world.rebuild()
	_expect(world.skills.woodcutting_xp == kept, "a new seed keeps woodcutting")
	_expect(world.skills.firemaking_xp == kept_fire, "a new seed keeps fire-making")
	_expect(world.skills.forage_xp == kept_forage, "a new seed keeps foraging")
	world.free()


func _test_continue_boxes_and_overwrite() -> void:
	_use_empty_saves()
	ShoreSave.write_slot(0, _named_save("First shore", 11, 3000))
	var menu := TitleMenu.new()
	root.add_child(menu)
	menu.assemble()
	menu.press_new_game()
	_expect(menu.departing_slot() == 1, "new game skips a box that already has a file")
	_expect(not ShoreSave.has_slot(1), "the new box is still empty")
	_expect(str(ShoreSave.read_slot(0)["name"]) == "First shore", "the first file is untouched")
	menu.free()
	_use_empty_saves()
	for i in 3:
		ShoreSave.write_slot(i, _named_save("Shore %d" % (i + 1), 11 + i, 4000 + i))
	_expect(ShoreSave.label(0) == "Shore 1\n" + ShoreSave.format_cst(4000), "continue shows the name and the time")
	menu = TitleMenu.new()
	root.add_child(menu)
	menu.assemble()
	menu.press_continue()
	_expect(menu.can_load_slot(2), "a filled box can load")
	menu.press_slot(2)
	_expect(menu.is_departing(), "continue leaves the way new game does")
	_expect(menu.departing_slot() == 2, "continue opens that box")
	_expect(menu.booting_world().world_seed == 13, "continue carries that shore's seed")
	menu.free()
	menu = TitleMenu.new()
	root.add_child(menu)
	menu.assemble()
	menu.press_new_game()
	_expect(menu.screen == TitleMenu.Screen.OVERWRITE_ASK, "a full set asks before it overwrites")
	_expect(not menu.is_departing(), "the ask does not leave yet")
	menu.press_overwrite_no()
	_expect(menu.screen == TitleMenu.Screen.CHOOSE, "no returns to new game and continue")
	menu.press_new_game()
	menu.press_overwrite_yes()
	_expect(menu.screen == TitleMenu.Screen.OVERWRITE_PICK, "yes asks which box")
	var before := ShoreSave.read_slot(1)
	menu.press_overwrite_slot(1)
	_expect(menu.departing_slot() == 1, "the picked box is the one this run will write")
	var after := ShoreSave.read_slot(1)
	_expect(str(after["name"]) == str(before["name"]), "the old file stays until the floppy")
	_expect(int(after["saved_unix"]) == int(before["saved_unix"]), "the old time stays until the floppy")
	menu.free()


func _test_delete_save() -> void:
	_use_empty_saves()
	ShoreSave.write_slot(0, _named_save("Kept", 11, 5000))
	ShoreSave.write_slot(1, _named_save("Gone", 12, 5001))
	var menu := TitleMenu.new()
	root.add_child(menu)
	menu.assemble()
	menu.press_continue()
	var column := menu.get_node("Menu/Buttons")
	_expect(column.get_child(0).get_node_or_null("Delete") != null, "a filled save has an x")
	_expect(column.get_child(2).get_node_or_null("Delete") == null, "an empty box has no x")
	menu.press_delete(2)
	_expect(menu.screen == TitleMenu.Screen.SLOTS, "an empty box cannot be deleted")
	menu.press_delete(1)
	_expect(menu.screen == TitleMenu.Screen.DELETE_ASK, "the x asks before it deletes")
	_expect(ShoreSave.has_slot(1), "the file is still there while he decides")
	menu.press_delete_no()
	_expect(menu.screen == TitleMenu.Screen.SLOTS, "no leaves the save")
	_expect(str(ShoreSave.read_slot(1)["name"]) == "Gone", "no does not delete")
	menu.press_delete(1)
	menu.press_back()
	_expect(ShoreSave.has_slot(1), "escape does not delete")
	menu.press_delete(1)
	menu.press_delete_yes()
	_expect(menu.screen == TitleMenu.Screen.SLOTS, "yes returns to the boxes")
	_expect(not ShoreSave.has_slot(1), "yes deletes that save")
	_expect(menu.slot_label(1) == "No save file", "the box is empty again")
	_expect(str(ShoreSave.read_slot(0)["name"]) == "Kept", "the other save stays")
	menu.free()


func _named_save(save_name: String, world_seed: int, unix_time: int) -> Dictionary:
	return {
		"version": 1,
		"name": save_name,
		"saved_unix": unix_time,
		"seed": world_seed,
	}


func _is_floppy_mark(tex: Texture2D) -> bool:
	var img := tex.get_image()
	if img == null or img.get_width() != 16 or img.get_height() != 16:
		return false
	var center := img.get_pixel(8, 8)
	if center.a <= 0.5:
		return false
	var opaque := 0
	for y in 16:
		for x in 16:
			if img.get_pixel(x, y).a > 0.5:
				opaque += 1
	if opaque <= 80:
		return false
	# Old pause bars were two ink runs on row y=7. A filled disc must not match that.
	var runs := 0
	var in_bar := false
	for x in 16:
		var ink := img.get_pixel(x, 7).a > 0.5
		if ink and not in_bar:
			runs += 1
			in_bar = true
		elif not ink:
			in_bar = false
	if runs == 2:
		return false
	return true


## Stand on the tile south of target and face it, so F aims at that world cell.
func _stand_facing_cell(world: World, target: Vector2i, facing: String) -> void:
	var stand := target + Vector2i(0, 1)
	if facing == "south":
		stand = target + Vector2i(0, -1)
	elif facing == "east":
		stand = target + Vector2i(-1, 0)
	elif facing == "west":
		stand = target + Vector2i(1, 0)
	var host := world._chunk_at(ChunkGenerator.chunk_of_cell(stand))
	_expect(host != null, "the stand tile has a chunk")
	if host == null or world._player == null:
		return
	if world._player.get_parent() != null:
		world._player.get_parent().remove_child(world._player)
	host.add_child(world._player)
	world._chunk = host
	var tile := float(ChunkGenerator.TILE)
	world._player.global_position = Vector2((float(stand.x) + 0.5) * tile, (float(stand.y) + 0.5) * tile)
	world._player.set_facing(facing)
	_expect(Interact.tile_ahead(world._player.global_position, facing) == target, "F aims at the open cell")


func _open_fire_cell(world: World) -> Vector2i:
	for child in world.get_children():
		if not child is MapChunk:
			continue
		var chunk := child as MapChunk
		if chunk.chunk_y != 0:
			continue
		for ty in range(8, 20):
			for tx in range(8, 40):
				var local := Vector2i(tx, ty)
				if world.generator.is_blocked(chunk.tile_kind(local)):
					continue
				if chunk.cell_occupied(local):
					continue
				return Vector2i(
					chunk.chunk_x * ChunkGenerator.WIDTH + tx,
					chunk.chunk_y * ChunkGenerator.HEIGHT + ty
				)
	return Vector2i(-1, -1)


func _campfire_at(world: World, cell: Vector2i) -> Campfire:
	for child in world.get_children():
		if not child is MapChunk:
			continue
		var chunk := child as MapChunk
		for node in chunk.get_children():
			if not node is Campfire:
				continue
			var local := chunk.cell_of_prop(node)
			var here := Vector2i(
				chunk.chunk_x * ChunkGenerator.WIDTH + local.x,
				chunk.chunk_y * ChunkGenerator.HEIGHT + local.y
			)
			if here == cell:
				return node as Campfire
	return null


func _test_caribou_on_the_trail() -> void:
	print("caribou on the trail")
	var gen := ChunkGenerator.new()
	var path := gen.caribou_trail_cells(11, World.STRIP_NORTH)
	_expect(not path.is_empty(), "the trail has a walk")
	if path.is_empty():
		return
	var wide := 0
	var last_y := path[0].y + 1
	var step_ok := true
	for i in path.size():
		if i > 0:
			var a := path[i - 1]
			var b := path[i]
			if maxi(absi(a.x - b.x), absi(a.y - b.y)) != 1:
				step_ok = false
		if path[i].y == last_y:
			wide += 1
		last_y = path[i].y
	_expect(step_ok, "the walk steps one tile at a time")
	_expect(wide == 0, "the walk is one tile wide")
	var trail_hits := 0
	var trail_miss := 0
	for cy in range(World.STRIP_NORTH, World.STRIP_SOUTH + 1):
		var data := gen.generate(11, 0, cy, _coast())
		var tiles: PackedInt32Array = data["tiles"]
		for ty in ChunkGenerator.HEIGHT:
			for tx in ChunkGenerator.WIDTH:
				if tiles[ty * ChunkGenerator.WIDTH + tx] != ChunkGenerator.TILE_TRAIL:
					continue
				var cell := Vector2i(tx, cy * ChunkGenerator.HEIGHT + ty)
				if path.has(cell):
					trail_hits += 1
				else:
					trail_miss += 1
	_expect(trail_hits > 0, "painted trail tiles sit on the walk")
	_expect(trail_miss == 0, "every painted trail tile is on the walk")
	var spawn_i := gen.caribou_seed_index(path)
	var spawn_cell := path[spawn_i]
	_expect(path.has(spawn_cell), "seed spawn is on the walk")
	_expect(spawn_cell.y < ChunkGenerator.HEIGHT - ChunkGenerator.WATER_ROWS - ChunkGenerator.SHORE_ROWS - 8, "seed spawn is inland of the beach")
	var tile := float(ChunkGenerator.TILE)
	var self_px := Vector2(8, 8)
	var south := self_px + Vector2(0, 3.5 * tile)
	var north := self_px + Vector2(0, -3.5 * tile)
	var toward := Vector2(0, -1)
	_expect(Caribou.should_spook(self_px, south, toward, true), "jog toward at 4 tiles spooks")
	_expect(not Caribou.should_spook(self_px, south + Vector2(0, tile), toward, true), "jog toward at 5 tiles does not")
	var walk_close := self_px + Vector2(0, 1.5 * tile)
	_expect(Caribou.should_spook(self_px, walk_close, toward, false), "walk toward at 2 tiles spooks")
	_expect(not Caribou.should_spook(self_px, south, toward, false), "walk toward at 4 tiles does not")
	_expect(not Caribou.should_spook(self_px, walk_close, Vector2.ZERO, false), "standing still inside 2 tiles does not spook")
	var away := Caribou.pick_away(self_px, south, [north, south])
	_expect(away == north, "flee picks the cell farther from Leif")
	var trapped := Caribou.pick_away(self_px, north, [south])
	_expect(trapped == south, "toward-Leif only when that is the open step")
	_expect(Caribou.FLEE_SPEED > Player.RUN_SPEED, "it runs faster than Leif")
	var walker := Caribou.new()
	var short: Array[Vector2i] = [Vector2i(10, 10), Vector2i(10, 9), Vector2i(10, 8), Vector2i(10, 7)]
	walker.setup(short, 1)
	var start := walker.position
	walker.tick_with(0.4, Vector2(1000, 1000), Vector2.ZERO, false)
	_expect(walker.position != start, "walking advances along the path")
	_expect(not walker.is_fleeing(), "a far stand does not spook")
	var graze_at := walker.position
	walker.hold_graze(2.0)
	walker.tick_with(0.4, Vector2(1000, 1000), Vector2.ZERO, false)
	_expect(walker.is_grazing(), "graze holds still")
	_expect(walker.position == graze_at, "graze does not move")
	var before_flee := walker.position
	var leif_south := before_flee + Vector2(0, 3.0 * tile)
	walker.tick_with(0.05, leif_south, toward, true)
	_expect(walker.is_fleeing(), "jog toward in range starts a flee")
	for _i in 20:
		walker.tick_with(0.05, leif_south, toward, true)
	_expect(walker.position.distance_to(leif_south) > before_flee.distance_to(leif_south), "flee increases distance")
	_expect(is_instance_valid(walker), "the node is still there after a run")
	for _j in 40:
		walker.tick_with(0.1, walker.position + Vector2(0, 8), toward, true)
	_expect(is_instance_valid(walker), "the north edge does not free the node")
	walker.free()
	var dummy := Node2D.new()
	dummy.set_meta("kind", "caribou")
	dummy.set_meta("species", "caribou")
	var interact := Interact.new()
	interact.supplies = Supplies.new()
	interact.biome = _coast()
	var wood := interact.supplies.wood
	var forage := interact.supplies.forage
	_expect(interact.use_on(dummy) == "", "Space on a caribou does nothing")
	_expect(is_equal_approx(interact.supplies.wood, wood), "wood stays")
	_expect(interact.supplies.forage == forage, "forage stays")
	dummy.free()
	interact.free()
	var world := _boot_run(0, {})
	var elk := world.caribou()
	_expect(elk != null, "the woods have a caribou")
	if elk == null:
		world.free()
		return
	var seed_cell := ChunkGenerator.world_cell_at(elk.global_position)
	_expect(path.has(seed_cell) or gen.caribou_trail_cells(world.world_seed, World.STRIP_NORTH).has(seed_cell), "it stands on the walk")
	_expect(seed_cell.y < 0, "New Game puts it inland")
	var kept := elk.global_position + Vector2(0, -32)
	elk.global_position = kept
	elk.set_facing("west")
	elk.travel_dir = -1
	var shot := world.capture_walk()
	_expect(is_equal_approx(float(shot["caribou_x"]), kept.x), "save keeps the caribou")
	elk.global_position = kept + Vector2(48, 0)
	world.apply_walk(shot)
	_expect(is_equal_approx(world.caribou().global_position.x, kept.x), "continue puts it back")
	_expect(world.caribou().facing_name() == "west", "continue keeps facing")
	_expect(world.caribou().travel_dir == -1, "continue keeps travel")
	var old_file := world.capture_walk()
	old_file.erase("caribou_x")
	old_file.erase("caribou_y")
	world.rebuild()
	world.apply_walk(old_file)
	_expect(world.caribou() != null, "an old file still spawns a caribou")
	if world.caribou() != null:
		_expect(ChunkGenerator.world_cell_at(world.caribou().global_position).y < 0, "the old file seed-spawns inland")
	world.free()


func _test_arctic_hare_on_the_moss() -> void:
	print("arctic hare on the moss")
	var gen := ChunkGenerator.new()
	var trail := gen.caribou_trail_cells(11, World.STRIP_NORTH)
	var cells := gen.hare_seed_cells(11, World.STRIP_NORTH)
	_expect(cells.size() == 3, "seed places three hares")
	var trail_hit := 0
	var inland_ok := true
	var moss_ok := true
	for i in cells.size():
		var cell: Vector2i = cells[i]
		if trail.has(cell):
			trail_hit += 1
		if cell.y >= 0:
			inland_ok = false
		var kind := gen.peek_ground(11, cell.x, cell.y)
		if kind != ChunkGenerator.TILE_MOSS and kind != ChunkGenerator.TILE_PEAT:
			moss_ok = false
		for j in range(i + 1, cells.size()):
			_expect(Vector2(cell).distance_to(Vector2(cells[j])) >= 12.0, "hares are at least 12 tiles apart")
	_expect(trail_hit == 0, "seed cells are off the caribou trail")
	_expect(inland_ok, "seed cells are inland")
	_expect(moss_ok, "seed cells are moss or peat")
	for cell in cells:
		var near := false
		for t in trail:
			if Vector2(cell).distance_to(Vector2(t)) <= 6.5:
				near = true
				break
		_expect(near, "seed cells sit beside the caribou trail")
	var tile := float(ChunkGenerator.TILE)
	var self_px := Vector2(8, 8)
	var south := self_px + Vector2(0, 3.5 * tile)
	var north := self_px + Vector2(0, -3.5 * tile)
	var toward := Vector2(0, -1)
	_expect(Hare.should_spook(self_px, south, toward, true), "jog toward at 4 tiles spooks")
	_expect(not Hare.should_spook(self_px, south + Vector2(0, tile), toward, true), "jog toward at 5 tiles does not")
	var walk_close := self_px + Vector2(0, 1.5 * tile)
	_expect(Hare.should_spook(self_px, walk_close, toward, false), "walk toward at 2 tiles spooks")
	_expect(not Hare.should_spook(self_px, south, toward, false), "walk toward at 4 tiles does not")
	_expect(not Hare.should_spook(self_px, walk_close, Vector2.ZERO, false), "standing still inside 2 tiles does not spook")
	var away := Hare.pick_away(self_px, south, [north, south])
	_expect(away == north, "flee picks the cell farther from Leif")
	_expect(Hare.FLEE_SPEED > Player.RUN_SPEED, "it runs faster than Leif")
	var hopper := Hare.new()
	hopper.setup_at(Vector2i(10, -10))
	hopper.hold_sit(0.1)
	var start := hopper.position
	hopper.tick_with(0.2, Vector2(1000, 1000), Vector2.ZERO, false)
	_expect(not hopper.is_sitting() or hopper.position == start, "sit holds still while it lasts")
	hopper.hold_sit(0.0)
	hopper.tick_with(0.2, Vector2(1000, 1000), Vector2.ZERO, false)
	_expect(hopper.position != start or hopper.is_sitting(), "a hop or sit follows an ended sit")
	var before_flee := hopper.position
	var leif_south := before_flee + Vector2(0, 3.0 * tile)
	hopper.tick_with(0.05, leif_south, toward, true)
	_expect(hopper.is_fleeing(), "jog toward in range starts a flee")
	for _i in 20:
		hopper.tick_with(0.05, leif_south, toward, true)
	_expect(hopper.position.distance_to(leif_south) > before_flee.distance_to(leif_south), "flee increases distance")
	_expect(is_instance_valid(hopper), "the node is still there after a run")
	for _j in 40:
		hopper.tick_with(0.1, hopper.position + Vector2(0, 8), toward, true)
	_expect(is_instance_valid(hopper), "a long flee does not free the node")
	hopper.free()
	var dummy := Node2D.new()
	dummy.set_meta("kind", "hare")
	dummy.set_meta("species", "arctic_hare")
	var interact := Interact.new()
	interact.supplies = Supplies.new()
	interact.biome = _coast()
	var wood := interact.supplies.wood
	var forage := interact.supplies.forage
	_expect(interact.use_on(dummy) == "", "Space on a hare does nothing")
	_expect(is_equal_approx(interact.supplies.wood, wood), "wood stays")
	_expect(interact.supplies.forage == forage, "forage stays")
	dummy.free()
	interact.free()
	var world := _boot_run(0, {})
	var pack := world.hares()
	_expect(pack.size() == 3, "the woods have three hares")
	if pack.size() != 3:
		world.free()
		return
	var world_trail := world.generator.caribou_trail_cells(world.world_seed, World.STRIP_NORTH)
	for hare in pack:
		_expect(hare != null and is_instance_valid(hare), "each hare is alive")
		var cell := ChunkGenerator.world_cell_at(hare.global_position)
		_expect(cell.y < 0, "New Game puts a hare inland")
		_expect(not world.is_trail_cell(cell), "New Game keeps a hare off the trail")
		var near := false
		for t in world_trail:
			if Vector2(cell).distance_to(Vector2(t)) <= 8.0:
				near = true
				break
		_expect(near, "New Game puts a hare beside the trail")
	var kept: Array[Vector2] = []
	var facings: Array[String] = []
	for i in pack.size():
		var shifted := pack[i].global_position + Vector2(float(i) * 16.0, -24.0)
		pack[i].global_position = shifted
		pack[i].set_facing("west" if i % 2 == 0 else "east")
		kept.append(shifted)
		facings.append(pack[i].facing_name())
	var shot := world.capture_walk()
	_expect(shot.has("hares") and shot["hares"] is Array, "save keeps a hares list")
	var rows: Array = shot["hares"]
	_expect(rows.size() == 3, "save keeps three hares")
	for i in kept.size():
		pack[i].global_position = kept[i] + Vector2(48, 0)
	world.apply_walk(shot)
	var restored := world.hares()
	_expect(restored.size() == 3, "continue puts three hares back")
	for i in mini(restored.size(), kept.size()):
		_expect(is_equal_approx(restored[i].global_position.x, kept[i].x), "continue keeps hare %d place" % i)
		_expect(restored[i].facing_name() == facings[i], "continue keeps hare %d facing" % i)
	var old_file := world.capture_walk()
	old_file.erase("hares")
	world.rebuild()
	world.apply_walk(old_file)
	var seeded := world.hares()
	_expect(seeded.size() == 3, "an old file still spawns three hares")
	for hare in seeded:
		if hare == null or not is_instance_valid(hare):
			continue
		_expect(ChunkGenerator.world_cell_at(hare.global_position).y < 0, "the old file seed-spawns inland")
	world.free()


func _test_death_and_respawn() -> void:
	print("death and respawn")
	_use_empty_saves()
	var world := _boot_run(0, {})
	var hud := _hud_of(world)
	var clock := _clock_of(world)
	var leif := world.leif()
	_expect(hud != null and clock != null and leif != null, "the woods are up for death")
	if hud == null or clock == null or leif == null:
		world.free()
		return
	var landing := leif.global_position
	# Sleep fade stays unmarked.
	world._dying = false
	world._sleep_phase = "out"
	world._sleep_t = World.SLEEP_OUT * 0.5
	world._tick_sleep(0.0)
	_expect(is_equal_approx(hud.death_mark_alpha(), 0.0), "sleep fade does not show the skull")
	world._sleep_phase = ""
	world._sleep_t = 0.0
	hud.set_fade(0.0)
	hud.set_death_mark(0.0)
	# Mark a camp inland, then walk away with a full pack.
	var camp := landing + Vector2(0, -96)
	leif.global_position = camp
	world._has_sleep_mark = true
	world._sleep_mark = camp
	leif.global_position = camp + Vector2(80, 0)
	var away := leif.global_position
	world.supplies.wood = 7.0
	world.supplies.forage = 5
	world.supplies.hearts = 0.5
	world.skills.woodcutting_xp = 100
	world.skills.firemaking_xp = 80
	world.skills.forage_xp = 40
	world._fog.reveal(Vector2i(3, -2))
	var fog_before := world._fog.revealed.size()
	clock.elapsed = DayClock.DAY_SECONDS + 5.0
	DayClock.darkness_now = clock.darkness()
	world._begin_death()
	_expect(world.is_dying(), "death starts the fade")
	_expect(world.is_sleeping(), "death uses the sleep blink")
	# Fade out: skull rises with the black.
	world._sleep_t = World.SLEEP_OUT * 0.5
	world._tick_sleep(0.0)
	_expect(hud.death_mark_alpha() > 0.4, "the skull fades in on death")
	# Finish out: tax, dawn, wake at the camp.
	world._sleep_t = World.SLEEP_OUT
	world._tick_sleep(0.0)
	_expect(clock.phase() == "dawn", "death wakes at dawn")
	_expect(is_equal_approx(world.supplies.wood, 3.5), "half the wood is gone")
	_expect(world.supplies.forage == 2, "half the berries are gone")
	_expect(is_equal_approx(world.supplies.hearts, 1.0), "he wakes with one heart")
	_expect(is_equal_approx(leif.global_position.x, camp.x), "he wakes at the last sleep")
	_expect(is_equal_approx(leif.global_position.y, camp.y), "the camp tile is the wake place")
	_expect(not is_equal_approx(leif.global_position.x, away.x), "he left the cold spot")
	_expect(world.skills.woodcutting_xp == 100, "woodcutting stays")
	_expect(world.skills.firemaking_xp == 80, "fire-making stays")
	_expect(world.skills.forage_xp == 40, "foraging stays")
	_expect(world._fog.revealed.size() == fog_before, "the map stays")
	_expect(hud.lines().contains("Half the pack is gone"), "the death hint is up")
	_expect(world._sleep_phase == "hold", "death holds the black")
	_expect(is_equal_approx(hud.death_mark_alpha(), 1.0), "the skull is full on the hold")
	# Hold ends; skull fades with the wake.
	world._sleep_t = World.DEATH_HOLD
	world._tick_sleep(0.0)
	_expect(world._sleep_phase == "in", "death fades back in")
	world._sleep_t = World.SLEEP_IN
	world._tick_sleep(0.0)
	_expect(not world.is_dying(), "death is over")
	_expect(is_equal_approx(hud.death_mark_alpha(), 0.0), "the skull is gone after wake")
	# Capture keeps the sleep mark; R clears it.
	var shot := world.capture_walk()
	_expect(shot.has("sleep_x") and shot.has("sleep_y"), "the floppy stores the sleep mark")
	world.rebuild()
	_expect(not world.has_sleep_mark(), "R clears the sleep mark")
	var land_again := world.leif().global_position
	# Old file without sleep keys: landing wake.
	var old := shot.duplicate(true)
	old.erase("sleep_x")
	old.erase("sleep_y")
	world.apply_walk(old)
	_expect(not world.has_sleep_mark(), "an old file has no sleep mark")
	# Put him inland, die, wake on landing (no sleep mark on this shore).
	world.leif().global_position = land_again + Vector2(0, -128)
	world.supplies.wood = 4.0
	world.supplies.forage = 3
	world.supplies.hearts = 0.5
	clock.elapsed = DayClock.DAY_SECONDS + 5.0
	world._begin_death()
	world._sleep_t = World.SLEEP_OUT
	world._tick_sleep(0.0)
	_expect(is_equal_approx(world.leif().global_position.x, land_again.x), "never slept wakes on the landing")
	_expect(is_equal_approx(world.leif().global_position.y, land_again.y), "landing is the New Game spawn")
	_expect(is_equal_approx(world.supplies.wood, 2.0), "half of four wood is two")
	_expect(world.supplies.forage == 1, "half of three berries is one")
	world._sleep_phase = ""
	world._dying = false
	hud.set_fade(0.0)
	hud.set_death_mark(0.0)
	# Named shore writes after death.
	world._save_name = "Cold"
	world.supplies.wood = 8.0
	world.supplies.forage = 9
	world.supplies.hearts = 0.5
	world._has_sleep_mark = true
	world._sleep_mark = camp
	world.leif().global_position = camp + Vector2(16, 0)
	clock.elapsed = DayClock.DAY_SECONDS + 5.0
	world._begin_death()
	world._sleep_t = World.SLEEP_OUT
	world._tick_sleep(0.0)
	var saved := ShoreSave.read_slot(0)
	_expect(not saved.is_empty(), "a named shore writes after death")
	if not saved.is_empty():
		_expect(is_equal_approx(float(saved.get("wood", -1)), 4.0), "the file has half the wood")
		_expect(int(saved.get("forage", -1)) == 4, "the file has half the berries")
		_expect(is_equal_approx(float(saved.get("hearts", -1)), 1.0), "the file has one heart")
		_expect(is_equal_approx(float(saved.get("sleep_x", -1)), camp.x), "the file keeps the sleep mark")
	world.free()


func _boot_run(slot: int, snapshot: Dictionary) -> World:
	var world := World.new()
	world.prepare_run(slot, snapshot)
	world.begin_staged_boot()
	var guard := 0
	while not world.stage_boot_step():
		guard += 1
		if guard > 5000:
			_expect(false, "the coast finished building")
			break
	root.add_child(world)
	world.open_play()
	return world


func _hud_of(world: World) -> GameHud:
	for child in world.get_children():
		if child is GameHud:
			return child
	return null


func _clock_of(world: World) -> DayClock:
	for child in world.get_children():
		if child is DayClock:
			return child
	return null


func _first_tree(chunk: MapChunk) -> Node2D:
	for child in chunk.get_children():
		if not child is Node2D:
			continue
		var node := child as Node2D
		if str(node.get_meta("kind", "")) == "tree":
			return node
	return null


func _tree_on(chunk: MapChunk, cell: Vector2i) -> Node2D:
	for child in chunk.get_children():
		if not child is Node2D:
			continue
		var node := child as Node2D
		if str(node.get_meta("kind", "")) != "tree":
			continue
		if chunk.cell_of_prop(node) == cell:
			return node
	return null


func _click_title(menu: TitleMenu, text: String) -> void:
	var column := menu.get_node("Menu/Buttons")
	for child in column.get_children():
		var button := child as Button
		if button != null and button.text == text:
			button.pressed.emit()
			return
	_expect(false, "no title button %s" % text)
