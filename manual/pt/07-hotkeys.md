# Teclas de Atalho

Pode ver todas as principais combinações de teclas com `Super + K` (combinações do Tmux com `Super + Alt + K` e combinações do Herdr com `Super + Ctrl + K`).

## Como as teclas de atalho estão organizadas

Cada tecla de atalho fica num plano, definido pelos seus modificadores, e cada plano tem uma função. É isso que impede as teclas de atalho de se confundirem umas com as outras, e significa que normalmente consegue adivinhar onde está cada coisa.

| Plano | O que está lá | Exemplos |
| --- | --- | --- |
| `Super + key` | O sistema: janelas, áreas de trabalho, disposições e menus principais | `Super + Space` Menu Omarchy, `Super + W` fechar janela, `Super + F` ecrã completo |
| `Super + Shift + key` | Aplicações | `Super + Shift + B` navegador, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Painéis e menus do sistema | `Super + Ctrl + A` áudio, `Super + Ctrl + N` rede, `Super + Ctrl + C` menu de captura |
| `Super + Ctrl + Alt + key` | Ações rápidas e avisos | `Super + Ctrl + Alt + T` mostrar a hora, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` captura de ecrã |

Adicionar `Alt` a uma tecla de atalho dá-lhe uma variante da mesma coisa, nunca algo sem relação:

- `Super + Shift + B` abre o navegador; `Super + Shift + Alt + B` abre uma janela privada
- `Super + Shift + E` abre o e-mail; `Super + Shift + Alt + E` inicia um novo
- `Super + F` entra em ecrã completo; `Super + Alt + F` entra em largura total
- `Super + Ctrl + C` abre o menu de captura; `Super + Ctrl + Alt + C` salta o menu e faz uma captura de ecrã

Ao adicionar uma tecla de atalho:

1. Escolha o plano a partir do que faz, depois escolha a tecla.
2. Não desloque uma tecla de atalho existente para arranjar espaço. Encontre uma tecla livre no plano certo.
3. Use `Alt` apenas para uma variante da tecla de atalho sem ele.

Algumas teclas de atalho quebram estas regras porque são convenientes. `Shift` com uma seta ou `Tab` move ou inverte em vez de abrir uma aplicação, e `Print`, as teclas multimédia, `Alt + Tab` e `Ctrl + Alt + Del` funcionam como em todo o lado. São exceções, não padrões para copiar.

Se uma predefinição não lhe servir (por exemplo, se quiser `Super + Shift + S` para capturas de ecrã como no Windows), volte a associá-la em `~/.config/hypr/bindings.lua`.

## Navegação

| Tecla de atalho                  | Função              |
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
| `Super + Alt + L`         | Percorrer as disposições no sentido inverso |
| `Super + P`               | Alternar estilo de janela pseudo (natural vs. esticado) |
| `Super + F`                 | Entrar em ecrã completo              |
| `Super + Alt + F`                 | Entrar em largura total              |
| `Super + Ctrl + F`                 | Entrar em ecrã completo dentro da janela              |
| `Super + 1…9/0`         | Saltar para uma área de trabalho específica (0 é 10) no monitor focado |
| `Super + Tab` | Saltar para a área de trabalho seguinte no monitor focado |
| `Super + Shift + Tab` | Saltar para a área de trabalho anterior no monitor focado |
| `Super + Ctrl + Tab` | Saltar para a área de trabalho onde estava antes no monitor focado |
| `Super + Shift + 1…9/0` | Mover janela para a área de trabalho no monitor focado |
| `Super + Shift + Alt + 1…9/0` | Mover janela para a área de trabalho no monitor focado sem a seguir |
| `Super + S` | Alternar scratchpad completo |
| `Super + Alt + S` | Mover janela para o scratchpad completo |
| `Super + Grave` | Alternar consola Quake |
| `Super + Shift + Grave` | Mover janela para a consola Quake |
| `Super + Shift + Ctrl + Arrows` | Mover janela para o monitor nessa direção |
| `Super + Shift + Alt + Arrows` | Mover área de trabalho para o monitor nessa direção |
| `Super + Arrow`  | Mover o foco para a janela na direção da seta, passando para o monitor desse lado no limite do ecrã |
| `Super + Shift + Arrow`  | Trocar a janela com outra na direção da seta, incluindo uma no monitor desse lado |
| `Super + Minus` | Expandir janela para a esquerda |
| `Super + Equal` | Encolher janela para a esquerda |
| `Super + Shift + Minus` | Encolher janela para cima |
| `Super + Shift + Equal` | Expandir janela para baixo |
| `Super + Alt + Minus/Equal` | O mesmo redimensionamento em passos mais pequenos |
| `Super + Ctrl + Minus/Equal` | O mesmo redimensionamento em passos maiores |
| `Super + Alt + Home` | Guardar largura da janela |
| `Super + Home` | Repor largura da janela guardada |
| `Super + Left Mouse` | Arrastar janela |
| `Super + Right Mouse` | Redimensionar janela |
| `Super + Scroll Wheel` | Percorrer áreas de trabalho no monitor focado |
| `Super + G`               | Alternar agrupamento de janelas      |
| `Super + Alt + G`               | Retirar janela do agrupamento      |
| `Super + Alt + Tab`               | Percorrer janelas no agrupamento      |
| `Super + Alt + Shift + Tab`               | Percorrer janelas no agrupamento no sentido inverso      |
| `Super + Alt + Scroll Wheel` | Percorrer janelas no agrupamento |
| `Super + Alt + 1/2/3/4/5`               | Saltar para uma janela específica no agrupamento      |
| `Super + Alt + Arrow`  | Mover janela para dentro do agrupamento na direção da seta, incluindo uma no monitor desse lado |
| `Super + Ctrl + Left/Right`  | Mover entre janelas dentro de um grupo em mosaico |
| `Super + Ctrl + Z` | Ampliar o ecrã (repita para ampliar mais) |
| `Super + Ctrl + Alt + Z` | Reduzir totalmente o zoom do ecrã |
| `Super + /` | Avançar pelas opções de escala do monitor |
| `Super + Alt + /` | Retroceder pelas opções de escala do monitor |
| `Alt + Tab` | Percorrer para a frente as janelas na área de trabalho ativa |
| `Alt + Shift + Tab` | Percorrer para trás as janelas na área de trabalho ativa |
| `Ctrl + Alt + Tab`| Percorrer o foco para a frente pelos monitores |
| `Ctrl + Alt + Shift + Tab`| Percorrer o foco para trás pelos monitores |
| `Super + I` | Mudar idioma de entrada (com mais de uma disposição ou método de entrada) |
| `Super + Shift + I` | Voltar ao idioma de entrada anterior |

Num touchpad, gestos com três e quatro dedos mudam de área de trabalho, movem janelas e abrem o menu e a consola Quake; veja [teclado, rato e trackpad](34-keyboard-mouse-trackpad.md) para os gestos.

Os atalhos de redimensionamento usam as teclas físicas `code:20` e `code:21` (XKB `<AE11>` e `<AE12>`), independentemente dos caracteres impressos no teclado. Nos teclados dos EUA, estas teclas são `-` e `=`; nos teclados japoneses (JIS), são `-` e `^`; nos teclados espanhóis, são `'` e `¡`. No JIS, `Super + ^` é `Super + Equal`, enquanto `Super + Shift + -` (que escreve `=`) é `Super + Shift + Minus`.

## Controlos do sistema

| Tecla de atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Painel de áudio    |
| `Super + Ctrl + B`           | Painel Bluetooth    |
| `Super + Ctrl + N`           | Painel Wi-Fi/rede    |
| `Super + Ctrl + D`           | Painel do ecrã    |
| `Super + Ctrl + P`           | Painel de energia    |
| `Super + Ctrl + X`           | Painel de agentes    |
| `Super + Ctrl + Alt + D`           | Painel de calendário    |
| `Super + Ctrl + Alt + E`           | Painel de relógio mundial    |
| `Super + Ctrl + 1-9`           | Alternar painel da barra por posição    |
| `Super + Ctrl + S` | Menu de partilha (via LocalSend) |
| `Super + Ctrl + C` | Controlos de captura (captura de ecrã/gravação/seletor) |
| `Super + Ctrl + O` | Alternar menu |
| `Super + Ctrl + H` | Menu de hardware |
| `Super + Ctrl + E` | Seletor de emojis |
| `Super + Ctrl + .` | Transcodificar multimédia |
| `Super + Shift + Ctrl + A` | Escolher um agente de IA |
| `Power` key | Menu do sistema |
| `Super + Shift + Copilot` key | Menu Omarchy |

## Ajustes

| Tecla de atalho                  | Função              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Brilho máximo do ecrã |
| `Shift + Brightness Down` | Brilho mínimo do ecrã |
| `Alt + Brightness Up/Down` | Alterações precisas de brilho de 1% |
| `Alt + Volume Up/Down` | Alterações precisas de volume de 1% |
| `Keyboard Brightness Up/Down` | Retroiluminação do teclado mais forte/mais fraca |
| `Keyboard Backlight` | Percorrer os níveis de retroiluminação do teclado |
| `Ctrl + Brightness Up/Down` | Retroiluminação do teclado mais forte/mais fraca, em teclados sem teclas próprias |
| `Mic Mute` | Silenciar o microfone |
| `Shift + Mute` | Mudar saída de áudio |
| `Touchpad Toggle` | Ligar ou desligar o touchpad |
| `Display` key | Percorrer a disposição da área de trabalho |
| `Alt + Play` | Faixa seguinte |
| `Alt + Shift + Play` | Faixa anterior |

## Abrir aplicações

| Tecla de atalho                  | Função              |
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
| `Super + Shift + N`           | Editor (Plain, ou a sua predefinição escolhida)  |
| `Super + Shift + C`           | Calendário ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Novo e-mail ([HEY](https://hey.com/))  |
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

Altere/adiciona associações em `~/.config/hypr/bindings.lua`.

## Área de transferência universal

| Tecla de atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + A`           | Selecionar tudo em aplicações que suportam `Ctrl + A`    |
| `Super + C`           | Copiar    |
| `Super + X`           | Cortar (não no terminal)    |
| `Super + V`           | Colar    |
| `Super + Ctrl + V`           | Gestor da área de transferência    |

Normalmente no Linux, precisa de `Ctrl + Shift + C/V` para copiar e colar no terminal e de `Ctrl + C/V` para o fazer em qualquer outro sítio. Estas teclas de atalho unificadas da área de transferência do Omarchy funcionam em todo o lado.

## Captura

| Tecla de atalho              | Função                       |
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
| `Alt + Shift + L` | Copiar URL atual da webapp ou do navegador |
| `Alt + Shift + D` | Transferir o vídeo da página atual para `~/Videos` |
| `Alt + Space` | Iniciar/parar ditado (requer _Configuração > Predefinições > Ditado_) |
| `Right Alt` | Manter premido para ditar (requer _Configuração > Predefinições > Ditado_) |

Nas gravações de ecrã, a tecla de atalho pergunta primeiro que áudio quer, depois começa a gravar. Prima-a novamente para parar. Veja [capturas de ecrã e gravação](12-screenshots-recording.md) para os detalhes.

Todas as opções de captura também estão acessíveis em _Acionador > Captura_ no menu Omarchy (`Super + Space`).

## Notificações

| Tecla de atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + ,` | Atuar sobre a notificação mais recente: abri-la ou premir o seu único botão, escolher uma das suas opções, ou dispensá-la quando não tiver nenhuma  |
| `Super + Shift + ,` | Dispensar todas as notificações |
| `Super + Ctrl + ,` | Controlar notificações com o teclado  |
| `Super + Alt + ,` | Dispensar a notificação mais recente  |
| `Super + Shift + Alt + ,` | Abrir histórico de notificações  |
| `Super + Ctrl + Alt + ,` | Alternar silenciamento de notificações  |

## Estilo

| Tecla de atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Escolher um novo tema (também `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Escolher fundo do tema (também `Super + Ctrl + Space`) |
| `Super + Backspace` | Alternar transparência numa janela |
| `Super + Ctrl + Backspace` | Alternar formato quadrado de janela única |

As imagens de fundo extra estão em `~/.config/omarchy/backgrounds/<theme name>`. Também disponíveis através de _Instalar > Estilo > Fundo_ no menu Omarchy.

Todas as opções de estilo também estão acessíveis em _Aparência_ no menu Omarchy (`Super + Space`).

## Alternâncias

| Tecla de atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Alternar bloqueio por inatividade |
| `Super + Ctrl + Delete` | Alternar ligar/desligar o ecrã do portátil |
| `Super + Ctrl + Alt + Delete` | Alternar espelhamento do ecrã do portátil |
| `Super + Shift + Space` | Alternar a barra superior  |
| `Shift + Mute` | Mudar para a saída de áudio seguinte |
| `Shift + Play` | Mudar para a fonte multimédia seguinte |
| `Super + Shift + Backspace` | Alternar espaços entre janelas |
| `Super + Ctrl + Alt + F` | Alternar ambiente de trabalho em ecrã completo (barra superior + espaços entre janelas) |

## Lembretes

| Tecla de atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Definir um lembrete  |
| `Super + Ctrl + Alt + R` | Ver todos os lembretes  |
| `Super + Ctrl + Shift + R` | Apagar todos os lembretes  |

## Avisos

| Tecla de atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Mostrar a hora como notificação  |
| `Super + Ctrl + Alt + B` | Mostrar a bateria como notificação  |
| `Super + Ctrl + Alt + W` | Alternar o tempo como notificação  |

## Tmux

A tecla de prefixo é `Ctrl + Space` (`Ctrl + B` também funciona). Pode alterar estas associações em `~/.config/tmux/tmux.conf`.

### Painéis

| Tecla de atalho                  | Função              |
| ----------------------- | --------------------- |
| `Prefix + v` | Dividir painel ao lado (vertical) |
| `Prefix + h` | Dividir painel abaixo (horizontal) |
| `Prefix + x` | Eliminar painel |
| `Prefix + z` | Alternar zoom do painel (ecrã completo) |
| `Alt + Enter` | Dividir painel abaixo (sem prefixo) |
| `Alt + Shift + Enter` | Dividir painel ao lado (sem prefixo) |
| `Alt + Escape` | Eliminar painel (sem prefixo) |
| `Ctrl + Alt + Arrows` | Mover entre painéis |
| `Ctrl + Alt + Shift + Arrows` | Redimensionar painéis |

### Janelas

| Tecla de atalho                  | Função              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nova janela |
| `Prefix + k` | Eliminar janela |
| `Prefix + r` | Renomear janela |
| `Alt + 1-9` | Ir para uma janela específica |
| `Alt + Arrow Left/Right` | Mover entre janelas |
| `Alt + Shift + Arrow Left/Right` | Mover janela para a esquerda/direita |

### Sessões

| Tecla de atalho                  | Função              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sessão |
| `Prefix + K` | Eliminar sessão |
| `Prefix + R` | Renomear sessão |
| `Prefix + N` | Sessão seguinte |
| `Prefix + P` | Sessão anterior |
| `Alt + Arrow Up/Down` | Mover entre sessões |
| `Prefix + s` | Listar sessões |
| `Prefix + d` | Desligar-se da sessão |

### Modo de cópia (estilo vi)

| Tecla de atalho                  | Função              |
| ----------------------- | --------------------- |
| `Prefix + [` | Entrar no modo de cópia |
| `v` | Iniciar seleção (no modo de cópia) |
| `y` | Copiar seleção (no modo de cópia) |

### Geral

| Tecla de atalho                  | Função              |
| ----------------------- | --------------------- |
| `Prefix + q` | Recarregar configuração |
| `Prefix + ?` | Mostrar combinações de teclas do Tmux |
| `Prefix + :` | Linha de comandos |

### Funções de disposição do Tmux

Estas funções têm de ser executadas dentro de uma sessão Tmux.

| Comando | Função |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Criar disposição de desenvolvimento com editor, IA e terminal |
| `tdlm <ai> [<second_ai>]` | Criar disposição de desenvolvimento por subdiretório |
| `tsl <count> <command>` | Criar disposição swarm com vários painéis |

## Terminal Ghostty

O terminal Ghostty é instalado através de _Instalar > Terminal_ no menu Omarchy.

| Tecla de atalho                  | Função              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova divisão abaixo |
| `Ctrl + Shift + O` | Nova divisão ao lado |
| `Ctrl + Alt + Arrows` | Mover entre divisões |
| `Super + Ctrl + Shift + Arrows` | Redimensionar divisão em 10 linhas |
| `Super + Ctrl + Shift + Alt + Arrows` | Redimensionar divisão em 100 linhas |
| `Ctrl + Shift + T` | Novo separador  |
| `Ctrl + Shift + Arrows` | Mover entre separadores |
| `Alt + Numbers` | Ir para um separador específico |
| `Shift + Pg Up/Down` | Percorrer o histórico |
| `Ctrl + Left mouse` | Abrir ligação no navegador |

## Gestor de Ficheiros

| Tecla de atalho              | Função                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ir para o caminho                     |
| `Space`               | Pré-visualizar ficheiro (as setas navegam) |
| `Alt + Up`       | Subir para a pasta superior        |

## Neovim (w/ lazyvim)

### Navegação

| Tecla de atalho                   | Função                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Mostrar opções de comandos            |
| `Space Space`              | Abrir ficheiro através de pesquisa aproximada      |
| `Space E`                  | Alternar barra lateral                  |
| `Space G G`                | Mostrar controlos do git               |
| `Space S G`                | Pesquisar conteúdo dos ficheiros             |
| `Ctrl + W W`               | Saltar entre a barra lateral e o editor |
| `Ctrl + Left/right arrow`  | Alterar tamanho da barra lateral          |
| `Shift + H`                      | Ir para o separador de ficheiro da esquerda             |
| `Shift + L`                      | Ir para o separador de ficheiro da direita            |
| `Space B D`                | Fechar separador de ficheiro                  |

### Na barra lateral

| Tecla de atalho                   | Função                        |
| ------------------------ | ------------------------------- |
| `A`                        | Adicionar novo ficheiro no diretório superior      |
| `Shift + A`                | Adicionar novo subdiretório no diretório superior    |
| `D`                        | Eliminar ficheiro/diretório destacado     |
| `M`                        | Mover ficheiro/diretório destacado       |
| `R`                        | Renomear ficheiro/diretório destacado     |
| `?`                        | Mostrar ajuda para todos os comandos      |

[Veja todas as teclas de atalho do Neovim configuradas pelo LazyVim](https://www.lazyvim.org/keymaps).

## Emojis Rápidos

Pode usar `Super + Ctrl + E` para mostrar um seletor de emojis completo que coloca a seleção na área de transferência, ou pode usar estas opções de acesso rápido.

| Tecla de atalho       | EM | Pista       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | sorriso      |
| `Shift + CapsLock M C` | 😂 | chorar        |
| `Shift + CapsLock M L` | 😍 | amor       |
| `Shift + CapsLock M V` | ✌️ | vitória    |
| `Shift + CapsLock M H` | ❤️ | coração      |
| `Shift + CapsLock M Y` | 👍 | sim        |
| `Shift + CapsLock M N` | 👎 | não         |
| `Shift + CapsLock M F` | 🖕 | foda-se       |
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

## Completações Rápidas

| Tecla de atalho       | Completação       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | O seu nome (tal como introduzido na configuração)  |
| `Shift + CapsLock Space E` | O seu e-mail (tal como introduzido na configuração)  |

Pode adicionar mais das suas editando `~/.XCompose` e depois executando `omarchy restart xcompose` no terminal para as alterações serem aplicadas.
