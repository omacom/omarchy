# Vir do Mac ou do Windows

Se passou anos no macOS ou no Windows, os seus dedos sabem cem coisas que o seu cérebro já esqueceu que alguma vez aprendeu. Este capítulo é a camada de tradução: para onde vão esses instintos no Omarchy. As próprias funcionalidades são tratadas em profundidade noutros capítulos — isto é apenas o mapa.

### O Super é o centro de tudo

Toda a memória muscular que construiu à volta do Cmd ou da tecla Windows transfere-se para uma só tecla: Super. É a tecla Windows num teclado de PC e é a âncora de quase todos os atalhos de teclado no Omarchy.

O seu reflexo do Spotlight, do Raycast ou do menu Iniciar passa a ser `Super + Space`. Isso abre o menu do Omarchy, que lança aplicações, altera definições, instala software, captura o ecrã — praticamente tudo. Comece a escrever para filtrar. `Super + Alt + Space` mostra todas as aplicações numa única grelha, como faz o Launchpad. Consulte [navegação](04-navigation.md).

### Sem ícones no ambiente de trabalho, e a dock só aparece em modo flutuante

Não há ícones para organizar no ambiente de trabalho, nem dock num workspace em mosaico — a dock só aparece num workspace flutuante (consulte [navegação](04-navigation.md)). As aplicações arrancam a partir de um atalho de teclado (`Super + Return` para o terminal, `Super + Shift + Return` para o browser e `Super + K` para uma lista de tudo o que está mapeado) ou a partir do menu. O único elemento persistente da interface é [a barra superior](05-the-top-bar.md), que cobre o que a barra de menus, a área de sistema e a Central de Notificações faziam por si antes — e quase todos os widgets nela fazem alguma coisa com o clique esquerdo, direito e do meio.

### As janelas posicionam-se sozinhas

A maior mudança de mentalidade: não arrasta janelas de um lado para o outro nem as encaixa em metades do ecrã. Abra uma janela e ela ocupa o ecrã inteiro. Abra uma segunda e elas dividem-no. Nunca tem de andar a pescar uma janela debaixo de outra, porque as janelas não se sobrepõem.

Quando precisa mesmo de uma janela flutuante, `Super + T` retira a janela ativa do mosaico (e volta a colocá-la lá). Mas primeiro dê uma oportunidade a sério ao mosaico — é o coração de tudo isto. [Navegação](04-navigation.md) guia-o ao longo de tudo.

Os workspaces vão parecer-lhe familiares: são os Spaces do macOS ou os ambientes de trabalho virtuais do Windows, exceto que vai mesmo utilizá-los, porque `Super + 1/2/3/4` salta diretamente para um deles e `Super + Shift + 1/2/3/4` envia a janela ativa para lá. Sem atrasos de animação, apenas saltos instantâneos. Isto significa que pode até nem precisar de vários monitores, se estava habituado a isso antes.

### Copiar e colar simplesmente funciona

No Mac tinha Cmd + C em todo o lado. No Windows tinha Ctrl + C em todo o lado — exceto no terminal, onde isso mata o programa. O Omarchy dá-lhe `Super + C`, `Super + X` e `Super + V`, e funcionam em todo o lado, incluindo no terminal. Não há nenhum reflexo separado para aprender para a shell.

Pessoal do Windows: o vosso histórico da área de transferência do Win + V está no `Super + Ctrl + V` e guarda imagens, além de texto. Consulte [área de transferência unificada e histórico](08-unified-clipboard-history.md).

### A tabela de tradução

| O que procura usar | No Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Iniciar | `Super + Space` — o menu do Omarchy |
| AirDrop | LocalSend, através de `Super + Ctrl + S` — consulte [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ou `Print Screen` — consulte [capturas de ecrã e gravação](12-screenshots-recording.md) |
| Central de Notificações | Histórico de notificações em `Super + Shift + Alt + ,` |
| Time Machine (para o sistema) | [Snapshots do sistema](47-system-snapshots.md) automáticos a cada atualização |
| App Store / descarregar um instalador | _Install_ no menu ou `omarchy pkg add` — consulte [outros pacotes](29-other-packages.md) |
| Definições do Sistema / Painel de Controlo | _Setup_ no menu, que edita ficheiros de configuração simples — consulte [dotfiles](31-dotfiles.md) |
| Finder / Explorador de Ficheiros | Files, em `Super + Shift + F` — consulte [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome em `Super + Shift + Return`; escolha outro em _Setup > Defaults > Browser_ — consulte [navegadores](23-browsers.md) |
| Pré-visualização / Fotografias | Omaview para imagens, vídeo e música, Document Viewer para PDFs — consulte [GUIs](22-guis.md) |
| TextEdit / Bloco de Notas | Plain, em `Super + Shift + N`; escolha outro em _Setup > Defaults > Editor_ |

### Algumas coisas são mesmo diferentes

Muitas definições vivem em ficheiros de texto que edita, e não em painéis onde clica de um lado para o outro. Isso parece primitivo até perceber que significa que cada ajuste pode ser visto, copiado para a sua próxima máquina e colocado em controlo de versões. O menu _Setup_ leva-o diretamente ao ficheiro certo e reinicia o que precisar de ser reiniciado quando terminar.

As atualizações chegam através de um único comando — _Update > Omarchy_ — que atualiza o próprio Omarchy e todos os pacotes do sistema, criando primeiro um snapshot. Nada de atualizadores por aplicação a chateá-lo ao acaso. Consulte [atualizações](30-updates.md).

O software vem de um gestor de pacotes, e não de instaladores descarregados.

E quando fecha uma janela, a aplicação fecha mesmo. Não há nenhum limbo do macOS em que o programa continua a correr sem janelas. `Super + W` — ou `Super + Q`, se foi essa a memória dos dedos com que chegou — significa que desapareceu.

### Em hardware Mac

O Omarchy corre bem em Macs Intel — consulte [suporte para Mac](44-mac-support.md). E o teclado é simpático consigo: o Omarchy não remapeia nada e o Linux trata a tecla Command como Super, por isso o Super fica exatamente onde o Cmd sempre esteve. O seu polegar nem vai notar a mudança.

### Dê-lhe duas semanas

Os instintos transferem-se mais depressa do que imagina. Leia na diagonal o capítulo [atalhos de teclado](07-hotkeys.md) uma vez e, sempre que tiver uma branca sobre uma combinação, carregue em `Super + K` — ele mostra-lhe todas. É o único atalho de teclado que tem mesmo de memorizar.
