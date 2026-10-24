# Teclado, mouse, trackpad

O Hyprland permite que você configure todas as suas entradas em grande detalhe. Você pode tornar a repetição do teclado supersonicamente rápida ou fazer o trackpad usar rolagem natural. Você altera tudo em `~/.config/hypr/input.lua`, que também pode ser acessado em _Configuração > Entrada_ no menu do Omarchy (`Super + Space`). Qualquer coisa que você definir lá substitui os padrões do Omarchy.

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

CapsLock funciona como um Caps Lock normal, e `Shift + CapsLock` é a tecla compose para [emojis rápidos](07-hotkeys.md#quick-emojis) e [outras complementações](07-hotkeys.md#quick-completions). Se você preferir a tecla compose em outro lugar, substitua `omarchy:shift_caps_compose` em `kb_options`. Por exemplo, isso move a tecla compose para o Alt direito:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestos do trackpad

Você também pode ativar [gestos do touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), como deslizar com três dedos para mudar de área de trabalho:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Em notebooks Dell XPS com um touchpad háptico, você também pode definir a força do clique como baixa, média ou alta em _Acionar > Hardware > Vibração do touchpad_.

### Digitando em chinês, japonês e outros idiomas

Selecione japonês, coreano, chinês (simplificado, Pinyin) ou chinês (tradicional, Zhuyin) quando o instalador perguntar pelo seu teclado. O Omarchy configura o teclado e o mecanismo de entrada correspondente automaticamente, inclusive durante a configuração off-line na primeira inicialização. O japonês usa o Mozc, o coreano usa o Hangul padrão de dois conjuntos, o chinês simplificado usa o Pinyin, e o chinês tradicional usa a organização Zhuyin padrão do Chewing. Japonês (teclado dos EUA) oferece o Mozc com um layout de teclado dos EUA.

A digitação começa no modo latino. Pressione `Super + I` para percorrer os métodos de entrada configurados, e `Super + Shift + I` para percorrer em sentido contrário. Toque em `Shift` sozinho para sair de um método de entrada como o Pinyin para letras latinas, e toque de novo para voltar, da maneira como o Sogou, o Microsoft Pinyin e o macOS funcionam; `Shift` mais uma letra ainda digita uma maiúscula. Em teclados japoneses, 全角/半角 alterna a entrada, 変換 a liga e 無変換 a desliga. Em um layout de teclado coreano, as teclas dedicadas 한/영 e 한자 alternam para Hangul e convertem para Hanja. `Ctrl + Space` permanece disponível para o Tmux e o Herdr; `Shift + CapsLock` permanece a tecla compose.

O indicador de teclado aparece à direita da barra quando você tem vários layouts de teclado ou métodos de entrada. Clique nele para alternar os idiomas de entrada; o japonês exibe あ para hiragana. Para escolhas de caracteres em japonês, mude para japonês, digite uma palavra como `nihongo` e depois pressione Espaço duas vezes. Pressione Enter para aceitar sua escolha. Se você também tiver vários layouts de teclado, clique com o botão direito no indicador para percorrê-los.

Use _Configuração > Digitação > Layouts de teclado_ para selecionar layouts como inglês e francês, a partir das mesmas escolhas oferecidas durante a instalação. Use _Configuração > Digitação > Métodos de entrada_ para selecionar quais mecanismos de composição estão ativos. Os dois seletores abrem dentro do menu do Omarchy com suas seleções atuais marcadas. Clique ou pressione Enter para alternar uma escolha; cada alteração é aplicada imediatamente. Desmarcar um método de entrada o remove do ciclo sem desinstalá-lo; o teclado permanece disponível.

Execute `omarchy setup keyboard` ou `omarchy setup input` para abrir os mesmos seletores. Para acrescentar um idioma pela linha de comando, use `omarchy setup input mozc`, `hangul`, `pinyin` ou `chewing`. Suas teclas de troca personalizadas são preservadas. Para layouts ou teclas alternativos do mecanismo, instale o `fcitx5-configtool` com `omarchy pkg add fcitx5-configtool` e inicie-o a partir de um terminal. Selecionar um idioma de entrada não altera o idioma da área de trabalho.

Use `Super + I` para percorrer os métodos de entrada ou layouts de teclado, e `Super + Shift + I` para ir no outro sentido, então, com três configurados, você pode se mover entre dois vizinhos. O indicador de entrada aparece à direita da barra apenas quando mais de um método de entrada ou layout está configurado. Essa vinculação da área de trabalho funciona junto com suas teclas de troca existentes do Fcitx; você pode substituí-la em `~/.config/hypr/bindings.lua`. Os mecanismos de entrada e as sequências compose usam o serviço [Fcitx5](https://fcitx-im.org/) já em execução em todas as sessões.

### Usar ALT como SUPER

Em alguns teclados, não é conveniente usar a tecla meta principal (tecla Windows/cmd) como SUPER. Você pode alterar isso para ser ALT usando esta alteração:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
