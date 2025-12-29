class_name GameEnums
extends RefCounted
## Centralized game enumerations for type-safe data definitions.
## Used across all resource definitions and game systems.

# ═══════════════════════════════════════════════════════════════════════════════
# HERO ENUMS
# ═══════════════════════════════════════════════════════════════════════════════

## Hero rarity tiers (affects stats, gacha rates)
enum Rarity {
	COMMON,      # 1-star, 60% gacha rate
	UNCOMMON,    # 2-star, 25% gacha rate
	RARE,        # 3-star, 10% gacha rate
	EPIC,        # 4-star, 4% gacha rate
	LEGENDARY,   # 5-star, 1% gacha rate (pity at 90)
}

## Hero elemental types (rock-paper-scissors combat)
enum Element {
	FIRE,    # Strong vs Nature, weak vs Water
	WATER,   # Strong vs Fire, weak vs Nature
	NATURE,  # Strong vs Water, weak vs Fire
	LIGHT,   # Strong vs Dark
	DARK,    # Strong vs Light
	NEUTRAL, # No advantage/disadvantage
}

## Hero combat roles
enum HeroRole {
	TANK,      # High HP, taunt abilities
	DPS,       # High damage output
	SUPPORT,   # Healing, buffs
	CONTROL,   # CC, debuffs
}

## Hero stat types
enum Stat {
	HP,
	ATK,
	DEF,
	SPD,
	CRIT_RATE,
	CRIT_DMG,
}

# ═══════════════════════════════════════════════════════════════════════════════
# CROP ENUMS
# ═══════════════════════════════════════════════════════════════════════════════

## Crop tiers (affects growth time, gem yield)
enum CropTier {
	BASIC,      # Fast growth, low yield
	IMPROVED,   # Medium growth, medium yield
	PREMIUM,    # Slow growth, high yield
	MYTHIC,     # Very slow, very high yield
}

## Crop growth stages
enum GrowthStage {
	SEED,
	SPROUT,
	GROWING,
	MATURE,
	HARVESTABLE,
	WITHERED,  # If not harvested in time
}

# ═══════════════════════════════════════════════════════════════════════════════
# EQUIPMENT ENUMS
# ═══════════════════════════════════════════════════════════════════════════════

## Equipment slots
enum EquipmentSlot {
	WEAPON,
	ARMOR,
	ACCESSORY,
}

## Equipment rarity (same as hero for consistency)
enum EquipmentRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY,
}

# ═══════════════════════════════════════════════════════════════════════════════
# GACHA ENUMS
# ═══════════════════════════════════════════════════════════════════════════════

## Banner types
enum BannerType {
	STANDARD,     # Permanent, all heroes
	LIMITED,      # Time-limited, featured hero
	ELEMENTAL,    # Specific element rate-up
}

# ═══════════════════════════════════════════════════════════════════════════════
# GAME MODE ENUMS
# ═══════════════════════════════════════════════════════════════════════════════

## Rift floor types
enum RiftFloorType {
	COMBAT,       # Fight enemies
	TREASURE,     # Bonus loot
	ELITE,        # Harder fight, better rewards
	BOSS,         # Floor 10, 20, 30 bosses
	REST,         # Heal between floors
	EVENT,        # Random event
}

## Expedition types
enum ExpeditionType {
	GATHER,       # Resource gathering
	EXPLORE,      # Discovery, rare drops
	HUNT,         # Combat focus, hero exp
}

## Chronicle difficulty
enum Difficulty {
	NORMAL,
	HARD,
	NIGHTMARE,
}

# ═══════════════════════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

## Converts rarity enum to display string
static func rarity_to_string(rarity: Rarity) -> String:
	match rarity:
		Rarity.COMMON: return "Common"
		Rarity.UNCOMMON: return "Uncommon"
		Rarity.RARE: return "Rare"
		Rarity.EPIC: return "Epic"
		Rarity.LEGENDARY: return "Legendary"
		_: return "Unknown"

## Converts rarity to star count
static func rarity_to_stars(rarity: Rarity) -> int:
	return rarity + 1

## Converts element enum to display string
static func element_to_string(element: Element) -> String:
	match element:
		Element.FIRE: return "Fire"
		Element.WATER: return "Water"
		Element.NATURE: return "Nature"
		Element.LIGHT: return "Light"
		Element.DARK: return "Dark"
		Element.NEUTRAL: return "Neutral"
		_: return "Unknown"

## Gets element advantage multiplier
static func get_element_multiplier(attacker: Element, defender: Element) -> float:
	# Advantage = 1.3x, Disadvantage = 0.7x, Neutral = 1.0x
	match attacker:
		Element.FIRE:
			if defender == Element.NATURE: return 1.3
			if defender == Element.WATER: return 0.7
		Element.WATER:
			if defender == Element.FIRE: return 1.3
			if defender == Element.NATURE: return 0.7
		Element.NATURE:
			if defender == Element.WATER: return 1.3
			if defender == Element.FIRE: return 0.7
		Element.LIGHT:
			if defender == Element.DARK: return 1.3
		Element.DARK:
			if defender == Element.LIGHT: return 1.3
	return 1.0
