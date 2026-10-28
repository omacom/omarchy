# कीबोर्ड, माउस, ट्रैकपैड

Hyprland आपको अपने सभी inputs को बेहद बारीकी से configure करने देता है। आप keyboard repeat को सुपरसोनिक रफ़्तार वाला बना सकते हैं या trackpad पर natural scrolling इस्तेमाल कर सकते हैं। आप यह सब `~/.config/hypr/input.lua` में बदलते हैं, जहाँ आप Omarchy मेनू (`Super + Space`) में _Setup > Input_ के ज़रिए भी पहुँच सकते हैं। वहाँ आप जो कुछ भी set करेंगे, वह Omarchy के defaults की जगह ले लेगा।

यहाँ एक उदाहरण है:

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

आप Hyprland wiki पर inputs के लिए [सभी input options देख सकते हैं](https://wiki.hypr.land/Configuring/Basics/Variables/#input)।

CapsLock सामान्य Caps Lock की तरह काम करता है, और `Shift + CapsLock` [quick emojis](07-hotkeys.md#quick-emojis) और [अन्य completions](07-hotkeys.md#quick-completions) के लिए compose key है। अगर आप compose key कहीं और रखना चाहें, तो `kb_options` में `omarchy:shift_caps_compose` को बदल दें। उदाहरण के लिए, यह compose key को Right Alt पर ले जाता है:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Trackpad gestures

Desktop पर इधर-उधर जाने के लिए trackpad पर swipe करें:

| Gesture | Action |
| --- | --- |
| तीन उँगलियाँ बाएँ / दाएँ | पिछला / अगला workspace, खाली workspaces समेत |
| तीन उँगलियाँ ऊपर | AI console टॉगल करें |
| तीन उँगलियाँ नीचे | Omarchy मेनू खोलें |
| चार उँगलियाँ बाएँ / दाएँ | सक्रिय window को पिछले / अगले workspace पर ले जाएँ |
| चार उँगलियाँ नीचे | Fullscreen टॉगल करें |

किसी एक को बदलने के लिए, अपना खुद का [touchpad gesture](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) जोड़ने से पहले उसे `~/.config/hypr/input.lua` में unset करें, क्योंकि Hyprland एक ही उँगलियों और दिशा पर दो gestures स्वीकार नहीं करेगा:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy के सभी gestures बंद करने के लिए, Omarchy के defaults load होने से पहले, `~/.config/hypr/hyprland.lua` के शीर्ष के पास `omarchy_default_gestures = false` set करें।

Haptic touchpad वाले Dell XPS laptops पर, आप _Trigger > Hardware > Touchpad Haptics_ के तहत click strength को low, mid या high पर भी set कर सकते हैं।

### चीनी, जापानी और अन्य भाषाओं में typing

जब installer आपके keyboard के बारे में पूछे, तो Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) या Hong Kong (Cangjie) चुनें। Omarchy keyboard और उससे मेल खाने वाले input engine को स्वचालित रूप से configure कर देता है, offline first-boot setup के दौरान भी। Japanese में Mozc इस्तेमाल होता है, Korean में standard two-set Hangul इस्तेमाल होता है, Simplified Chinese में Pinyin इस्तेमाल होता है, Taiwan में Chewing की standard Zhuyin व्यवस्था इस्तेमाल होती है, और Hong Kong में Hong Kong character forms के साथ Cangjie इस्तेमाल होता है। Japanese (US keyboard) US keyboard layout के साथ Mozc देता है। Hangul, Zhuyin और Cangjie keys अपनी standard स्थितियों में ही रहती हैं, तब भी जब आप Dvorak, Colemak या AZERTY से Latin अक्षर type करते हैं। अगर आपने इससे पहले Hangul या Chewing जोड़ा था, तो उसकी keys को वहाँ ले जाने के लिए _Setup > Typing > Input Methods_ के तहत उसे deselect करके फिर से select करें; Omarchy उस engine को अकेला छोड़ देता है जिसके साथ आप पहले से type कर रहे हैं।

Typing Latin mode में शुरू होती है। Configure किए गए input methods के बीच cycle करने के लिए `Super + I` दबाएँ, और वापस cycle करने के लिए `Super + Shift + I` दबाएँ। Pinyin जैसे किसी input method से बाहर निकलकर Latin अक्षरों में आने के लिए अकेले `Shift` tap करें, और वापस जाने के लिए उसे फिर tap करें, बिल्कुल वैसे ही जैसे Sogou, Microsoft Pinyin और macOS काम करते हैं; `Shift` के साथ कोई अक्षर दबाने से अब भी बड़ा अक्षर type होता है। Japanese keyboards पर, 全角/半角 input टॉगल करता है, 変換 उसे चालू करता है, और 無変換 उसे बंद करता है। Korean के साथ, 한/영 Hangul switch करता है और 한자 Hanja में convert करता है, चाहे आपके keyboard में dedicated keys हों या वह उनके लिए Right Alt और Right Ctrl भेजता हो, जैसा कि कई laptops करते हैं, इसलिए वहाँ Right Alt और Right Ctrl plain modifiers नहीं हैं; dictation push-to-talk F9 पर ही रहता है। `Ctrl + Space` Tmux और Herdr के लिए उपलब्ध रहता है; `Shift + CapsLock` compose key ही रहता है।

जब आपके पास कई keyboard layouts या input methods होते हैं, तो keyboard indicator bar के दाईं ओर दिखाई देता है। Input भाषाएँ switch करने के लिए उस पर click करें; Japanese में hiragana के लिए あ दिखता है। Japanese character विकल्पों के लिए, Japanese पर switch करें, `nihongo` जैसा कोई शब्द type करें, फिर Space दो बार दबाएँ। अपनी पसंद स्वीकार करने के लिए Enter दबाएँ। अगर आपके पास कई keyboard layouts भी हैं, तो उनके बीच cycle करने के लिए indicator पर right-click करें।

English और French जैसे layouts चुनने के लिए _Setup > Typing > Keyboard Layouts_ इस्तेमाल करें, उन्हीं विकल्पों में से जो installation के दौरान दिए जाते हैं। कौन से composition engines सक्रिय हैं, यह चुनने के लिए _Setup > Typing > Input Methods_ इस्तेमाल करें। दोनों pickers Omarchy मेनू के अंदर खुलते हैं, जिनमें आपके मौजूदा selections पर निशान लगे होते हैं। किसी विकल्प को टॉगल करने के लिए click करें या Enter दबाएँ; हर बदलाव तुरंत लागू होता है। किसी input method को deselect करने से वह cycle से हट जाता है, uninstall नहीं होता; keyboard उपलब्ध रहता है।

वही pickers खोलने के लिए `omarchy setup keyboard` या `omarchy setup input` चलाएँ। Command line से एक भाषा जोड़ने के लिए, `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` या `cangjie5` इस्तेमाल करें। Quick, Boshiamy और Array Cangjie वाले ही package में आते हैं और Input Methods picker में दिखाई देते हैं। आपकी custom switching keys सुरक्षित रहती हैं। वैकल्पिक engine layouts या keys के लिए, `omarchy pkg add fcitx5-configtool` से `fcitx5-configtool` install करें और उसे terminal से launch करें। कोई input भाषा चुनने से desktop भाषा नहीं बदलती। _Setup > Language_ के तहत Japanese, Korean या Chinese चुनने पर, अगर आपके पास अभी कोई input method नहीं है, तो उसका input method जुड़ जाता है।

Input methods या keyboard layouts के बीच cycle करने के लिए `Super + I` इस्तेमाल करें, और दूसरी ओर वापस जाने के लिए `Super + Shift + I` इस्तेमाल करें, ताकि तीन configure होने पर आप दो पड़ोसियों के बीच आ-जा सकें। Input indicator bar के दाईं ओर केवल तभी दिखाई देता है जब एक से अधिक input method या layout configure हो। यह desktop binding आपकी मौजूदा Fcitx switching keys के साथ-साथ काम करती है; आप इसे `~/.config/hypr/bindings.lua` में override कर सकते हैं। Input engines और compose sequences हर session में पहले से चल रही [Fcitx5](https://fcitx-im.org/) service का इस्तेमाल करते हैं।

### ALT को SUPER के रूप में इस्तेमाल करें

कुछ keyboards पर, primary meta key (Windows/cmd key) को SUPER के रूप में इस्तेमाल करना सुविधाजनक नहीं होता। आप इस बदलाव से उसे बदलकर ALT कर सकते हैं:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
