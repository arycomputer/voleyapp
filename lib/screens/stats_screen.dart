import 'package:flutter/material.dart';
import '../models/player.dart';

class StatsScreen extends StatelessWidget {
  final Map<String, int> playerPoints;
  final List<Player> teamA;
  final List<Player> teamB;

  const StatsScreen({
    super.key,
    required this.playerPoints,
    required this.teamA,
    required this.teamB,
  });

  @override
  Widget build(BuildContext context) {
    final teamAPlayers = teamA.map((p) => p.name).toSet();

    final teamAPoints = playerPoints.entries
        .where((entry) => teamAPlayers.contains(entry.key))
        .toList();

    final teamBPoints = playerPoints.entries
        .where((entry) => !teamAPlayers.contains(entry.key))
        .toList();

    teamAPoints.sort((a, b) => b.value.compareTo(a.value));
    teamBPoints.sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTeamStats('Time A', teamAPoints)),
              const SizedBox(width: 20),
              Expanded(child: _buildTeamStats('Time B', teamBPoints)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamStats(String title, List<MapEntry<String, int>> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (points.isEmpty)
          const Text('Nenhum ponto marcado.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: points.length,
            itemBuilder: (context, index) {
              final entry = points[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(entry.value.toString())),
                  title: Text(entry.key),
                ),
              );
            },
          ),
      ],
    );
  }
}
