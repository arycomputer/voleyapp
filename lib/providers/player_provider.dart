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

  List<Jogador> get players => _players;
  List<Map<String, dynamic>> get teams => _teams;

  PlayerProvider() {
    loadInitialPlayers();
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

  void updatePlayer(Jogador oldPlayer, Jogador newPlayer) {
    final index = _players.indexOf(oldPlayer);
    if (index != -1) {
      _players[index] = newPlayer;
      notifyListeners();
    }
  }

  Future<void> importPlayersFromCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.bytes != null) {
      try {
        final bytes = result.files.single.bytes!;
        final csvString = utf8.decode(bytes);
        final fields = const CsvToListConverter(eol: '\n').convert(csvString);

        for (var row in fields) {
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
        debugPrint('Erro ao ler ou processar o arquivo CSV: $e');
      }
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
    if (_players.isEmpty) {
      _teams = [];
      notifyListeners();
      return;
    }

    // Garante que os jogadores estejam ordenados por nível para uma distribuição mais justa.
    _players.sort((a, b) => b.nivel.compareTo(a.nivel));

    // Define o número máximo de jogadores por time.
    const maxPlayersPerTeam = 6;

    // Calcula o número de times, garantindo um mínimo de 2 times se houver jogadores suficientes.
    int numTeams = (_players.length / maxPlayersPerTeam).ceil();
    if (_players.length > 1 && numTeams < 2) {
      numTeams = 2;
    }

    if (numTeams == 0) {
      _teams = [];
      notifyListeners();
      return;
    }

    // Inicializa as equipes com nomes padrão e listas de jogadores vazias.
    _teams = List.generate(
      numTeams,
      (index) => {'name': 'Time ${index + 1}', 'players': <Jogador>[]},
    );

    // Distribui os jogadores entre as equipes de forma balanceada.
    int currentTeam = 0;
    bool forward = true;
    for (final player in _players) {
      _teams[currentTeam]['players'].add(player);

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

  void renameTeam(int teamIndex, String newName) {
    if (teamIndex >= 0 && teamIndex < _teams.length) {
      _teams[teamIndex]['name'] = newName;
      notifyListeners();
    }
  }

  void clearTeams() {
    _teams = [];
    notifyListeners();
  }
}
