class DeviceConstants {
  /// Fixed namespace for deterministic device_id generation (UUID v5).
  /// DO NOT CHANGE - changing this invalidates device_id for all existing installs,
  /// since every device would appear as a new one to the backend.
  static const String uuidNamespace = "f47ac10b-58cc-4372-a567-0e02b2c3d479";
}
