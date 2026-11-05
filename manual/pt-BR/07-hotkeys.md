# Atalhos de teclado

Você pode ver todas as principais combinações de teclas com `Super + K` (combinações do Tmux com `Super + Alt + K` e combinações do Herdr com `Super + Ctrl + K`).

## Como os atalhos de teclado são organizados

Cada atalho de teclado fica em um plano, definido pelos seus modificadores, e cada plano tem uma função. É isso que impede os atalhos de se misturarem, e significa que você geralmente consegue adivinhar onde algo fica.

| Plano | O que fica ali | Exemplos |
| --- | --- | --- |
| `Super + key` | O sistema: janelas, áreas de trabalho, layouts e menus principais | `Super + Space` menu do Omarchy, `Super + W` fechar janela, `Super + F` tela cheia |
| `Super + Shift + key` | Aplicativos | `Super + Shift + B` navegador, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Painéis e menus do sistema | `Super + Ctrl + A` áudio, `Super + Ctrl + N` rede, `Super + Ctrl + C` menu de captura |
| `Super + Ctrl + Alt + key` | Ações rápidas e avisos | `Super + Ctrl + Alt + T` mostrar hora, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` captura de tela |

Adicionar `Alt` a um atalho oferece uma variante da mesma coisa, nunca algo sem relação:

- `Super + Shift + B` abre o navegador; `Super + Shift + Alt + B` abre uma janela privativa
- `Super + Shift + E` abre o e-mail; `Super + Shift + Alt + E` começa um novo
- `Super + F` entra em tela cheia; `Super + Alt + F` entra em largura total
- `Super + Ctrl + C` abre o menu de captura; `Super + Ctrl + Alt + C` pula o menu e faz uma captura de tela

Ao adicionar um atalho de teclado:

1. Escolha o plano pelo que ele faz, depois escolha a tecla.
2. Não mova um atalho existente para abrir espaço. Encontre uma tecla livre no plano certo.
3. Use `Alt` apenas para uma variante do atalho sem ele.

Alguns atalhos quebram essas regras porque são convenientes. `Shift` com uma seta ou `Tab` move ou inverte em vez de abrir um aplicativo, e `Print`, as teclas de mídia, `Alt + Tab` e `Ctrl + Alt + Del` funcionam do jeito que funcionam em qualquer outro lugar. São exceções, não padrões para copiar.

Se um padrão não servir para você (digamos que você queira `Super + Shift + S` para capturas de tela como no Windows), redefina-o em `~/.config/hypr/bindings.lua`.

## Navegação

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + Space` | Menu do Omarchy (aplicativos e todo o resto) |
| `Super + Alt + Space` | Grade de aplicativos |
| `Super + Escape` | Menu do sistema (suspender, reiniciar etc.) |
| `Super + Ctrl + L` | Bloquear o computador |
| `Super + W` ou `Super + Q` | Fechar janela |
| `Ctrl + Alt + Del` | Fechar todas as janelas |
| `Super + T` | Alternar janela entre lado a lado/flutuante |
| `Super + J` | Alternar posição da janela (horizontal/vertical) |
| `Super + O` | Alternar janela destacada para fixa e flutuante |
| `Super + L` | Alternar entre os layouts dwindle, scrolling e flutuante |
| `Super + Alt + L` | Alternar entre os layouts na ordem inversa |
| `Super + P` | Alternar estilo de janela pseudo (natural x esticado) |
| `Super + F` | Entrar em tela cheia |
| `Super + Alt + F` | Entrar em largura total |
| `Super + Ctrl + F` | Entrar em tela cheia dentro da janela |
| `Super + 1/2/3/4` | Ir para uma área de trabalho específica no monitor em foco |
| `Super + Tab` | Ir para a próxima área de trabalho no monitor em foco |
| `Super + Shift + Tab` | Ir para a área de trabalho anterior no monitor em foco |
| `Super + Ctrl + Tab` | Ir para a área de trabalho anterior no monitor em foco |
| `Super + Shift + 1/2/3/4` | Mover janela para uma área de trabalho no monitor em foco |
| `Super + Shift + Alt + 1/2/3/4` | Mover janela para uma área de trabalho no monitor em foco sem acompanhá-la |
| `Super + S` | Alternar scratchpad completo |
| `Super + Alt + S` | Mover janela para o scratchpad completo |
| `Super + Grave` | Alternar console Quake |
| `Super + Shift + Grave` | Mover janela para o console Quake |
| `Super + Shift + Ctrl + Arrows` | Mover janela para o monitor naquela direção |
| `Super + Shift + Alt + Arrows` | Mover área de trabalho para o monitor naquela direção |
| `Super + Arrow` | Mover o foco para a janela na direção da seta, cruzando para o monitor daquele lado na borda da tela |
| `Super + Shift + Arrow` | Trocar a janela com outra na direção da seta, incluindo uma no monitor daquele lado |
| `Super + Minus` | Expandir janela para a esquerda |
| `Super + Equal` | Encolher janela para a esquerda |
| `Super + Shift + Minus` | Encolher janela para cima |
| `Super + Shift + Equal` | Expandir janela para baixo |
| `Super + Alt + Minus/Equal` | O mesmo redimensionamento em passos menores |
| `Super + Ctrl + Minus/Equal` | O mesmo redimensionamento em passos maiores |
| `Super + Alt + Home` | Salvar largura da janela |
| `Super + Home` | Restaurar largura salva da janela |
| `Super + Left Mouse` | Arrastar a janela |
| `Super + Right Mouse` | Redimensionar janela |
| `Super + Scroll Wheel` | Rolar pelas áreas de trabalho no monitor em foco |
| `Super + G` | Alternar agrupamento de janelas |
| `Super + Alt + G` | Mover janela para fora do agrupamento |
| `Super + Alt + Tab` | Alternar entre janelas no agrupamento |
| `Super + Alt + Shift + Tab` | Alternar para trás entre janelas no agrupamento |
| `Super + Alt + Scroll Wheel` | Alternar entre janelas no agrupamento |
| `Super + Alt + 1/2/3/4/5` | Ir para uma janela específica no agrupamento |
| `Super + Alt + Arrow` | Mover janela para dentro do agrupamento na direção da seta, incluindo uma no monitor daquele lado |
| `Super + Ctrl + Left/Right` | Mover entre janelas dentro de um grupo lado a lado |
| `Super + Ctrl + Z` | Ampliar a tela (repita para ampliar mais) |
| `Super + Ctrl + Alt + Z` | Reduzir totalmente o zoom da tela |
| `Super + /` | Avançar pelas opções de escala do monitor |
| `Super + Alt + /` | Voltar pelas opções de escala do monitor |
| `Alt + Tab` | Avançar pelas janelas na área de trabalho ativa |
| `Alt + Shift + Tab` | Voltar pelas janelas na área de trabalho ativa |
| `Ctrl + Alt + Tab` | Avançar o foco pelos monitores |
| `Ctrl + Alt + Shift + Tab` | Voltar o foco pelos monitores |

Os atalhos de redimensionamento usam as teclas físicas `code:20` e `code:21` (XKB `<AE11>` e `<AE12>`), independentemente dos caracteres impressos no teclado. Em teclados dos EUA, essas teclas são `-` e `=`; em teclados japoneses (JIS), são `-` e `^`; em teclados espanhóis, são `'` e `¡`. No JIS, `Super + ^` é `Super + Equal`, enquanto `Super + Shift + -` (que digita `=`) é `Super + Shift + Minus`.

## Controles do sistema

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Painel de áudio |
| `Super + Ctrl + B` | Painel de Bluetooth |
| `Super + Ctrl + N` | Painel de Wi-Fi/rede |
| `Super + Ctrl + D` | Painel de exibição |
| `Super + Ctrl + P` | Painel de energia |
| `Super + Ctrl + Alt + D` | Painel de calendário |
| `Super + Ctrl + Alt + E` | Painel de relógio mundial |
| `Super + Ctrl + 1-9` | Alternar painel da barra por posição |
| `Super + Ctrl + S` | Menu de compartilhamento (via LocalSend) |
| `Super + Ctrl + C` | Controles de captura (captura de tela/gravação/seletor) |
| `Super + Ctrl + O` | Menu de alternância |
| `Super + Ctrl + H` | Menu de hardware |
| `Super + Ctrl + E` | Seletor de emojis |
| `Super + Ctrl + .` | Transcodificar mídia |
| `Super + Shift + Ctrl + A` | Escolher um agente de IA |

## Ajustes

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Brilho máximo da tela |
| `Shift + Brightness Down` | Brilho mínimo da tela |
| `Alt + Brightness Up/Down` | Mudanças precisas de brilho de 1% |
| `Alt + Volume Up/Down` | Mudanças precisas de volume de 1% |
| `Keyboard Brightness Up/Down` | Luz de fundo do teclado mais forte/mais fraca |
| `Keyboard Backlight` | Alternar entre os níveis de luz de fundo do teclado |
| `Alt + Play` | Próxima faixa |
| `Alt + Shift + Play` | Faixa anterior |

## Abrir aplicativos

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (gerenciador de agentes) |
| `Super + Shift + Return` | Navegador |
| `Super + Shift + Alt + B` | Navegador (privativo/anônimo) |
| `Super + Shift + F` | Gerenciador de arquivos |
| `Super + Shift + Alt + F` | Gerenciador de arquivos no diretório atual do terminal |
| `Super + Shift + M` | Música (Spotify) |
| `Super + Shift + Alt + M` | Música (cliamp) |
| `Super + Shift + /` | Gerenciador de senhas (1password) |
| `Super + Shift + Q` | Calculadora (Omacalc) |
| `Super + Shift + T` | Atividade (btop) |
| `Super + Shift + N` | Editor (Neovim) |
| `Super + Shift + C` | Calendário ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-mail ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Novo e-mail ([HEY](https://hey.com/)) |
| `Super + Shift + A` | IA (ChatGPT) |
| `Super + Shift + Alt + A` | IA (Grok) |
| `Super + Shift + G` | Mensageiro (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Mensageiro (WhatsApp) |
| `Super + Shift + Ctrl + G` | Mensageiro (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Escrita (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X Compose |
| `Super + Shift + Y` | YouTube |

Altere/adicione combinações em `~/.config/hypr/bindings.lua`.

## Área de transferência universal

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + A` | Selecionar tudo em aplicativos que oferecem suporte a `Ctrl + A` |
| `Super + C` | Copiar |
| `Super + X` | Recortar (não no terminal) |
| `Super + V` | Colar |
| `Super + Ctrl + V` | Gerenciador da área de transferência |

Normalmente no Linux, você precisa de `Ctrl + Shift + C/V` para copiar e colar no terminal e de `Ctrl + C/V` para fazer isso em todos os outros lugares. Esses atalhos unificados de área de transferência do Omarchy funcionam em todos os lugares.

## Captura

| Atalho de teclado | Função |
| ------------------- | ------------------------------ |
| `Print Screen` | Captura de tela |
| `Super + Ctrl + Alt + C` | Captura de tela (a mesma captura, para teclados sem a tecla Print Screen) |
| `Super + Ctrl + C` | Menu de captura |
| `Alt + Print Screen` | Gravação de tela |
| `Super + Print Screen` | Seletor de cores |
| `Super + Ctrl + Print Screen` | Extração de texto para a área de transferência |
| `Super + Alt + [` | Diminuir a sobreposição da webcam durante a gravação |
| `Super + Alt + ]` | Aumentar a sobreposição da webcam durante a gravação |
| `Alt + Shift + L` | Copiar o URL atual de um webapp ou do Chromium |
| `Alt + Shift + D` | Baixar o vídeo da página atual para `~/Videos` |
| `Alt + Space` | Iniciar/parar ditado (requer _Configuração > Padrões > Ditado_) |
| `Right Alt` | Segurar para ditar (requer _Configuração > Padrões > Ditado_) |

Com as gravações de tela, o atalho primeiro pergunta qual áudio você quer, depois começa a gravar. Pressione-o de novo para parar. Veja [capturas de tela e gravação](12-screenshots-recording.md) para os detalhes.

Todas as opções de captura também estão acessíveis em _Acionar > Captura_ no menu do Omarchy (`Super + Space`).

## Notificações

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + ,` | Agir sobre a notificação mais recente: abri-la ou pressionar seu único botão, escolher entre suas opções ou dispensá-la quando ela não tiver nenhuma |
| `Super + Shift + ,` | Dispensar todas as notificações |
| `Super + Ctrl + ,` | Controlar notificações com o teclado |
| `Super + Alt + ,` | Dispensar a notificação mais recente |
| `Super + Shift + Alt + ,` | Abrir o histórico de notificações |
| `Super + Ctrl + Alt + ,` | Alternar o silenciamento de notificações |

## Estilo

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Escolher um novo tema (também `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Escolher o plano de fundo do tema (também `Super + Ctrl + Space`) |
| `Super + Backspace` | Alternar transparência em uma janela |
| `Super + Ctrl + Backspace` | Alternar proporção quadrada em janela única |

Imagens extras de plano de fundo ficam em `~/.config/omarchy/backgrounds/<theme name>`. Também disponíveis via _Instalar > Estilo > Plano de fundo_ no menu do Omarchy.

Todas as opções de estilo também estão acessíveis em _Estilo_ no menu do Omarchy (`Super + Space`).

## Alternâncias

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Alternar bloqueio por inatividade |
| `Super + Ctrl + Delete` | Alternar tela do laptop ligada/desligada |
| `Super + Ctrl + Alt + Delete` | Alternar espelhamento da tela do laptop |
| `Super + Shift + Space` | Alternar a barra superior |
| `Shift + Mute` | Alternar para a próxima saída de áudio |
| `Shift + Play` | Alternar para a próxima fonte de mídia |
| `Super + Shift + Backspace` | Alternar espaçamentos entre janelas |
| `Super + Ctrl + Alt + F` | Alternar área de trabalho em tela cheia (barra superior + espaçamentos entre janelas) |

## Lembretes

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Definir um lembrete |
| `Super + Ctrl + Alt + R` | Ver todos os lembretes |
| `Super + Ctrl + Shift + R` | Limpar todos os lembretes |

## Avisos

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Mostrar a hora como notificação |
| `Super + Ctrl + Alt + B` | Mostrar a bateria como notificação |
| `Super + Ctrl + Alt + W` | Alternar o clima como notificação |

## Tmux

A tecla de prefixo é `Ctrl + Space` (`Ctrl + B` também funciona). Você pode alterar essas combinações em `~/.config/tmux/tmux.conf`.

### Painéis

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Prefix + v` | Dividir painel ao lado (vertical) |
| `Prefix + h` | Dividir painel abaixo (horizontal) |
| `Prefix + x` | Encerrar painel |
| `Prefix + z` | Alternar zoom do painel (tela cheia) |
| `Alt + Enter` | Dividir painel abaixo (sem prefixo) |
| `Alt + Shift + Enter` | Dividir painel ao lado (sem prefixo) |
| `Alt + Escape` | Encerrar painel (sem prefixo) |
| `Ctrl + Alt + Arrows` | Mover entre painéis |
| `Ctrl + Alt + Shift + Arrows` | Redimensionar painéis |

### Janelas

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Prefix + c` | Nova janela |
| `Prefix + k` | Encerrar janela |
| `Prefix + r` | Renomear janela |
| `Alt + 1-9` | Ir para uma janela específica |
| `Alt + Arrow Left/Right` | Mover entre janelas |
| `Alt + Shift + Arrow Left/Right` | Mover janela para a esquerda/direita |

### Sessões

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sessão |
| `Prefix + K` | Encerrar sessão |
| `Prefix + R` | Renomear sessão |
| `Prefix + N` | Próxima sessão |
| `Prefix + P` | Sessão anterior |
| `Alt + Arrow Up/Down` | Mover entre sessões |
| `Prefix + s` | Listar sessões |
| `Prefix + d` | Desanexar da sessão |

### Modo de cópia (estilo vi)

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Prefix + [` | Entrar no modo de cópia |
| `v` | Iniciar seleção (no modo de cópia) |
| `y` | Copiar seleção (no modo de cópia) |

### Geral

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Prefix + q` | Recarregar configuração |
| `Prefix + ?` | Mostrar combinações de teclas do Tmux |
| `Prefix + :` | Prompt de comando |

### Funções de layout do Tmux

Essas funções devem ser executadas dentro de uma sessão do Tmux.

| Comando | Função |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Criar layout de desenvolvimento com editor, IA e terminal |
| `tdlm <ai> [<second_ai>]` | Criar layout de desenvolvimento por subdiretório |
| `tsl <count> <command>` | Criar layout enxame com vários painéis |

## Terminal Ghostty

O terminal Ghostty é instalado usando _Instalar > Terminal_ via menu do Omarchy.

| Atalho de teclado | Função |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova divisão abaixo |
| `Ctrl + Shift + O` | Nova divisão ao lado |
| `Ctrl + Alt + Arrows` | Mover entre divisões |
| `Super + Ctrl + Shift + Arrows` | Redimensionar divisão em 10 linhas |
| `Super + Ctrl + Shift + Alt + Arrows` | Redimensionar divisão em 100 linhas |
| `Ctrl + Shift + T` | Nova aba |
| `Ctrl + Shift + Arrows` | Mover entre abas |
| `Alt + Numbers` | Ir para uma aba específica |
| `Shift + Pg Up/Down` | Rolar pelo histórico |
| `Ctrl + Left mouse` | Abrir link no navegador |

## Gerenciador de arquivos

| Atalho de teclado | Função |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Ir para o caminho |
| `Space` | Visualizar arquivo (as setas navegam) |
| `Alt + Up` | Subir para a pasta pai |

## Neovim (com lazyvim)

### Navegação

| Atalho de teclado | Função |
| ------------------------ | ------------------------------- |
| `Space` | Mostrar opções de comando |
| `Space Space` | Abrir arquivo via busca difusa |
| `Space E` | Alternar barra lateral |
| `Space G G` | Mostrar controles do git |
| `Space S G` | Pesquisar conteúdo do arquivo |
| `Ctrl + W W` | Alternar entre barra lateral e editor |
| `Ctrl + Left/right arrow` | Alterar o tamanho da barra lateral |
| `Shift + H` | Ir para a aba de arquivo da esquerda |
| `Shift + L` | Ir para a aba de arquivo da direita |
| `Space B D` | Fechar aba de arquivo |

### Na barra lateral

| Atalho de teclado | Função |
| ------------------------ | ------------------------------- |
| `A` | Adicionar novo arquivo no diretório pai |
| `Shift + A` | Adicionar novo subdiretório no diretório pai |
| `D` | Excluir arquivo/diretório destacado |
| `M` | Mover arquivo/diretório destacado |
| `R` | Renomear arquivo/diretório destacado |
| `?` | Mostrar ajuda para todos os comandos |

[Veja todos os atalhos de teclado do Neovim configurados pelo LazyVim](https://www.lazyvim.org/keymaps).

## Emojis rápidos

Você pode usar `Super + Ctrl + E` para mostrar um seletor completo de emojis que colocará a seleção na área de transferência, ou pode usar estas opções de acesso rápido.

| Atalho de teclado | EM | Dica |
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
| `Shift + CapsLock M P` | 🙏 | rezar |
| `Shift + CapsLock M D` | 🤤 | babar |
| `Shift + CapsLock M M` | 💰 | dinheiro |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | brinde |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | saudação |
| `Shift + CapsLock M A` |💪 | braço |
| `Shift + CapsLock M B` |🤯 | explodindo |

## Preenchimentos rápidos

| Atalho de teclado | Preenchimento |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (travessão) |
| `Shift + CapsLock Space N` | Seu nome (como informado na configuração) |
| `Shift + CapsLock Space E` | Seu e-mail (como informado na configuração) |

Você pode adicionar mais dos seus próprios editando `~/.XCompose` e depois executando `omarchy-restart-xcompose` no terminal para que as alterações sejam reconhecidas.
