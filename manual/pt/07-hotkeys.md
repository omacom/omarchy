# Atalhos de Teclado

Pode ver todas as principais associações de teclas com `Super + K` (associações do Tmux com `Super + Alt + K` e associações do Herdr com `Super + Ctrl + K`).

## Como os atalhos de teclado estão organizados

Cada atalho de teclado fica num plano, definido pelos seus modificadores, e cada plano tem uma função. É isso que impede os atalhos de se misturarem, e significa que normalmente consegue adivinhar onde está cada coisa.

| Plano | O que vive lá | Exemplos |
| --- | --- | --- |
| `Super + key` | O sistema: janelas, áreas de trabalho, disposições e menus principais | `Super + Space` menu Omarchy, `Super + W` fechar janela, `Super + F` ecrã inteiro |
| `Super + Shift + key` | Aplicações | `Super + Shift + B` navegador, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Painéis e menus do sistema | `Super + Ctrl + A` áudio, `Super + Ctrl + N` rede, `Super + Ctrl + C` menu de captura |
| `Super + Ctrl + Alt + key` | Ações rápidas e avisos | `Super + Ctrl + Alt + T` mostrar a hora, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` captura de ecrã |

Adicionar `Alt` a um atalho dá-lhe uma variante da mesma coisa, nunca algo sem relação:

- `Super + Shift + B` abre o navegador; `Super + Shift + Alt + B` abre uma janela privada
- `Super + Shift + E` abre o e-mail; `Super + Shift + Alt + E` começa um novo
- `Super + F` passa para ecrã inteiro; `Super + Alt + F` passa para a largura total
- `Super + Ctrl + C` abre o menu de captura; `Super + Ctrl + Alt + C` salta o menu e faz uma captura de ecrã

Ao adicionar um atalho de teclado:

1. Escolha o plano a partir do que ele faz, e depois escolha a tecla.
2. Não desloque um atalho existente para arranjar espaço. Encontre uma tecla livre no plano certo.
3. Use `Alt` apenas para uma variante do atalho sem ele.

Alguns atalhos quebram estas regras porque são convenientes. `Shift` com uma seta ou `Tab` move ou inverte, em vez de abrir uma aplicação, e `Print`, as teclas multimédia, `Alt + Tab` e `Ctrl + Alt + Del` funcionam como funcionam em todo o lado. São exceções, não padrões para copiar.

Se uma predefinição não lhe servir (por exemplo, se quiser `Super + Shift + S` para capturas de ecrã, como no Windows), volte a associá-la em `~/.config/hypr/bindings.lua`.

## Navegação

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + Space` | Menu Omarchy (aplicações e tudo o resto) |
| `Super + Alt + Space` | Grelha de aplicações |
| `Super + Escape` | Menu do sistema (suspender, reiniciar, etc.) |
| `Super + Ctrl + L` | Bloquear o computador |
| `Super + W` or `Super + Q` | Fechar a janela |
| `Ctrl + Alt + Del` | Fechar todas as janelas |
| `Super + T` | Alternar a janela entre mosaico/flutuante |
| `Super + J` | Alternar a posição da janela (horizontal/vertical) |
| `Super + O` | Alternar a janela saliente para sticky'n'floating |
| `Super + L` | Percorrer as disposições dwindle, scrolling e floating |
| `Super + Alt + L` | Percorrer as disposições pela ordem inversa |
| `Super + P` | Alternar o estilo de janela pseudo (natural vs. esticado) |
| `Super + F` | Passar para ecrã inteiro |
| `Super + Alt + F` | Passar para a largura total |
| `Super + Ctrl + F` | Passar para ecrã inteiro dentro da janela |
| `Super + 1/2/3/4` | Saltar para uma área de trabalho específica no monitor focado |
| `Super + Tab` | Saltar para a área de trabalho seguinte no monitor focado |
| `Super + Shift + Tab` | Saltar para a área de trabalho anterior no monitor focado |
| `Super + Ctrl + Tab` | Saltar para a área de trabalho anterior no monitor focado |
| `Super + Shift + 1/2/3/4` | Mover a janela para uma área de trabalho no monitor focado |
| `Super + Shift + Alt + 1/2/3/4` | Mover a janela para uma área de trabalho no monitor focado sem a seguir |
| `Super + S` | Alternar o scratchpad completo |
| `Super + Alt + S` | Mover a janela para o scratchpad completo |
| `Super + Grave` | Alternar a consola Quake |
| `Super + Shift + Grave` | Mover a janela para a consola Quake |
| `Super + Shift + Ctrl + Arrows` | Mover a janela para o monitor nessa direção |
| `Super + Shift + Alt + Arrows` | Mover a área de trabalho para o monitor nessa direção |
| `Super + Arrow` | Mover o foco para a janela na direção da seta, passando para o monitor desse lado no limite do ecrã |
| `Super + Shift + Arrow` | Trocar a janela com outra na direção da seta, incluindo uma no monitor desse lado |
| `Super + Minus` | Expandir a janela para a esquerda |
| `Super + Equal` | Encolher a janela para a esquerda |
| `Super + Shift + Minus` | Encolher a janela para cima |
| `Super + Shift + Equal` | Expandir a janela para baixo |
| `Super + Alt + Minus/Equal` | O mesmo redimensionamento em passos mais pequenos |
| `Super + Ctrl + Minus/Equal` | O mesmo redimensionamento em passos maiores |
| `Super + Alt + Home` | Guardar a largura da janela |
| `Super + Home` | Repor a largura da janela guardada |
| `Super + Left Mouse` | Arrastar a janela |
| `Super + Right Mouse` | Redimensionar a janela |
| `Super + Scroll Wheel` | Percorrer as áreas de trabalho no monitor focado |
| `Super + G` | Alternar o agrupamento de janelas |
| `Super + Alt + G` | Retirar a janela do agrupamento |
| `Super + Alt + Tab` | Percorrer as janelas no agrupamento |
| `Super + Alt + Shift + Tab` | Percorrer para trás as janelas no agrupamento |
| `Super + Alt + Scroll Wheel` | Percorrer as janelas no agrupamento |
| `Super + Alt + 1/2/3/4/5` | Saltar para uma janela específica no agrupamento |
| `Super + Alt + Arrow` | Mover a janela para o agrupamento na direção da seta, incluindo uma no monitor desse lado |
| `Super + Ctrl + Left/Right` | Mover entre janelas dentro de um grupo em mosaico |
| `Super + Ctrl + Z` | Ampliar o ecrã (repetir para ampliar mais) |
| `Super + Ctrl + Alt + Z` | Reduzir totalmente o zoom do ecrã |
| `Super + /` | Avançar pelas opções de escala do monitor |
| `Super + Alt + /` | Recuar pelas opções de escala do monitor |
| `Alt + Tab` | Percorrer para a frente as janelas na área de trabalho ativa |
| `Alt + Shift + Tab` | Percorrer para trás as janelas na área de trabalho ativa |
| `Ctrl + Alt + Tab` | Percorrer o foco para a frente pelos monitores |
| `Ctrl + Alt + Shift + Tab` | Percorrer o foco para trás pelos monitores |

Os atalhos de redimensionamento usam as teclas físicas `code:20` e `code:21` (XKB `<AE11>` e `<AE12>`), independentemente dos caracteres impressos no teclado. Nos teclados dos EUA, estas teclas são `-` e `=`; nos teclados japoneses (JIS), são `-` e `^`; nos teclados espanhóis, são `'` e `¡`. No JIS, `Super + ^` é `Super + Equal`, enquanto `Super + Shift + -` (que escreve `=`) é `Super + Shift + Minus`.

## Controlos do sistema

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Painel de áudio |
| `Super + Ctrl + B` | Painel Bluetooth |
| `Super + Ctrl + N` | Painel Wi-Fi/rede |
| `Super + Ctrl + D` | Painel de ecrã |
| `Super + Ctrl + P` | Painel de energia |
| `Super + Ctrl + X` | Painel de agentes |
| `Super + Ctrl + Alt + D` | Painel de calendário |
| `Super + Ctrl + Alt + E` | Painel de relógio mundial |
| `Super + Ctrl + 1-9` | Alternar o painel da barra por posição |
| `Super + Ctrl + S` | Menu de partilha (via LocalSend) |
| `Super + Ctrl + C` | Controlos de captura (captura de ecrã/gravação/seletor) |
| `Super + Ctrl + O` | Menu de alternância |
| `Super + Ctrl + H` | Menu de hardware |
| `Super + Ctrl + E` | Seletor de emojis |
| `Super + Ctrl + .` | Transcodificar multimédia |
| `Super + Shift + Ctrl + A` | Escolher um agente de IA |

## Ajustes

| Atalho | Função |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Brilho máximo do ecrã |
| `Shift + Brightness Down` | Brilho mínimo do ecrã |
| `Alt + Brightness Up/Down` | Alterações precisas de brilho de 1% |
| `Alt + Volume Up/Down` | Alterações precisas de volume de 1% |
| `Keyboard Brightness Up/Down` | Retroiluminação do teclado mais forte/mais fraca |
| `Keyboard Backlight` | Percorrer os níveis de retroiluminação do teclado |
| `Alt + Play` | Faixa seguinte |
| `Alt + Shift + Play` | Faixa anterior |

## Iniciar aplicações

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (gestor de agentes) |
| `Super + Shift + Return` | Navegador |
| `Super + Shift + Alt + B` | Navegador (privado/anónimo) |
| `Super + Shift + F` | Gestor de ficheiros |
| `Super + Shift + Alt + F` | Gestor de ficheiros no cwd do terminal |
| `Super + Shift + M` | Música (Spotify) |
| `Super + Shift + Alt + M` | Música (cliamp) |
| `Super + Shift + /` | Gestor de palavras-passe (1password) |
| `Super + Shift + Q` | Calculadora (Omacalc) |
| `Super + Shift + T` | Atividade (btop) |
| `Super + Shift + N` | Editor (Neovim) |
| `Super + Shift + C` | Calendário ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-mail ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Novo e-mail ([HEY](https://hey.com/)) |
| `Super + Shift + A` | IA (ChatGPT) |
| `Super + Shift + Alt + A` | IA (Grok) |
| `Super + Shift + G` | Mensagens (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Mensagens (WhatsApp) |
| `Super + Shift + Ctrl + G` | Mensagens (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Escrita (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X Compose |
| `Super + Shift + Y` | YouTube |

Altere/adicione associações em `~/.config/hypr/bindings.lua`.

## Área de transferência universal

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + A` | Selecionar tudo nas aplicações que suportam `Ctrl + A` |
| `Super + C` | Copiar |
| `Super + X` | Cortar (não no terminal) |
| `Super + V` | Colar |
| `Super + Ctrl + V` | Gestor da área de transferência |

Normalmente, no Linux, precisa de `Ctrl + Shift + C/V` para copiar e colar no terminal e de `Ctrl + C/V` para o fazer em todo o resto. Estes atalhos unificados da área de transferência do Omarchy funcionam em todo o lado.

## Captura

| Atalho | Função |
| ------------------- | ------------------------------ |
| `Print Screen` | Captura de ecrã |
| `Super + Ctrl + Alt + C` | Captura de ecrã (a mesma captura, para teclados sem tecla Print Screen) |
| `Super + Ctrl + C` | Menu de captura |
| `Alt + Print Screen` | Gravação de ecrã |
| `Super + Shift + Ctrl + Alt + C` | Gravação de ecrã sem áudio, sem passar pelo menu (prima outra vez para parar) |
| `Super + Print Screen` | Seletor de cores |
| `Super + Ctrl + Print Screen` | Extração de texto para a área de transferência |
| `Super + Alt + [` | Tornar a sobreposição da webcam mais pequena durante a gravação |
| `Super + Alt + ]` | Tornar a sobreposição da webcam maior durante a gravação |
| `Alt + Shift + L` | Copiar o URL atual da webapp ou do navegador |
| `Alt + Shift + D` | Transferir o vídeo da página atual para `~/Videos` |
| `Alt + Space` | Iniciar/parar o ditado (requer _Configuração > Predefinições > Ditado_) |
| `Right Alt` | Manter premido para ditar (requer _Configuração > Predefinições > Ditado_) |

Nas gravações de ecrã, o atalho pergunta primeiro que áudio quer, e depois começa a gravar. Prima-o outra vez para parar. Consulte [capturas de ecrã e gravação](12-screenshots-recording.md) para ver os detalhes.

Todas as opções de captura também estão acessíveis em _Acionador > Captura_ no menu Omarchy (`Super + Space`).

## Notificações

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + ,` | Atuar sobre a notificação mais recente: abri-la ou premir o seu único botão, escolher entre as suas opções, ou dispensá-la quando não tem nenhuma |
| `Super + Shift + ,` | Dispensar todas as notificações |
| `Super + Ctrl + ,` | Controlar as notificações com o teclado |
| `Super + Alt + ,` | Dispensar a notificação mais recente |
| `Super + Shift + Alt + ,` | Abrir o histórico de notificações |
| `Super + Ctrl + Alt + ,` | Alternar o silenciamento das notificações |

## Estilo

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Escolher um novo tema (também `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Escolher o fundo do tema (também `Super + Ctrl + Space`) |
| `Super + Backspace` | Alternar a transparência numa janela |
| `Super + Ctrl + Backspace` | Alternar o formato quadrado de janela única |

As imagens de fundo extra estão em `~/.config/omarchy/backgrounds/<theme name>`. Também disponíveis através de _Instalar > Estilo > Fundo_ no menu Omarchy.

Todas as opções de estilo também estão acessíveis em _Estilo_ no menu Omarchy (`Super + Space`).

## Alternâncias

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Alternar o bloqueio por inatividade |
| `Super + Ctrl + Delete` | Ligar/desligar o ecrã do portátil |
| `Super + Ctrl + Alt + Delete` | Alternar o espelhamento do ecrã do portátil |
| `Super + Shift + Space` | Alternar a barra superior |
| `Shift + Mute` | Mudar para a saída de áudio seguinte |
| `Shift + Play` | Mudar para a fonte multimédia seguinte |
| `Super + Shift + Backspace` | Alternar os espaços entre janelas |
| `Super + Ctrl + Alt + F` | Alternar o ambiente de trabalho em ecrã inteiro (barra superior + espaços entre janelas) |

## Lembretes

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Definir um lembrete |
| `Super + Ctrl + Alt + R` | Ver todos os lembretes |
| `Super + Ctrl + Shift + R` | Limpar todos os lembretes |

## Avisos

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Mostrar a hora como notificação |
| `Super + Ctrl + Alt + B` | Mostrar a bateria como notificação |
| `Super + Ctrl + Alt + W` | Alternar a meteorologia como notificação |

## Tmux

A tecla de prefixo é `Ctrl + Space` (`Ctrl + B` também funciona). Pode alterar estas associações em `~/.config/tmux/tmux.conf`.

### Painéis

| Atalho | Função |
| ----------------------- | --------------------- |
| `Prefix + v` | Dividir o painel ao lado (vertical) |
| `Prefix + h` | Dividir o painel abaixo (horizontal) |
| `Prefix + x` | Terminar o painel |
| `Prefix + z` | Alternar o zoom do painel (ecrã inteiro) |
| `Alt + Enter` | Dividir o painel abaixo (sem prefixo) |
| `Alt + Shift + Enter` | Dividir o painel ao lado (sem prefixo) |
| `Alt + Escape` | Terminar o painel (sem prefixo) |
| `Ctrl + Alt + Arrows` | Mover entre painéis |
| `Ctrl + Alt + Shift + Arrows` | Redimensionar painéis |

### Janelas

| Atalho | Função |
| ----------------------- | --------------------- |
| `Prefix + c` | Nova janela |
| `Prefix + k` | Terminar a janela |
| `Prefix + r` | Mudar o nome da janela |
| `Alt + 1-9` | Ir para uma janela específica |
| `Alt + Arrow Left/Right` | Mover entre janelas |
| `Alt + Shift + Arrow Left/Right` | Mover a janela para a esquerda/direita |

### Sessões

| Atalho | Função |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sessão |
| `Prefix + K` | Terminar a sessão |
| `Prefix + R` | Mudar o nome da sessão |
| `Prefix + N` | Sessão seguinte |
| `Prefix + P` | Sessão anterior |
| `Alt + Arrow Up/Down` | Mover entre sessões |
| `Prefix + s` | Listar sessões |
| `Prefix + d` | Desligar da sessão |

### Modo de cópia (estilo vi)

| Atalho | Função |
| ----------------------- | --------------------- |
| `Prefix + [` | Entrar no modo de cópia |
| `v` | Iniciar a seleção (no modo de cópia) |
| `y` | Copiar a seleção (no modo de cópia) |

### Geral

| Atalho | Função |
| ----------------------- | --------------------- |
| `Prefix + q` | Recarregar a configuração |
| `Prefix + ?` | Mostrar os atalhos de teclado do Tmux |
| `Prefix + :` | Linha de comandos |

### Funções de disposição do Tmux

Estas funções têm de ser executadas dentro de uma sessão Tmux.

| Comando | Função |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Criar uma disposição de desenvolvimento com editor, IA e terminal |
| `tdlm <ai> [<second_ai>]` | Criar uma disposição de desenvolvimento por subdiretório |
| `tsl <count> <command>` | Criar uma disposição swarm com vários painéis |

## Terminal Ghostty

O terminal Ghostty é instalado através de _Instalar > Terminal_ no menu Omarchy.

| Atalho | Função |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova divisão abaixo |
| `Ctrl + Shift + O` | Nova divisão ao lado |
| `Ctrl + Alt + Arrows` | Mover entre divisões |
| `Super + Ctrl + Shift + Arrows` | Redimensionar a divisão em 10 linhas |
| `Super + Ctrl + Shift + Alt + Arrows` | Redimensionar a divisão em 100 linhas |
| `Ctrl + Shift + T` | Novo separador |
| `Ctrl + Shift + Arrows` | Mover entre separadores |
| `Alt + Numbers` | Ir para um separador específico |
| `Shift + Pg Up/Down` | Percorrer o histórico |
| `Ctrl + Left mouse` | Abrir a ligação no navegador |

## Gestor de Ficheiros

| Atalho | Função |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Ir para o caminho |
| `Space` | Pré-visualizar o ficheiro (as setas navegam) |
| `Alt + Up` | Subir para a pasta superior |

## Neovim (com LazyVim)

### Navegação

| Atalho | Função |
| ------------------------ | ------------------------------- |
| `Space` | Mostrar as opções de comando |
| `Space Space` | Abrir um ficheiro através de pesquisa aproximada |
| `Space E` | Alternar a barra lateral |
| `Space G G` | Mostrar os controlos git |
| `Space S G` | Pesquisar o conteúdo dos ficheiros |
| `Ctrl + W W` | Saltar entre a barra lateral e o editor |
| `Ctrl + Left/right arrow` | Alterar o tamanho da barra lateral |
| `Shift + H` | Ir para o separador de ficheiro da esquerda |
| `Shift + L` | Ir para o separador de ficheiro da direita |
| `Space B D` | Fechar o separador de ficheiro |

### Na barra lateral

| Atalho | Função |
| ------------------------ | ------------------------------- |
| `A` | Adicionar um novo ficheiro no diretório superior |
| `Shift + A` | Adicionar um novo subdiretório no diretório superior |
| `D` | Eliminar o ficheiro/diretório destacado |
| `M` | Mover o ficheiro/diretório destacado |
| `R` | Mudar o nome do ficheiro/diretório destacado |
| `?` | Mostrar a ajuda de todos os comandos |

[Veja todos os atalhos do Neovim configurados pelo LazyVim](https://www.lazyvim.org/keymaps).

## Emojis Rápidos

Pode usar `Super + Ctrl + E` para mostrar um seletor de emojis completo que coloca a seleção na área de transferência, ou pode usar estas opções de acesso rápido.

| Atalho | EM | Pista |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | sorriso |
| `Shift + CapsLock M C` | 😂 | choro |
| `Shift + CapsLock M L` | 😍 | amor |
| `Shift + CapsLock M V` | ✌️ | vitória |
| `Shift + CapsLock M H` | ❤️ | coração |
| `Shift + CapsLock M Y` | 👍 | sim |
| `Shift + CapsLock M N` | 👎 | não |
| `Shift + CapsLock M F` | 🖕 | foda-se |
| `Shift + CapsLock M W` | 🤞 | desejo |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | beijo |
| `Shift + CapsLock M E` | 🙄 | revirar os olhos |
| `Shift + CapsLock M I` | 😉 | piscar o olho |
| `Shift + CapsLock M P` | 🙏 | rezar |
| `Shift + CapsLock M D` | 🤤 | babar-se |
| `Shift + CapsLock M M` | 💰 | dinheiro |
| `Shift + CapsLock M X` | 🎉 | celebrar |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | brinde |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | saudação |
| `Shift + CapsLock M A` |💪 | braço |
| `Shift + CapsLock M B` |🤯 | explodir |

## Preenchimentos Rápidos

| Atalho | Preenchimento |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (travessão) |
| `Shift + CapsLock Space N` | O seu nome (tal como introduzido na configuração) |
| `Shift + CapsLock Space E` | O seu e-mail (tal como introduzido na configuração) |

Pode adicionar mais dos seus editando `~/.XCompose` e executando depois `omarchy-restart-xcompose` no terminal para as alterações serem aplicadas.
