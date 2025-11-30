import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/settings_provider.dart';
import 'stats_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildSectionTitle(context, 'Aparência'),
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
          _buildSectionTitle(context, 'Regras do Jogo'),
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
          const Divider(),
          _buildSectionTitle(context, 'Estatísticas'),
          ListTile(
            title: const Text('Ver Estatísticas'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.brightness_6),
        title: const Text('Tema'),
        trailing: DropdownButton<ThemeMode>(
          value: settingsProvider.themeMode,
          onChanged: (ThemeMode? newValue) {
            if (newValue != null) {
              settingsProvider.setThemeMode(newValue);
            }
          },
          items: const [
            DropdownMenuItem(value: ThemeMode.system, child: Text('Sistema')),
            DropdownMenuItem(value: ThemeMode.light, child: Text('Claro')),
            DropdownMenuItem(value: ThemeMode.dark, child: Text('Escuro')),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(
    BuildContext context,
    String title,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.color_lens),
        title: Text(title),
        trailing: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Escolha uma cor'),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: currentColor,
                      onColorChanged: onColorChanged,
                      pickerAreaHeightPercent: 0.8,
                      portraitOnly: true,
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
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: currentColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 2),
            ),
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
    return Card(
      child: ListTile(
        leading: const Icon(Icons.format_list_numbered),
        title: Text(label),
        trailing: SizedBox(
          width: 80,
          child: TextField(
            controller: TextEditingController(text: value),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
            ),
            onSubmitted: onChanged,
          ),
        ),
      ),
    );
  }
}
