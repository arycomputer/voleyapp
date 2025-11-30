import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/jogador.dart';
import '../providers/player_provider.dart';
import '../providers/theme_provider.dart';

class TeamBuilderScreen extends StatelessWidget {
  const TeamBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Gerenciar Jogadores'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPlayerDialog(context, playerProvider),
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: () => playerProvider.importPlayersFromCsv(),
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => playerProvider.exportPlayersToCsv(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.groups),
                  label: const Text('Gerar Times'),
                  onPressed: playerProvider.players.isNotEmpty
                      ? () {
                          playerProvider.generateTeams();
                          Navigator.pop(
                            context,
                          ); // Go back to the management screen
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50), // Set a minimum size
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Limpar Times'),
                  onPressed: playerProvider.teams.isNotEmpty
                      ? () => playerProvider.clearTeams()
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50), // Set a minimum size
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(child: _buildPlayersList(playerProvider)),
        ],
      ),
    );
  }

  Widget _buildPlayersList(PlayerProvider playerProvider) {
    if (playerProvider.players.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum jogador cadastrado. Adicione jogadores para começar.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      itemCount: playerProvider.players.length,
      itemBuilder: (context, index) {
        final player = playerProvider.players[index];
        return ListTile(
          title: Text(player.nome),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nível: ${player.nivel}'),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    _showEditPlayerDialog(context, playerProvider, player),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => playerProvider.removePlayer(player),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddPlayerDialog(
    BuildContext context,
    PlayerProvider playerProvider,
  ) {
    final nameController = TextEditingController();
    double currentLevel = 3.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Jogador'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  Text('Nível: ${currentLevel.round()}'),
                  Slider(
                    value: currentLevel,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: currentLevel.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        currentLevel = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final level = currentLevel.round();

                if (name.isNotEmpty) {
                  playerProvider.addPlayer(Jogador(nome: name, nivel: level));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPlayerDialog(
    BuildContext context,
    PlayerProvider playerProvider,
    Jogador oldPlayer,
  ) {
    final nameController = TextEditingController(text: oldPlayer.nome);
    double currentLevel = oldPlayer.nivel.toDouble();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Jogador'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  Text('Nível: ${currentLevel.round()}'),
                  Slider(
                    value: currentLevel,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: currentLevel.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        currentLevel = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final level = currentLevel.round();

                if (name.isNotEmpty) {
                  final newPlayer = Jogador(nome: name, nivel: level);
                  playerProvider.updatePlayer(oldPlayer, newPlayer);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}
