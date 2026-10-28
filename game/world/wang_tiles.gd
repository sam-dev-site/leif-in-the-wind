class_name WangTiles
extends RefCounted

## PixelLab tileset15 sheets: 16 Wang tiles, 4 corners, lower vs upper.
## NW=8, NE=4, SW=2, SE=1. Atlas positions come from each sheet's JSON.

const PAIR_WATER_SHORE := 0
const PAIR_SHORE_MOSS := 1
const PAIR_MOSS_TRAIL := 2
const PAIR_MOSS_GRANITE := 3

const _SHEETS := {
	PAIR_WATER_SHORE: "res://art/tiles/tiles_water_shore",
	PAIR_SHORE_MOSS: "res://art/tiles/tiles_shore_moss",
	PAIR_MOSS_TRAIL: "res://art/tiles/tiles_moss_trail",
	PAIR_MOSS_GRANITE: "res://art/tiles/tiles_moss_granite",
}

var _tex: Dictionary = {}
var _img: Dictionary = {}
var _origin: Dictionary = {}


static func index(nw: bool, ne: bool, sw: bool, se: bool) -> int:
	return (8 if nw else 0) + (4 if ne else 0) + (2 if sw else 0) + (1 if se else 0)


static func is_upper(pair: int, kind: int) -> bool:
	match pair:
		PAIR_WATER_SHORE:
			return kind != ChunkGenerator.TILE_WATER
		PAIR_SHORE_MOSS:
			return (
				kind == ChunkGenerator.TILE_MOSS
				or kind == ChunkGenerator.TILE_PEAT
				or kind == ChunkGenerator.TILE_TRAIL
				or kind == ChunkGenerator.TILE_GRANITE
			)
		PAIR_MOSS_TRAIL:
			return kind == ChunkGenerator.TILE_TRAIL
		PAIR_MOSS_GRANITE:
			return kind == ChunkGenerator.TILE_GRANITE
		_:
			return false


static func pick_pair(kind: int, neighbor_kinds: Array[int]) -> int:
	if kind == ChunkGenerator.TILE_WATER:
		return PAIR_WATER_SHORE
	if kind == ChunkGenerator.TILE_SHORE:
		if neighbor_kinds.has(ChunkGenerator.TILE_WATER):
			return PAIR_WATER_SHORE
		return PAIR_SHORE_MOSS
	if kind == ChunkGenerator.TILE_TRAIL:
		return PAIR_MOSS_TRAIL
	if kind == ChunkGenerator.TILE_GRANITE:
		return PAIR_MOSS_GRANITE
	if neighbor_kinds.has(ChunkGenerator.TILE_TRAIL):
		return PAIR_MOSS_TRAIL
	if neighbor_kinds.has(ChunkGenerator.TILE_GRANITE):
		return PAIR_MOSS_GRANITE
	if neighbor_kinds.has(ChunkGenerator.TILE_SHORE) or neighbor_kinds.has(ChunkGenerator.TILE_WATER):
		return PAIR_SHORE_MOSS
	return PAIR_MOSS_TRAIL


func load_coastal() -> void:
	_tex.clear()
	_img.clear()
	_origin.clear()
	for pair in _SHEETS.keys():
		var base := str(_SHEETS[pair])
		var png := "%s.png" % base
		if ResourceLoader.exists(png):
			var tex := load(png) as Texture2D
			_tex[pair] = tex
			if tex != null:
				var sheet := tex.get_image()
				if sheet != null:
					if sheet.is_compressed():
						sheet.decompress()
					_img[pair] = sheet
		_origin[pair] = _atlas_from_json("%s.json" % base)


func ready() -> bool:
	return _tex.size() == 4


func blit(item: CanvasItem, tx: int, ty: int, sample: Callable) -> bool:
	var kind: int = sample.call(tx, ty)
	var neighbors: Array[int] = []
	for oy in range(-1, 2):
		for ox in range(-1, 2):
			if ox == 0 and oy == 0:
				continue
			neighbors.append(sample.call(tx + ox, ty + oy))
	var pair := pick_pair(kind, neighbors)
	if not _tex.has(pair):
		return false
	var tex := _tex[pair] as Texture2D
	if tex == null:
		return false
	var idx := _cell_index(tx, ty, pair, sample)
	var origin: Vector2 = (_origin[pair] as PackedVector2Array)[idx]
	var dest := Rect2(
		tx * ChunkGenerator.TILE,
		ty * ChunkGenerator.TILE,
		ChunkGenerator.TILE,
		ChunkGenerator.TILE
	)
	item.draw_texture_rect_region(tex, dest, Rect2(origin, Vector2(ChunkGenerator.TILE, ChunkGenerator.TILE)))
	return true


func blit_to_image(dest: Image, tx: int, ty: int, sample: Callable) -> bool:
	if dest == null:
		return false
	var kind: int = sample.call(tx, ty)
	var neighbors: Array[int] = []
	for oy in range(-1, 2):
		for ox in range(-1, 2):
			if ox == 0 and oy == 0:
				continue
			neighbors.append(sample.call(tx + ox, ty + oy))
	var pair := pick_pair(kind, neighbors)
	if not _img.has(pair):
		return false
	var sheet: Image = _img[pair]
	if sheet == null:
		return false
	var idx := _cell_index(tx, ty, pair, sample)
	var origin: Vector2 = (_origin[pair] as PackedVector2Array)[idx]
	dest.blit_rect(
		sheet,
		Rect2i(int(origin.x), int(origin.y), ChunkGenerator.TILE, ChunkGenerator.TILE),
		Vector2i(tx * ChunkGenerator.TILE, ty * ChunkGenerator.TILE)
	)
	return true


func _cell_index(tx: int, ty: int, pair: int, sample: Callable) -> int:
	var nw := _vertex_upper(tx, ty, pair, sample)
	var ne := _vertex_upper(tx + 1, ty, pair, sample)
	var sw := _vertex_upper(tx, ty + 1, pair, sample)
	var se := _vertex_upper(tx + 1, ty + 1, pair, sample)
	return index(nw, ne, sw, se)


func _vertex_upper(vx: int, vy: int, pair: int, sample: Callable) -> bool:
	var votes := 0
	for oy in [-1, 0]:
		for ox in [-1, 0]:
			if is_upper(pair, sample.call(vx + ox, vy + oy)):
				votes += 1
	return votes >= 2


func _atlas_from_json(path: String) -> PackedVector2Array:
	var origins := PackedVector2Array()
	origins.resize(16)
	for i in 16:
		origins[i] = Vector2((i % 4) * ChunkGenerator.TILE, int(i / 4.0) * ChunkGenerator.TILE)
	if not FileAccess.file_exists(path):
		return origins
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return origins
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return origins
	var data: Dictionary = parsed
	var tileset: Dictionary = data.get("tileset_data", {})
	var tiles: Array = tileset.get("tiles", [])
	for tile in tiles:
		if typeof(tile) != TYPE_DICTIONARY:
			continue
		var name := str(tile.get("name", ""))
		if not name.begins_with("wang_"):
			continue
		var idx := int(name.substr(5))
		if idx < 0 or idx > 15:
			continue
		var box: Dictionary = tile.get("bounding_box", {})
		origins[idx] = Vector2(float(box.get("x", 0)), float(box.get("y", 0)))
	return origins
