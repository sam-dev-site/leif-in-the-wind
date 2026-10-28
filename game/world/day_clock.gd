class_name DayClock
extends Node

## Short cycle so a playtest reaches night, then dawn, without a long wait.
## The campfire is the warm light. Cold hearts are the world's job, not this clock.

const DAY_SECONDS := 50.0
const DUSK_SECONDS := 10.0
## Cold night is 60s (six hearts at ½ / 5s). This constant includes the dawn fade after it.
const NIGHT_SECONDS := 70.0
const DAWN_SECONDS := 10.0
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
	var after := phase()
	if after != before:
		phase_changed.emit(after)


func cycle_length() -> float:
	return DAY_SECONDS + NIGHT_SECONDS


func phase() -> String:
	var t := fposmod(elapsed, cycle_length())
	if t >= cycle_length() - DAWN_SECONDS:
		return "dawn"
	if t >= DAY_SECONDS:
		return "night"
	if t >= DAY_SECONDS - DUSK_SECONDS:
		return "dusk"
	return "day"


func is_night() -> bool:
	return phase() == "night"


## How long `is_night()` stays true. Dawn is after this, carved from NIGHT_SECONDS.
static func cold_seconds() -> float:
	return NIGHT_SECONDS - DAWN_SECONDS


func can_sleep() -> bool:
	var name := phase()
	return name == "dusk" or name == "night"


func seconds_until_dawn() -> float:
	if not can_sleep():
		return 0.0
	var cycle := cycle_length()
	var dawn_start := cycle - DAWN_SECONDS
	var t := fposmod(elapsed, cycle)
	return maxf(0.0, dawn_start - t)


func sleep_to_dawn() -> bool:
	if not can_sleep():
		return false
	var cycle := cycle_length()
	var dawn_start := cycle - DAWN_SECONDS
	var t := fposmod(elapsed, cycle)
	elapsed = elapsed - t + dawn_start
	darkness_now = darkness()
	if modulate != null:
		modulate.color = modulate_color()
	phase_changed.emit(phase())
	return true


## 0 is full daylight. 1 is night. Dusk eases in; dawn eases out so the wrap is not a cut.
func darkness() -> float:
	var t := fposmod(elapsed, cycle_length())
	var dusk_start := DAY_SECONDS - DUSK_SECONDS
	var dawn_start := cycle_length() - DAWN_SECONDS
	if t <= dusk_start:
		return 0.0
	if t < DAY_SECONDS:
		return (t - dusk_start) / DUSK_SECONDS
	if t < dawn_start:
		return 1.0
	return 1.0 - (t - dawn_start) / DAWN_SECONDS


func modulate_color() -> Color:
	var dark := darkness()
	if dark <= 0.0:
		return Color(1, 1, 1, 1)
	if dark >= 1.0:
		return NIGHT_COLOR
	return Color(1, 1, 1, 1).lerp(NIGHT_COLOR, dark)
