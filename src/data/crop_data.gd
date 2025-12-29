class_name CropData
extends Resource
## Static crop definition data for the farm system.
## Defines growth time, gem yield, and visual assets.

@export_group("Identity")
@export var id: String = ""  # Unique identifier (e.g., "crop_gem_sprout")
@export var display_name: String = ""
@export var description: String = ""

@export_group("Visuals")
@export var seed_icon: Texture2D
@export var sprout_icon: Texture2D
@export var growing_icon: Texture2D
@export var mature_icon: Texture2D
@export var withered_icon: Texture2D

@export_group("Classification")
@export var tier: GameEnums.CropTier = GameEnums.CropTier.BASIC
@export var element: GameEnums.Element = GameEnums.Element.NEUTRAL  # Matches hero elements

@export_group("Growth")
@export var growth_time_seconds: int = 300  # Time to fully grow (5 min default)
@export var wither_time_seconds: int = 600  # Time before withering after mature
@export var stages: int = 4  # Number of visual growth stages

@export_group("Yield")
@export var base_gem_yield: int = 10  # Gems on harvest
@export var gem_yield_variance: float = 0.2  # ±20% randomness
@export var bonus_drop_chance: float = 0.1  # Chance for bonus items
@export var bonus_drop_id: String = ""  # What bonus item drops

@export_group("Requirements")
@export var unlock_level: int = 1  # Player level to unlock
@export var seed_cost: int = 0  # Cost to plant (0 = free)
@export var requires_premium: bool = false  # Premium currency only

@export_group("Synergies")
@export var preferred_hero_elements: Array[int] = []  # Elements that boost yield
@export var element_bonus: float = 0.25  # 25% bonus with matching hero


## Calculates actual gem yield with variance
func calculate_yield(hero_bonus: float = 0.0) -> int:
	var base: float = base_gem_yield

	# Apply hero bonus
	base *= (1.0 + hero_bonus)

	# Apply variance
	var variance: float = randf_range(-gem_yield_variance, gem_yield_variance)
	base *= (1.0 + variance)

	return maxi(1, int(base))


## Gets growth time per stage in seconds
func get_stage_duration() -> float:
	return float(growth_time_seconds) / float(stages)


## Checks if crop should wither based on time since maturity
func should_wither(seconds_since_mature: int) -> bool:
	return seconds_since_mature >= wither_time_seconds


## Gets the current growth stage based on elapsed time
func get_growth_stage(elapsed_seconds: int) -> GameEnums.GrowthStage:
	if elapsed_seconds <= 0:
		return GameEnums.GrowthStage.SEED

	var progress: float = float(elapsed_seconds) / float(growth_time_seconds)

	if progress < 0.25:
		return GameEnums.GrowthStage.SPROUT
	elif progress < 0.5:
		return GameEnums.GrowthStage.GROWING
	elif progress < 1.0:
		return GameEnums.GrowthStage.MATURE
	else:
		return GameEnums.GrowthStage.HARVESTABLE


## Gets tier display name
func get_tier_name() -> String:
	match tier:
		GameEnums.CropTier.BASIC: return "Basic"
		GameEnums.CropTier.IMPROVED: return "Improved"
		GameEnums.CropTier.PREMIUM: return "Premium"
		GameEnums.CropTier.MYTHIC: return "Mythic"
		_: return "Unknown"


## Validates crop data is complete
func is_valid() -> bool:
	if id.is_empty():
		return false
	if display_name.is_empty():
		return false
	if growth_time_seconds <= 0:
		return false
	if base_gem_yield <= 0:
		return false
	return true
