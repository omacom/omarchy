# Teclado, Rato, Trackpad

O Hyprland permite configurar todos os dispositivos de entrada ao pormenor. Pode deixar a repetição do teclado supersonicamente rápida ou fazer o trackpad utilizar o deslocamento natural. Altera tudo em `~/.config/hypr/input.lua`, ao qual também pode aceder através de _Setup > Input_ no menu do Omarchy (`Super + Space`). Tudo o que definir ali substitui as predefinições do Omarchy.

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

Pode [ver todas as opções de entrada](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wiki do Hyprland para as entradas.

O CapsLock funciona como um Caps Lock normal, e `Shift + CapsLock` é a tecla de composição para [emojis rápidos](07-hotkeys.md#quick-emojis) e [outros completamentos](07-hotkeys.md#quick-completions). Se preferir colocar a tecla de composição noutro sítio, substitua `omarchy:shift_caps_compose` em `kb_options`. Por exemplo, isto desloca a tecla de composição para o Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Teclas de função

A fila superior de um teclado de portátil envia as teclas multimédia (volume, brilho e assim por diante) por predefinição, e manter `Fn` premido dá acesso a F1-F12; `Fn + Esc` bloqueia no sentido inverso até voltar a premi-lo. A maior parte dos teclados lembra-se desse bloqueio por si própria. Os portáteis ASUS e os teclados de estilo Apple deixam isso a cargo do Linux, que os inicia nas teclas multimédia a cada arranque. Para que comecem antes em F1-F12, execute `omarchy device keyboard toprow fnkeys` (e `omarchy device keyboard toprow mediakeys` para voltar atrás); em alguns portáteis, a alteração só produz efeito depois de reiniciar. Os Macs com Apple Silicon mantêm a sua própria definição.

### Gestos do trackpad

Deslize no trackpad para se deslocar pelo ambiente de trabalho:

| Gesto | Ação |
| --- | --- |
| Três dedos para a esquerda / direita | Espaço de trabalho anterior / seguinte, incluindo os vazios |
| Três dedos para cima | Alternar a consola de IA |
| Três dedos para baixo | Abrir o menu do Omarchy |
| Quatro dedos para a esquerda / direita | Mover a janela ativa para o espaço de trabalho anterior / seguinte |
| Quatro dedos para baixo | Alternar o ecrã inteiro |

Para alterar um gesto, anule-o em `~/.config/hypr/input.lua` antes de adicionar o seu próprio [gesto do touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), uma vez que o Hyprland não aceita dois gestos com os mesmos dedos e a mesma direção:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Para desligar todos os gestos do Omarchy, defina `omarchy_default_gestures = false` perto do topo de `~/.config/hypr/hyprland.lua`, antes de as predefinições do Omarchy serem carregadas.

Nos portáteis Dell XPS com um touchpad háptico, também pode definir a força do clique como baixa, média ou alta em _Trigger > Hardware > Touchpad Haptics_.

### Escrever em chinês, japonês e outras línguas

Selecione japonês, coreano, chinês (simplificado, Pinyin), Taiwan (Zhuyin) ou Hong Kong (Cangjie) quando o instalador lhe pedir o teclado. O Omarchy configura automaticamente o teclado e o motor de entrada correspondente, incluindo durante a configuração offline no primeiro arranque. O japonês utiliza o Mozc, o coreano utiliza o Hangul padrão de dois conjuntos, o chinês simplificado utiliza o Pinyin, Taiwan utiliza a disposição Zhuyin padrão do Chewing e Hong Kong utiliza o Cangjie com formas de caracteres de Hong Kong. Japonês (teclado US) fornece o Mozc com uma disposição de teclado US. As teclas de Hangul, Zhuyin e Cangjie mantêm as suas posições padrão mesmo quando escreve letras latinas com Dvorak, Colemak ou AZERTY. Se já tinha adicionado o Hangul ou o Chewing antes disto, desselecione-o e volte a selecioná-lo em _Setup > Keyboard > Input Methods_ para deslocar as respectivas teclas para lá; o Omarchy não mexe num motor que já esteja a utilizar para escrever.

A escrita começa em modo latino. Prima `Super + I` para percorrer os métodos de entrada configurados e `Super + Shift + I` para percorrer no sentido inverso. Toque em `Shift` sozinho para sair de um método de entrada como o Pinyin e passar para letras latinas, e toque novamente para voltar, tal como funcionam o Sogou, o Microsoft Pinyin e o macOS; `Shift` mais uma letra continua a escrever uma maiúscula. Nos teclados japoneses, 全角/半角 alterna a entrada, 変換 ativa-a e 無変換 desativa-a. Com o coreano, 한/영 alterna para Hangul e 한자 converte para Hanja, quer o teclado tenha teclas dedicadas, quer envie Right Alt e Right Ctrl para esse efeito, como acontece em muitos portáteis, pelo que o Right Alt e o Right Ctrl não são modificadores simples nesse caso; em vez disso, o ditado alterna com Alt + Space. `Ctrl + Space` continua disponível para o Tmux e o Herdr; `Shift + CapsLock` continua a ser a tecla de composição.

O indicador de teclado aparece à direita da barra quando tem várias disposições de teclado ou métodos de entrada. Clique nele para alternar entre línguas de entrada; o japonês mostra あ para hiragana. Para escolhas de caracteres japoneses, mude para japonês, escreva uma palavra como `nihongo` e, em seguida, prima Space duas vezes. Prima Enter para aceitar a sua escolha. Se também tiver várias disposições de teclado, clique com o botão direito no indicador para as percorrer.

Utilize _Setup > Keyboard > Keyboard Inputs_ para selecionar disposições como inglês e francês, a partir das mesmas opções apresentadas durante a instalação. Utilize _Setup > Keyboard > Input Methods_ para selecionar quais os motores de composição ativos. Ambos os seletores se abrem dentro do menu do Omarchy, com as suas seleções atuais assinaladas. Clique ou prima Enter para ativar ou desativar uma opção; cada alteração é aplicada de imediato. Desselecionar um método de entrada remove-o do ciclo sem o desinstalar; o teclado continua disponível.

Execute `omarchy setup keyboard` ou `omarchy setup input` para abrir os mesmos seletores. Para acrescentar uma língua a partir da linha de comandos, utilize `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ou `cangjie5`. Quick, Boshiamy e Array vêm no mesmo pacote que o Cangjie e aparecem no seletor Input Methods. As suas teclas personalizadas de alternância são preservadas. Para disposições ou teclas alternativas dos motores, instale o `fcitx5-configtool` com `omarchy pkg add fcitx5-configtool` e inicie-o a partir de um terminal. Selecionar uma língua de entrada não altera a língua do ambiente de trabalho. Escolher japonês, coreano ou chinês em _Setup > Region > Language_ acrescenta o respectivo método de entrada quando ainda não tem nenhum.

Utilize `Super + I` para percorrer os métodos de entrada ou as disposições de teclado, e `Super + Shift + I` para voltar no sentido contrário, pelo que, com três configurados, pode deslocar-se entre dois vizinhos. O indicador de entrada aparece à direita da barra apenas quando está configurado mais do que um método de entrada ou disposição. Esta combinação de teclas do ambiente de trabalho funciona em conjunto com as suas teclas de alternância Fcitx já existentes; pode substituí-la em `~/.config/hypr/bindings.lua`. Os motores de entrada e as sequências de composição utilizam o serviço [Fcitx5](https://fcitx-im.org/) que já está a ser executado em todas as sessões.

### Utilizar ALT como SUPER

Em alguns teclados, não é conveniente utilizar a tecla meta principal (tecla Windows/cmd) como SUPER. Pode alterar isto para ALT em alternativa, utilizando esta alteração:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
