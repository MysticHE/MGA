class_name GameDatabaseClass
extends Node
## Central database for all static game data.
## Loads and caches hero, crop, and equipment definitions.

const HEROES_PATH: String = "res://data/heroes/"
const CROPS_PATH: String = "res://data/crops/"
const EQUIPMENT_PATH: String = "res://data/equipment/"

signal database_loaded()
signal load_error(message: String)

var _heroes: Dictionary = {}      # id -> HeroData
var _crops: Dictionary = {}       # id -> CropData
var _equipment: Dictionary = {}   # id -> EquipmentData
var _is_loaded: bool = false


func _ready() -> void:
	_load_all_data()


## Loads all game data from resource folders
func _load_all_data() -> void:
	print("[GameDatabase] Loading game data...")

	_load_heroes()
	_load_crops()
	_load_equipment()

	_is_loaded = true
	print("[GameDatabase] Loaded: ", _heroes.size(), " heroes, ",
		_crops.size(), " crops, ", _equipment.size(), " equipment")
	database_loaded.emit()


## Loads all hero definitions
func _load_heroes() -> void:
	_heroes.clear()
	var dir: DirAccess = DirAccess.open(HEROES_PATH)
	if dir == null:
		print("[GameDatabase] Heroes folder not found, skipping")
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var path: String = HEROES_PATH + file_name
			var hero: HeroData = load(path) as HeroData
			if hero and hero.is_valid():
				_heroes[hero.id] = hero
			else:
				push_warning("[GameDatabase] Invalid hero data: ", path)
		file_name = dir.get_next()
	dir.list_dir_end()


## Loads all crop definitions
func _load_crops() -> void:
	_crops.clear()
	var dir: DirAccess = DirAccess.open(CROPS_PATH)
	if dir == null:
		print("[GameDatabase] Crops folder not found, skipping")
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var path: String = CROPS_PATH + file_name
			var crop: CropData = load(path) as CropData
			if crop and crop.is_valid():
				_crops[crop.id] = crop
			else:
				push_warning("[GameDatabase] Invalid crop data: ", path)
		file_name = dir.get_next()
	dir.list_dir_end()


## Loads all equipment definitions
func _load_equipment() -> void:
	_equipment.clear()
	var dir: DirAccess = DirAccess.open(EQUIPMENT_PATH)
	if dir == null:
		print("[GameDatabase] Equipment folder not found, skipping")
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var path: String = EQUIPMENT_PATH + file_name
			var equip: EquipmentData = load(path) as EquipmentData
			if equip and equip.is_valid():
				_equipment[equip.id] = equip
			else:
				push_warning("[GameDatabase] Invalid equipment data: ", path)
		file_name = dir.get_next()
	dir.list_dir_end()


# ═══════════════════════════════════════════════════════════════════════════════
# HERO ACCESS
# ═══════════════════════════════════════════════════════════════════════════════

## Gets a hero by ID
func get_hero(hero_id: String) -> HeroData:
	return _heroes.get(hero_id, null)


## Gets all heroes
func get_all_heroes() -> Array[HeroData]:
	var result: Array[HeroData] = []
	for hero: HeroData in _heroes.values():
		result.append(hero)
	return result


## Gets heroes filtered by rarity
func get_heroes_by_rarity(rarity: GameEnums.Rarity) -> Array[HeroData]:
	var result: Array[HeroData] = []
	for hero: HeroData in _heroes.values():
		if hero.rarity == rarity:
			result.append(hero)
	return result


## Gets heroes filtered by element
func get_heroes_by_element(element: GameEnums.Element) -> Array[HeroData]:
	var result: Array[HeroData] = []
	for hero: HeroData in _heroes.values():
		if hero.element == element:
			result.append(hero)
	return result


## Gets non-limited heroes (for standard banner)
func get_standard_pool_heroes() -> Array[HeroData]:
	var result: Array[HeroData] = []
	for hero: HeroData in _heroes.values():
		if not hero.is_limited:
			result.append(hero)
	return result


# ═══════════════════════════════════════════════════════════════════════════════
# CROP ACCESS
# ═══════════════════════════════════════════════════════════════════════════════

## Gets a crop by ID
func get_crop(crop_id: String) -> CropData:
	return _crops.get(crop_id, null)


## Gets all crops
func get_all_crops() -> Array[CropData]:
	var result: Array[CropData] = []
	for crop: CropData in _crops.values():
		result.append(crop)
	return result


## Gets crops unlocked at player level
func get_unlocked_crops(player_level: int) -> Array[CropData]:
	var result: Array[CropData] = []
	for crop: CropData in _crops.values():
		if crop.unlock_level <= player_level and not crop.requires_premium:
			result.append(crop)
	return result


## Gets crops by tier
func get_crops_by_tier(tier: GameEnums.CropTier) -> Array[CropData]:
	var result: Array[CropData] = []
	for crop: CropData in _crops.values():
		if crop.tier == tier:
			result.append(crop)
	return result


# ═══════════════════════════════════════════════════════════════════════════════
# EQUIPMENT ACCESS
# ═══════════════════════════════════════════════════════════════════════════════

## Gets equipment by ID
func get_equipment(equip_id: String) -> EquipmentData:
	return _equipment.get(equip_id, null)


## Gets all equipment
func get_all_equipment() -> Array[EquipmentData]:
	var result: Array[EquipmentData] = []
	for equip: EquipmentData in _equipment.values():
		result.append(equip)
	return result


## Gets equipment by slot type
func get_equipment_by_slot(slot: GameEnums.EquipmentSlot) -> Array[EquipmentData]:
	var result: Array[EquipmentData] = []
	for equip: EquipmentData in _equipment.values():
		if equip.slot == slot:
			result.append(equip)
	return result


## Gets equipment by set ID
func get_equipment_set(set_id: String) -> Array[EquipmentData]:
	var result: Array[EquipmentData] = []
	for equip: EquipmentData in _equipment.values():
		if equip.set_id == set_id:
			result.append(equip)
	return result


# ═══════════════════════════════════════════════════════════════════════════════
# UTILITY
# ═══════════════════════════════════════════════════════════════════════════════

## Checks if database is fully loaded
func is_loaded() -> bool:
	return _is_loaded


## Gets total count of all data entries
func get_total_entries() -> int:
	return _heroes.size() + _crops.size() + _equipment.size()
