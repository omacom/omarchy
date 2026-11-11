# Atalhos de teclado

Pode ver todas as principais combinações de teclas com `Super + K` (combinações Tmux com `Super + Alt + K` e combinações Herdr com `Super + Ctrl + K`).

## Como estão organizados os atalhos

Cada atalho está num plano, definido pelos seus modificadores, e cada plano tem uma função. É isso que impede os atalhos de se confundirem, e significa que normalmente consegue adivinhar onde está cada coisa.

| Plano | O que está lá | Exemplos |
| --- | --- | --- |
| `Super + key` | O sistema: janelas, áreas de trabalho, disposições e menus principais | `Super + Space` menu Omarchy, `Super + W` fechar janela, `Super + F` ecrã inteiro |
| `Super + Shift + key` | Aplicações | `Super + Shift + B` navegador, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Painéis e menus do sistema | `Super + Ctrl + A` áudio, `Super + Ctrl + N` rede, `Super + Ctrl + C` menu de captura |
| `Super + Ctrl + Alt + key` | Ações rápidas e avisos | `Super + Ctrl + Alt + T` mostrar a hora, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` captura de ecrã |

Adicionar `Alt` a um atalho dá-lhe uma variante da mesma coisa, nunca algo sem relação:

- `Super + Shift + B` abre o navegador; `Super + Shift + Alt + B` abre uma janela privada
- `Super + Shift + E` abre o e-mail; `Super + Shift + Alt + E` começa um novo
- `Super + F` fica em ecrã inteiro; `Super + Alt + F` fica em largura total
- `Super + Ctrl + C` abre o menu de captura; `Super + Ctrl + Alt + C` ignora o menu e tira uma captura de ecrã

Ao adicionar um atalho:

1. Escolha o plano a partir do que faz, depois escolha a tecla.
2. Não desloque um atalho existente para arranjar espaço. Encontre uma tecla livre no plano certo.
3. Use `Alt` apenas para uma variante do atalho sem ele.

Alguns atalhos quebram estas regras porque são convenientes. `Shift` com uma seta ou `Tab` desloca ou inverte em vez de abrir uma aplicação, e `Print`, as teclas multimédia, `Alt + Tab` e `Ctrl + Alt + Del` funcionam como em todo o lado. São exceções, não padrões para copiar.

Se uma predefinição não lhe servir (imagine que quer `Super + Shift + S` para capturas de ecrã como no Windows), volte a associá-la em `~/.config/hypr/bindings.lua`.

## Navegação

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + Space` | Menu Omarchy (aplicações e tudo o resto) |
| `Super + Alt + Space` | Grelha de aplicações |
| `Super + Escape` | Menu do sistema (suspender, reiniciar, etc.) |
| `Super + Ctrl + L` | Bloquear o computador |
| `Super + W` or `Super + Q` | Fechar janela |
| `Ctrl + Alt + Del` | Fechar todas as janelas |
| `Super + T` | Alternar janela entre mosaico/flutuante |
| `Super + J` | Alternar posição da janela (horizontal/vertical) |
| `Super + O` | Alternar janela emergente para fixa e flutuante |
| `Super + L` | Percorrer as disposições dwindle, scrolling e floating |
| `Super + Alt + L` | Percorrer as disposições ao contrário |
| `Super + P` | Alternar estilo de pseudojanela (natural vs. esticado) |
| `Super + F` | Ecrã inteiro |
| `Super + Alt + F` | Largura total |
| `Super + Ctrl + F` | Ecrã inteiro dentro da janela |
| `Super + 1/2/3/4` | Saltar para uma área de trabalho específica no monitor focado |
| `Super + Tab` | Saltar para a área de trabalho seguinte no monitor focado |
| `Super + Shift + Tab` | Saltar para a área de trabalho anterior no monitor focado |
| `Super + Ctrl + Tab` | Saltar para a área de trabalho onde estava antes no monitor focado |
| `Super + Shift + 1/2/3/4` | Mover janela para uma área de trabalho no monitor focado |
| `Super + Shift + Alt + 1/2/3/4` | Mover janela para uma área de trabalho no monitor focado sem a acompanhar |
| `Super + S` | Alternar scratchpad completo |
| `Super + Alt + S` | Mover janela para o scratchpad completo |
| `Super + Grave` | Alternar consola Quake |
| `Super + Shift + Grave` | Mover janela para a consola Quake |
| `Super + Shift + Ctrl + Arrows` | Mover janela para o monitor nessa direção |
| `Super + Shift + Alt + Arrows` | Mover área de trabalho para o monitor nessa direção |
| `Super + Arrow` | Mover o foco para a janela na direção da seta, passando para o monitor desse lado no limite do ecrã |
| `Super + Shift + Arrow` | Trocar a janela com outra na direção da seta, incluindo uma no monitor desse lado |
| `Super + Minus` | Expandir janela para a esquerda |
| `Super + Equal` | Encolher janela para a esquerda |
| `Super + Shift + Minus` | Encolher janela para cima |
| `Super + Shift + Equal` | Expandir janela para baixo |
| `Super + Alt + Minus/Equal` | O mesmo redimensionamento em passos mais pequenos |
| `Super + Ctrl + Minus/Equal` | O mesmo redimensionamento em passos maiores |
| `Super + Alt + Home` | Guardar largura da janela |
| `Super + Home` | Repor largura guardada da janela |
| `Super + Left Mouse` | Arrastar a janela |
| `Super + Right Mouse` | Redimensionar janela |
| `Super + Scroll Wheel` | Percorrer áreas de trabalho no monitor focado |
| `Super + G` | Alternar agrupamento de janelas |
| `Super + Alt + G` | Retirar janela do agrupamento |
| `Super + Alt + Tab` | Percorrer janelas do agrupamento |
| `Super + Alt + Shift + Tab` | Percorrer janelas do agrupamento ao contrário |
| `Super + Alt + Scroll Wheel` | Percorrer janelas do agrupamento |
| `Super + Alt + 1/2/3/4/5` | Saltar para uma janela específica do agrupamento |
| `Super + Alt + Arrow` | Mover janela para um agrupamento na direção da seta, incluindo um no monitor desse lado |
| `Super + Ctrl + Left/Right` | Mover-se entre janelas dentro de um grupo em mosaico |
| `Super + Ctrl + Z` | Ampliar o ecrã (repetir para ampliar mais) |
| `Super + Ctrl + Alt + Z` | Reduzir totalmente o zoom do ecrã |
| `Super + /` | Avançar pelas opções de escala do monitor |
| `Super + Alt + /` | Recuar pelas opções de escala do monitor |
| `Alt + Tab` | Percorrer para a frente as janelas na área de trabalho ativa |
| `Alt + Shift + Tab` | Percorrer para trás as janelas na área de trabalho ativa |
| `Ctrl + Alt + Tab` | Percorrer para a frente o foco pelos monitores |
| `Ctrl + Alt + Shift + Tab` | Percorrer para trás o foco pelos monitores |

Os atalhos de redimensionamento usam as teclas físicas `code:20` e `code:21` (XKB `<AE11>` e `<AE12>`), independentemente dos caracteres impressos no teclado. Nos teclados norte-americanos, estas teclas são `-` e `=`; nos teclados japoneses (JIS) são `-` e `^`; nos teclados espanhóis são `'` e `¡`. No JIS, `Super + ^` é `Super + Equal`, enquanto `Super + Shift + -` (que escreve `=`) é `Super + Shift + Minus`.

## Controlos do sistema

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Painel de áudio |
| `Super + Ctrl + B` | Painel Bluetooth |
| `Super + Ctrl + N` | Painel de Wi-Fi/rede |
| `Super + Ctrl + D` | Painel de ecrã |
| `Super + Ctrl + P` | Painel de energia |
| `Super + Ctrl + X` | Painel de agentes |
| `Super + Ctrl + Alt + D` | Painel de calendário |
| `Super + Ctrl + Alt + E` | Painel de relógio mundial |
| `Super + Ctrl + 1-9` | Alternar painel da barra por posição |
| `Super + Ctrl + S` | Menu de partilha (via LocalSend) |
| `Super + Ctrl + C` | Controlos de captura (captura de ecrã/gravação/seletor) |
| `Super + Ctrl + O` | Alternar menu |
| `Super + Ctrl + H` | Menu de hardware |
| `Super + Ctrl + E` | Seletor de emojis |
| `Super + Ctrl + .` | Transcodificar multimédia |
| `Super + Shift + Ctrl + A` | Escolher um agente de IA |

## Ajustes

| Atalho | Função |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Brilho máximo do ecrã |
| `Shift + Brightness Down` | Brilho mínimo do ecrã |
| `Alt + Brightness Up/Down` | Alterações precisas de 1% no brilho |
| `Alt + Volume Up/Down` | Alterações precisas de 1% no volume |
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
| `Super + Shift + Alt + X` | Compor no X |
| `Super + Shift + Y` | YouTube |

Altere/adiciona as associações em `~/.config/hypr/bindings.lua`.

## Área de transferência universal

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + A` | Selecionar tudo nas aplicações que suportam `Ctrl + A` |
| `Super + C` | Copiar |
| `Super + X` | Cortar (não no terminal) |
| `Super + V` | Colar |
| `Super + Ctrl + V` | Gestor da área de transferência |

Normalmente, no Linux, precisa de `Ctrl + Shift + C/V` para copiar e colar no terminal e de `Ctrl + C/V` para o fazer em qualquer outro lugar. Estes atalhos unificados da área de transferência do Omarchy funcionam em todo o lado.

## Captura

| Atalho | Função |
| ------------------- | ------------------------------ |
| `Print Screen` | Captura de ecrã |
| `Super + Ctrl + Alt + C` | Captura de ecrã (a mesma captura, para teclados sem tecla Print Screen) |
| `Super + Ctrl + C` | Menu de captura |
| `Alt + Print Screen` | Gravação de ecrã |
| `Super + Print Screen` | Seletor de cores |
| `Super + Ctrl + Print Screen` | Extração de texto para a área de transferência |
| `Super + Alt + [` | Tornar a sobreposição da webcam mais pequena durante a gravação |
| `Super + Alt + ]` | Tornar a sobreposição da webcam maior durante a gravação |
| `Alt + Shift + L` | Copiar o URL atual de uma webapp ou do Chromium |
| `Alt + Shift + D` | Descarregar o vídeo da página atual para `~/Videos` |
| `Alt + Space` | Iniciar/parar ditado (requer _Setup > Defaults > Dictation_) |
| `Right Alt` | Manter premido para ditar (requer _Setup > Defaults > Dictation_) |

Nas gravações de ecrã, o atalho pergunta primeiro que áudio quer e depois começa a gravar. Prima-o outra vez para parar. Veja [capturas de ecrã e gravação](12-screenshots-recording.md) para ver os detalhes.

Todas as opções de captura também estão acessíveis em _Trigger > Capture_ no menu Omarchy (`Super + Space`).

## Notificações

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + ,` | Agir sobre a notificação mais recente: abri-la ou premir o seu único botão, escolher entre as suas opções, ou dispensá-la quando não tiver nenhuma |
| `Super + Shift + ,` | Dispensar todas as notificações |
| `Super + Ctrl + ,` | Controlar as notificações com o teclado |
| `Super + Alt + ,` | Dispensar a notificação mais recente |
| `Super + Shift + Alt + ,` | Abrir o histórico de notificações |
| `Super + Ctrl + Alt + ,` | Alternar o silenciamento das notificações |

## Estilo

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Escolher um tema novo (também `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Escolher o fundo do tema (também `Super + Ctrl + Space`) |
| `Super + Backspace` | Alternar a transparência de uma janela |
| `Super + Ctrl + Backspace` | Alternar o formato quadrado de uma só janela |

As imagens de fundo extra estão em `~/.config/omarchy/backgrounds/<theme name>`. Também disponíveis via _Install > Style > Background_ no menu Omarchy.

Todas as opções de estilo também estão acessíveis em _Style_ no menu Omarchy (`Super + Space`).

## Ativar/desativar

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Alternar o bloqueio em inatividade |
| `Super + Ctrl + Delete` | Ligar/desligar o ecrã do portátil |
| `Super + Ctrl + Alt + Delete` | Alternar o espelhamento do ecrã do portátil |
| `Super + Shift + Space` | Alternar a barra superior |
| `Shift + Mute` | Mudar para a saída de áudio seguinte |
| `Shift + Play` | Mudar para a fonte multimédia seguinte |
| `Super + Shift + Backspace` | Alternar os intervalos entre janelas |
| `Super + Ctrl + Alt + F` | Alternar o ambiente de trabalho em ecrã inteiro (barra superior + intervalos entre janelas) |

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
| `Super + Ctrl + Alt + W` | Alternar o tempo como notificação |

## Tmux

A tecla de prefixo é `Ctrl + Space` (`Ctrl + B` também funciona). Pode alterar estas associações em `~/.config/tmux/tmux.conf`.

### Painéis

| Atalho | Função |
| ----------------------- | --------------------- |
| `Prefix + v` | Dividir painel ao lado (vertical) |
| `Prefix + h` | Dividir painel abaixo (horizontal) |
| `Prefix + x` | Terminar painel |
| `Prefix + z` | Alternar o zoom do painel (ecrã inteiro) |
| `Alt + Enter` | Dividir painel abaixo (sem prefixo) |
| `Alt + Shift + Enter` | Dividir painel ao lado (sem prefixo) |
| `Alt + Escape` | Terminar painel (sem prefixo) |
| `Ctrl + Alt + Arrows` | Mover-se entre painéis |
| `Ctrl + Alt + Shift + Arrows` | Redimensionar painéis |

### Janelas

| Atalho | Função |
| ----------------------- | --------------------- |
| `Prefix + c` | Nova janela |
| `Prefix + k` | Terminar janela |
| `Prefix + r` | Alterar o nome da janela |
| `Alt + 1-9` | Ir para uma janela específica |
| `Alt + Arrow Left/Right` | Mover-se entre janelas |
| `Alt + Shift + Arrow Left/Right` | Mover janela para a esquerda/direita |

### Sessões

| Atalho | Função |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sessão |
| `Prefix + K` | Terminar sessão |
| `Prefix + R` | Alterar o nome da sessão |
| `Prefix + N` | Sessão seguinte |
| `Prefix + P` | Sessão anterior |
| `Alt + Arrow Up/Down` | Mover-se entre sessões |
| `Prefix + s` | Listar sessões |
| `Prefix + d` | Desligar da sessão |

### Modo de cópia (estilo vi)

| Atalho | Função |
| ----------------------- | --------------------- |
| `Prefix + [` | Entrar no modo de cópia |
| `v` | Começar a seleção (no modo de cópia) |
| `y` | Copiar a seleção (no modo de cópia) |

### Geral

| Atalho | Função |
| ----------------------- | --------------------- |
| `Prefix + q` | Recarregar a configuração |
| `Prefix + ?` | Mostrar as associações de teclas do Tmux |
| `Prefix + :` | Linha de comandos |

### Funções de disposição do Tmux

Estas funções têm de ser executadas dentro de uma sessão Tmux.

| Comando | Função |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Criar disposição de desenvolvimento com editor, IA e terminal |
| `tdlm <ai> [<second_ai>]` | Criar disposição de desenvolvimento por subdiretório |
| `tsl <count> <command>` | Criar disposição em enxame com vários painéis |

## Terminal Ghostty

O terminal Ghostty é instalado através de _Install > Terminal_ no menu Omarchy.

| Atalho | Função |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova divisão abaixo |
| `Ctrl + Shift + O` | Nova divisão ao lado |
| `Ctrl + Alt + Arrows` | Mover-se entre divisões |
| `Super + Ctrl + Shift + Arrows` | Redimensionar divisão em 10 linhas |
| `Super + Ctrl + Shift + Alt + Arrows` | Redimensionar divisão em 100 linhas |
| `Ctrl + Shift + T` | Novo separador |
| `Ctrl + Shift + Arrows` | Mover-se entre separadores |
| `Alt + Numbers` | Ir para um separador específico |
| `Shift + Pg Up/Down` | Percorrer o histórico |
| `Ctrl + Left mouse` | Abrir ligação no navegador |

## Gestor de ficheiros

| Atalho | Função |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Ir para o caminho |
| `Space` | Pré-visualizar ficheiro (as setas navegam) |
| `Alt + Up` | Subir para a pasta acima |

## Neovim (com lazyvim)

### Navegação

| Atalho | Função |
| ------------------------ | ------------------------------- |
| `Space` | Mostrar opções de comandos |
| `Space Space` | Abrir ficheiro através de pesquisa aproximada |
| `Space E` | Alternar a barra lateral |
| `Space G G` | Mostrar controlos do git |
| `Space S G` | Pesquisar no conteúdo dos ficheiros |
| `Ctrl + W W` | Saltar entre a barra lateral e o editor |
| `Ctrl + Left/right arrow` | Alterar o tamanho da barra lateral |
| `Shift + H` | Ir para o separador de ficheiro da esquerda |
| `Shift + L` | Ir para o separador de ficheiro da direita |
| `Space B D` | Fechar separador de ficheiro |

### Na barra lateral

| Atalho | Função |
| ------------------------ | ------------------------------- |
| `A` | Adicionar novo ficheiro no diretório superior |
| `Shift + A` | Adicionar novo subdiretório no diretório superior |
| `D` | Eliminar ficheiro/diretório destacado |
| `M` | Mover ficheiro/diretório destacado |
| `R` | Alterar o nome do ficheiro/diretório destacado |
| `?` | Mostrar ajuda para todos os comandos |

[Veja todos os atalhos do Neovim configurados pelo LazyVim](https://www.lazyvim.org/keymaps).

## Emojis rápidos

Pode usar `Super + Ctrl + E` para mostrar um seletor de emojis completo que coloca a seleção na área de transferência, ou pode usar estas opções de acesso rápido.

| Atalho | EM | Pista |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | sorriso |
| `Shift + CapsLock M C` | 😂 | chorar |
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
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | brinde |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | saudação |
| `Shift + CapsLock M A` |💪 | braço |
| `Shift + CapsLock M B` |🤯 | a explodir |

## Preenchimentos rápidos

| Atalho | Preenchimento |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (travessão) |
| `Shift + CapsLock Space N` | O seu nome (tal como introduzido na configuração) |
| `Shift + CapsLock Space E` | O seu e-mail (tal como introduzido na configuração) |

Pode adicionar mais ao editar `~/.XCompose` e depois executar `omarchy-restart-xcompose` no terminal para que as alterações sejam aplicadas.
