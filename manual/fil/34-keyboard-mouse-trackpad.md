# Keyboard, Mouse, at Trackpad

Hinahayaan ka ng Hyprland na i-configure ang lahat ng input mo nang napakadetalyado. Maaari mong gawing supersonically mabilis ang keyboard repeat o gawing natural scrolling ang gamit ng trackpad. Babaguhin mo ang lahat ng ito sa `~/.config/hypr/input.lua`, na maaari mo ring maabot sa pamamagitan ng _Setup > Input_ sa menu ng Omarchy (`Super + Space`). Papalitan ng anumang ilagay mo roon ang mga default ng Omarchy.

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

Maaari mong [tingnan ang lahat ng opsyon sa input](https://wiki.hypr.land/Configuring/Basics/Variables/#input) sa wiki ng Hyprland para sa mga input.

Gumagana ang CapsLock bilang normal na Caps Lock, at ang `Shift + CapsLock` ang compose key para sa [mabilisang emoji](07-hotkeys.md#quick-emojis) at [iba pang completion](07-hotkeys.md#quick-completions). Kung mas gusto mong ilagay ang compose key sa iba, palitan ang `omarchy:shift_caps_compose` sa `kb_options`. Halimbawa, inililipat nito ang compose key sa Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Mga gesture sa trackpad

Mag-swipe sa trackpad para gumalaw sa desktop:

| Gesture | Aksyon |
| --- | --- |
| Tatlong daliri pakaliwa / pakanan | Nakaraan / susunod na workspace, kasama ang mga walang laman |
| Tatlong daliri pataas | I-toggle ang AI console |
| Tatlong daliri pababa | Buksan ang menu ng Omarchy |
| Apat na daliri pakaliwa / pakanan | Ilipat ang aktibong window sa nakaraan / susunod na workspace |
| Apat na daliri pababa | I-toggle ang fullscreen |

Para baguhin ang isa, i-unset ito sa `~/.config/hypr/input.lua` bago idagdag ang sarili mong [touchpad gesture](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), dahil hindi tatanggap ang Hyprland ng dalawang gesture sa parehong mga daliri at direksyon:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Para i-off ang lahat ng gesture ng Omarchy, itakda ang `omarchy_default_gestures = false` malapit sa itaas ng `~/.config/hypr/hyprland.lua`, bago mag-load ang mga default ng Omarchy.

Sa mga laptop na Dell XPS na may haptic touchpad, maaari mo ring itakda ang lakas ng click sa low, mid, o high sa ilalim ng _Trigger > Hardware > Touchpad Haptics_.

### Pag-type sa Chinese, Japanese, at iba pang wika

Piliin ang Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), o Hong Kong (Cangjie) kapag tinanong ng installer ang keyboard mo. Awtomatikong iko-configure ng Omarchy ang keyboard at ang katugmang input engine, kasama na sa offline na first-boot setup. Gumagamit ang Japanese ng Mozc, gumagamit ang Korean ng karaniwang two-set na Hangul, gumagamit ang Simplified Chinese ng Pinyin, gumagamit ang Taiwan ng karaniwang ayos ng Zhuyin ng Chewing, at gumagamit ang Hong Kong ng Cangjie na may mga anyo ng karakter ng Hong Kong. Nagbibigay ang Japanese (US keyboard) ng Mozc na may US keyboard layout. Nananatili ang mga key ng Hangul, Zhuyin, at Cangjie sa kanilang karaniwang posisyon kahit na nagta-type ka ng mga letrang Latin gamit ang Dvorak, Colemak, o AZERTY. Kung nagdagdag ka ng Hangul o Chewing bago ito, alisin ang pagkakapili at piliin itong muli sa ilalim ng _Setup > Typing > Input Methods_ para ilipat ang mga key nito roon; hahayaan lang ng Omarchy ang isang engine na ginagamit mo na sa pag-type.

Nagsisimula ang pag-type sa Latin mode. Pindutin ang `Super + I` para umikot sa mga na-configure na input method, at ang `Super + Shift + I` para umikot pabalik. Pindutin ang `Shift` nang mag-isa para lumabas mula sa isang input method tulad ng Pinyin papunta sa mga letrang Latin, at pindutin itong muli para bumalik, gaya ng paggana ng Sogou, Microsoft Pinyin, at macOS; nagta-type pa rin ng malaking letra ang `Shift` kasama ng isang letra. Sa mga Japanese keyboard, ino-toggle ng 全角/半角 ang input, ino-on ito ng 変換, at ino-off ito ng 無変換. Sa Korean, pinapalitan ng 한/영 ang Hangul at nagko-convert ang 한자 papunta sa Hanja, may nakalaang mga key man ang keyboard mo o nagpapadala ito ng Right Alt at Right Ctrl para sa mga iyon, gaya ng ginagawa ng maraming laptop, kaya hindi simpleng modifier ang Right Alt at Right Ctrl roon; nananatili sa F9 ang dictation push-to-talk. Nananatiling available ang `Ctrl + Space` para sa Tmux at Herdr; nananatili ang `Shift + CapsLock` bilang compose key.

Lumilitaw ang keyboard indicator sa kanan ng bar kapag marami kang keyboard layout o input method. I-click ito para lumipat ng mga wikang pang-input; ipinapakita ng Japanese ang あ para sa hiragana. Para sa mga pagpipiliang karakter na Japanese, lumipat sa Japanese, mag-type ng salitang tulad ng `nihongo`, pagkatapos ay pindutin ang Space nang dalawang beses. Pindutin ang Enter para tanggapin ang pinili mo. Kung marami ka ring keyboard layout, i-right-click ang indicator para umikot sa mga iyon.

Gamitin ang _Setup > Typing > Keyboard Layouts_ para pumili ng mga layout tulad ng English at French, mula sa parehong mga pagpipiliang iniaalok sa panahon ng installation. Gamitin ang _Setup > Typing > Input Methods_ para piliin kung aling mga composition engine ang aktibo. Bumubukas ang dalawang picker sa loob ng menu ng Omarchy na naka-check ang kasalukuyang mga pinili mo. I-click o pindutin ang Enter para i-toggle ang isang pagpipilian; agad na nalalapat ang bawat pagbabago. Ang pag-alis ng pagkakapili sa isang input method ay nag-aalis nito sa cycle nang hindi ito ina-uninstall; nananatiling available ang keyboard.

Patakbuhin ang `omarchy setup keyboard` o `omarchy setup input` para buksan ang parehong mga picker. Para magdagdag ng isang wika mula sa command line, gamitin ang `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, o `cangjie5`. Kasama ang Quick, Boshiamy, at Array sa parehong package ng Cangjie at lumilitaw sa picker ng Input Methods. Mapapanatili ang mga custom na switching key mo. Para sa alternatibong mga layout o key ng engine, i-install ang `fcitx5-configtool` gamit ang `omarchy pkg add fcitx5-configtool` at ilunsad ito mula sa isang terminal. Hindi binabago ng pagpili ng wikang pang-input ang wika ng desktop. Ang pagpili ng Japanese, Korean, o Chinese sa ilalim ng _Setup > Language_ ay nagdaragdag ng input method nito kapag wala ka pa nito.

Gamitin ang `Super + I` para umikot sa mga input method o keyboard layout, at ang `Super + Shift + I` para bumalik sa kabilang direksyon, kaya sa tatlong na-configure ay maaari kang gumalaw sa pagitan ng dalawang magkatabi. Lumilitaw lang ang input indicator sa kanan ng bar kapag higit sa isang input method o layout ang na-configure. Gumagana ang desktop binding na ito kasama ng umiiral mong mga Fcitx switching key; maaari mo itong i-override sa `~/.config/hypr/bindings.lua`. Ginagamit ng mga input engine at ng mga compose sequence ang serbisyong [Fcitx5](https://fcitx-im.org/) na tumatakbo na sa bawat session.

### Gamitin ang ALT bilang SUPER

Sa ilang keyboard, hindi maginhawang gamitin ang primary meta key (Windows/cmd key) bilang SUPER. Maaari mong baguhin ito para maging ALT sa halip gamit ang pagbabagong ito:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
