# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) é uma alternativa deliciosa a algo como a aplicação GitHub Desktop, e funciona dentro do terminal.

Podes executá-lo diretamente, indo a qualquer diretório gerido pelo git e executando `lazygit`. Ou podes executá-lo dentro do Neovim, onde pode ser iniciado com `Space G G`.

Saltas entre os diferentes painéis com `Tab`. No painel Files, selecionas ficheiros para staging com `Space`, e depois podes criar um novo commit com `c`. Podes ver todos os comandos disponíveis com `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) é um belíssimo gestor de recursos que mostra a utilização de memória, CPU, disco e rede. Também lista todos os processos ativos e permite geri-los.

O Omarchy chama-lhe Activity, e podes iniciá-lo carregando em `Super + Shift + T`. Abre como uma janela flutuante, que podes colocar em mosaico com `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) é um gestor de áreas de trabalho para o terminal que te dá áreas de trabalho, separadores e painéis, e mantém tudo a funcionar numa sessão persistente da qual te podes desligar e à qual podes regressar mais tarde.

Inicias-lo (ou voltas a ligar-te à tua sessão existente) com `Super + Ctrl + Return`. O Omarchy inclui uma configuração do Herdr que espelha a sua configuração do Tmux, por isso a tecla de prefixo também aqui é `Ctrl + Space`. Podes consultar todos os atalhos de teclado com `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) mostra informações do sistema, como a versão do kernel, o tempo de atividade, o tema, a CPU, a memória e muito mais. É o sucessor da popular ferramenta neofetch.

O Omarchy incluiu isto como _About_ no menu do Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) é um leitor de música retro para o terminal, inspirado no Winamp 2.x, completo com estações de rádio integradas para lo-fi beats. Inicia-o com `Super + Shift + Alt + M`, ou a partir do menu do Omarchy, em _Apps_. Carrega em `?` para veres a lista completa de atalhos de teclado.

## E quanto ao Wi-Fi e ao Bluetooth?

Não vais encontrar TUIs para Wi-Fi e Bluetooth — esses trabalhos pertencem à shell do Omarchy. Clica no ícone de Wi-Fi na barra superior (ou carrega em `Super + Ctrl + N`) para veres as redes e ligares-te, e clica no ícone de Bluetooth (ou carrega em `Super + Ctrl + B`) para emparelhar e ligar dispositivos. Consulta [redes](35-networking.md) para saberes a história completa.

## Adicionar as tuas próprias

Qualquer programa de terminal pode ter direito ao tratamento completo de aplicação. Vai a _Install > TUI_ no menu do Omarchy (`Super + Space`), dá-lhe um nome, um comando de arranque, um estilo de janela e um ícone, e ele vai aparecer no lançador de aplicações como qualquer outra aplicação. Podes removê-lo novamente em _Remove > TUI_.
