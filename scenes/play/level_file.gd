extends Node2D
class_name LevelFile

@export var level_file_path: String = "res://levels/dwellingarea.lvl"
@export var debug_logging: bool = false

var line_comment_regex = RegEx.new()
var level_setting_regex = RegEx.new()
var tile_code_regex = RegEx.new()
var level_chance_regex = RegEx.new()
var monster_chance_regex = RegEx.new()
var template_type_regex = RegEx.new()
var template_setting_regex = RegEx.new()

func _ready():
	line_comment_regex.compile("^\\/\\/") # //
	var value_pattern = "(?<value>(?:(?!\\/\\/).)*)"
	level_setting_regex.compile("^\\\\-" + value_pattern) # \-
	tile_code_regex.compile("^\\\\\\?" + value_pattern) # \?
	level_chance_regex.compile("^\\\\%" + value_pattern) # \%
	monster_chance_regex.compile("^\\\\\\+" + value_pattern) # \+
	template_type_regex.compile("^\\\\\\." + value_pattern) # \.
	template_setting_regex.compile("^\\\\!" + value_pattern) # \!
	load_file(level_file_path)

var level_settings: Dictionary # maps settings name to value(s)
var tile_codes: Dictionary # maps tile code to name and chance
var level_chances: Dictionary # maps event name to chance (% or 1/n)
var monster_chances: Dictionary # maps monster name to chance (% or 1/n)
var templates: Dictionary # maps template type to array of templates

var _current_template_type: String
var _template_complete: bool

var _parse_functions = [
	{
		"pattern": level_setting_regex,
		"function": _parse_level_setting,
	},
	{
		"pattern": tile_code_regex,
		"function": _parse_tile_code,
	},
	{
		"pattern": level_chance_regex,
		"function": _parse_level_chance,
	},
	{
		"pattern": monster_chance_regex,
		"function": _parse_monster_chance,
	},
	{
		"pattern": template_type_regex,
		"function": _parse_template_type,
	},
	{
		"pattern": template_setting_regex,
		"function": _parse_template_setting,
	},
]


func load_file(path: String):
	_clear()
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		while not file.eof_reached():
			var line = file.get_line()
			_parse_line(line)
	# pretend to parse an empty line, to potentially complete the last template
	_parse_empty_line()
	_validate()


func _parse_line(line: String):
	if line_comment_regex.search(line):
		return
	for parse_fn in _parse_functions:
		var result: RegExMatch = parse_fn["pattern"].search(line)
		if result:
			var values = _split_string(result.get_string("value"))
			parse_fn["function"].call(values)
			return
			# print(str(parse_fn["function"]), values)
	var empty_line_regex = RegEx.new()
	empty_line_regex.compile("^\\s*$")
	if empty_line_regex.search(line):
		_parse_empty_line()
	else:
		_parse_template_tiles(line)


func _clear():
	level_settings = {}
	tile_codes = {}
	level_chances = {}
	monster_chances = {}
	templates = {}
	_current_template_type = ''
	_template_complete = false


func _validate():
	assert(level_settings["size"], 'level setting "size" is mandatory')
	assert( \
		level_settings["size"].x > 0 and level_settings["size"].y > 0, \
		'level setting "size" must not be at least "1 1"' \
	)
	var _valid_template_types = [
		"entrance", # left, right open
		"entrance_drop", # left, right, bottom open
		"exit", # left, right open
		"exit_notop", # left, right, top open
		"side", # not on the critical path
		"path_normal", # left, right open
		"path_notop", # left, right, top open
		"path_drop", # left, right, bottom open
		"path_drop_notop", # top, bottom open
		"idol_top", # room above idol (not traversable in dwelling until idol is taken)
		"idol", # left, right open
		"coffin_player", # left, right open
		"coffin_player_vertical", # left, right, top open
		"coffin_unlockable", # left, right open
		"udjatentrance", # left, right open
		"udjattop", # top part of udjat cave
		"machine_bigroom_path",
		"machine_bigroom_side",
		"machine_wideroom_path",
		"machine_wideroom_side",
		"machine_tallroom_path",
		"machine_tallroom_side",
		"machine_keyroom",
		"machine_rewardroom",
		"pen_room", # Yang and his turkeys (left, right open)
		"chunk_door",
		"chunk_ground",
		"chunk_air"
	]


func _parse_level_setting(values: Array[String]):
	var setting_name = values[0]
	var args = values.slice(1)
	var setting: Variant
	if setting_name == 'size':
		assert(args.size() == 2, 'level setting "size" must contain 2 arguments')
		setting = Vector2i(int(args[0]), int(args[1]))
	else:
		assert(args.size() == 1, "level settings must contain 1 argument")
		if setting_name == 'liquid_gravity':
			setting = float(args[0])
		else:
			setting = int(args[0])
	level_settings[setting_name] = setting
	if debug_logging: print('level_setting: ', setting_name, ', value: ', setting)


func _parse_tile_code(values: Array[String]):
	var tile_and_chance = values[0]
	var tile_code = values[1]
	var tile_parts = tile_and_chance.split('%')
	var tile_name = tile_parts[0]
	var chance = int(tile_parts[1]) if tile_parts.size() == 2 else 100
	tile_codes[tile_code] = {
		'name': tile_name,
		'chance': chance,
	}
	if debug_logging:
		var chance_str = '' if chance == 100 else " (" + chance + "%)"
		print('tile_code "', tile_code, '" stands for ', tile_name, chance_str)


func _parse_level_chance(values: Array[String]):
	var chance_name = values[0]
	var args = values.slice(1)
	assert(args.size() == 1 or args.size() == 4, "level chances must contain 1 or 4 arguments")
	args = _to_int_list(args) # sometimes %, sometimes 1/n
	level_chances[chance_name] = args
	if debug_logging: print('level_chance: ', chance_name, ', args: ', args)


func _parse_monster_chance(values: Array[String]):
	var monster = values[0]
	var args = values.slice(1)
	assert(args.size() == 1 or args.size() == 4, "monster chances must contain 1 or 4 arguments")
	args = _to_int_list(args) # sometimes %, sometimes 1/n
	monster_chances[monster] = args
	if debug_logging: print('monster_chance: ', monster, ', args: ', args)


func _new_template() -> Dictionary:
	var template = {
		"settings": [],
		"tiles": [],
	}
	templates[_current_template_type].append(template)
	_template_complete = false
	return template


func _parse_template_type(values: Array[String]):
	assert(values.size() == 1, "template type must not contain arguments")
	_current_template_type = values[0]
	templates[_current_template_type] = []
	if debug_logging: print('template_type: ', _current_template_type)


func _parse_template_setting(values: Array[String]):
	assert(values.size() == 1, "template settings must not contain arguments")
	var setting = values[0]
	assert(not templates.is_empty(), "a template type must be given first")
	var template: Dictionary
	if templates[_current_template_type].is_empty():
		template = _new_template()
	else:
		template = templates[_current_template_type].back()
		if not (template["tiles"] as Array).is_empty():
			template = _new_template()
	template["settings"].append(setting)
	if debug_logging: print('template_setting: ', setting)


func _parse_template_tiles(line: String):
	assert(not templates.is_empty(), "a template type must be given first")
	var template: Dictionary
	if _template_complete:
		template = _new_template()
	else:
		template = templates[_current_template_type].back()
	(template["tiles"] as Array).append(line.split())
	if debug_logging: print('template_tiles: ', line)


func _parse_empty_line():
	if templates.is_empty() or templates[_current_template_type].is_empty():
		return
	var template = templates[_current_template_type].back()
	if not (template["tiles"] as Array).is_empty() and not _template_complete:
		_template_complete = true
		if debug_logging: print('template complete')


func _to_int_list(list: Array[String]) -> Array[int]:
	var int_only_regex = RegEx.new()
	int_only_regex.compile("^\\d+$")
	var int_list: Array[int] = []
	for e in list:
		assert(int_only_regex.search(e), "only integer arguments accepted")
		int_list.append(int(e))
	return int_list


func _to_float_list(list: Array[String]) -> Array[float]:
	var float_only_regex = RegEx.new()
	float_only_regex.compile("^\\d+\\.?\\d*$")
	var float_list: Array[float] = []
	for e in list:
		assert(float_only_regex.search(e), "only float arguments accepted")
		float_list.append(float(e))
	return float_list


# split by spaces, tabs and commas
# commas are luckily never used as tile codes in the real game
func _split_string(to_split: String) -> Array[String]:
	var split_string_regex = RegEx.new()
	split_string_regex.compile("[^,\\s]+")
	var splitted: Array[String] = []
	for m in split_string_regex.search_all(to_split):
		splitted.append(m.get_string())
	return splitted
