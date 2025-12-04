# Visão Geral do Projeto

Este é um aplicativo Flutter para gerenciamento de times e placar de voleibol. O aplicativo permite que os usuários gerenciem uma lista de jogadores, gerem times com base no nível de habilidade de cada jogador e mantenham o placar durante um jogo.

# Funcionalidades e Design

## Gerenciamento de Jogadores

-   **Adicionar, editar e remover jogadores:** Os usuários podem adicionar novos jogadores, editar as informações dos jogadores existentes e remover jogadores da lista.
-   **Importar e exportar jogadores:** Os usuários podem importar uma lista de jogadores de um arquivo CSV e exportar a lista atual de jogadores para um arquivo CSV.
-   **Lista de jogadores com código de cores:** As linhas na lista de jogadores são coloridas de acordo com o nível de habilidade do jogador:
    -   Nível 1-2: Vermelho
    -   Nível 3-4: Amarelo
    -   Nível 5: Verde

## Geração de Times

-   **Geração automática de times:** O aplicativo pode gerar times automaticamente com base no nível de habilidade dos jogadores para criar times equilibrados.
-   **Troca de jogadores:** Os usuários podem arrastar e soltar jogadores entre os times para trocar suas posições. Ao trocar dois jogadores, a posição do jogador na lista é mantida.
-   **Personalização de times:** Os usuários podem renomear os times e ajustar manualmente a composição dos times.

## Placar

-   **Placar em tempo real:** O aplicativo fornece um placar em tempo real para acompanhar a pontuação durante um jogo.
-   **Controle de tempo:** Um cronômetro está incluído para controlar a duração do jogo.

# Plano de Alterações Atuais

-   **Aprimorar a troca de jogadores:** Manter a posição do jogador na lista ao ser trocado de time.
