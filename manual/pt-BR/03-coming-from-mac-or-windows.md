# Vindo do Mac ou do Windows

Se você passou anos no macOS ou no Windows, seus dedos sabem cem coisas que seu cérebro esqueceu que um dia aprendeu. Este capítulo é a camada de tradução: para onde vão esses instintos no Omarchy. Os recursos em si são abordados em profundidade em outros lugares — este é apenas o mapa.

### Super é o centro de tudo

Toda a memória muscular que você construiu em torno do Cmd ou da tecla Windows se transfere para uma única tecla: Super. É a tecla Windows em um teclado de PC, e ela é a âncora de quase todos os atalhos de teclado no Omarchy.

Seu reflexo de Spotlight ou Raycast ou menu Iniciar se torna `Super + Space`. Isso abre o menu do Omarchy, que inicia apps, altera configurações, instala software, captura a tela — praticamente tudo. Comece a digitar para filtrar. `Super + Alt + Space` mostra todos os apps em uma única grade, do jeito que o Launchpad faz. Veja [navegação](04-navigation.md).

### Não há dock nem ícones na área de trabalho

Nada para clicar para iniciar as coisas, nenhum ícone para organizar na área de trabalho. Os apps são iniciados por um atalho de teclado (`Super + Return` para o terminal, `Super + Shift + Return` para o navegador e `Super + K` para uma lista de tudo o que está mapeado) ou pelo menu. O único elemento persistente da interface é [a barra superior](05-the-top-bar.md), que cobre o que a barra de menus, a bandeja do sistema e a Central de Notificações faziam por você antes — e quase todos os widgets nela fazem algo com o clique esquerdo, direito e do meio.

### As janelas se posicionam sozinhas

A maior mudança de mentalidade: você não arrasta janelas por aí nem as encaixa em metades da tela. Abra uma janela e ela ocupa a tela inteira. Abra uma segunda e elas dividem a tela. Você nunca precisa pescar uma janela debaixo de outra, porque as janelas não se sobrepõem.

Quando você realmente precisa de uma janela flutuante, `Super + T` retira a janela ativa do tiling (e a coloca de volta). Mas dê uma chance de verdade ao tiling primeiro — ele é o coração de tudo. [Navegação](04-navigation.md) explica tudo para você.

Os workspaces serão familiares: eles são os Spaces do macOS ou as áreas de trabalho virtuais do Windows, exceto que você realmente vai usá-los, porque `Super + 1/2/3/4` pula direto para um e `Super + Shift + 1/2/3/4` envia a janela ativa para lá. Sem atraso de animação, apenas saltos instantâneos. Isso significa que você talvez nem precise de vários monitores, se era a isso que você estava acostumado antes.

### Copiar e colar simplesmente funcionam

No Mac, você tinha Cmd + C em todos os lugares. No Windows, você tinha Ctrl + C em todos os lugares — exceto no terminal, onde ele mata o seu programa. O Omarchy oferece `Super + C`, `Super + X` e `Super + V`, e eles funcionam em todos os lugares, inclusive no terminal. Nenhum reflexo separado para aprender para o shell.

Pessoal do Windows: o histórico da área de transferência do seu Win + V mora em `Super + Ctrl + V`, e ele guarda imagens além de texto. Veja [área de transferência unificada e histórico](08-unified-clipboard-history.md).

### A tabela de tradução

| Você procura por | No Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Iniciar | `Super + Space` — o menu do Omarchy |
| AirDrop | LocalSend, via `Super + Ctrl + S` — veja [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ou `Print Screen` — veja [capturas de tela e gravação](12-screenshots-recording.md) |
| Central de Notificações | Histórico de notificações em `Super + Shift + Alt + ,` |
| Time Machine (para o sistema) | [snapshots do sistema](47-system-snapshots.md) automáticos a cada atualização |
| App Store / baixar um instalador | _Instalar_ no menu, ou `omarchy pkg add` — veja [outros pacotes](29-other-packages.md) |
| Configurações do Sistema / Painel de Controle | _Configuração_ no menu, que edita arquivos de configuração simples — veja [dotfiles](31-dotfiles.md) |

### Algumas coisas são realmente diferentes

Muitas configurações vivem em arquivos de texto que você edita, não em painéis pelos quais você clica. Isso parece primitivo até você perceber que significa que cada ajuste pode ser visto, copiado para a sua próxima máquina e colocado em controle de versão. O menu _Configuração_ coloca você direto no arquivo certo e reinicia o que precisar ser reiniciado quando você terminar.

As atualizações vêm por um único comando — _Atualizar > Omarchy_ — que atualiza o próprio Omarchy e todos os pacotes do sistema, criando um snapshot antes. Nada de atualizadores de cada aplicativo incomodando você em momentos aleatórios. Veja [atualizações](30-updates.md).

O software vem de um gerenciador de pacotes, não de instaladores baixados.

E, quando você fecha uma janela, o aplicativo realmente encerra. Não existe aquele limbo do macOS em que o programa continua rodando sem nenhuma janela. `Super + W` — ou `Super + Q`, se foi com essa memória nos dedos que você chegou — significa que acabou.

### Em hardware Mac

O Omarchy roda bem em Macs Intel — veja [suporte ao Mac](44-mac-support.md). E o teclado é gentil com você: o Omarchy não remapeia nada, e o Linux trata a tecla Command como Super, então Super fica exatamente onde o Cmd sempre esteve. Seu polegar nem vai notar a mudança.

### Dê duas semanas

Os instintos se transferem mais rápido do que você imagina. Dê uma olhada no capítulo de [atalhos de teclado](07-hotkeys.md) uma vez e, sempre que der um branco em um atalho, aperte `Super + K` — ele mostra todos eles para você. Esse é o único atalho que você realmente precisa memorizar.
