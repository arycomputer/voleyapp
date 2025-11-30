import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  int _maxScore;
  int _timeoutsPerSet;
  int _timerDuration;
  Color _teamAColor;
  Color _teamBColor;
  Color _fontColor;
  ThemeMode _themeMode;

  // Chaves para o mapa de configurações
  static const String maxScoreKey = 'max_score';
  static const String timeoutsKey = 'timeouts_per_set';
  static const String timerDurationKey = 'timer_duration';
  static const String teamAColorKey = 'team_a_color';
  static const String teamBColorKey = 'team_b_color';
  static const String fontColorKey = 'font_color';
  static const String themeModeKey = 'theme_mode';

  SettingsProvider({
    int maxScore = 25,
    int timeoutsPerSet = 2,
    int timerDuration = 30,
    Color teamAColor = Colors.red,
    Color teamBColor = Colors.blue,
    Color fontColor = Colors.white,
    ThemeMode themeMode = ThemeMode.system,
  }) : _maxScore = maxScore,
       _timeoutsPerSet = timeoutsPerSet,
       _timerDuration = timerDuration,
       _teamAColor = teamAColor,
       _teamBColor = teamBColor,
       _fontColor = fontColor,
       _themeMode = themeMode {
    _loadSettings();
  }

  // Getters
  int get maxScore => _maxScore;
  int get timeoutsPerSet => _timeoutsPerSet;
  int get timerDuration => _timerDuration;
  Color get teamAColor => _teamAColor;
  Color get teamBColor => _teamBColor;
  Color get fontColor => _fontColor;
  ThemeMode get themeMode => _themeMode;

  // Setters que salvam as preferências
  void setMaxScore(int newScore) {
    _maxScore = newScore;
    _saveSettings();
    notifyListeners();
  }

  void setTimeoutsPerSet(int newTimeouts) {
    _timeoutsPerSet = newTimeouts;
    _saveSettings();
    notifyListeners();
  }

  void setTimerDuration(int newDuration) {
    _timerDuration = newDuration;
    _saveSettings();
    notifyListeners();
  }

  void setTeamAColor(Color newColor) {
    _teamAColor = newColor;
    _saveSettings();
    notifyListeners();
  }

  void setTeamBColor(Color newColor) {
    _teamBColor = newColor;
    _saveSettings();
    notifyListeners();
  }

  void setFontColor(Color newColor) {
    _fontColor = newColor;
    _saveSettings();
    notifyListeners();
  }

  void setThemeMode(ThemeMode newThemeMode) {
    _themeMode = newThemeMode;
    _saveSettings();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final settings = {
      maxScoreKey: _maxScore,
      timeoutsKey: _timeoutsPerSet,
      timerDurationKey: _timerDuration,
      teamAColorKey: _teamAColor.toARGB32(),
      teamBColorKey: _teamBColor.toARGB32(),
      fontColorKey: _fontColor.toARGB32(),
      themeModeKey: _themeMode.index,
    };

    if (kIsWeb) {
      await _settingsService.saveSettings(settings);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(maxScoreKey, _maxScore);
      await prefs.setInt(timeoutsKey, _timeoutsPerSet);
      await prefs.setInt(timerDurationKey, _timerDuration);
      await prefs.setInt(teamAColorKey, _teamAColor.toARGB32());
      await prefs.setInt(teamBColorKey, _teamBColor.toARGB32());
      await prefs.setInt(fontColorKey, _fontColor.toARGB32());
      await prefs.setInt(themeModeKey, _themeMode.index);
    }
  }

  Future<void> _loadSettings() async {
    if (kIsWeb) {
      final settings = await _settingsService.loadSettings();
      _maxScore = settings[maxScoreKey] ?? 25;
      _timeoutsPerSet = settings[timeoutsKey] ?? 2;
      _timerDuration = settings[timerDurationKey] ?? 30;
      _teamAColor = Color(settings[teamAColorKey] ?? Colors.red.toARGB32());
      _teamBColor = Color(settings[teamBColorKey] ?? Colors.blue.toARGB32());
      _fontColor = Color(settings[fontColorKey] ?? Colors.white.toARGB32());
      _themeMode =
          ThemeMode.values[settings[themeModeKey] ?? ThemeMode.system.index];
    } else {
      final prefs = await SharedPreferences.getInstance();
      _maxScore = prefs.getInt(maxScoreKey) ?? 25;
      _timeoutsPerSet = prefs.getInt(timeoutsKey) ?? 2;
      _timerDuration = prefs.getInt(timerDurationKey) ?? 30;
      _teamAColor = Color(prefs.getInt(teamAColorKey) ?? Colors.red.toARGB32());
      _teamBColor = Color(
        prefs.getInt(teamBColorKey) ?? Colors.blue.toARGB32(),
      );
      _fontColor = Color(prefs.getInt(fontColorKey) ?? Colors.white.toARGB32());
      final themeIndex = prefs.getInt(themeModeKey) ?? ThemeMode.system.index;
      _themeMode = ThemeMode.values[themeIndex];
    }
    notifyListeners();
  }
}
