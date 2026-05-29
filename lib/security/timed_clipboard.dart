import "dart:async";

import "package:flutter/services.dart";

class TimedClipboard {
  const TimedClipboard._();

  static Timer? _clearTimer;

  static Future<void> copyText(
    String text, {
    Duration clearAfter = const Duration(seconds: 30),
  }) async {
    await Clipboard.setData(ClipboardData(text: text));

    _clearTimer?.cancel();
    _clearTimer = Timer(clearAfter, () async {
      final current = await Clipboard.getData(Clipboard.kTextPlain);

      if (current?.text == text) {
        await Clipboard.setData(const ClipboardData(text: ""));
      }
    });
  }
}