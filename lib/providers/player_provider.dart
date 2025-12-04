import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../models/jogador.dart';
import '../services/file_service_factory.dart';

class PlayerProvider with ChangeNotifier {
  final List<Jogador> _players = [];
  List<Map<String, dynamic>> _teams = [];
  int _playersPerTeam = 6;

  List<Jogador> get players => _players;
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

  double getTeamAverageLevel(List<Jogador> team) {
    if (team.isEmpty) {
      return 0.0;
    }
    final totalLevel = team.fold(0, (sum, player) => sum + player.nivel);
    return totalLevel / team.length;
  }

  String? getTeamForPlayer(Jogador player) {
    for (final team in _teams) {
      if ((team['players'] as List<Jogador>).contains(player)) {
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
      ).convert(normalizedData);
      for (var row in listData) {
        try {
          final nome = row[0].toString();
          final nivel = int.parse(row[1].toString());

          if (nome.isNotEmpty && nivel >= 1 && nivel <= 5) {
            _players.add(Jogador(nome: nome, nivel: nivel));
          } else {
            debugPrint('Dados inválidos para o jogador: $row');
          }
        } catch (e) {
          debugPrint('Erro ao processar a linha do CSV: $row. Erro: $e');
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao carregar jogadores iniciais: $e");
    }
  }

  void addPlayer(Jogador player) {
    _players.add(player);
    notifyListeners();
  }

  void removePlayer(Jogador player) {
    _players.remove(player);
    notifyListeners();
  }

  void clearPlayers() {
    _players.clear();
    _teams.clear();
    notifyListeners();
  }

  void updatePlayer(Jogador oldPlayer, Jogador newPlayer) {
    final index = _players.indexOf(oldPlayer);
    if (index != -1) {
      _players[index] = newPlayer;
      notifyListeners();
    }
  }

  void movePlayer(Jogador player, String toTeamName) {
    String? fromTeamName;

    for (final team in _teams) {
      if ((team['players'] as List<Jogador>).contains(player)) {
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
          (team['players'] as List<Jogador>).remove(player);
          break;
        }
      }
    }

    for (final team in _teams) {
      if (team['name'] == toTeamName) {
        (team['players'] as List<Jogador>).add(player);
        break;
      }
    }

    notifyListeners();
  }

  void swapPlayers(Jogador player1, Jogador player2) {
    String? teamName1;
    String? teamName2;
    int? index1;
    int? index2;

    for (final team in _teams) {
      final players = team['players'] as List<Jogador>;
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
          final players = team['players'] as List<Jogador>;
          players.removeAt(index1);
          players.insert(index1, player2);
        }
      }

      for (final team in _teams) {
        if (team['name'] == teamName2) {
          final players = team['players'] as List<Jogador>;
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

    final List<Jogador> newPlayers = [];
    final List<String> errors = [];

    try {
      final bytes = result.files.single.bytes!;
      final csvString = utf8.decode(bytes);
      final normalizedCsv = csvString.replaceAll('\r\n', '\n');
      final fields = const CsvToListConverter(eol: '\n').convert(normalizedCsv);

      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];
        final lineNumber = i + 1;

        if (row.length < 2) {
          errors.add('Linha $lineNumber: Formato inválido.');
          continue;
        }

        try {
          final nome = row[0].toString().trim();
          final nivel = int.parse(row[1].toString());

          if (nome.isNotEmpty && nivel >= 1 && nivel <= 5) {
            newPlayers.add(Jogador(nome: nome, nivel: nivel));
          } else {
            errors.add(
                'Linha $lineNumber: Dados inválidos (Nome: "$nome", Nível: $nivel).');
          }
        } on FormatException {
          errors.add(
              'Linha $lineNumber: Nível inválido (valor: "${row[1]}"). O nível deve ser um número.');
        } catch (e) {
          errors.add(
              'Linha $lineNumber: Erro inesperado ao processar: $e');
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
    rows.add(["Nome", "Nível"]);
    for (var player in _players) {
      rows.add([player.nome, player.nivel]);
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

  void generateTeams() {
    if (_players.length < _playersPerTeam) {
      _teams = [];
      notifyListeners();
      return;
    }

    _players.sort((a, b) => b.nivel.compareTo(a.nivel));

    final int numTeams = (_players.length / _playersPerTeam).floor();

    if (numTeams < 1) {
      _teams = [];
      notifyListeners();
      return;
    }

    final List<Jogador> playersToDistribute =
        _players.sublist(0, numTeams * _playersPerTeam);

    _teams = List.generate(
      numTeams,
      (index) => {'name': 'Time ${index + 1}', 'players': <Jogador>[]},
    );

    int currentTeam = 0;
    bool forward = true;
    for (final player in playersToDistribute) {
      (_teams[currentTeam]['players'] as List<Jogador>).add(player);

      if (forward) {
        currentTeam++;
        if (currentTeam == numTeams) {
          forward = false;
          currentTeam--;
        }
      } else {
        currentTeam--;
        if (currentTeam < 0) {
          forward = true;
          currentTeam++;
        }
      }
    }

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
