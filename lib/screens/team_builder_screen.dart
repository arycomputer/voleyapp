import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../models/jogador.dart';

class TeamBuilderScreen extends StatelessWidget {
  const TeamBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Montar Times'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPlayerDialog(context, playerProvider),
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: () => playerProvider.importPlayersFromCsv(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: playerProvider.players.length,
        itemBuilder: (context, index) {
          final player = playerProvider.players[index];
          return ListTile(
            title: Text(player.nome),
            trailing: Text('Nível: ${player.nivel}'),
          );
        },
      ),
    );
  }

  void _showAddPlayerDialog(BuildContext context, PlayerProvider playerProvider) {
    final nameController = TextEditingController();
    final levelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Jogador'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: levelController,
                decoration: const InputDecoration(labelText: 'Nível (1-5)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final level = int.tryParse(levelController.text) ?? 0;

                if (name.isNotEmpty && level >= 1 && level <= 5) {
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
}
