import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../models/jogador.dart';

class PlayerProvider with ChangeNotifier {
  final List<Jogador> _players = [];

  List<Jogador> get players => _players;

  PlayerProvider() {
    loadInitialPlayers();
  }

  Future<void> loadInitialPlayers() async {
    try {
      final rawData = await rootBundle.loadString('assets/database/jogadores.csv');
      List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
      for (var row in listData) {
          try {
            final nome = row[0].toString();
            final nivel = int.parse(row[1].toString());

            if (nivel >= 1 && nivel <= 5) {
              _players.add(Jogador(nome: nome, nivel: nivel));
            } else {
              debugPrint('Nível inválido para o jogador $nome: $nivel. O nível deve ser entre 1 e 5.');
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

  Future<void> importPlayersFromCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      final input = file.openRead();
      try {
        final fields = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter())
            .toList();

        for (var row in fields.skip(1)) { // Pula o cabeçalho do CSV
          try {
            final nome = row[0].toString();
            final nivel = int.parse(row[1].toString());

            if (nivel >= 1 && nivel <= 5) {
              _players.add(Jogador(nome: nome, nivel: nivel));
            } else {
              debugPrint('Nível inválido para o jogador $nome: $nivel. O nível deve ser entre 1 e 5.');
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
}
