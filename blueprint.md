# Placar de Vôlei

## Visão Geral

Este é um aplicativo Flutter simples que funciona como um placar para partidas de vôlei. O aplicativo foi projetado para funcionar exclusivamente no modo paisagem para uma melhor visualização durante os jogos.

## Estilo e Design

- **Orientação:** A aplicação é bloqueada no modo paisagem.
- **Layout:** A tela é dividida em duas colunas, uma para cada time (Time A e Time B).
- **Cores:** O Time A é representado pela cor vermelha e o Time B pela cor azul. O usuário pode alterar as cores de cada placar.
- **Tipografia:** As pontuações são exibidas em uma fonte grande e em negrito para facilitar a leitura à distância. A pontuação agora se ajusta automaticamente para preencher o espaço disponível.
- **Interatividade:** Os usuários podem incrementar a pontuação de um time tocando em qualquer lugar da coluna correspondente.

## Recursos

- **Contagem de Pontos:** Os usuários podem adicionar pontos para o Time A e para o Time B.
- **Reiniciar Pontuação:** Um botão de ação flutuante permite que os usuários reiniciem a pontuação de ambos os times para zero.
- **Configurações:** Um ícone de configurações permite ao usuário acessar uma tela de configurações.
- **Cronômetro:**
    - **Iniciar/Pausar:** Um botão na AppBar permite iniciar ou pausar o cronômetro.
    - **Início Automático:** O cronômetro inicia automaticamente quando o primeiro ponto é marcado.
    - **Exibição:** O tempo decorrido é exibido na AppBar.
    - **Reiniciar:** O cronômetro é zerado junto com a pontuação.
- **Montagem de Times:**
    - **Entrada Manual:** Permite adicionar jogadores manualmente, especificando um nome e um nível de habilidade de 1 a 5 com um slider.
    - **Importação de CSV:** Permite importar uma lista de jogadores de um arquivo CSV. O CSV pode ter uma coluna (nome) ou duas colunas (nome, nível).
    - **Geração de Times Balanceada:** Gera dois times a partir da lista de jogadores, distribuindo-os de forma a equilibrar o nível de habilidade total de cada time.
- **Estatísticas dos Jogadores:**
    - **Rastreamento Opcional:** Uma opção nas configurações permite ativar o rastreamento de pontos por jogador.
    - **Seleção de Jogador:** Quando o rastreamento está ativo, um diálogo aparece após cada ponto para selecionar qual jogador pontuou.
    - **Tela de Estatísticas:** Uma nova tela exibe a pontuação de cada jogador, dividida por time.
- **Personalização:**
    - Alterar o tema de cores do aplicativo (claro, escuro ou padrão do sistema).
    - Selecionar cores personalizadas para o placar de cada time.


## Estrutura do Projeto

- **`lib/main.dart`:** O ponto de entrada principal da aplicação, contendo a lógica principal do placar e a navegação.
- **`lib/models/player.dart`:** O modelo de dados para um jogador, contendo nome e nível de habilidade.
- **`lib/providers/settings_provider.dart`:** Gerencia o estado das configurações do aplicativo.
- **`lib/screens/settings_screen.dart`:** A tela de configurações, onde os usuários podem personalizar o aplicativo.
- **`lib/screens/team_builder_screen.dart`:** A tela onde os usuários podem adicionar, importar e gerar times.
- **`lib/screens/stats_screen.dart`:** A tela que exibe as estatísticas de pontos dos jogadores.
- **`lib/widgets/score_column.dart`:** O widget que exibe a pontuação de um time.
