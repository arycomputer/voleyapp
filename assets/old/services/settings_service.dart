import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    if (kIsWeb) {
      // On the web, we can't directly write to the assets folder.
      // We'll use SharedPreferences as a workaround for this example.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('settings', jsonEncode(settings));
    } else {
      // On other platforms, you might write to a file.
    }
  }

  Future<Map<String, dynamic>> loadSettings() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final settingsString = prefs.getString('settings');
      if (settingsString != null) {
        return jsonDecode(settingsString);
      }
    }
    return {};
  }
}
