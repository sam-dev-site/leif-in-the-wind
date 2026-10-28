class_name PlayWindow
extends RefCounted

## Keep 480×270. Size the play window to the largest 16:9 that fits this screen.
## Integer 3× needs 1440px; this Surface's desktop is 1368px, so fractional fill is how F5 gets bigger.
static func fit(win: Window) -> void:
	if Engine.is_embedded_in_editor():
		return
	if DisplayServer.get_name() == "headless":
		return
	if win == null:
		return
	if win.mode == Window.MODE_FULLSCREEN or win.mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
		return
	var usable := DisplayServer.screen_get_usable_rect(win.current_screen)
	var scale := minf(float(usable.size.x) / 480.0, float(usable.size.y) / 270.0)
	scale = maxf(scale, 1.0)
	var size := Vector2i(int(480.0 * scale), int(270.0 * scale))
	win.mode = Window.MODE_WINDOWED
	win.size = size
	var extra := usable.size - size
	win.position = usable.position + Vector2i(extra.x / 2, extra.y / 2)
