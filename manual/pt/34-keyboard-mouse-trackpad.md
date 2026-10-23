# Teclado, rato, painel tátil

O Hyprland permite-te configurar todas as tuas entradas com grande detalhe. Podes tornar a repetição do teclado supersonicamente rápida ou fazer o painel tátil usar deslocamento natural. Alteras tudo isso em `~/.config/hypr/input.lua`, a que também podes chegar através de _Configurar > Entrada_ no menu Omarchy (`Super + Space`). Tudo o que definires aí substitui as predefinições do Omarchy.

Eis um exemplo:

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

Podes [ver todas as opções de entrada](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wiki do Hyprland para entradas.

O CapsLock funciona como um Caps Lock normal, e `Shift + CapsLock` é a tecla de composição para [emoji rápidos](07-hotkeys.md#quick-emojis) e [outros preenchimentos](07-hotkeys.md#quick-completions). Se preferires ter a tecla de composição noutro sítio, substitui `omarchy:shift_caps_compose` em `kb_options`. Por exemplo, isto move a tecla de composição para o Alt direito:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestos do painel tátil

Também podes ativar [gestos do painel tátil](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), como deslizar com três dedos para mudar de área de trabalho:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Em portáteis Dell XPS com painel tátil háptico, também podes definir a força do clique como baixa, média ou alta em _Acionar > Hardware > Vibração tátil_.

### Escrever em chinês, japonês e outras línguas

Seleciona japonês, coreano, chinês (simplificado, Pinyin) ou chinês (tradicional, Zhuyin) quando o instalador te pedir o teclado. O Omarchy configura automaticamente o teclado e o motor de entrada correspondente, incluindo durante a configuração offline no primeiro arranque. O japonês usa o Mozc, o coreano usa o Hangul normal de dois conjuntos, o chinês simplificado usa o Pinyin e o chinês tradicional usa a disposição Zhuyin normal do Chewing. O japonês (teclado EUA) fornece o Mozc com um esquema de teclado EUA.

A escrita começa em modo latino. Carrega em `Super + I` para percorreres os métodos de entrada configurados e em `Super + Shift + I` para percorreres para trás. Toca em `Shift` sozinho para saíres de um método de entrada como o Pinyin para letras latinas, e toca outra vez para voltares, da forma como o Sogou, o Microsoft Pinyin e o macOS funcionam; `Shift` mais uma letra continua a escrever uma maiúscula. Em teclados japoneses, 全角/半角 alterna a entrada, 変換 liga-a e 無変換 desliga-a. Num esquema de teclado coreano, as teclas dedicadas 한/영 e 한자 alternam o Hangul e convertem para Hanja. O `Ctrl + Space` continua disponível para o Tmux e o Herdr; o `Shift + CapsLock` continua a ser a tecla de composição.

O indicador de teclado aparece à direita da barra quando tens vários esquemas de teclado ou métodos de entrada. Clica nele para mudares de língua de entrada; o japonês apresenta あ para hiragana. Para escolhas de carateres japoneses, muda para japonês, escreve uma palavra como `nihongo` e depois carrega duas vezes em Space. Carrega em Enter para aceitares a tua escolha. Se também tiveres vários esquemas de teclado, clica com o botão direito no indicador para os percorreres.

Usa _Configurar > Escrita > Esquemas de teclado_ para selecionares esquemas como inglês e francês, a partir das mesmas escolhas oferecidas durante a instalação. Usa _Configurar > Escrita > Métodos de entrada_ para selecionares quais os motores de composição que estão ativos. Ambos os seletores abrem dentro do menu Omarchy com as tuas seleções atuais assinaladas. Clica ou carrega em Enter para alternares uma escolha; cada alteração aplica-se de imediato. Desmarcar um método de entrada remove-o do ciclo sem o desinstalar; o teclado continua disponível.

Executa `omarchy setup keyboard` ou `omarchy setup input` para abrires os mesmos seletores. Para acrescentares uma língua a partir da linha de comandos, usa `omarchy setup input mozc`, `hangul`, `pinyin` ou `chewing`. As tuas teclas de alternância personalizadas são preservadas. Para esquemas ou teclas de motor alternativos, instala o `fcitx5-configtool` com `omarchy pkg add fcitx5-configtool` e inicia-o a partir de um terminal. Selecionar uma língua de entrada não altera a língua do ambiente de trabalho.

Usa `Super + I` para percorreres métodos de entrada ou esquemas de teclado, e `Super + Shift + I` para ires no outro sentido, por isso, com três configurados, podes mover-te entre dois vizinhos. O indicador de entrada aparece à direita da barra apenas quando está configurado mais do que um método de entrada ou esquema. Esta associação do ambiente de trabalho funciona a par das tuas teclas de alternância Fcitx existentes; podes substituí-la em `~/.config/hypr/bindings.lua`. Os motores de entrada e as sequências de composição usam o serviço [Fcitx5](https://fcitx-im.org/) que já corre em todas as sessões.

### Usar ALT como SUPER

Em alguns teclados, não é conveniente usar a tecla meta principal (tecla Windows/cmd) como SUPER. Podes mudar isto para ser antes o ALT usando esta alteração:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
