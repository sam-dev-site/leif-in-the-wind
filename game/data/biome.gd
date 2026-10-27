class_name Biome
extends Resource

## Data for one ecoregion. Filled from docs/research/biomes/<id>.md — never from vibes.

@export var id: StringName = &""
@export var display_name: String = ""
@export var tree_species: PackedStringArray = []
@export var forage_species: PackedStringArray = []
@export var trail_maker: StringName = &""
@export var water_color: Color = Color(0.23, 0.37, 0.44)
@export var shore_color: Color = Color(0.77, 0.71, 0.60)
@export var moss_color: Color = Color(0.24, 0.36, 0.20)
@export var peat_color: Color = Color(0.29, 0.23, 0.16)
@export var granite_color: Color = Color(0.48, 0.48, 0.45)
@export var trail_color: Color = Color(0.36, 0.25, 0.19)
