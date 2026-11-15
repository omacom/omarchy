# Atalhos de teclado

Você pode ver todas as principais combinações de teclas com `Super + K` (combinações do Tmux com `Super + Alt + K` e combinações do Herdr com `Super + Ctrl + K`).

## Como os atalhos são organizados

Cada atalho fica em um plano, definido por seus modificadores, e cada plano tem uma função. É isso que impede os atalhos de se misturarem, e significa que geralmente você consegue adivinhar onde algo fica.

| Plano | O que fica lá | Exemplos |
| --- | --- | --- |
| `Super + key` | O sistema: janelas, áreas de trabalho, layouts e menus principais | `Super + Space` menu Omarchy, `Super + W` fechar janela, `Super + F` tela cheia |
| `Super + Shift + key` | Aplicativos | `Super + Shift + B` navegador, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Painéis e menus do sistema | `Super + Ctrl + A` áudio, `Super + Ctrl + N` rede, `Super + Ctrl + C` menu de captura |
| `Super + Ctrl + Alt + key` | Ações rápidas e avisos | `Super + Ctrl + Alt + T` mostrar a hora, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` captura de tela |

Adicionar `Alt` a um atalho oferece uma variante da mesma coisa, nunca algo sem relação:

- `Super + Shift + B` abre o navegador; `Super + Shift + Alt + B` abre uma janela privada
- `Super + Shift + E` abre o e-mail; `Super + Shift + Alt + E` inicia um novo
- `Super + F` entra em tela cheia; `Super + Alt + F` entra em largura total
- `Super + Ctrl + C` abre o menu de captura; `Super + Ctrl + Alt + C` pula o menu e faz uma captura de tela

Ao adicionar um atalho:

1. Escolha o plano pelo que ele faz, depois escolha a tecla.
2. Não mova um atalho existente para abrir espaço. Encontre uma tecla livre no plano certo.
3. Só use `Alt` para uma variante do atalho sem ele.

Alguns atalhos quebram essas regras porque são convenientes. `Shift` com uma seta ou `Tab` move ou inverte em vez de abrir um aplicativo, e `Print`, as teclas de mídia, `Alt + Tab` e `Ctrl + Alt + Del` funcionam do jeito que funcionam em todo lugar. São exceções, não padrões para copiar.

Se um padrão não servir para você (digamos que você queira `Super + Shift + S` para capturas de tela como no Windows), vincule-o novamente em `~/.config/hypr/bindings.lua`.

## Navegação

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (aplicativos e todo o resto)    |
| `Super + Alt + Space` | Grade de aplicativos |
| `Super + Escape` | Menu do sistema (suspender, reiniciar, etc)  |
| `Super + Ctrl + L` | Bloquear o computador |
| `Super + W` or `Super + Q` | Fechar a janela             |
| `Ctrl + Alt + Del` | Fechar todas as janelas |
| `Super + T`               | Alternar a janela entre mosaico/flutuante             |
| `Super + J` | Alternar a posição da janela (horizontal/vertical) |
| `Super + O`               | Alternar a janela destacada para fixa e flutuante |
| `Super + L`               | Percorrer os layouts dwindle, scrolling e floating |
| `Super + Alt + L`         | Percorrer os layouts na ordem inversa |
| `Super + P`               | Alternar o estilo pseudo da janela (natural x esticado) |
| `Super + F`                 | Entrar em tela cheia              |
| `Super + Alt + F`                 | Entrar em largura total              |
| `Super + Ctrl + F`                 | Entrar em tela cheia dentro da janela              |
| `Super + 1/2/3/4`         | Ir para uma área de trabalho específica no monitor em foco |
| `Super + Tab` | Ir para a próxima área de trabalho no monitor em foco |
| `Super + Shift + Tab` | Ir para a área de trabalho anterior no monitor em foco |
| `Super + Ctrl + Tab` | Voltar para a área de trabalho anterior no monitor em foco |
| `Super + Shift + 1/2/3/4` | Mover a janela para a área de trabalho no monitor em foco |
| `Super + Shift + Alt + 1/2/3/4` | Mover a janela para a área de trabalho no monitor em foco sem acompanhá-la |
| `Super + S` | Alternar o scratchpad completo |
| `Super + Alt + S` | Mover a janela para o scratchpad completo |
| `Super + Grave` | Alternar o console Quake |
| `Super + Shift + Grave` | Mover a janela para o console Quake |
| `Super + Shift + Ctrl + Arrows` | Mover a janela para o monitor naquela direção |
| `Super + Shift + Alt + Arrows` | Mover a área de trabalho para o monitor naquela direção |
| `Super + Arrow`  | Mover o foco para a janela na direção da seta, cruzando para o monitor daquele lado na borda da tela |
| `Super + Shift + Arrow`  | Trocar a janela com outra na direção da seta, incluindo uma no monitor daquele lado |
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
| `Super + G`               | Alternar o agrupamento de janelas      |
| `Super + Alt + G`               | Mover a janela para fora do agrupamento      |
| `Super + Alt + Tab`               | Percorrer as janelas do agrupamento      |
| `Super + Alt + Shift + Tab`               | Percorrer para trás as janelas do agrupamento      |
| `Super + Alt + Scroll Wheel` | Percorrer as janelas do agrupamento |
| `Super + Alt + 1/2/3/4/5`               | Ir para uma janela específica no agrupamento      |
| `Super + Alt + Arrow`  | Mover a janela para dentro do agrupamento na direção da seta, incluindo uma no monitor daquele lado |
| `Super + Ctrl + Left/Right`  | Mover-se entre as janelas dentro de um grupo em mosaico |
| `Super + Ctrl + Z` | Ampliar a tela (repita para ampliar mais) |
| `Super + Ctrl + Alt + Z` | Reduzir totalmente o zoom da tela |
| `Super + /` | Avançar pelas opções de escala do monitor |
| `Super + Alt + /` | Retroceder pelas opções de escala do monitor |
| `Alt + Tab` | Percorrer para frente as janelas na área de trabalho ativa |
| `Alt + Shift + Tab` | Percorrer para trás as janelas na área de trabalho ativa |
| `Ctrl + Alt + Tab`| Percorrer o foco para frente pelos monitores |
| `Ctrl + Alt + Shift + Tab`| Percorrer o foco para trás pelos monitores |

Os atalhos de redimensionamento usam as teclas físicas `code:20` e `code:21` (XKB `<AE11>` e `<AE12>`), independentemente dos caracteres impressos no teclado. Em teclados US, essas teclas são `-` e `=`; em teclados japoneses (JIS), são `-` e `^`; em teclados espanhóis, são `'` e `¡`. No JIS, `Super + ^` é `Super + Equal`, enquanto `Super + Shift + -` (que digita `=`) é `Super + Shift + Minus`.

## Controles do sistema

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Painel de áudio    |
| `Super + Ctrl + B`           | Painel Bluetooth    |
| `Super + Ctrl + N`           | Painel Wi-Fi/rede    |
| `Super + Ctrl + D`           | Painel de exibição    |
| `Super + Ctrl + P`           | Painel de energia    |
| `Super + Ctrl + X`           | Painel de agentes    |
| `Super + Ctrl + Alt + D`           | Painel de calendário    |
| `Super + Ctrl + Alt + E`           | Painel de relógio mundial    |
| `Super + Ctrl + 1-9`           | Alternar o painel da barra pela posição    |
| `Super + Ctrl + S` | Menu de compartilhamento (via LocalSend) |
| `Super + Ctrl + C` | Controles de captura (captura de tela/-gravação/seletor) |
| `Super + Ctrl + O` | Menu de alternâncias |
| `Super + Ctrl + H` | Menu de hardware |
| `Super + Ctrl + E` | Seletor de emojis |
| `Super + Ctrl + .` | Transcodificar mídia |
| `Super + Shift + Ctrl + A` | Escolher um agente de IA |

## Ajustes

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Brilho máximo da tela |
| `Shift + Brightness Down` | Brilho mínimo da tela |
| `Alt + Brightness Up/Down` | Alterações precisas de brilho de 1% |
| `Alt + Volume Up/Down` | Alterações precisas de volume de 1% |
| `Keyboard Brightness Up/Down` | Luz de fundo do teclado mais forte/mais fraca |
| `Keyboard Backlight` | Percorrer os níveis da luz de fundo do teclado |
| `Alt + Play` | Próxima faixa |
| `Alt + Shift + Play` | Faixa anterior |

## Abrir aplicativos

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (gerenciador de agentes) |
| `Super + Shift + Return`           | Navegador    |
| `Super + Shift + Alt + B`           | Navegador (privado/anônimo)    |
| `Super + Shift + F`           | Gerenciador de arquivos    |
| `Super + Shift + Alt + F`           | Gerenciador de arquivos no cwd do terminal    |
| `Super + Shift + M`           | Música (Spotify)    |
| `Super + Shift + Alt + M`           | Música (cliamp)    |
| `Super + Shift + /`           | Gerenciador de senhas (1password)    |
| `Super + Shift + Q`           | Calculadora (Omacalc)    |
| `Super + Shift + T`           | Atividade (btop)    |
| `Super + Shift + N`           | Editor (Neovim)  |
| `Super + Shift + C`           | Calendário ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Novo e-mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | IA (ChatGPT)  |
| `Super + Shift + Alt + A`           | IA (Grok)  |
| `Super + Shift + G`           | Mensageiro (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Mensageiro (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Mensageiro (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Escrita (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Altere/adicione combinações em `~/.config/hypr/bindings.lua`.

## Área de transferência universal

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + A`           | Selecionar tudo em aplicativos compatíveis com `Ctrl + A`    |
| `Super + C`           | Copiar    |
| `Super + X`           | Recortar (não no terminal)    |
| `Super + V`           | Colar    |
| `Super + Ctrl + V`           | Gerenciador da área de transferência    |

Normalmente no Linux, você precisa de `Ctrl + Shift + C/V` para copiar e colar no terminal e de `Ctrl + C/V` para fazer isso em todo o resto. Esses atalhos universais de área de transferência do Omarchy funcionam em todo lugar.

## Captura

| Atalho              | Função                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Captura de tela                      |
| `Super + Ctrl + Alt + C`            | Captura de tela (a mesma captura, para teclados sem a tecla Print Screen) |
| `Super + Ctrl + C` | Menu de captura |
| `Alt + Print Screen`            | Gravação de tela                     |
| `Super + Print Screen` | Seletor de cores |
| `Super + Ctrl + Print Screen` | Extração de texto para a área de transferência |
| `Super + Alt + [` | Diminuir a sobreposição da webcam durante a gravação |
| `Super + Alt + ]` | Aumentar a sobreposição da webcam durante a gravação |
| `Alt + Shift + L` | Copiar a URL atual do webapp ou navegador |
| `Alt + Shift + D` | Baixar o vídeo da página atual para `~/Videos` |
| `Alt + Space` | Iniciar/parar o ditado (requer _Setup > Defaults > Dictation_) |
| `Right Alt` | Manter pressionado para ditar (requer _Setup > Defaults > Dictation_) |

Com gravações de tela, o atalho primeiro pergunta qual áudio você quer, depois começa a gravar. Pressione-o novamente para parar. Veja [capturas de tela e gravação](12-screenshots-recording.md) para os detalhes.

Todas as opções de captura também estão acessíveis em _Trigger > Capture_ no menu Omarchy (`Super + Space`).

## Notificações

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + ,` | Agir sobre a notificação mais recente: abri-la ou pressionar seu único botão, escolher entre suas opções ou dispensá-la quando ela não tiver nenhuma  |
| `Super + Shift + ,` | Dispensar todas as notificações |
| `Super + Ctrl + ,` | Controlar as notificações com o teclado  |
| `Super + Alt + ,` | Dispensar a notificação mais recente  |
| `Super + Shift + Alt + ,` | Abrir o histórico de notificações  |
| `Super + Ctrl + Alt + ,` | Alternar o silenciamento das notificações  |

## Estilo

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Escolher um novo tema (também `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Escolher o plano de fundo do tema (também `Super + Ctrl + Space`) |
| `Super + Backspace` | Alternar a transparência de uma janela |
| `Super + Ctrl + Backspace` | Alternar o aspecto quadrado de janela única |

Imagens de plano de fundo extras ficam em `~/.config/omarchy/backgrounds/<theme name>`. Também disponível em _Install > Style > Background_ no menu Omarchy.

Todas as opções de estilo também estão acessíveis em _Style_ no menu Omarchy (`Super + Space`).

## Alternâncias

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Alternar o bloqueio por inatividade |
| `Super + Ctrl + Delete` | Ligar/desligar a tela do laptop |
| `Super + Ctrl + Alt + Delete` | Alternar o espelhamento da tela do laptop |
| `Super + Shift + Space` | Alternar a barra superior  |
| `Shift + Mute` | Mudar para a próxima saída de áudio |
| `Shift + Play` | Mudar para a próxima fonte de mídia |
| `Super + Shift + Backspace` | Alternar os espaçamentos entre janelas |
| `Super + Ctrl + Alt + F` | Alternar a área de trabalho em tela cheia (barra superior + espaçamentos entre janelas) |

## Lembretes

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Definir um lembrete  |
| `Super + Ctrl + Alt + R` | Ver todos os lembretes  |
| `Super + Ctrl + Shift + R` | Limpar todos os lembretes  |

## Avisos

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Mostrar a hora como notificação  |
| `Super + Ctrl + Alt + B` | Mostrar a bateria como notificação  |
| `Super + Ctrl + Alt + W` | Alternar o clima como notificação  |

## Tmux

A tecla de prefixo é `Ctrl + Space` (`Ctrl + B` também funciona). Você pode alterar essas combinações em `~/.config/tmux/tmux.conf`.

### Painéis

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Prefix + v` | Dividir o painel ao lado (vertical) |
| `Prefix + h` | Dividir o painel abaixo (horizontal) |
| `Prefix + x` | Encerrar o painel |
| `Prefix + z` | Alternar o zoom do painel (tela cheia) |
| `Alt + Enter` | Dividir o painel abaixo (sem prefixo) |
| `Alt + Shift + Enter` | Dividir o painel ao lado (sem prefixo) |
| `Alt + Escape` | Encerrar o painel (sem prefixo) |
| `Ctrl + Alt + Arrows` | Mover-se entre os painéis |
| `Ctrl + Alt + Shift + Arrows` | Redimensionar os painéis |

### Janelas

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nova janela |
| `Prefix + k` | Encerrar a janela |
| `Prefix + r` | Renomear a janela |
| `Alt + 1-9` | Ir para uma janela específica |
| `Alt + Arrow Left/Right` | Mover-se entre as janelas |
| `Alt + Shift + Arrow Left/Right` | Mover a janela para a esquerda/direita |

### Sessões

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sessão |
| `Prefix + K` | Encerrar a sessão |
| `Prefix + R` | Renomear a sessão |
| `Prefix + N` | Próxima sessão |
| `Prefix + P` | Sessão anterior |
| `Alt + Arrow Up/Down` | Mover-se entre as sessões |
| `Prefix + s` | Listar as sessões |
| `Prefix + d` | Desanexar da sessão |

### Modo de cópia (estilo vi)

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Prefix + [` | Entrar no modo de cópia |
| `v` | Iniciar a seleção (no modo de cópia) |
| `y` | Copiar a seleção (no modo de cópia) |

### Geral

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Prefix + q` | Recarregar a configuração |
| `Prefix + ?` | Mostrar as combinações de teclas do Tmux |
| `Prefix + :` | Prompt de comando |

### Funções de layout do Tmux

Essas funções devem ser executadas dentro de uma sessão Tmux.

| Comando | Função |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Criar layout de desenvolvimento com editor, IA e terminal |
| `tdlm <ai> [<second_ai>]` | Criar layout de desenvolvimento por subdiretório |
| `tsl <count> <command>` | Criar layout swarm com vários painéis |

## Terminal Ghostty

O terminal Ghostty é instalado usando _Install > Terminal_ pelo menu Omarchy.

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova divisão abaixo |
| `Ctrl + Shift + O` | Nova divisão ao lado |
| `Ctrl + Alt + Arrows` | Mover-se entre as divisões |
| `Super + Ctrl + Shift + Arrows` | Redimensionar a divisão em 10 linhas |
| `Super + Ctrl + Shift + Alt + Arrows` | Redimensionar a divisão em 100 linhas |
| `Ctrl + Shift + T` | Nova aba  |
| `Ctrl + Shift + Arrows` | Mover-se entre as abas |
| `Alt + Numbers` | Ir para uma aba específica |
| `Shift + Pg Up/Down` | Rolar o histórico |
| `Ctrl + Left mouse` | Abrir o link no navegador |

## Gerenciador de arquivos

| Atalho              | Função                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ir para o caminho                     |
| `Space`               | Visualizar o arquivo (as setas navegam) |
| `Alt + Up`       | Subir para a pasta pai        |

## Neovim (com lazyvim)

### Navegação

| Atalho                   | Função                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Mostrar as opções de comando            |
| `Space Space`              | Abrir arquivo pela busca fuzzy      |
| `Space E`                  | Alternar a barra lateral                  |
| `Space G G`                | Mostrar os controles git               |
| `Space S G`                | Pesquisar o conteúdo do arquivo             |
| `Ctrl + W W`               | Alternar entre a barra lateral e o editor |
| `Ctrl + Left/right arrow`  | Alterar o tamanho da barra lateral          |
| `Shift + H`                      | Ir para a aba de arquivo à esquerda             |
| `Shift + L`                      | Ir para a aba de arquivo à direita            |
| `Space B D`                | Fechar a aba de arquivo                  |

### Na barra lateral

| Atalho                   | Função                        |
| ------------------------ | ------------------------------- |
| `A`                        | Adicionar novo arquivo no diretório pai      |
| `Shift + A`                | Adicionar novo subdiretório no diretório pai    |
| `D`                        | Excluir o arquivo/diretório destacado     |
| `M`                        | Mover o arquivo/diretório destacado       |
| `R`                        | Renomear o arquivo/diretório destacado     |
| `?`                        | Mostrar a ajuda de todos os comandos      |

[Veja todos os atalhos do Neovim configurados pelo LazyVim](https://www.lazyvim.org/keymaps).

## Emojis rápidos

Você pode usar `Super + Ctrl + E` para mostrar um seletor de emojis completo que colocará a seleção na área de transferência, ou pode usar estas opções de acesso rápido.

| Atalho       | EM | Dica       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | sorriso      |
| `Shift + CapsLock M C` | 😂 | choro        |
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
| `Shift + CapsLock M I` | 😉 | piscada       |
| `Shift + CapsLock M P` | 🙏 | rezar |
| `Shift + CapsLock M D` | 🤤 | babar      |
| `Shift + CapsLock M M` | 💰 | dinheiro      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | brinde      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | saudação |
| `Shift + CapsLock M A` |💪 | braço |
| `Shift + CapsLock M B` |🤯 | explodindo |

## Preenchimentos rápidos

| Atalho       | Preenchimento       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (travessão)   |
| `Shift + CapsLock Space N` | Seu nome (como informado na configuração)  |
| `Shift + CapsLock Space E` | Seu e-mail (como informado na configuração)  |

Você pode adicionar mais dos seus editando `~/.XCompose` e depois executando `omarchy-restart-xcompose` no terminal para que as alterações sejam detectadas.
