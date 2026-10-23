# TUI

## Lazygit

O [Lazygit](https://github.com/jesseduffield/lazygit) é uma alternativa deliciosa a algo como a aplicação GitHub Desktop, e corre dentro do terminal.

Podes executá-lo diretamente, indo a qualquer diretório gerido pelo git e executando `lazygit`. Ou podes executá-lo dentro do Neovim, onde pode ser iniciado com `Space G G`.

Saltas entre os diferentes painéis com `Tab`. No painel Files, selecionas ficheiros para staging com `Space`, e depois podes criar um novo commit com `c`. Podes ver todos os comandos disponíveis com `?`.

## Btop

O [Btop](https://github.com/aristocratos/btop) é um belo gestor de recursos que mostra a utilização de memória, CPU, disco e rede. Também lista todos os processos ativos e permite-te geri-los.

O Omarchy chama-lhe Activity, e inicias-no carregando em `Super + Ctrl + T`. Abre como uma janela flutuante, que podes colocar em mosaico com `Super + T`.

## Herdr

O [Herdr](https://github.com/omacom-io/herdr) é um gestor de espaços de trabalho de terminal que te dá áreas de trabalho, separadores e painéis, e os mantém todos a correr numa sessão persistente da qual te podes desligar e à qual podes voltar mais tarde.

Inicias-no (ou voltas a ligar-te à tua sessão existente) com `Super + Ctrl + Return`. O Omarchy traz uma configuração do Herdr que espelha a sua configuração do Tmux, por isso a tecla de prefixo também é aqui `Ctrl + Space`. Podes consultar todos os atalhos com `Super + Ctrl + K`.

## Fastfetch

O [Fastfetch](https://github.com/fastfetch-cli/fastfetch) mostra informação do sistema, como a versão do kernel, o tempo de atividade, o tema, o CPU, a memória e muito mais. É um sucessor da popular ferramenta neofetch.

O Omarchy empacotou isto como _Sobre_ no menu Omarchy (`Super + Space`).

## Cliamp

O [Cliamp](https://www.cliamp.stream/) é um leitor de música de terminal retro inspirado no Winamp 2.x, completo com estações de rádio integradas para ritmos lo-fi. Inicia-o com `Super + Shift + Alt + M`, ou a partir do menu Omarchy em _Aplicações_. Carrega em `?` para veres a lista completa de atalhos.

## E o Wi-Fi e o Bluetooth?

Não vais encontrar TUI para Wi-Fi e Bluetooth — essas tarefas pertencem à shell do Omarchy. Clica no ícone de Wi-Fi na barra superior (ou carrega em `Super + Ctrl + W`) para veres as redes e te ligares, e clica no ícone de Bluetooth (ou carrega em `Super + Ctrl + B`) para emparelhares e ligares dispositivos. Vê [rede](35-networking.md) para a história completa.

## Adicionar as tuas próprias

Qualquer programa de terminal pode receber o tratamento completo de aplicação. Vai a _Instalar > TUI_ no menu Omarchy (`Super + Space`), dá-lhe um nome, um comando de arranque, um estilo de janela e um ícone, e ele aparece no lançador de aplicações como qualquer outra aplicação. Podes removê-lo outra vez em _Remover > TUI_.
