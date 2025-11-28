class Player {
  final String name;
  final int habilidade;

  Player({required this.name, required this.habilidade});

  @override
  String toString() {
    return '$name (Habilidade: $habilidade)';
  }
}
