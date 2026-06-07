import 'dart:math';

class PasswordGenerator {
  static const String _lower = 'abcdefghijklmnopqrstuvwxyz';
  static const String _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _digits = '0123456789';
  static const String _symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

  static String generate({
    int length = 16,
    bool useLower = true,
    bool useUpper = true,
    bool useDigits = true,
    bool useSymbols = true,
  }) {
    final pool = StringBuffer();
    final required = <String>[];

    if (useLower) {
      pool.write(_lower);
      required.add(_lower[Random.secure().nextInt(_lower.length)]);
    }
    if (useUpper) {
      pool.write(_upper);
      required.add(_upper[Random.secure().nextInt(_upper.length)]);
    }
    if (useDigits) {
      pool.write(_digits);
      required.add(_digits[Random.secure().nextInt(_digits.length)]);
    }
    if (useSymbols) {
      pool.write(_symbols);
      required.add(_symbols[Random.secure().nextInt(_symbols.length)]);
    }

    if (pool.isEmpty) return '';

    final chars = pool.toString();
    final rng = Random.secure();
    final result = List<String>.generate(
      length - required.length,
      (_) => chars[rng.nextInt(chars.length)],
    )..addAll(required);

    result.shuffle(rng);
    return result.join();
  }

  /// Strength: 0 = very weak, 1 = weak, 2 = fair, 3 = strong, 4 = very strong
  static int strength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*()\-_=+\[\]{}|;:,.<>?]').hasMatch(password)) score++;
    return score.clamp(0, 4);
  }

  static String strengthLabel(int score) {
    switch (score) {
      case 0:
        return 'Sangat Lemah';
      case 1:
        return 'Lemah';
      case 2:
        return 'Cukup';
      case 3:
        return 'Kuat';
      case 4:
        return 'Sangat Kuat';
      default:
        return '';
    }
  }
}
