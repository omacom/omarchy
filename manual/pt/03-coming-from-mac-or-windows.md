# Vindo do Mac ou do Windows

Se passaste anos no macOS ou no Windows, os teus dedos sabem cem coisas que o teu cérebro já se esqueceu de ter aprendido. Este capítulo é a camada de tradução: para onde vão esses instintos no Omarchy. As funcionalidades em si são tratadas em profundidade noutros capítulos — isto é só o mapa.

### O Super é o centro de tudo

Toda a memória muscular que construíste em torno do Cmd ou da tecla Windows transfere-se para uma só tecla: Super. É a tecla Windows num teclado de PC e é a âncora de quase todos os atalhos de teclado no Omarchy.

O teu reflexo de Spotlight ou Raycast ou Start menu passa a ser `Super + Space`. Isso abre o menu do Omarchy, que lança aplicações, altera definições, instala software, captura o ecrã — praticamente tudo. Começa a escrever para filtrar. `Super + Alt + Space` mostra todas as aplicações numa única grelha, como faz o Launchpad. Consulta [navegação](04-navigation.md).

### Sem ícones no ambiente de trabalho, e a dock fica fora do caminho

Não há ícones para arrumar no ambiente de trabalho, e a dock esconde-se assim que um espaço de trabalho tem uma janela, até empurrares o ponteiro para o bordo do ecrã do lado dela — o da direita, a menos que a movas (consulta [navegação](04-navigation.md)). As aplicações arrancam a partir de um atalho de teclado (`Super + Return` para o terminal, `Super + Shift + Return` para o navegador, e `Super + K` para uma lista de tudo o que está mapeado) ou a partir do menu. O único elemento persistente da interface é [a barra superior](05-the-top-bar.md), que cobre o que a barra de menus, a área de notificação do sistema e o Notification Center faziam por ti antes — e quase todos os widgets nela fazem alguma coisa com o clique esquerdo, direito e do meio.

### As janelas posicionam-se sozinhas

A maior mudança de mentalidade: não arrastas as janelas nem as encaixas em metades do ecrã. Abres uma janela e ela ocupa o ecrã inteiro. Abres uma segunda e elas dividem-no. Nunca andas a pescar uma janela debaixo de outra, porque as janelas não se sobrepõem.

Quando precisas mesmo de uma janela flutuante, `Super + T` tira a janela ativa do modo em mosaico (e volta a colocá-la lá). Mas dá primeiro uma oportunidade a sério ao mosaico — é o coração de tudo isto. [Navegação](04-navigation.md) explica-te como funciona.

Os espaços de trabalho vão parecer-te familiares: são os Spaces do macOS ou os ambientes de trabalho virtuais do Windows, só que vais mesmo usá-los, porque `Super + 1/2/3/4` salta diretamente para um e `Super + Shift + 1/2/3/4` envia a janela ativa para lá. Sem atraso de animação, apenas saltos instantâneos. Isto significa que até podes nem precisar de vários monitores, se era a isso que estavas habituado antes.

### Copiar e colar simplesmente funcionam

No Mac tinhas Cmd + C em todo o lado. No Windows tinhas Ctrl + C em todo o lado — exceto no terminal, onde mata o teu programa. O Omarchy dá-te `Super + C`, `Super + X` e `Super + V`, e funcionam em todo o lado, incluindo no terminal. Não há nenhum reflexo separado para aprenderes para a shell.

Pessoal do Windows: o teu histórico da área de transferência do Win + V vive em `Super + Ctrl + V`, e guarda imagens além de texto. Consulta [área de transferência unificada & histórico](08-unified-clipboard-history.md).

### A tabela de tradução

| Aquilo a que recorres | No Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — o menu do Omarchy |
| AirDrop | LocalSend, através de `Super + Ctrl + S` — consulta [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ou `Print Screen` — consulta [capturas de ecrã e gravação](12-screenshots-recording.md) |
| Notification Center | Histórico de notificações em `Super + Shift + Alt + ,` |
| Time Machine (para o sistema) | [Instantâneos do sistema](47-system-snapshots.md) automáticos em cada atualização |
| App Store / descarregar um instalador | _Install_ no menu, ou `omarchy pkg add` — consulta [outros pacotes](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ no menu, que edita ficheiros de configuração simples — consulta [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, em `Super + Shift + F` — consulta [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome em `Super + Shift + Return`; escolhe outro em _Setup > Defaults > Browser_ — consulta [navegadores](23-browsers.md) |
| Preview / Photos | Omaview para imagens, vídeo e música, Document Viewer para PDFs — consulta [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, em `Super + Shift + N`; escolhe outro em _Setup > Defaults > Editor_ |

### Algumas coisas são mesmo diferentes

Muitas definições vivem em ficheiros de texto que editas, não em painéis por onde vais clicando. Soa a primitivo até perceberes que isso significa que cada ajuste pode ser visto, copiado para a tua próxima máquina e colocado sob controlo de versões. O menu _Setup_ deixa-te logo no ficheiro certo e reinicia tudo o que precisar de ser reiniciado quando acabares.

As atualizações chegam através de um único comando — _Update > Omarchy_ — que atualiza o próprio Omarchy e todos os pacotes do sistema, criando primeiro um instantâneo. Sem atualizadores de cada aplicação a chatear-te a horas aleatórias. Consulta [atualizações](30-updates.md).

O software vem de um gestor de pacotes, não de instaladores descarregados.

E quando fechas uma janela, a aplicação fecha mesmo. Não há aquele limbo do macOS em que o programa continua a correr sem janelas. `Super + W` — ou `Super + Q`, se é essa a memória dos teus dedos com que chegaste — significa que desapareceu.

### Em hardware Mac

O Omarchy corre bem em Macs Intel e em Macs M1, M2 e M3 com o Omarchy for Apple Silicon. Consulta [suporte para Mac](44-mac-support.md). E o teclado é simpático contigo: o Omarchy não remapeia nada, e o Linux trata a tecla Command como Super, por isso o Super fica exatamente onde o Cmd sempre esteve. O teu polegar nem vai notar a mudança.

### Dá-lhe duas semanas

Os instintos transferem-se mais depressa do que imaginas. Passa os olhos uma vez pelo capítulo [atalhos de teclado](07-hotkeys.md), e sempre que te der uma branca com um atalho, carrega em `Super + K` — ele mostra-te todos. É o único atalho que tens mesmo de memorizar.
