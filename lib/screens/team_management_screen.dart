import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/jogador.dart';
import '../providers/player_provider.dart';
import 'placar_screen.dart';
import 'team_builder_screen.dart';

class TeamManagementScreen extends StatelessWidget {
  const TeamManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Times'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.build),
              label: const Text('Gerar Novos Times'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeamBuilderScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                  double.infinity,
                  50,
                ), // Make button wider
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: playerProvider.teams.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum time foi gerado ainda. Clique em "Gerar Novos Times" para começar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : _buildTeamsView(context, playerProvider),
          ),
        ],
      ),
      floatingActionButton: playerProvider.teams.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const PlacarScreen(),
                  ),
                );
              },
              label: const Text('Usar no Placar'),
              icon: const Icon(Icons.arrow_forward),
            )
          : null,
    );
  }

  Widget _buildTeamsView(BuildContext context, PlayerProvider playerProvider) {
    return ListView.builder(
      itemCount: playerProvider.teams.length,
      itemBuilder: (context, index) {
        final teamData = playerProvider.teams[index];
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
                    title: Text(player.nome),
                    trailing: Text('Nível: ${player.nivel}'),
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
