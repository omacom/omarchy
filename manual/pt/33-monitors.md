# Monitores

O Omarchy assume, por predefinição, que está a usar um ecrã de classe retina com capacidade 2x. É disso que precisa para obter aqueles tipos de letra de programador bonitos e nítidos. É para isso que estão otimizados quase todos os novos computadores portáteis premium com ecrãs de alta resolução. É o que vai querer usar num [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) de 27" 5K ou num [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) de 32" 6K.

Mas se não estiver a usar um ecrã com um PPI de 218 ou superior, vai querer alterar as definições do monitor. Por exemplo, se tiver um 4K de 27" ou 32", pode usar o escalonamento fracionário ao abrir `~/.config/hypr/monitors.lua` (através de _Configuração > Monitores_ no menu do Omarchy) e ao mudar para a recomendação para essa combinação:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Se estiver a usar um ecrã de 1080p ou 1440p, provavelmente vai querer apenas usar o escalonamento 1x, por isso pode usar:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

As alterações ao `GDK_SCALE` aplicam-se às aplicações iniciadas depois da alteração (e o GTK só aceita números inteiros, por isso mantenha-o no inteiro mais próximo da escala do seu monitor). Por isso, certifique-se de que fecha as janelas sobredimensionadas que tiver depois da alteração (ou feche todas as janelas com `Ctrl + Alt + Del`!).

Também pode percorrer rapidamente as principais proporções de escalonamento do monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) com `Super + /` para aumentar e `Super + Alt + /` para diminuir, ou escolher uma no painel do monitor na barra superior. Estas alteram apenas o monitor em que está focado, por isso um ecrã de portátil e um ecrã externo podem ter cada um a sua própria escala. A escolha é guardada em `~/.config/hypr/monitors.lua` como uma regra `hl.monitor` para esse monitor, por isso persiste após o reinício e tem precedência sobre `omarchy_monitor_scale`, que continua a ser a escala para todos os monitores sem uma regra própria.

### Tornar o texto maior ou menor

O escalonamento do monitor altera o tamanho de tudo. Se tudo o que quer é texto maior ou menor, há um único ajuste para isso:

```
omarchy display text size 14
```

Isso aceita um tamanho em píxeis entre 9 e 20 e ajusta a shell do Omarchy, as aplicações GTK e o seu terminal em conjunto, para que todo o ambiente de trabalho se mantenha proporcional. Execute-o sem argumento para ver em que ponto está, e `omarchy display text size reset` para voltar à predefinição. O Foot é o único retardatário: não tem forma de recarregar a sua configuração, por isso os terminais em execução mantêm o tamanho antigo até abrir um novo.

### Estender e espelhar ecrãs de portátil

Quando liga um ecrã externo ao seu portátil, o ecrã é automaticamente estendido. Mas pode alterar isso para espelhamento, em vez disso, através de _Acionador > Hardware_ no menu do Omarchy ou de `Super + Ctrl + Alt + Delete`. Isto é especialmente útil se esse ecrã externo for um projetor e quiser mostrar algo enquanto trabalha.

Quando está a estender, fechar a tampa do portátil desliga automaticamente o ecrã interno. Abrir a tampa volta a ligá-lo. Também pode controlar isto manualmente através de _Acionador > Hardware_ no menu do Omarchy ou de `Super + Ctrl + Delete`.

### Organizar vários ecrãs

O Hyprland funciona muito bem com vários ecrãs. Leia mais sobre como os organizar na [documentação de monitores do Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). No Omarchy, estes vão para `~/.config/hypr/monitors.lua` como entradas `hl.monitor` — o ficheiro vem com exemplos comentados para fixar um monitor específico numa resolução, posição e rotação.

Cada monitor tem os seus próprios espaços de trabalho 1 a 10, por isso `Super + 1` significa sempre o primeiro espaço de trabalho do monitor em que está. Nos bastidores, o Hyprland continua a numerar os espaços de trabalho em todos os monitores: o ecrã do seu portátil (ou o primeiro monitor) fica com 1–10, o monitor seguinte com 11–20, e assim sucessivamente, e cada monitor mantém o seu bloco sempre que o liga. Use esses números se escrever [regras de espaços de trabalho](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ou regras de janelas para um monitor específico, para que o espaço de trabalho 12 seja o segundo espaço de trabalho do seu segundo monitor. `~/.local/state/omarchy/monitor-workspaces` lista que bloco cada monitor tem.

As teclas de seta funcionam entre monitores que partilham uma aresta na sua disposição. Ecrãs que só se tocam num canto, ou que têm um espaço entre si, não são vizinhos, por isso use `Ctrl + Alt + Tab` para passar entre eles.

| Tecla de atalho | Entre monitores |
| --- | --- |
| `Super + Arrow` | Move o foco para o monitor desse lado assim que já não houver nenhuma janela nessa direção |
| `Super + Shift + Arrow` | Troca com uma janela no monitor desse lado |
| `Super + Alt + Arrow` | Move a janela para um grupo no monitor desse lado |
| `Super + Shift + Ctrl + Arrow` | Move a janela para o monitor desse lado, para o espaço de trabalho que este está a mostrar |
| `Super + Shift + Alt + Arrow` | Move o espaço de trabalho para o monitor desse lado, a manter o seu número se estiver livre |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Move o foco para o monitor seguinte ou anterior, qualquer que seja a disposição |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Permanecem no monitor em que está |

Também pode ver o [Hyprmon](https://github.com/erans/hyprmon/), se quiser uma TUI para o ajudar com o posicionamento de vários ecrãs.

### Controlar o brilho

O brilho do monitor é controlado pelas teclas de função dedicadas para aumentar/diminuir o brilho. Se mantiver premido Shift enquanto prime estas teclas, vai para o brilho máximo ou mínimo. As teclas controlam o ecrã em que está focado, por isso os monitores externos que falam DDC/CI são ajustados da mesma forma que o ecrã do portátil.

### Ecrãs Apple

Se estiver a usar um ecrã Apple, as teclas normais de brilho do teclado também funcionam automaticamente, se estiver focado no ecrã Apple. Isto é feito através do comando `asdcontrol`.

Note que, se estiver a usar um ecrã Apple 6K XDR, pode ver um ecrã fantasma na sua listagem de `hyprctl monitors`. Pode desligar isto com algo como `hl.monitor({ output = "DP-2", disabled = true })` através de _Configuração > Monitores_.

Nas máquinas Intel, deve ligar-se aos ecrãs Apple com um cabo Thunderbolt normal. Noutras máquinas sem Thunderbolt, normalmente terá de usar um [cabo DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) para que funcione.
