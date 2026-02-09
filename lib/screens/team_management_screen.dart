import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../providers/player_provider.dart';

class TeamManagementScreen extends StatelessWidget {
  const TeamManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Times'),
      ),
      body: Consumer<PlayerProvider>(
        builder: (context, playerProvider, child) {
          if (playerProvider.teams.isEmpty) {
            return const Center(
              child: Text('Nenhum time foi gerado ainda.'),
            );
          }

          return ListView.builder(
            itemCount: playerProvider.teams.length,
            itemBuilder: (context, index) {
              final team = playerProvider.teams[index];
              final players = team['players'] as List<Player>;
              final teamLevel = players.fold(0, (sum, player) => sum + player.level);

              return Card(
                margin: const EdgeInsets.all(12.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nível Total do Time: $teamLevel',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Divider(height: 20),
                      const Text(
                        'Jogadores:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...players.map((player) => Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '  - ${player.name} (Nível: ${player.level})',
                            ),
                          )),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
