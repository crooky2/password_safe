import "dart:math";

class PasswordGeneratorOptions {
  const PasswordGeneratorOptions({
    required this.length,
    required this.includeLetters,
    required this.includeUpperLetters,
    required this.includeNumbers,
    required this.includeSpecialChars,
  });

  final int length;
  final bool includeLetters;
  final bool includeUpperLetters;
  final bool includeNumbers;
  final bool includeSpecialChars;

  bool get hasCharacterSet =>
      includeLetters || includeUpperLetters || includeNumbers || includeSpecialChars;
}

class PasswordGenerator {
  PasswordGenerator({
    Random? random,
  }) : _random = random ?? Random.secure();

  static const String _letters = "abcdefghijklmnopqrstuvwxyz";
  static const String _upperLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  static const String _numbers = "0123456789";
  static const String _specialChars = r"!@#\$%^&*()-_=+[]{}|;:,.<>?";

  final Random _random;

  String generate(PasswordGeneratorOptions options) {
    if (options.length <= 0 || !options.hasCharacterSet) {
      return "";
    }

    final selectedSets = <String>[
      if (options.includeLetters) _letters,
      if (options.includeUpperLetters) _upperLetters,
      if (options.includeNumbers) _numbers,
      if (options.includeSpecialChars) _specialChars,
    ];

    final pool = selectedSets.join();
    final passwordChars = <String>[];

    if (options.length >= selectedSets.length) {
      for (final set in selectedSets) {
        passwordChars.add(_pickCharacter(set));
      }
    }

    while (passwordChars.length < options.length) {
      passwordChars.add(_pickCharacter(pool));
    }

    passwordChars.shuffle(_random);
    return passwordChars.join();
  }

  String _pickCharacter(String source) {
    return source[_random.nextInt(source.length)];
  }
}