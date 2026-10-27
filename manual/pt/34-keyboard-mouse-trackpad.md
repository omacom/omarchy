# Teclado, Rato, Trackpad

O Hyprland permite-te configurar todas as entradas com grande detalhe. Podes tornar a repetição do teclado supersonicamente rápida ou fazer o trackpad usar a deslocação natural. Alteras tudo em `~/.config/hypr/input.lua`, a que também podes aceder através de _Setup > Input_ no menu do Omarchy (`Super + Space`). Tudo o que definires aí substitui as predefinições do Omarchy.

Segue-se um exemplo:

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

O CapsLock funciona como um Caps Lock normal, e `Shift + CapsLock` é a tecla de composição para [emojis rápidos](07-hotkeys.md#quick-emojis) e [outras completações](07-hotkeys.md#quick-completions). Se preferires ter a tecla de composição noutro sítio, substitui `omarchy:shift_caps_compose` em `kb_options`. Por exemplo, isto move a tecla de composição para Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestos do trackpad

Também podes ativar [gestos do touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), como passar três dedos para mudar de espaços de trabalho:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Nos portáteis Dell XPS com um touchpad háptico, também podes definir a força do clique como baixa, média ou alta em _Trigger > Hardware > Touchpad Haptics_.

### Escrever em chinês, japonês e outras línguas

Seleciona japonês, coreano, chinês (simplificado, Pinyin), Taiwan (Zhuyin) ou Hong Kong (Cangjie) quando o instalador te pedir o teclado. O Omarchy configura automaticamente o teclado e o motor de entrada correspondente, incluindo durante a configuração offline no primeiro arranque. O japonês usa Mozc, o coreano usa o Hangul padrão de dois conjuntos, o chinês simplificado usa Pinyin, Taiwan usa a disposição Zhuyin padrão do Chewing e Hong Kong usa Cangjie com formas de carateres de Hong Kong. Japonês (teclado US) fornece Mozc com uma disposição de teclado US. As teclas de Hangul, Zhuyin e Cangjie mantêm-se nas suas posições padrão mesmo quando escreves letras latinas com Dvorak, Colemak ou AZERTY. Se já tinhas adicionado Hangul ou Chewing antes disto, desmarca-o e volta a marcá-lo em _Setup > Typing > Input Methods_ para mover as respetivas teclas para lá; o Omarchy deixa intacto um motor que já uses para escrever.

A escrita começa em modo latino. Prime `Super + I` para percorrer ciclicamente os métodos de entrada configurados e `Super + Shift + I` para percorrer no sentido inverso. Toca em `Shift` isoladamente para sair de um método de entrada como o Pinyin e passar para letras latinas, e toca outra vez para voltar, tal como funcionam o Sogou, o Microsoft Pinyin e o macOS; `Shift` mais uma letra continua a escrever uma maiúscula. Nos teclados japoneses, 全角/半角 alterna a entrada, 変換 ativa-a e 無変換 desativa-a. Com coreano, 한/영 alterna para Hangul e 한자 converte para Hanja, quer o teu teclado tenha teclas dedicadas quer envie Right Alt e Right Ctrl para esse efeito, como acontece em muitos portáteis, pelo que Right Alt e Right Ctrl não são aí modificadores simples; a função premir-para-falar do ditado mantém-se em F9. `Ctrl + Space` continua disponível para Tmux e Herdr; `Shift + CapsLock` continua a ser a tecla de composição.

O indicador do teclado aparece do lado direito da barra quando tens várias disposições de teclado ou métodos de entrada. Clica nele para mudar de língua de entrada; o japonês mostra あ para hiragana. Para escolheres carateres japoneses, muda para japonês, escreve uma palavra como `nihongo` e depois prime Space duas vezes. Prime Enter para aceitar a tua escolha. Se também tiveres várias disposições de teclado, clica com o botão direito no indicador para as percorrer ciclicamente.

Usa _Setup > Typing > Keyboard Layouts_ para selecionar disposições como inglês e francês, entre as mesmas opções oferecidas durante a instalação. Usa _Setup > Typing > Input Methods_ para selecionar quais os motores de composição que estão ativos. Ambos os seletores abrem dentro do menu do Omarchy com as tuas seleções atuais marcadas. Clica ou prime Enter para ativar ou desativar uma opção; cada alteração aplica-se de imediato. Desmarcar um método de entrada remove-o do ciclo sem o desinstalar; o teclado continua disponível.

Executa `omarchy setup keyboard` ou `omarchy setup input` para abrir os mesmos seletores. Para acrescentar uma língua a partir da linha de comandos, usa `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ou `cangjie5`. Quick, Boshiamy e Array vêm no mesmo pacote que o Cangjie e aparecem no seletor de Input Methods. As tuas teclas personalizadas de mudança são mantidas. Para disposições ou teclas alternativas para os motores, instala `fcitx5-configtool` com `omarchy pkg add fcitx5-configtool` e executa-o a partir de um terminal. Selecionar uma língua de entrada não altera a língua do ambiente de trabalho. Escolher japonês, coreano ou chinês em _Setup > Language_ acrescenta o respetivo método de entrada quando ainda não tiveres nenhum.

Usa `Super + I` para percorrer ciclicamente os métodos de entrada ou as disposições de teclado e `Super + Shift + I` para ir no sentido inverso, por isso, com três configurados, podes mover-te entre dois vizinhos. O indicador de entrada aparece do lado direito da barra apenas quando está configurado mais do que um método de entrada ou disposição. Esta combinação de teclas do ambiente de trabalho funciona em conjunto com as tuas teclas de mudança do Fcitx já existentes; podes substituí-la em `~/.config/hypr/bindings.lua`. Os motores de entrada e as sequências de composição usam o serviço [Fcitx5](https://fcitx-im.org/) que já está a correr em todas as sessões.

### Usar ALT como SUPER

Em alguns teclados, não é prático usar a tecla meta principal (tecla Windows/cmd) como SUPER. Podes alterar isto para passar a ser ALT, com esta alteração:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
