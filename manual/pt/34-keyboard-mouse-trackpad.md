# Teclado, Rato, Trackpad

O Hyprland permite-lhe configurar todas as entradas em grande detalhe. Pode tornar a repetição do teclado supersonicamente rápida ou fazer o trackpad usar a deslocação natural. Altera tudo em `~/.config/hypr/input.lua`, a que também pode aceder através de _Configuração > Entrada_ no menu do Omarchy (`Super + Space`). Tudo o que definir aí substitui as predefinições do Omarchy.

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

Pode [ver todas as opções de entrada](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wiki do Hyprland para entradas.

O CapsLock funciona como um Caps Lock normal, e `Shift + CapsLock` é a tecla compose para [emojis rápidos](07-hotkeys.md#quick-emojis) e [outros completamentos](07-hotkeys.md#quick-completions). Se preferir ter a tecla compose noutro local, substitua `omarchy:shift_caps_compose` em `kb_options`. Por exemplo, isto move a tecla compose para Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Teclas de função

A linha superior de um teclado de portátil envia as teclas multimédia (volume, brilho e assim por diante) por predefinição, e manter premido `Fn` dá F1-F12; `Fn + Esc` bloqueia-o no sentido inverso até o premir novamente. A maioria dos teclados lembra-se desse bloqueio por si só. Os portáteis ASUS e os teclados de estilo Apple deixam isso para o Linux, que os inicia com as teclas multimédia em cada arranque. Para que iniciem com F1-F12 em vez disso, execute `omarchy device keyboard toprow fnkeys` (e `omarchy device keyboard toprow mediakeys` para voltar); em alguns portáteis, só produz efeito após um reinício. Os Macs com Apple Silicon mantêm a sua própria definição.

### Gestos do trackpad

Deslize no trackpad para se mover pelo ambiente de trabalho:

| Gesto | Ação |
| --- | --- |
| Três dedos para a esquerda / direita | Espaço de trabalho anterior / seguinte, incluindo os vazios |
| Três dedos para cima | Alternar a consola de IA |
| Três dedos para baixo | Abrir o menu do Omarchy |
| Quatro dedos para a esquerda / direita | Mover a janela ativa para o espaço de trabalho anterior / seguinte |
| Quatro dedos para baixo | Alternar o ecrã inteiro |

Para alterar um, anule-o em `~/.config/hypr/input.lua` antes de adicionar o seu próprio [gesto do touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), uma vez que o Hyprland não aceitará dois gestos com os mesmos dedos e a mesma direção:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Para desligar todos os gestos do Omarchy, defina `omarchy_default_gestures = false` perto do topo de `~/.config/hypr/hyprland.lua`, antes de as predefinições do Omarchy serem carregadas.

Nos portáteis Dell XPS com um touchpad háptico, também pode definir a força do clique para low, mid ou high em _Trigger > Hardware > Touchpad Haptics_.

### Escrever em chinês, japonês e outras línguas

Selecione japonês, coreano, chinês (simplificado, Pinyin), Taiwan (Zhuyin) ou Hong Kong (Cangjie) quando o instalador lhe pedir o teclado. O Omarchy configura o teclado e o motor de entrada correspondente automaticamente, incluindo durante a configuração offline no primeiro arranque. O japonês usa Mozc, o coreano usa o Hangul habitual de dois conjuntos, o chinês simplificado usa Pinyin, Taiwan usa a disposição Zhuyin habitual do Chewing e Hong Kong usa Cangjie com formas de caracteres de Hong Kong. Japonês (teclado US) fornece Mozc com uma disposição de teclado US. As teclas de Hangul, Zhuyin e Cangjie mantêm-se nas suas posições habituais mesmo quando está a escrever letras latinas com Dvorak, Colemak ou AZERTY. Se adicionou Hangul ou Chewing antes disto, desselecione e volte a selecionar em _Configuração > Teclado > Métodos de Entrada_ para mover as respetivas teclas para lá; o Omarchy não mexe num motor com que já esteja a escrever.

A escrita começa em modo latino. Prima `Super + I` para percorrer ciclicamente os métodos de entrada configurados, e `Super + Shift + I` para percorrer no sentido inverso. Toque em `Shift` isoladamente para sair de um método de entrada como o Pinyin para letras latinas, e toque novamente para voltar, da forma como o Sogou, o Microsoft Pinyin e o macOS funcionam; `Shift` mais uma letra continua a escrever uma maiúscula. Nos teclados japoneses, 全角/半角 alterna a entrada, 変換 ativa-a e 無変換 desativa-a. Com o coreano, 한/영 alterna o Hangul e 한자 converte para Hanja, quer o seu teclado tenha teclas dedicadas quer envie Right Alt e Right Ctrl para elas, como muitos portáteis fazem, por isso Right Alt e Right Ctrl não são modificadores simples aí; o ditado alterna com Alt + Space em vez disso. `Ctrl + Space` continua disponível para Tmux e Herdr; `Shift + CapsLock` continua a ser a tecla compose.

O indicador do teclado aparece à direita da barra quando tem vários esquemas de teclado ou métodos de entrada. Clique nele para alternar as línguas de entrada; o japonês mostra あ para hiragana. Para escolhas de caracteres japoneses, mude para japonês, escreva uma palavra como `nihongo` e, em seguida, prima Space duas vezes. Prima Enter para aceitar a sua escolha. Se também tiver vários esquemas de teclado, clique com o botão direito no indicador para os percorrer ciclicamente.

Utilize _Configuração > Teclado > Entradas de Teclado_ para selecionar disposições como inglês e francês, a partir das mesmas escolhas oferecidas durante a instalação. Utilize _Configuração > Teclado > Métodos de Entrada_ para selecionar que motores de composição estão ativos. Ambos os seletores abrem dentro do menu do Omarchy com as suas seleções atuais assinaladas. Clique ou prima Enter para alternar uma escolha; cada alteração aplica-se imediatamente. Desselecionar um método de entrada remove-o do ciclo sem o desinstalar; o teclado continua disponível.

Execute `omarchy setup keyboard` ou `omarchy setup input` para abrir os mesmos seletores. Para acrescentar uma língua a partir da linha de comandos, utilize `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ou `cangjie5`. Quick, Boshiamy e Array vêm no mesmo pacote que o Cangjie e aparecem no seletor Métodos de Entrada. As suas teclas de alternância personalizadas são preservadas. Para disposições ou teclas alternativas para o motor, instale `fcitx5-configtool` com `omarchy pkg add fcitx5-configtool` e inicie-o a partir de um terminal. Selecionar uma língua de entrada não altera a língua do ambiente de trabalho. Escolher japonês, coreano ou chinês em _Configuração > Língua_ adiciona o respetivo método de entrada quando ainda não tem nenhum.

Utilize `Super + I` para percorrer ciclicamente os métodos de entrada ou as disposições de teclado, e `Super + Shift + I` para voltar no sentido inverso, por isso, com três configurados, pode mover-se entre dois vizinhos. O indicador de entrada aparece à direita da barra apenas quando está configurado mais do que um método de entrada ou disposição. Esta tecla de atalho do ambiente de trabalho funciona juntamente com as suas teclas de alternância do Fcitx já existentes; pode substituí-la em `~/.config/hypr/bindings.lua`. Os motores de entrada e as sequências compose utilizam o serviço [Fcitx5](https://fcitx-im.org/) já em execução em cada sessão.

### Usar ALT como SUPER

Em alguns teclados, não é prático usar a tecla meta principal (tecla Windows/cmd) como SUPER. Pode alterar isto para ser ALT em vez disso, usando esta alteração:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
