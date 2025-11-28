# Visão Geral do Projeto

Este é um aplicativo de placar e gerenciamento de times, projetado para organizar partidas amadoras ("peladas"). Ele permite aos usuários marcar pontos, cronometrar jogos, personalizar a aparência do placar e gerenciar jogadores para montar equipes equilibradas.

# Recursos Implementados

## Placar

- [x] Tela de placar com dois times (A e B).
- [x] Contagem de pontos com um simples toque na área do time.
- [x] Decremento de pontos com um toque longo.
- [x] Cronômetro central com controles de iniciar, pausar e reiniciar.
- [x] Botão de reiniciar para zerar placares e o cronômetro.
- [x] Integração total com a tela de configurações para personalização em tempo real.

## Configurações

- [x] Tela de configurações acessível a partir do placar.
- [x] Seletor de tema (claro, escuro ou padrão do sistema).
- [x] Seletores de cores (usando `MaterialPicker`) para os placares dos times A e B e para a fonte.
- [x] Campo para definir a pontuação máxima do jogo.
- [x] Campo para definir o número de pedidos de tempo por set.

# Plano de Desenvolvimento (Próximos Passos)

## Montagem de Times

- [ ] **Modelo de Dados**: Criar um modelo `Jogador` com os atributos `nome` (String) and `nivel` (int, de 1 a 5).
- [ ] **Adicionar Dependências**: Instalar os pacotes `file_picker` para seleção de arquivos e `csv` para processamento de dados.
- [ ] **Gerenciador de Estado**: Desenvolver um `PlayerProvider` para gerenciar a lista de jogadores, incluindo a lógica para adicionar e importar jogadores.
- [ ] **Tela de Montagem**: Construir a `TeamBuilderScreen` para permitir a visualização, adição manual e importação de jogadores a partir de um arquivo CSV.
- [ ] **Navegação**: Adicionar um ícone na `PlacarScreen` para dar acesso à nova tela de montagem de times.
- [ ] **Integração**: Usar `MultiProvider` no `main.dart` para disponibilizar o novo `PlayerProvider` junto com o `SettingsProvider` existente.
