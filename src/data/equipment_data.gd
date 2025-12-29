class_name EquipmentData
extends Resource
## Static equipment definition data for hero gear.
## Provides stat bonuses when equipped to heroes.

@export_group("Identity")
@export var id: String = ""  # Unique identifier (e.g., "weapon_fire_sword")
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D

@export_group("Classification")
@export var slot: GameEnums.EquipmentSlot = GameEnums.EquipmentSlot.WEAPON
@export var rarity: GameEnums.EquipmentRarity = GameEnums.EquipmentRarity.COMMON
@export var required_level: int = 1  # Hero level required to equip

@export_group("Base Stats")
@export var hp_bonus: int = 0
@export var atk_bonus: int = 0
@export var def_bonus: int = 0
@export var spd_bonus: int = 0
@export var crit_rate_bonus: float = 0.0
@export var crit_dmg_bonus: float = 0.0

@export_group("Enhancement")
@export var max_enhance_level: int = 15
@export var enhance_stat_multiplier: float = 0.1  # 10% per level

@export_group("Set Bonus")
@export var set_id: String = ""  # Equipment set this belongs to
@export var set_pieces_required: int = 2  # Pieces needed for set bonus

@export_group("Restrictions")
@export var hero_element_restriction: GameEnums.Element = GameEnums.Element.NEUTRAL  # NEUTRAL = any
@export var hero_role_restriction: GameEnums.HeroRole = GameEnums.HeroRole.DPS  # Only used if has_role_restriction
@export var has_role_restriction: bool = false


## Calculates stats at a given enhancement level
func get_stats_at_level(enhance_level: int) -> Dictionary:
	var multiplier: float = 1.0 + (enhance_stat_multiplier * enhance_level)
	return {
		GameEnums.Stat.HP: int(hp_bonus * multiplier),
		GameEnums.Stat.ATK: int(atk_bonus * multiplier),
		GameEnums.Stat.DEF: int(def_bonus * multiplier),
		GameEnums.Stat.SPD: int(spd_bonus * multiplier),
		GameEnums.Stat.CRIT_RATE: crit_rate_bonus * multiplier,
		GameEnums.Stat.CRIT_DMG: crit_dmg_bonus * multiplier,
	}


## Gets slot display name
func get_slot_name() -> String:
	match slot:
		GameEnums.EquipmentSlot.WEAPON: return "Weapon"
		GameEnums.EquipmentSlot.ARMOR: return "Armor"
		GameEnums.EquipmentSlot.ACCESSORY: return "Accessory"
		_: return "Unknown"


## Gets rarity display name
func get_rarity_name() -> String:
	match rarity:
		GameEnums.EquipmentRarity.COMMON: return "Common"
		GameEnums.EquipmentRarity.UNCOMMON: return "Uncommon"
		GameEnums.EquipmentRarity.RARE: return "Rare"
		GameEnums.EquipmentRarity.EPIC: return "Epic"
		GameEnums.EquipmentRarity.LEGENDARY: return "Legendary"
		_: return "Unknown"


## Checks if a hero can equip this item
func can_equip(hero_data: HeroData, hero_level: int) -> bool:
	if hero_level < required_level:
		return false

	if hero_element_restriction != GameEnums.Element.NEUTRAL:
		if hero_data.element != hero_element_restriction:
			return false

	if has_role_restriction:
		if hero_data.role != hero_role_restriction:
			return false

	return true


## Validates equipment data is complete
func is_valid() -> bool:
	if id.is_empty():
		return false
	if display_name.is_empty():
		return false
	return true
