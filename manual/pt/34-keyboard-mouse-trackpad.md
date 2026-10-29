# Teclado, Rato, Trackpad

O Hyprland permite configurar todas as entradas com grande detalhe. Pode tornar a repetição do teclado supersónica ou fazer com que o trackpad use a deslocação natural. Altera tudo em `~/.config/hypr/input.lua`, que também pode abrir através de _Setup > Input_ no menu do Omarchy (`Super + Space`). Tudo o que definir aí substitui as predefinições do Omarchy.

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

A CapsLock funciona como uma Caps Lock normal, e `Shift + CapsLock` é a tecla de composição para [emojis rápidos](07-hotkeys.md#quick-emojis) e [outros completamentos](07-hotkeys.md#quick-completions). Se preferir ter a tecla de composição noutro lugar, substitua `omarchy:shift_caps_compose` em `kb_options`. Por exemplo, isto move a tecla de composição para Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestos do trackpad

Deslize no trackpad para se mover pelo ambiente de trabalho:

| Gesto | Ação |
| --- | --- |
| Três dedos para a esquerda / para a direita | Área de trabalho anterior / seguinte, incluindo as vazias |
| Três dedos para cima | Alternar a consola de IA |
| Três dedos para baixo | Abrir o menu do Omarchy |
| Quatro dedos para a esquerda / para a direita | Mover a janela ativa para a área de trabalho anterior / seguinte |
| Quatro dedos para baixo | Alternar o ecrã inteiro |

Para alterar um gesto, desative-o em `~/.config/hypr/input.lua` antes de adicionar o seu próprio [gesto do trackpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), uma vez que o Hyprland não aceita dois gestos com os mesmos dedos e na mesma direção:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Para desligar todos os gestos do Omarchy, defina `omarchy_default_gestures = false` perto do topo de `~/.config/hypr/hyprland.lua`, antes de serem carregadas as predefinições do Omarchy.

Nos portáteis Dell XPS com um touchpad háptico, também pode definir a força do clique como baixa, média ou alta em _Trigger > Hardware > Touchpad Haptics_.

### Escrever em chinês, japonês e outras línguas

Selecione japonês, coreano, chinês (simplificado, Pinyin), Taiwan (Zhuyin) ou Hong Kong (Cangjie) quando o instalador lhe pedir o teclado. O Omarchy configura automaticamente o teclado e o motor de entrada correspondente, incluindo durante a configuração offline no primeiro arranque. O japonês usa Mozc, o coreano usa Hangul padrão de dois conjuntos, o chinês simplificado usa Pinyin, Taiwan usa a disposição Zhuyin padrão do Chewing e Hong Kong usa Cangjie com formas de caracteres de Hong Kong. Japonês (teclado dos EUA) fornece Mozc com uma disposição de teclado dos EUA. As teclas Hangul, Zhuyin e Cangjie mantêm-se nas suas posições padrão mesmo quando escreve letras latinas com Dvorak, Colemak ou AZERTY. Se já tinha adicionado Hangul ou Chewing anteriormente, desmarque-o e volte a marcá-lo em _Setup > Typing > Input Methods_ para mover as suas teclas para lá; o Omarchy não mexe num motor com o qual já escreve.

A escrita começa em modo latino. Prima `Super + I` para percorrer os métodos de entrada configurados e `Super + Shift + I` para percorrer no sentido inverso. Toque em `Shift` isoladamente para sair de um método de entrada como o Pinyin para as letras latinas e toque novamente para voltar, tal como funcionam o Sogou, o Microsoft Pinyin e o macOS; `Shift` mais uma letra continua a escrever uma maiúscula. Nos teclados japoneses, 全角/半角 alterna a entrada, 変換 liga-a e 無変換 desliga-a. Com o coreano, 한/영 alterna Hangul e 한자 converte para Hanja, quer o teclado tenha teclas dedicadas quer envie Right Alt e Right Ctrl para esse efeito, como fazem muitos portáteis, pelo que Right Alt e Right Ctrl não são modificadores simples nesse caso; o premir para falar do ditado mantém-se em F9. `Ctrl + Space` mantém-se disponível para o Tmux e o Herdr; `Shift + CapsLock` mantém-se como a tecla de composição.

O indicador de teclado aparece à direita da barra quando tem várias disposições de teclado ou vários métodos de entrada. Clique nele para trocar de língua de entrada; o japonês mostra あ para hiragana. Para as escolhas de caracteres japoneses, mude para japonês, escreva uma palavra como `nihongo` e, em seguida, prima Space duas vezes. Prima Enter para aceitar a escolha. Se também tiver várias disposições de teclado, clique com o botão direito no indicador para as percorrer.

Use _Setup > Typing > Keyboard Layouts_ para selecionar disposições como inglês e francês, a partir das mesmas escolhas oferecidas durante a instalação. Use _Setup > Typing > Input Methods_ para selecionar que motores de composição estão ativos. Ambos os seletores abrem dentro do menu do Omarchy com as suas seleções atuais marcadas. Clique ou prima Enter para alternar uma escolha; cada alteração aplica-se imediatamente. Desmarcar um método de entrada remove-o do ciclo sem o desinstalar; o teclado continua disponível.

Execute `omarchy setup keyboard` ou `omarchy setup input` para abrir os mesmos seletores. Para acrescentar uma língua a partir da linha de comandos, use `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ou `cangjie5`. Quick, Boshiamy e Array vêm no mesmo pacote que o Cangjie e aparecem no seletor Input Methods. As suas teclas de alternância personalizadas são preservadas. Para disposições ou teclas alternativas para os motores, instale `fcitx5-configtool` com `omarchy pkg add fcitx5-configtool` e inicie-o a partir de um terminal. Selecionar uma língua de entrada não altera a língua do ambiente de trabalho. Escolher japonês, coreano ou chinês em _Setup > Language_ acrescenta o respetivo método de entrada quando ainda não tem nenhum.

Use `Super + I` para percorrer os métodos de entrada ou as disposições de teclado e `Super + Shift + I` para voltar no sentido oposto, pelo que, com três configurados, pode mover-se entre dois vizinhos. O indicador de entrada aparece à direita da barra apenas quando está configurado mais do que um método de entrada ou uma disposição. Este atalho do ambiente de trabalho funciona em conjunto com as suas teclas de alternância do Fcitx já existentes; pode substituí-lo em `~/.config/hypr/bindings.lua`. Os motores de entrada e as sequências de composição usam o serviço [Fcitx5](https://fcitx-im.org/) que já está a ser executado em todas as sessões.

### Usar ALT como SUPER

Em alguns teclados, não é prático usar a tecla meta principal (tecla Windows/cmd) como SUPER. Pode alterá-la para ALT em vez disso com esta alteração:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
