class Jogador {
  final String nome;
  final int nivel;

  Jogador({required this.nome, required this.nivel});

  @override
  String toString() {
    return 'Jogador(nome: $nome, nivel: $nivel)';
  }
}
