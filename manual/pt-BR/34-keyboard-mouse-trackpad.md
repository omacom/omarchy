# Teclado, Mouse, Trackpad

O Hyprland permite configurar todas as suas entradas em grande detalhe. Você pode deixar a repetição do teclado supersonicamente rápida ou fazer o trackpad usar rolagem natural. Você altera tudo isso em `~/.config/hypr/input.lua`, que também pode ser acessado via _Setup > Input_ no menu do Omarchy (`Super + Space`). Qualquer coisa que você definir ali substitui os padrões do Omarchy.

Veja um exemplo:

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

Você pode [ver todas as opções de entrada](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wiki do Hyprland para entradas.

CapsLock funciona como um Caps Lock normal, e `Shift + CapsLock` é a tecla compose para [emojis rápidos](07-hotkeys.md#quick-emojis) e [outros preenchimentos](07-hotkeys.md#quick-completions). Se você preferir colocar a tecla compose em outro lugar, substitua `omarchy:shift_caps_compose` em `kb_options`. Por exemplo, isto move a tecla compose para Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Teclas de função

A fileira superior de um teclado de laptop envia as teclas de mídia (volume, brilho e assim por diante) por padrão, e segurar `Fn` oferece F1-F12; `Fn + Esc` trava isso do outro modo até você pressioná-lo novamente. A maioria dos teclados lembra essa trava por conta própria. Laptops ASUS e teclados estilo Apple deixam isso para o Linux, que os inicia nas teclas de mídia a cada inicialização. Para que eles iniciem em F1-F12, execute `omarchy keyboard toprow fnkeys` (e `omarchy keyboard toprow mediakeys` para voltar); em alguns laptops, isso entra em vigor após uma reinicialização. Macs com Apple Silicon mantêm sua própria configuração.

### Gestos do trackpad

Deslize no trackpad para se mover pela área de trabalho:

| Gesto | Ação |
| --- | --- |
| Três dedos para a esquerda / direita | Workspace anterior / próximo, incluindo os vazios |
| Três dedos para cima | Alternar o console de IA |
| Três dedos para baixo | Abrir o menu do Omarchy |
| Quatro dedos para a esquerda / direita | Mover a janela ativa para o workspace anterior / próximo |
| Quatro dedos para baixo | Alternar tela cheia |

Para alterar um deles, desfaça-o em `~/.config/hypr/input.lua` antes de adicionar o seu próprio [gesto do touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), já que o Hyprland não aceita dois gestos com os mesmos dedos e direção:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Para desativar todos os gestos do Omarchy, defina `omarchy_default_gestures = false` perto do topo de `~/.config/hypr/hyprland.lua`, antes que os padrões do Omarchy sejam carregados.

Em laptops Dell XPS com touchpad háptico, você também pode definir a intensidade do clique como baixa, média ou alta em _Trigger > Hardware > Touchpad Haptics_.

### Digitando em chinês, japonês e outros idiomas

Selecione japonês, coreano, chinês (simplificado, Pinyin), Taiwan (Zhuyin) ou Hong Kong (Cangjie) quando o instalador perguntar sobre o seu teclado. O Omarchy configura o teclado e o mecanismo de entrada correspondente automaticamente, inclusive durante a configuração offline da primeira inicialização. O japonês usa Mozc, o coreano usa o Hangul padrão de dois conjuntos, o chinês simplificado usa Pinyin, Taiwan usa o arranjo Zhuyin padrão do Chewing e Hong Kong usa Cangjie com formas de caracteres de Hong Kong. Japonês (teclado US) oferece Mozc com um layout de teclado US. As teclas Hangul, Zhuyin e Cangjie permanecem em suas posições padrão mesmo quando você digita letras latinas com Dvorak, Colemak ou AZERTY. Se você adicionou Hangul ou Chewing antes disso, desmarque e selecione novamente em _Setup > Keyboard > Input Methods_ para mover suas teclas para lá; o Omarchy não mexe em um mecanismo que você já usa para digitar.

A digitação começa no modo latino. Pressione `Super + I` para percorrer os métodos de entrada configurados, e `Super + Shift + I` para percorrer no sentido contrário. Toque em `Shift` sozinho para sair de um método de entrada como o Pinyin para letras latinas, e toque nele novamente para voltar, do jeito que Sogou, Microsoft Pinyin e macOS funcionam; `Shift` mais uma letra continua digitando uma maiúscula. Em teclados japoneses, 全角/半角 alterna a entrada, 変換 a ativa, e 無変換 a desativa. Com o coreano, 한/영 alterna o Hangul e 한자 converte para Hanja, independentemente de o seu teclado ter teclas dedicadas ou enviar Right Alt e Right Ctrl para isso, como muitos laptops fazem, portanto Right Alt e Right Ctrl não são modificadores simples ali; o ditado alterna com Alt + Space. `Ctrl + Space` continua disponível para Tmux e Herdr; `Shift + CapsLock` continua sendo a tecla compose.

O indicador de teclado aparece à direita da barra quando você tem vários layouts de teclado ou métodos de entrada. Clique nele para alternar os idiomas de entrada; o japonês exibe あ para hiragana. Para escolhas de caracteres japoneses, mude para japonês, digite uma palavra como `nihongo` e pressione Space duas vezes. Pressione Enter para aceitar sua escolha. Se você também tiver vários layouts de teclado, clique com o botão direito no indicador para alternar entre eles.

Use _Setup > Keyboard > Keyboard Inputs_ para selecionar layouts como inglês e francês, a partir das mesmas escolhas oferecidas durante a instalação. Use _Setup > Keyboard > Input Methods_ para selecionar quais mecanismos de composição estão ativos. Ambos os seletores abrem dentro do menu do Omarchy com suas seleções atuais marcadas. Clique ou pressione Enter para alternar uma escolha; cada alteração é aplicada imediatamente. Desmarcar um método de entrada o remove do ciclo sem desinstalá-lo; o teclado permanece disponível.

Execute `omarchy setup keyboard` ou `omarchy setup input` para abrir os mesmos seletores. Para acrescentar um idioma a partir da linha de comando, use `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ou `cangjie5`. Quick, Boshiamy e Array vêm no mesmo pacote que Cangjie e aparecem no seletor Input Methods. Suas teclas personalizadas de alternância são preservadas. Para layouts ou teclas alternativos de mecanismo, instale `fcitx5-configtool` com `omarchy pkg add fcitx5-configtool` e inicie-o a partir de um terminal. Selecionar um idioma de entrada não altera o idioma da área de trabalho. Escolher japonês, coreano ou chinês em _Setup > Language_ adiciona seu método de entrada quando você ainda não tem nenhum.

Use `Super + I` para percorrer métodos de entrada ou layouts de teclado, e `Super + Shift + I` para voltar no outro sentido, assim, com três configurados, você pode se mover entre dois vizinhos. O indicador de entrada aparece à direita da barra apenas quando mais de um método de entrada ou layout está configurado. Este atalho da área de trabalho funciona junto com suas teclas existentes de alternância do Fcitx; você pode substituí-lo em `~/.config/hypr/bindings.lua`. Os mecanismos de entrada e as sequências compose usam o serviço [Fcitx5](https://fcitx-im.org/) já em execução em todas as sessões.

### Usar ALT como SUPER

Em alguns teclados, não é conveniente usar a tecla meta primária (tecla Windows/cmd) como SUPER. Você pode alterar isso para ser ALT em vez disso usando esta alteração:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
