# Vir do Mac ou do Windows

Se passaste anos no macOS ou no Windows, os teus dedos sabem cem coisas que o teu cérebro já esqueceu que alguma vez aprendeu. Este capítulo é a camada de tradução: para onde vão esses instintos no Omarchy. As funcionalidades em si estão explicadas em profundidade noutros capítulos — isto é apenas o mapa.

### O Super é o centro de tudo

Toda a memória muscular que construíste à volta do Cmd ou da tecla Windows transfere-se para uma tecla: Super. É a tecla Windows num teclado de PC, e é a âncora de quase todos os atalhos no Omarchy.

O teu reflexo do Spotlight, do Raycast ou do menu Iniciar passa a ser `Super + Space`. Isso abre o menu do Omarchy, que lança aplicações, altera definições, instala software, captura o ecrã — praticamente tudo. Começa a escrever para filtrar. `Super + Alt + Space` mostra todas as aplicações numa única grelha, como faz o Launchpad. Ver [navegação](04-navigation.md).

### Sem ícones no ambiente de trabalho, e a dock fica fora do caminho

Sem ícones para organizar no ambiente de trabalho, e a dock esconde-se assim que uma área de trabalho tem uma janela, até empurrares o ponteiro para o bordo do ecrã onde ela está, o de baixo, a não ser que a movas (ver [navegação](04-navigation.md)). As aplicações arrancam a partir de um atalho (`Super + Return` para o terminal, `Super + Shift + Return` para o browser e `Super + K` para uma lista de tudo o que está mapeado) ou a partir do menu. A única peça persistente da interface é [a barra superior](05-the-top-bar.md), que assume o que a barra de menus, a área de notificação do sistema e o Centro de Notificações faziam por ti antes — e quase todos os widgets nela fazem alguma coisa com o clique esquerdo, direito e do meio.

### As janelas posicionam-se sozinhas

A maior mudança de mentalidade: não andas a arrastar janelas nem a encaixá-las em metades do ecrã. Abres uma janela e ela ocupa o ecrã inteiro. Abres uma segunda e elas dividem-no. Nunca andas a pescar uma janela debaixo de outra, porque as janelas não se sobrepõem.

Quando precisas mesmo de uma janela flutuante, `Super + T` tira a janela ativa do modo em mosaico (e volta a pô-la lá). Mas dá primeiro uma oportunidade a sério ao mosaico — é o coração disto tudo. A [Navegação](04-navigation.md) explica-te como funciona.

As áreas de trabalho vão parecer-te familiares: são os Spaces do macOS ou os ambientes de trabalho virtuais do Windows, só que vais usá-las mesmo, porque `Super + 1/2/3/4` salta diretamente para uma e `Super + Shift + 1/2/3/4` envia a janela ativa para lá. Sem atraso de animação, só saltos instantâneos. Isto significa que até podes nem precisar de vários monitores, se era a isso que estavas habituado antes.

### Copiar e colar funciona sem complicações

No Mac tinhas o Cmd + C em todo o lado. No Windows tinhas o Ctrl + C em todo o lado — exceto no terminal, onde mata o programa. O Omarchy dá-te `Super + C`, `Super + X` e `Super + V`, e funcionam em todo o lado, incluindo no terminal. Sem um reflexo separado para aprenderes para a shell.

Para quem vem do Windows: o histórico da área de transferência do Win + V vive no `Super + Ctrl + V`, e guarda imagens além de texto. Ver [área de transferência unificada e histórico](08-unified-clipboard-history.md).

### A tabela de tradução

| Aquilo que procuras | No Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — o menu do Omarchy |
| AirDrop | LocalSend, via `Super + Ctrl + S` — ver [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ou `Print Screen` — ver [capturas de ecrã e gravação](12-screenshots-recording.md) |
| Notification Center | Histórico de notificações em `Super + Shift + Alt + ,` |
| Time Machine (para o sistema) | [snapshots do sistema](47-system-snapshots.md) automáticos em cada atualização |
| App Store / descarregar um instalador | _Install_ no menu, ou `omarchy pkg add` — ver [outros pacotes](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ no menu, que edita ficheiros de configuração simples — ver [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, em `Super + Shift + F` — ver [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome em `Super + Shift + Return`; escolhe outro em _Setup > Defaults > Browser_ — ver [navegadores](23-browsers.md) |
| Preview / Photos | Omaview para fotografias, vídeo e música, Document Viewer para PDFs — ver [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, em `Super + Shift + N`; escolhe outro em _Setup > Defaults > Editor_ |

### Algumas coisas são mesmo diferentes

Muitas definições vivem em ficheiros de texto que editas, não em painéis por onde clicas. Isso soa primitivo até perceberes que significa que cada ajuste pode ser visto, copiado para a tua próxima máquina e colocado sob controlo de versões. O menu _Setup_ deixa-te logo no ficheiro certo e reinicia o que precisar de ser reiniciado quando terminares.

As atualizações chegam através de um único comando — _Update > Omarchy_ — que atualiza o próprio Omarchy e todos os pacotes do sistema, criando primeiro um snapshot. Sem atualizadores por aplicação a chatear-te a horas aleatórias. Ver [atualizações](30-updates.md).

O software vem de um gestor de pacotes, não de instaladores descarregados.

E quando fechas uma janela, a aplicação fecha mesmo. Não há aquele limbo do macOS em que o programa continua a correr sem janelas. `Super + W` — ou `Super + Q`, se foi com essa memória nos dedos que chegaste — significa que desapareceu.

### Em hardware Mac

O Omarchy corre bem em Macs Intel, e em Macs M1, M2 e M3 com o Omarchy for Apple Silicon. Ver [suporte para Mac](44-mac-support.md). E o teclado é simpático contigo: o Omarchy não remapeia nada, e o Linux trata a tecla Command como Super, por isso o Super fica exatamente onde o Cmd sempre esteve. O teu polegar nem vai notar a mudança.

### Dá-lhe duas semanas

Os instintos transferem-se mais depressa do que pensas. Passa os olhos pelo capítulo dos [atalhos](07-hotkeys.md) uma vez, e sempre que te der uma branca com um atalho, carrega em `Super + K` — ele mostra-tos todos. É o único atalho que tens mesmo de memorizar.
