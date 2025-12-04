import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/jogador.dart';
import '../providers/player_provider.dart';

class TeamBuilderScreen extends StatefulWidget {
  const TeamBuilderScreen({super.key});

  @override
  State<TeamBuilderScreen> createState() => _TeamBuilderScreenState();
}

class _TeamBuilderScreenState extends State<TeamBuilderScreen> {
  late int _selectedPlayersPerTeam;

  @override
  void initState() {
    super.initState();
    _selectedPlayersPerTeam =
        Provider.of<PlayerProvider>(context, listen: false).playersPerTeam;
  }

  Color _getColorForNivel(int nivel) {
    if (nivel <= 2) {
      return Colors.red.withAlpha(77);
    } else if (nivel <= 4) {
      return Colors.yellow.withAlpha(77);
    } else {
      return Colors.green.withAlpha(77);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final playerProvider = Provider.of<PlayerProvider>(context);

    final bool canGenerateTeams = playerProvider.players.length >= _selectedPlayersPerTeam;
    final int requiredPlayers = _selectedPlayersPerTeam;

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
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPlayerDialog(context, playerProvider),
          ),
          IconButton(
            icon: const Icon(Icons.content_paste),
            onPressed: () => _showPastePlayerDialog(context, playerProvider),
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: () => _importPlayers(playerProvider),
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Jogadores por time:'),
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      value: _selectedPlayersPerTeam,
                      items: List.generate(9, (index) => index + 2)
                          .map((e) => DropdownMenuItem<int>(
                                value: e,
                                child: Text(e.toString()),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPlayersPerTeam = newValue;
                          });
                          playerProvider.setPlayersPerTeam(newValue);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.groups),
                      label: const Text('Gerar Times'),
                      onPressed: canGenerateTeams
                          ? () {
                              playerProvider.generateTeams();
                              if (playerProvider.teams.isNotEmpty) {
                                //Navigator.pop(context);
                              } else {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Não há jogadores suficientes para formar pelo menos um time.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(150, 50),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete_sweep),
                      label: const Text('Limpar Times'),
                      onPressed: playerProvider.teams.isNotEmpty
                          ? () => playerProvider.clearTeams()
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(150, 50),
                      ),
                    ),
                  ],
                ),
                if (!canGenerateTeams)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      'São necessários pelo menos $requiredPlayers jogadores para gerar os times.',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: playerProvider.teams.isEmpty
                ? _buildPlayersList(context, playerProvider)
                : _buildTeams(context, playerProvider),
          ),
        ],
      ),
    );
  }

  Future<void> _importPlayers(PlayerProvider playerProvider) async {
    final result = await playerProvider.importPlayersFromCsv();

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] as String),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final message = result['message'] as String?;
      final errors = result['errors'] as List<String>?;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro na Importação'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  if (message != null) Text(message),
                  if (errors != null && errors.isNotEmpty)
                    ...errors.map((error) => Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                          child: Text('- $error'),
                        )),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildTeams(BuildContext context, PlayerProvider playerProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: playerProvider.teams.map((teamData) {
        final teamName = teamData['name'] as String;
        final team = teamData['players'] as List<Jogador>;
        final averageLevel = playerProvider.getTeamAverageLevel(team);

        return Expanded(
          child: DragTarget<Jogador>(
            onWillAcceptWithDetails: (details) {
              final draggedPlayerTeam = playerProvider.getTeamForPlayer(details.data);
              return draggedPlayerTeam != teamName;
            },
            onAcceptWithDetails: (details) {
              playerProvider.movePlayer(details.data, teamName);
            },
            builder: (context, candidateData, rejectedData) {
              return Card(
                elevation: 4,
                margin: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              teamName,
                              style: Theme.of(context).textTheme.titleLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showEditTeamNameDialog(
                                context, playerProvider, teamName),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Nível: ${averageLevel.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: team.length,
                        itemBuilder: (context, index) {
                          final player = team[index];
                          return Draggable<Jogador>(
                            data: player,
                            feedback: Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(player.nome),
                              ),
                            ),
                            childWhenDragging: Container(),
                            child: DragTarget<Jogador>(
                              onWillAcceptWithDetails: (details) {
                                final draggedPlayer = details.data;
                                return player != draggedPlayer;
                              },
                              onAcceptWithDetails: (details) {
                                playerProvider.swapPlayers(details.data, player);
                              },
                              builder: (context, candidateData, rejectedData) {
                                return ListTile(
                                  tileColor: _getColorForNivel(player.nivel),
                                  title: Text(player.nome),
                                  subtitle: Text('Nível: ${player.nivel}'),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  void _showEditTeamNameDialog(
      BuildContext context, PlayerProvider playerProvider, String oldName) {
    final nameController = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Nome do Time'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Novo nome'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final newName = nameController.text;
                if (newName.isNotEmpty) {
                  playerProvider.renameTeam(oldName, newName);
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

  Widget _buildPlayersList(BuildContext context, PlayerProvider playerProvider) {
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
          tileColor: _getColorForNivel(player.nivel),
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
                onPressed: () => _showDeleteConfirmationDialog(
                    context, playerProvider, player),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    PlayerProvider playerProvider,
    Jogador player,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
              'Você tem certeza que deseja excluir o jogador "${player.nome}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                playerProvider.removePlayer(player);
                Navigator.of(context).pop();
              },
              child: const Text('Excluir'),
            ),
          ],
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
              return SingleChildScrollView(
                child: Column(
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
                ),
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
              return SingleChildScrollView(
                child: Column(
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
                ),
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

  void _showPastePlayerDialog(
    BuildContext context,
    PlayerProvider playerProvider,
  ) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Colar Lista de Jogadores'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'Cole os nomes, um por linha',
              alignLabelWithHint: true,
            ),
            maxLines: 10,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final pastedText = textController.text;
                if (pastedText.isNotEmpty) {
                  final lines = pastedText
                      .split('\n')
                      .where((line) => line.trim().isNotEmpty)
                      .toList();
                  for (var line in lines) {
                    final parts = line.split(',');
                    final name = parts[0].trim();
                    final nivel = parts.length > 1 ? int.tryParse(parts[1].trim()) ?? 3 : 3;
                    playerProvider.addPlayer(
                        Jogador(nome: name, nivel: nivel));
                  }
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
