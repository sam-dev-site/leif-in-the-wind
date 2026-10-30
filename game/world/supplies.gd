class_name Supplies
extends RefCounted

## What Leif is carrying. Wood buys a fire. Three berries buy half a heart.
## Night away from a fire spends hearts slowly. There is no hunger bar.

const WOOD_PER_TREE := 3.0
const WOOD_PER_BRANCH := 0.5
## Early fire-making tax. Live cost comes from Skills.fire_wood_cost().
const CAMPFIRE_WOOD := 7.0
const EAT_FORAGE := 3
const HEART_STEP := 0.5
const COLD_SECONDS := 5.0
const HEAL_SECONDS := 10.0

var hearts: float = 3.0
var hearts_max: float = 3.0
var wood: float = 0.0
var forage: int = 0
var cold_acc := 0.0
var heal_acc := 0.0


func pick_forage(species: String, biome: Biome) -> bool:
	if not _listed(species, biome, false):
		return false
	forage += 1
	return true


func can_chop_tree(species: String, biome: Biome) -> bool:
	return _listed(species, biome, true)


func chop_tree(species: String, biome: Biome, amount: float = WOOD_PER_TREE) -> bool:
	if not can_chop_tree(species, biome):
		return false
	_add_wood(amount)
	return true


func gather_branch(species: String) -> bool:
	if not is_branch(species):
		return false
	_add_wood(WOOD_PER_BRANCH)
	return true


func try_spend_wood(amount: float) -> bool:
	if amount < 0.0 or wood + 0.0001 < amount:
		return false
	wood = snappedf(wood - amount, 0.1)
	return true


## Spend 3 berries for half a heart. Short hands and full hearts spend nothing.
## Day heal and night cold are untouched.
func try_eat() -> String:
	if forage < EAT_FORAGE:
		return "short"
	if hearts >= hearts_max:
		return "full"
	forage -= EAT_FORAGE
	hearts = snappedf(minf(hearts_max, hearts + HEART_STEP), HEART_STEP)
	return "eat"


static func is_branch(species: String) -> bool:
	return species.ends_with("_branch")


static func wood_label(amount: float) -> String:
	if is_equal_approx(amount, snappedf(amount, 1.0)):
		return str(int(round(amount)))
	return "%.1f" % amount


func _add_wood(amount: float) -> void:
	wood = snappedf(wood + amount, 0.1)


## Night away from a fire: lose half a heart every 5s. Otherwise heal half a heart every 10s.
func tick_vitals(is_night: bool, is_warm: bool, delta: float) -> String:
	if delta <= 0.0:
		return ""
	if is_night and not is_warm:
		heal_acc = 0.0
		cold_acc += delta
		if cold_acc < COLD_SECONDS:
			return ""
		cold_acc = 0.0
		if hearts <= HEART_STEP:
			return ""
		hearts = snappedf(maxf(HEART_STEP, hearts - HEART_STEP), HEART_STEP)
		return "cold"
	cold_acc = 0.0
	if hearts >= hearts_max:
		heal_acc = 0.0
		return ""
	heal_acc += delta
	if heal_acc < HEAL_SECONDS:
		return ""
	heal_acc = 0.0
	hearts = snappedf(minf(hearts_max, hearts + HEART_STEP), HEART_STEP)
	return "heal"


func _listed(species: String, biome: Biome, as_tree: bool) -> bool:
	if biome == null or species.is_empty():
		return false
	var names := biome.tree_species if as_tree else biome.forage_species
	return names.has(species)
