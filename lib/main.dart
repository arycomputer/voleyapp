import 'package:flutter/material.dart';
import 'screens/placar_screen.dart';
import 'screens/team_builder_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Pelada',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _teams = [];

  void _navigateToPlacar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlacarScreen(teams: _teams)),
    );
  }

  void _navigateToTeamBuilder(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TeamBuilderScreen()),
    );

    if (result != null && result['teams'] != null) {
      setState(() {
        _teams = List<Map<String, dynamic>>.from(result['teams']);
      });
      _navigateToPlacar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciador de Pelada'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _navigateToTeamBuilder(context),
              child: const Text('Montar Times e Iniciar Placar'),
            ),
          ],
        ),
      ),
    );
  }
}
