import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/player.dart';

class TeamBuilderScreen extends StatefulWidget {
  const TeamBuilderScreen({super.key});

  @override
  TeamBuilderScreenState createState() => TeamBuilderScreenState();
}

class TeamBuilderScreenState extends State<TeamBuilderScreen> {
  final List<Player> _players = [];
  List<List<Player>> _teams = [];
  final List<TextEditingController> _teamNameControllers = [];

  @override
  void dispose() {
    for (var controller in _teamNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPlayer(String name, int habilidade) {
    if (name.isNotEmpty) {
      setState(() {
        _players.add(Player(name: name, habilidade: habilidade));
      });
    }
  }

  void _editPlayer(int index, String newName, int newHabilidade) {
    if (newName.isNotEmpty) {
      setState(() {
        _players[index] = Player(name: newName, habilidade: newHabilidade);
      });
    }
  }

  void _showAddPlayerDialog() {
    final nameController = TextEditingController();
    int habilidade = 3;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Jogador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome do Jogador'),
              autofocus: true,
            ),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Text('Habilidade: $habilidade'),
                    Slider(
                      value: habilidade.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: habilidade.toString(),
                      onChanged: (value) {
                        setState(() {
                          habilidade = value.round();
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _addPlayer(nameController.text, habilidade);
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showEditPlayerDialog(int index, Player player) {
    final nameController = TextEditingController(text: player.name);
    int habilidade = player.habilidade;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Jogador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome do Jogador'),
              autofocus: true,
            ),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Text('Habilidade: $habilidade'),
                    Slider(
                      value: habilidade.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: habilidade.toString(),
                      onChanged: (value) {
                        setState(() {
                          habilidade = value.round();
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _editPlayer(index, nameController.text, habilidade);
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _balanceTeams() {
    if (_players.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'É necessário ter pelo menos 12 jogadores para montar dois times de 6.')),
      );
      return;
    }

    List<Player> sortedPlayers = List.from(_players);
    sortedPlayers.sort((a, b) => b.habilidade.compareTo(a.habilidade));

    int numberOfTeams = (_players.length / 6).floor();
    List<List<Player>> teams = List.generate(numberOfTeams, (_) => []);
    List<int> teamScores = List.generate(numberOfTeams, (_) => 0);

    for (var controller in _teamNameControllers) {
      controller.dispose();
    }
    _teamNameControllers.clear();

    for (int i = 0; i < numberOfTeams; i++) {
      _teamNameControllers.add(TextEditingController(text: 'Time ${i + 1}'));
    }

    for (var player in sortedPlayers) {
      int targetTeam = 0;
      int minScore = teamScores[0];

      for (int i = 1; i < numberOfTeams; i++) {
        if (teamScores[i] < minScore) {
          minScore = teamScores[i];
          targetTeam = i;
        }
      }

      teams[targetTeam].add(player);
      teamScores[targetTeam] += player.habilidade;
    }

    setState(() {
      _teams = teams;
    });
  }

  Future<void> _importPlayersFromAssets() async {
    try {
      final String csvString = await rootBundle.loadString(
        'assets/database/jogadores.csv',
      );
      final List<List<dynamic>> fields = const CsvToListConverter().convert(
        csvString,
        fieldDelimiter: ',',
        eol: '\r\n',
      );

      setState(() {
        _players.clear(); // Limpa a lista de jogadores existentes
        // Começa em 1 para pular a linha de cabeçalho
        for (var i = 1; i < fields.length; i++) {
          final row = fields[i];
          if (row.length >= 2) {
            final name = row[0].toString();
            try {
              final habilidade = int.parse(row[1].toString());
              _players.add(Player(name: name, habilidade: habilidade));
            } catch (e) {
              if (kDebugMode) {
                print('Não foi possível analisar a linha: $row, erro: $e');
              }
            }
          }
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jogadores da base de dados importados com sucesso!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao importar jogadores: $e')));
    }
  }

  void _importPlayersFromCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      final bytes = result.files.single.bytes;
      if (bytes == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum arquivo selecionado.')),
        );
        return;
      }

      final input = utf8.decode(bytes);
      final fields = const CsvToListConverter()
          .convert(input, fieldDelimiter: ',', eol: '\r\n');

      setState(() {
        for (var i = 1; i < fields.length; i++) {
          final row = fields[i];
          if (row.length >= 2) {
            final name = row[0].toString();
            final habilidade = int.tryParse(row[1].toString());
            if (habilidade != null) {
              _players.add(Player(name: name, habilidade: habilidade));
            }
          }
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jogadores importados com sucesso!')),
      );
    }
  }

  void _exportPlayersToCsv() async {
    if (_players.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum jogador para exportar.')),
      );
      return;
    }
    List<List<dynamic>> rows = [];
    rows.add(['Nome', 'Habilidade']);
    for (var player in _players) {
      rows.add([player.name, player.habilidade]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final bytes = Uint8List.fromList(utf8.encode(csv));

    try {
      final path = await FileSaver.instance.saveFile(
        name: 'jogadores.csv',
        bytes: bytes,
        mimeType: MimeType.csv,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jogadores exportados para $path')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao exportar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Montar Times'),
        actions: [
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: _importPlayersFromAssets,
            tooltip: 'Importar da Base de Dados',
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: _importPlayersFromCsv,
            tooltip: 'Importar de Arquivo CSV',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportPlayersToCsv,
            tooltip: 'Exportar CSV',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddPlayerDialog,
            tooltip: 'Adicionar Jogador',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: _players.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Nenhum jogador adicionado.'),
                ),
              )
            : Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _players.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 3,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemBuilder: (context, index) {
                      final player = _players[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  player.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text('(${player.habilidade})'),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                onPressed: () => _showEditPlayerDialog(index, player),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _players.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: _balanceTeams,
                      child: const Text('Sortear Times'),
                    ),
                  ),
                  if (_teams.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _teams.asMap().entries.map((entry) {
                        int index = entry.key;
                        List<Player> team = entry.value;
                        return _buildTeamList(index, team);
                      }).toList(),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final teamsWithNames = _teams.asMap().entries.map((entry) {
            int index = entry.key;
            List<Player> team = entry.value;
            return {
              'name': _teamNameControllers[index].text,
              'players': team,
            };
          }).toList();
          Navigator.pop(context, {'teams': teamsWithNames});
        },
        tooltip: 'Confirmar Times',
        child: const Icon(Icons.check),
      ),
    );
  }

  Widget _buildTeamList(int teamIndex, List<Player> team) {
    final int totalHabilidade = team.fold(0, (sum, player) => sum + player.habilidade);
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3.3,
      child: Card(
        margin: const EdgeInsets.all(0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _teamNameControllers[teamIndex],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Pontuação: $totalHabilidade', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: team.length,
              itemBuilder: (context, index) {
                final player = team[index];
                return ListTile(
                  title: Text('${player.name} (${player.habilidade})', style: Theme.of(context).textTheme.bodyMedium),
                  dense: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
