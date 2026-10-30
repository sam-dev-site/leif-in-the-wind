class_name AdminSettings
extends RefCounted

## Machine-wide QC knobs for the title admin panel.
## Not a shore save. Session values apply to the next New Game / Continue
## even without Save. Save writes user://admin_settings.json for the next launch.

const DEFAULTS := {
	"day_seconds": 50.0,
	"night_seconds": 60.0,
	"hearts": 3,
	"xp_scale": 1.0,
	"foliage_percent": 0,
	"walk_speed": 70.0,
	"run_speed": 100.0,
}

## Default density is 80% of the top. The bottom can strip the scatter.
const FOLIAGE_MIN := -100
const FOLIAGE_MAX := 25

static var path := "user://admin_settings.json"

static var day_seconds: float = 50.0
static var night_seconds: float = 60.0
static var hearts: int = 3
static var xp_scale: float = 1.0
static var foliage_percent: int = 0
static var walk_speed: float = 70.0
static var run_speed: float = 100.0


static func use_path(p: String) -> void:
	path = p


static func absolute_path() -> String:
	return ProjectSettings.globalize_path(path)


static func foliage_multiplier() -> float:
	return 1.0 + float(foliage_percent) / 100.0


static func reset_to_defaults() -> void:
	_apply(DEFAULTS.duplicate())


static func load_file() -> void:
	if not FileAccess.file_exists(path):
		reset_to_defaults()
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		reset_to_defaults()
		return
	var data: Dictionary = DEFAULTS.duplicate()
	var raw: Dictionary = parsed
	for key in DEFAULTS.keys():
		if raw.has(key):
			data[key] = raw[key]
	_apply(data)


static func save_file() -> bool:
	clamp_live()
	var data := {
		"day_seconds": day_seconds,
		"night_seconds": night_seconds,
		"hearts": hearts,
		"xp_scale": xp_scale,
		"foliage_percent": foliage_percent,
		"walk_speed": walk_speed,
		"run_speed": run_speed,
	}
	var abs_dir := ProjectSettings.globalize_path(path.get_base_dir())
	if abs_dir != "":
		DirAccess.make_dir_recursive_absolute(abs_dir)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	return true


static func clamp_live() -> void:
	day_seconds = clampf(float(day_seconds), 15.0, 180.0)
	night_seconds = clampf(float(night_seconds), 10.0, 180.0)
	hearts = clampi(int(hearts), 1, 10)
	xp_scale = clampf(float(xp_scale), 0.25, 2.0)
	foliage_percent = clampi(int(foliage_percent), FOLIAGE_MIN, FOLIAGE_MAX)
	walk_speed = clampf(float(walk_speed), 30.0, 150.0)
	run_speed = clampf(float(run_speed), 40.0, 200.0)
	if run_speed < walk_speed:
		run_speed = walk_speed


static func _apply(data: Dictionary) -> void:
	day_seconds = float(data.get("day_seconds", DEFAULTS["day_seconds"]))
	night_seconds = float(data.get("night_seconds", DEFAULTS["night_seconds"]))
	hearts = int(data.get("hearts", DEFAULTS["hearts"]))
	xp_scale = float(data.get("xp_scale", DEFAULTS["xp_scale"]))
	foliage_percent = int(data.get("foliage_percent", DEFAULTS["foliage_percent"]))
	walk_speed = float(data.get("walk_speed", DEFAULTS["walk_speed"]))
	run_speed = float(data.get("run_speed", DEFAULTS["run_speed"]))
	clamp_live()
