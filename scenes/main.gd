class_name MainScene
extends Control
## Main entry point for Gem Harvest Idle.
## Handles initialization sequence: consent -> load -> offline rewards -> game start.

const CONSENT_DIALOG_SCENE: String = "res://scenes/ui/popups/consent_dialog.tscn"

@onready var loading_label: Label = %LoadingLabel

var _consent_dialog: ConsentDialog

func _ready() -> void:
	_initialize_game()

func _initialize_game() -> void:
	_update_loading_status("Starting...")

	# Wait a frame for autoloads to initialize
	await get_tree().process_frame

	# Verify autoloads
	print("[Main] EventBus loaded: ", EventBus != null)
	print("[Main] EncryptionManager loaded: ", EncryptionManager != null)
	print("[Main] ConsentManager loaded: ", ConsentManager != null)
	print("[Main] SaveManager loaded: ", SaveManager != null)
	# GameDatabase checked at runtime to avoid parse-time issues
	var game_db: Node = get_node_or_null("/root/GameDatabase")
	print("[Main] GameDatabase loaded: ", game_db != null)

	# CRITICAL: Check consent BEFORE any data operations
	if ConsentManager.needs_consent():
		_update_loading_status("Privacy settings required...")
		await _show_consent_dialog()

	_update_loading_status("Initializing security...")
	await get_tree().process_frame

	# Test encryption (only if analytics consent given)
	if ConsentManager.has_consent(ConsentManager.ConsentType.ANALYTICS):
		_test_encryption()

	# Load or create save data
	_update_loading_status("Loading game data...")
	await get_tree().process_frame
	await _load_or_create_save()

	# Calculate offline earnings if returning player
	if SaveManager.current_save != null:
		var offline_seconds: int = SaveManager.current_save.get_offline_seconds()
		if offline_seconds > 60:  # Only show if away for > 1 minute
			_update_loading_status("Calculating offline rewards...")
			await get_tree().process_frame
			_show_offline_earnings(offline_seconds)
			SaveManager.current_save.mark_online()

	# Start auto-save
	SaveManager.start_auto_save()

	_update_loading_status("Gem Harvest Idle started!")
	print("[Main] Initialization complete")
	EventBus.game_started.emit()

## Shows the consent dialog and waits for user response
func _show_consent_dialog() -> void:
	print("[Main] Showing consent dialog")

	# Load and instantiate consent dialog
	var dialog_scene: PackedScene = load(CONSENT_DIALOG_SCENE)
	_consent_dialog = dialog_scene.instantiate() as ConsentDialog
	add_child(_consent_dialog)

	# Connect to consent signal
	_consent_dialog.consent_submitted.connect(_on_consent_submitted)

	# Show and wait
	_consent_dialog.show_dialog()

	# Wait until consent is recorded
	while ConsentManager.needs_consent():
		await get_tree().process_frame

	print("[Main] Consent received")

## Called when user submits consent choices
func _on_consent_submitted(consents: Dictionary) -> void:
	ConsentManager.record_consent(consents)

	# Clean up dialog
	if _consent_dialog:
		_consent_dialog.queue_free()
		_consent_dialog = null

## Tests encryption functionality
func _test_encryption() -> void:
	var test_data: String = "Test encryption: Gem Harvest Idle"
	var encrypted: String = EncryptionManager.encrypt_string(test_data)
	var decrypted: String = EncryptionManager.decrypt_string(encrypted)

	if decrypted == test_data:
		print("[Main] Encryption test PASSED")
	else:
		push_error("[Main] Encryption test FAILED!")

func _update_loading_status(message: String) -> void:
	if loading_label:
		loading_label.text = message
	print("[Main] ", message)

## Loads existing save or creates new one
func _load_or_create_save() -> void:
	if SaveManager.has_save_file():
		print("[Main] Loading existing save...")
		var success: bool = SaveManager.load_game()
		if success:
			print("[Main] Save loaded successfully")
			var save: SaveData = SaveManager.current_save
			print("[Main] Player level: ", save.player_level, " | Gems: ", save.gems)
		else:
			push_warning("[Main] Failed to load save, creating new one")
			SaveManager.create_new_save()
	else:
		print("[Main] No save found, creating new save...")
		SaveManager.create_new_save()

## Calculates and displays offline earnings
func _show_offline_earnings(offline_seconds: int) -> void:
	var hours: int = offline_seconds / 3600
	var minutes: int = (offline_seconds % 3600) / 60

	print("[Main] Welcome back! You were away for ", hours, "h ", minutes, "m")

	# Calculate offline gem earnings (basic formula for now)
	# TODO: Integrate with actual farm gem generation rate
	var base_gem_rate: int = 10  # gems per minute (placeholder)
	var max_offline_minutes: int = 480  # 8 hours max
	var actual_minutes: int = mini(offline_seconds / 60, max_offline_minutes)
	var offline_gems: int = actual_minutes * base_gem_rate

	if offline_gems > 0 and SaveManager.current_save != null:
		SaveManager.current_save.gems += offline_gems
		SaveManager.current_save.stats["total_gems_earned"] = \
			SaveManager.current_save.stats.get("total_gems_earned", 0) + offline_gems
		SaveManager.mark_dirty()
		print("[Main] Offline earnings: +", offline_gems, " gems")
		EventBus.idle_gems_generated.emit(offline_gems)
