class_name ShoreSave
extends RefCounted

## Three shores in Godot's user folder. An export uses the same files.
## Steam Cloud can watch that folder later. A file is the walk, not the chopped trees.

const SLOT_COUNT := 3
const EMPTY_LABEL := "No save file"
const NAME_LIMIT := 24
## Costa Rica stays on UTC−6. It does not switch to daylight time.
const CST_OFFSET_SEC := -6 * 3600

static var directory := "user://saves"
## Tests pin the clock. Play leaves this at -1 and uses the real time.
static var unix_override := -1


static func use_directory(path: String) -> void:
	directory = path


static func wipe() -> void:
	var dir := DirAccess.open(directory)
	if dir == null:
		return
	for i in SLOT_COUNT:
		dir.remove("slot_%d.json" % i)


static func now_unix() -> int:
	if unix_override >= 0:
		return unix_override
	return int(Time.get_unix_time_from_system())


static func slot_path(index: int) -> String:
	return directory.path_join("slot_%d.json" % index)


static func clean_name(raw: String) -> String:
	var text := raw.replace("\n", "").replace("\r", "").strip_edges()
	if text.length() > NAME_LIMIT:
		text = text.substr(0, NAME_LIMIT).strip_edges()
	return text


static func read_slot(index: int) -> Dictionary:
	if index < 0 or index >= SLOT_COUNT:
		return {}
	var path := slot_path(index)
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


static func has_slot(index: int) -> bool:
	return _filled(read_slot(index))


static func first_empty() -> int:
	for i in SLOT_COUNT:
		if not has_slot(i):
			return i
	return -1


static func label(index: int) -> String:
	var data := read_slot(index)
	if not _filled(data):
		return EMPTY_LABEL
	return "%s\n%s" % [str(data["name"]), format_cst(int(data["saved_unix"]))]


static func delete_slot(index: int) -> void:
	if index < 0 or index >= SLOT_COUNT:
		return
	var dir := DirAccess.open(directory)
	if dir == null:
		return
	dir.remove("slot_%d.json" % index)


static func write_slot(index: int, data: Dictionary) -> bool:
	if index < 0 or index >= SLOT_COUNT:
		return false
	if not _filled(data):
		return false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var file := FileAccess.open(slot_path(index), FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	return true


static func format_cst(unix_time: int) -> String:
	# This call returns UTC. Shift the instant so those fields are Costa Rica's clock.
	var dict := Time.get_datetime_dict_from_unix_time(unix_time + CST_OFFSET_SEC)
	var hour := int(dict["hour"])
	var suffix := "AM"
	if hour >= 12:
		suffix = "PM"
	var hour12 := hour % 12
	if hour12 == 0:
		hour12 = 12
	var months: PackedStringArray = PackedStringArray([
		"Jan", "Feb", "Mar", "Apr", "May", "Jun",
		"Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
	])
	var month := months[int(dict["month"]) - 1]
	return "%s %d, %d:%02d %s CST" % [month, int(dict["day"]), hour12, int(dict["minute"]), suffix]


static func _filled(data: Dictionary) -> bool:
	if data.is_empty():
		return false
	if not data.has("name") or clean_name(str(data["name"])) == "":
		return false
	return data.has("saved_unix")
