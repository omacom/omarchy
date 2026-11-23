# Atalhos de teclado

Pode ver todas as principais combinações de teclas com `Super + K` (combinações do Tmux com `Super + Alt + K` e combinações do Herdr com `Super + Ctrl + K`).

## Como estão organizados os atalhos de teclado

Cada atalho de teclado fica num plano, definido pelos seus modificadores, e cada plano tem uma função. É isso que impede os atalhos de se misturarem uns com os outros, e significa que normalmente consegue adivinhar onde está cada coisa.

| Plano | O que vive ali | Exemplos |
| --- | --- | --- |
| `Super + key` | O sistema: janelas, áreas de trabalho, disposições e menus principais | `Super + Space` menu Omarchy, `Super + W` fechar janela, `Super + F` ecrã inteiro |
| `Super + Shift + key` | Aplicações | `Super + Shift + B` navegador, `Super + Shift + E` correio eletrónico, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Painéis e menus do sistema | `Super + Ctrl + A` áudio, `Super + Ctrl + N` rede, `Super + Ctrl + C` menu de captura |
| `Super + Ctrl + Alt + key` | Ações rápidas e avisos | `Super + Ctrl + Alt + T` mostrar a hora, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` captura de ecrã |

Adicionar `Alt` a um atalho de teclado dá-lhe uma variante da mesma coisa, nunca algo sem relação:

- `Super + Shift + B` abre o navegador; `Super + Shift + Alt + B` abre uma janela privada
- `Super + Shift + E` abre o correio eletrónico; `Super + Shift + Alt + E` começa um novo
- `Super + F` passa para ecrã inteiro; `Super + Alt + F` passa para largura total
- `Super + Ctrl + C` abre o menu de captura; `Super + Ctrl + Alt + C` salta o menu e tira uma captura de ecrã

Quando adicionar um atalho de teclado:

1. Escolha o plano a partir do que ele faz e depois escolha a tecla.
2. Não desloque um atalho existente para arranjar espaço. Encontre uma tecla livre no plano certo.
3. Use `Alt` apenas para uma variante do atalho sem ele.

Alguns atalhos quebram estas regras porque são práticos. `Shift` com uma seta ou `Tab` desloca ou inverte em vez de abrir uma aplicação, e `Print`, as teclas multimédia, `Alt + Tab` e `Ctrl + Alt + Del` funcionam como funcionam em todo o lado. São exceções, não padrões para copiar.

Se uma predefinição não lhe servir (por exemplo, se quiser `Super + Shift + S` para capturas de ecrã como no Windows), reatribua-a em `~/.config/hypr/bindings.lua`.

## Navegação

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + Space` | Menu Omarchy (aplicações e tudo o resto) |
| `Super + Alt + Space` | Grelha de aplicações |
| `Super + Escape` | Menu do sistema (suspender, reiniciar, etc.) |
| `Super + Ctrl + L` | Bloquear o computador |
| `Super + W` or `Super + Q` | Fechar a janela |
| `Ctrl + Alt + Del` | Fechar todas as janelas |
| `Super + K` | Mostrar todos os atalhos de teclado |
| `Super + Alt + K` | Mostrar atalhos de teclado do tmux |
| `Super + Ctrl + K` | Mostrar atalhos de teclado do herdr |
| `Super + M` | Minimizar a janela para a dock |
| `Super + T` | Alternar a janela entre modo em mosaico e flutuante |
| `Super + J` | Alternar a posição da janela (horizontal/vertical) |
| `Super + O` | Alternar a janela para fixa e flutuante (sticky'n'floating) |
| `Super + L` | Percorrer as disposições dwindle, scrolling e floating |
| `Super + Alt + L` | Percorrer as disposições em sentido inverso |
| `Super + P` | Alternar o estilo de janela pseudo (natural vs. esticado) |
| `Super + F` | Passar para ecrã inteiro |
| `Super + Alt + F` | Passar para largura total |
| `Super + Ctrl + F` | Passar para ecrã inteiro dentro da janela |
| `Super + 1…9/0` | Saltar para uma área de trabalho específica (0 é 10) no monitor em foco |
| `Super + Tab` | Saltar para a área de trabalho seguinte no monitor em foco |
| `Super + Shift + Tab` | Saltar para a área de trabalho anterior no monitor em foco |
| `Super + Ctrl + Tab` | Saltar para a área de trabalho onde estava antes no monitor em foco |
| `Super + Shift + 1…9/0` | Mover a janela para a área de trabalho no monitor em foco |
| `Super + Shift + Alt + 1…9/0` | Mover a janela para a área de trabalho no monitor em foco sem a acompanhar |
| `Super + S` | Alternar o scratchpad completo |
| `Super + Alt + S` | Mover a janela para o scratchpad completo |
| `Super + the key above Tab` (acento grave nos teclados dos EUA) | Alternar a consola Quake |
| `Super + Shift + the key above Tab` (acento grave nos teclados dos EUA) | Mover a janela para a consola Quake |
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
| `Super + Scroll Wheel` | Percorrer as áreas de trabalho no monitor em foco |
| `Super + G` | Alternar o agrupamento de janelas |
| `Super + Alt + G` | Retirar a janela do agrupamento |
| `Super + Alt + Tab` | Percorrer as janelas do agrupamento |
| `Super + Alt + Shift + Tab` | Percorrer as janelas do agrupamento em sentido inverso |
| `Super + Alt + Scroll Wheel` | Percorrer as janelas do agrupamento |
| `Super + Alt + 1/2/3/4/5` | Saltar para uma janela específica do agrupamento |
| `Super + Alt + Arrow` | Mover a janela para dentro do agrupamento na direção da seta, incluindo uma no monitor desse lado |
| `Super + Ctrl + Left/Right` | Mover-se entre janelas dentro de um grupo em mosaico |
| `Super + Ctrl + Z` | Ampliar o ecrã (repetir para ampliar mais) |
| `Super + Ctrl + Alt + Z` | Reduzir totalmente o zoom do ecrã |
| `Super + /` | Avançar pelas opções de escala do monitor |
| `Super + Alt + /` | Recuar pelas opções de escala do monitor |
| `Alt + Tab` | Percorrer para a frente as janelas na área de trabalho ativa |
| `Alt + Shift + Tab` | Percorrer para trás as janelas na área de trabalho ativa |
| `Ctrl + Alt + Tab` | Mover o foco para a frente pelos monitores |
| `Ctrl + Alt + Shift + Tab` | Mover o foco para trás pelos monitores |
| `Super + I` | Mudar o idioma de entrada (com mais de uma disposição ou método de entrada) |
| `Super + Shift + I` | Voltar ao idioma de entrada anterior |

Num touchpad, os gestos de deslizar com três e quatro dedos mudam de área de trabalho, movem janelas e abrem o menu e a consola Quake; consulte [teclado, rato e trackpad](34-keyboard-mouse-trackpad.md) para ver os gestos.

O redimensionamento usa as duas teclas à direita do 0, independentemente do que o seu teclado tiver impresso nelas: `-` e `=` nos teclados dos EUA, `+` e `´` nos dinamarqueses e suecos, `+` e `\` nos noruegueses, `ß` e `´` nos alemães, `'` e `¡` nos espanhóis e `-` e `^` nos japoneses (JIS). `Super + K` lista-as tal como o seu teclado as imprime. Nos JIS, `Super + ^` é `Super + Equal`, enquanto `Super + Shift + -` (que escreve `=`) é `Super + Shift + Minus`. A escala do monitor e o gestor de palavras-passe usam `/`; nas disposições que só escrevem `/` com Shift, como a maioria das europeias, usam antes a tecla à esquerda do Shift direito (`-` nos dinamarqueses e alemães).

## Controlos do sistema

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Painel de áudio |
| `Super + Ctrl + B` | Painel Bluetooth |
| `Super + Ctrl + N` | Painel Wi-Fi/rede |
| `Super + Ctrl + D` | Painel do ecrã |
| `Super + Ctrl + P` | Painel de energia |
| `Super + Ctrl + X` | Painel de agentes |
| `Super + Ctrl + Alt + X` | Painel de modelos locais |
| `Super + Ctrl + Alt + D` | Painel do calendário |
| `Super + Ctrl + Alt + E` | Painel do relógio mundial |
| `Super + Ctrl + 1-9` | Alternar o painel da barra por posição |
| `Super + Ctrl + S` | Menu de partilha (via LocalSend) |
| `Super + Ctrl + C` | Controlos de captura (captura de ecrã/gravação/seletor) |
| `Super + Ctrl + O` | Alternar o menu |
| `Super + Ctrl + H` | Menu de hardware |
| `Super + Ctrl + E` | Seletor de emojis |
| `Super + Ctrl + .` | Transcodificar multimédia |
| `Super + Shift + Ctrl + A` | Iniciar o seu agente predefinido |
| `Power` key | Menu do sistema |
| `Super + Shift + Copilot` key | Menu Omarchy |

## Ajustes

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Brilho máximo do ecrã |
| `Shift + Brightness Down` | Brilho mínimo do ecrã |
| `Alt + Brightness Up/Down` | Alterações precisas de brilho de 1% |
| `Alt + Volume Up/Down` | Alterações precisas de volume de 1% |
| `Keyboard Brightness Up/Down` | Retroiluminação do teclado mais forte/mais fraca |
| `Keyboard Backlight` | Percorrer os níveis de retroiluminação do teclado |
| `Ctrl + Brightness Up/Down` | Retroiluminação do teclado mais forte/mais fraca, em teclados sem teclas próprias |
| `Mic Mute` | Silenciar o microfone |
| `Shift + Mute` | Mudar a saída de áudio |
| `Touchpad Toggle` | Ligar ou desligar o touchpad |
| `Display` key | Percorrer a disposição da área de trabalho |
| `Alt + Play` | Faixa seguinte |
| `Alt + Shift + Play` | Faixa anterior |

## Abrir aplicações

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (gestor de agentes) |
| `Super + Shift + Return` or `Super + Shift + B` | Navegador |
| `Super + Shift + Alt + B` | Navegador (privado/incógnito) |
| `Super + Shift + F` | Gestor de ficheiros |
| `Super + Shift + Alt + F` | Gestor de ficheiros na cwd do terminal |
| `Super + Shift + M` | Música (Spotify) |
| `Super + Shift + Alt + M` | Música (cliamp) |
| `Super + Shift + /` | Gestor de palavras-passe (1password) |
| `Super + Shift + Q` or `Calculator` key | Calculadora (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, depois de instalado) |
| `Super + Shift + T` | Atividade (btop) |
| `Super + Shift + N` | Editor (Plain, ou o predefinido que escolheu) |
| `Super + Shift + C` | Calendário ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Correio eletrónico ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Novo correio eletrónico ([HEY](https://hey.com/)) |
| `Super + Shift + A` | O seu agente predefinido, ou o ChatGPT até escolher um |
| `Super + Shift + Alt + A` | IA (Grok) |
| `Super + Shift + G` | Mensagens (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Mensagens (WhatsApp) |
| `Super + Shift + Ctrl + G` | Mensagens (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Escrita (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (nova publicação) |
| `Super + Shift + Y` | YouTube |

Altere/adicione combinações em `~/.config/hypr/bindings.lua`.

## Área de transferência universal

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + A` | Selecionar tudo nas aplicações que suportam `Ctrl + A` |
| `Super + C` | Copiar |
| `Super + X` | Cortar (não no terminal) |
| `Super + V` | Colar |
| `Super + Ctrl + V` | Gestor da área de transferência |

Normalmente no Linux, precisa de `Ctrl + Shift + C/V` para copiar e colar no terminal e de `Ctrl + C/V` para o fazer em todo o resto. Estes atalhos de teclado unificados da área de transferência do Omarchy funcionam em todo o lado.

## Captura

| Atalho de teclado | Função |
| ------------------- | ------------------------------ |
| `Print Screen` | Captura de ecrã |
| `Super + Ctrl + Alt + C` | Captura de ecrã (a mesma captura, para teclados sem tecla Print Screen) |
| `Super + Ctrl + C` | Menu de captura |
| `Alt + Print Screen` | Gravação de ecrã |
| `Super + Shift + Ctrl + Alt + C` | Gravação de ecrã sem áudio, saltando o menu (prima novamente para parar) |
| `Super + Print Screen` | Seletor de cores |
| `Super + Ctrl + Print Screen` | Extração de texto para a área de transferência |
| `Super + Alt + [` | Tornar a sobreposição da webcam mais pequena durante a gravação |
| `Super + Alt + ]` | Tornar a sobreposição da webcam maior durante a gravação |
| `Alt + Shift + L` | Copiar o URL atual da webapp ou do navegador |
| `Alt + Shift + D` | Transferir o vídeo da página atual para `~/Videos` |
| `Alt + Space` | Iniciar/parar o ditado (requer _Setup > Defaults > Dictation_) |
| `Right Alt` | Manter premido para ditar (requer _Setup > Defaults > Dictation_) |

Nas gravações de ecrã, o atalho pergunta primeiro que áudio quer e só depois começa a gravar. Prima-o novamente para parar. Consulte [capturas de ecrã e gravação](12-screenshots-recording.md) para ver os detalhes.

Todas as opções de captura também estão acessíveis em _Trigger > Capture_ no menu Omarchy (`Super + Space`).

## Notificações

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + ,` | Agir sobre a notificação mais recente: abri-la ou premir o seu único botão, escolher uma das suas opções ou dispensá-la quando não tiver nenhuma |
| `Super + Shift + ,` | Dispensar todas as notificações |
| `Super + Ctrl + ,` | Controlar as notificações com o teclado |
| `Super + Alt + ,` | Dispensar a notificação mais recente |
| `Super + Shift + Alt + ,` | Abrir o histórico de notificações |
| `Super + Ctrl + Alt + ,` | Alternar o silenciamento das notificações |

## Estilo

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Escolher um novo tema (também `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Escolher o fundo do tema (também `Super + Ctrl + Space`) |
| `Super + Backspace` | Alternar a transparência numa janela |
| `Super + Ctrl + Backspace` | Alternar o formato quadrado de janela única |

As imagens de fundo extra vivem em `~/.config/omarchy/backgrounds/<theme name>`. Também disponíveis através de _Install > Style > Background_ no menu Omarchy.

Todas as opções de estilo também estão acessíveis em _Appearance_ no menu Omarchy (`Super + Space`).

## Ativar/desativar

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Alternar o bloqueio em inatividade |
| `Super + Ctrl + Delete` | Ligar/desligar o ecrã do portátil |
| `Super + Ctrl + Alt + Delete` | Alternar o espelhamento do ecrã do portátil |
| `Super + Shift + Space` | Alternar a barra superior |
| `Shift + Mute` | Mudar para a saída de áudio seguinte |
| `Shift + Play` | Mudar para a fonte multimédia seguinte |
| `Super + Shift + Backspace` | Alternar os espaços entre janelas |
| `Super + Ctrl + Alt + F` | Alternar o ambiente de trabalho em ecrã inteiro (barra superior + espaços entre janelas) |

## Lembretes

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Definir um lembrete |
| `Super + Ctrl + Alt + R` | Ver todos os lembretes |
| `Super + Ctrl + Shift + R` | Apagar todos os lembretes |

## Avisos

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Mostrar a hora como notificação |
| `Super + Ctrl + Alt + B` | Mostrar a bateria como notificação |
| `Super + Ctrl + Alt + W` | Alternar o tempo como notificação |

## Tmux

A tecla de prefixo é `Ctrl + Space` (`Ctrl + B` também funciona). Pode alterar estas combinações em `~/.config/tmux/tmux.conf`.

### Painéis

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Prefix + v` | Dividir o painel ao lado (vertical) |
| `Prefix + h` | Dividir o painel abaixo (horizontal) |
| `Prefix + x` | Eliminar o painel |
| `Prefix + z` | Alternar o zoom do painel (ecrã inteiro) |
| `Alt + Enter` | Dividir o painel abaixo (sem prefixo) |
| `Alt + Shift + Enter` | Dividir o painel ao lado (sem prefixo) |
| `Alt + Escape` | Eliminar o painel (sem prefixo) |
| `Ctrl + Alt + Arrows` | Mover-se entre painéis |
| `Ctrl + Alt + Shift + Arrows` | Redimensionar painéis |

### Janelas

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Prefix + c` | Nova janela |
| `Prefix + k` | Eliminar a janela |
| `Prefix + r` | Renomear a janela |
| `Alt + 1-9` | Ir para uma janela específica |
| `Alt + Arrow Left/Right` | Mover-se entre janelas |
| `Alt + Shift + Arrow Left/Right` | Mover a janela para a esquerda/direita |

### Sessões

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sessão |
| `Prefix + K` | Eliminar a sessão |
| `Prefix + R` | Renomear a sessão |
| `Prefix + N` | Sessão seguinte |
| `Prefix + P` | Sessão anterior |
| `Alt + Arrow Up/Down` | Mover-se entre sessões |
| `Prefix + s` | Listar as sessões |
| `Prefix + d` | Desligar da sessão |

### Modo de cópia (estilo vi)

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Prefix + [` | Entrar no modo de cópia |
| `v` | Começar a seleção (no modo de cópia) |
| `y` | Copiar a seleção (no modo de cópia) |

### Geral

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Prefix + q` | Recarregar a configuração |
| `Prefix + ?` | Mostrar as combinações de teclas do Tmux |
| `Prefix + :` | Linha de comandos |

### Funções de disposição do Tmux

Estas funções têm de ser executadas dentro de uma sessão Tmux.

| Comando | Função |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Criar uma disposição de desenvolvimento com editor, IA e terminal |
| `tdlm <ai> [<second_ai>]` | Criar uma disposição de desenvolvimento por subdiretório |
| `tsl <count> <command>` | Criar uma disposição swarm com vários painéis |

## Terminal Ghostty

O terminal Ghostty é instalado através de _Install > Terminal_ no menu Omarchy.

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova divisão abaixo |
| `Ctrl + Shift + O` | Nova divisão ao lado |
| `Ctrl + Alt + Arrows` | Mover-se entre divisões |
| `Super + Ctrl + Shift + Arrows` | Redimensionar a divisão em 10 linhas |
| `Super + Ctrl + Shift + Alt + Arrows` | Redimensionar a divisão em 100 linhas |
| `Ctrl + Shift + T` | Novo separador |
| `Ctrl + Shift + Arrows` | Mover-se entre separadores |
| `Alt + Numbers` | Ir para um separador específico |
| `Shift + Pg Up/Down` | Percorrer o histórico |
| `Ctrl + Left mouse` | Abrir a ligação no navegador |

## Gestor de ficheiros

| Atalho de teclado | Função |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Ir para o caminho |
| `Space` | Pré-visualizar o ficheiro (navegar com as setas) |
| `Alt + Up` | Subir para a pasta superior |

## Neovim (com lazyvim)

### Navegação

| Atalho de teclado | Função |
| ------------------------ | ------------------------------- |
| `Space` | Mostrar as opções de comando |
| `Space Space` | Abrir um ficheiro por pesquisa aproximada |
| `Space E` | Alternar a barra lateral |
| `Space G G` | Mostrar os controlos git |
| `Space S G` | Pesquisar o conteúdo do ficheiro |
| `Ctrl + W W` | Saltar entre a barra lateral e o editor |
| `Ctrl + Left/right arrow` | Alterar o tamanho da barra lateral |
| `Shift + H` | Ir para o separador de ficheiro da esquerda |
| `Shift + L` | Ir para o separador de ficheiro da direita |
| `Space B D` | Fechar o separador de ficheiro |

### Na barra lateral

| Atalho de teclado | Função |
| ------------------------ | ------------------------------- |
| `A` | Adicionar um novo ficheiro no diretório superior |
| `Shift + A` | Adicionar um novo subdiretório no diretório superior |
| `D` | Eliminar o ficheiro/diretório destacado |
| `M` | Mover o ficheiro/diretório destacado |
| `R` | Renomear o ficheiro/diretório destacado |
| `?` | Mostrar a ajuda de todos os comandos |

[Consulte todos os atalhos de teclado do Neovim configurados pelo LazyVim](https://www.lazyvim.org/keymaps).

## Emojis rápidos

Pode usar `Super + Ctrl + E` para mostrar um seletor de emojis completo que coloca a seleção na área de transferência, ou pode usar estas opções de acesso rápido.

| Atalho de teclado | EM | Pista |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | sorriso |
| `Shift + CapsLock M C` | 😂 | chorar |
| `Shift + CapsLock M L` | 😍 | amor |
| `Shift + CapsLock M V` | ✌️ | vitória |
| `Shift + CapsLock M H` | ❤️ | coração |
| `Shift + CapsLock M Y` | 👍 | sim |
| `Shift + CapsLock M N` | 👎 | não |
| `Shift + CapsLock M F` | 🖕 | foda |
| `Shift + CapsLock M W` | 🤞 | desejo |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | beijo |
| `Shift + CapsLock M E` | 🙄 | revirar os olhos |
| `Shift + CapsLock M I` | 😉 | piscadela |
| `Shift + CapsLock M P` | 🙏 | rezar |
| `Shift + CapsLock M D` | 🤤 | babar |
| `Shift + CapsLock M M` | 💰 | dinheiro |
| `Shift + CapsLock M X` | 🎉 | xelebrar |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | brinde |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | saudação |
| `Shift + CapsLock M A` |💪 | braço |
| `Shift + CapsLock M B` |🤯 | a explodir |

## Preenchimentos rápidos

| Atalho de teclado | Preenchimento |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (travessão) |
| `Shift + CapsLock Space N` | O seu nome (tal como introduzido na configuração) |
| `Shift + CapsLock Space E` | O seu correio eletrónico (tal como introduzido na configuração) |

Pode adicionar outros seus: edite `~/.XCompose` e depois execute `omarchy restart xcompose` no terminal para que as alterações sejam aplicadas.
