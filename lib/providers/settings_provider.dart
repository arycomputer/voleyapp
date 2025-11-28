import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _teamAColor = Colors.blue[100]!;
  Color _teamBColor = Colors.red[100]!;
  Color _fontColor = Colors.black;
  int _maxScore = 25;
  int _timeoutsPerSet = 2;
  int _timerDuration = 30;

  ThemeMode get themeMode => _themeMode;
  Color get teamAColor => _teamAColor;
  Color get teamBColor => _teamBColor;
  Color get fontColor => _fontColor;
  int get maxScore => _maxScore;
  int get timeoutsPerSet => _timeoutsPerSet;
  int get timerDuration => _timerDuration;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setTeamAColor(Color color) {
    _teamAColor = color;
    notifyListeners();
  }

  void setTeamBColor(Color color) {
    _teamBColor = color;
    notifyListeners();
  }

  void setFontColor(Color color) {
    _fontColor = color;
    notifyListeners();
  }

  void setMaxScore(int score) {
    _maxScore = score;
    notifyListeners();
  }

  void setTimeoutsPerSet(int timeouts) {
    _timeoutsPerSet = timeouts;
    notifyListeners();
  }

  void setTimerDuration(int duration) {
    _timerDuration = duration;
    notifyListeners();
  }
}
