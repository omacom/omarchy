# Teclado, Rato, Painel Tátil

O Hyprland permite-te configurar todas as tuas entradas ao pormenor. Podes tornar a repetição do teclado supersonicamente rápida ou fazer com que o painel tátil use o deslocamento natural. Alteras tudo isso em `~/.config/hypr/input.lua`, a que também podes aceder através de _Setup > Input_ no menu do Omarchy (`Super + Space`). Tudo o que definires aí substitui as predefinições do Omarchy.

Aqui fica um exemplo:

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

Podes [ver todas as opções de introdução](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wiki do Hyprland para entradas.

O CapsLock funciona como um Caps Lock normal, e `Shift + CapsLock` é a tecla de composição para [emojis rápidos](07-hotkeys.md#quick-emojis) e [outras conclusões](07-hotkeys.md#quick-completions). Se preferires ter a tecla de composição noutro sítio, substitui `omarchy:shift_caps_compose` em `kb_options`. Por exemplo, isto move a tecla de composição para Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestos no painel tátil

Desliza no painel tátil para te deslocares pelo ambiente de trabalho:

| Gesto | Ação |
| --- | --- |
| Três dedos para a esquerda / direita | Área de trabalho anterior / seguinte, incluindo as vazias |
| Três dedos para cima | Mostrar/ocultar a consola de IA |
| Três dedos para baixo | Abrir o menu do Omarchy |
| Quatro dedos para a esquerda / direita | Mover a janela ativa para a área de trabalho anterior / seguinte |
| Quatro dedos para baixo | Ativar/desativar o ecrã inteiro |

Para alterares um, desativa-o em `~/.config/hypr/input.lua` antes de adicionares o teu próprio [gesto no painel tátil](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), uma vez que o Hyprland não aceita dois gestos com os mesmos dedos e na mesma direção:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Para desligares todos os gestos do Omarchy, define `omarchy_default_gestures = false` perto do topo de `~/.config/hypr/hyprland.lua`, antes de as predefinições do Omarchy serem carregadas.

Nos portáteis Dell XPS com painel tátil háptico, também podes definir a força do clique como baixa, média ou alta em _Trigger > Hardware > Touchpad Haptics_.

### Escrever em chinês, japonês e noutros idiomas

Seleciona japonês, coreano, chinês (simplificado, Pinyin), Taiwan (Zhuyin) ou Hong Kong (Cangjie) quando o instalador te pedir o teclado. O Omarchy configura automaticamente o teclado e o motor de introdução correspondente, incluindo durante a configuração offline no primeiro arranque. O japonês usa o Mozc, o coreano usa o Hangul padrão de dois conjuntos, o chinês simplificado usa o Pinyin, Taiwan usa a disposição Zhuyin padrão do Chewing e Hong Kong usa o Cangjie com formas de carateres de Hong Kong. Japonês (teclado dos EUA) disponibiliza o Mozc com uma disposição de teclado dos EUA. As teclas do Hangul, do Zhuyin e do Cangjie mantêm-se nas suas posições padrão mesmo quando escreves letras latinas com Dvorak, Colemak ou AZERTY. Se já tinhas adicionado o Hangul ou o Chewing antes disto, desmarca-o e volta a marcá-lo em _Setup > Typing > Input Methods_ para moveres as respetivas teclas para lá; o Omarchy não altera um motor que já uses para escrever.

A escrita começa no modo latino. Prime `Super + I` para percorreres os métodos de introdução configurados e `Super + Shift + I` para percorreres no sentido inverso. Prime `Shift` sozinho para saíres temporariamente de um método de introdução como o Pinyin para as letras latinas e prime-o novamente para voltares, tal como funcionam o Sogou, o Microsoft Pinyin e o macOS; `Shift` mais uma letra continua a escrever uma maiúscula. Nos teclados japoneses, 全角/半角 ativa/desativa a introdução, 変換 ativa-a e 無変換 desativa-a. Com o coreano, 한/영 alterna o Hangul e 한자 converte para Hanja, quer o teu teclado tenha teclas dedicadas, quer envie Right Alt e Right Ctrl para essas funções, como acontece em muitos portáteis, pelo que Right Alt e Right Ctrl não são modificadores simples nesse caso; em vez disso, o ditado ativa-se/desativa-se com Alt + Space. `Ctrl + Space` continua disponível para o Tmux e o Herdr; `Shift + CapsLock` continua a ser a tecla de composição.

O indicador do teclado aparece à direita da barra quando tens várias disposições de teclado ou métodos de introdução. Clica nele para mudares de idioma de introdução; o japonês mostra あ para hiragana. Para escolheres carateres japoneses, muda para japonês, escreve uma palavra como `nihongo` e depois prime Space duas vezes. Prime Enter para aceitares a tua escolha. Se também tiveres várias disposições de teclado, clica com o botão direito no indicador para as percorreres.

Usa _Setup > Typing > Keyboard Layouts_ para selecionares disposições como inglês e francês, a partir das mesmas opções oferecidas durante a instalação. Usa _Setup > Typing > Input Methods_ para selecionares quais os motores de composição ativos. Ambos os seletores se abrem dentro do menu do Omarchy com as tuas seleções atuais assinaladas. Clica ou prime Enter para ativares/desativares uma opção; cada alteração aplica-se imediatamente. Desmarcar um método de introdução remove-o do ciclo sem o desinstalar; o teclado continua disponível.

Executa `omarchy setup keyboard` ou `omarchy setup input` para abrires os mesmos seletores. Para acrescentares um idioma a partir da linha de comandos, usa `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ou `cangjie5`. O Quick, o Boshiamy e o Array vêm no mesmo pacote que o Cangjie e aparecem no seletor Input Methods. As tuas teclas de mudança personalizadas são preservadas. Para disposições ou teclas alternativas do motor, instala `fcitx5-configtool` com `omarchy pkg add fcitx5-configtool` e arranca-o a partir de um terminal. Selecionar um idioma de introdução não altera o idioma do ambiente de trabalho. Escolher japonês, coreano ou chinês em _Setup > Language_ adiciona o respetivo método de introdução quando ainda não tens nenhum.

Usa `Super + I` para percorreres os métodos de introdução ou as disposições de teclado e `Super + Shift + I` para voltares no sentido oposto, pelo que, com três configurados, podes mover-te entre dois vizinhos. O indicador de introdução aparece à direita da barra apenas quando está configurado mais do que um método de introdução ou disposição. Este atalho do ambiente de trabalho funciona em conjunto com as tuas teclas de mudança do Fcitx já existentes; podes substituí-lo em `~/.config/hypr/bindings.lua`. Os motores de introdução e as sequências de composição usam o serviço [Fcitx5](https://fcitx-im.org/) que já está a correr em todas as sessões.

### Usar ALT como SUPER

Em alguns teclados, não dá jeito usar a tecla meta principal (tecla Windows/cmd) como SUPER. Podes alterá-la para ser ALT, em vez disso, com esta alteração:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
