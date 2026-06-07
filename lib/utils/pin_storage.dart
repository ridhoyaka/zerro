import '../database/db_helper.dart';

/// Wrapper tipis di atas DBHelper untuk operasi PIN.
/// Tidak membuka database sendiri — semua delegate ke DBHelper.
class PinStorage {
  static const String _key = 'pin';
  static const String _defaultPin = '000000';

  static Future<String> getPin() async {
    return await DBHelper.getSetting(_key) ?? _defaultPin;
  }

  static Future<void> setPin(String pin) async {
    await DBHelper.setSetting(_key, pin);
  }

  static Future<bool> verify(String input) async {
    return input == await getPin();
  }
}
