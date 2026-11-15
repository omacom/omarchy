# Atalhos de teclado

Pode ver todas as principais associações de teclas com `Super + K` (associações do Tmux com `Super + Alt + K` e associações do Herdr com `Super + Ctrl + K`).

## Como estão organizados os atalhos de teclado

Cada atalho de teclado fica num plano, definido pelos seus modificadores, e cada plano tem uma função. É isso que impede os atalhos de se confundirem e significa que normalmente consegue adivinhar onde está cada coisa.

| Plano | O que está lá | Exemplos |
| --- | --- | --- |
| `Super + key` | O sistema: janelas, espaços de trabalho, disposições e menus principais | `Super + Space` menu Omarchy, `Super + W` fechar janela, `Super + F` ecrã inteiro |
| `Super + Shift + key` | Aplicações | `Super + Shift + B` navegador, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Painéis e menus do sistema | `Super + Ctrl + A` áudio, `Super + Ctrl + N` rede, `Super + Ctrl + C` menu de captura |
| `Super + Ctrl + Alt + key` | Ações rápidas e avisos | `Super + Ctrl + Alt + T` mostrar a hora, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` captura de ecrã |

Adicionar `Alt` a um atalho de teclado dá-lhe uma variante da mesma coisa, nunca algo sem relação:

- `Super + Shift + B` abre o navegador; `Super + Shift + Alt + B` abre uma janela privada
- `Super + Shift + E` abre o e-mail; `Super + Shift + Alt + E` começa um novo
- `Super + F` entra em ecrã inteiro; `Super + Alt + F` entra em largura total
- `Super + Ctrl + C` abre o menu de captura; `Super + Ctrl + Alt + C` ignora o menu e faz uma captura de ecrã

Ao adicionar um atalho de teclado:

1. Escolha o plano a partir do que ele faz, depois escolha a tecla.
2. Não desloque um atalho de teclado existente para arranjar espaço. Encontre uma tecla livre no plano certo.
3. Use `Alt` apenas para uma variante do atalho de teclado sem ele.

Alguns atalhos de teclado quebram estas regras porque são convenientes. `Shift` com uma seta ou `Tab` desloca ou inverte em vez de abrir uma aplicação, e `Print`, as teclas multimédia, `Alt + Tab` e `Ctrl + Alt + Del` funcionam como em todo o lado. São exceções, não padrões para copiar.

Se uma predefinição não lhe servir (por exemplo, se quiser `Super + Shift + S` para capturas de ecrã como no Windows), redefina-a em `~/.config/hypr/bindings.lua`.

## Navegação

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (aplicações e tudo o resto)    |
| `Super + Alt + Space` | Grelha de aplicações |
| `Super + Escape` | Menu do sistema (suspender, reiniciar, etc.)  |
| `Super + Ctrl + L` | Bloquear o computador |
| `Super + W` or `Super + Q` | Fechar janela             |
| `Ctrl + Alt + Del` | Fechar todas as janelas |
| `Super + T`               | Alternar janela entre modo em mosaico/flutuante             |
| `Super + J` | Alternar posição da janela (horizontal/vertical) |
| `Super + O`               | Alternar janela destacada para fixa e flutuante |
| `Super + L`               | Percorrer as disposições dwindle, scrolling e floating |
| `Super + Alt + L`         | Percorrer as disposições no sentido inverso |
| `Super + P`               | Alternar estilo de pseudojanela (natural vs. esticado) |
| `Super + F`                 | Entrar em ecrã inteiro              |
| `Super + Alt + F`                 | Entrar em largura total              |
| `Super + Ctrl + F`                 | Entrar em ecrã inteiro dentro da janela              |
| `Super + 1/2/3/4`         | Saltar para um espaço de trabalho específico no monitor focado |
| `Super + Tab` | Saltar para o espaço de trabalho seguinte no monitor focado |
| `Super + Shift + Tab` | Saltar para o espaço de trabalho anterior no monitor focado |
| `Super + Ctrl + Tab` | Saltar para o espaço de trabalho onde estava antes no monitor focado |
| `Super + Shift + 1/2/3/4` | Mover janela para o espaço de trabalho no monitor focado |
| `Super + Shift + Alt + 1/2/3/4` | Mover janela para o espaço de trabalho no monitor focado sem a seguir |
| `Super + S` | Ativar/desativar scratchpad completo |
| `Super + Alt + S` | Mover janela para o scratchpad completo |
| `Super + Grave` | Ativar/desativar consola Quake |
| `Super + Shift + Grave` | Mover janela para a consola Quake |
| `Super + Shift + Ctrl + Arrows` | Mover janela para o monitor nessa direção |
| `Super + Shift + Alt + Arrows` | Mover espaço de trabalho para o monitor nessa direção |
| `Super + Arrow`  | Mover o foco para a janela na direção da seta, passando para o monitor desse lado no limite do ecrã |
| `Super + Shift + Arrow`  | Trocar a janela com outra na direção da seta, incluindo uma no monitor desse lado |
| `Super + Minus` | Expandir janela para a esquerda |
| `Super + Equal` | Encolher janela para a esquerda |
| `Super + Shift + Minus` | Encolher janela para cima |
| `Super + Shift + Equal` | Expandir janela para baixo |
| `Super + Alt + Minus/Equal` | O mesmo redimensionamento em passos mais pequenos |
| `Super + Ctrl + Minus/Equal` | O mesmo redimensionamento em passos maiores |
| `Super + Alt + Home` | Guardar largura da janela |
| `Super + Home` | Restaurar largura da janela guardada |
| `Super + Left Mouse` | Arrastar a janela |
| `Super + Right Mouse` | Redimensionar janela |
| `Super + Scroll Wheel` | Percorrer os espaços de trabalho no monitor focado |
| `Super + G`               | Ativar/desativar agrupamento de janelas      |
| `Super + Alt + G`               | Retirar janela do agrupamento      |
| `Super + Alt + Tab`               | Percorrer as janelas do agrupamento      |
| `Super + Alt + Shift + Tab`               | Percorrer as janelas do agrupamento no sentido inverso      |
| `Super + Alt + Scroll Wheel` | Percorrer as janelas do agrupamento |
| `Super + Alt + 1/2/3/4/5`               | Saltar para uma janela específica do agrupamento      |
| `Super + Alt + Arrow`  | Mover janela para dentro do agrupamento na direção da seta, incluindo uma no monitor desse lado |
| `Super + Ctrl + Left/Right`  | Mover entre janelas dentro de um grupo em mosaico |
| `Super + Ctrl + Z` | Ampliar o ecrã (repetir para ampliar mais) |
| `Super + Ctrl + Alt + Z` | Reduzir totalmente o zoom do ecrã |
| `Super + /` | Avançar pelas opções de escala do monitor |
| `Super + Alt + /` | Retroceder pelas opções de escala do monitor |
| `Alt + Tab` | Percorrer para a frente as janelas no espaço de trabalho ativo |
| `Alt + Shift + Tab` | Percorrer para trás as janelas no espaço de trabalho ativo |
| `Ctrl + Alt + Tab`| Percorrer o foco para a frente pelos monitores |
| `Ctrl + Alt + Shift + Tab`| Percorrer o foco para trás pelos monitores |

Os atalhos de redimensionamento usam as teclas físicas `code:20` e `code:21` (XKB `<AE11>` e `<AE12>`), independentemente dos caracteres impressos no teclado. Nos teclados dos EUA, estas teclas são `-` e `=`; nos teclados japoneses (JIS), são `-` e `^`; nos teclados espanhóis, são `'` e `¡`. No JIS, `Super + ^` é `Super + Equal`, enquanto `Super + Shift + -` (que escreve `=`) é `Super + Shift + Minus`.

## Controlos do sistema

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Painel de áudio    |
| `Super + Ctrl + B`           | Painel de Bluetooth    |
| `Super + Ctrl + N`           | Painel de Wi-Fi/rede    |
| `Super + Ctrl + D`           | Painel do ecrã    |
| `Super + Ctrl + P`           | Painel de energia    |
| `Super + Ctrl + X`           | Painel de agentes    |
| `Super + Ctrl + Alt + D`           | Painel do calendário    |
| `Super + Ctrl + Alt + E`           | Painel do relógio mundial    |
| `Super + Ctrl + 1-9`           | Ativar/desativar painel da barra por posição    |
| `Super + Ctrl + S` | Menu de partilha (via LocalSend) |
| `Super + Ctrl + C` | Controlos de captura (captura de ecrã/gravação/seletor) |
| `Super + Ctrl + O` | Ativar/desativar menu |
| `Super + Ctrl + H` | Menu de hardware |
| `Super + Ctrl + E` | Seletor de emojis |
| `Super + Ctrl + .` | Transcodificar multimédia |
| `Super + Shift + Ctrl + A` | Escolher um agente de IA |

## Ajustes

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Brilho máximo do ecrã |
| `Shift + Brightness Down` | Brilho mínimo do ecrã |
| `Alt + Brightness Up/Down` | Alterações precisas de 1% no brilho |
| `Alt + Volume Up/Down` | Alterações precisas de 1% no volume |
| `Keyboard Brightness Up/Down` | Retroiluminação do teclado mais forte/mais fraca |
| `Keyboard Backlight` | Percorrer os níveis de retroiluminação do teclado |
| `Alt + Play` | Faixa seguinte |
| `Alt + Shift + Play` | Faixa anterior |

## Abrir aplicações

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (gestor de agentes) |
| `Super + Shift + Return`           | Navegador    |
| `Super + Shift + Alt + B`           | Navegador (privado/anónimo)    |
| `Super + Shift + F`           | Gestor de ficheiros    |
| `Super + Shift + Alt + F`           | Gestor de ficheiros no cwd do terminal    |
| `Super + Shift + M`           | Música (Spotify)    |
| `Super + Shift + Alt + M`           | Música (cliamp)    |
| `Super + Shift + /`           | Gestor de palavras-passe (1password)    |
| `Super + Shift + Q`           | Calculadora (Omacalc)    |
| `Super + Shift + T`           | Atividade (btop)    |
| `Super + Shift + N`           | Editor (Neovim)  |
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
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Altere/adicione associações em `~/.config/hypr/bindings.lua`.

## Área de transferência universal

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + A`           | Selecionar tudo nas aplicações que suportam `Ctrl + A`    |
| `Super + C`           | Copiar    |
| `Super + X`           | Cortar (não no terminal)    |
| `Super + V`           | Colar    |
| `Super + Ctrl + V`           | Gestor da área de transferência    |

Normalmente no Linux, precisa de `Ctrl + Shift + C/V` para copiar e colar no terminal e de `Ctrl + C/V` para o fazer em qualquer outro lado. Estes atalhos unificados de área de transferência do Omarchy funcionam em todo o lado.

## Captura

| Atalho              | Função                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Captura de ecrã                      |
| `Super + Ctrl + Alt + C`            | Captura de ecrã (a mesma captura, para teclados sem tecla Print Screen) |
| `Super + Ctrl + C` | Menu de captura |
| `Alt + Print Screen`            | Gravação de ecrã                     |
| `Super + Print Screen` | Seletor de cores |
| `Super + Ctrl + Print Screen` | Extração de texto para a área de transferência |
| `Super + Alt + [` | Tornar a sobreposição da webcam mais pequena durante a gravação |
| `Super + Alt + ]` | Tornar a sobreposição da webcam maior durante a gravação |
| `Alt + Shift + L` | Copiar o URL atual da aplicação web ou do navegador |
| `Alt + Shift + D` | Transferir o vídeo da página atual para `~/Videos` |
| `Alt + Space` | Iniciar/parar ditado (requer _Configuração > Predefinições > Ditado_) |
| `Right Alt` | Manter premido para ditar (requer _Configuração > Predefinições > Ditado_) |

Com as gravações de ecrã, o atalho pergunta primeiro que áudio quer, depois começa a gravar. Prima-o outra vez para parar. Consulte [capturas de ecrã e gravação](12-screenshots-recording.md) para ver os detalhes.

Todas as opções de captura também estão acessíveis em _Acionador > Captura_ no menu Omarchy (`Super + Space`).

## Notificações

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + ,` | Agir sobre a notificação mais recente: abri-la ou premir o seu único botão, escolher entre as suas opções ou dispensá-la quando não tiver nenhuma  |
| `Super + Shift + ,` | Dispensar todas as notificações |
| `Super + Ctrl + ,` | Controlar as notificações com o teclado  |
| `Super + Alt + ,` | Dispensar a notificação mais recente  |
| `Super + Shift + Alt + ,` | Abrir o histórico de notificações  |
| `Super + Ctrl + Alt + ,` | Ativar/desativar o silenciamento de notificações  |

## Estilo

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Escolher um novo tema (também `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Escolher o fundo do tema (também `Super + Ctrl + Space`) |
| `Super + Backspace` | Ativar/desativar a transparência numa janela |
| `Super + Ctrl + Backspace` | Ativar/desativar o formato quadrado de janela única |

As imagens de fundo extra estão em `~/.config/omarchy/backgrounds/<theme name>`. Também disponíveis através de _Instalar > Estilo > Fundo_ no menu Omarchy.

Todas as opções de estilo também estão acessíveis em _Estilo_ no menu Omarchy (`Super + Space`).

## Alternar

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Ativar/desativar o bloqueio em inatividade |
| `Super + Ctrl + Delete` | Ligar/desligar o ecrã do portátil |
| `Super + Ctrl + Alt + Delete` | Ativar/desativar o espelhamento do ecrã do portátil |
| `Super + Shift + Space` | Ativar/desativar a barra superior  |
| `Shift + Mute` | Mudar para a saída de áudio seguinte |
| `Shift + Play` | Mudar para a fonte multimédia seguinte |
| `Super + Shift + Backspace` | Ativar/desativar os espaços entre janelas |
| `Super + Ctrl + Alt + F` | Ativar/desativar ambiente de trabalho em ecrã inteiro (barra superior + espaços entre janelas) |

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
| `Super + Ctrl + Alt + W` | Ativar/desativar o tempo como notificação  |

## Tmux

A tecla de prefixo é `Ctrl + Space` (`Ctrl + B` também funciona). Pode alterar estas associações em `~/.config/tmux/tmux.conf`.

### Painéis

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Prefix + v` | Dividir painel ao lado (vertical) |
| `Prefix + h` | Dividir painel abaixo (horizontal) |
| `Prefix + x` | Terminar painel |
| `Prefix + z` | Ativar/desativar zoom do painel (ecrã inteiro) |
| `Alt + Enter` | Dividir painel abaixo (sem prefixo) |
| `Alt + Shift + Enter` | Dividir painel ao lado (sem prefixo) |
| `Alt + Escape` | Terminar painel (sem prefixo) |
| `Ctrl + Alt + Arrows` | Mover entre painéis |
| `Ctrl + Alt + Shift + Arrows` | Redimensionar painéis |

### Janelas

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nova janela |
| `Prefix + k` | Terminar janela |
| `Prefix + r` | Mudar o nome da janela |
| `Alt + 1-9` | Ir para uma janela específica |
| `Alt + Arrow Left/Right` | Mover entre janelas |
| `Alt + Shift + Arrow Left/Right` | Mover janela para a esquerda/direita |

### Sessões

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sessão |
| `Prefix + K` | Terminar sessão |
| `Prefix + R` | Mudar o nome da sessão |
| `Prefix + N` | Sessão seguinte |
| `Prefix + P` | Sessão anterior |
| `Alt + Arrow Up/Down` | Mover entre sessões |
| `Prefix + s` | Listar sessões |
| `Prefix + d` | Desligar da sessão |

### Modo de cópia (estilo vi)

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Prefix + [` | Entrar no modo de cópia |
| `v` | Iniciar seleção (no modo de cópia) |
| `y` | Copiar seleção (no modo de cópia) |

### Geral

| Atalho                  | Função              |
| ----------------------- | --------------------- |
| `Prefix + q` | Recarregar configuração |
| `Prefix + ?` | Mostrar associações de teclas do Tmux |
| `Prefix + :` | Linha de comandos |

### Funções de disposição do Tmux

Estas funções têm de ser executadas dentro de uma sessão Tmux.

| Comando | Função |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Criar disposição de desenvolvimento com editor, IA e terminal |
| `tdlm <ai> [<second_ai>]` | Criar disposição de desenvolvimento por subpasta |
| `tsl <count> <command>` | Criar disposição em enxame com vários painéis |

## Terminal Ghostty

O terminal Ghostty é instalado através de _Instalar > Terminal_ no menu Omarchy.

| Atalho                  | Função              |
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

## Gestor de ficheiros

| Atalho              | Função                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ir para o caminho                     |
| `Space`               | Pré-visualizar ficheiro (as setas navegam) |
| `Alt + Up`       | Subir para a pasta superior        |

## Neovim (com LazyVim)

### Navegação

| Atalho                   | Função                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Mostrar opções de comandos            |
| `Space Space`              | Abrir ficheiro através de pesquisa difusa      |
| `Space E`                  | Mostrar/ocultar barra lateral                  |
| `Space G G`                | Mostrar controlos do git               |
| `Space S G`                | Pesquisar conteúdo do ficheiro             |
| `Ctrl + W W`               | Saltar entre a barra lateral e o editor |
| `Ctrl + Left/right arrow`  | Alterar o tamanho da barra lateral          |
| `Shift + H`                      | Ir para o separador de ficheiro da esquerda             |
| `Shift + L`                      | Ir para o separador de ficheiro da direita            |
| `Space B D`                | Fechar separador de ficheiro                  |

### Na barra lateral

| Atalho                   | Função                        |
| ------------------------ | ------------------------------- |
| `A`                        | Adicionar novo ficheiro na pasta superior      |
| `Shift + A`                | Adicionar nova subpasta na pasta superior    |
| `D`                        | Eliminar o ficheiro/a pasta em destaque     |
| `M`                        | Mover o ficheiro/a pasta em destaque       |
| `R`                        | Mudar o nome do ficheiro/da pasta em destaque     |
| `?`                        | Mostrar ajuda para todos os comandos      |

[Consulte todos os atalhos do Neovim configurados pelo LazyVim](https://www.lazyvim.org/keymaps).

## Emojis rápidos

Pode usar `Super + Ctrl + E` para mostrar um seletor de emojis completo que coloca a seleção na área de transferência, ou pode usar estas opções de acesso rápido.

| Atalho       | EM | Pista       |
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

| Atalho       | Preenchimento       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | O seu nome (como introduzido na configuração)  |
| `Shift + CapsLock Space E` | O seu e-mail (como introduzido na configuração)  |

Pode adicionar mais dos seus ao editar `~/.XCompose`, depois execute `omarchy-restart-xcompose` no terminal para as alterações serem aplicadas.
