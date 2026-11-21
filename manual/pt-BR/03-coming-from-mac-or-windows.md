# Vindo do Mac ou do Windows

Se você passou anos no macOS ou no Windows, seus dedos sabem cem coisas que seu cérebro esqueceu que aprendeu. Este capítulo é a camada de tradução: para onde esses instintos vão no Omarchy. As funcionalidades em si são tratadas em detalhes em outros lugares — isto aqui é só o mapa.

### Super é o centro de tudo

Toda a memória muscular que você construiu em torno do Cmd ou da tecla Windows se transfere para uma única tecla: Super. É a tecla Windows em um teclado de PC, e é a âncora de quase todos os atalhos do Omarchy.

Seu reflexo de Spotlight, Raycast ou menu Iniciar vira `Super + Space`. Isso abre o menu do Omarchy, que lança aplicativos, muda configurações, instala software, captura a tela — praticamente tudo. Comece a digitar para filtrar. `Super + Alt + Space` mostra todos os aplicativos em uma única grade, do jeito que o Launchpad faz. Veja [navegação](04-navigation.md).

### Sem ícones na área de trabalho, e o dock só aparece quando você flutua

Sem ícones para organizar na área de trabalho, e sem dock em um workspace em mosaico — o dock só aparece em um workspace flutuante (veja [navegação](04-navigation.md)). Os aplicativos começam por um atalho (`Super + Return` para o terminal, `Super + Shift + Return` para o navegador, e `Super + K` para uma lista de tudo o que está mapeado) ou pelo menu. A única parte persistente da interface é [a barra superior](05-the-top-bar.md), que cobre o que a barra de menus, a bandeja do sistema e a Central de Notificações faziam por você antes — e quase todos os widgets nela fazem alguma coisa com clique esquerdo, direito e do meio.

### As janelas se posicionam sozinhas

A maior mudança de mentalidade: você não arrasta janelas por aí nem as encaixa em metades da tela. Abra uma janela e ela ocupa a tela inteira. Abra uma segunda e elas dividem a tela. Você nunca precisa pescar uma janela debaixo de outra, porque as janelas não se sobrepõem.

Quando você realmente precisa de uma janela flutuante, `Super + T` tira a janela ativa do mosaico (e a coloca de volta). Mas dê uma chance de verdade ao mosaico primeiro — ele é o coração de tudo. [Navegação](04-navigation.md) guia você por isso.

Os workspaces vão parecer familiares: são os Spaces do macOS ou as áreas de trabalho virtuais do Windows, só que você vai realmente usá-los, porque `Super + 1/2/3/4` pula direto para um deles e `Super + Shift + 1/2/3/4` envia a janela ativa para lá. Sem atraso de animação, só saltos instantâneos. Isso significa que você pode nem precisar de vários monitores, se era a isso que você estava acostumado antes.

### Copiar e colar simplesmente funcionam

No Mac, você tinha Cmd + C em todo lugar. No Windows, você tinha Ctrl + C em todo lugar — exceto no terminal, onde isso mata o seu programa. O Omarchy oferece `Super + C`, `Super + X` e `Super + V`, e eles funcionam em todo lugar, inclusive no terminal. Nenhum reflexo separado para aprender para o shell.

Pessoal do Windows: seu histórico da área de transferência do Win + V vive em `Super + Ctrl + V`, e ele guarda imagens além de texto. Veja [área de transferência unificada e histórico](08-unified-clipboard-history.md).

### A tabela de tradução

| O que você procura | No Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Iniciar | `Super + Space` — o menu do Omarchy |
| AirDrop | LocalSend, via `Super + Ctrl + S` — veja [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ou `Print Screen` — veja [capturas de tela e gravação](12-screenshots-recording.md) |
| Central de Notificações | Histórico de notificações em `Super + Shift + Alt + ,` |
| Time Machine (para o sistema) | [snapshots do sistema](47-system-snapshots.md) automáticos a cada atualização |
| App Store / baixar um instalador | _Install_ no menu, ou `omarchy pkg add` — veja [outros pacotes](29-other-packages.md) |
| Ajustes do Sistema / Painel de Controle | _Setup_ no menu, que edita arquivos de configuração simples — veja [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, em `Super + Shift + F` — veja [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome em `Super + Shift + Return`; escolha outro em _Setup > Defaults > Browser_ — veja [navegadores](23-browsers.md) |
| Pré-Visualização / Fotos | Omaview para fotos, vídeo e música, Document Viewer para PDFs — veja [GUIs](22-guis.md) |
| TextEdit / Bloco de Notas | Plain, em `Super + Shift + N`; escolha outro em _Setup > Defaults > Editor_ |

### Algumas coisas são realmente diferentes

Muitas configurações moram em arquivos de texto que você edita, não em painéis pelos quais você clica. Isso soa primitivo até você perceber que significa que cada ajuste pode ser visto, copiado para sua próxima máquina e colocado sob controle de versão. O menu _Setup_ coloca você direto no arquivo certo e reinicia o que precisa ser reiniciado quando você termina.

As atualizações vêm por um único comando — _Update > Omarchy_ — que atualiza o próprio Omarchy e todos os pacotes do sistema, criando um snapshot antes. Sem atualizadores de cada aplicativo importunando você em momentos aleatórios. Veja [atualizações](30-updates.md).

O software vem de um gerenciador de pacotes, não de instaladores baixados.

E quando você fecha uma janela, o aplicativo realmente encerra. Não existe aquele limbo do macOS em que o programa continua rodando sem nenhuma janela. `Super + W` — ou `Super + Q`, se essa é a memória dos dedos com a qual você chegou — significa fechado de vez.

### Em hardware Mac

O Omarchy roda bem em Macs Intel — veja [suporte a Mac](44-mac-support.md). E o teclado é gentil com você: o Omarchy não remapeia nada, e o Linux trata a tecla Command como Super, então o Super fica bem onde o Cmd sempre esteve. Seu polegar nem vai notar a mudança.

### Dê duas semanas

Os instintos se transferem mais rápido do que você imagina. Dê uma olhada rápida no capítulo de [atalhos](07-hotkeys.md) uma vez, e sempre que der um branco em um atalho, aperte `Super + K` — ele mostra todos eles. Esse é o único atalho que você realmente precisa memorizar.
