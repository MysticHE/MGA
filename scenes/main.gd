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

	# CRITICAL: Check consent BEFORE any data operations
	if ConsentManager.needs_consent():
		_update_loading_status("Privacy settings required...")
		await _show_consent_dialog()

	_update_loading_status("Initializing security...")
	await get_tree().process_frame

	# Test encryption (only if analytics consent given)
	if ConsentManager.has_consent(ConsentManager.ConsentType.ANALYTICS):
		_test_encryption()

	_update_loading_status("Loading game data...")
	await get_tree().process_frame

	# TODO: Add save loading
	# TODO: Add offline earnings calculation
	# TODO: Transition to farm screen

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
