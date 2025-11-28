import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _teamAColor = Colors.red[400]!;
  Color _teamBColor = Colors.blue[400]!;
  Color _fontColor = Colors.white;
  String _teamAName = 'Time A';
  String _teamBName = 'Time B';
  bool _trackPlayerStats = false;
  bool _endGameAtThreeSets = true;
  int _timeoutsPerSet = 2;
  Color _backgroundColor = Colors.white;

  ThemeMode get themeMode => _themeMode;
  Color get teamAColor => _teamAColor;
  Color get teamBColor => _teamBColor;
  Color get fontColor => _fontColor;
  String get teamAName => _teamAName;
  String get teamBName => _teamBName;
  bool get trackPlayerStats => _trackPlayerStats;
  bool get endGameAtThreeSets => _endGameAtThreeSets;
  int get timeoutsPerSet => _timeoutsPerSet;
  Color get backgroundColor => _backgroundColor;

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

  void setTeamAName(String name) {
    _teamAName = name;
    notifyListeners();
  }

  void setTeamBName(String name) {
    _teamBName = name;
    notifyListeners();
  }

  void setTrackPlayerStats(bool value) {
    _trackPlayerStats = value;
    notifyListeners();
  }

  void setEndGameAtThreeSets(bool value) {
    _endGameAtThreeSets = value;
    notifyListeners();
  }

  void setTimeoutsPerSet(int value) {
    _timeoutsPerSet = value;
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }
}
