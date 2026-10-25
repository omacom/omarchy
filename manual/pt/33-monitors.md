# Monitores

O Omarchy assume, por predefinição, que está a utilizar um ecrã de classe retina com capacidade 2x. É disso que precisa para obter aqueles tipos de letra de programação agradáveis e nítidos. É aquilo para que quase todos os novos portáteis premium com ecrãs de alta resolução estão otimizados. É o que vai querer utilizar num [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) de 27" e 5K ou num [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) de 32" e 6K.

Mas, se não estiver a utilizar um ecrã com um PPI de 218 ou superior, vai querer alterar as definições do monitor. Por exemplo, se tiver um ecrã 4K de 27" ou 32", pode utilizar o escalonamento fracionário abrindo `~/.config/hypr/monitors.lua` (através de _Setup > Monitors_ no menu do Omarchy) e mudando para a recomendação para essa combinação:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Se estiver a utilizar um ecrã de 1080p ou 1440p, provavelmente vai querer apenas utilizar o escalonamento 1x, pelo que pode utilizar:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

As alterações ao `GDK_SCALE` aplicam-se às aplicações iniciadas depois da alteração (e o GTK só aceita números inteiros, pelo que deve mantê-lo no inteiro mais próximo da escala do seu monitor). Por isso, certifique-se de que fecha as janelas que tiver sobredimensionadas depois da alteração (ou feche todas as janelas com `Ctrl + Alt + Del`!).

Também pode percorrer rapidamente os principais rácios de escalonamento do monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) utilizando `Super + /` para aumentar e `Super + Alt + /` para diminuir. Se tiver a configuração predefinida, estas alterações também vão persistir após reiniciar.

### Tornar o texto maior ou mais pequeno

O escalonamento do monitor altera o tamanho de tudo. Se tudo o que quer é texto maior ou mais pequeno, existe um único ajuste para isso:

```
omarchy display text size 14
```

Isto recebe um tamanho em píxeis entre 9 e 20 e move a shell do Omarchy, as aplicações GTK e o seu terminal em conjunto, para que todo o ambiente de trabalho se mantenha em proporção. Execute-o sem um argumento para ver em que ponto está, e `omarchy display text size reset` para voltar à predefinição. O Foot é o único que fica para trás: não tem forma de recarregar a sua configuração, pelo que os terminais em execução mantêm o tamanho antigo até abrir um novo.

### Estender e espelhar ecrãs de portátil

Quando liga um ecrã externo ao seu portátil, o ecrã é automaticamente estendido. Mas pode alterar isso para espelhamento, em vez disso, utilizando _Trigger > Hardware_ no menu do Omarchy ou `Super + Ctrl + Alt + Delete`. Isto é especialmente útil se esse ecrã externo for um projetor e quiser mostrar algo enquanto está a trabalhar.

Quando estiver a estender, fechar a tampa do portátil vai desligar automaticamente o ecrã interno. Abrir a tampa vai voltar a ligá-lo. Também pode controlar isto manualmente utilizando _Trigger > Hardware_ no menu do Omarchy ou `Super + Ctrl + Delete`.

### Organizar vários ecrãs

O Hyprland funciona muito bem com vários ecrãs. Leia mais sobre como os dispor na [documentação de monitores do Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). No Omarchy, isto vai para `~/.config/hypr/monitors.lua` como entradas `hl.monitor` — o ficheiro inclui exemplos comentados para fixar um monitor específico numa resolução, posição e rotação.

Cada monitor tem os seus próprios espaços de trabalho de 1 a 10, pelo que `Super + 1` significa sempre o primeiro espaço de trabalho do monitor em que está. Nos bastidores, o Hyprland continua a numerar os espaços de trabalho em todos os monitores: o ecrã do seu portátil (ou o primeiro monitor) fica com 1–10, o monitor seguinte com 11–20, e assim sucessivamente, e cada monitor mantém o seu bloco sempre que o liga. Utilize esses números se escrever [regras de espaços de trabalho](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ou regras de janelas para um monitor específico, pelo que o espaço de trabalho 12 é o segundo espaço de trabalho do seu segundo monitor. `~/.local/state/omarchy/monitor-workspaces` lista que bloco tem cada monitor.

As teclas de seta funcionam entre monitores que partilham uma aresta na sua disposição. Ecrãs que só se tocam num canto, ou que têm um intervalo entre eles, não são vizinhos, pelo que deve utilizar `Ctrl + Alt + Tab` para passar entre eles.

| Hotkey | Entre monitores |
| --- | --- |
| `Super + Arrow` | Move o foco para o monitor desse lado quando já não houver nenhuma janela nessa direção |
| `Super + Shift + Arrow` | Troca com uma janela no monitor desse lado |
| `Super + Alt + Arrow` | Move a janela para um grupo no monitor desse lado |
| `Super + Shift + Ctrl + Arrow` | Move a janela para o monitor desse lado, para o espaço de trabalho que ele está a mostrar |
| `Super + Shift + Alt + Arrow` | Move o espaço de trabalho para o monitor desse lado, mantendo o seu número se estiver livre |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Move o foco para o monitor seguinte ou anterior, independentemente da disposição |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Permanecem no monitor em que está |

Também pode dar uma vista de olhos ao [Hyprmon](https://github.com/erans/hyprmon/), se quiser uma TUI para o ajudar no posicionamento de vários ecrãs.

### Controlar a luminosidade

A luminosidade do monitor é controlada pelas teclas de função dedicadas para aumentar/diminuir a luminosidade. Se mantiver premido shift enquanto prime estas teclas, vai para a luminosidade máxima ou mínima. As teclas controlam o ecrã em que está focado, pelo que os monitores externos que falam DDC/CI são ajustados da mesma forma que o ecrã do portátil.

### Ecrãs Apple

Se estiver a utilizar um ecrã Apple, as teclas normais de luminosidade do teclado também vão funcionar automaticamente, se estiver focado no ecrã Apple. Isto é feito através do comando `asdcontrol`.

Note que, se estiver a utilizar um ecrã Apple 6K XDR, pode ver um ecrã fantasma na sua listagem `hyprctl monitors`. Pode desligar isto com algo como `hl.monitor({ output = "DP-2", disabled = true })` através de _Setup > Monitors_.

Em máquinas Intel, deve ligar-se a ecrãs Apple utilizando um cabo Thunderbolt normal. Noutras máquinas sem Thunderbolt, normalmente vai ter de utilizar um [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) para que funcione.
