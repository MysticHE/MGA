class_name EncryptionManagerClass
extends Node
## Handles AES-256-CBC encryption for local save data.
## PDPA compliant - encrypts all personal data at rest.

const SALT: String = "gem_harvest_2025_sg"
const KEY_ITERATIONS: int = 1000
const BLOCK_SIZE: int = 16  # AES block size

var _encryption_key: PackedByteArray
var _is_initialized: bool = false

func _ready() -> void:
	_initialize_encryption_key()

## Derives encryption key from device-specific data
func _initialize_encryption_key() -> void:
	var device_id: String = _get_device_identifier()
	var key_material: String = device_id + SALT

	# Derive key using multiple SHA-256 iterations
	var key_bytes: PackedByteArray = key_material.to_utf8_buffer()
	for i in range(KEY_ITERATIONS):
		key_bytes = key_bytes.sha256_buffer()

	# Use first 32 bytes for AES-256
	_encryption_key = key_bytes.slice(0, 32)
	_is_initialized = true
	print("[EncryptionManager] Initialized with device-specific key")

## Gets a unique device identifier
func _get_device_identifier() -> String:
	var identifier: String = ""

	# Combine multiple device properties for uniqueness
	identifier += OS.get_unique_id()
	identifier += OS.get_model_name()
	identifier += OS.get_name()

	# Fallback if unique_id is empty (some platforms)
	if identifier.is_empty():
		identifier = "fallback_" + str(Time.get_unix_time_from_system())

	return identifier

## Encrypts raw byte data using AES-256-CBC
func encrypt_data(data: PackedByteArray) -> PackedByteArray:
	if not _is_initialized:
		push_error("[EncryptionManager] Not initialized!")
		return PackedByteArray()

	if data.is_empty():
		return PackedByteArray()

	# Generate random IV
	var iv: PackedByteArray = _generate_random_iv()

	# Apply PKCS7 padding
	var padded_data: PackedByteArray = _pkcs7_pad(data)

	# Encrypt using AES-256-CBC
	var aes: AESContext = AESContext.new()
	var error: Error = aes.start(AESContext.MODE_CBC_ENCRYPT, _encryption_key, iv)
	if error != OK:
		push_error("[EncryptionManager] AES start failed: ", error)
		return PackedByteArray()

	var encrypted: PackedByteArray = aes.update(padded_data)
	aes.finish()

	# Prepend IV to encrypted data (IV is not secret)
	var result: PackedByteArray = PackedByteArray()
	result.append_array(iv)
	result.append_array(encrypted)

	return result

## Decrypts AES-256-CBC encrypted data
func decrypt_data(encrypted: PackedByteArray) -> PackedByteArray:
	if not _is_initialized:
		push_error("[EncryptionManager] Not initialized!")
		return PackedByteArray()

	if encrypted.size() < BLOCK_SIZE * 2:  # At least IV + 1 block
		push_error("[EncryptionManager] Data too short to decrypt")
		return PackedByteArray()

	# Extract IV from first 16 bytes
	var iv: PackedByteArray = encrypted.slice(0, BLOCK_SIZE)
	var cipher_data: PackedByteArray = encrypted.slice(BLOCK_SIZE)

	# Decrypt using AES-256-CBC
	var aes: AESContext = AESContext.new()
	var error: Error = aes.start(AESContext.MODE_CBC_DECRYPT, _encryption_key, iv)
	if error != OK:
		push_error("[EncryptionManager] AES decrypt start failed: ", error)
		return PackedByteArray()

	var decrypted: PackedByteArray = aes.update(cipher_data)
	aes.finish()

	# Remove PKCS7 padding
	var unpadded: PackedByteArray = _pkcs7_unpad(decrypted)

	return unpadded

## Encrypts a string and returns base64-encoded result
func encrypt_string(text: String) -> String:
	if text.is_empty():
		return ""

	var data: PackedByteArray = text.to_utf8_buffer()
	var encrypted: PackedByteArray = encrypt_data(data)

	if encrypted.is_empty():
		return ""

	return Marshalls.raw_to_base64(encrypted)

## Decrypts a base64-encoded encrypted string
func decrypt_string(encrypted_base64: String) -> String:
	if encrypted_base64.is_empty():
		return ""

	var encrypted: PackedByteArray = Marshalls.base64_to_raw(encrypted_base64)
	var decrypted: PackedByteArray = decrypt_data(encrypted)

	if decrypted.is_empty():
		return ""

	return decrypted.get_string_from_utf8()

## Generates a random 16-byte IV
func _generate_random_iv() -> PackedByteArray:
	var iv: PackedByteArray = PackedByteArray()
	iv.resize(BLOCK_SIZE)

	for i in range(BLOCK_SIZE):
		iv[i] = randi() % 256

	return iv

## Applies PKCS7 padding to data
func _pkcs7_pad(data: PackedByteArray) -> PackedByteArray:
	var padding_length: int = BLOCK_SIZE - (data.size() % BLOCK_SIZE)
	var padded: PackedByteArray = data.duplicate()

	for i in range(padding_length):
		padded.append(padding_length)

	return padded

## Removes PKCS7 padding from data
func _pkcs7_unpad(data: PackedByteArray) -> PackedByteArray:
	if data.is_empty():
		return PackedByteArray()

	var padding_length: int = data[data.size() - 1]

	# Validate padding
	if padding_length < 1 or padding_length > BLOCK_SIZE:
		push_error("[EncryptionManager] Invalid padding length")
		return data  # Return as-is if padding is invalid

	# Verify all padding bytes are correct
	for i in range(padding_length):
		if data[data.size() - 1 - i] != padding_length:
			push_error("[EncryptionManager] Invalid padding bytes")
			return data

	return data.slice(0, data.size() - padding_length)

## Checks if encryption is ready
func is_ready() -> bool:
	return _is_initialized
