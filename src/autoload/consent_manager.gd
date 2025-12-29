class_name ConsentManagerClass
extends Node
## Manages PDPA-compliant consent for data collection.
## CRITICAL: Game MUST NOT collect ANY data before consent is given.

## Consent types as per PDPA requirements
enum ConsentType {
	ESSENTIAL,        ## Required for game to function (always granted)
	ANALYTICS,        ## Gameplay analytics, crash reporting
	CRASH_REPORTING,  ## Crash logs and error reporting
	MARKETING,        ## Push notifications, promotional content
}

## Current consent version - increment when privacy policy changes
const CONSENT_VERSION: int = 1
const CONSENT_FILE_PATH: String = "user://consent_record.json"

## Emitted when consent is updated
signal consent_updated(consents: Dictionary)

## Emitted when consent dialog needs to be shown
signal consent_required()

## Emitted when user withdraws consent
signal consent_withdrawn(consent_type: ConsentType)

## Current consent state
var _consents: Dictionary = {}
var _consent_version: int = 0
var _consent_timestamp: int = 0
var _is_loaded: bool = false

func _ready() -> void:
	_load_consent()

## Checks if consent dialog needs to be shown
func needs_consent() -> bool:
	# Always show if not loaded or version outdated
	if not _is_loaded:
		return true

	if _consent_version < CONSENT_VERSION:
		return true

	# Check if essential consent exists
	if not _consents.has(ConsentType.ESSENTIAL):
		return true

	return false

## Checks if a specific consent type has been granted
func has_consent(consent_type: ConsentType) -> bool:
	# Essential is always considered granted once any consent is given
	if consent_type == ConsentType.ESSENTIAL and _is_loaded:
		return _consents.get(ConsentType.ESSENTIAL, false)

	return _consents.get(consent_type, false)

## Records user consent choices
func record_consent(consents: Dictionary) -> void:
	_consents = consents.duplicate()
	_consents[ConsentType.ESSENTIAL] = true  # Essential always granted
	_consent_version = CONSENT_VERSION
	_consent_timestamp = int(Time.get_unix_time_from_system())
	_is_loaded = true

	_save_consent()
	consent_updated.emit(_consents)

	print("[ConsentManager] Consent recorded: ", _get_consent_summary())

## Withdraws a specific consent type
func withdraw_consent(consent_type: ConsentType) -> void:
	if consent_type == ConsentType.ESSENTIAL:
		push_warning("[ConsentManager] Cannot withdraw essential consent")
		return

	_consents[consent_type] = false
	_consent_timestamp = int(Time.get_unix_time_from_system())

	_save_consent()
	consent_withdrawn.emit(consent_type)
	consent_updated.emit(_consents)

	print("[ConsentManager] Consent withdrawn: ", ConsentType.keys()[consent_type])

## Gets all current consents
func get_all_consents() -> Dictionary:
	return _consents.duplicate()

## Gets consent timestamp
func get_consent_timestamp() -> int:
	return _consent_timestamp

## Gets current consent version
func get_consent_version() -> int:
	return _consent_version

## Loads consent from file
func _load_consent() -> void:
	if not FileAccess.file_exists(CONSENT_FILE_PATH):
		_is_loaded = false
		print("[ConsentManager] No consent record found - consent required")
		return

	var file: FileAccess = FileAccess.open(CONSENT_FILE_PATH, FileAccess.READ)
	if file == null:
		push_error("[ConsentManager] Failed to open consent file")
		_is_loaded = false
		return

	var json_string: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_string)
	if parse_result != OK:
		push_error("[ConsentManager] Failed to parse consent JSON")
		_is_loaded = false
		return

	var data: Dictionary = json.data
	if not data is Dictionary:
		push_error("[ConsentManager] Invalid consent data format")
		_is_loaded = false
		return

	_consent_version = data.get("version", 0)
	_consent_timestamp = data.get("timestamp", 0)

	# Convert string keys back to enum values
	var stored_consents: Dictionary = data.get("consents", {})
	_consents = {}
	for key in stored_consents:
		var consent_type: int = int(key)
		_consents[consent_type] = stored_consents[key]

	_is_loaded = true
	print("[ConsentManager] Loaded consent v", _consent_version, ": ", _get_consent_summary())

## Saves consent to file
func _save_consent() -> void:
	var file: FileAccess = FileAccess.open(CONSENT_FILE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("[ConsentManager] Failed to save consent file")
		return

	# Convert enum keys to strings for JSON
	var storable_consents: Dictionary = {}
	for key in _consents:
		storable_consents[str(key)] = _consents[key]

	var data: Dictionary = {
		"version": _consent_version,
		"timestamp": _consent_timestamp,
		"consents": storable_consents,
	}

	file.store_string(JSON.stringify(data, "\t"))
	file.close()

	print("[ConsentManager] Consent saved")

## Gets a human-readable summary of consents
func _get_consent_summary() -> String:
	var parts: Array[String] = []
	for consent_type in _consents:
		var name: String = ConsentType.keys()[consent_type]
		var granted: String = "✓" if _consents[consent_type] else "✗"
		parts.append("%s:%s" % [name, granted])
	return ", ".join(parts)

## Clears all consent (for testing or data deletion requests)
func clear_consent() -> void:
	_consents = {}
	_consent_version = 0
	_consent_timestamp = 0
	_is_loaded = false

	if FileAccess.file_exists(CONSENT_FILE_PATH):
		DirAccess.remove_absolute(CONSENT_FILE_PATH)

	print("[ConsentManager] All consent cleared")
