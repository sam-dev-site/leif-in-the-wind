class_name LeafBurst
extends Node2D

## A short fall of fir needles around Leif when woodcutting levels up.

const LIFE := 1.0
const COUNT := 8
const LEAF := "res://art/ui/leaf_fir.png"

var _age := 0.0
var _vel: Array[Vector2] = []
var _sprites: Array[Node2D] = []


func _ready() -> void:
	z_index = 8
	var tex: Texture2D = null
	if ResourceLoader.exists(LEAF):
		tex = load(LEAF) as Texture2D
	for i in COUNT:
		var node: Node2D
		if tex != null:
			var sprite := Sprite2D.new()
			sprite.texture = tex
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.centered = true
			sprite.scale = Vector2(0.7, 0.7)
			node = sprite
		else:
			var pip := ColorRect.new()
			pip.size = Vector2(2, 3)
			pip.color = Color(0.22, 0.42, 0.18, 1)
			pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
			pip.position = Vector2(-1, -2)
			var wrap := Node2D.new()
			wrap.add_child(pip)
			node = wrap
		var start := Vector2(randf_range(-10.0, 10.0), randf_range(-22.0, -8.0))
		node.position = start
		add_child(node)
		_sprites.append(node)
		_vel.append(Vector2(randf_range(-18.0, 18.0), randf_range(28.0, 52.0)))


func _process(delta: float) -> void:
	_age += delta
	var fade := clampf(1.0 - _age / LIFE, 0.0, 1.0)
	for i in _sprites.size():
		_sprites[i].position += _vel[i] * delta
		_vel[i].y += 40.0 * delta
		_sprites[i].modulate.a = fade
	if _age >= LIFE:
		queue_free()
