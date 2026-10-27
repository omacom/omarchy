# Keyboard, Mouse, Trackpad

Hinahayaan ka ng Hyprland na i-configure ang lahat ng input mo nang napakadetalyado. Maaari mong gawing napakabilis ng keyboard repeat o gawing natural scrolling ang gamit ng trackpad. Binabago mo ang lahat ng ito sa `~/.config/hypr/input.lua`, na maaari mo ring maabot sa pamamagitan ng _Setup > Input_ sa Omarchy menu (`Super + Space`). Papalitan ng anumang itatakda mo roon ang mga default ng Omarchy.

Narito ang isang halimbawa:

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

Makikita mo ang [lahat ng opsyon sa input](https://wiki.hypr.land/Configuring/Basics/Variables/#input) sa wiki ng Hyprland para sa mga input.

Gumagana ang CapsLock bilang normal na Caps Lock, at ang `Shift + CapsLock` ang compose key para sa [mabilisang emoji](07-hotkeys.md#quick-emojis) at [iba pang completion](07-hotkeys.md#quick-completions). Kung mas gusto mong ilagay ang compose key sa ibang lugar, palitan ang `omarchy:shift_caps_compose` sa `kb_options`. Halimbawa, inililipat nito ang compose key sa Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Mga galaw sa trackpad

Maaari mo ring i-on ang [mga galaw sa touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), tulad ng pag-swipe gamit ang tatlong daliri upang magpalit ng mga workspace:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Sa mga laptop na Dell XPS na may haptic touchpad, maaari mo ring itakda ang lakas ng pag-click sa low, mid, o high sa ilalim ng _Trigger > Hardware > Touchpad Haptics_.

### Pag-type sa Chinese, Japanese, at iba pang wika

Piliin ang Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), o Hong Kong (Cangjie) kapag tinanong ng installer ang keyboard mo. Awtomatikong kino-configure ng Omarchy ang keyboard at ang katugmang input engine, kabilang na sa offline na first-boot setup. Gumagamit ang Japanese ng Mozc, gumagamit ang Korean ng karaniwang two-set Hangul, gumagamit ang Simplified Chinese ng Pinyin, gumagamit ang Taiwan ng karaniwang ayos ng Zhuyin ng Chewing, at gumagamit ang Hong Kong ng Cangjie na may mga anyong karakter ng Hong Kong. Nagbibigay ang Japanese (US keyboard) ng Mozc na may US keyboard layout. Nananatili ang mga key ng Hangul, Zhuyin, at Cangjie sa kanilang karaniwang posisyon kahit nagta-type ka ng mga letrang Latin gamit ang Dvorak, Colemak, o AZERTY. Kung nagdagdag ka ng Hangul o Chewing bago ito, i-deselect at muling piliin ito sa ilalim ng _Setup > Typing > Input Methods_ upang ilipat ang mga key nito roon; hindi gagalawin ng Omarchy ang engine na ginagamit mo na sa pag-type.

Nagsisimula ang pag-type sa Latin mode. Pindutin ang `Super + I` upang magpalit-palit sa mga naka-configure na input method, at ang `Super + Shift + I` upang bumalik. I-tap ang `Shift` nang mag-isa upang lumabas mula sa isang input method tulad ng Pinyin papunta sa mga letrang Latin, at i-tap itong muli upang bumalik, gaya ng ginagawa ng Sogou, Microsoft Pinyin, at macOS; nagta-type pa rin ng malaking letra ang `Shift` kasama ang isang letra. Sa mga Japanese keyboard, nagpapalit ng input ang 全角/半角, ino-on ito ng 変換, at ino-off ito ng 無変換. Sa Korean, nagpapalit ng Hangul ang 한/영 at nagko-convert papuntang Hanja ang 한자, may mga nakalaang key man ang keyboard mo o nagpapadala ito ng Right Alt at Right Ctrl para sa mga ito, gaya ng ginagawa ng maraming laptop, kaya hindi mga karaniwang modifier ang Right Alt at Right Ctrl roon; nananatili sa F9 ang dictation push-to-talk. Nananatiling available ang `Ctrl + Space` para sa Tmux at Herdr; nananatiling compose key ang `Shift + CapsLock`.

Lumilitaw ang keyboard indicator sa kanan ng bar kapag marami kang keyboard layout o input method. I-click ito upang magpalit ng mga wikang input; ipinapakita ng Japanese ang あ para sa hiragana. Para sa mga pagpipiliang karakter sa Japanese, lumipat sa Japanese, mag-type ng salitang tulad ng `nihongo`, pagkatapos ay pindutin ang Space nang dalawang beses. Pindutin ang Enter upang tanggapin ang pinili mo. Kung marami ka ring keyboard layout, i-right-click ang indicator upang magpalit-palit sa mga iyon.

Gamitin ang _Setup > Typing > Keyboard Layouts_ upang pumili ng mga layout tulad ng English at French, mula sa parehong mga pagpipiliang iniaalok sa panahon ng pag-install. Gamitin ang _Setup > Typing > Input Methods_ upang piliin kung aling mga composition engine ang aktibo. Bumubukas ang parehong picker sa loob ng Omarchy menu na naka-check ang kasalukuyan mong mga pinili. I-click o pindutin ang Enter upang i-toggle ang isang pagpipilian; agad na nalalapat ang bawat pagbabago. Inaalis ng pag-deselect sa isang input method ito mula sa cycle nang hindi ito ina-uninstall; nananatiling available ang keyboard.

Patakbuhin ang `omarchy setup keyboard` o `omarchy setup input` upang buksan ang parehong mga picker. Upang magdagdag ng isang wika mula sa command line, gamitin ang `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, o `cangjie5`. Kasama ang Quick, Boshiamy, at Array sa parehong package ng Cangjie at lumilitaw ang mga ito sa Input Methods picker. Pinapanatili ang custom mong switching keys. Para sa mga alternatibong layout o key ng engine, i-install ang `fcitx5-configtool` gamit ang `omarchy pkg add fcitx5-configtool` at ilunsad ito mula sa terminal. Hindi binabago ng pagpili ng wikang input ang wika ng desktop. Nagdaragdag ang pagpili ng Japanese, Korean, o Chinese sa ilalim ng _Setup > Language_ ng input method nito kapag wala ka pang ganoon.

Gamitin ang `Super + I` upang magpalit-palit sa mga input method o keyboard layout, at ang `Super + Shift + I` upang bumalik sa kabilang direksyon, kaya sa tatlong naka-configure ay maaari kang gumalaw sa pagitan ng dalawang magkatabi. Lumilitaw lamang ang input indicator sa kanan ng bar kapag higit sa isang input method o layout ang naka-configure. Gumagana ang desktop binding na ito kasabay ng kasalukuyan mong Fcitx switching keys; maaari mo itong i-override sa `~/.config/hypr/bindings.lua`. Ginagamit ng mga input engine at ng compose sequences ang serbisyong [Fcitx5](https://fcitx-im.org/) na tumatakbo na sa bawat session.

### Gamitin ang ALT bilang SUPER

Sa ilang keyboard, hindi maginhawang gamitin ang pangunahing meta key (Windows/cmd key) bilang SUPER. Maaari mong baguhin ito upang maging ALT sa halip gamit ang pagbabagong ito:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
