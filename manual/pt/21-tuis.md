# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) é uma alternativa deliciosa a algo como a aplicação GitHub Desktop, e funciona dentro do terminal.

Podes executá-lo diretamente, indo a qualquer diretório gerido pelo git e executando `lazygit`. Ou podes executá-lo dentro do Neovim, onde pode ser iniciado com `Space G G`.

Saltas entre os diferentes painéis com `Tab`. No painel Files, selecionas ficheiros para staging com `Space` e, depois, podes criar um novo commit com `c`. Podes ver todos os comandos disponíveis com `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) é um belo gestor de recursos que mostra a utilização de memória, CPU, disco e rede. Também lista todos os processos ativos e permite-te geri-los.

O Omarchy chama-lhe Activity Monitor, e podes iniciá-lo a partir do lançador de aplicações ou premindo `Super + Shift + T`. Abre-se como uma janela flutuante, que podes colocar em mosaico com `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) é um gestor de espaços de trabalho para o terminal que te dá espaços de trabalho, separadores e painéis, e mantém tudo a funcionar numa sessão persistente de que te podes desligar e a que podes regressar mais tarde.

Podes iniciá-lo (ou voltar a ligar-te à tua sessão existente) a partir do lançador de aplicações ou com `Super + Ctrl + Return`. O Omarchy inclui uma configuração do Herdr que espelha a sua configuração do Tmux, por isso a tecla de prefixo aqui também é `Ctrl + Space`. Podes consultar todos os atalhos de teclado com `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) mostra informações do sistema, como a versão do kernel, o tempo de atividade, o tema, a CPU, a memória e muito mais. É o sucessor da popular ferramenta neofetch.

O Omarchy apresenta-o como _About_ no menu do Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) é um leitor de música retro para o terminal, inspirado no Winamp 2.x, completo com estações de rádio integradas de lo-fi beats. Inicia-o com `Super + Shift + Alt + M`, ou a partir do menu do Omarchy em _Apps_. Prime `?` para veres a lista completa de atalhos de teclado.

## E quanto ao Wi-Fi e ao Bluetooth?

Não vais encontrar TUIs para Wi-Fi e Bluetooth — essas tarefas pertencem à shell do Omarchy. Clica no ícone de Wi-Fi na barra superior (ou prime `Super + Ctrl + N`) para veres as redes e ligares-te, e clica no ícone de Bluetooth (ou prime `Super + Ctrl + B`) para emparelhares e ligares dispositivos. Vê [redes](35-networking.md) para saberes tudo.

## Adicionar os teus próprios

Qualquer programa de terminal pode receber o tratamento completo de aplicação. Vai a _Install > TUI_ no menu do Omarchy (`Super + Space`), dá-lhe um nome, um comando de arranque, um estilo de janela e um ícone, e ele aparecerá no lançador de aplicações como qualquer outra aplicação. Podes removê-lo novamente em _Remove > TUI_.
