# Vindo do Mac ou do Windows

Se você passou anos no macOS ou no Windows, seus dedos sabem cem coisas que seu cérebro esqueceu que um dia aprendeu. Este capítulo é a camada de tradução: para onde esses instintos vão no Omarchy. Os recursos em si são abordados em profundidade em outras partes — isto aqui é só o mapa.

### Super é o centro de tudo

Toda a memória muscular que você construiu em torno do Cmd ou da tecla do Windows é transferida para uma única tecla: Super. É a tecla do Windows em um teclado de PC, e é a âncora de quase todos os atalhos no Omarchy.

Seu reflexo do Spotlight, do Raycast ou do menu Iniciar vira `Super + Space`. Isso abre o menu do Omarchy, que lança apps, altera configurações, instala software, captura a tela — praticamente tudo. Comece a digitar para filtrar. `Super + Alt + Space` mostra todos os apps em uma única grade, do jeito que o Launchpad faz. Veja [navegação](04-navigation.md).

### Sem ícones na área de trabalho, e o dock só aparece quando você flutua

Sem ícones para organizar na área de trabalho, e sem dock em um workspace em mosaico — o dock só aparece em um workspace flutuante (veja [navegação](04-navigation.md)). Os apps são iniciados por um atalho (`Super + Return` para o terminal, `Super + Shift + Return` para o navegador e `Super + K` para uma lista de tudo o que está mapeado) ou pelo menu. A única parte persistente da interface é [a barra superior](05-the-top-bar.md), que cobre o que a barra de menus, a bandeja do sistema e a Central de Notificações faziam por você antes — e quase todos os widgets nela fazem alguma coisa ao clicar com o botão esquerdo, direito e do meio.

### As janelas se posicionam sozinhas

A maior mudança de mentalidade: você não arrasta janelas por aí nem as encaixa em metades da tela. Abra uma janela e ela ocupa a tela inteira. Abra uma segunda e elas dividem a tela. Você nunca precisa pescar uma janela debaixo de outra, porque as janelas não se sobrepõem.

Quando você realmente precisa de uma janela flutuante, `Super + T` alterna a janela ativa para fora do mosaico (e de volta). Mas dê uma chance de verdade ao mosaico primeiro — ele é o coração de tudo isso. [Navegação](04-navigation.md) explica tudo para você.

Os workspaces vão parecer familiares: são os Spaces do macOS ou as áreas de trabalho virtuais do Windows, exceto que você realmente vai usá-los, porque `Super + 1/2/3/4` salta direto para um deles e `Super + Shift + 1/2/3/4` envia a janela ativa para lá. Sem atraso de animação, apenas saltos instantâneos. Isso significa que você talvez nem precise de vários monitores, se estava acostumado com isso antes.

### Copiar e colar simplesmente funcionam

No Mac, você tinha Cmd + C em todo lugar. No Windows, você tinha Ctrl + C em todo lugar — exceto no terminal, onde ele mata seu programa. O Omarchy oferece `Super + C`, `Super + X` e `Super + V`, e eles funcionam em todo lugar, inclusive no terminal. Nenhum reflexo separado para aprender para o shell.

Pessoal do Windows: seu histórico da área de transferência do Win + V fica em `Super + Ctrl + V`, e ele guarda imagens além de texto. Veja [área de transferência unificada e histórico](08-unified-clipboard-history.md).

### A tabela de tradução

| Você procura | No Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Iniciar | `Super + Space` — o menu do Omarchy |
| AirDrop | LocalSend, via `Super + Ctrl + S` — veja [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ou `Print Screen` — veja [capturas de tela e gravação](12-screenshots-recording.md) |
| Central de Notificações | Histórico de notificações em `Super + Shift + Alt + ,` |
| Time Machine (para o sistema) | [Snapshots do sistema](47-system-snapshots.md) automáticos a cada atualização |
| App Store / baixar um instalador | _Instalar_ no menu, ou `omarchy pkg add` — veja [outros pacotes](29-other-packages.md) |
| Ajustes do Sistema / Painel de Controle | _Configuração_ no menu, que edita arquivos de configuração simples — veja [dotfiles](31-dotfiles.md) |
| Finder / Explorador de Arquivos | Files, em `Super + Shift + F` — veja [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome em `Super + Shift + Return`; escolha outro em _Configuração > Padrões > Navegador_ — veja [navegadores](23-browsers.md) |
| Pré-Visualização / Fotos | Omaview para imagens, vídeo e música, Document Viewer para PDFs — veja [GUIs](22-guis.md) |
| TextEdit / Bloco de Notas | Plain, em `Super + Shift + N`; escolha outro em _Configuração > Padrões > Editor_ |

### Algumas coisas são realmente diferentes

Muitas configurações ficam em arquivos de texto que você edita, não em painéis por onde você clica. Isso parece primitivo até você perceber que significa que cada ajuste pode ser visto, copiado para sua próxima máquina e colocado sob controle de versão. O menu _Configuração_ coloca você direto no arquivo certo e reinicia o que precisar ser reiniciado quando terminar.

As atualizações vêm por um único comando — _Atualizar > Omarchy_ — que atualiza o próprio Omarchy e todos os pacotes do sistema, criando um snapshot antes. Nada de atualizadores por app incomodando você em momentos aleatórios. Veja [atualizações](30-updates.md).

O software vem de um gerenciador de pacotes, não de instaladores baixados.

E quando você fecha uma janela, o app realmente encerra. Não existe aquele limbo do macOS em que o programa continua rodando sem nenhuma janela. `Super + W` — ou `Super + Q`, se foi com essa memória nos dedos que você chegou — significa que ele se foi.

### Em hardware Mac

O Omarchy roda bem em Macs Intel, e em Macs M1, M2 e M3 com o Omarchy para Apple Silicon. Veja [suporte ao Mac](44-mac-support.md). E o teclado é gentil com você: o Omarchy não remapeia nada, e o Linux trata a tecla Command como Super, então o Super fica exatamente onde o Cmd sempre esteve. Seu polegar nem vai notar a mudança.

### Dê duas semanas

Os instintos são transferidos mais rápido do que você imagina. Leia rapidamente o capítulo de [atalhos de teclado](07-hotkeys.md) uma vez e, sempre que der um branco em uma combinação, pressione `Super + K` — ele mostra todas para você. Esse é o único atalho que você realmente precisa memorizar.
