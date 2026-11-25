# Atalhos de teclado

Pode ver todas as principais combinações de teclas com `Super + K` (as combinações do Tmux com `Super + Alt + K` e as do Herdr com `Super + Ctrl + K`).

## Como estão organizadas as teclas de atalho

Cada tecla de atalho está num plano, definido pelos seus modificadores, e cada plano tem uma função. É isso que impede as teclas de atalho de se confundirem e significa que, normalmente, consegue adivinhar onde está cada coisa.

| Plano | O que encontra lá | Exemplos |
| --- | --- | --- |
| `Super + key` | O sistema: janelas, áreas de trabalho, disposições e menus principais | `Super + Space` menu Omarchy, `Super + W` fechar janela, `Super + F` ecrã inteiro |
| `Super + Shift + key` | Aplicações | `Super + Shift + B` navegador, `Super + Shift + E` email, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Painéis e menus do sistema | `Super + Ctrl + A` áudio, `Super + Ctrl + N` rede, `Super + Ctrl + C` menu de captura |
| `Super + Ctrl + Alt + key` | Ações rápidas e avisos | `Super + Ctrl + Alt + T` mostrar as horas, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` captura de ecrã |

Adicionar `Alt` a uma tecla de atalho dá-lhe uma variante da mesma coisa, nunca algo sem relação:

- `Super + Shift + B` abre o navegador; `Super + Shift + Alt + B` abre uma janela privada
- `Super + Shift + E` abre o email; `Super + Shift + Alt + E` começa um novo
- `Super + F` passa a ecrã inteiro; `Super + Alt + F` passa a largura total
- `Super + Ctrl + C` abre o menu de captura; `Super + Ctrl + Alt + C` salta o menu e tira uma captura de ecrã

Ao adicionar uma tecla de atalho:

1. Escolha o plano a partir do que faz, depois escolha a tecla.
2. Não desloque uma tecla de atalho existente para arranjar espaço. Encontre uma tecla livre no plano certo.
3. Use `Alt` apenas para uma variante da tecla de atalho sem ele.

Algumas teclas de atalho quebram estas regras porque são convenientes. `Shift` com uma seta ou `Tab` desloca ou inverte em vez de abrir uma aplicação, e `Print`, as teclas multimédia, `Alt + Tab` e `Ctrl + Alt + Del` funcionam como em qualquer outro lado. São exceções, não padrões para copiar.

Se uma predefinição não lhe servir (por exemplo, se quiser `Super + Shift + S` para capturas de ecrã como no Windows), volte a associá-la em `~/.config/hypr/bindings.lua`.

## Navegação

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (aplicações e tudo o resto)    |
| `Super + Alt + Space` | Grelha de aplicações |
| `Super + Escape` | Menu do sistema (suspender, reiniciar, etc.)  |
| `Super + Ctrl + L` | Bloquear computador |
| `Super + W` or `Super + Q` | Fechar janela             |
| `Ctrl + Alt + Del` | Fechar todas as janelas |
| `Super + K` | Mostrar todas as teclas de atalho |
| `Super + Alt + K` | Mostrar teclas de atalho do tmux |
| `Super + Ctrl + K` | Mostrar teclas de atalho do herdr |
| `Super + M` | Minimizar janela para a dock |
| `Super + T`               | Alternar janela entre mosaico/flutuante             |
| `Super + J` | Alternar posição da janela (horizontal/vertical) |
| `Super + O`               | Alternar a passagem da janela para fixa e flutuante |
| `Super + L`               | Percorrer as disposições dwindle, scrolling e floating |
| `Super + Alt + L`         | Percorrer as disposições ao contrário |
| `Super + P`               | Alternar o estilo pseudo da janela (natural vs. esticado) |
| `Super + F`                 | Passar a ecrã inteiro              |
| `Super + Alt + F`                 | Passar a largura total              |
| `Super + Ctrl + F`                 | Passar a ecrã inteiro dentro da janela              |
| `Super + 1…9/0`         | Saltar para uma área de trabalho específica (0 é 10) no monitor focado |
| `Super + Tab` | Saltar para a área de trabalho seguinte no monitor focado |
| `Super + Shift + Tab` | Saltar para a área de trabalho anterior no monitor focado |
| `Super + Ctrl + Tab` | Saltar para a área de trabalho onde estava antes no monitor focado |
| `Super + Shift + 1…9/0` | Mover janela para a área de trabalho no monitor focado |
| `Super + Shift + Alt + 1…9/0` | Mover janela para a área de trabalho no monitor focado sem a seguir |
| `Super + S` | Alternar o scratchpad completo |
| `Super + Alt + S` | Mover janela para o scratchpad completo |
| `Super + the key above Tab` (grave on US layouts) | Alternar a consola Quake |
| `Super + Shift + the key above Tab` (grave on US layouts) | Mover janela para a consola Quake |
| `Super + Shift + Ctrl + Arrows` | Mover janela para o monitor nessa direção |
| `Super + Shift + Alt + Arrows` | Mover a área de trabalho para o monitor nessa direção |
| `Super + Arrow`  | Mover o foco para a janela na direção da seta, passando para o monitor desse lado no limite do ecrã |
| `Super + Shift + Arrow`  | Trocar a janela com outra na direção da seta, incluindo uma no monitor desse lado |
| `Super + Minus` | Expandir janela para a esquerda |
| `Super + Equal` | Encolher janela para a esquerda |
| `Super + Shift + Minus` | Encolher janela para cima |
| `Super + Shift + Equal` | Expandir janela para baixo |
| `Super + Alt + Minus/Equal` | O mesmo redimensionamento em passos mais pequenos |
| `Super + Ctrl + Minus/Equal` | O mesmo redimensionamento em passos maiores |
| `Super + Alt + Home` | Guardar a largura da janela |
| `Super + Home` | Repor a largura guardada da janela |
| `Super + Left Mouse` | Arrastar a janela |
| `Super + Right Mouse` | Redimensionar janela |
| `Super + Scroll Wheel` | Percorrer as áreas de trabalho no monitor focado |
| `Super + G`               | Alternar o agrupamento de janelas      |
| `Super + Alt + G`               | Retirar a janela do agrupamento      |
| `Super + Alt + Tab`               | Percorrer as janelas do agrupamento      |
| `Super + Alt + Shift + Tab`               | Percorrer as janelas do agrupamento para trás      |
| `Super + Alt + Scroll Wheel` | Percorrer as janelas do agrupamento |
| `Super + Alt + 1/2/3/4/5`               | Saltar para uma janela específica do agrupamento      |
| `Super + Alt + Arrow`  | Mover a janela para dentro do agrupamento na direção da seta, incluindo uma no monitor desse lado |
| `Super + Ctrl + Left/Right`  | Mover entre janelas dentro de um grupo em mosaico |
| `Super + Ctrl + Z` | Aproximar no ecrã (repetir para aproximar mais) |
| `Super + Ctrl + Alt + Z` | Afastar totalmente do ecrã |
| `Super + /` | Avançar pelas opções de escala do monitor |
| `Super + Alt + /` | Retroceder pelas opções de escala do monitor |
| `Alt + Tab` | Percorrer para a frente as janelas na área de trabalho ativa |
| `Alt + Shift + Tab` | Percorrer para trás as janelas na área de trabalho ativa |
| `Ctrl + Alt + Tab`| Percorrer o foco para a frente pelos monitores |
| `Ctrl + Alt + Shift + Tab`| Percorrer o foco para trás pelos monitores |
| `Super + I` | Mudar o idioma de entrada (com mais de um layout ou método de entrada) |
| `Super + Shift + I` | Voltar ao idioma de entrada anterior |

Num touchpad, os gestos de deslizar com três e quatro dedos mudam de área de trabalho, movem janelas e abrem o menu e a consola Quake; consulte [teclado, rato e trackpad](34-keyboard-mouse-trackpad.md) para ver os gestos.

O redimensionamento usa as duas teclas à direita do 0, seja o que for que o seu teclado tenha impresso nelas: `-` e `=` nos teclados dos EUA, `+` e `´` nos dinamarqueses e suecos, `+` e `\` nos noruegueses, `ß` e `´` nos alemães, `'` e `¡` nos espanhóis e `-` e `^` nos japoneses (JIS). `Super + K` apresenta-as tal como o seu teclado as imprime. No JIS, `Super + ^` é `Super + Equal`, enquanto `Super + Shift + -` (que escreve `=`) é `Super + Shift + Minus`. A escala do monitor e o gestor de palavras-passe usam `/`; nos layouts que só escrevem `/` com Shift, como a maioria dos europeus, usam em vez disso a tecla à esquerda do Shift direito (`-` nos dinamarqueses e alemães).

## Controlos do sistema

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Painel de áudio    |
| `Super + Ctrl + B`           | Painel Bluetooth    |
| `Super + Ctrl + N`           | Painel Wi-Fi/rede    |
| `Super + Ctrl + D`           | Painel do ecrã    |
| `Super + Ctrl + P`           | Painel de energia    |
| `Super + Ctrl + X`           | Painel de agentes    |
| `Super + Ctrl + Alt + D`           | Painel do calendário    |
| `Super + Ctrl + Alt + E`           | Painel do relógio mundial    |
| `Super + Ctrl + 1-9`           | Alternar o painel da barra por posição    |
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

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Brilho máximo do ecrã |
| `Shift + Brightness Down` | Brilho mínimo do ecrã |
| `Alt + Brightness Up/Down` | Alterações precisas de 1% no brilho |
| `Alt + Volume Up/Down` | Alterações precisas de 1% no volume |
| `Keyboard Brightness Up/Down` | Retroiluminação do teclado mais forte/mais fraca |
| `Keyboard Backlight` | Percorrer os níveis de retroiluminação do teclado |
| `Ctrl + Brightness Up/Down` | Retroiluminação do teclado mais forte/mais fraca, em teclados sem teclas próprias |
| `Mic Mute` | Silenciar o microfone |
| `Shift + Mute` | Mudar a saída de áudio |
| `Touchpad Toggle` | Ligar ou desligar o touchpad |
| `Display` key | Percorrer a disposição das áreas de trabalho |
| `Alt + Play` | Faixa seguinte |
| `Alt + Shift + Play` | Faixa anterior |

## Iniciar aplicações

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (gestor de agentes) |
| `Super + Shift + Return` or `Super + Shift + B`  | Navegador    |
| `Super + Shift + Alt + B`           | Navegador (privado/anónimo)    |
| `Super + Shift + F`           | Gestor de ficheiros    |
| `Super + Shift + Alt + F`           | Gestor de ficheiros no cwd do terminal    |
| `Super + Shift + M`           | Música (Spotify)    |
| `Super + Shift + Alt + M`           | Música (cliamp)    |
| `Super + Shift + /`           | Gestor de palavras-passe (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Calculadora (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, depois de instalado)    |
| `Super + Shift + T`           | Atividade (btop)    |
| `Super + Shift + N`           | Editor (Plain, ou o predefinido que escolher)  |
| `Super + Shift + C`           | Calendário ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Email ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Novo email ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | IA (ChatGPT)  |
| `Super + Shift + Alt + A`           | IA (Grok)  |
| `Super + Shift + G`           | Mensagens (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Mensagens (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Mensagens (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Escrita (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (nova publicação) |
| `Super + Shift + Y`           | YouTube |

Altere/adicionar associações em `~/.config/hypr/bindings.lua`.

## Área de transferência universal

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + A`           | Selecionar tudo nas aplicações que suportam `Ctrl + A`    |
| `Super + C`           | Copiar    |
| `Super + X`           | Cortar (não no terminal)    |
| `Super + V`           | Colar    |
| `Super + Ctrl + V`           | Gestor da área de transferência    |

Normalmente, no Linux, precisa de `Ctrl + Shift + C/V` para copiar e colar no terminal e de `Ctrl + C/V` para o fazer em qualquer outro lado. Estas teclas de atalho unificadas da área de transferência do Omarchy funcionam em todo o lado.

## Captura

| Hotkey              | Function                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Captura de ecrã                      |
| `Super + Ctrl + Alt + C`            | Captura de ecrã (a mesma captura, para teclados sem tecla Print Screen) |
| `Super + Ctrl + C` | Menu de captura |
| `Alt + Print Screen`            | Gravação de ecrã                     |
| `Super + Shift + Ctrl + Alt + C` | Gravação de ecrã sem áudio, saltando o menu (prima novamente para parar) |
| `Super + Print Screen` | Seletor de cor |
| `Super + Ctrl + Print Screen` | Extração de texto para a área de transferência |
| `Super + Alt + [` | Tornar a sobreposição da webcam mais pequena durante a gravação |
| `Super + Alt + ]` | Tornar a sobreposição da webcam maior durante a gravação |
| `Alt + Shift + L` | Copiar o URL atual da webapp ou do navegador |
| `Alt + Shift + D` | Transferir o vídeo da página atual para `~/Videos` |
| `Alt + Space` | Iniciar/parar o ditado (requer _Configuração > Predefinições > Ditado_) |
| `Right Alt` | Manter premido para ditar (requer _Configuração > Predefinições > Ditado_) |

Nas gravações de ecrã, a tecla de atalho pergunta primeiro que áudio quer e só depois começa a gravar. Prima-a novamente para parar. Consulte [capturas de ecrã e gravação](12-screenshots-recording.md) para ver os detalhes.

Todas as opções de captura também estão acessíveis em _Acionador > Captura_ no menu Omarchy (`Super + Space`).

## Notificações

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + ,` | Atuar sobre a notificação mais recente: abri-la ou premir o seu único botão, escolher uma das suas opções ou dispensá-la quando não tiver nenhuma  |
| `Super + Shift + ,` | Dispensar todas as notificações |
| `Super + Ctrl + ,` | Controlar as notificações com o teclado  |
| `Super + Alt + ,` | Dispensar a notificação mais recente  |
| `Super + Shift + Alt + ,` | Abrir o histórico de notificações  |
| `Super + Ctrl + Alt + ,` | Alternar o silenciamento das notificações  |

## Estilo

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Escolher um novo tema (também `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Escolher o fundo do tema (também `Super + Ctrl + Space`) |
| `Super + Backspace` | Alternar a transparência numa janela |
| `Super + Ctrl + Backspace` | Alternar o formato quadrado de janela única |

As imagens de fundo extra estão em `~/.config/omarchy/backgrounds/<theme name>`. Também disponíveis através de _Instalar > Estilo > Fundo_ no menu Omarchy.

Todas as opções de estilo também estão acessíveis em _Aspeto_ no menu Omarchy (`Super + Space`).

## Ativar/desativar

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Alternar o bloqueio em inatividade |
| `Super + Ctrl + Delete` | Ligar/desligar o ecrã do portátil |
| `Super + Ctrl + Alt + Delete` | Alternar o espelhamento do ecrã do portátil |
| `Super + Shift + Space` | Alternar a barra superior  |
| `Shift + Mute` | Mudar para a saída de áudio seguinte |
| `Shift + Play` | Mudar para a fonte multimédia seguinte |
| `Super + Shift + Backspace` | Alternar os intervalos entre janelas |
| `Super + Ctrl + Alt + F` | Alternar o ambiente de trabalho em ecrã inteiro (barra superior + intervalos entre janelas) |

## Lembretes

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Definir um lembrete  |
| `Super + Ctrl + Alt + R` | Ver todos os lembretes  |
| `Super + Ctrl + Shift + R` | Limpar todos os lembretes  |

## Avisos

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Mostrar as horas como notificação  |
| `Super + Ctrl + Alt + B` | Mostrar a bateria como notificação  |
| `Super + Ctrl + Alt + W` | Alternar o tempo como notificação  |

## Tmux

A tecla de prefixo é `Ctrl + Space` (`Ctrl + B` também funciona). Pode alterar estas associações em `~/.config/tmux/tmux.conf`.

### Painéis

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + v` | Dividir o painel ao lado (vertical) |
| `Prefix + h` | Dividir o painel abaixo (horizontal) |
| `Prefix + x` | Encerrar o painel |
| `Prefix + z` | Alternar o zoom do painel (ecrã inteiro) |
| `Alt + Enter` | Dividir o painel abaixo (sem prefixo) |
| `Alt + Shift + Enter` | Dividir o painel ao lado (sem prefixo) |
| `Alt + Escape` | Encerrar o painel (sem prefixo) |
| `Ctrl + Alt + Arrows` | Mover entre painéis |
| `Ctrl + Alt + Shift + Arrows` | Redimensionar painéis |

### Janelas

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nova janela |
| `Prefix + k` | Encerrar a janela |
| `Prefix + r` | Mudar o nome da janela |
| `Alt + 1-9` | Ir para uma janela específica |
| `Alt + Arrow Left/Right` | Mover entre janelas |
| `Alt + Shift + Arrow Left/Right` | Mover a janela para a esquerda/direita |

### Sessões

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sessão |
| `Prefix + K` | Encerrar a sessão |
| `Prefix + R` | Mudar o nome da sessão |
| `Prefix + N` | Sessão seguinte |
| `Prefix + P` | Sessão anterior |
| `Alt + Arrow Up/Down` | Mover entre sessões |
| `Prefix + s` | Listar sessões |
| `Prefix + d` | Desligar da sessão |

### Modo de cópia (estilo vi)

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + [` | Entrar no modo de cópia |
| `v` | Começar a seleção (no modo de cópia) |
| `y` | Copiar a seleção (no modo de cópia) |

### Geral

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + q` | Recarregar a configuração |
| `Prefix + ?` | Mostrar as combinações de teclas do Tmux |
| `Prefix + :` | Linha de comandos |

### Funções de disposição do Tmux

Estas funções têm de ser executadas dentro de uma sessão Tmux.

| Command | Function |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Criar uma disposição de desenvolvimento com editor, IA e terminal |
| `tdlm <ai> [<second_ai>]` | Criar uma disposição de desenvolvimento por subdiretório |
| `tsl <count> <command>` | Criar uma disposição swarm com vários painéis |

## Terminal Ghostty

O terminal Ghostty é instalado através de _Instalar > Terminal_ no menu Omarchy.

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova divisão abaixo |
| `Ctrl + Shift + O` | Nova divisão ao lado |
| `Ctrl + Alt + Arrows` | Mover entre divisões |
| `Super + Ctrl + Shift + Arrows` | Redimensionar a divisão em 10 linhas |
| `Super + Ctrl + Shift + Alt + Arrows` | Redimensionar a divisão em 100 linhas |
| `Ctrl + Shift + T` | Novo separador  |
| `Ctrl + Shift + Arrows` | Mover entre separadores |
| `Alt + Numbers` | Ir para um separador específico |
| `Shift + Pg Up/Down` | Percorrer o histórico |
| `Ctrl + Left mouse` | Abrir a ligação no navegador |

## Gestor de ficheiros

| Hotkey              | Function                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ir para o caminho                     |
| `Space`               | Pré-visualizar o ficheiro (as setas navegam) |
| `Alt + Up`       | Ir para a pasta superior        |

## Neovim (com lazyvim)

### Navegação

| Hotkey                   | Function                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Mostrar as opções de comandos            |
| `Space Space`              | Abrir um ficheiro através de pesquisa aproximada      |
| `Space E`                  | Alternar a barra lateral                  |
| `Space G G`                | Mostrar os controlos do git               |
| `Space S G`                | Pesquisar o conteúdo dos ficheiros             |
| `Ctrl + W W`               | Saltar entre a barra lateral e o editor |
| `Ctrl + Left/right arrow`  | Alterar o tamanho da barra lateral          |
| `Shift + H`                      | Ir para o separador de ficheiro da esquerda             |
| `Shift + L`                      | Ir para o separador de ficheiro da direita            |
| `Space B D`                | Fechar o separador de ficheiro                  |

### Na barra lateral

| Hotkey                   | Function                        |
| ------------------------ | ------------------------------- |
| `A`                        | Adicionar um novo ficheiro no diretório superior      |
| `Shift + A`                | Adicionar um novo subdiretório no diretório superior    |
| `D`                        | Eliminar o ficheiro/diretório destacado     |
| `M`                        | Mover o ficheiro/diretório destacado       |
| `R`                        | Mudar o nome do ficheiro/diretório destacado     |
| `?`                        | Mostrar a ajuda para todos os comandos      |

[Veja todas as teclas de atalho do Neovim configuradas pelo LazyVim](https://www.lazyvim.org/keymaps).

## Emojis rápidos

Pode usar `Super + Ctrl + E` para mostrar um seletor de emojis completo que coloca a seleção na área de transferência, ou pode usar estas opções de acesso rápido.

| Hotkey       | EM | Clue       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | sorriso      |
| `Shift + CapsLock M C` | 😂 | chorar        |
| `Shift + CapsLock M L` | 😍 | amor       |
| `Shift + CapsLock M V` | ✌️ | vitória    |
| `Shift + CapsLock M H` | ❤️ | coração      |
| `Shift + CapsLock M Y` | 👍 | sim        |
| `Shift + CapsLock M N` | 👎 | não         |
| `Shift + CapsLock M F` | 🖕 | foda       |
| `Shift + CapsLock M W` | 🤞 | desejo       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | beijo       |
| `Shift + CapsLock M E` | 🙄 | revirar os olhos    |
| `Shift + CapsLock M I` | 😉 | piscar o olho       |
| `Shift + CapsLock M P` | 🙏 | rezar |
| `Shift + CapsLock M D` | 🤤 | babar      |
| `Shift + CapsLock M M` | 💰 | dinheiro      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | brinde      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | saudação |
| `Shift + CapsLock M A` |💪 | braço |
| `Shift + CapsLock M B` |🤯 | a explodir |

## Preenchimentos rápidos

| Hotkey       | Completion       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (travessão)   |
| `Shift + CapsLock Space N` | O seu nome (tal como introduzido na configuração)  |
| `Shift + CapsLock Space E` | O seu email (tal como introduzido na configuração)  |

Pode adicionar mais da sua autoria ao editar `~/.XCompose` e depois executar `omarchy restart xcompose` no terminal para que as alterações sejam aplicadas.
