class_name MainScene
extends Control
## Main entry point for Gem Harvest Idle.
## Handles initialization sequence: consent -> load -> offline rewards -> game start.

@onready var loading_label: Label = %LoadingLabel

func _ready() -> void:
	_initialize_game()

func _initialize_game() -> void:
	_update_loading_status("Starting...")

	# Wait a frame for autoloads to initialize
	await get_tree().process_frame

	_update_loading_status("Gem Harvest Idle started!")
	print("Gem Harvest Idle v0.1.0 initialized")
	print("EventBus loaded: ", EventBus != null)

	# TODO: Add consent check
	# TODO: Add save loading
	# TODO: Add offline earnings calculation
	# TODO: Transition to farm screen

func _update_loading_status(message: String) -> void:
	if loading_label:
		loading_label.text = message
	print("[Main] ", message)
