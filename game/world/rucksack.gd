class_name Rucksack
extends RefCounted

## Extras Leif carries. Not wood. Not forage. Stacks cap at 99, then a new pile.

const STACK_CAP := 99
const ID_PITCH := "pitch"
const ID_STICK := "stick"
const ID_TORCH := "torch"
const STICK_CHANCE := 0.25
const PITCH_CHANCE := 0.10
const TORCH_STICK := 1
const TORCH_PITCH := 1
const DEATH_TAX_MIN := 5
const DEATH_TAX_MAX := 10
const DEATH_TAX_STACKS_MAX := 4

## Ordered piles: { "id": String, "count": int }
var stacks: Array = []
## Index of the equipped torch stack, or -1.
var equipped_index: int = -1
var torch_lit: bool = false
var torch_burn_left: float = 0.0


func clear() -> void:
	stacks.clear()
	equipped_index = -1
	torch_lit = false
	torch_burn_left = 0.0


func total_of(id: String) -> int:
	var n := 0
	for stack in stacks:
		if str(stack.get("id", "")) == id:
			n += int(stack.get("count", 0))
	return n


func stack_count() -> int:
	return stacks.size()


func add(id: String, amount: int = 1) -> int:
	if amount < 1 or id.is_empty():
		return 0
	var left := amount
	var added := 0
	while left > 0:
		var idx := _first_open(id)
		if idx < 0:
			var put := mini(left, STACK_CAP)
			stacks.append({"id": id, "count": put})
			added += put
			left -= put
		else:
			var room := STACK_CAP - int(stacks[idx]["count"])
			var put := mini(left, room)
			stacks[idx]["count"] = int(stacks[idx]["count"]) + put
			added += put
			left -= put
	return added


func can_craft_torch() -> bool:
	return total_of(ID_STICK) >= TORCH_STICK and total_of(ID_PITCH) >= TORCH_PITCH


func craft_torch() -> bool:
	if not can_craft_torch():
		return false
	if not _spend(ID_STICK, TORCH_STICK):
		return false
	if not _spend(ID_PITCH, TORCH_PITCH):
		# Should not happen if can_craft checked both; restore stick if pitch failed.
		add(ID_STICK, TORCH_STICK)
		return false
	add(ID_TORCH, 1)
	return true


func is_torch_equipped() -> bool:
	return _valid_equip()


func equip_torch_at(index: int) -> bool:
	if torch_lit:
		return false
	if index < 0 or index >= stacks.size():
		return false
	if str(stacks[index].get("id", "")) != ID_TORCH:
		return false
	if int(stacks[index].get("count", 0)) < 1:
		return false
	if equipped_index == index:
		equipped_index = -1
		return true
	equipped_index = index
	return true


func light_torch(lifetime: float) -> bool:
	if torch_lit:
		return false
	if not _valid_equip():
		return false
	if lifetime <= 0.0:
		return false
	torch_lit = true
	torch_burn_left = lifetime
	return true


## Burns the lit torch. Returns true when it just went out and was consumed.
func tick_torch(delta: float) -> bool:
	if not torch_lit or delta <= 0.0:
		return false
	torch_burn_left = maxf(0.0, torch_burn_left - delta)
	if torch_burn_left > 0.0:
		return false
	_consume_equipped_torch()
	return true


## Sleep or death: put out a lit torch and spend that one.
func extinguish_and_consume() -> bool:
	if not torch_lit:
		return false
	_consume_equipped_torch()
	return true


func roll_stick(rng: RandomNumberGenerator) -> bool:
	if rng == null:
		return false
	return rng.randf() < STICK_CHANCE


func roll_pitch(rng: RandomNumberGenerator) -> bool:
	if rng == null:
		return false
	return rng.randf() < PITCH_CHANCE


## 5–10% of total extras, from up to 4 random stacks, uneven split. Wood/forage stay elsewhere.
func take_death_tax(rng: RandomNumberGenerator) -> void:
	if stacks.is_empty() or rng == null:
		return
	var total := 0
	for stack in stacks:
		total += int(stack.get("count", 0))
	if total < 1:
		return
	var p := rng.randi_range(DEATH_TAX_MIN, DEATH_TAX_MAX)
	var k := rng.randi_range(1, mini(DEATH_TAX_STACKS_MAX, stacks.size()))
	var picks: Array[int] = []
	var pool: Array[int] = []
	for i in stacks.size():
		pool.append(i)
	for _n in k:
		if pool.is_empty():
			break
		var at := rng.randi_range(0, pool.size() - 1)
		picks.append(pool[at])
		pool.remove_at(at)
	if picks.is_empty():
		return
	var shares := _split_percent(p, picks.size(), rng)
	for i in picks.size():
		var idx: int = picks[i]
		if idx < 0 or idx >= stacks.size():
			continue
		var count := int(stacks[idx].get("count", 0))
		var lose := int(floor(float(count) * float(shares[i]) / 100.0))
		if lose < 1:
			continue
		stacks[idx]["count"] = count - lose
	_prune_empty()


func to_save() -> Dictionary:
	var rows: Array = []
	for stack in stacks:
		rows.append({
			"id": str(stack.get("id", "")),
			"count": int(stack.get("count", 0)),
		})
	return {
		"stacks": rows,
		"equipped_index": equipped_index,
		"torch_lit": torch_lit,
		"torch_burn_left": torch_burn_left,
	}


func from_save(data: Variant) -> void:
	clear()
	if data == null or not (data is Dictionary):
		return
	var d: Dictionary = data
	var rows: Variant = d.get("stacks", [])
	if rows is Array:
		for item in rows:
			if not (item is Dictionary):
				continue
			var id := str(item.get("id", ""))
			var count := clampi(int(item.get("count", 0)), 0, STACK_CAP)
			if id.is_empty() or count < 1:
				continue
			# Keep separate piles. A file that overfilled one row is clamped, not merged.
			stacks.append({"id": id, "count": count})
	equipped_index = int(d.get("equipped_index", -1))
	if not _valid_equip():
		equipped_index = -1
		torch_lit = false
		torch_burn_left = 0.0
		return
	torch_lit = bool(d.get("torch_lit", false))
	torch_burn_left = float(d.get("torch_burn_left", 0.0))
	if torch_lit and torch_burn_left <= 0.0:
		torch_lit = false
		torch_burn_left = 0.0


func _valid_equip() -> bool:
	if equipped_index < 0 or equipped_index >= stacks.size():
		return false
	var stack: Dictionary = stacks[equipped_index]
	return str(stack.get("id", "")) == ID_TORCH and int(stack.get("count", 0)) >= 1


func _consume_equipped_torch() -> void:
	torch_lit = false
	torch_burn_left = 0.0
	if not _valid_equip():
		equipped_index = -1
		return
	var count := int(stacks[equipped_index].get("count", 0)) - 1
	if count < 1:
		stacks.remove_at(equipped_index)
		equipped_index = -1
	else:
		stacks[equipped_index]["count"] = count
		# Still equipped on the same pile if any remain.
	_prune_empty()


func _first_open(id: String) -> int:
	for i in stacks.size():
		if str(stacks[i].get("id", "")) != id:
			continue
		if int(stacks[i].get("count", 0)) < STACK_CAP:
			return i
	return -1


func _spend(id: String, amount: int) -> bool:
	if amount < 1 or total_of(id) < amount:
		return false
	var left := amount
	var i := 0
	while i < stacks.size() and left > 0:
		if str(stacks[i].get("id", "")) != id:
			i += 1
			continue
		var have := int(stacks[i].get("count", 0))
		var take := mini(have, left)
		stacks[i]["count"] = have - take
		left -= take
		if int(stacks[i]["count"]) < 1:
			if equipped_index == i:
				equipped_index = -1
				torch_lit = false
				torch_burn_left = 0.0
			elif equipped_index > i:
				equipped_index -= 1
			stacks.remove_at(i)
		else:
			i += 1
	return left == 0


func _prune_empty() -> void:
	var i := 0
	while i < stacks.size():
		if int(stacks[i].get("count", 0)) < 1:
			if equipped_index == i:
				equipped_index = -1
				torch_lit = false
				torch_burn_left = 0.0
			elif equipped_index > i:
				equipped_index -= 1
			stacks.remove_at(i)
		else:
			i += 1
	if not _valid_equip():
		equipped_index = -1


func _split_percent(total: int, parts: int, rng: RandomNumberGenerator) -> Array[int]:
	var out: Array[int] = []
	if parts < 1:
		return out
	if parts == 1:
		out.append(total)
		return out
	# Positive integers that sum to total.
	var cuts: Array[int] = []
	for _i in parts - 1:
		cuts.append(rng.randi_range(1, maxi(1, total - 1)))
	cuts.sort()
	var prev := 0
	var used := 0
	for c in cuts:
		var share := maxi(1, c - prev)
		# Keep enough for the remaining parts.
		var remain_parts := parts - out.size() - 1
		var max_share := total - used - remain_parts
		share = clampi(share, 1, maxi(1, max_share))
		out.append(share)
		used += share
		prev = c
	out.append(maxi(1, total - used))
	# Fix drift if clamp pushed us over/under.
	var sum := 0
	for s in out:
		sum += s
	if sum != total and not out.is_empty():
		out[out.size() - 1] = maxi(1, out[out.size() - 1] + (total - sum))
	return out
