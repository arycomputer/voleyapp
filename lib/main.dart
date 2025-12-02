import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/player_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/placar_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, SettingsProvider>(
      builder: (context, themeProvider, settingsProvider, child) {
        final fontColor = settingsProvider.fontColor;
        final backgroundColor = settingsProvider.backgroundColor;

        TextTheme createTextTheme(TextTheme base, Color color) {
          return base.apply(
            bodyColor: color,
            displayColor: color,
          );
        }

        final lightBase = ThemeData.light();
        final lightTheme = lightBase.copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: backgroundColor,
          textTheme: createTextTheme(lightBase.textTheme, fontColor),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue.shade600,
            titleTextStyle: TextStyle(
              color: fontColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: fontColor),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: Colors.blue.shade800,
            unselectedItemColor: Colors.grey.shade600,
          ),
          iconTheme: IconThemeData(color: fontColor),
        );

        final darkBase = ThemeData.dark();
        final darkTheme = darkBase.copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: backgroundColor,
          textTheme: createTextTheme(darkBase.textTheme, fontColor),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[900],
            titleTextStyle: TextStyle(
              color: fontColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: fontColor),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: Colors.orange.shade400,
            unselectedItemColor: Colors.grey.shade600,
          ),
          iconTheme: IconThemeData(color: fontColor),
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Gerador de Times',
          themeMode: themeProvider.themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: const PlacarScreen(),
        );
      },
    );
  }
}
