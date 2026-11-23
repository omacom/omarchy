# Quem vem do Mac ou do Windows

Se passou anos no macOS ou no Windows, os seus dedos sabem cem coisas que o cérebro já esqueceu que aprendeu. Este capítulo é a camada de tradução: para onde vão esses instintos no Omarchy. As funcionalidades em si estão explicadas em profundidade noutras secções — isto é apenas o mapa.

### A Super é o centro de tudo

Toda a memória muscular que desenvolveu à volta da tecla Cmd ou da tecla Windows transfere-se para uma única tecla: Super. É a tecla Windows num teclado de PC, e é a âncora de quase todos os atalhos de teclado no Omarchy.

O seu reflexo de Spotlight ou Raycast ou menu Iniciar passa a ser `Super + Space`. Isso abre o menu Omarchy, que lança aplicações, altera definições, instala software, captura o ecrã — praticamente tudo. Comece a escrever para filtrar. `Super + Alt + Space` mostra todas as aplicações numa única grelha, como faz o Launchpad. Consulte [navegação](04-navigation.md).

### Sem ícones no ambiente de trabalho, e o dock só aparece quando passa para flutuante

Sem ícones para organizar no ambiente de trabalho, e sem dock numa área de trabalho em mosaico — o dock só aparece numa área de trabalho flutuante (consulte [navegação](04-navigation.md)). As aplicações arrancam a partir de um atalho de teclado (`Super + Return` para o terminal, `Super + Shift + Return` para o navegador e `Super + K` para uma lista de tudo o que está mapeado) ou a partir do menu. O único elemento persistente da interface é [a barra superior](05-the-top-bar.md), que assume o que a barra de menus, a área de notificação do sistema e o Notification Center faziam por si antes — e quase todos os widgets nela fazem alguma coisa com o clique esquerdo, direito e do meio.

### As janelas posicionam-se sozinhas

A maior mudança de mentalidade: não anda a arrastar janelas nem a encaixá-las em metades do ecrã. Abra uma janela e ela ocupa o ecrã inteiro. Abra uma segunda e elas dividem o espaço. Nunca tem de andar a pescar uma janela por baixo de outra, porque as janelas não se sobrepõem.

Quando precisa mesmo de uma janela flutuante, `Super + T` retira a janela ativa do mosaico (e volta a colocá-la lá). Mas dê primeiro uma oportunidade a sério ao mosaico — é o coração de tudo isto. A [Navegação](04-navigation.md) guia-o ao longo do processo.

As áreas de trabalho vão parecer familiares: são os Spaces do macOS ou os ambientes de trabalho virtuais do Windows, exceto que aqui vai mesmo usá-las, porque `Super + 1/2/3/4` salta diretamente para uma e `Super + Shift + 1/2/3/4` envia a janela ativa para lá. Sem atrasos de animação, só saltos instantâneos. Isto significa que pode até nem precisar de vários monitores, se era a isso que estava habituado antes.

### Copiar e colar simplesmente funcionam

No Mac tinha Cmd + C em todo o lado. No Windows tinha Ctrl + C em todo o lado — exceto no terminal, onde isso mata o programa. O Omarchy dá-lhe `Super + C`, `Super + X` e `Super + V`, e funcionam em todo o lado, incluindo o terminal. Sem nenhum reflexo separado para aprender para a shell.

Para quem vem do Windows: o seu histórico da área de transferência do Win + V está em `Super + Ctrl + V`, e guarda imagens além de texto. Consulte [área de transferência unificada e histórico](08-unified-clipboard-history.md).

### A tabela de tradução

| O que procura | No Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Iniciar | `Super + Space` — o menu Omarchy |
| AirDrop | LocalSend, através de `Super + Ctrl + S` — consulte [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ou `Print Screen` — consulte [capturas de ecrã e gravação](12-screenshots-recording.md) |
| Centro de Notificações | Histórico de notificações em `Super + Shift + Alt + ,` |
| Time Machine (para o sistema) | [Instantâneos do sistema](47-system-snapshots.md) automáticos em cada atualização |
| App Store / descarregar um instalador | _Install_ no menu, ou `omarchy pkg add` — consulte [outros pacotes](29-other-packages.md) |
| Definições do Sistema / Painel de Controlo | _Setup_ no menu, que edita ficheiros de configuração simples — consulte [dotfiles](31-dotfiles.md) |
| Finder / Explorador de Ficheiros | Files, em `Super + Shift + F` — consulte [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome em `Super + Shift + Return`; escolha outro em _Setup > Defaults > Browser_ — consulte [navegadores](23-browsers.md) |
| Pré-visualização / Fotos | Omaview para imagens, vídeo e música, Document Viewer para PDFs — consulte [GUIs](22-guis.md) |
| TextEdit / Bloco de Notas | Plain, em `Super + Shift + N`; escolha outro em _Setup > Defaults > Editor_ |

### Algumas coisas são mesmo diferentes

Muitas definições vivem em ficheiros de texto que edita, não em painéis por onde clica. Parece primitivo, até perceber que isso significa que cada ajuste pode ser visto, copiado para a sua próxima máquina e colocado em controlo de versões. O menu _Setup_ coloca-o diretamente no ficheiro certo e reinicia o que precisar de ser reiniciado quando terminar.

As atualizações chegam através de um único comando — _Update > Omarchy_ — que atualiza o próprio Omarchy e todos os pacotes do sistema, criando primeiro um instantâneo. Sem atualizadores aplicação a aplicação a chateá-lo a qualquer momento. Consulte [atualizações](30-updates.md).

O software vem de um gestor de pacotes, não de instaladores descarregados.

E quando fecha uma janela, a aplicação fecha mesmo. Não há aquele limbo do macOS em que o programa continua a correr sem nenhuma janela. `Super + W` — ou `Super + Q`, se foi com essa memória nos dedos que chegou — significa fechado.

### Em hardware Mac

O Omarchy corre bem em Macs Intel e em Macs M1, M2 e M3 com o Omarchy for Apple Silicon. Consulte [suporte para Mac](44-mac-support.md). E o teclado é simpático consigo: o Omarchy não remapeia nada, e o Linux trata a tecla Command como Super, por isso a Super fica exatamente onde a Cmd sempre esteve. O seu polegar nem vai notar a mudança.

### Dê-lhe duas semanas

Os instintos transferem-se mais depressa do que imagina. Leia na diagonal o capítulo [atalhos de teclado](07-hotkeys.md) uma vez, e sempre que lhe der uma branca sobre uma combinação, prima `Super + K` — mostra-lhe todas. É o único atalho que tem mesmo de memorizar.
