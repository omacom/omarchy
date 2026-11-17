# Teclado, Rato, Trackpad

O Hyprland permite-lhe configurar todas as entradas em grande detalhe. Pode alterar a repetição do teclado para ser supersonicamente rápida ou fazer o trackpad usar a deslocação natural. Altera tudo em `~/.config/hypr/input.lua`, a que também pode aceder através de _Setup > Input_ no menu do Omarchy (`Super + Space`). Tudo o que definir lá substitui os valores predefinidos do Omarchy.

Aqui está um exemplo:

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

Pode [ver todas as opções de entrada](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wiki do Hyprland para entradas.

CapsLock funciona como um Caps Lock normal, e `Shift + CapsLock` é a tecla de composição para [emojis rápidos](07-hotkeys.md#quick-emojis) e [outras conclusões](07-hotkeys.md#quick-completions). Se preferir ter a tecla de composição noutro sítio, substitua `omarchy:shift_caps_compose` em `kb_options`. Por exemplo, isto move a tecla de composição para Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Teclas de função

A fila superior de um teclado de portátil envia as teclas multimédia (volume, brilho e assim por diante) por predefinição, e manter `Fn` premido dá F1-F12; `Fn + Esc` bloqueia-o no sentido inverso até o premir novamente. A maioria dos teclados lembra-se desse bloqueio por si só. Os portáteis ASUS e os teclados de estilo Apple deixam isso para o Linux, que os inicia nas teclas multimédia a cada arranque. Para que iniciem antes em F1-F12, execute `omarchy keyboard toprow fnkeys` (e `omarchy keyboard toprow mediakeys` para voltar); em alguns portáteis, só produz efeito após um reinício. Os Macs com Apple Silicon mantêm a sua própria definição.

### Gestos do trackpad

Deslize no trackpad para se mover pelo ambiente de trabalho:

| Gesto | Ação |
| --- | --- |
| Três dedos para a esquerda / direita | Área de trabalho anterior / seguinte, incluindo as vazias |
| Três dedos para cima | Alternar a consola de IA |
| Três dedos para baixo | Abrir o menu do Omarchy |
| Quatro dedos para a esquerda / direita | Mover a janela ativa para a área de trabalho anterior / seguinte |
| Quatro dedos para baixo | Alternar o ecrã inteiro |

Para alterar um, anule-o em `~/.config/hypr/input.lua` antes de adicionar o seu próprio [gesto do touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), uma vez que o Hyprland não aceita dois gestos com os mesmos dedos e direção:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Para desligar todos os gestos do Omarchy, defina `omarchy_default_gestures = false` perto do topo de `~/.config/hypr/hyprland.lua`, antes de os valores predefinidos do Omarchy serem carregados.

Nos portáteis Dell XPS com um touchpad háptico, também pode definir a força do clique para low, mid ou high em _Trigger > Hardware > Touchpad Haptics_.

### Escrever em chinês, japonês e outras línguas

Selecione japonês, coreano, chinês (simplificado, Pinyin), Taiwan (Zhuyin) ou Hong Kong (Cangjie) quando o instalador lhe pedir o teclado. O Omarchy configura automaticamente o teclado e o motor de entrada correspondente, incluindo durante a configuração offline no primeiro arranque. O japonês usa Mozc, o coreano usa o Hangul padrão de dois conjuntos, o chinês simplificado usa Pinyin, Taiwan usa a disposição Zhuyin padrão do Chewing e Hong Kong usa Cangjie com formas de caracteres de Hong Kong. Japonês (teclado US) fornece Mozc com uma disposição de teclado US. As teclas Hangul, Zhuyin e Cangjie mantêm-se nas suas posições padrão mesmo quando escreve letras latinas com Dvorak, Colemak ou AZERTY. Se já tinha adicionado Hangul ou Chewing antes disto, desselecione-o e volte a selecioná-lo em _Setup > Keyboard > Input Methods_ para mover as suas teclas para lá; o Omarchy não mexe num motor com que já escreve.

A escrita começa em modo latino. Prima `Super + I` para percorrer os métodos de entrada configurados e `Super + Shift + I` para percorrer no sentido inverso. Toque em `Shift` sozinho para sair de um método de entrada como Pinyin para letras latinas, e toque novamente para voltar, da forma como funcionam o Sogou, o Microsoft Pinyin e o macOS; `Shift` mais uma letra continua a escrever uma maiúscula. Nos teclados japoneses, 全角/半角 alterna a entrada, 変換 ativa-a e 無変換 desativa-a. Com coreano, 한/영 alterna o Hangul e 한자 converte para Hanja, quer o seu teclado tenha teclas dedicadas quer envie Right Alt e Right Ctrl para elas, como fazem muitos portáteis, pelo que Right Alt e Right Ctrl não são modificadores simples nesse caso; em vez disso, o ditado alterna com Alt + Space. `Ctrl + Space` continua disponível para Tmux e Herdr; `Shift + CapsLock` continua a ser a tecla de composição.

O indicador do teclado aparece à direita da barra quando tem várias disposições de teclado ou métodos de entrada. Clique nele para trocar de línguas de entrada; o japonês mostra あ para hiragana. Para escolher caracteres japoneses, mude para japonês, escreva uma palavra como `nihongo` e depois prima Space duas vezes. Prima Enter para aceitar a sua escolha. Se também tiver várias disposições de teclado, clique com o botão direito no indicador para as percorrer.

Use _Setup > Keyboard > Keyboard Inputs_ para selecionar disposições como inglês e francês, a partir das mesmas escolhas oferecidas durante a instalação. Use _Setup > Keyboard > Input Methods_ para selecionar quais os motores de composição ativos. Ambos os seletores abrem dentro do menu do Omarchy com as suas seleções atuais marcadas. Clique ou prima Enter para alternar uma escolha; cada alteração aplica-se imediatamente. Desselecionar um método de entrada remove-o do ciclo sem o desinstalar; o teclado continua disponível.

Execute `omarchy setup keyboard` ou `omarchy setup input` para abrir os mesmos seletores. Para acrescentar uma língua a partir da linha de comandos, use `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ou `cangjie5`. Quick, Boshiamy e Array vêm no mesmo pacote que Cangjie e aparecem no seletor Input Methods. As suas teclas de troca personalizadas são preservadas. Para disposições ou teclas de motor alternativas, instale `fcitx5-configtool` com `omarchy pkg add fcitx5-configtool` e inicie-o a partir de um terminal. Selecionar uma língua de entrada não altera a língua do ambiente de trabalho. Escolher japonês, coreano ou chinês em _Setup > Language_ adiciona o respetivo método de entrada quando ainda não tem nenhum.

Use `Super + I` para percorrer os métodos de entrada ou as disposições de teclado e `Super + Shift + I` para voltar no sentido contrário, pelo que, com três configurados, pode mover-se entre dois vizinhos. O indicador de entrada aparece à direita da barra apenas quando está configurado mais do que um método de entrada ou disposição. Este atalho do ambiente de trabalho funciona juntamente com as suas teclas de troca Fcitx existentes; pode substituí-lo em `~/.config/hypr/bindings.lua`. Os motores de entrada e as sequências de composição usam o serviço [Fcitx5](https://fcitx-im.org/) já em execução em todas as sessões.

### Utilizar ALT como SUPER

Em alguns teclados, não é conveniente usar a tecla meta principal (tecla Windows/cmd) como SUPER. Pode alterá-la para ser ALT, em vez disso, usando esta alteração:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
