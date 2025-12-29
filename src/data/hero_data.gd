class_name HeroData
extends Resource
## Static hero definition data (template).
## Instance data (level, exp) stored in SaveData.

@export_group("Identity")
@export var id: String = ""  # Unique identifier (e.g., "hero_fire_knight")
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var portrait: Texture2D

@export_group("Classification")
@export var rarity: GameEnums.Rarity = GameEnums.Rarity.COMMON
@export var element: GameEnums.Element = GameEnums.Element.NEUTRAL
@export var role: GameEnums.HeroRole = GameEnums.HeroRole.DPS

@export_group("Base Stats (Level 1)")
@export var base_hp: int = 100
@export var base_atk: int = 10
@export var base_def: int = 5
@export var base_spd: int = 100
@export var base_crit_rate: float = 0.05  # 5%
@export var base_crit_dmg: float = 1.5    # 150%

@export_group("Growth (per level)")
@export var hp_growth: float = 10.0
@export var atk_growth: float = 2.0
@export var def_growth: float = 1.0
@export var spd_growth: float = 0.5

@export_group("Skills")
@export var skill_ids: Array[String] = []  # References to skill data

@export_group("Gacha")
@export var is_limited: bool = false  # Only in limited banners
@export var release_banner: String = ""  # Banner ID when released

@export_group("Farm Bonus")
@export var farm_gem_bonus: float = 0.0  # % bonus to gem generation when assigned
@export var preferred_crop_type: String = ""  # Gets extra bonus with this crop


## Calculates stats at a given level
func get_stats_at_level(level: int) -> Dictionary:
	var lvl_modifier: float = level - 1
	return {
		GameEnums.Stat.HP: int(base_hp + (hp_growth * lvl_modifier)),
		GameEnums.Stat.ATK: int(base_atk + (atk_growth * lvl_modifier)),
		GameEnums.Stat.DEF: int(base_def + (def_growth * lvl_modifier)),
		GameEnums.Stat.SPD: int(base_spd + (spd_growth * lvl_modifier)),
		GameEnums.Stat.CRIT_RATE: base_crit_rate,
		GameEnums.Stat.CRIT_DMG: base_crit_dmg,
	}


## Gets the star rating display
func get_stars() -> int:
	return GameEnums.rarity_to_stars(rarity)


## Gets element as string for display
func get_element_name() -> String:
	return GameEnums.element_to_string(element)


## Gets rarity as string for display
func get_rarity_name() -> String:
	return GameEnums.rarity_to_string(rarity)


## Validates hero data is complete
func is_valid() -> bool:
	if id.is_empty():
		return false
	if display_name.is_empty():
		return false
	if base_hp <= 0 or base_atk <= 0:
		return false
	return true
