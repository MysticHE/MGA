class_name EventBusClass
extends Node
## Global event bus for decoupled component communication.
## All game events flow through here using Godot signals.

# ═══════════════════════════════════════════════════════════════════════════════
# GAME STATE SIGNALS
# ═══════════════════════════════════════════════════════════════════════════════

## Emitted when the game has finished initial loading
signal game_started()

## Emitted when the game is paused/resumed
signal game_paused(is_paused: bool)

## Emitted when transitioning between screens
signal screen_changed(from_screen: String, to_screen: String)

# ═══════════════════════════════════════════════════════════════════════════════
# ECONOMY SIGNALS
# ═══════════════════════════════════════════════════════════════════════════════

## Emitted when gems change (for UI updates)
signal gems_changed(new_total: int, delta: int)

## Emitted when premium gems change
signal premium_gems_changed(new_total: int, delta: int)

## Emitted when trying to spend more than available
signal currency_insufficient(currency_type: String, needed: int, available: int)

## Emitted when idle gems are generated
signal idle_gems_generated(amount: int)

# ═══════════════════════════════════════════════════════════════════════════════
# HERO SIGNALS
# ═══════════════════════════════════════════════════════════════════════════════

## Emitted when a new hero is obtained (gacha or reward)
signal hero_obtained(hero_id: String, rarity: String, is_duplicate: bool)

## Emitted when a hero levels up
signal hero_leveled_up(hero_id: String, new_level: int)

## Emitted when hero equipment changes
signal hero_equipped(hero_id: String, slot: String, equipment_id: String)

## Emitted when team composition changes
signal team_changed(team_slots: Array)

# ═══════════════════════════════════════════════════════════════════════════════
# GACHA SIGNALS
# ═══════════════════════════════════════════════════════════════════════════════

## Emitted when a gacha pull is completed (single or multi)
signal gacha_pull_completed(results: Array)

## Emitted when pity counter updates
signal pity_updated(counter: int, guaranteed_featured: bool)

## Emitted when banner changes or expires
signal banner_updated(banner_id: String, time_remaining: int)

# ═══════════════════════════════════════════════════════════════════════════════
# RIFT SIGNALS
# ═══════════════════════════════════════════════════════════════════════════════

## Emitted when a rift run starts
signal rift_started(rift_id: String, floor_count: int)

## Emitted when a floor is completed
signal rift_floor_completed(floor_num: int, gems_earned: int)

## Emitted when rift run ends
signal rift_finished(victory: bool, total_gems: int, floors_cleared: int)

## Emitted when rift energy changes
signal rift_energy_changed(current: int, max_energy: int)

## Emitted when path choice is available
signal rift_path_choice_available(paths: Array)

# ═══════════════════════════════════════════════════════════════════════════════
# COMBAT SIGNALS
# ═══════════════════════════════════════════════════════════════════════════════

## Emitted each combat tick for UI updates
signal combat_tick(team_hp: Array, enemy_hp: Array)

## Emitted when combat starts
signal combat_started()

## Emitted when combat ends
signal combat_finished(victory: bool)

# ═══════════════════════════════════════════════════════════════════════════════
# FARM SIGNALS
# ═══════════════════════════════════════════════════════════════════════════════

## Emitted when farm level increases
signal farm_leveled_up(new_level: int)

## Emitted when farm visual evolution triggers
signal farm_evolved(evolution_stage: int)

# ═══════════════════════════════════════════════════════════════════════════════
# ALCHEMY SIGNALS
# ═══════════════════════════════════════════════════════════════════════════════

## Emitted when essence is crafted
signal essence_crafted(essence_type: String, amount: int)

## Emitted when recipe is unlocked
signal recipe_unlocked(recipe_id: String)

# ═══════════════════════════════════════════════════════════════════════════════
# CHRONICLE SIGNALS
# ═══════════════════════════════════════════════════════════════════════════════

## Emitted when chapter is unlocked
signal chapter_unlocked(chapter_id: String)

## Emitted when quest is completed
signal quest_completed(quest_id: String, rewards: Dictionary)

# ═══════════════════════════════════════════════════════════════════════════════
# EXPEDITION SIGNALS
# ═══════════════════════════════════════════════════════════════════════════════

## Emitted when expedition is started
signal expedition_started(expedition_id: String, hero_ids: Array)

## Emitted when expedition completes
signal expedition_completed(expedition_id: String, rewards: Dictionary)

# ═══════════════════════════════════════════════════════════════════════════════
# UI SIGNALS
# ═══════════════════════════════════════════════════════════════════════════════

## Emitted to show loading overlay
signal show_loading(message: String)

## Emitted to hide loading overlay
signal hide_loading()

## Emitted to show a popup
signal show_popup(popup_type: String, data: Dictionary)

## Emitted for toast notifications
signal show_toast(message: String, toast_type: String)

# ═══════════════════════════════════════════════════════════════════════════════
# SAVE/SYNC SIGNALS
# ═══════════════════════════════════════════════════════════════════════════════

## Emitted when save is completed
signal save_completed(success: bool)

## Emitted when save is loaded
signal load_completed(success: bool)

## Emitted when server sync completes
signal sync_completed(success: bool)

## Emitted when offline data is queued
signal offline_action_queued(action_type: String)

# ═══════════════════════════════════════════════════════════════════════════════
# PRIVACY/CONSENT SIGNALS
# ═══════════════════════════════════════════════════════════════════════════════

## Emitted when consent is updated
signal consent_updated(consents: Dictionary)

## Emitted when consent dialog needs to be shown
signal consent_required()

## Emitted when data export is ready
signal data_export_ready(export_path: String)

# ═══════════════════════════════════════════════════════════════════════════════
# NETWORK SIGNALS
# ═══════════════════════════════════════════════════════════════════════════════

## Emitted when connection status changes
signal connection_changed(is_online: bool)

## Emitted on server error
signal server_error(error_code: int, message: String)
