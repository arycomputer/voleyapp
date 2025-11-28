import 'package:flutter/material.dart';
import 'dart:async';

import '../models/player.dart';

class PlacarScreen extends StatefulWidget {
  final List<Map<String, dynamic>> teams;

  const PlacarScreen({super.key, required this.teams});

  @override
  PlacarScreenState createState() => PlacarScreenState();
}

class PlacarScreenState extends State<PlacarScreen> {
  int _scoreA = 0;
  int _scoreB = 0;
  late Timer _timer;
  int _start = 300; // 5 minutos em segundos
  String _timeA = "Time A";
  String _timeB = "Time B";
  List<Player> _playersA = [];
  List<Player> _playersB = [];

  @override
  void initState() {
    super.initState();
    startTimer();
    if (widget.teams.isNotEmpty) {
      _playersA = (widget.teams[0]['players'] as List<dynamic>).cast<Player>().toList();
      if (widget.teams.length > 1) {
        _playersB = (widget.teams[1]['players'] as List<dynamic>).cast<Player>().toList();
      }
    }
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _incrementScore(int team) {
    setState(() {
      if (team == 0) {
        _scoreA++;
      } else {
        _scoreB++;
      }
    });
  }

  void _decrementScore(int team) {
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
    });
  }

  void _resetTimer() {
    setState(() {
      _start = 300;
    });
  }

  String get _timerString {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Placar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _resetScores();
              _resetTimer();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                _timerString,
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTeamColumn(0, _timeA, _scoreA, _playersA),
                  _buildTeamColumn(1, _timeB, _scoreB, _playersB),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamColumn(int teamIndex, String teamName, int score, List<Player> players) {
    return Expanded(
      child: Column(
        children: [
          Text(
            teamName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            score.toString(),
            style: const TextStyle(
              fontSize: 100,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => _decrementScore(teamIndex),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _incrementScore(teamIndex),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPlayerList(players),
        ],
      ),
    );
  }

  Widget _buildPlayerList(List<Player> players) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return Card(
          child: ListTile(
            title: Text(player.name),
            trailing: Text('(${player.habilidade})'),
          ),
        );
      },
    );
  }
}
