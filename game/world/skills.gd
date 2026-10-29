class_name Skills
extends RefCounted

## Woodcutting on this coast. Fire-making can sit next to it later.
## Levels 1–30 keep Old School RuneScape’s table. After 30 each step
## costs 3% more than the last, so 99 is a stay, not a second career.

const XP_PER_FELL := 25
const MAX_LEVEL := 99
const LATE_START := 30
const LATE_GROWTH := 1.03

var woodcutting_xp: int = 0


func level() -> int:
	var lv := 1
	while lv < MAX_LEVEL and woodcutting_xp >= xp_for_level(lv + 1):
		lv += 1
	return lv


func add_woodcutting_xp(amount: int) -> int:
	if amount <= 0:
		return 0
	var before := level()
	var cap := xp_for_level(MAX_LEVEL)
	woodcutting_xp = mini(cap, woodcutting_xp + amount)
	return level() - before


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


static func chop_range(lv: int) -> Vector2i:
	lv = clampi(lv, 1, MAX_LEVEL)
	if lv >= 80:
		return Vector2i(1, 1)
	if lv >= 50:
		return Vector2i(1, 2)
	if lv >= 20:
		return Vector2i(2, 3)
	return Vector2i(3, 4)


func step_into() -> int:
	return woodcutting_xp - xp_for_level(level())


func step_cost() -> int:
	var lv := level()
	if lv >= MAX_LEVEL:
		return 0
	return xp_for_level(lv + 1) - xp_for_level(lv)


func step_label() -> String:
	if level() >= MAX_LEVEL:
		return "99"
	return "%d/%d" % [step_into(), step_cost()]


static func xp_for_level(lv: int) -> int:
	lv = clampi(lv, 1, MAX_LEVEL)
	if lv <= LATE_START:
		return _osrs_xp(lv)
	var base := _osrs_xp(LATE_START)
	var step0 := _osrs_xp(LATE_START + 1) - _osrs_xp(LATE_START)
	var k := lv - LATE_START
	return int(floor(float(base) + float(step0) * (pow(LATE_GROWTH, float(k)) - 1.0) / (LATE_GROWTH - 1.0)))


static func _osrs_xp(lv: int) -> int:
	if lv <= 1:
		return 0
	var points := 0
	for i in range(1, lv):
		points += int(floor(float(i) + 300.0 * pow(2.0, float(i) / 7.0)))
	return int(floor(float(points) / 4.0))
