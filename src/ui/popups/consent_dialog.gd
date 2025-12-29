class_name ConsentDialog
extends Control
## PDPA-compliant consent dialog for data collection permissions.
## MUST be shown before ANY data collection occurs.

const PRIVACY_POLICY_URL: String = "https://gemharvestidle.com/privacy"

## Local reference to consent types (avoids autoload parse issues)
enum ConsentType {
	ESSENTIAL,
	ANALYTICS,
	CRASH_REPORTING,
	MARKETING,
}

## Emitted when user submits their consent choices
signal consent_submitted(consents: Dictionary)

@onready var analytics_toggle: CheckBox = %AnalyticsToggle
@onready var crash_toggle: CheckBox = %CrashToggle
@onready var marketing_toggle: CheckBox = %MarketingToggle

func _ready() -> void:
	# All optional consents default to OFF (PDPA requirement)
	analytics_toggle.button_pressed = false
	crash_toggle.button_pressed = false
	marketing_toggle.button_pressed = false

## Shows the dialog with animation
func show_dialog() -> void:
	visible = true
	modulate.a = 0.0

	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

## Hides the dialog with animation
func hide_dialog() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished
	visible = false

## Called when "Essential Only" button is pressed
func _on_essential_only_pressed() -> void:
	var consents: Dictionary = {
		ConsentType.ESSENTIAL: true,
		ConsentType.ANALYTICS: false,
		ConsentType.CRASH_REPORTING: false,
		ConsentType.MARKETING: false,
	}
	_submit_consent(consents)

## Called when "Accept All" button is pressed
func _on_accept_all_pressed() -> void:
	var consents: Dictionary = {
		ConsentType.ESSENTIAL: true,
		ConsentType.ANALYTICS: true,
		ConsentType.CRASH_REPORTING: true,
		ConsentType.MARKETING: true,
	}
	_submit_consent(consents)

## Called when "Confirm Selection" button is pressed
func _on_confirm_selection_pressed() -> void:
	var consents: Dictionary = {
		ConsentType.ESSENTIAL: true,
		ConsentType.ANALYTICS: analytics_toggle.button_pressed,
		ConsentType.CRASH_REPORTING: crash_toggle.button_pressed,
		ConsentType.MARKETING: marketing_toggle.button_pressed,
	}
	_submit_consent(consents)

## Called when "Privacy Policy" link is pressed
func _on_privacy_policy_pressed() -> void:
	OS.shell_open(PRIVACY_POLICY_URL)
	print("[ConsentDialog] Opening privacy policy: ", PRIVACY_POLICY_URL)

## Submits consent and closes dialog
func _submit_consent(consents: Dictionary) -> void:
	consent_submitted.emit(consents)
	hide_dialog()
