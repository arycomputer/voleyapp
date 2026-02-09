import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle(context, 'Pontuação e Tempo'),
            _buildMaxScoreSetting(context, settingsProvider),
            const SizedBox(height: 16),
            _buildTimeoutsSetting(context, settingsProvider),
            const SizedBox(height: 16),
            _buildTimerDurationSetting(context, settingsProvider),
            const Divider(height: 32, thickness: 1),
            _buildSectionTitle(context, 'Cores das Equipes'),
            _buildColorPicker(
              context,
              'Cor da Equipe A',
              settingsProvider.teamAColor,
              (color) => settingsProvider.setTeamAColor(color),
            ),
            const SizedBox(height: 16),
            _buildColorPicker(
              context,
              'Cor da Equipe B',
              settingsProvider.teamBColor,
              (color) => settingsProvider.setTeamBColor(color),
            ),
            const Divider(height: 32, thickness: 1),
            _buildSectionTitle(context, 'Aparência'),
            _buildColorPicker(
              context,
              'Cor da Fonte',
              settingsProvider.fontColor,
              (color) => settingsProvider.setFontColor(color),
            ),
            const SizedBox(height: 16),
            _buildColorPicker(
              context,
              'Cor de Fundo do App',
              settingsProvider.backgroundColor,
              (color) => settingsProvider.setBackgroundColor(color),
            ),
            const SizedBox(height: 16),
            _buildColorPicker(
              context,
              'Cor da Fonte do Placar A',
              settingsProvider.scoreFontColorA,
              (color) => settingsProvider.setScoreFontColorA(color),
            ),
            const SizedBox(height: 16),
            _buildColorPicker(
              context,
              'Cor da Fonte do Placar B',
              settingsProvider.scoreFontColorB,
              (color) => settingsProvider.setScoreFontColorB(color),
            ),
            const SizedBox(height: 16),
            _buildThemeSetting(context, themeProvider),
          ],
        ),
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
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildMaxScoreSetting(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    return ListTile(
      title: const Text('Pontuação Máxima'),
      subtitle: Text(
        'Define a pontuação necessária para vencer o set. Atual: ${settingsProvider.maxScore}',
      ),
      trailing: DropdownButton<int>(
        value: settingsProvider.maxScore,
        items: [15, 21, 25, 30].map((score) {
          return DropdownMenuItem<int>(
            value: score,
            child: Text(score.toString()),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            settingsProvider.setMaxScore(value);
          }
        },
      ),
    );
  }

  Widget _buildTimeoutsSetting(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    return ListTile(
      title: const Text('Pedidos de Tempo por Set'),
      subtitle: Text(
        'Número de pausas que cada equipe pode solicitar. Atual: ${settingsProvider.timeoutsPerSet}',
      ),
      trailing: DropdownButton<int>(
        value: settingsProvider.timeoutsPerSet,
        items: [0, 1, 2, 3].map((timeouts) {
          return DropdownMenuItem<int>(
            value: timeouts,
            child: Text(timeouts.toString()),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            settingsProvider.setTimeoutsPerSet(value);
          }
        },
      ),
    );
  }

  Widget _buildTimerDurationSetting(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    return ListTile(
      title: const Text('Duração do Cronômetro'),
      subtitle: Text(
        'Tempo para pausas e pedidos de tempo (em segundos). Atual: ${settingsProvider.timerDuration}s',
      ),
      trailing: DropdownButton<int>(
        value: settingsProvider.timerDuration,
        items: [30, 45, 60, 90].map((duration) {
          return DropdownMenuItem<int>(
            value: duration,
            child: Text('$duration s'),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            settingsProvider.setTimerDuration(value);
          }
        },
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
      subtitle: const Text('Toque para selecionar a cor'),
      trailing: ColorIndicator(
        width: 44,
        height: 44,
        borderRadius: 22,
        color: currentColor,
        onSelect: () async {
          final newColor = await showColorPickerDialog(
            context,
            currentColor,
            title: Text(title, style: Theme.of(context).textTheme.titleLarge),
            width: 40,
            height: 40,
            spacing: 0,
            runSpacing: 0,
            borderRadius: 0,
            wheelDiameter: 165,
            enableOpacity: true,
            showColorCode: true,
            colorCodeHasColor: true,
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.both: false,
              ColorPickerType.primary: true,
              ColorPickerType.accent: true,
              ColorPickerType.bw: false,
              ColorPickerType.custom: true,
              ColorPickerType.wheel: true,
            },
          );
          onColorChanged(newColor);
        },
      ),
    );
  }

  Widget _buildThemeSetting(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tema do Aplicativo',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const <ButtonSegment<ThemeMode>>[
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              label: Text('Claro'),
              icon: Icon(Icons.light_mode),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              label: Text('Escuro'),
              icon: Icon(Icons.dark_mode),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              label: Text('Sistema'),
              icon: Icon(Icons.auto_mode),
            ),
          ],
          selected: <ThemeMode>{themeProvider.themeMode},
          onSelectionChanged: (Set<ThemeMode> newSelection) {
            themeProvider.setThemeMode(newSelection.first);
          },
        ),
      ],
    );
  }
}
