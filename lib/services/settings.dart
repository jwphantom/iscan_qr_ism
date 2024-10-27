import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static Future<bool> hasValidSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('ip');
    final port = prefs.getString('port');

    return ip != null && port != null && ip.isNotEmpty && port.isNotEmpty;
  }

  static Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('settings_pin');
  }
}
