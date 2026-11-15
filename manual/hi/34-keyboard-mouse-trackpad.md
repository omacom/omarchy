# कीबोर्ड, माउस, ट्रैकपैड

Hyprland आपको अपने सभी इनपुट को बहुत विस्तार से कॉन्फ़िगर करने देता है। आप कीबोर्ड रिपीट को सुपरसोनिक तेज़ कर सकते हैं या ट्रैकपैड में natural scrolling का इस्तेमाल कर सकते हैं। आप यह सब `~/.config/hypr/input.lua` में बदलते हैं, जिसे आप Omarchy मेनू (`Super + Space`) में _Setup > Input_ के ज़रिए भी खोल सकते हैं। वहाँ आप जो कुछ भी सेट करते हैं, वह Omarchy के डिफ़ॉल्ट की जगह ले लेता है।

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

आप Hyprland wiki पर इनपुट के लिए [सभी इनपुट विकल्प देख सकते हैं](https://wiki.hypr.land/Configuring/Basics/Variables/#input)।

CapsLock सामान्य Caps Lock की तरह काम करता है, और `Shift + CapsLock` [quick emojis](07-hotkeys.md#quick-emojis) और [अन्य completions](07-hotkeys.md#quick-completions) के लिए compose कुंजी है। अगर आप compose कुंजी कहीं और रखना चाहते हैं, तो `kb_options` में `omarchy:shift_caps_compose` को बदल दें। उदाहरण के लिए, यह compose कुंजी को Right Alt पर ले जाता है:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Function कुंजियाँ

लैपटॉप कीबोर्ड की सबसे ऊपरी पंक्ति डिफ़ॉल्ट रूप से मीडिया कुंजियाँ (वॉल्यूम, ब्राइटनेस आदि) भेजती है, और `Fn` दबाए रखने से F1-F12 मिलते हैं; `Fn + Esc` इसे उल्टी दिशा में लॉक कर देता है, जब तक आप इसे फिर से न दबाएँ। ज़्यादातर कीबोर्ड वह लॉक खुद याद रखते हैं। ASUS लैपटॉप और Apple-शैली के कीबोर्ड इसे Linux पर छोड़ देते हैं, जो हर बूट पर उन्हें मीडिया कुंजियों पर शुरू करता है। इसके बजाय उन्हें F1-F12 पर शुरू करने के लिए `omarchy keyboard toprow fnkeys` चलाएँ (और वापस जाने के लिए `omarchy keyboard toprow mediakeys` चलाएँ); कुछ लैपटॉप पर यह रीबूट के बाद प्रभावी होता है। Apple Silicon Macs अपनी खुद की सेटिंग रखते हैं।

### ट्रैकपैड जेस्चर

डेस्कटॉप पर इधर-उधर जाने के लिए ट्रैकपैड पर स्वाइप करें:

| जेस्चर | कार्रवाई |
| --- | --- |
| तीन उंगलियाँ बाएँ / दाएँ | पिछला / अगला workspace, खाली वालों समेत |
| तीन उंगलियाँ ऊपर | AI कंसोल को टॉगल करें |
| तीन उंगलियाँ नीचे | Omarchy मेनू खोलें |
| चार उंगलियाँ बाएँ / दाएँ | सक्रिय विंडो को पिछले / अगले workspace में ले जाएँ |
| चार उंगलियाँ नीचे | fullscreen टॉगल करें |

किसी एक को बदलने के लिए, अपना खुद का [touchpad gesture](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) जोड़ने से पहले उसे `~/.config/hypr/input.lua` में अनसेट करें, क्योंकि Hyprland एक ही उंगलियों और दिशा पर दो जेस्चर नहीं लेगा:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy के सभी जेस्चर बंद करने के लिए, Omarchy के डिफ़ॉल्ट लोड होने से पहले, `~/.config/hypr/hyprland.lua` के शीर्ष के पास `omarchy_default_gestures = false` सेट करें।

haptic टचपैड वाले Dell XPS लैपटॉप पर, आप _Trigger > Hardware > Touchpad Haptics_ के अंतर्गत क्लिक की मज़बूती को low, mid या high पर भी सेट कर सकते हैं।

### चीनी, जापानी और अन्य भाषाओं में टाइप करना

जब इंस्टॉलर आपका कीबोर्ड पूछे, तब Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) या Hong Kong (Cangjie) चुनें। Omarchy कीबोर्ड और उससे मेल खाने वाले इनपुट इंजन को अपने आप कॉन्फ़िगर कर देता है, ऑफ़लाइन first-boot सेटअप के दौरान भी। Japanese में Mozc का इस्तेमाल होता है, Korean में मानक two-set Hangul का, Simplified Chinese में Pinyin का, Taiwan में Chewing की मानक Zhuyin व्यवस्था का, और Hong Kong में Hong Kong वर्ण रूपों के साथ Cangjie का इस्तेमाल होता है। Japanese (US keyboard) US कीबोर्ड लेआउट के साथ Mozc देता है। Hangul, Zhuyin और Cangjie कुंजियाँ अपने मानक स्थानों पर रहती हैं, तब भी जब आप Dvorak, Colemak या AZERTY के साथ Latin अक्षर टाइप करते हैं। अगर आपने इससे पहले Hangul या Chewing जोड़ा था, तो उसकी कुंजियों को वहाँ ले जाने के लिए _Setup > Keyboard > Input Methods_ के अंतर्गत उसे अचयनित करके फिर से चुनें; Omarchy उस इंजन को अकेला छोड़ देता है जिसके साथ आप पहले से टाइप करते हैं।

टाइपिंग Latin मोड में शुरू होती है। कॉन्फ़िगर किए गए इनपुट तरीकों में चक्र लगाने के लिए `Super + I` दबाएँ, और वापस चक्र लगाने के लिए `Super + Shift + I` दबाएँ। Pinyin जैसे इनपुट तरीके से बाहर निकलकर Latin अक्षरों में जाने के लिए अकेले `Shift` को टैप करें, और वापस जाने के लिए उसे फिर से टैप करें, ठीक वैसे ही जैसे Sogou, Microsoft Pinyin और macOS काम करते हैं; `Shift` और कोई अक्षर मिलकर अभी भी बड़ा अक्षर टाइप करता है। जापानी कीबोर्ड पर, 全角/半角 इनपुट को टॉगल करता है, 変換 उसे चालू करता है, और 無変換 उसे बंद करता है। Korean के साथ, 한/영 Hangul को बदलता है और 한자 Hanja में बदलता है, चाहे आपके कीबोर्ड में इसके लिए समर्पित कुंजियाँ हों या वह उनके लिए Right Alt और Right Ctrl भेजता हो, जैसा कि कई लैपटॉप करते हैं, इसलिए वहाँ Right Alt और Right Ctrl साधारण मॉडिफ़ायर नहीं हैं; इसके बजाय डिक्टेशन Alt + Space से टॉगल होता है। `Ctrl + Space` Tmux और Herdr के लिए उपलब्ध रहता है; `Shift + CapsLock` compose कुंजी बना रहता है।

जब आपके पास कई कीबोर्ड लेआउट या इनपुट तरीके होते हैं, तो कीबोर्ड संकेतक बार के दाईं ओर दिखाई देता है। इनपुट भाषाएँ बदलने के लिए उस पर क्लिक करें; Japanese hiragana के लिए あ दिखाता है। जापानी वर्ण विकल्पों के लिए, Japanese पर जाएँ, `nihongo` जैसा कोई शब्द टाइप करें, फिर Space को दो बार दबाएँ। अपनी पसंद स्वीकार करने के लिए Enter दबाएँ। अगर आपके पास कई कीबोर्ड लेआउट भी हैं, तो उनमें चक्र लगाने के लिए संकेतक पर राइट-क्लिक करें।

English और French जैसे लेआउट चुनने के लिए _Setup > Keyboard > Keyboard Inputs_ का इस्तेमाल करें, इंस्टॉलेशन के दौरान दिए गए उन्हीं विकल्पों में से। कौन से composition इंजन सक्रिय हैं, यह चुनने के लिए _Setup > Keyboard > Input Methods_ का इस्तेमाल करें। दोनों पिकर Omarchy मेनू के अंदर खुलते हैं, जिनमें आपके मौजूदा चयन चेक किए हुए होते हैं। किसी विकल्प को टॉगल करने के लिए क्लिक करें या Enter दबाएँ; हर बदलाव तुरंत लागू होता है। किसी इनपुट तरीके को अचयनित करने से वह उसे अनइंस्टॉल किए बिना चक्र से हट जाता है; कीबोर्ड उपलब्ध रहता है।

वही पिकर खोलने के लिए `omarchy setup keyboard` या `omarchy setup input` चलाएँ। कमांड लाइन से एक भाषा जोड़ने के लिए `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` या `cangjie5` का इस्तेमाल करें। Quick, Boshiamy और Array Cangjie के साथ एक ही पैकेज में आते हैं और Input Methods पिकर में दिखाई देते हैं। आपकी कस्टम स्विचिंग कुंजियाँ सुरक्षित रहती हैं। वैकल्पिक इंजन लेआउट या कुंजियों के लिए, `omarchy pkg add fcitx5-configtool` के साथ `fcitx5-configtool` इंस्टॉल करें और उसे टर्मिनल से लॉन्च करें। इनपुट भाषा चुनने से डेस्कटॉप की भाषा नहीं बदलती। जब आपके पास अभी कोई इनपुट तरीका नहीं है, तो _Setup > Language_ के अंतर्गत Japanese, Korean या Chinese चुनने से उसका इनपुट तरीका जुड़ जाता है।

इनपुट तरीकों या कीबोर्ड लेआउट में चक्र लगाने के लिए `Super + I` का इस्तेमाल करें, और दूसरी दिशा में वापस जाने के लिए `Super + Shift + I` का इस्तेमाल करें, इसलिए तीन कॉन्फ़िगर होने पर आप दो पड़ोसियों के बीच आ-जा सकते हैं। इनपुट संकेतक बार के दाईं ओर केवल तभी दिखाई देता है जब एक से ज़्यादा इनपुट तरीका या लेआउट कॉन्फ़िगर हो। यह डेस्कटॉप बाइंडिंग आपकी मौजूदा Fcitx स्विचिंग कुंजियों के साथ-साथ काम करती है; आप इसे `~/.config/hypr/bindings.lua` में बदल सकते हैं। इनपुट इंजन और compose अनुक्रम हर सत्र में पहले से चल रही [Fcitx5](https://fcitx-im.org/) सेवा का इस्तेमाल करते हैं।

### ALT को SUPER के रूप में इस्तेमाल करें

कुछ कीबोर्ड पर, प्राथमिक मेटा कुंजी (Windows/cmd कुंजी) को SUPER के रूप में इस्तेमाल करना सुविधाजनक नहीं होता। आप इस बदलाव का इस्तेमाल करके इसके बजाय ALT को इस्तेमाल कर सकते हैं:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
