# Teclado, Mouse, Trackpad

O Hyprland permite configurar todas as suas entradas nos mínimos detalhes. Você pode deixar a repetição do teclado supersonicamente rápida ou fazer o trackpad usar a rolagem natural. Você altera tudo isso em `~/.config/hypr/input.lua`, que também pode ser acessado via _Setup > Input_ no menu do Omarchy (`Super + Space`). Qualquer coisa que você definir ali substitui os padrões do Omarchy.

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

Você pode [ver todas as opções de entrada](https://wiki.hypr.land/Configuring/Basics/Variables/#input) no wiki do Hyprland para entradas.

O CapsLock funciona como um Caps Lock normal, e `Shift + CapsLock` é a tecla de composição para [emojis rápidos](07-hotkeys.md#quick-emojis) e [outras completações](07-hotkeys.md#quick-completions). Se você preferir colocar a tecla de composição em outro lugar, substitua `omarchy:shift_caps_compose` em `kb_options`. Por exemplo, isto move a tecla de composição para o Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestos do trackpad

Deslize no trackpad para se mover pela área de trabalho:

| Gesto | Ação |
| --- | --- |
| Três dedos para a esquerda / direita | Workspace anterior / próximo, incluindo os vazios |
| Três dedos para cima | Alternar o console de IA |
| Três dedos para baixo | Abrir o menu do Omarchy |
| Quatro dedos para a esquerda / direita | Mover a janela ativa para o workspace anterior / próximo |
| Quatro dedos para baixo | Alternar a tela cheia |

Para alterar um deles, desative-o em `~/.config/hypr/input.lua` antes de adicionar seu próprio [gesto do touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), já que o Hyprland não aceita dois gestos com os mesmos dedos e na mesma direção:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Para desligar todos os gestos do Omarchy, defina `omarchy_default_gestures = false` perto do topo de `~/.config/hypr/hyprland.lua`, antes que os padrões do Omarchy sejam carregados.

Em laptops Dell XPS com touchpad háptico, você também pode definir a força do clique como baixa, média ou alta em _Trigger > Hardware > Touchpad Haptics_.

### Digitando em chinês, japonês e outros idiomas

Selecione japonês, coreano, chinês (simplificado, Pinyin), Taiwan (Zhuyin) ou Hong Kong (Cangjie) quando o instalador perguntar sobre o seu teclado. O Omarchy configura o teclado e o mecanismo de entrada correspondente automaticamente, inclusive durante a configuração offline da primeira inicialização. O japonês usa Mozc, o coreano usa o Hangul padrão de dois conjuntos, o chinês simplificado usa Pinyin, Taiwan usa o arranjo Zhuyin padrão do Chewing, e Hong Kong usa Cangjie com formas de caracteres de Hong Kong. Japonês (teclado US) fornece Mozc com um layout de teclado US. As teclas de Hangul, Zhuyin e Cangjie permanecem em suas posições padrão mesmo quando você digita letras latinas com Dvorak, Colemak ou AZERTY. Se você adicionou Hangul ou Chewing antes disso, desmarque e selecione novamente em _Setup > Typing > Input Methods_ para mover suas teclas para lá; o Omarchy deixa em paz um mecanismo com o qual você já digita.

A digitação começa no modo latino. Pressione `Super + I` para percorrer os métodos de entrada configurados, e `Super + Shift + I` para percorrer no sentido contrário. Toque em `Shift` sozinho para sair de um método de entrada como o Pinyin e ir para as letras latinas, e toque nele novamente para voltar, do jeito que Sogou, Microsoft Pinyin e macOS funcionam; `Shift` mais uma letra ainda digita uma maiúscula. Em teclados japoneses, 全角/半角 alterna a entrada, 変換 ativa e 無変換 desativa. Com o coreano, 한/영 alterna o Hangul e 한자 converte para Hanja, tenha o seu teclado teclas dedicadas ou envie Right Alt e Right Ctrl para elas, como muitos laptops fazem, então Right Alt e Right Ctrl não são modificadores comuns ali; o ditado alterna com Alt + Space. `Ctrl + Space` continua disponível para Tmux e Herdr; `Shift + CapsLock` continua sendo a tecla de composição.

O indicador de teclado aparece à direita da barra quando você tem vários layouts de teclado ou métodos de entrada. Clique nele para trocar os idiomas de entrada; o japonês exibe あ para hiragana. Para escolhas de caracteres japoneses, mude para o japonês, digite uma palavra como `nihongo` e pressione Space duas vezes. Pressione Enter para aceitar sua escolha. Se você também tiver vários layouts de teclado, clique com o botão direito no indicador para percorrê-los.

Use _Setup > Typing > Keyboard Layouts_ para selecionar layouts como inglês e francês, entre as mesmas opções oferecidas durante a instalação. Use _Setup > Typing > Input Methods_ para selecionar quais mecanismos de composição estão ativos. Os dois seletores abrem dentro do menu do Omarchy com suas seleções atuais marcadas. Clique ou pressione Enter para alternar uma opção; cada alteração é aplicada imediatamente. Desmarcar um método de entrada o remove do ciclo sem desinstalá-lo; o teclado continua disponível.

Execute `omarchy setup keyboard` ou `omarchy setup input` para abrir os mesmos seletores. Para adicionar um idioma pela linha de comando, use `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ou `cangjie5`. Quick, Boshiamy e Array vêm no mesmo pacote que o Cangjie e aparecem no seletor de Input Methods. Suas teclas de troca personalizadas são preservadas. Para layouts ou teclas alternativos do mecanismo, instale `fcitx5-configtool` com `omarchy pkg add fcitx5-configtool` e inicie-o a partir de um terminal. Selecionar um idioma de entrada não altera o idioma da área de trabalho. Escolher japonês, coreano ou chinês em _Setup > Language_ adiciona seu método de entrada quando você ainda não tem nenhum.

Use `Super + I` para percorrer métodos de entrada ou layouts de teclado, e `Super + Shift + I` para voltar pelo outro caminho, então, com três configurados, você pode se mover entre dois vizinhos. O indicador de entrada aparece à direita da barra somente quando mais de um método de entrada ou layout está configurado. Esse atalho da área de trabalho funciona junto com suas teclas de troca existentes do Fcitx; você pode substituí-lo em `~/.config/hypr/bindings.lua`. Os mecanismos de entrada e as sequências de composição usam o serviço [Fcitx5](https://fcitx-im.org/) que já está em execução em todas as sessões.

### Usar ALT como SUPER

Em alguns teclados, não é conveniente usar a tecla meta principal (tecla Windows/cmd) como SUPER. Você pode alterar isso para usar ALT em vez disso com esta alteração:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
