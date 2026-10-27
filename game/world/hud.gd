class_name GameHud
extends CanvasLayer

var _label: Label


func _ready() -> void:
	_label = Label.new()
	_label.position = Vector2(8, 8)
	_label.add_theme_font_size_override("font_size", 8)
	_label.modulate = Color(0.95, 0.93, 0.86)
	add_child(_label)


func show_status(world_seed: int, biome_name: String) -> void:
	_label.text = (
		"Leif in the Wind  seed %d  %s\n"
		+ "WASD / arrows walk   R new woods\n"
		+ "Water behind you. The trail leads inland."
	) % [world_seed, biome_name]
