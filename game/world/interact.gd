class_name Interact
extends Node

## Space uses the prop on Leif's tile, or a prop on a neighboring tile he is facing.
## Positions are chunk-local, same space as the player and the colored-box props.

const MIN_FACING_DOT := 0.5

signal acted(action: String, species: String)

var player: Player
var supplies: Supplies
var biome: Biome
var chunk: MapChunk
var world: World


static func facing_vector(facing_name: String) -> Vector2:
	match facing_name:
		"east":
			return Vector2.RIGHT
		"west":
			return Vector2.LEFT
		"north":
			return Vector2.UP
		"south":
			return Vector2.DOWN
		"north-east":
			return Vector2(1, -1).normalized()
		"north-west":
			return Vector2(-1, -1).normalized()
		"south-east":
			return Vector2(1, 1).normalized()
		"south-west":
			return Vector2(-1, 1).normalized()
		_:
			return Vector2.DOWN


static func tile_ahead(player_pos: Vector2, facing_name: String) -> Vector2i:
	var cell := MapChunk.cell_at_point(player_pos)
	var dir := facing_vector(facing_name)
	return cell + Vector2i(int(round(dir.x)), int(round(dir.y)))


func best_target(origin: Vector2, facing_name: String, props: Array) -> Node2D:
	var player_cell := MapChunk.cell_at_point(origin)
	var forward := facing_vector(facing_name)
	var best: Node2D = null
	var best_score := -1.0
	for prop in props:
		if not prop is Node2D:
			continue
		var node := prop as Node2D
		if not _is_usable(node):
			continue
		var cell := MapChunk.cell_at_prop(_point_of(node))
		var delta := Vector2(float(cell.x - player_cell.x), float(cell.y - player_cell.y))
		var steps := maxi(absi(cell.x - player_cell.x), absi(cell.y - player_cell.y))
		if steps > 1:
			continue
		var score := 0.99 if steps == 0 else delta.normalized().dot(forward)
		if steps > 0 and score < MIN_FACING_DOT:
			continue
		if score > best_score:
			best = node
			best_score = score
	return best


func use_on(target: Node2D) -> String:
	if target == null or supplies == null or not is_instance_valid(target):
		return ""
	if not target.has_meta("kind") or not target.has_meta("species"):
		return ""
	if bool(target.get_meta("harvested", false)):
		return ""
	var kind := str(target.get_meta("kind"))
	var species := str(target.get_meta("species"))
	var ok := false
	var action := ""
	if kind == "forage":
		ok = supplies.pick_forage(species, biome)
		action = "forage"
	elif kind == "tree" or kind == "fallen":
		ok = supplies.chop_tree(species, biome)
		action = "chop"
	elif kind == "branch" or (kind == "clutter" and Supplies.is_branch(species)):
		ok = supplies.gather_branch(species)
		action = "clear"
	if not ok:
		return ""
	target.set_meta("harvested", true)
	return action


func _unhandled_input(event: InputEvent) -> void:
	if player == null or supplies == null:
		return
	if world != null and world.is_naming():
		return
	if not event is InputEventKey:
		return
	var key := event as InputEventKey
	if not key.pressed or key.echo or key.keycode != KEY_SPACE:
		return
	var target := best_target(player.global_position, player.facing_name(), _usable_props())
	var action := use_on(target)
	if action == "":
		return
	var species := str(target.get_meta("species"))
	acted.emit(action, species)
	_release(target)
	get_viewport().set_input_as_handled()


func _usable_props() -> Array:
	if world != null:
		return world.nearby_props()
	if chunk != null:
		return chunk.prop_nodes()
	return []


func _release(target: Node2D) -> void:
	var host := target.get_parent()
	if host is MapChunk:
		(host as MapChunk).release_prop(target)
	elif chunk != null:
		chunk.release_prop(target)


func _point_of(node: Node2D) -> Vector2:
	if node.is_inside_tree():
		return node.global_position
	return node.position


func _is_usable(node: Node2D) -> bool:
	if not is_instance_valid(node) or node.is_queued_for_deletion():
		return false
	if bool(node.get_meta("harvested", false)):
		return false
	if not node.has_meta("kind") or not node.has_meta("species"):
		return false
	var kind := str(node.get_meta("kind"))
	if kind == "tree" or kind == "forage" or kind == "fallen" or kind == "branch":
		return true
	return kind == "clutter" and Supplies.is_branch(str(node.get_meta("species")))
