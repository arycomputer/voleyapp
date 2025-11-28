import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildThemeSelector(context, settingsProvider),
          const Divider(),
          _buildColorPicker(
            context,
            'Cor do Time A',
            settingsProvider.teamAColor,
            (color) => settingsProvider.setTeamAColor(color),
          ),
          _buildColorPicker(
            context,
            'Cor do Time B',
            settingsProvider.teamBColor,
            (color) => settingsProvider.setTeamBColor(color),
          ),
          _buildColorPicker(
            context,
            'Cor da Fonte',
            settingsProvider.fontColor,
            (color) => settingsProvider.setFontColor(color),
          ),
          const Divider(),
          _buildNumberInput(
            context,
            'Pontuação Máxima',
            settingsProvider.maxScore.toString(),
            (value) {
              final newScore = int.tryParse(value);
              if (newScore != null) {
                settingsProvider.setMaxScore(newScore);
              }
            },
          ),
          _buildNumberInput(
            context,
            'Tempos por Set',
            settingsProvider.timeoutsPerSet.toString(),
            (value) {
              final newTimeouts = int.tryParse(value);
              if (newTimeouts != null) {
                settingsProvider.setTimeoutsPerSet(newTimeouts);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, SettingsProvider settingsProvider) {
    return ListTile(
      title: const Text('Tema'),
      trailing: DropdownButton<ThemeMode>(
        value: settingsProvider.themeMode,
        onChanged: (ThemeMode? newValue) {
          if (newValue != null) {
            settingsProvider.setThemeMode(newValue);
          }
        },
        items: const [
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Text('Sistema'),
          ),
          DropdownMenuItem(
            value: ThemeMode.light,
            child: Text('Claro'),
          ),
          DropdownMenuItem(
            value: ThemeMode.dark,
            child: Text('Escuro'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(
      BuildContext context,
      String title,
      Color currentColor,
      Function(Color) onColorChanged,
      ) {
    return ListTile(
      title: Text(title),
      trailing: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Escolha uma cor'),
                content: SingleChildScrollView(
                  child: MaterialPicker(
                    pickerColor: currentColor,
                    onColorChanged: onColorChanged,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: currentColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberInput(
      BuildContext context,
      String label,
      String value,
      Function(String) onChanged,
      ) {
    return ListTile(
      title: Text(label),
      trailing: SizedBox(
        width: 80,
        child: TextField(
          controller: TextEditingController(text: value),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          onSubmitted: onChanged,
        ),
      ),
    );
  }
}
