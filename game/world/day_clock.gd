class_name DayClock
extends Node

## Short cycle so a playtest reaches night, then dawn, without a long wait.
## The campfire is the warm light. This clock does not deal damage.

const DAY_SECONDS := 50.0
const DUSK_SECONDS := 10.0
const NIGHT_SECONDS := 40.0
const NIGHT_COLOR := Color(0.07, 0.08, 0.16, 1.0)

signal phase_changed(next: String)

## Latest darkness, so a campfire can fade its pool in without a per-frame search.
static var darkness_now := 0.0

var elapsed := 0.0
var supplies: Supplies
var modulate: CanvasModulate


func _process(delta: float) -> void:
	var before := phase()
	elapsed += delta
	darkness_now = darkness()
	if modulate != null:
		modulate.color = modulate_color()
	if supplies != null:
		supplies.tick_night(is_night())
	var after := phase()
	if after != before:
		phase_changed.emit(after)


func cycle_length() -> float:
	return DAY_SECONDS + NIGHT_SECONDS


func phase() -> String:
	var t := fposmod(elapsed, cycle_length())
	if t >= DAY_SECONDS:
		return "night"
	if t >= DAY_SECONDS - DUSK_SECONDS:
		return "dusk"
	return "day"


func is_night() -> bool:
	return phase() == "night"


## 0 is full daylight. 1 is night.
func darkness() -> float:
	var t := fposmod(elapsed, cycle_length())
	if t >= DAY_SECONDS:
		return 1.0
	var dusk_start := DAY_SECONDS - DUSK_SECONDS
	if t <= dusk_start:
		return 0.0
	return (t - dusk_start) / DUSK_SECONDS


func modulate_color() -> Color:
	var dark := darkness()
	if dark <= 0.0:
		return Color(1, 1, 1, 1)
	if dark >= 1.0:
		return NIGHT_COLOR
	return Color(1, 1, 1, 1).lerp(NIGHT_COLOR, dark)
