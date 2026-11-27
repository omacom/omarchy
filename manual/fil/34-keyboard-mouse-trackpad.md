# Keyboard, Mouse, Trackpad

Pinahihintulutan ka ng Hyprland na i-configure ang lahat ng iyong mga input nang detalyado. Maaari mong gawing napakabilis na parang supersonic ang pag-ulit ng keyboard o pagawain ang trackpad ng natural scrolling. Babaguhin mo ang lahat ng ito sa `~/.config/hypr/input.lua`, na maaari mo ring maabot sa pamamagitan ng _Setup > Input_ sa Omarchy menu (`Super + Space`). Papalitan ng anumang itakda mo roon ang mga default ng Omarchy.

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

Maaari mong [tingnan ang lahat ng mga opsyon sa input](https://wiki.hypr.land/Configuring/Basics/Variables/#input) sa Hyprland wiki para sa mga input.

Gumagana ang CapsLock bilang normal na Caps Lock, at ang `Shift + CapsLock` ang compose key para sa [mabilisang mga emoji](07-hotkeys.md#quick-emojis) at [iba pang mga completion](07-hotkeys.md#quick-completions). Kung mas gusto mong nasa ibang lugar ang compose key, palitan ang `omarchy:shift_caps_compose` sa `kb_options`. Halimbawa, inililipat nito ang compose key sa Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Mga function key

Ang pinakaitaas na hanay ng laptop keyboard ay nagpapadala ng mga media key (volume, brightness at iba pa) bilang default, at ang paghawak sa `Fn` ang nagbibigay ng F1-F12; binabaliktad ito ng `Fn + Esc` hanggang pindutin mo itong muli. Karamihan ng mga keyboard ay sila mismo ang nakakaalala ng lock na iyon. Hinahayaan ito ng mga ASUS laptop at Apple-style keyboard sa Linux, na sinisimulan sila sa mga media key sa bawat boot. Para simulan sila sa F1-F12 sa halip, patakbuhin ang `omarchy device keyboard toprow fnkeys` (at `omarchy device keyboard toprow mediakeys` para bumalik); sa ilang laptop, magkakabisa ito pagkatapos ng reboot. Pinapanatili ng mga Apple Silicon Mac ang sarili nilang setting.

### Mga galaw sa trackpad

Mag-swipe sa trackpad para gumalaw sa desktop:

| Gesture | Action |
| --- | --- |
| Three fingers left / right | Previous / next workspace, including empty ones |
| Three fingers up | Toggle the AI console |
| Three fingers down | Open the Omarchy menu |
| Four fingers left / right | Move the active window to the previous / next workspace |
| Four fingers down | Toggle fullscreen |

Para baguhin ang isa, i-unset muna ito sa `~/.config/hypr/input.lua` bago idagdag ang sarili mong [touchpad gesture](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), dahil hindi tatanggap ang Hyprland ng dalawang galaw sa parehong mga daliri at direksyon:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Para patayin ang lahat ng galaw ng Omarchy, itakda ang `omarchy_default_gestures = false` malapit sa itaas ng `~/.config/hypr/hyprland.lua`, bago mag-load ang mga default ng Omarchy.

Sa mga Dell XPS laptop na may haptic touchpad, maaari mo ring itakda ang lakas ng pag-click sa mababa, katamtaman, o mataas sa ilalim ng _Trigger > Hardware > Touchpad Haptics_.

### Pagta-type sa Chinese, Japanese, at iba pang mga wika

Piliin ang Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), o Hong Kong (Cangjie) kapag tinanong ng installer ang tungkol sa iyong keyboard. Awtomatikong iko-configure ng Omarchy ang keyboard at ang katugmang input engine, kasama na sa panahon ng offline na first-boot setup. Gumagamit ang Japanese ng Mozc, gumagamit ang Korean ng karaniwang two-set Hangul, gumagamit ang Simplified Chinese ng Pinyin, gumagamit ang Taiwan ng karaniwang Zhuyin arrangement ng Chewing, at gumagamit ang Hong Kong ng Cangjie na may mga anyo ng karakter ng Hong Kong. Nagbibigay ang Japanese (US keyboard) ng Mozc na may US keyboard layout. Nananatili ang mga Hangul, Zhuyin, at Cangjie key sa kanilang karaniwang mga posisyon kahit nagta-type ka ng mga letrang Latin gamit ang Dvorak, Colemak, o AZERTY. Kung nagdagdag ka ng Hangul o Chewing bago ito, alisin ito sa pagkakapili at piliin itong muli sa ilalim ng _Setup > Keyboard > Input Methods_ para ilipat ang mga key nito roon; hindi gagalawin ng Omarchy ang isang engine na ginagamit mo na sa pagta-type.

Nagsisimula ang pagta-type sa Latin mode. Pindutin ang `Super + I` para magpalit-palit sa mga naka-configure na input method, at `Super + Shift + I` para magpalit pabalik. Pindutin ang `Shift` nang mag-isa para umalis sa isang input method tulad ng Pinyin papunta sa mga letrang Latin, at pindutin itong muli para bumalik, sa paraang ginagawa ng Sogou, Microsoft Pinyin, at macOS; nagta-type pa rin ng malaking letra ang `Shift` kasama ng isang letra. Sa mga Japanese keyboard, ang 全角/半角 ang nagto-toggle ng input, ang 変換 ang nagbubukas nito, at ang 無変換 ang nagpapatay nito. Sa Korean, ang 한/영 ang nagpapalit sa Hangul at ang 한자 ang nagko-convert papuntang Hanja, may mga nakalaang key man ang iyong keyboard o nagpapadala ito ng Right Alt at Right Ctrl para sa mga ito, tulad ng ginagawa ng maraming laptop, kaya hindi mga simpleng modifier ang Right Alt at Right Ctrl roon; sa halip, ang dictation ang nagto-toggle gamit ang Alt + Space. Mananatiling magagamit ang `Ctrl + Space` para sa Tmux at Herdr; mananatili ang `Shift + CapsLock` bilang compose key.

Lumilitaw ang keyboard indicator sa kanan ng bar kapag marami kang keyboard layout o input method. I-click ito para magpalit ng mga wikang pang-input; ipinapakita ng Japanese ang あ para sa hiragana. Para sa mga pagpipiliang karakter sa Japanese, lumipat sa Japanese, mag-type ng salitang gaya ng `nihongo`, pagkatapos ay pindutin ang Space nang dalawang beses. Pindutin ang Enter para tanggapin ang iyong pinili. Kung marami ka ring keyboard layout, i-right-click ang indicator para magpalit-palit sa mga iyon.

Gamitin ang _Setup > Keyboard > Keyboard Inputs_ para pumili ng mga layout gaya ng English at French, mula sa parehong mga pagpipiliang inaalok sa panahon ng pag-install. Gamitin ang _Setup > Keyboard > Input Methods_ para piliin kung aling mga composition engine ang aktibo. Nagbubukas ang parehong picker sa loob ng Omarchy menu na may check ang iyong mga kasalukuyang napili. I-click o pindutin ang Enter para i-toggle ang isang pagpipilian; magkakabisa agad ang bawat pagbabago. Ang pag-alis sa pagkakapili ng isang input method ay nag-aalis nito sa cycle nang hindi ito ina-uninstall; mananatiling magagamit ang keyboard.

Patakbuhin ang `omarchy setup keyboard` o `omarchy setup input` para buksan ang parehong mga picker. Para magdagdag ng isang wika mula sa command line, gamitin ang `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, o `cangjie5`. Ang Quick, Boshiamy, at Array ay kasama sa parehong package ng Cangjie at lumilitaw sa Input Methods picker. Mapapanatili ang iyong mga custom na switching key. Para sa mga alternatibong layout o key ng engine, i-install ang `fcitx5-configtool` gamit ang `omarchy pkg add fcitx5-configtool` at ilunsad ito mula sa isang terminal. Hindi binabago ng pagpili ng wikang pang-input ang wika ng desktop. Ang pagpili ng Japanese, Korean, o Chinese sa ilalim ng _Setup > Region > Language_ ay nagdaragdag ng input method nito kapag wala ka pa nito.

Gamitin ang `Super + I` para magpalit-palit sa mga input method o keyboard layout, at `Super + Shift + I` para bumalik sa kabilang direksyon, kaya sa tatlong naka-configure ay maaari kang gumalaw sa pagitan ng dalawang magkatabi. Lumilitaw lamang ang input indicator sa kanan ng bar kapag higit sa isang input method o layout ang naka-configure. Gumagana ang desktop binding na ito kasabay ng iyong mga kasalukuyang Fcitx switching key; maaari mo itong i-override sa `~/.config/hypr/bindings.lua`. Gumagamit ang mga input engine at ang mga compose sequence ng [Fcitx5](https://fcitx-im.org/) service na tumatakbo na sa bawat session.

### Gamitin ang ALT bilang SUPER

Sa ilang keyboard, hindi maginhawang gamitin ang pangunahing meta key (Windows/cmd key) bilang SUPER. Maaari mo itong palitan ng ALT sa halip gamit ang pagbabagong ito:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
