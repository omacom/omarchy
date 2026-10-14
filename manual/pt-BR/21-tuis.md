# TUIs

## Lazygit

O [Lazygit](https://github.com/jesseduffield/lazygit) é uma alternativa deliciosa a algo como o aplicativo GitHub Desktop, e ele é executado dentro do terminal.

Você pode executá-lo diretamente, indo a qualquer diretório gerenciado pelo git e executando `lazygit`. Ou pode executá-lo dentro do Neovim, onde ele pode ser iniciado com `Space G G`.

Você pula entre os diferentes painéis usando `Tab`. No painel Arquivos, você seleciona arquivos para staging usando `Space`, e depois pode criar um novo commit usando `c`. Você pode ver todos os comandos disponíveis usando `?`.

## Btop

O [Btop](https://github.com/aristocratos/btop) é um belo gerenciador de recursos que mostra o uso de memória, CPU, disco e rede. Ele também lista todos os processos ativos e permite que você os gerencie.

O Omarchy o chama de Activity, e você o inicia pressionando `Super + Ctrl + T`. Ele abre como uma janela flutuante, que você pode colocar em mosaico com `Super + T`.

## Herdr

O [Herdr](https://github.com/omacom-io/herdr) é um gerenciador de áreas de trabalho do terminal que oferece áreas de trabalho, guias e painéis, e mantém todos eles em execução em uma sessão persistente da qual você pode se desconectar e à qual pode voltar mais tarde.

Você o inicia (ou se reconecta à sua sessão existente) com `Super + Ctrl + Return`. O Omarchy vem com uma configuração do Herdr que espelha sua configuração do Tmux, então a tecla de prefixo também é `Ctrl + Space` aqui. Você pode navegar por todos os atalhos de teclado com `Super + Ctrl + K`.

## Fastfetch

O [Fastfetch](https://github.com/fastfetch-cli/fastfetch) mostra informações do sistema, como versão do kernel, tempo de atividade, tema, CPU, memória e mais. É um sucessor da popular ferramenta neofetch.

O Omarchy empacotou isso como _Sobre_ no menu do Omarchy (`Super + Space`).

## Cliamp

O [Cliamp](https://www.cliamp.stream/) é um reprodutor de música retrô para o terminal inspirado no Winamp 2.x, completo com estações de rádio integradas para batidas lo-fi. Inicie-o com `Super + Shift + Alt + M`, ou pelo menu do Omarchy em _Aplicativos_. Pressione `?` para a lista completa de atalhos de teclado.

## E quanto a Wi-Fi e Bluetooth?

Você não encontrará TUIs para Wi-Fi e Bluetooth — essas tarefas pertencem ao shell do Omarchy. Clique no ícone de Wi-Fi na barra superior (ou pressione `Super + Ctrl + W`) para ver as redes e se conectar, e clique no ícone de Bluetooth (ou pressione `Super + Ctrl + B`) para parear e conectar dispositivos. Consulte [rede](35-networking.md) para a história completa.

## Adicionando as suas próprias

Qualquer programa de terminal pode receber o tratamento completo de aplicativo. Vá a _Instalar > TUI_ no menu do Omarchy (`Super + Space`), dê a ele um nome, um comando de inicialização, um estilo de janela e um ícone, e ele aparecerá no inicializador de aplicativos como qualquer outro aplicativo. Você pode removê-lo novamente em _Remover > TUI_.
