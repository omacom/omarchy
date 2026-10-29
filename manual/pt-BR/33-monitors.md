# Monitores

O Omarchy supõe por padrão que você está usando uma tela de classe retina com capacidade de 2x. É disso que você precisa para obter aquelas fontes de programador bonitas e nítidas. É para isso que quase todos os novos laptops premium com telas de alta resolução são otimizados. É o que você ia querer usar em um [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) de 27" 5K ou um [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) de 32" 6K.

Mas, se você não estiver usando uma tela com PPI de 218 ou superior, vai querer alterar as configurações do monitor. Por exemplo, se você tiver um 4K de 27" ou 32", poderá usar a escala fracionária abrindo `~/.config/hypr/monitors.lua` (por meio de _Configuração > Monitores_ no menu do Omarchy) e mudando para a recomendação para essa combinação:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Se você estiver usando uma tela de 1080p ou 1440p, provavelmente vai querer usar apenas a escala de 1x, então você pode usar:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

As alterações no `GDK_SCALE` se aplicam aos aplicativos iniciados depois da alteração (e o GTK só aceita números inteiros, então mantenha-o no inteiro mais próximo da escala do seu monitor). Portanto, feche as janelas que você tiver e que ficarem grandes demais depois da alteração (ou feche todas as janelas com `Ctrl + Alt + Del`!).

Você também pode percorrer rapidamente as principais proporções de escala do monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) usando `Super + /` para aumentar e `Super + Alt + /` para diminuir, ou escolher uma no painel do monitor na barra superior. Elas alteram apenas o monitor em que você está focado, para que a tela do laptop e uma tela externa possam ter cada uma a sua própria escala. A escolha é salva em `~/.config/hypr/monitors.lua` como uma regra `hl.monitor` para esse monitor, portanto ela persiste após a reinicialização e tem precedência sobre `omarchy_monitor_scale`, que continua sendo a escala para todos os monitores sem uma regra própria. Como o `GDK_SCALE` é um único valor para todas as telas, essas alterações o definem a partir do monitor com a menor escala, para que os aplicativos X11 fiquem um pouco pequenos na tela mais densa, em vez de grandes demais na outra.

### Aumentando ou diminuindo o texto

A escala do monitor altera o tamanho de tudo. Se tudo o que você quer é um _texto_ maior ou menor, existe um único ajuste para isso:

```
omarchy display text size 14
```

Isso aceita um tamanho em pixels entre 9 e 20 e move o shell do Omarchy, os aplicativos GTK e o seu terminal juntos, para que toda a área de trabalho permaneça em proporção. Execute-o sem um argumento para ver onde você está e `omarchy display text size reset` para voltar ao padrão. O Foot é o único retardatário: ele não tem como recarregar sua configuração, então os terminais em execução mantêm o tamanho antigo até você abrir um novo.

### Estendendo e espelhando telas de laptop

Quando você conecta uma tela externa ao seu laptop, a tela é estendida automaticamente. Mas você pode mudar isso para espelhamento, usando _Acionador > Hardware_ no menu do Omarchy ou `Super + Ctrl + Alt + Delete`. Isso é especialmente útil se essa tela externa for um projetor e você quiser mostrar algo enquanto trabalha.

Ao estender, fechar a tampa do laptop desligará automaticamente a tela interna. Abrir a tampa a ligará novamente. Você também pode controlar isso manualmente usando _Acionador > Hardware_ no menu do Omarchy ou `Super + Ctrl + Delete`.

### Organizando várias telas

O Hyprland funciona muito bem com várias telas. Leia mais sobre como organizá-las na [documentação de monitores do Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). No Omarchy, elas vão em `~/.config/hypr/monitors.lua` como entradas `hl.monitor` — o arquivo vem com exemplos comentados para fixar um monitor específico em uma resolução, posição e rotação.

Cada monitor tem seus próprios workspaces de 1 a 10, então `Super + 1` sempre significa o primeiro workspace do monitor em que você está. Nos bastidores, o Hyprland ainda numera os workspaces em todos os monitores: a tela do seu laptop (ou o primeiro monitor) fica com 1–10, o próximo monitor com 11–20, e assim por diante, e cada monitor mantém o seu bloco toda vez que você o conecta. Use esses números se você escrever [regras de workspace](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ou regras de janela para um monitor específico, de modo que o workspace 12 seja o segundo workspace do seu segundo monitor. `~/.local/state/omarchy/monitor-workspaces` lista qual bloco cada monitor tem.

As teclas de seta funcionam entre monitores que compartilham uma borda no seu layout. Telas que só se tocam em um canto, ou que têm um espaço entre elas, não são vizinhas, então use `Ctrl + Alt + Tab` para ir de uma para a outra.

| Tecla de atalho | Entre monitores |
| --- | --- |
| `Super + Arrow` | Move o foco para o monitor daquele lado, quando não houver mais nenhuma janela naquela direção |
| `Super + Shift + Arrow` | Troca com uma janela no monitor daquele lado |
| `Super + Alt + Arrow` | Move a janela para um grupo no monitor daquele lado |
| `Super + Shift + Ctrl + Arrow` | Move a janela para o monitor daquele lado, para o workspace que ele está exibindo |
| `Super + Shift + Alt + Arrow` | Move o workspace para o monitor daquele lado, mantendo o seu número, se ele estiver livre |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Move o foco para o próximo monitor ou para o monitor anterior, seja qual for o layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Permanecem no monitor em que você está |

Você também pode conferir o [Hyprmon](https://github.com/erans/hyprmon/), se quiser uma TUI para ajudá-lo com o posicionamento de várias telas.

### Controlando o brilho

O brilho do monitor é controlado pelas teclas de função dedicadas para aumentar/diminuir o brilho. Se você segurar Shift enquanto pressiona essas teclas, irá para o brilho máximo ou mínimo. As teclas controlam a tela em que você está focado, então monitores externos que falam DDC/CI são ajustados da mesma forma que a tela do laptop.

### Telas da Apple

Se você estiver usando uma tela da Apple, as teclas comuns de brilho do teclado também funcionarão automaticamente, se você estiver focado na tela da Apple. Isso é feito por meio do comando `asdcontrol`.

Observe que, se você estiver usando uma tela Apple 6K XDR, poderá ver uma tela fantasma na sua listagem de `hyprctl monitors`. Você pode desativar isso com algo como `hl.monitor({ output = "DP-2", disabled = true })` por meio de _Configuração > Monitores_.

Em máquinas Intel, você deve conectar as telas da Apple usando um cabo Thunderbolt comum. Em outras máquinas sem Thunderbolt, você normalmente terá que usar um [cabo DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) para fazer isso funcionar.
