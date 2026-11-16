# Ecrãs

O Omarchy assume, por predefinição, que está a utilizar um ecrã de classe retina com capacidade 2x. É disso que precisa para obter aqueles tipos de letra de programador bonitos e nítidos. É para isso que estão otimizados quase todos os novos portáteis premium com ecrãs de alta resolução. É o que vai querer utilizar num ecrã de 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ou de 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Mas se não estiver a utilizar um ecrã com um PPI de 218 ou superior, vai querer alterar as definições do ecrã. Por exemplo, se tiver um 4K de 27" ou 32", pode escolher uma escala fracionária para ele no painel do ecrã na barra superior, ou definir a predefinição para todos os ecrãs ao abrir `~/.config/hypr/monitors.lua` e ao mudar para a recomendação para essa combinação:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Se estiver a utilizar um ecrã 1080p ou 1440p, provavelmente vai querer apenas utilizar a escala 1x, e o mesmo para as aplicações GTK e X11, por isso pode utilizar:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

As alterações ao `GDK_SCALE` aplicam-se às aplicações iniciadas depois da alteração (e o GTK só aceita números inteiros, por isso mantenha-o no inteiro mais próximo da escala do seu ecrã). Por isso, certifique-se de que fecha as janelas sobredimensionadas que tiver depois da alteração (ou feche todas as janelas com `Ctrl + Alt + Del`!).

Também pode percorrer rapidamente as principais proporções de escala do ecrã (1x, 1.25x, 1.6x, 2x, 3x, 4x) com `Super + /` para aumentar e `Super + Alt + /` para diminuir, ou escolher uma no painel do ecrã na barra superior. Estas só alteram o ecrã onde está o foco, por isso o ecrã do portátil e um ecrã externo podem ter cada um a sua própria escala. O painel também define a resolução, a taxa de atualização e a rotação de cada ecrã. As suas escolhas são guardadas para esse ecrã físico em `~/.local/state/omarchy/monitors/settings`, por isso mantêm-se depois de reiniciar e seguem o ecrã para qualquer porta ou dock a que ele seja ligado a seguir. Têm precedência sobre qualquer regra para o mesmo ecrã em `~/.config/hypr/monitors.lua`, que o Omarchy nunca edita. Se preferir definir os seus ecrãs inteiramente nesse ficheiro, adicione `omarchy_monitor_panel_settings = false` ao mesmo, e as alterações do painel só durarão até o Hyprland recarregar. Como o `GDK_SCALE` é um único valor para todos os ecrãs, uma escala escolhida define-o a partir do ecrã com a escala mais baixa, por isso as aplicações X11 ficam um pouco pequenas no ecrã mais denso em vez de sobredimensionadas no outro.

### Tornar o texto maior ou menor

A escala do ecrã altera o tamanho de tudo. Se só quiser _texto_ maior ou menor, há um único ajuste para isso:

```
omarchy display text size 14
```

Isso aceita um tamanho em píxeis entre 9 e 20, e ajusta em conjunto a shell do Omarchy, as aplicações GTK e o seu terminal, para que todo o ambiente de trabalho se mantenha proporcional. Execute-o sem argumento para ver em que ponto está, e `omarchy display text size reset` para voltar à predefinição. O Foot é o único retardatário: não tem forma de recarregar a sua configuração, por isso os terminais em execução mantêm o tamanho antigo até abrir um novo.

### Estender e espelhar ecrãs do portátil

Quando liga um ecrã externo ao seu portátil, o ecrã é automaticamente estendido. Mas pode mudar isso para espelhamento, em vez disso, com _Trigger > Hardware_ no menu do Omarchy ou `Super + Ctrl + Alt + Delete`. Isto é especialmente útil se esse ecrã externo for um projetor e quiser mostrar alguma coisa enquanto trabalha.

Quando está a estender, fechar a tampa do portátil desliga automaticamente o ecrã interno. Abrir a tampa volta a ligá-lo. Também pode controlar isto manualmente com _Trigger > Hardware_ no menu do Omarchy ou `Super + Ctrl + Delete`.

### Organizar vários ecrãs

O Hyprland funciona muito bem com vários ecrãs. O painel do ecrã na barra superior desenha-os onde eles estão: arraste um contra a lateral de outro para o mover para lá, e a disposição é guardada com as outras definições de cada ecrã. Para tudo o que o painel não abrange, leia mais sobre como os dispor na [documentação de ecrãs do Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). No Omarchy, estas vão para `~/.config/hypr/monitors.lua` como entradas `hl.monitor` — o ficheiro inclui exemplos comentados para manter um ecrã desligado, modos que o painel não oferece, cor de 10 bits e taxa de atualização variável.

Cada ecrã tem as suas próprias áreas de trabalho 1 a 10, por isso `Super + 1` significa sempre a primeira área de trabalho do ecrã onde está. Nos bastidores, o Hyprland continua a numerar as áreas de trabalho por todos os ecrãs: o ecrã do seu portátil (ou o primeiro ecrã) fica com 1–10, o ecrã seguinte com 11–20, e assim sucessivamente, e cada ecrã mantém o seu bloco sempre que o liga. Utilize esses números se escrever [regras de áreas de trabalho](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ou regras de janelas para um ecrã específico, para que a área de trabalho 12 seja a segunda área de trabalho do seu segundo ecrã. `~/.local/state/omarchy/monitors/workspaces` indica que bloco tem cada ecrã.

As teclas de setas funcionam entre ecrãs que partilham uma aresta na sua disposição. Ecrãs que só se tocam num canto, ou que têm um espaço entre eles, não são vizinhos, por isso utilize `Ctrl + Alt + Tab` para passar entre eles.

| Tecla de atalho | Entre ecrãs |
| --- | --- |
| `Super + Arrow` | Move o foco para o ecrã desse lado quando já não há nenhuma janela nessa direção |
| `Super + Shift + Arrow` | Troca com uma janela no ecrã desse lado |
| `Super + Alt + Arrow` | Move a janela para um grupo no ecrã desse lado |
| `Super + Shift + Ctrl + Arrow` | Move a janela para o ecrã desse lado, para a área de trabalho que ele está a mostrar |
| `Super + Shift + Alt + Arrow` | Move a área de trabalho para o ecrã desse lado, mantendo o seu número se estiver livre |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Move o foco para o ecrã seguinte ou anterior, independentemente da disposição |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Mantêm-se no ecrã onde está |

Também pode ver o [Hyprmon](https://github.com/erans/hyprmon/), se quiser um TUI para o ajudar com o posicionamento de vários ecrãs.

### Controlar o brilho

O brilho do ecrã é controlado pelas teclas de função dedicadas para aumentar/diminuir o brilho. Se mantiver premido o shift enquanto prime estas teclas, irá para o brilho máximo ou mínimo. As teclas controlam o ecrã onde está o foco, por isso os ecrãs externos que falam DDC/CI são ajustados da mesma forma que o ecrã do portátil.

### Ecrãs Apple

Se estiver a utilizar um ecrã Apple, as teclas normais de brilho do teclado também funcionarão automaticamente, se estiver focado no ecrã Apple. Isto é feito através do comando `asdcontrol`.

Note que, se estiver a utilizar um ecrã Apple 6K XDR, poderá ver um ecrã fantasma na sua listagem `hyprctl monitors`. Pode desligar isto com algo como `hl.monitor({ output = "DP-2", disabled = true })` em `~/.config/hypr/monitors.lua`.

Em máquinas Intel, deve ligar-se a ecrãs Apple com um cabo Thunderbolt normal. Noutras máquinas sem Thunderbolt, normalmente terá de utilizar um [cabo DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) para que funcione.
