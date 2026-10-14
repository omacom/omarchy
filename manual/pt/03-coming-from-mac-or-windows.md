# Vindo do Mac ou do Windows

Se passaste anos no macOS ou no Windows, os teus dedos sabem uma centena de coisas que o teu cérebro já esqueceu ter aprendido. Este capítulo é a camada de tradução: para onde vão esses instintos no Omarchy. As funcionalidades em si são tratadas em profundidade noutros lugares — isto é apenas o mapa.

### A tecla Super é o centro de tudo

Toda a memória muscular que construíste em torno do Cmd ou da tecla Windows transfere-se para uma única tecla: Super. É a tecla Windows num teclado de PC, e é a âncora de quase todos os atalhos no Omarchy.

O teu reflexo de Spotlight, Raycast ou menu Iniciar passa a ser `Super + Space`. Isso abre o menu do Omarchy, que lança aplicações, muda definições, instala software, captura o ecrã — praticamente tudo. Começa a escrever para filtrar. `Super + Alt + Space` mostra todas as aplicações numa única grelha, como faz o Launchpad. Vê [navegação](04-navigation.md).

### Não há dock nem ícones no ambiente de trabalho

Nada para clicar para lançar coisas, nenhum ícone para organizar no ambiente de trabalho. As aplicações arrancam a partir de um atalho (`Super + Return` para o terminal, `Super + Shift + Return` para o browser e `Super + K` para uma lista de tudo o que está mapeado) ou a partir do menu. A única peça permanente da interface é [a barra superior](05-the-top-bar.md), que cobre aquilo que a barra de menus, a área de notificação e a Central de Notificações faziam por ti antes — e quase todos os widgets nela fazem qualquer coisa com o clique esquerdo, direito e do meio.

### As janelas colocam-se sozinhas

A maior mudança de mentalidade: não arrastas janelas nem as encostas a metades do ecrã. Abres uma janela e ela ocupa o ecrã inteiro. Abres uma segunda e elas dividem-no. Nunca andas à pesca de uma janela debaixo de outra, porque as janelas não se sobrepõem.

Quando precisas mesmo de uma janela flutuante, `Super + T` retira a janela ativa do mosaico (e volta a colocá-la lá). Mas dá primeiro uma oportunidade a sério ao mosaico — é o coração de tudo isto. [Navegação](04-navigation.md) guia-te por ele.

Os espaços de trabalho vão parecer familiares: são os Espaços do macOS ou os ambientes de trabalho virtuais do Windows, exceto que aqui vais mesmo usá-los, porque `Super + 1/2/3/4` salta diretamente para um deles e `Super + Shift + 1/2/3/4` envia para lá a janela ativa. Sem atrasos de animação, só saltos instantâneos. Isto significa que se calhar nem precisas de vários monitores, se era a isso que estavas habituado antes.

### Copiar e colar simplesmente funciona

No Mac tinhas Cmd + C por todo o lado. No Windows tinhas Ctrl + C por todo o lado — exceto no terminal, onde isso mata o teu programa. O Omarchy dá-te `Super + C`, `Super + X` e `Super + V`, e funcionam em todo o lado, incluindo o terminal. Não há um reflexo separado para aprender para a shell.

Malta do Windows: o vosso histórico da área de transferência do Win + V vive no `Super + Ctrl + V`, e guarda imagens além de texto. Vê [área de transferência unificada e histórico](08-unified-clipboard-history.md).

### A tabela de tradução

| Aquilo que procuras | No Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Iniciar | `Super + Space` — o menu do Omarchy |
| AirDrop | LocalSend, com `Super + Ctrl + S` — vê [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — vê [capturas de ecrã e gravação](12-screenshots-recording.md) |
| Central de Notificações | Histórico de notificações em `Super + Shift + Alt + ,` |
| Time Machine (para o sistema) | [Instantâneos do sistema](47-system-snapshots.md) automáticos a cada atualização |
| App Store / transferir um instalador | _Instalar_ no menu, ou `omarchy pkg add` — vê [outros pacotes](29-other-packages.md) |
| Definições do Sistema / Painel de Controlo | _Configurar_ no menu, que edita ficheiros de configuração simples — vê [dotfiles](31-dotfiles.md) |

### Algumas coisas são mesmo diferentes

Muitas definições vivem em ficheiros de texto que editas, não em painéis que percorres com cliques. Isso soa primitivo até perceberes que significa que cada ajuste pode ser visto, copiado para a tua próxima máquina e colocado em controlo de versões. O menu _Configurar_ leva-te diretamente ao ficheiro certo e reinicia o que precisar de ser reiniciado quando terminares.

As atualizações chegam através de um único comando — _Atualizar > Omarchy_ — que atualiza o próprio Omarchy e todos os pacotes do sistema, tirando um instantâneo primeiro. Sem atualizadores por aplicação a chatearem-te ao acaso. Vê [atualizações](30-updates.md).

O software vem de um gestor de pacotes, não de instaladores transferidos.

E quando fechas uma janela, a aplicação termina mesmo. Não há limbo ao estilo do macOS em que o programa continua a correr sem janelas. `Super + W` — ou `Super + Q`, se é essa a memória de dedos com que chegaste — significa desaparecido.

### Em hardware Mac

O Omarchy corre bem em Macs Intel — vê [suporte a Mac](44-mac-support.md). E o teclado trata-te bem: o Omarchy não remapeia nada, e o Linux trata a tecla Command como Super, por isso a tecla Super fica mesmo onde o Cmd sempre esteve. O teu polegar nem vai notar a mudança.

### Dá-lhe duas semanas

Os instintos transferem-se mais depressa do que pensas. Passa os olhos pelo capítulo dos [atalhos](07-hotkeys.md) uma vez, e sempre que te escapar uma combinação, prime `Super + K` — ele mostra-te todas. É esse o único atalho que tens mesmo de memorizar.
