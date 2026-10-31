# Monitores

O Omarchy parte do princípio de que, por predefinição, estás a usar um ecrã de classe retina com capacidade 2x. É isso que precisas para teres aquelas fontes de programador bonitas e nítidas. É para isso que quase todos os portáteis premium novos com ecrãs de alta resolução estão otimizados. É o que vais querer usar num [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) de 27" 5K ou num [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) de 32" 6K.

Mas se não estiveres a usar um ecrã com um PPI de 218 ou superior, vais querer alterar as definições do monitor. Por exemplo, se tiveres um 4K de 27" ou 32", podes escolher uma escala fracionária para ele a partir do painel do monitor na barra superior, ou definir a predefinição para cada monitor abrindo `~/.config/hypr/monitors.lua` e mudando para a recomendação para essa combinação:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Se estiveres a usar um ecrã de 1080p ou 1440p, provavelmente vais querer apenas usar uma escala de 1x, e o mesmo para as aplicações GTK e X11, por isso podes usar:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

As alterações ao `GDK_SCALE` aplicam-se às aplicações iniciadas depois da alteração (e o GTK só aceita números inteiros, por isso mantém-no no número inteiro mais próximo da escala do teu monitor). Por isso, certifica-te de que fechas as janelas que tiveres sobredimensionadas depois da alteração (ou fecha todas as janelas com `Ctrl + Alt + Del`!).

Também podes percorrer rapidamente as principais proporções de escala do monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) usando `Super + /` para subir e `Super + Alt + /` para descer, ou escolher uma a partir do painel do monitor na barra superior. Estas só alteram o monitor em que estás focado, por isso um ecrã de portátil e um ecrã externo podem ter cada um a sua própria escala. O painel também define a resolução de cada monitor. As tuas escolhas são guardadas para esse monitor físico em `~/.local/state/omarchy/monitors/settings`, por isso persistem depois de reiniciares e acompanham o monitor para qualquer porta ou dock a que o ligues a seguir. Têm precedência sobre qualquer regra para o mesmo monitor em `~/.config/hypr/monitors.lua`, que o Omarchy nunca edita. Como o `GDK_SCALE` é um único valor para todos os ecrãs, uma escala escolhida define-o a partir do monitor com a escala mais baixa, por isso as aplicações X11 ficam um pouco pequenas no ecrã mais denso em vez de sobredimensionadas no outro.

### Tornar o texto maior ou menor

A escala do monitor altera o tamanho de tudo. Se tudo o que queres é _texto_ maior ou menor, há um único ajuste para isso:

```
omarchy display text size 14
```

Isso aceita um tamanho em píxeis entre 9 e 20, e move a shell do Omarchy, as aplicações GTK e o teu terminal em conjunto, para que todo o ambiente de trabalho se mantenha em proporção. Executa-o sem um argumento para veres onde estás, e `omarchy display text size reset` para voltares à predefinição. O Foot é o único que fica para trás: não tem forma de recarregar a sua configuração, por isso os terminais em execução mantêm o tamanho antigo até abrires um novo.

### Estender e espelhar ecrãs de portátil

Quando ligas um ecrã externo ao teu portátil, o ecrã é automaticamente estendido. Mas podes mudar isso para espelhamento, em vez disso, usando _Trigger > Hardware_ no menu do Omarchy ou `Super + Ctrl + Alt + Delete`. Isto é especialmente útil se esse ecrã externo for um projetor, e quiseres mostrar algo enquanto estás a trabalhar.

Quando estás a estender, fechar a tampa do portátil desliga automaticamente o ecrã interno. Abrir a tampa volta a ligá-lo. Também podes controlar isto manualmente usando _Trigger > Hardware_ no menu do Omarchy ou `Super + Ctrl + Delete`.

### Organizar vários ecrãs

O Hyprland funciona muito bem com vários ecrãs. O painel do monitor na barra superior desenha-os onde eles estão: arrasta um contra o lado de outro para o moveres para lá, e a disposição é guardada juntamente com as outras definições de cada monitor. Para tudo o que o painel não cobre, lê mais sobre como os dispor na [documentação de monitores do Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). No Omarchy, estas vão em `~/.config/hypr/monitors.lua` como entradas `hl.monitor` — o ficheiro vem com exemplos comentados para fixares um monitor específico a uma resolução, posição e rotação.

Cada monitor tem as suas próprias áreas de trabalho de 1 a 10, por isso `Super + 1` significa sempre a primeira área de trabalho do monitor em que estás. Nos bastidores, o Hyprland continua a numerar as áreas de trabalho por todos os monitores: o ecrã do teu portátil (ou o primeiro monitor) recebe 1–10, o monitor seguinte 11–20, e assim por diante, e cada monitor mantém o seu bloco de cada vez que o ligas. Usa esses números se escreveres [regras de áreas de trabalho](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ou regras de janelas para um monitor específico, por isso a área de trabalho 12 é a segunda área de trabalho do teu segundo monitor. `~/.local/state/omarchy/monitors/workspaces` lista que bloco cada monitor tem.

As teclas de seta funcionam entre monitores que partilham um lado na tua disposição. Ecrãs que só se tocam num canto, ou que têm um espaço entre eles, não são vizinhos, por isso usa `Ctrl + Alt + Tab` para passares entre eles.

| Tecla de atalho | Entre monitores |
| --- | --- |
| `Super + Arrow` | Move o foco para o monitor desse lado quando já não houver nenhuma janela nessa direção |
| `Super + Shift + Arrow` | Troca com uma janela no monitor desse lado |
| `Super + Alt + Arrow` | Move a janela para um grupo no monitor desse lado |
| `Super + Shift + Ctrl + Arrow` | Move a janela para o monitor desse lado, para a área de trabalho que ele está a mostrar |
| `Super + Shift + Alt + Arrow` | Move a área de trabalho para o monitor desse lado, mantendo o seu número se estiver livre |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Move o foco para o monitor seguinte ou anterior, independentemente da disposição |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Permanecem no monitor em que estás |

Também podes ver o [Hyprmon](https://github.com/erans/hyprmon/), se quiseres uma TUI para te ajudar com o posicionamento de vários ecrãs.

### Controlar o brilho

O brilho do monitor é controlado pelas teclas de função dedicadas para aumentar e diminuir o brilho. Se mantiveres o Shift premido enquanto premes estas teclas, vais para o brilho máximo ou mínimo. As teclas controlam o ecrã em que estás focado, por isso os monitores externos que falam DDC/CI são ajustados da mesma forma que o ecrã do portátil.

### Ecrãs Apple

Se estiveres a usar um ecrã Apple, as teclas normais de brilho do teclado também funcionam automaticamente, se estiveres focado no ecrã Apple. Isto é feito através do comando `asdcontrol`.

Nota que, se estiveres a usar um ecrã Apple 6K XDR, poderás ver um ecrã fantasma na tua listagem `hyprctl monitors`. Podes desligar isto com algo como `hl.monitor({ output = "DP-2", disabled = true })` em `~/.config/hypr/monitors.lua`.

Em máquinas Intel, deves ligar-te a ecrãs Apple usando um cabo Thunderbolt normal. Noutras máquinas sem Thunderbolt, normalmente terás de usar um [cabo DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) para que funcione.
