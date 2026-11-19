# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) é uma alternativa deliciosa a algo como o aplicativo GitHub Desktop, e roda dentro do terminal.

Você pode executá-lo diretamente, indo a qualquer diretório gerenciado pelo git e executando `lazygit`. Ou pode executá-lo dentro do Neovim, onde ele pode ser iniciado com `Space G G`.

Você salta entre os diferentes painéis usando `Tab`. No painel de arquivos, você seleciona arquivos para staging usando `Space`, e depois pode criar um novo commit usando `c`. Você pode ver todos os comandos disponíveis usando `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) é um belo gerenciador de recursos que mostra o uso de memória, CPU, disco e rede. Ele também lista todos os processos ativos e permite que você os gerencie.

O Omarchy o chama de Activity Monitor, e você o inicia a partir do lançador de aplicativos ou pressionando `Super + Shift + T`. Ele abre como uma janela flutuante, que você pode colocar em mosaico com `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) é um gerenciador de espaços de trabalho no terminal que oferece espaços de trabalho, abas e painéis, e mantém todos eles rodando em uma sessão persistente da qual você pode se desconectar e voltar depois.

Você o inicia (ou se reconecta à sua sessão existente) a partir do lançador de aplicativos ou com `Super + Ctrl + Return`. O Omarchy inclui uma configuração do Herdr que espelha sua configuração do Tmux, então a tecla de prefixo também é `Ctrl + Space` aqui. Você pode navegar por todos os atalhos de teclado com `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) mostra informações do sistema, como versão do kernel, tempo de atividade, tema, CPU, memória e muito mais. É um sucessor da popular ferramenta neofetch.

O Omarchy empacotou isso como _Sistema > Sobre_ no menu do Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) é um player de música retrô para terminal inspirado no Winamp 2.x, completo com estações de rádio integradas para batidas lo-fi. Inicie-o com `Super + Shift + Alt + M`, ou pelo menu do Omarchy em _Aplicativos_. Pressione `?` para ver a lista completa de atalhos de teclado.

## E quanto ao Wi-Fi e ao Bluetooth?

Você não vai encontrar TUIs para Wi-Fi e Bluetooth — essas tarefas pertencem ao shell do Omarchy. Clique no ícone de Wi-Fi na barra superior (ou pressione `Super + Ctrl + N`) para ver as redes e se conectar, e clique no ícone do Bluetooth (ou pressione `Super + Ctrl + B`) para parear e conectar dispositivos. Veja [rede](35-networking.md) para a história completa.

## Adicionando suas próprias

Qualquer programa de terminal pode receber o tratamento completo de aplicativo. Vá para _Instalar > TUI_ no menu do Omarchy (`Super + Space`), dê a ele um nome, um comando de inicialização, um estilo de janela e um ícone, e ele aparecerá no lançador de aplicativos como qualquer outro aplicativo. Você pode removê-lo novamente em _Remover > TUI_.
