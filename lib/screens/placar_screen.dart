import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/timer_widget.dart';
import 'settings_screen.dart';
import 'team_builder_screen.dart';

class PlacarScreen extends StatefulWidget {
  final List<Map<String, dynamic>> teams;

  const PlacarScreen({super.key, required this.teams});

  @override
  PlacarScreenState createState() => PlacarScreenState();
}

class PlacarScreenState extends State<PlacarScreen> {
  int _scoreA = 0;
  int _scoreB = 0;
  int _timeoutsA = 0;
  int _timeoutsB = 0;
  late Timer _timer;
  int _start = 300; // 5 minutos em segundos
  final String _timeA = "A";
  final String _timeB = "B";
  bool _isTimerRunning = false;
  bool _isCountdownVisible = false;

  @override
  void initState() {
    super.initState();
    // Não inicia o timer automaticamente
  }

  void startTimer() {
    if (_isTimerRunning) return;
    setState(() {
      _isTimerRunning = true;
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _isTimerRunning = false;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void pauseTimer() {
    if (_isTimerRunning) {
      _timer.cancel();
      setState(() {
        _isTimerRunning = false;
      });
    }
  }

  @override
  void dispose() {
    if (_isTimerRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _incrementScore(int team, int maxScore) {
    setState(() {
      if (team == 0) {
        if (_scoreA < maxScore) _scoreA++;
      } else {
        if (_scoreB < maxScore) _scoreB++;
      }
    });
  }

  void _decrementScore(int team) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (team == 0 && _scoreA > 0) {
        _scoreA--;
      } else if (team == 1 && _scoreB > 0) {
        _scoreB--;
      }
    });
  }

  void _resetScores() {
    setState(() {
      _scoreA = 0;
      _scoreB = 0;
      _timeoutsA = 0;
      _timeoutsB = 0;
    });
  }

  void _resetTimer() {
    pauseTimer();
    setState(() {
      _start = 300;
    });
  }

  void _useTimeout(int team) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    setState(() {
      if (team == 0) {
        if (_timeoutsA < settingsProvider.timeoutsPerSet) {
          _timeoutsA++;
          _showCountdown();
        }
      } else {
        if (_timeoutsB < settingsProvider.timeoutsPerSet) {
          _timeoutsB++;
          _showCountdown();
        }
      }
    });
  }

  void _showCountdown() {
    setState(() {
      _isCountdownVisible = true;
    });
  }

  void _hideCountdown() {
    setState(() {
      _isCountdownVisible = false;
    });
  }

  String get _timerString {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Row(
              children: [
                _buildTeamColumn(0, _timeA, _scoreA, settingsProvider.teamAColor, settingsProvider.fontColor, settingsProvider.maxScore, settingsProvider.timeoutsPerSet),
                _buildMiddleColumn(),
                _buildTeamColumn(1, _timeB, _scoreB, settingsProvider.teamBColor, settingsProvider.fontColor, settingsProvider.maxScore, settingsProvider.timeoutsPerSet),
              ],
            ),
          ),
          if (_isCountdownVisible)
            TimerWidget(
              duration: settingsProvider.timerDuration,
              onTimerFinish: _hideCountdown,
            ),
        ],
      ),
    );
  }

  Widget _buildMiddleColumn() {
    return Expanded(
      flex: 6, // Flex menor para a coluna do meio
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                'TEMPO',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                _timerString,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(_isTimerRunning ? Icons.pause_circle_filled : Icons.play_circle_filled),
                      onPressed: () {
                        if (_isTimerRunning) {
                          pauseTimer();
                        } else {
                          startTimer();
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        _resetScores();
                        _resetTimer();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.people),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TeamBuilderScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(int teamIndex, String teamName, int score, Color color, Color fontColor, int maxScore, int timeoutsPerSet) {
    int timeoutsUsed = teamIndex == 0 ? _timeoutsA : _timeoutsB;
    return Expanded(
      flex: 17, // Flex maior para as colunas dos times
      child: GestureDetector(
        onTap: () => _incrementScore(teamIndex, maxScore),
        onLongPress: () => _decrementScore(teamIndex),
        child: Card(
          margin: const EdgeInsets.all(4),
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1, // Flex menor para o nome do time
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      teamName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                         color: fontColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5, // Flex maior para o placar
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      score.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                         color: fontColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(timeoutsPerSet, (index) {
                      return GestureDetector(
                        onTap: () => _useTimeout(teamIndex),
                        child: Icon(
                          index < timeoutsUsed ? Icons.timer_off : Icons.timer,
                          color: fontColor,
                          size: 30,
                        ),
                      );
                    }),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
