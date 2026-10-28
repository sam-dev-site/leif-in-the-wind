class_name FogMap
extends RefCounted

## Local circle around Leif. One pixel per tile. Fog opens the play view, not one cell.

const VIEW := 41
const RADIUS := 20
const PLAY_SIZE := Vector2(480, 270)
const FOG_COLOR := Color8(10, 15, 10, 240)
const LEIF_COLOR := Color8(245, 230, 184, 255)
const RIM_COLOR := Color8(42, 32, 22, 255)
const CLEAR := Color(0, 0, 0, 0)

var revealed: Dictionary = {}


func reveal(cell: Vector2i) -> bool:
	if revealed.has(cell):
		return false
	revealed[cell] = true
	return true


## Tiles currently on the 480×270 play view, centered on camera.
static func view_rect(center_px: Vector2, view_size: Vector2 = PLAY_SIZE) -> Rect2i:
	var half := view_size * 0.5
	var a := ChunkGenerator.world_cell_at(center_px - half)
	var b := ChunkGenerator.world_cell_at(center_px + half - Vector2(1, 1))
	var minc := Vector2i(mini(a.x, b.x), mini(a.y, b.y))
	var maxc := Vector2i(maxi(a.x, b.x), maxi(a.y, b.y))
	return Rect2i(minc, maxc - minc + Vector2i.ONE)


func reveal_rect(rect: Rect2i) -> bool:
	var opened := false
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			if reveal(Vector2i(x, y)):
				opened = true
	return opened


func is_revealed(cell: Vector2i) -> bool:
	return revealed.has(cell)


func clear() -> void:
	revealed.clear()


func count() -> int:
	return revealed.size()


func map_pixel(cell: Vector2i, player_cell: Vector2i) -> Vector2i:
	return Vector2i(cell.x - player_cell.x + RADIUS, cell.y - player_cell.y + RADIUS)


func in_view(cell: Vector2i, player_cell: Vector2i) -> bool:
	return _inside_circle(map_pixel(cell, player_cell))


## sample(cell) -> tile kind. color_of(kind) -> Color.
func paint(sample: Callable, color_of: Callable, player_cell: Vector2i) -> Image:
	var img := Image.create(VIEW, VIEW, false, Image.FORMAT_RGBA8)
	img.fill(CLEAR)
	for py in VIEW:
		for px in VIEW:
			var at := Vector2i(px, py)
			if not _inside_circle(at):
				continue
			if _on_rim(at):
				img.set_pixel(px, py, RIM_COLOR)
				continue
			var cell := Vector2i(player_cell.x + px - RADIUS, player_cell.y + py - RADIUS)
			if is_revealed(cell):
				img.set_pixel(px, py, color_of.call(int(sample.call(cell))))
			else:
				img.set_pixel(px, py, FOG_COLOR)
	img.set_pixel(RADIUS, RADIUS, LEIF_COLOR)
	return img


func _inside_circle(pixel: Vector2i) -> bool:
	var dx := pixel.x - RADIUS
	var dy := pixel.y - RADIUS
	return dx * dx + dy * dy <= RADIUS * RADIUS


func _on_rim(pixel: Vector2i) -> bool:
	var dx := pixel.x - RADIUS
	var dy := pixel.y - RADIUS
	var d2 := dx * dx + dy * dy
	return d2 <= RADIUS * RADIUS and d2 >= (RADIUS - 1) * (RADIUS - 1)
