class_name Supplies
extends RefCounted

## What Leif is carrying. Slice 0 spends wood on a fire and keeps forage for later.
## Hearts are shown and are not spent: hunger and freezing are slice 1.

const WOOD_PER_TREE := 3
const CAMPFIRE_WOOD := 3

var hearts: int = 3
var hearts_max: int = 3
var wood: int = 0
var forage: int = 0


func pick_forage(species: String, biome: Biome) -> bool:
	if not _listed(species, biome, false):
		return false
	forage += 1
	return true


func chop_tree(species: String, biome: Biome) -> bool:
	if not _listed(species, biome, true):
		return false
	wood += WOOD_PER_TREE
	return true


func try_spend_wood(amount: int) -> bool:
	if amount < 0 or wood < amount:
		return false
	wood -= amount
	return true


## Called every frame the clock is running. Night is dark, not lethal.
func tick_night(_is_night: bool) -> void:
	pass


func _listed(species: String, biome: Biome, as_tree: bool) -> bool:
	if biome == null or species.is_empty():
		return false
	var names := biome.tree_species if as_tree else biome.forage_species
	return names.has(species)
