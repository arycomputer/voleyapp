import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/screens/team_builder_screen.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/timer_widget.dart';
import 'team_management_screen.dart';
import 'settings_screen.dart';

class PlacarScreen extends StatefulWidget {
  final List<Map<String, dynamic>> teams;

  const PlacarScreen({super.key, required this.teams});

  @override
  PlacarScreenState createState() => PlacarScreenState();
}

class PlacarScreenState extends State<PlacarScreen> {
  int _scoreA = 0;
  int _scoreB = 0;
  int _setsA = 0;
  int _setsB = 0;
  int _timeoutsA = 0;
  int _timeoutsB = 0;
  Timer? _timer;
  int _start = 300;
  late String _teamAName;
  late String _teamBName;
  bool _isTimerRunning = false;
  bool _isCountdownVisible = false;
  bool _isSetFinished = false;
  bool _isGameFinished = false;

  @override
  void initState() {
    super.initState();
    _teamAName = widget.teams.isNotEmpty ? widget.teams[0]['name'] : "Time A";
    _teamBName = widget.teams.length > 1 ? widget.teams[1]['name'] : "Time B";
  }

  void startTimer() {
    if (_isTimerRunning) return;
    setState(() {
      _isTimerRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
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
    });
  }

  void pauseTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      setState(() {
        _isTimerRunning = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _incrementScore(int team) {
    if (_isSetFinished || _isGameFinished) return;

    setState(() {
      if (team == 0) {
        _scoreA++;
      } else {
        _scoreB++;
      }
    });

    _checkForSetWin();
  }

  void _decrementScore(int team) {
    if (_isSetFinished || _isGameFinished) return;
    HapticFeedback.mediumImpact();
    setState(() {
      if (team == 0 && _scoreA > 0) {
        _scoreA--;
      } else if (team == 1 && _scoreB > 0) {
        _scoreB--;
      }
    });
  }

  void _checkForSetWin() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    int currentMaxScore = (_setsA == 2 && _setsB == 2) ? 15 : settings.maxScore;

    bool teamAWon = (_scoreA >= currentMaxScore && _scoreA >= _scoreB + 2);
    bool teamBWon = (_scoreB >= currentMaxScore && _scoreB >= _scoreA + 2);

    if (teamAWon) {
      _handleSetWin(0);
    } else if (teamBWon) {
      _handleSetWin(1);
    }
  }

  void _handleSetWin(int winnerTeamIndex) {
    pauseTimer();
    setState(() {
      if (winnerTeamIndex == 0) {
        _setsA++;
      } else {
        _setsB++;
      }
      _isSetFinished = true;

      if (_setsA == 3 || _setsB == 3) {
        _isGameFinished = true;
        _showGameWinnerNotification(
          winnerTeamIndex == 0 ? _teamAName : _teamBName,
        );
      } else {
        _showSetWinnerNotification(
          winnerTeamIndex == 0 ? _teamAName : _teamBName,
        );
      }
    });
  }

  void _showSetWinnerNotification(String winnerName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$winnerName venceu o set!'),
        duration: const Duration(days: 365),
        action: SnackBarAction(
          label: 'NOVO SET',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            _resetScores();
          },
        ),
      ),
    );
  }

  void _showGameWinnerNotification(String winnerName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$winnerName venceu o jogo!'),
        duration: const Duration(days: 365),
        action: SnackBarAction(
          label: 'NOVO JOGO',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            _resetGame();
          },
        ),
      ),
    );
  }

  void _resetScores() {
    setState(() {
      _scoreA = 0;
      _scoreB = 0;
      _timeoutsA = 0;
      _timeoutsB = 0;
      _isSetFinished = false;
    });
    _resetTimer();
    startTimer();
  }

  void _resetGame() {
    setState(() {
      _scoreA = 0;
      _scoreB = 0;
      _setsA = 0;
      _setsB = 0;
      _timeoutsA = 0;
      _timeoutsB = 0;
      _isSetFinished = false;
      _isGameFinished = false;
    });
    _resetTimer();
    pauseTimer();
  }

  void _showResetGameConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reiniciar Jogo?'),
          content: const Text('Você tem certeza que deseja reiniciar o jogo?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reiniciar'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetTimer() {
    setState(() {
      _start = 300;
    });
  }

  void _useTimeout(int team) {
    if (_isSetFinished || _isGameFinished) return;
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
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

  void _showTeamSelectionDialog(int teamIndex) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    if (playerProvider.teams.isEmpty) {
      _navigateToTeamManagement();
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecionar Time'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: playerProvider.teams.length,
              itemBuilder: (context, index) {
                final team = playerProvider.teams[index];
                final teamName = team['name']!;
                final bool isSelected =
                    (teamIndex == 0 && teamName == _teamBName) ||
                    (teamIndex == 1 && teamName == _teamAName);

                return ListTile(
                  title: Text(
                    teamName,
                    style: TextStyle(color: isSelected ? Colors.grey : null),
                  ),
                  onTap: () {
                    if (isSelected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Este time já está selecionado.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      if (teamIndex == 0) {
                        _teamAName = teamName;
                      } else {
                        _teamBName = teamName;
                      }
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _navigateToTeamManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TeamManagementScreen()),
    );
    if (!mounted) return;
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    if (playerProvider.teams.isNotEmpty) {
      setState(() {
        _teamAName = playerProvider.teams[0]['name'] ?? "Time A";
        _teamBName = playerProvider.teams.length > 1
            ? playerProvider.teams[1]['name'] ?? "Time B"
            : "Time B";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                _buildTeamColumn(
                  0,
                  _teamAName,
                  _scoreA,
                  _setsA,
                  settingsProvider.teamAColor,
                  settingsProvider.fontColor,
                  settingsProvider.timeoutsPerSet,
                ),
                _buildMiddleColumn(),
                _buildTeamColumn(
                  1,
                  _teamBName,
                  _scoreB,
                  _setsB,
                  settingsProvider.teamBColor,
                  settingsProvider.fontColor,
                  settingsProvider.timeoutsPerSet,
                ),
              ],
            ),
            if (_isCountdownVisible)
              TimerWidget(
                duration: settingsProvider.timerDuration,
                onTimerFinish: _hideCountdown,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiddleColumn() {
    return Expanded(
      flex: 6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _timerString,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          IconButton(
            icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
            iconSize: 30.0,
            onPressed: () {
              if (_isTimerRunning) {
                pauseTimer();
              } else {
                startTimer();
              }
            },
          ),
          const SizedBox(height: 10),
          IconButton(
            icon: const Icon(Icons.settings),
            iconSize: 30.0,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            iconSize: 30.0,
            onPressed: _showResetGameConfirmationDialog,
          ),
          const SizedBox(height: 10),
          IconButton(
            icon: const Icon(Icons.group_add),
            iconSize: 30.0,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeamBuilderScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(
    int teamIndex,
    String teamName,
    int score,
    int setsWon,
    Color color,
    Color fontColor,
    int timeoutsPerSet,
  ) {
    int timeoutsUsed = teamIndex == 0 ? _timeoutsA : _timeoutsB;
    return Expanded(
      flex: 17,
      child: GestureDetector(
        onTap: () => _incrementScore(teamIndex),
        onLongPress: () => _decrementScore(teamIndex),
        child: Card(
          margin: const EdgeInsets.all(4),
          color: color,
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => _showTeamSelectionDialog(teamIndex),
                    child: Text(
                      teamName,
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: fontColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(setsWon, (index) {
                      return Icon(
                        Icons.sports_volleyball,
                        color: fontColor,
                        size: 24,
                      );
                    }),
                  ),
                  Text(
                    score.toString(),
                    style: TextStyle(
                      fontSize: 120.0,
                      fontWeight: FontWeight.bold,
                      color: fontColor,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(timeoutsPerSet, (index) {
                      return IconButton(
                        icon: Icon(
                          index < timeoutsUsed ? Icons.timer_off : Icons.timer,
                          color: fontColor,
                          size: 30,
                        ),
                        onPressed: () => _useTimeout(teamIndex),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
