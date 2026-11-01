# விசைப்பலகை, சுட்டி, Trackpad

Hyprland உங்கள் அனைத்து உள்ளீடுகளையும் மிக விரிவாக உள்ளமைக்க உங்களை அனுமதிக்கிறது. நீங்கள் விசைப்பலகை மீண்டும் அழுத்தும் வேகத்தை அதிவேகமாக மாற்றலாம் அல்லது trackpad இயற்கை உருளலைப் பயன்படுத்தச் செய்யலாம். நீங்கள் அனைத்தையும் `~/.config/hypr/input.lua` இல் மாற்றுகிறீர்கள், இதை Omarchy menu (`Super + Space`) இல் உள்ள _Setup > Input_ வழியாகவும் அடையலாம். அங்கு நீங்கள் அமைப்பது எதுவும் Omarchy இன் இயல்புநிலைகளை மாற்றிவிடும்.

இங்கே ஒரு எடுத்துக்காட்டு:

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

உள்ளீடுகளுக்கான Hyprland wiki இல் [அனைத்து உள்ளீட்டு விருப்பங்களையும் நீங்கள் பார்க்கலாம்](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock சாதாரண Caps Lock ஆகச் செயல்படுகிறது, மேலும் `Shift + CapsLock` என்பது [விரைவு emojis](07-hotkeys.md#quick-emojis) மற்றும் [பிற நிறைவுகளுக்கான](07-hotkeys.md#quick-completions) compose key ஆகும். compose key வேறு எங்காவது இருக்க வேண்டும் என்று நீங்கள் விரும்பினால், `kb_options` இல் உள்ள `omarchy:shift_caps_compose` ஐ மாற்றவும். எடுத்துக்காட்டாக, இது compose key ஐ Right Alt க்கு நகர்த்துகிறது:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Trackpad சைகைகள்

desktop இல் சுற்றி நகர trackpad இல் swipe செய்யவும்:

| சைகை | செயல் |
| --- | --- |
| மூன்று விரல்கள் இடது / வலது | முந்தைய / அடுத்த workspace, காலியானவை உட்பட |
| மூன்று விரல்கள் மேலே | AI console ஐ மாற்றவும் |
| மூன்று விரல்கள் கீழே | Omarchy menu ஐத் திறக்கவும் |
| நான்கு விரல்கள் இடது / வலது | செயலில் உள்ள window ஐ முந்தைய / அடுத்த workspace க்கு நகர்த்தவும் |
| நான்கு விரல்கள் கீழே | fullscreen ஐ மாற்றவும் |

ஒன்றை மாற்ற, உங்கள் சொந்த [touchpad gesture](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) ஐச் சேர்ப்பதற்கு முன் `~/.config/hypr/input.lua` இல் அதை unset செய்யவும், ஏனெனில் Hyprland ஒரே விரல்கள் மற்றும் திசையில் இரண்டு சைகைகளை ஏற்காது:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy இன் அனைத்து சைகைகளையும் முடக்க, Omarchy இன் இயல்புநிலைகள் ஏற்றப்படுவதற்கு முன், `~/.config/hypr/hyprland.lua` இன் மேற்பகுதிக்கு அருகில் `omarchy_default_gestures = false` என அமைக்கவும்.

haptic touchpad கொண்ட Dell XPS laptops இல், _Trigger > Hardware > Touchpad Haptics_ இன் கீழ் click strength ஐ low, mid, அல்லது high எனவும் அமைக்கலாம்.

### சீனம், ஜப்பானியம் மற்றும் பிற மொழிகளில் தட்டச்சு செய்தல்

installer உங்கள் விசைப்பலகையைக் கேட்கும்போது Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), அல்லது Hong Kong (Cangjie) ஐத் தேர்ந்தெடுக்கவும். offline first-boot setup இன் போது உட்பட, Omarchy விசைப்பலகையையும் பொருந்தும் input engine ஐயும் தானாகவே உள்ளமைக்கிறது. Japanese Mozc ஐப் பயன்படுத்துகிறது, Korean நிலையான two-set Hangul ஐப் பயன்படுத்துகிறது, Simplified Chinese Pinyin ஐப் பயன்படுத்துகிறது, Taiwan Chewing இன் நிலையான Zhuyin அமைப்பைப் பயன்படுத்துகிறது, மேலும் Hong Kong Hong Kong எழுத்து வடிவங்களுடன் Cangjie ஐப் பயன்படுத்துகிறது. Japanese (US keyboard) US விசைப்பலகை அமைப்புடன் Mozc ஐ வழங்குகிறது. நீங்கள் Dvorak, Colemak, அல்லது AZERTY உடன் Latin எழுத்துகளைத் தட்டச்சு செய்யும்போதும் Hangul, Zhuyin, மற்றும் Cangjie விசைகள் அவற்றின் நிலையான நிலைகளிலேயே இருக்கும். இதற்கு முன் நீங்கள் Hangul அல்லது Chewing ஐச் சேர்த்திருந்தால், அதன் விசைகளை அங்கு நகர்த்த _Setup > Typing > Input Methods_ இன் கீழ் அதைத் தேர்வுநீக்கி மீண்டும் தேர்ந்தெடுக்கவும்; நீங்கள் ஏற்கனவே தட்டச்சு செய்யும் ஒரு engine ஐ Omarchy தனியாக விட்டுவிடுகிறது.

தட்டச்சு Latin mode இல் தொடங்குகிறது. உள்ளமைக்கப்பட்ட input methods வழியாகச் சுழல `Super + I` ஐ அழுத்தவும், பின்னோக்கிச் சுழல `Super + Shift + I` ஐ அழுத்தவும். Pinyin போன்ற ஒரு input method இலிருந்து Latin எழுத்துகளுக்கு வெளியேற `Shift` ஐ மட்டும் தட்டவும், மீண்டும் உள்ளே செல்ல அதை மீண்டும் தட்டவும், Sogou, Microsoft Pinyin, மற்றும் macOS செயல்படும் விதம் போலவே; `Shift` மற்றும் ஒரு எழுத்து இன்னும் ஒரு பெரிய எழுத்தைத் தட்டச்சு செய்கிறது. Japanese விசைப்பலகைகளில், 全角/半角 உள்ளீட்டை மாற்றுகிறது, 変換 அதை இயக்குகிறது, மேலும் 無変換 அதை முடக்குகிறது. Korean உடன், 한/영 Hangul ஐ மாற்றுகிறது மற்றும் 한자 Hanja ஆக மாற்றுகிறது, உங்கள் விசைப்பலகையில் பிரத்யேக விசைகள் இருந்தாலும் அல்லது பல laptops செய்வது போல அவற்றுக்காக Right Alt மற்றும் Right Ctrl ஐ அனுப்பினாலும், எனவே Right Alt மற்றும் Right Ctrl அங்கு சாதாரண modifiers அல்ல; dictation அதற்குப் பதிலாக Alt + Space உடன் மாறுகிறது. `Ctrl + Space` Tmux மற்றும் Herdr க்குக் கிடைக்கிறது; `Shift + CapsLock` compose key ஆகவே இருக்கிறது.

உங்களிடம் பல விசைப்பலகை அமைப்புகள் அல்லது input methods இருக்கும்போது விசைப்பலகை indicator bar இன் வலதுபுறத்தில் தோன்றும். உள்ளீட்டு மொழிகளை மாற்ற அதை click செய்யவும்; Japanese hiragana க்கு あ ஐக் காட்டுகிறது. Japanese எழுத்துத் தேர்வுகளுக்கு, Japanese க்கு மாறி, `nihongo` போன்ற ஒரு சொல்லைத் தட்டச்சு செய்து, பின் Space ஐ இரண்டு முறை அழுத்தவும். உங்கள் தேர்வை ஏற்க Enter ஐ அழுத்தவும். உங்களிடம் பல விசைப்பலகை அமைப்புகளும் இருந்தால், அவற்றுக்கிடையே சுழல indicator ஐ right-click செய்யவும்.

நிறுவலின் போது வழங்கப்படும் அதே தேர்வுகளிலிருந்து English மற்றும் French போன்ற அமைப்புகளைத் தேர்ந்தெடுக்க _Setup > Typing > Keyboard Layouts_ ஐப் பயன்படுத்தவும். எந்த composition engines செயலில் உள்ளன என்பதைத் தேர்ந்தெடுக்க _Setup > Typing > Input Methods_ ஐப் பயன்படுத்தவும். இரண்டு pickers உம் Omarchy menu க்குள் உங்கள் தற்போதைய தேர்வுகள் தேர்ந்தெடுக்கப்பட்ட நிலையில் திறக்கும். ஒரு தேர்வை மாற்ற click செய்யவும் அல்லது Enter ஐ அழுத்தவும்; ஒவ்வொரு மாற்றமும் உடனடியாகப் பயன்படுத்தப்படும். ஒரு input method ஐத் தேர்வுநீக்குவது அதை நிறுவல்நீக்காமல் சுழற்சியிலிருந்து நீக்குகிறது; விசைப்பலகை தொடர்ந்து கிடைக்கும்.

அதே pickers ஐத் திறக்க `omarchy setup keyboard` அல்லது `omarchy setup input` ஐ இயக்கவும். command line இலிருந்து ஒரு மொழியைச் சேர்க்க, `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, அல்லது `cangjie5` ஐப் பயன்படுத்தவும். Quick, Boshiamy, மற்றும் Array ஆகியவை Cangjie உடன் அதே package இல் வருகின்றன மற்றும் Input Methods picker இல் தோன்றும். உங்கள் தனிப்பயன் switching keys பாதுகாக்கப்படும். மாற்று engine அமைப்புகள் அல்லது விசைகளுக்கு, `omarchy pkg add fcitx5-configtool` உடன் `fcitx5-configtool` ஐ நிறுவி terminal இலிருந்து அதைத் தொடங்கவும். ஒரு உள்ளீட்டு மொழியைத் தேர்ந்தெடுப்பது desktop மொழியை மாற்றாது. _Setup > Language_ இன் கீழ் Japanese, Korean, அல்லது Chinese ஐத் தேர்ந்தெடுப்பது, உங்களிடம் இன்னும் எதுவும் இல்லாதபோது அதன் input method ஐச் சேர்க்கிறது.

input methods அல்லது விசைப்பலகை அமைப்புகள் வழியாகச் சுழல `Super + I` ஐப் பயன்படுத்தவும், மற்ற திசையில் திரும்பிச் செல்ல `Super + Shift + I` ஐப் பயன்படுத்தவும், எனவே மூன்று உள்ளமைக்கப்பட்டிருந்தால் நீங்கள் இரண்டு அண்டை நிலைகளுக்கு இடையே நகரலாம். ஒன்றுக்கு மேற்பட்ட input method அல்லது அமைப்பு உள்ளமைக்கப்பட்டிருக்கும்போது மட்டுமே உள்ளீட்டு indicator bar இன் வலதுபுறத்தில் தோன்றும். இந்த desktop binding உங்கள் ஏற்கனவே உள்ள Fcitx switching keys உடன் இணைந்து செயல்படுகிறது; நீங்கள் அதை `~/.config/hypr/bindings.lua` இல் மாற்றலாம். input engines மற்றும் compose sequences ஒவ்வொரு session இலும் ஏற்கனவே இயங்கும் [Fcitx5](https://fcitx-im.org/) service ஐப் பயன்படுத்துகின்றன.

### ALT ஐ SUPER ஆகப் பயன்படுத்தவும்

சில விசைப்பலகைகளில், முதன்மை meta key (Windows/cmd key) ஐ SUPER ஆகப் பயன்படுத்துவது வசதியாக இல்லை. அதற்குப் பதிலாக இதை ALT ஆக மாற்ற இந்த மாற்றத்தைப் பயன்படுத்தலாம்:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
