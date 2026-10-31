# Monitores

O Omarchy assume, por omissão, que está a utilizar um ecrã de classe retina com capacidade para 2x. É disto que precisa para obter aqueles tipos de letra de programador bonitos e nítidos. É para isto que estão otimizados quase todos os novos portáteis premium com ecrãs de alta resolução. É o que vai querer utilizar num 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ou num 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Mas se não estiver a utilizar um ecrã com 218 PPI ou mais, vai querer alterar as definições do monitor. Por exemplo, se tiver um ecrã 4K de 27" ou 32", pode escolher uma escala fracionária para o mesmo no painel do monitor na barra superior, ou definir a predefinição para todos os monitores abrindo `~/.config/hypr/monitors.lua` e mudando para a recomendação indicada para essa combinação:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Se estiver a utilizar um ecrã de 1080p ou 1440p, provavelmente vai querer usar simplesmente a escala 1x, e o mesmo para as aplicações GTK e X11, pelo que pode utilizar:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

As alterações a `GDK_SCALE` aplicam-se às aplicações iniciadas depois da alteração (e o GTK só aceita números inteiros, por isso mantenha-o no número inteiro mais próximo da escala do seu monitor). Por isso, certifique-se de que fecha as janelas que tiver sobredimensionadas depois da alteração (ou feche todas as janelas com `Ctrl + Alt + Del`!).

Também pode percorrer rapidamente as principais proporções de escala do monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) utilizando `Super + /` para aumentar e `Super + Alt + /` para diminuir, ou escolher uma no painel do monitor na barra superior. Estas alterações afetam apenas o monitor em que está focado, pelo que o ecrã de um portátil e um ecrã externo podem ter cada um a sua própria escala. O painel também define a resolução de cada monitor. As suas escolhas são guardadas para esse monitor físico em `~/.local/state/omarchy/monitors/settings`, pelo que se mantêm após reiniciar e acompanham o monitor para qualquer porta ou base de ligação a que seja ligado a seguir. Têm precedência sobre qualquer regra para o mesmo monitor em `~/.config/hypr/monitors.lua`, que o Omarchy nunca edita. Se preferir definir os seus monitores inteiramente nesse ficheiro, adicione `omarchy_monitor_panel_settings = false` ao mesmo, e as alterações do painel durarão apenas até o Hyprland recarregar. Como `GDK_SCALE` é um único valor para todos os ecrãs, uma escala escolhida define-o a partir do monitor com a escala mais baixa, pelo que as aplicações X11 ficam um pouco pequenas no ecrã mais denso, em vez de sobredimensionadas no outro.

### Tornar o texto maior ou menor

A escala do monitor altera o tamanho de tudo. Se tudo o que quer é texto maior ou menor, existe um único controlo para isso:

```
omarchy display text size 14
```

Aceita um tamanho em píxeis entre 9 e 20 e ajusta em conjunto a shell do Omarchy, as aplicações GTK e o seu terminal, para que todo o ambiente de trabalho se mantenha proporcionado. Execute-o sem argumento para ver o valor atual, e `omarchy display text size reset` para voltar à predefinição. O Foot é o único atrasado: não tem forma de recarregar a sua configuração, pelo que os terminais em execução mantêm o tamanho antigo até abrir um novo.

### Estender e espelhar ecrãs de portátil

Quando liga um ecrã externo ao seu portátil, o ecrã é automaticamente estendido. Mas pode mudar isso para espelhamento, em alternativa, utilizando _Trigger > Hardware_ no menu do Omarchy ou `Super + Ctrl + Alt + Delete`. Isto é especialmente útil se esse ecrã externo for um projetor e quiser mostrar algo enquanto trabalha.

Quando está a estender, fechar a tampa do portátil desliga automaticamente o ecrã interno. Abrir a tampa volta a ligá-lo. Também pode controlar isto manualmente utilizando _Trigger > Hardware_ no menu do Omarchy ou `Super + Ctrl + Delete`.

### Organizar vários ecrãs

O Hyprland funciona muito bem com vários ecrãs. O painel do monitor na barra superior desenha-os onde estão posicionados: arraste um contra o lado de outro para o mover para aí, e a disposição é guardada juntamente com as restantes definições de cada monitor. Para tudo o que o painel não abrange, leia mais sobre como os organizar na [documentação de monitores do Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). No Omarchy, estas definições vão para `~/.config/hypr/monitors.lua` como entradas `hl.monitor` — o ficheiro inclui exemplos comentados para fixar um monitor específico numa resolução, posição e rotação.

Cada monitor tem os seus próprios espaços de trabalho 1 a 10, pelo que `Super + 1` significa sempre o primeiro espaço de trabalho do monitor em que se encontra. Nos bastidores, o Hyprland continua a numerar os espaços de trabalho através de todos os monitores: o ecrã do seu portátil (ou o primeiro monitor) fica com 1–10, o monitor seguinte com 11–20, e assim por diante, e cada monitor mantém o seu bloco sempre que o volta a ligar. Utilize esses números se escrever [regras de espaços de trabalho](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ou regras de janelas para um monitor específico, pelo que o espaço de trabalho 12 é o segundo espaço de trabalho do seu segundo monitor. `~/.local/state/omarchy/monitors/workspaces` lista o bloco que cada monitor tem.

As teclas de setas funcionam entre monitores que partilham uma margem na sua disposição. Os ecrãs que só se tocam num canto, ou que têm um intervalo entre si, não são vizinhos, pelo que deve utilizar `Ctrl + Alt + Tab` para passar entre eles.

| Tecla de atalho | Entre monitores |
| --- | --- |
| `Super + Arrow` | Move o foco para o monitor desse lado assim que já não houver nenhuma janela nessa direção |
| `Super + Shift + Arrow` | Troca com uma janela no monitor desse lado |
| `Super + Alt + Arrow` | Move a janela para um grupo no monitor desse lado |
| `Super + Shift + Ctrl + Arrow` | Move a janela para o monitor desse lado, para o espaço de trabalho que está a mostrar |
| `Super + Shift + Alt + Arrow` | Move o espaço de trabalho para o monitor desse lado, mantendo o seu número se estiver livre |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Move o foco para o monitor seguinte ou anterior, qualquer que seja a disposição |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Mantêm-se no monitor em que se encontra |

Também pode experimentar o [Hyprmon](https://github.com/erans/hyprmon/), se quiser uma TUI para o ajudar no posicionamento de vários ecrãs.

### Controlar o brilho

O brilho do monitor é controlado pelas teclas de função dedicadas para aumentar/diminuir o brilho. Se mantiver premido o shift enquanto prime estas teclas, irá para o brilho máximo ou mínimo. As teclas controlam o ecrã em que está focado, pelo que os monitores externos que comunicam por DDC/CI são ajustados da mesma forma que o ecrã do portátil.

### Ecrãs Apple

Se estiver a utilizar um ecrã Apple, as teclas normais de brilho do teclado também funcionarão automaticamente, se estiver focado no ecrã Apple. Isto é feito através do comando `asdcontrol`.

Tenha em atenção que, se estiver a utilizar um ecrã Apple 6K XDR, poderá ver um ecrã fantasma na listagem de `hyprctl monitors`. Pode desligar isto com algo como `hl.monitor({ output = "DP-2", disabled = true })` em `~/.config/hypr/monitors.lua`.

Em máquinas Intel, deve ligar-se a ecrãs Apple utilizando um cabo Thunderbolt normal. Noutras máquinas sem Thunderbolt, terá normalmente de utilizar um [cabo DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) para que funcione.
