class_name SaveData
extends Resource
## Container for all player save data.
## Serializable resource for encrypted persistence.

## Save format version for migration support
const SAVE_VERSION: int = 1

## Metadata
@export var save_version: int = SAVE_VERSION
@export var created_at: int = 0  # Unix timestamp
@export var updated_at: int = 0  # Unix timestamp
@export var play_time_seconds: int = 0
@export var last_online_time: int = 0  # For offline earnings

## Currency
@export var gems: int = 0
@export var premium_gems: int = 0
@export var gold: int = 0
@export var essence: int = 0

## Player progression
@export var player_level: int = 1
@export var player_exp: int = 0
@export var tutorial_completed: bool = false
@export var tutorial_step: int = 0

## Farm state
@export var farm_plots: Array[Dictionary] = []
@export var unlocked_plot_count: int = 4

## Hero roster (stored as dictionaries for flexibility)
@export var heroes: Array[Dictionary] = []
@export var hero_slots: int = 50

## Gacha pity counters
@export var standard_pity: int = 0
@export var premium_pity: int = 0
@export var guarantee_next: bool = false

## Expedition state
@export var expedition_slots: Array[Dictionary] = []
@export var expedition_unlocked: int = 1

## Chronicle progress
@export var chronicle_chapter: int = 1
@export var chronicle_stage: int = 1
@export var chronicle_stars: Dictionary = {}

## Rift progress
@export var rift_highest_floor: int = 0
@export var rift_weekly_attempts: int = 0

## Alchemy recipes unlocked
@export var unlocked_recipes: Array[String] = []

## Settings
@export var settings: Dictionary = {
	"music_volume": 1.0,
	"sfx_volume": 1.0,
	"notifications_enabled": true,
	"auto_battle_speed": 1,
}

## Statistics for achievements
@export var stats: Dictionary = {
	"total_gems_earned": 0,
	"total_heroes_summoned": 0,
	"total_battles_won": 0,
	"total_crops_harvested": 0,
}


## Creates a new save with default values
static func create_new() -> SaveData:
	var save: SaveData = SaveData.new()
	save.created_at = int(Time.get_unix_time_from_system())
	save.updated_at = save.created_at
	save.last_online_time = save.created_at

	# Initialize default farm plots
	for i in range(save.unlocked_plot_count):
		save.farm_plots.append({
			"plot_id": i,
			"crop_type": "",
			"planted_at": 0,
			"is_empty": true,
		})

	# Initialize expedition slots
	save.expedition_slots.append({
		"slot_id": 0,
		"hero_ids": [],
		"started_at": 0,
		"expedition_type": "",
		"is_active": false,
	})

	return save


## Updates the last modified timestamp
func touch() -> void:
	updated_at = int(Time.get_unix_time_from_system())


## Calculates offline time in seconds
func get_offline_seconds() -> int:
	var now: int = int(Time.get_unix_time_from_system())
	return now - last_online_time


## Updates online timestamp (call when player returns)
func mark_online() -> void:
	last_online_time = int(Time.get_unix_time_from_system())


## Converts to dictionary for JSON serialization
func to_dict() -> Dictionary:
	return {
		"save_version": save_version,
		"created_at": created_at,
		"updated_at": updated_at,
		"play_time_seconds": play_time_seconds,
		"last_online_time": last_online_time,
		"gems": gems,
		"premium_gems": premium_gems,
		"gold": gold,
		"essence": essence,
		"player_level": player_level,
		"player_exp": player_exp,
		"tutorial_completed": tutorial_completed,
		"tutorial_step": tutorial_step,
		"farm_plots": farm_plots,
		"unlocked_plot_count": unlocked_plot_count,
		"heroes": heroes,
		"hero_slots": hero_slots,
		"standard_pity": standard_pity,
		"premium_pity": premium_pity,
		"guarantee_next": guarantee_next,
		"expedition_slots": expedition_slots,
		"expedition_unlocked": expedition_unlocked,
		"chronicle_chapter": chronicle_chapter,
		"chronicle_stage": chronicle_stage,
		"chronicle_stars": chronicle_stars,
		"rift_highest_floor": rift_highest_floor,
		"rift_weekly_attempts": rift_weekly_attempts,
		"unlocked_recipes": unlocked_recipes,
		"settings": settings,
		"stats": stats,
	}


## Loads from dictionary (JSON deserialization)
static func from_dict(data: Dictionary) -> SaveData:
	var save: SaveData = SaveData.new()

	# Metadata
	save.save_version = data.get("save_version", SAVE_VERSION)
	save.created_at = data.get("created_at", 0)
	save.updated_at = data.get("updated_at", 0)
	save.play_time_seconds = data.get("play_time_seconds", 0)
	save.last_online_time = data.get("last_online_time", 0)

	# Currency
	save.gems = data.get("gems", 0)
	save.premium_gems = data.get("premium_gems", 0)
	save.gold = data.get("gold", 0)
	save.essence = data.get("essence", 0)

	# Progression
	save.player_level = data.get("player_level", 1)
	save.player_exp = data.get("player_exp", 0)
	save.tutorial_completed = data.get("tutorial_completed", false)
	save.tutorial_step = data.get("tutorial_step", 0)

	# Farm
	save.farm_plots = _convert_to_array_dict(data.get("farm_plots", []))
	save.unlocked_plot_count = data.get("unlocked_plot_count", 4)

	# Heroes
	save.heroes = _convert_to_array_dict(data.get("heroes", []))
	save.hero_slots = data.get("hero_slots", 50)

	# Gacha
	save.standard_pity = data.get("standard_pity", 0)
	save.premium_pity = data.get("premium_pity", 0)
	save.guarantee_next = data.get("guarantee_next", false)

	# Expedition
	save.expedition_slots = _convert_to_array_dict(data.get("expedition_slots", []))
	save.expedition_unlocked = data.get("expedition_unlocked", 1)

	# Chronicle
	save.chronicle_chapter = data.get("chronicle_chapter", 1)
	save.chronicle_stage = data.get("chronicle_stage", 1)
	save.chronicle_stars = data.get("chronicle_stars", {})

	# Rift
	save.rift_highest_floor = data.get("rift_highest_floor", 0)
	save.rift_weekly_attempts = data.get("rift_weekly_attempts", 0)

	# Alchemy
	save.unlocked_recipes = _convert_to_array_string(data.get("unlocked_recipes", []))

	# Settings & Stats
	save.settings = data.get("settings", save.settings)
	save.stats = data.get("stats", save.stats)

	return save


## Helper to convert Array to Array[Dictionary]
static func _convert_to_array_dict(arr: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item in arr:
		if item is Dictionary:
			result.append(item)
	return result


## Helper to convert Array to Array[String]
static func _convert_to_array_string(arr: Array) -> Array[String]:
	var result: Array[String] = []
	for item in arr:
		if item is String:
			result.append(item)
	return result
