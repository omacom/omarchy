# Monitores

O Omarchy parte do princípio de que estás a correr, por predefinição, num ecrã de classe retina capaz de 2x. É isto que precisas para obteres aqueles tipos de letra de programador bonitos e nítidos. É aquilo para que quase todos os portáteis premium novos com ecrãs de alta resolução estão otimizados. É o que quererias correr num [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) de 27" 5K ou num [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) de 32" 6K.

Mas, se não estiveres a correr num ecrã com um PPI de 218 ou superior, vais querer alterar as definições do monitor. Por exemplo, se tiveres um 4K de 27" ou 32", podes usar escalonamento fracionário abrindo `~/.config/hypr/monitors.lua` (através de _Configurar > Ecrãs_ no menu Omarchy) e mudando para a recomendação para essa combinação:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Se estiveres a usar um ecrã de 1080p ou 1440p, provavelmente vais querer apenas usar escalonamento 1x, por isso podes usar:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

As alterações ao `GDK_SCALE` aplicam-se às aplicações iniciadas depois da alteração (e o GTK só respeita números inteiros, por isso mantém-no no inteiro mais próximo da escala do teu monitor). Por isso, certifica-te de que fechas as janelas que tens sobredimensionadas depois da alteração (ou fecha todas as janelas com `Ctrl + Alt + Del`!).

Também podes percorrer rapidamente as principais proporções de escalonamento do monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) usando `Super + /` para subir e `Super + Alt + /` para descer. Se tiveres a configuração predefinida, estas alterações também persistem após o reinício.

### Tornar o texto maior ou menor

O escalonamento do monitor altera o tamanho de tudo. Se tudo o que queres é _texto_ maior ou menor, há um único botão para isso:

```
omarchy display text size 14
```

Isso aceita um tamanho em píxeis entre 9 e 20 e move a shell do Omarchy, as aplicações GTK e o teu terminal em conjunto, para que todo o ambiente de trabalho se mantenha proporcional. Executa-o sem argumento para veres onde estás e `omarchy display text size reset` para voltares à predefinição. O Foot é o único retardatário: não tem forma de recarregar a sua configuração, por isso os terminais em execução mantêm o tamanho antigo até abrires um novo.

### Estender e espelhar ecrãs de portáteis

Quando ligas um ecrã externo ao teu portátil, o ecrã é automaticamente estendido. Mas podes mudar isso para espelhamento usando _Acionar > Hardware_ no menu Omarchy ou `Super + Ctrl + Alt + Delete`. Isto é especialmente útil se esse ecrã externo for um projetor e quiseres mostrar alguma coisa enquanto trabalhas.

Quando estiveres a estender, fechar a tampa do portátil desliga automaticamente o ecrã interno. Abrir a tampa volta a ligá-lo. Também podes controlar isto manualmente usando _Acionar > Hardware_ no menu Omarchy ou `Super + Ctrl + Delete`.

### Dispor vários ecrãs

O Hyprland funciona muito bem com vários ecrãs. Lê mais sobre como os dispor na [documentação de monitores do Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Também podes [associar áreas de trabalho específicas a monitores específicos](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). No Omarchy, estas regras vão para `~/.config/hypr/monitors.lua` como entradas `hl.monitor` — o ficheiro vem com exemplos comentados para fixar um monitor específico a uma resolução, posição e rotação.

Também podes espreitar o [Hyprmon](https://github.com/erans/hyprmon/), se quiseres uma TUI para te ajudar no posicionamento de vários ecrãs.

### Controlar o brilho

O brilho do monitor é controlado pelas teclas de função dedicadas para aumentar/diminuir o brilho. Se mantiveres o Shift carregado enquanto carregas nelas, vais para o brilho máximo ou mínimo. As teclas controlam o ecrã em que estás focado, por isso os monitores externos que falam DDC/CI são ajustados da mesma forma que o ecrã do portátil.

### Ecrãs Apple

Se estiveres a usar um ecrã Apple, as teclas normais de brilho do teclado também funcionam automaticamente, se estiveres focado no ecrã Apple. Isto é feito através do comando `asdcontrol`.

Nota que, se estiveres a usar um ecrã Apple 6K XDR, podes ver um ecrã fantasma na tua listagem `hyprctl monitors`. Podes desligar isto com algo como `hl.monitor({ output = "DP-2", disabled = true })` através de _Configurar > Ecrãs_.

Em máquinas Intel, deves ligar-te a ecrãs Apple usando um cabo Thunderbolt normal. Noutras máquinas sem Thunderbolt, normalmente tens de usar um [cabo DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) para que funcione.
