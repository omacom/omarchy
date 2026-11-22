# Atalhos de teclado

Você pode ver todos os principais atalhos de teclado com `Super + K` (atalhos do Tmux com `Super + Alt + K` e atalhos do Herdr com `Super + Ctrl + K`).

## Como os atalhos de teclado são organizados

Cada atalho fica em um plano, definido pelos seus modificadores, e cada plano tem uma única função. É isso que impede que os atalhos se misturem, e significa que você normalmente consegue adivinhar onde cada coisa fica.

| Plano | O que fica lá | Exemplos |
| --- | --- | --- |
| `Super + key` | O sistema: janelas, áreas de trabalho, layouts e menus principais | `Super + Space` menu do Omarchy, `Super + W` fechar janela, `Super + F` tela cheia |
| `Super + Shift + key` | Aplicativos | `Super + Shift + B` navegador, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Painéis e menus do sistema | `Super + Ctrl + A` áudio, `Super + Ctrl + N` rede, `Super + Ctrl + C` menu de captura |
| `Super + Ctrl + Alt + key` | Ações rápidas e avisos | `Super + Ctrl + Alt + T` mostrar hora, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` captura de tela |

Adicionar `Alt` a um atalho oferece uma variante da mesma coisa, nunca algo sem relação:

- `Super + Shift + B` abre o navegador; `Super + Shift + Alt + B` abre uma janela privativa
- `Super + Shift + E` abre o e-mail; `Super + Shift + Alt + E` inicia um novo
- `Super + F` entra em tela cheia; `Super + Alt + F` entra em largura total
- `Super + Ctrl + C` abre o menu de captura; `Super + Ctrl + Alt + C` pula o menu e faz uma captura de tela

Ao adicionar um atalho:

1. Escolha o plano pelo que ele faz, depois escolha a tecla.
2. Não mova um atalho existente para abrir espaço. Encontre uma tecla livre no plano certo.
3. Use `Alt` somente para uma variante do atalho sem ele.

Alguns atalhos quebram essas regras porque são convenientes. `Shift` com uma seta ou `Tab` move ou inverte, em vez de abrir um aplicativo, e `Print`, as teclas de mídia, `Alt + Tab` e `Ctrl + Alt + Del` funcionam do mesmo jeito que em qualquer outro lugar. São exceções, não padrões para copiar.

Se um padrão não servir para você (digamos que você queira `Super + Shift + S` para capturas de tela, como no Windows), redefina-o em `~/.config/hypr/bindings.lua`.

## Navegação

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + Space` | Menu do Omarchy (aplicativos e todo o resto) |
| `Super + Alt + Space` | Grade de aplicativos |
| `Super + Escape` | Menu do sistema (suspender, reiniciar etc.) |
| `Super + Ctrl + L` | Bloquear o computador |
| `Super + W` ou `Super + Q` | Fechar janela |
| `Ctrl + Alt + Del` | Fechar todas as janelas |
| `Super + K` | Mostrar todos os atalhos |
| `Super + Alt + K` | Mostrar atalhos do tmux |
| `Super + Ctrl + K` | Mostrar atalhos do herdr |
| `Super + M` | Minimizar a janela para a dock |
| `Super + T` | Alternar a janela entre lado a lado/flutuante |
| `Super + J` | Alternar a posição da janela (horizontal/vertical) |
| `Super + O` | Alternar a janela destacada para fixa e flutuante |
| `Super + L` | Percorrer os layouts dwindle, scrolling e floating |
| `Super + Alt + L` | Percorrer os layouts na ordem inversa |
| `Super + P` | Alternar o estilo de janela pseudo (natural ou esticado) |
| `Super + F` | Entrar em tela cheia |
| `Super + Alt + F` | Entrar em largura total |
| `Super + Ctrl + F` | Entrar em tela cheia dentro da janela |
| `Super + 1…9/0` | Ir para a área de trabalho específica (0 é 10) no monitor em foco |
| `Super + Tab` | Ir para a próxima área de trabalho no monitor em foco |
| `Super + Shift + Tab` | Ir para a área de trabalho anterior no monitor em foco |
| `Super + Ctrl + Tab` | Ir para a área de trabalho usada anteriormente no monitor em foco |
| `Super + Shift + 1…9/0` | Mover a janela para a área de trabalho no monitor em foco |
| `Super + Shift + Alt + 1…9/0` | Mover a janela para a área de trabalho no monitor em foco sem acompanhá-la |
| `Super + S` | Alternar o scratchpad completo |
| `Super + Alt + S` | Mover a janela para o scratchpad completo |
| `Super + Grave` | Alternar o console Quake |
| `Super + Shift + Grave` | Mover a janela para o console Quake |
| `Super + Shift + Ctrl + Arrows` | Mover a janela para o monitor naquela direção |
| `Super + Shift + Alt + Arrows` | Mover a área de trabalho para o monitor naquela direção |
| `Super + Arrow` | Mover o foco para a janela na direção da seta, cruzando para o monitor daquele lado na borda da tela |
| `Super + Shift + Arrow` | Trocar a janela com outra na direção da seta, incluindo uma no monitor daquele lado |
| `Super + Minus` | Expandir a janela para a esquerda |
| `Super + Equal` | Encolher a janela para a esquerda |
| `Super + Shift + Minus` | Encolher a janela para cima |
| `Super + Shift + Equal` | Expandir a janela para baixo |
| `Super + Alt + Minus/Equal` | O mesmo redimensionamento em passos menores |
| `Super + Ctrl + Minus/Equal` | O mesmo redimensionamento em passos maiores |
| `Super + Alt + Home` | Salvar a largura da janela |
| `Super + Home` | Restaurar a largura salva da janela |
| `Super + Left Mouse` | Arrastar a janela |
| `Super + Right Mouse` | Redimensionar a janela |
| `Super + Scroll Wheel` | Percorrer as áreas de trabalho no monitor em foco |
| `Super + G` | Alternar o agrupamento de janelas |
| `Super + Alt + G` | Remover a janela do agrupamento |
| `Super + Alt + Tab` | Percorrer as janelas do agrupamento |
| `Super + Alt + Shift + Tab` | Percorrer as janelas do agrupamento para trás |
| `Super + Alt + Scroll Wheel` | Percorrer as janelas do agrupamento |
| `Super + Alt + 1/2/3/4/5` | Ir para uma janela específica no agrupamento |
| `Super + Alt + Arrow` | Mover a janela para o agrupamento na direção da seta, incluindo uma no monitor daquele lado |
| `Super + Ctrl + Left/Right` | Mover-se entre janelas dentro de um grupo lado a lado |
| `Super + Ctrl + Z` | Ampliar a tela (repita para ampliar mais) |
| `Super + Ctrl + Alt + Z` | Reduzir totalmente o zoom da tela |
| `Super + /` | Avançar pelas opções de escala do monitor |
| `Super + Alt + /` | Voltar pelas opções de escala do monitor |
| `Alt + Tab` | Percorrer as janelas para frente na área de trabalho ativa |
| `Alt + Shift + Tab` | Percorrer as janelas para trás na área de trabalho ativa |
| `Ctrl + Alt + Tab` | Percorrer o foco para frente entre monitores |
| `Ctrl + Alt + Shift + Tab` | Percorrer o foco para trás entre monitores |
| `Super + I` | Trocar o idioma de entrada (com mais de um layout ou método de entrada) |
| `Super + Shift + I` | Voltar o idioma de entrada |

Em um touchpad, deslizes com três e quatro dedos trocam de área de trabalho, movem janelas e abrem o menu e o console Quake; veja [teclado, mouse e trackpad](34-keyboard-mouse-trackpad.md) para ver os gestos.

Os atalhos de redimensionamento usam as teclas físicas `code:20` e `code:21` (XKB `<AE11>` e `<AE12>`), independentemente dos caracteres impressos no teclado. Em teclados US, essas teclas são `-` e `=`; em teclados japoneses (JIS), são `-` e `^`; em teclados espanhóis, são `'` e `¡`. No JIS, `Super + ^` é `Super + Equal`, enquanto `Super + Shift + -` (que digita `=`) é `Super + Shift + Minus`.

## Controles do sistema

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Painel de áudio |
| `Super + Ctrl + B` | Painel Bluetooth |
| `Super + Ctrl + N` | Painel de Wi-Fi/rede |
| `Super + Ctrl + D` | Painel de tela |
| `Super + Ctrl + P` | Painel de energia |
| `Super + Ctrl + X` | Painel de agentes |
| `Super + Ctrl + Alt + X` | Painel de modelos locais |
| `Super + Ctrl + Alt + D` | Painel de calendário |
| `Super + Ctrl + Alt + E` | Painel de relógio mundial |
| `Super + Ctrl + 1-9` | Alternar o painel da barra por posição |
| `Super + Ctrl + S` | Menu de compartilhamento (via LocalSend) |
| `Super + Ctrl + C` | Controles de captura (captura de tela/gravação/seletor) |
| `Super + Ctrl + O` | Alternar menu |
| `Super + Ctrl + H` | Menu de hardware |
| `Super + Ctrl + E` | Seletor de emojis |
| `Super + Ctrl + .` | Transcodificar mídia |
| `Super + Shift + Ctrl + A` | Escolher um agente de AI |
| `Power` tecla | Menu do sistema |
| `Super + Shift + Copilot` tecla | Menu do Omarchy |

## Ajustes

| Atalho | Função |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Brilho máximo da tela |
| `Shift + Brightness Down` | Brilho mínimo da tela |
| `Alt + Brightness Up/Down` | Alterações precisas de brilho de 1% |
| `Alt + Volume Up/Down` | Alterações precisas de volume de 1% |
| `Keyboard Brightness Up/Down` | Luz de fundo do teclado mais forte/mais fraca |
| `Keyboard Backlight` | Percorrer os níveis de luz de fundo do teclado |
| `Ctrl + Brightness Up/Down` | Luz de fundo do teclado mais forte/mais fraca, em teclados sem teclas próprias |
| `Mic Mute` | Silenciar o microfone |
| `Shift + Mute` | Trocar a saída de áudio |
| `Touchpad Toggle` | Ligar ou desligar o touchpad |
| `Display` tecla | Percorrer o layout da área de trabalho |
| `Alt + Play` | Próxima faixa |
| `Alt + Shift + Play` | Faixa anterior |

## Abrindo aplicativos

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (gerenciador de agentes) |
| `Super + Shift + Return` ou `Super + Shift + B` | Navegador |
| `Super + Shift + Alt + B` | Navegador (privativo/anônimo) |
| `Super + Shift + F` | Gerenciador de arquivos |
| `Super + Shift + Alt + F` | Gerenciador de arquivos no cwd do terminal |
| `Super + Shift + M` | Música (Spotify) |
| `Super + Shift + Alt + M` | Música (cliamp) |
| `Super + Shift + /` | Gerenciador de senhas (1password) |
| `Super + Shift + Q` ou `Calculator` tecla | Calculadora (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, depois de instalado) |
| `Super + Shift + T` | Atividade (btop) |
| `Super + Shift + N` | Editor (Plain, ou o padrão que você escolheu) |
| `Super + Shift + C` | Calendário ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-mail ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Novo e-mail ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Mensageiro (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Mensageiro (WhatsApp) |
| `Super + Shift + Ctrl + G` | Mensageiro (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Escrita (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (nova postagem) |
| `Super + Shift + Y` | YouTube |

Altere/adicione atalhos em `~/.config/hypr/bindings.lua`.

## Área de transferência universal

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + A` | Selecionar tudo em aplicativos que suportam `Ctrl + A` |
| `Super + C` | Copiar |
| `Super + X` | Recortar (não no terminal) |
| `Super + V` | Colar |
| `Super + Ctrl + V` | Gerenciador da área de transferência |

Normalmente no Linux, você precisa de `Ctrl + Shift + C/V` para copiar e colar no terminal e de `Ctrl + C/V` para fazer isso em todos os outros lugares. Esses atalhos unificados de área de transferência do Omarchy funcionam em todo lugar.

## Captura

| Atalho | Função |
| ------------------- | ------------------------------ |
| `Print Screen` | Captura de tela |
| `Super + Ctrl + Alt + C` | Captura de tela (a mesma captura, para teclados sem a tecla Print Screen) |
| `Super + Ctrl + C` | Menu de captura |
| `Alt + Print Screen` | Gravação de tela |
| `Super + Shift + Ctrl + Alt + C` | Gravação de tela sem áudio, pulando o menu (pressione de novo para parar) |
| `Super + Print Screen` | Seletor de cores |
| `Super + Ctrl + Print Screen` | Extração de texto para a área de transferência |
| `Super + Alt + [` | Diminuir a sobreposição da webcam durante a gravação |
| `Super + Alt + ]` | Aumentar a sobreposição da webcam durante a gravação |
| `Alt + Shift + L` | Copiar a URL atual do webapp ou navegador |
| `Alt + Shift + D` | Baixar o vídeo da página atual para `~/Videos` |
| `Alt + Space` | Iniciar/parar ditado (requer _Setup > Defaults > Dictation_) |
| `Right Alt` | Segurar para ditar (requer _Setup > Defaults > Dictation_) |

Com gravações de tela, o atalho primeiro pergunta qual áudio você quer, depois inicia a gravação. Pressione de novo para parar. Veja [capturas de tela e gravação](12-screenshots-recording.md) para ver os detalhes.

Todas as opções de captura também estão acessíveis em _Trigger > Capture_ no menu do Omarchy (`Super + Space`).

## Notificações

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + ,` | Agir na notificação mais recente: abri-la ou pressionar seu único botão, escolher entre suas opções ou dispensá-la quando ela não tiver nenhuma |
| `Super + Shift + ,` | Dispensar todas as notificações |
| `Super + Ctrl + ,` | Controlar notificações com o teclado |
| `Super + Alt + ,` | Dispensar a notificação mais recente |
| `Super + Shift + Alt + ,` | Abrir o histórico de notificações |
| `Super + Ctrl + Alt + ,` | Alternar o silenciamento de notificações |

## Estilo

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Escolher um novo tema (também `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Escolher o fundo do tema (também `Super + Ctrl + Space`) |
| `Super + Backspace` | Alternar a transparência em uma janela |
| `Super + Ctrl + Backspace` | Alternar o aspecto quadrado de janela única |

Imagens de fundo extras ficam em `~/.config/omarchy/backgrounds/<theme name>`. Também disponíveis em _Install > Style > Background_ no menu do Omarchy.

Todas as opções de estilo também estão acessíveis em _Appearance_ no menu do Omarchy (`Super + Space`).

## Alternâncias

| Atalho | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Alternar o bloqueio por inatividade |
| `Super + Ctrl + Delete` | Ligar/desligar a tela do laptop |
| `Super + Ctrl + Alt + Delete` | Alternar o espelhamento da tela do laptop |
| `Super + Shift + Space` | Alternar a barra superior |
| `Shift + Mute` | Mudar para a próxima saída de áudio |
| `Shift + Play` | Mudar para a próxima fonte de mídia |
| `Super + Shift + Backspace` | Alternar os espaços entre janelas |
| `Super + Ctrl + Alt + F` | Alternar a área de trabalho em tela cheia (barra superior + espaços entre janelas) |

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
| `Super + Ctrl + Alt + W` | Alternar o clima como notificação |

## Tmux

A tecla de prefixo é `Ctrl + Space` (`Ctrl + B` também funciona). Você pode alterar esses atalhos em `~/.config/tmux/tmux.conf`.

### Painéis

| Atalho | Função |
| ----------------------- | --------------------- |
| `Prefix + v` | Dividir o painel ao lado (vertical) |
| `Prefix + h` | Dividir o painel abaixo (horizontal) |
| `Prefix + x` | Fechar painel |
| `Prefix + z` | Alternar o zoom do painel (tela cheia) |
| `Alt + Enter` | Dividir o painel abaixo (sem prefixo) |
| `Alt + Shift + Enter` | Dividir o painel ao lado (sem prefixo) |
| `Alt + Escape` | Fechar painel (sem prefixo) |
| `Ctrl + Alt + Arrows` | Mover-se entre painéis |
| `Ctrl + Alt + Shift + Arrows` | Redimensionar painéis |

### Janelas

| Atalho | Função |
| ----------------------- | --------------------- |
| `Prefix + c` | Nova janela |
| `Prefix + k` | Fechar janela |
| `Prefix + r` | Renomear janela |
| `Alt + 1-9` | Ir para uma janela específica |
| `Alt + Arrow Left/Right` | Mover-se entre janelas |
| `Alt + Shift + Arrow Left/Right` | Mover a janela para a esquerda/direita |

### Sessões

| Atalho | Função |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sessão |
| `Prefix + K` | Fechar sessão |
| `Prefix + R` | Renomear sessão |
| `Prefix + N` | Próxima sessão |
| `Prefix + P` | Sessão anterior |
| `Alt + Arrow Up/Down` | Mover-se entre sessões |
| `Prefix + s` | Listar sessões |
| `Prefix + d` | Desconectar da sessão |

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
| `Prefix + ?` | Mostrar os atalhos do Tmux |
| `Prefix + :` | Prompt de comando |

### Funções de layout do Tmux

Essas funções devem ser executadas dentro de uma sessão do Tmux.

| Comando | Função |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Criar layout de desenvolvimento com editor, AI e terminal |
| `tdlm <ai> [<second_ai>]` | Criar layout de desenvolvimento por subdiretório |
| `tsl <count> <command>` | Criar layout swarm com vários painéis |

## Terminal Ghostty

O terminal Ghostty é instalado usando _Install > Terminal_ pelo menu do Omarchy.

| Atalho | Função |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova divisão abaixo |
| `Ctrl + Shift + O` | Nova divisão ao lado |
| `Ctrl + Alt + Arrows` | Mover-se entre divisões |
| `Super + Ctrl + Shift + Arrows` | Redimensionar a divisão em 10 linhas |
| `Super + Ctrl + Shift + Alt + Arrows` | Redimensionar a divisão em 100 linhas |
| `Ctrl + Shift + T` | Nova aba |
| `Ctrl + Shift + Arrows` | Mover-se entre abas |
| `Alt + Numbers` | Ir para uma aba específica |
| `Shift + Pg Up/Down` | Rolar o histórico |
| `Ctrl + Left mouse` | Abrir o link no navegador |

## Gerenciador de arquivos

| Atalho | Função |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Ir para o caminho |
| `Space` | Visualizar o arquivo (as setas navegam) |
| `Alt + Up` | Ir para a pasta pai |

## Neovim (com lazyvim)

### Navegação

| Atalho | Função |
| ------------------------ | ------------------------------- |
| `Space` | Mostrar opções de comando |
| `Space Space` | Abrir arquivo por busca fuzzy |
| `Space E` | Alternar a barra lateral |
| `Space G G` | Mostrar controles do git |
| `Space S G` | Pesquisar o conteúdo do arquivo |
| `Ctrl + W W` | Saltar entre a barra lateral e o editor |
| `Ctrl + Left/right arrow` | Alterar o tamanho da barra lateral |
| `Shift + H` | Ir para a aba de arquivo da esquerda |
| `Shift + L` | Ir para a aba de arquivo da direita |
| `Space B D` | Fechar a aba de arquivo |

### Na barra lateral

| Atalho | Função |
| ------------------------ | ------------------------------- |
| `A` | Adicionar novo arquivo no diretório pai |
| `Shift + A` | Adicionar novo subdiretório no diretório pai |
| `D` | Excluir o arquivo/diretório destacado |
| `M` | Mover o arquivo/diretório destacado |
| `R` | Renomear o arquivo/diretório destacado |
| `?` | Mostrar ajuda para todos os comandos |

[Veja todos os atalhos de teclado do Neovim configurados pelo LazyVim](https://www.lazyvim.org/keymaps).

## Emojis rápidos

Você pode usar `Super + Ctrl + E` para mostrar um seletor de emojis completo que colocará a seleção na área de transferência, ou pode usar estas opções de acesso rápido.

| Atalho | EM | Dica |
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
| `Shift + CapsLock M I` | 😉 | piscada |
| `Shift + CapsLock M P` | 🙏 | oração |
| `Shift + CapsLock M D` | 🤤 | babar |
| `Shift + CapsLock M M` | 💰 | dinheiro |
| `Shift + CapsLock M X` | 🎉 | celebração |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | brinde |
| `Shift + CapsLock M O` | 👌 | ok |
| `Shift + CapsLock M G` | 👋 | saudação |
| `Shift + CapsLock M A` | 💪 | braço |
| `Shift + CapsLock M B` | 🤯 | explodindo |

## Preenchimentos rápidos

| Atalho | Preenchimento |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (travessão) |
| `Shift + CapsLock Space N` | Seu nome (como informado na configuração) |
| `Shift + CapsLock Space E` | Seu e-mail (como informado na configuração) |

Você pode adicionar mais dos seus editando `~/.XCompose` e depois executando `omarchy restart xcompose` no terminal para que as alterações sejam detectadas.
