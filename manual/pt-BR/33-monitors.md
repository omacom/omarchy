# Monitores

O Omarchy presume que você esteja usando uma tela da classe retina capaz de 2x por padrão. Isso é o que você precisa para obter aquelas fontes de programador agradáveis e nítidas. É para o que quase todos os novos notebooks premium com telas de alta resolução são otimizados. É o que você gostaria de usar em um [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) de 27" 5K ou em um [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) de 32" 6K.

Mas se você não estiver usando uma tela com PPI de 218 ou superior, você vai querer alterar as configurações do monitor. Por exemplo, se você tiver um 4K de 27" ou 32", poderá usar o dimensionamento fracionário abrindo `~/.config/hypr/monitors.lua` (em _Configuração > Monitores_ no menu do Omarchy) e mudando para a recomendação para essa combinação:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Se você estiver usando uma tela de 1080p ou 1440p, provavelmente vai querer usar dimensionamento 1x, então você pode usar:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Alterações em `GDK_SCALE` se aplicam a aplicativos iniciados depois da alteração (e o GTK só respeita números inteiros, então mantenha-o no inteiro mais próximo da sua escala de monitor). Portanto, certifique-se de sair das janelas que você tiver que estejam grandes demais depois da alteração (ou feche todas as janelas com `Ctrl + Alt + Del`!).

Você também pode avançar rapidamente pelas principais razões de dimensionamento de monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) usando `Super + /` para subir e `Super + Alt + /` para descer. Se você tiver a configuração padrão, essas alterações também persistirão após a reinicialização.

### Tornando o texto maior ou menor

O dimensionamento do monitor altera o tamanho de tudo. Se tudo o que você quer é um _texto_ maior ou menor, há um único controle para isso:

```
omarchy display text size 14
```

Isso recebe um tamanho em pixels entre 9 e 20 e move o shell do Omarchy, os aplicativos GTK e seu terminal juntos, para que toda a área de trabalho permaneça em proporção. Execute-o sem um argumento para ver onde você está, e `omarchy display text size reset` para voltar ao padrão. O Foot é o único retardatário: ele não tem como recarregar sua configuração, então terminais em execução mantêm seu tamanho antigo até você abrir um novo.

### Estendendo e espelhando telas de notebook

Quando você conecta uma tela externa ao seu notebook, a exibição é automaticamente estendida. Mas você pode alterar isso para espelhamento usando _Acionar > Hardware_ no menu do Omarchy ou `Super + Ctrl + Alt + Delete`. Isso é especialmente útil se aquela tela externa for um projetor e você quiser mostrar algo enquanto trabalha.

Quando você estiver estendendo, fechar a tampa do notebook desligará automaticamente a tela interna. Abrir a tampa a ligará de novo. Você também pode controlar isso manualmente usando _Acionar > Hardware_ no menu do Omarchy ou `Super + Ctrl + Delete`.

### Organizando várias telas

O Hyprland funciona muito bem com várias telas. Leia mais sobre como organizá-las na [documentação de monitores do Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Você também pode [vincular áreas de trabalho específicas a monitores específicos](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). No Omarchy, essas regras vão em `~/.config/hypr/monitors.lua` como entradas `hl.monitor` — o arquivo vem com exemplos comentados para fixar um monitor específico a uma resolução, posição e rotação.

Você também pode conferir o [Hyprmon](https://github.com/erans/hyprmon/), se quiser uma TUI para ajudá-lo com o posicionamento de várias telas.

### Controlando o brilho

O brilho do monitor é controlado pelas teclas de função dedicadas para aumentar/diminuir o brilho. Se você segurar Shift enquanto pressiona essas teclas, irá para o brilho máximo ou mínimo. As teclas controlam a tela em que você está focado, então monitores externos que falam DDC/CI são ajustados da mesma maneira que a tela do notebook.

### Telas da Apple

Se você estiver usando uma tela da Apple, as teclas comuns de brilho do teclado também funcionarão automaticamente, se você estiver focado na tela da Apple. Isso é feito pelo comando `asdcontrol`.

Observe que, se você estiver usando uma tela Apple 6K XDR, poderá ver uma tela fantasma na sua listagem do `hyprctl monitors`. Você pode desligá-la com algo como `hl.monitor({ output = "DP-2", disabled = true })` em _Configuração > Monitores_.

Em máquinas Intel, você deve se conectar a telas da Apple usando um cabo Thunderbolt comum. Em outras máquinas sem Thunderbolt, você normalmente terá de usar um [cabo DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) para fazer funcionar.
