import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../models/player.dart';
import '../services/file_service_factory.dart';

class PlayerProvider with ChangeNotifier {
  final List<Player> _players = [];
  List<Map<String, dynamic>> _teams = [];
  int _playersPerTeam = 6;

  List<Player> get players => _players;
  List<Map<String, dynamic>> get teams => _teams;
  int get playersPerTeam => _playersPerTeam;

  PlayerProvider() {
    loadInitialPlayers();
  }

  void setPlayersPerTeam(int count) {
    if (count > 0) {
      _playersPerTeam = count;
      notifyListeners();
    }
  }

  double getTeamAverageLevel(List<Player> team) {
    if (team.isEmpty) {
      return 0.0;
    }
    final totalLevel = team.fold(0, (sum, player) => sum + player.level);
    return totalLevel / team.length;
  }

  String? getTeamForPlayer(Player player) {
    for (final team in _teams) {
      if ((team['players'] as List<Player>).contains(player)) {
        return team['name'];
      }
    }
    return null;
  }

  Future<void> loadInitialPlayers() async {
    try {
      final rawData = await rootBundle.loadString(
        'assets/database/jogadores.csv',
      );
      final normalizedData = rawData.replaceAll('\r\n', '\n');
      List<List<dynamic>> listData = const CsvToListConverter(
        eol: '\n',
        fieldDelimiter: ',',
      ).convert(normalizedData);

      // Skip header row
      for (var i = 1; i < listData.length; i++) {
        var row = listData[i];
        try {
          final name = row[0].toString();
          final level = int.parse(row[1].toString());
          final position =
              row.length > 2 ? row[2].toString() : 'Não especificado';
          final isAvailable =
              row.length > 3 ? row[3].toString().toLowerCase() == 'true' : true;

          if (name.isNotEmpty && level >= 1 && level <= 5) {
            _players.add(Player(
              name: name,
              level: level,
              position: position,
              isAvailable: isAvailable,
            ));
          } else {
            developer.log('Dados inválidos para o jogador: $row',
                name: 'player_provider.loadInitialPlayers');
          }
        } catch (e) {
          developer.log('Erro ao processar a linha do CSV: $row. Erro: $e',
              name: 'player_provider.loadInitialPlayers');
        }
      }
      notifyListeners();
    } catch (e) {
      developer.log("Erro ao carregar jogadores iniciais: $e",
          name: 'player_provider.loadInitialPlayers');
    }
  }

  void addPlayer(Player player) {
    _players.add(player);
    notifyListeners();
  }

  void removePlayer(Player player) {
    _players.remove(player);
    notifyListeners();
  }

  void clearPlayers() {
    _players.clear();
    _teams.clear();
    notifyListeners();
  }

  void updatePlayer(Player oldPlayer, Player newPlayer) {
    final index = _players.indexOf(oldPlayer);
    if (index != -1) {
      _players[index] = newPlayer;
      notifyListeners();
    }
  }

  void movePlayer(Player player, String toTeamName) {
    String? fromTeamName;

    for (final team in _teams) {
      if ((team['players'] as List<Player>).contains(player)) {
        fromTeamName = team['name'];
        break;
      }
    }

    if (fromTeamName == toTeamName) {
      return;
    }

    if (fromTeamName != null) {
      for (final team in _teams) {
        if (team['name'] == fromTeamName) {
          (team['players'] as List<Player>).remove(player);
          break;
        }
      }
    }

    for (final team in _teams) {
      if (team['name'] == toTeamName) {
        (team['players'] as List<Player>).add(player);
        break;
      }
    }

    notifyListeners();
  }

  void swapPlayers(Player player1, Player player2) {
    String? teamName1;
    String? teamName2;
    int? index1;
    int? index2;

    for (final team in _teams) {
      final players = team['players'] as List<Player>;
      if (players.contains(player1)) {
        teamName1 = team['name'];
        index1 = players.indexOf(player1);
      }
      if (players.contains(player2)) {
        teamName2 = team['name'];
        index2 = players.indexOf(player2);
      }
    }

    if (teamName1 != null &&
        teamName2 != null &&
        index1 != null &&
        index2 != null &&
        teamName1 != teamName2) {
      for (final team in _teams) {
        if (team['name'] == teamName1) {
          final players = team['players'] as List<Player>;
          players.removeAt(index1);
          players.insert(index1, player2);
        }
      }

      for (final team in _teams) {
        if (team['name'] == teamName2) {
          final players = team['players'] as List<Player>;
          players.removeAt(index2);
          players.insert(index2, player1);
        }
      }

      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> importPlayersFromCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.single.bytes == null) {
      return {'success': false, 'message': 'Seleção de arquivo cancelada.'};
    }

    final List<Player> newPlayers = [];
    final List<String> errors = [];

    try {
      final bytes = result.files.single.bytes!;
      final csvString = utf8.decode(bytes);
      final normalizedCsv = csvString.replaceAll('\r\n', '\n');
      final fields = const CsvToListConverter(eol: '\n').convert(normalizedCsv);

      // Skip header
      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];
        final lineNumber = i + 1;

        if (row.length < 2) {
          errors.add('Linha $lineNumber: Formato inválido.');
          continue;
        }

        try {
          final name = row[0].toString().trim();
          final level = int.parse(row[1].toString());
          final position =
              row.length > 2 ? row[2].toString().trim() : 'Não especificado';
          final isAvailable = row.length > 3
              ? row[3].toString().trim().toLowerCase() == 'true'
              : true;

          if (name.isNotEmpty && level >= 1 && level <= 5) {
            newPlayers.add(Player(
                name: name,
                level: level,
                position: position,
                isAvailable: isAvailable));
          } else {
            errors.add(
                'Linha $lineNumber: Dados inválidos (Nome: "$name", Nível: $level).');
          }
        } on FormatException {
          errors.add(
              'Linha $lineNumber: Nível inválido (valor: "${row[1]}"). O nível deve ser um número.');
        } catch (e) {
          errors.add('Linha $lineNumber: Erro inesperado ao processar: $e');
        }
      }

      if (errors.isNotEmpty) {
        return {
          'success': false,
          'message': 'Encontramos alguns erros no arquivo:',
          'errors': errors,
        };
      } else {
        _players.addAll(newPlayers);
        notifyListeners();
        return {
          'success': true,
          'message': '${newPlayers.length} jogadores importados com sucesso!'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao ler ou processar o arquivo CSV: $e'
      };
    }
  }

  Future<void> exportPlayersToCsv() async {
    List<List<dynamic>> rows = [];
    rows.add(["Name", "Level", "Position", "IsAvailable"]);
    for (var player in _players) {
      rows.add(
          [player.name, player.level, player.position, player.isAvailable]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    Uint8List bytes = Uint8List.fromList(utf8.encode(csv));

    final fileService = getFileService();
    await fileService.saveFile(
      name: 'jogadores.csv',
      bytes: bytes,
      mimeType: 'text/csv',
    );
  }

  void generateTeams({int? numberOfTeams}) {
    final availablePlayers = _players.where((p) => p.isAvailable).toList();

    if (availablePlayers.isEmpty ||
        (numberOfTeams != null && numberOfTeams <= 0)) {
      _teams = [];
      notifyListeners();
      return;
    }

    int numTeams;
    if (numberOfTeams != null) {
      // Garante que o número de times não é maior que o número de jogadores
      numTeams = min(numberOfTeams, availablePlayers.length);
    } else {
      // Se o número de times não for fornecido, calcula com base no número de jogadores por time
      if (_playersPerTeam <= 0) {
        _teams = [];
        notifyListeners();
        return;
      }
      numTeams = (availablePlayers.length / _playersPerTeam).ceil();
    }

    if (numTeams <= 0) {
      _teams = [];
      notifyListeners();
      return;
    }

    // Garante que um dos times tenha o mínimo de jogadores
    if (availablePlayers.length < _playersPerTeam) {
      developer.log(
          "Não há jogadores suficientes para formar um time com o mínimo de jogadores selecionado.",
          name: 'player_provider.generateTeams');
      _teams = [];
      notifyListeners();
      return;
    }

    _teams = List.generate(
      numTeams,
      (index) => {
        'name': 'Time ${index + 1}',
        'players': <Player>[],
      },
    );

    // Ordena os jogadores por nível para garantir uma distribuição equilibrada
    availablePlayers.sort((a, b) => b.level.compareTo(a.level));

    // Distribui os jogadores em um padrão "cobra" (snake draft) para balancear melhor.
    int teamIndex = 0;
    int direction = 1;
    for (final player in availablePlayers) {
      (_teams[teamIndex]['players'] as List<Player>).add(player);
      teamIndex += direction;
      if (teamIndex < 0 || teamIndex >= numTeams) {
        direction *= -1;
        teamIndex += direction;
      }
    }

    // Reordena os times pelo nome para exibição consistente.
    _teams.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

    notifyListeners();
  }

  void renameTeam(String oldName, String newName) {
    for (final team in _teams) {
      if (team['name'] == oldName) {
        team['name'] = newName;
        break;
      }
    }
    notifyListeners();
  }

  void clearTeams() {
    _teams = [];
    notifyListeners();
  }
}
