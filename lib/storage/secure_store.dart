import "package:flutter_secure_storage/flutter_secure_storage.dart";

class SecureStore {
  const SecureStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const String deviceSecretKey = "device_secret";
  static const String quickUnlockRecordKey = "quick_unlock_record";
  static const String quickUnlockThrottleKey = "quick_unlock_throttle";

  final FlutterSecureStorage _storage;

  Future<void> writeDeviceSecret(String value) {
    return _storage.write(key: deviceSecretKey, value: value);
  }

  Future<String?> readDeviceSecret() {
    return _storage.read(key: deviceSecretKey);
  }

  Future<void> writeQuickUnlockRecord(String value) {
    return _storage.write(key: quickUnlockRecordKey, value: value);
  }

  Future<String?> readQuickUnlockRecord() {
    return _storage.read(key: quickUnlockRecordKey);
  }

  Future<bool> hasQuickUnlockRecord() {
    return _storage.containsKey(key: quickUnlockRecordKey);
  }

  Future<void> deleteQuickUnlockRecord() async {
    await _storage.delete(key: quickUnlockRecordKey);
    await _storage.delete(key: deviceSecretKey);
    await _storage.delete(key: quickUnlockThrottleKey);
  }

  Future<void> writeQuickUnlockThrottle(String value) {
    return _storage.write(key: quickUnlockThrottleKey, value: value);
  }

  Future<String?> readQuickUnlockThrottle() {
    return _storage.read(key: quickUnlockThrottleKey);
  }

  Future<void> deleteQuickUnlockThrottle() {
    return _storage.delete(key: quickUnlockThrottleKey);
  }
}
