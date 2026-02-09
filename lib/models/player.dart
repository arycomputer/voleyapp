class Player {
  final String name;
  final String position;
  final int level;
  final bool isAvailable;

  Player({
    required this.name,
    this.position = 'Não especificado',
    required this.level,
    this.isAvailable = true,
  });

  @override
  String toString() {
    return '$name (Level: $level)';
  }
}
