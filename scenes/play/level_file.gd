extends Node2D
class_name LevelFile

@export var debug_logging: bool = false

var line_comment_regex = RegEx.new()
var level_setting_regex = RegEx.new()
var tile_code_regex = RegEx.new()
var level_chance_regex = RegEx.new()
var monster_chance_regex = RegEx.new()
var template_placement_regex = RegEx.new()
var template_setting_regex = RegEx.new()

func _ready():
	line_comment_regex.compile("^\\/\\/") # //
	var value_pattern = "(?<value>(?:(?!\\/\\/).)*)"
	level_setting_regex.compile("^\\\\-" + value_pattern) # \-
	tile_code_regex.compile("^\\\\\\?" + value_pattern) # \?
	level_chance_regex.compile("^\\\\%" + value_pattern) # \%
	monster_chance_regex.compile("^\\\\\\+" + value_pattern) # \+
	template_placement_regex.compile("^\\\\\\." + value_pattern) # \.
	template_setting_regex.compile("^\\\\!" + value_pattern) # \!
	load_file('res://levels/dwellingarea.lvl')

var level_settings: Dictionary = {}
var tile_codes: Dictionary = {}
var level_chances: Dictionary = {}
var monster_chances: Dictionary = {}
var templates: Array[Dictionary] = []

func parse_level_setting(values: Array[String]):
	var setting = values[0]
	var args = values.slice(1)
	if setting == 'size':
		assert(args.size() == 2, 'level setting "size" must contain 2 arguments')
	else:
		assert(args.size() == 1, "level settings must contain 1 argument")
	if setting == 'liquid_gravity':
		args = _to_float_list(args)
	else:
		args = _to_int_list(args)
	level_settings[setting] = args
	if debug_logging: print('level_setting: ', setting, ', args: ', args)


func parse_tile_code(values: Array[String]):
	var tile = values[0]
	var args = values.slice(1)
	assert(args.size() == 1, "tile codes must contain 1 argument")
	tile_codes[tile] = args
	if debug_logging: print('tile_code: ', tile, ', args: ', args)


func parse_level_chance(values: Array[String]):
	var chance_name = values[0]
	var args = values.slice(1)
	assert(args.size() == 1 or args.size() == 4, "level chances must contain 1 or 4 arguments")
	args = _to_int_list(args) # sometimes %, sometimes 1/n
	level_chances[chance_name] = args
	if debug_logging: print('level_chance: ', chance_name, ', args: ', args)


func parse_monster_chance(values: Array[String]):
	var monster = values[0]
	var args = values.slice(1)
	assert(args.size() == 1 or args.size() == 4, "monster chances must contain 1 or 4 arguments")
	args = _to_int_list(args) # sometimes %, sometimes 1/n
	monster_chances[monster] = args
	if debug_logging: print('monster_chance: ', monster, ', args: ', args)


func _new_template_with_placement(placement: String) -> Dictionary:
	var template = {
		"placement": placement,
		"settings": [],
		"tiles": [],
		"complete": false,
	}
	templates.append(template)
	return template


func parse_template_placement(values: Array[String]):
	assert(values.size() == 1, "template placements must not contain arguments")
	var placement = values[0]
	var _template = _new_template_with_placement(placement)
	if debug_logging: print('template_placement: ', placement)


func parse_template_setting(values: Array[String]):
	assert(values.size() == 1, "template settings must not contain arguments")
	var setting = values[0]
	var template = templates.back()
	assert(template["tiles"].is_empty(), "templates must be separated by a space")
	template["settings"].append(setting)
	if debug_logging: print('template_setting: ', setting)


func parse_template_tiles(line: String):
	var template = templates.back()
	(template["tiles"] as Array).append(line.split())
	if debug_logging: print('template_tiles: ', line)


func parse_empty_line():
	if templates.is_empty():
		return
	var template = templates.back()
	if not template["complete"]:
		template["complete"] = true
		_new_template_with_placement(template["placement"])
		if debug_logging: print('template complete')


var parse_functions = [
	{
		"pattern": level_setting_regex,
		"function": parse_level_setting,
	},
	{
		"pattern": tile_code_regex,
		"function": parse_tile_code,
	},
	{
		"pattern": level_chance_regex,
		"function": parse_level_chance,
	},
	{
		"pattern": monster_chance_regex,
		"function": parse_monster_chance,
	},
	{
		"pattern": template_placement_regex,
		"function": parse_template_placement,
	},
	{
		"pattern": template_setting_regex,
		"function": parse_template_setting,
	},
]


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


func parse_line(line: String):
	if line_comment_regex.search(line):
		return
	for parse_fn in parse_functions:
		var result: RegExMatch = parse_fn["pattern"].search(line)
		if result:
			var values = _split_string(result.get_string("value"))
			parse_fn["function"].call(values)
			return
			# print(str(parse_fn["function"]), values)
	var empty_line_regex = RegEx.new()
	empty_line_regex.compile("^\\s*$")
	if empty_line_regex.search(line):
		parse_empty_line()
	else:
		parse_template_tiles(line)


func load_file(path: String):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		while not file.eof_reached():
			var line = file.get_line()
			parse_line(line)
	# pretend to parse an empty line, to potentially complete the last template
	parse_empty_line()
