# Monitores

O Omarchy pressupõe, por padrão, que você está usando um monitor classe retina com capacidade 2x. É disso que você precisa para ter aquelas fontes de programador bonitas e nítidas. É para isso que quase todos os novos laptops premium com telas de alta resolução são otimizados. É o que você iria querer usar em um monitor de 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ou de 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Mas se você não estiver usando um monitor com PPI de 218 ou superior, vai querer alterar as configurações do monitor. Por exemplo, se você tiver um 4K de 27" ou 32", pode escolher uma escala fracionária para ele no painel do monitor na barra superior, ou definir o padrão para todos os monitores abrindo `~/.config/hypr/monitors.lua` e mudando para a recomendação para essa combinação:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Se você estiver usando um monitor 1080p ou 1440p, provavelmente vai querer usar apenas a escala 1x, e o mesmo para aplicativos GTK e X11, então pode usar:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

As alterações em `GDK_SCALE` se aplicam aos aplicativos iniciados depois da alteração (e o GTK só aceita números inteiros, então mantenha-o no inteiro mais próximo da escala do seu monitor). Portanto, feche as janelas que você tiver que ficarem grandes demais depois da alteração (ou feche todas as janelas com `Ctrl + Alt + Del`!).

Você também pode percorrer rapidamente as principais proporções de escala do monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) usando `Super + /` para aumentar e `Super + Alt + /` para diminuir, ou escolher uma no painel do monitor na barra superior. Essas alterações afetam apenas o monitor em que você está focado, então a tela de um laptop e um monitor externo podem ter cada um sua própria escala. O painel também define a resolução, a taxa de atualização e a rotação de cada monitor. Suas escolhas são salvas para aquele monitor físico em `~/.local/state/omarchy/monitors/settings`, então elas persistem após a reinicialização e acompanham o monitor para qualquer porta ou dock em que ele for conectado da próxima vez. Elas têm precedência sobre qualquer regra para o mesmo monitor em `~/.config/hypr/monitors.lua`, que o Omarchy nunca edita. Se você preferir configurar seus monitores inteiramente nesse arquivo, adicione `omarchy_monitor_panel_settings = false` a ele, e as alterações do painel vão durar apenas até o Hyprland recarregar. Como `GDK_SCALE` é um único valor para todas as telas, uma escala escolhida o define a partir do monitor com a menor escala, então os aplicativos X11 ficam um pouco pequenos na tela mais densa em vez de grandes demais na outra.

### Aumentando ou diminuindo o texto

A escala do monitor altera o tamanho de tudo. Se tudo o que você quer é texto maior ou menor, há um único controle para isso:

```
omarchy display text size 14
```

Isso recebe um tamanho em pixels entre 9 e 20, e move a shell do Omarchy, os aplicativos GTK e seu terminal juntos, então toda a área de trabalho permanece proporcional. Execute-o sem argumento para ver onde você está, e `omarchy display text size reset` para voltar ao padrão. O Foot é o único que fica para trás: ele não tem como recarregar sua configuração, então os terminais em execução mantêm o tamanho antigo até você abrir um novo.

### Estendendo e espelhando telas de laptop

Quando você conecta uma tela externa ao seu laptop, a exibição é estendida automaticamente. Mas você pode mudar isso para espelhamento usando _Trigger > Hardware_ no menu do Omarchy ou `Super + Ctrl + Alt + Delete`. Isso é especialmente útil se essa tela externa for um projetor, e você quiser mostrar algo enquanto trabalha.

Quando você está estendendo, fechar a tampa do laptop desliga automaticamente a tela interna. Abrir a tampa a liga novamente. Você também pode controlar isso manualmente usando _Trigger > Hardware_ no menu do Omarchy ou `Super + Ctrl + Delete`.

### Organizando várias telas

O Hyprland funciona muito bem com várias telas. O painel do monitor na barra superior desenha elas onde estão posicionadas: arraste uma contra a lateral de outra para movê-la para lá, e a organização é salva junto com as outras configurações de cada monitor. Para qualquer coisa que o painel não cubra, leia mais sobre como organizá-las na [documentação de monitores do Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). No Omarchy, elas vão em `~/.config/hypr/monitors.lua` como entradas `hl.monitor` — o arquivo vem com exemplos comentados para manter um monitor desligado, modos que o painel não oferece, cor de 10 bits e taxa de atualização variável.

Cada monitor tem suas próprias workspaces de 1 a 10, então `Super + 1` sempre significa a primeira workspace do monitor em que você está. Nos bastidores, o Hyprland ainda numera as workspaces entre todos os monitores: a tela do seu laptop (ou primeiro monitor) fica com 1–10, o próximo monitor 11–20, e assim por diante, e cada monitor mantém seu bloco toda vez que você o conecta. Use esses números se você escrever [regras de workspace](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ou regras de janela para um monitor específico, então a workspace 12 é a segunda workspace do seu segundo monitor. `~/.local/state/omarchy/monitors/workspaces` lista qual bloco cada monitor tem.

As teclas de seta funcionam entre monitores que compartilham uma borda no seu layout. Telas que só se tocam em um canto, ou que têm um espaço entre elas, não são vizinhas, então use `Ctrl + Alt + Tab` para ir de uma para outra.

| Tecla de atalho | Entre monitores |
| --- | --- |
| `Super + Arrow` | Move o foco para o monitor daquele lado quando não há mais nenhuma janela naquela direção |
| `Super + Shift + Arrow` | Troca com uma janela no monitor daquele lado |
| `Super + Alt + Arrow` | Move a janela para um grupo no monitor daquele lado |
| `Super + Shift + Ctrl + Arrow` | Move a janela para o monitor daquele lado, para a workspace que ele está exibindo |
| `Super + Shift + Alt + Arrow` | Move a workspace para o monitor daquele lado, mantendo seu número se ele estiver livre |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Move o foco para o próximo monitor ou o anterior, independentemente do layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Permanecem no monitor em que você está |

Você também pode conferir o [Hyprmon](https://github.com/erans/hyprmon/), se quiser uma TUI para ajudar você com o posicionamento de várias telas.

### Controlando o brilho

O brilho do monitor é controlado pelas teclas de função dedicadas para aumentar/diminuir o brilho. Se você mantiver o shift pressionado enquanto pressiona essas teclas, vai para o brilho máximo ou mínimo. As teclas controlam a tela em que você está focado, então monitores externos que falam DDC/CI são ajustados da mesma forma que a tela do laptop.

### Monitores da Apple

Se você estiver usando um monitor da Apple, as teclas normais de brilho do teclado também vão funcionar automaticamente, se você estiver focado no monitor da Apple. Isso é feito por meio do comando `asdcontrol`.

Observe que, se você estiver usando um monitor Apple 6K XDR, pode ver uma tela fantasma na sua listagem de `hyprctl monitors`. Você pode desligar isso com algo como `hl.monitor({ output = "DP-2", disabled = true })` em `~/.config/hypr/monitors.lua`.

Em máquinas Intel, você deve conectar monitores da Apple usando um cabo Thunderbolt comum. Em outras máquinas sem Thunderbolt, normalmente você terá que usar um [cabo DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) para fazer isso funcionar.
