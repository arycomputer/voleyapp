import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/jogador.dart';
import '../providers/player_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estatísticas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Jogadores', icon: Icon(Icons.person)),
              Tab(text: 'Times', icon: Icon(Icons.group)),
            ],
          ),
        ),
        body: const TabBarView(children: [PlayerStatsTab(), TeamStatsTab()]),
      ),
    );
  }
}

class PlayerStatsTab extends StatelessWidget {
  const PlayerStatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final players = Provider.of<PlayerProvider>(context).players;

    if (players.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum jogador cadastrado.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            leading: CircleAvatar(child: Text(player.nivel.toString())),
            title: Text(
              player.nome,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Nível: ${player.nivel}'),
          ),
        );
      },
    );
  }
}

class TeamStatsTab extends StatelessWidget {
  const TeamStatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final teams = Provider.of<PlayerProvider>(context).teams;

    if (teams.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum time gerado.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final teamData = teams[index];
        final String teamName = teamData['name'];
        final List<Jogador> players = teamData['players'] as List<Jogador>;

        final teamAverage = players.isNotEmpty
            ? players.map((p) => p.nivel).reduce((a, b) => a + b) /
                  players.length
            : 0.0;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$teamName (Média: ${teamAverage.toStringAsFixed(2)})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                ...players.map(
                  (player) => ListTile(
                    leading: CircleAvatar(child: Text(player.nivel.toString())),
                    title: Text(player.nome),
                    dense: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
