import "dart:convert";
import "dart:math";
import "dart:typed_data";

final Random _secureRandom = Random.secure();

Uint8List generateRandomBytes(int length) {
  if (length <= 0) {
    throw ArgumentError.value(length, "length", "Must be greater than 0");
  }
  return Uint8List.fromList(
    List<int>.generate(
      length,
      (_) => _secureRandom.nextInt(256),
      growable: false,
    )
  );
}

String bytesToBase64(List<int> bytes) {
  return base64Encode(bytes);
}

Uint8List base64ToBytes(String value) {
  return Uint8List.fromList(base64Decode(value));
}