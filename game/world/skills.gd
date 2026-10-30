class_name Skills
extends RefCounted

## Woodcutting, fire-making, and foraging on this biome.
## Levels 1–30 keep Old School RuneScape’s table. After 30 each step
## costs 3% more than the last, so 99 is a stay, not a second career.

const XP_PER_FELL := 25
const XP_PER_LIGHT := 40
const XP_PER_PICK := 10
const MAX_LEVEL := 99
const LATE_START := 30
const LATE_GROWTH := 1.03
const CATCH_START := 0.35
const CATCH_SURE := 0.95
const FIRE_WOOD_START := 7.0
const FIRE_WOOD_END := 1.0
## Level-1 eat tax. Live cost comes from eat_forage_cost().
const EAT_FORAGE_START := 10
const EAT_FORAGE_END := 2

var woodcutting_xp: int = 0
var firemaking_xp: int = 0
var forage_xp: int = 0

## Tests only: -1 rolls, 0 forces a miss, 1 forces a catch.
var catch_override: int = -1
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _rng_ready := false


func level() -> int:
	return _level_of(woodcutting_xp)


func firemaking_level() -> int:
	return _level_of(firemaking_xp)


func forage_level() -> int:
	return _level_of(forage_xp)


func add_woodcutting_xp(amount: int) -> int:
	return _add_xp("woodcutting", amount)


func add_firemaking_xp(amount: int) -> int:
	return _add_xp("firemaking", amount)


func add_forage_xp(amount: int) -> int:
	return _add_xp("forage", amount)


func wood_at(lv: int = -1) -> float:
	if lv < 0:
		lv = level()
	lv = clampi(lv, 1, MAX_LEVEL)
	var raw := 0.5
	if lv <= LATE_START:
		raw = 0.5 + (3.0 - 0.5) * float(lv - 1) / 29.0
	else:
		raw = 3.0 + (10.0 - 3.0) * float(lv - LATE_START) / 69.0
	return snappedf(raw, 0.1)


## Whole berries from one bush. Level 1 keeps today’s one pick.
static func forage_at(lv: int = 1) -> int:
	lv = clampi(lv, 1, MAX_LEVEL)
	if lv >= 80:
		return 4
	if lv >= 50:
		return 3
	if lv >= LATE_START:
		return 2
	return 1


## Berries spent for half a heart. Ten-level bands, floor of 2.
## Quality is the current Foraging level — the handful in hand has no stored age.
static func eat_forage_cost(lv: int = 1) -> int:
	lv = clampi(lv, 1, MAX_LEVEL)
	var band := int((lv - 1) / 10)
	return maxi(EAT_FORAGE_END, EAT_FORAGE_START - band)


func forage_pay() -> int:
	return forage_at(forage_level())


func eat_cost() -> int:
	return eat_forage_cost(forage_level())


static func chop_range(lv: int) -> Vector2i:
	lv = clampi(lv, 1, MAX_LEVEL)
	if lv >= 80:
		return Vector2i(1, 1)
	if lv >= 50:
		return Vector2i(1, 2)
	if lv >= 20:
		return Vector2i(2, 3)
	return Vector2i(3, 4)


static func catch_chance(lv: int = 1) -> float:
	lv = clampi(lv, 1, MAX_LEVEL)
	if lv >= LATE_START:
		return CATCH_SURE
	return CATCH_START + (CATCH_SURE - CATCH_START) * float(lv - 1) / 29.0


static func fire_wood_cost(lv: int = 1) -> float:
	lv = clampi(lv, 1, MAX_LEVEL)
	if lv <= LATE_START:
		return FIRE_WOOD_START
	var raw := FIRE_WOOD_START + (FIRE_WOOD_END - FIRE_WOOD_START) * float(lv - LATE_START) / 69.0
	return snappedf(raw, 0.1)


func fire_cost() -> float:
	return fire_wood_cost(firemaking_level())


func roll_catch() -> bool:
	if catch_override == 0:
		return false
	if catch_override == 1:
		return true
	if not _rng_ready:
		rng.randomize()
		_rng_ready = true
	return rng.randf() < catch_chance(firemaking_level())


func step_into() -> int:
	return _step_into(woodcutting_xp)


func step_cost() -> int:
	return _step_cost(woodcutting_xp)


func step_label() -> String:
	return _step_label(woodcutting_xp)


func firemaking_step_into() -> int:
	return _step_into(firemaking_xp)


func firemaking_step_cost() -> int:
	return _step_cost(firemaking_xp)


func firemaking_step_label() -> String:
	return _step_label(firemaking_xp)


func forage_step_into() -> int:
	return _step_into(forage_xp)


func forage_step_cost() -> int:
	return _step_cost(forage_xp)


func forage_step_label() -> String:
	return _step_label(forage_xp)


static func xp_for_level(lv: int) -> int:
	lv = clampi(lv, 1, MAX_LEVEL)
	var raw := 0
	if lv <= LATE_START:
		raw = _osrs_xp(lv)
	else:
		var base := _osrs_xp(LATE_START)
		var step0 := _osrs_xp(LATE_START + 1) - _osrs_xp(LATE_START)
		var k := lv - LATE_START
		raw = int(floor(float(base) + float(step0) * (pow(LATE_GROWTH, float(k)) - 1.0) / (LATE_GROWTH - 1.0)))
	return int(floor(float(raw) * AdminSettings.xp_scale))


func _level_of(xp: int) -> int:
	var lv := 1
	while lv < MAX_LEVEL and xp >= xp_for_level(lv + 1):
		lv += 1
	return lv


func _add_xp(which: String, amount: int) -> int:
	if amount <= 0:
		return 0
	var cap := xp_for_level(MAX_LEVEL)
	match which:
		"firemaking":
			var before_fire := firemaking_level()
			firemaking_xp = mini(cap, firemaking_xp + amount)
			return firemaking_level() - before_fire
		"forage":
			var before_forage := forage_level()
			forage_xp = mini(cap, forage_xp + amount)
			return forage_level() - before_forage
		"woodcutting":
			var before_wood := level()
			woodcutting_xp = mini(cap, woodcutting_xp + amount)
			return level() - before_wood
		_:
			return 0


func _step_into(xp: int) -> int:
	return xp - xp_for_level(_level_of(xp))


func _step_cost(xp: int) -> int:
	var lv := _level_of(xp)
	if lv >= MAX_LEVEL:
		return 0
	return xp_for_level(lv + 1) - xp_for_level(lv)


func _step_label(xp: int) -> String:
	var lv := _level_of(xp)
	if lv >= MAX_LEVEL:
		return "99"
	return "%d/%d" % [_step_into(xp), _step_cost(xp)]


static func _osrs_xp(lv: int) -> int:
	if lv <= 1:
		return 0
	var points := 0
	for i in range(1, lv):
		points += int(floor(float(i) + 300.0 * pow(2.0, float(i) / 7.0)))
	return int(floor(float(points) / 4.0))
