import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Terminar jogo com 3 sets vencidos'),
            value: settings.endGameAtThreeSets,
            onChanged: (value) {
              settings.setEndGameAtThreeSets(value);
            },
          ),
          ListTile(
            title: const Text('Tempos por Set'),
            trailing: DropdownButton<int>(
              value: settings.timeoutsPerSet,
              items: [0, 1, 2, 3].map((timeouts) {
                return DropdownMenuItem(
                  value: timeouts,
                  child: Text(timeouts.toString()),
                );
              }).toList(),
              onChanged: (timeouts) {
                if (timeouts != null) {
                  settings.setTimeoutsPerSet(timeouts);
                }
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Marcar pontuação por jogador'),
            value: settings.trackPlayerStats,
            onChanged: (value) {
              settings.setTrackPlayerStats(value);
            },
          ),
          ListTile(
            title: const Text('Tema'),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('Sistema'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Claro')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Escuro')),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  settings.setThemeMode(mode);
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Cor do Time A'),
            trailing: CircleAvatar(backgroundColor: settings.teamAColor),
            onTap: () => _pickColor(context, settings, 'teamA'),
          ),
          ListTile(
            title: const Text('Cor do Time B'),
            trailing: CircleAvatar(backgroundColor: settings.teamBColor),
            onTap: () => _pickColor(context, settings, 'teamB'),
          ),
          ListTile(
            title: const Text('Cor da Fonte'),
            trailing: CircleAvatar(backgroundColor: settings.fontColor),
            onTap: () => _pickColor(context, settings, 'font'),
          ),
          ListTile(
            title: const Text('Cor do Fundo'),
            trailing: CircleAvatar(backgroundColor: settings.backgroundColor),
            onTap: () => _pickColor(context, settings, 'background'),
          ),
        ],
      ),
    );
  }

  void _pickColor(
    BuildContext context,
    SettingsProvider settings,
    String type,
  ) {
    Color currentColor;
    switch (type) {
      case 'teamA':
        currentColor = settings.teamAColor;
        break;
      case 'teamB':
        currentColor = settings.teamBColor;
        break;
      case 'font':
        currentColor = settings.fontColor;
        break;
      case 'background':
        currentColor = settings.backgroundColor;
        break;
      default:
        currentColor = Colors.white;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Escolha uma cor'),
          content: SingleChildScrollView(
            child: MaterialPicker(
              pickerColor: currentColor,
              onColorChanged: (color) {
                switch (type) {
                  case 'teamA':
                    settings.setTeamAColor(color);
                    break;
                  case 'teamB':
                    settings.setTeamBColor(color);
                    break;
                  case 'font':
                    settings.setFontColor(color);
                    break;
                  case 'background':
                    settings.setBackgroundColor(color);
                    break;
                }
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('FECHAR'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
