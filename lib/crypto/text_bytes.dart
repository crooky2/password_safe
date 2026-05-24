import "dart:convert";
import "dart:typed_data";

Uint8List textToBytes(String text) {
  return Uint8List.fromList(utf8.encode(text));
}

String bytesToText(List<int> bytes) {
  return utf8.decode(bytes);
}