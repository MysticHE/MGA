class_name SaveManagerClass
extends Node
## Manages encrypted save data with auto-save and backup.
## Integrates with EncryptionManager for PDPA-compliant storage.

const SAVE_FILE_PATH: String = "user://save_data.sav"
const BACKUP_FILE_PATH: String = "user://save_data.bak"
const AUTO_SAVE_INTERVAL: float = 60.0  # seconds
const MAX_BACKUPS: int = 3

signal save_started()
signal save_completed(success: bool)
signal load_started()
signal load_completed(success: bool)
signal save_error(message: String)

var current_save: SaveData = null
var _auto_save_timer: Timer = null
var _is_saving: bool = false
var _is_loading: bool = false
var _dirty: bool = false  # Tracks unsaved changes


func _ready() -> void:
	_setup_auto_save_timer()
	_connect_app_lifecycle()
	print("[SaveManager] Initialized")


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			# Save before closing (desktop)
			_on_app_closing()
		NOTIFICATION_APPLICATION_PAUSED:
			# Save when app goes to background (mobile)
			_on_app_paused()
		NOTIFICATION_APPLICATION_RESUMED:
			# Update online time when returning
			_on_app_resumed()


## Sets up auto-save timer
func _setup_auto_save_timer() -> void:
	_auto_save_timer = Timer.new()
	_auto_save_timer.wait_time = AUTO_SAVE_INTERVAL
	_auto_save_timer.one_shot = false
	_auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(_auto_save_timer)


## Connects to app lifecycle events
func _connect_app_lifecycle() -> void:
	get_tree().auto_accept_quit = false


## Creates a new save file
func create_new_save() -> void:
	current_save = SaveData.create_new()
	_dirty = true
	save_game()
	print("[SaveManager] New save created")
	_emit_event("save_created")


## Saves the current game state
func save_game() -> bool:
	if _is_saving:
		push_warning("[SaveManager] Save already in progress")
		return false

	if current_save == null:
		push_error("[SaveManager] No save data to save")
		return false

	_is_saving = true
	save_started.emit()

	# Update timestamps
	current_save.touch()

	# Convert to JSON
	var save_dict: Dictionary = current_save.to_dict()
	var json_string: String = JSON.stringify(save_dict)

	# Encrypt the data
	var encrypted: String = EncryptionManager.encrypt_string(json_string)
	if encrypted.is_empty():
		push_error("[SaveManager] Encryption failed")
		_is_saving = false
		save_error.emit("Encryption failed")
		save_completed.emit(false)
		return false

	# Create backup of existing save
	_create_backup()

	# Write encrypted save
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("[SaveManager] Cannot write save file: ", FileAccess.get_open_error())
		_is_saving = false
		save_error.emit("Cannot write save file")
		save_completed.emit(false)
		return false

	file.store_string(encrypted)
	file.close()

	_dirty = false
	_is_saving = false
	save_completed.emit(true)
	_emit_event("save_completed", [true])
	print("[SaveManager] Game saved successfully")
	return true


## Loads the saved game state
func load_game() -> bool:
	if _is_loading:
		push_warning("[SaveManager] Load already in progress")
		return false

	_is_loading = true
	load_started.emit()

	# Check if save file exists
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("[SaveManager] No save file found")
		_is_loading = false
		load_completed.emit(false)
		return false

	# Read encrypted save
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		push_error("[SaveManager] Cannot read save file: ", FileAccess.get_open_error())
		_is_loading = false
		load_completed.emit(false)
		return false

	var encrypted: String = file.get_as_text()
	file.close()

	# Decrypt the data
	var json_string: String = EncryptionManager.decrypt_string(encrypted)
	if json_string.is_empty():
		push_warning("[SaveManager] Decryption failed, trying backup")
		if _try_load_backup():
			_is_loading = false
			load_completed.emit(true)
			return true
		_is_loading = false
		load_completed.emit(false)
		return false

	# Parse JSON
	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_string)
	if parse_result != OK:
		push_error("[SaveManager] JSON parse error: ", json.get_error_message())
		_is_loading = false
		load_completed.emit(false)
		return false

	# Create SaveData from dictionary
	var save_dict: Dictionary = json.data
	current_save = SaveData.from_dict(save_dict)

	# Check for save version migration
	_migrate_save_if_needed()

	_dirty = false
	_is_loading = false
	load_completed.emit(true)
	_emit_event("save_loaded", [current_save])
	print("[SaveManager] Game loaded successfully")
	return true


## Checks if a save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)


## Deletes the save file (with confirmation required)
func delete_save() -> bool:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)

	if FileAccess.file_exists(BACKUP_FILE_PATH):
		DirAccess.remove_absolute(BACKUP_FILE_PATH)

	current_save = null
	print("[SaveManager] Save deleted")
	return true


## Marks save as dirty (needs saving)
func mark_dirty() -> void:
	_dirty = true


## Checks if there are unsaved changes
func has_unsaved_changes() -> bool:
	return _dirty


## Gets the current save data (read-only access pattern)
func get_save() -> SaveData:
	return current_save


## Starts auto-save timer
func start_auto_save() -> void:
	if _auto_save_timer and not _auto_save_timer.is_stopped():
		return
	_auto_save_timer.start()
	print("[SaveManager] Auto-save started (every ", AUTO_SAVE_INTERVAL, "s)")


## Stops auto-save timer
func stop_auto_save() -> void:
	if _auto_save_timer:
		_auto_save_timer.stop()
	print("[SaveManager] Auto-save stopped")


## Creates a backup of the current save
func _create_backup() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return

	# Read current save
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		return

	var content: String = file.get_as_text()
	file.close()

	# Write to backup
	var backup: FileAccess = FileAccess.open(BACKUP_FILE_PATH, FileAccess.WRITE)
	if backup == null:
		return

	backup.store_string(content)
	backup.close()
	print("[SaveManager] Backup created")


## Attempts to load from backup file
func _try_load_backup() -> bool:
	if not FileAccess.file_exists(BACKUP_FILE_PATH):
		print("[SaveManager] No backup file found")
		return false

	print("[SaveManager] Attempting backup recovery")

	var file: FileAccess = FileAccess.open(BACKUP_FILE_PATH, FileAccess.READ)
	if file == null:
		return false

	var encrypted: String = file.get_as_text()
	file.close()

	var json_string: String = EncryptionManager.decrypt_string(encrypted)
	if json_string.is_empty():
		return false

	var json: JSON = JSON.new()
	if json.parse(json_string) != OK:
		return false

	current_save = SaveData.from_dict(json.data)
	print("[SaveManager] Backup recovered successfully")
	return true


## Migrates save data if version is outdated
func _migrate_save_if_needed() -> void:
	if current_save == null:
		return

	if current_save.save_version < SaveData.SAVE_VERSION:
		print("[SaveManager] Migrating save from v", current_save.save_version, " to v", SaveData.SAVE_VERSION)
		# Add migration logic here as versions increase
		current_save.save_version = SaveData.SAVE_VERSION
		_dirty = true


## Auto-save timer callback
func _on_auto_save_timeout() -> void:
	if _dirty and current_save != null:
		print("[SaveManager] Auto-saving...")
		save_game()


## Called when app is closing (desktop)
func _on_app_closing() -> void:
	print("[SaveManager] App closing, saving...")
	if current_save != null and _dirty:
		save_game()
	get_tree().quit()


## Called when app goes to background (mobile)
func _on_app_paused() -> void:
	print("[SaveManager] App paused, saving...")
	if current_save != null:
		current_save.touch()
		save_game()


## Called when app returns from background
func _on_app_resumed() -> void:
	print("[SaveManager] App resumed")
	if current_save != null:
		var offline_seconds: int = current_save.get_offline_seconds()
		current_save.mark_online()
		_emit_event("offline_earnings_calculated", [offline_seconds])


## Helper to emit EventBus signals at runtime (avoids parse-time issues)
func _emit_event(signal_name: String, args: Array = []) -> void:
	var event_bus: Node = get_node_or_null("/root/EventBus")
	if event_bus == null:
		return

	match args.size():
		0:
			event_bus.emit_signal(signal_name)
		1:
			event_bus.emit_signal(signal_name, args[0])
		2:
			event_bus.emit_signal(signal_name, args[0], args[1])
		_:
			push_warning("[SaveManager] Too many args for signal: ", signal_name)
