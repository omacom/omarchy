# कीबोर्ड, माउस, ट्रैकपैड

Hyprland आपको अपने सभी इनपुट को बहुत विस्तार से कॉन्फ़िगर करने देता है। आप कीबोर्ड रिपीट को सुपरसोनिक गति जितना तेज़ कर सकते हैं या ट्रैकपैड को नैचुरल स्क्रॉलिंग इस्तेमाल करने के लिए सेट कर सकते हैं। आप यह सब `~/.config/hypr/input.lua` में बदलते हैं, जिस तक आप Omarchy मेनू (`Super + Space`) में _Setup > Input_ के ज़रिए भी पहुँच सकते हैं। वहाँ आप जो कुछ भी सेट करते हैं, वह Omarchy के डिफ़ॉल्ट की जगह ले लेता है।

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

आप इनपुट के लिए Hyprland विकी पर [सभी इनपुट विकल्प देख सकते हैं](https://wiki.hypr.land/Configuring/Basics/Variables/#input)।

CapsLock सामान्य Caps Lock की तरह काम करता है, और `Shift + CapsLock` [क्विक इमोजी](07-hotkeys.md#quick-emojis) और [अन्य कंप्लीशन](07-hotkeys.md#quick-completions) के लिए कंपोज़ की है। अगर आप कंपोज़ की को कहीं और रखना पसंद करते हैं, तो `kb_options` में `omarchy:shift_caps_compose` को बदल दें। उदाहरण के लिए, यह कंपोज़ की को Right Alt पर ले जाता है:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ट्रैकपैड जेस्चर

डेस्कटॉप पर इधर-उधर जाने के लिए ट्रैकपैड पर स्वाइप करें:

| जेस्चर | ऐक्शन |
| --- | --- |
| तीन उँगलियाँ बाएँ / दाएँ | पिछला / अगला वर्कस्पेस, खाली वर्कस्पेस समेत |
| तीन उँगलियाँ ऊपर | AI कंसोल टॉगल करें |
| तीन उँगलियाँ नीचे | Omarchy मेनू खोलें |
| चार उँगलियाँ बाएँ / दाएँ | सक्रिय विंडो को पिछले / अगले वर्कस्पेस पर ले जाएँ |
| चार उँगलियाँ नीचे | फ़ुलस्क्रीन टॉगल करें |

किसी एक को बदलने के लिए, अपना ख़ुद का [टचपैड जेस्चर](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) जोड़ने से पहले उसे `~/.config/hypr/input.lua` में अनसेट करें, क्योंकि Hyprland एक ही उँगलियों और एक ही दिशा पर दो जेस्चर स्वीकार नहीं करेगा:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy के सभी जेस्चर बंद करने के लिए, Omarchy के डिफ़ॉल्ट लोड होने से पहले, `~/.config/hypr/hyprland.lua` के शीर्ष के पास `omarchy_default_gestures = false` सेट करें।

haptic टचपैड वाले Dell XPS लैपटॉप पर, आप _Trigger > Hardware > Touchpad Haptics_ के अंतर्गत क्लिक की ताक़त को कम, मध्यम या ज़्यादा पर भी सेट कर सकते हैं।

### चीनी, जापानी और अन्य भाषाओं में टाइप करना

जब इंस्टॉलर आपके कीबोर्ड के बारे में पूछे, तो Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) या Hong Kong (Cangjie) चुनें। Omarchy कीबोर्ड और उससे मेल खाने वाले इनपुट इंजन को अपने आप कॉन्फ़िगर कर देता है, ऑफ़लाइन फ़र्स्ट-बूट सेटअप के दौरान भी। Japanese में Mozc इस्तेमाल होता है, Korean में मानक two-set Hangul इस्तेमाल होता है, Simplified Chinese में Pinyin इस्तेमाल होता है, Taiwan में Chewing की मानक Zhuyin व्यवस्था इस्तेमाल होती है, और Hong Kong में Hong Kong अक्षर रूपों के साथ Cangjie इस्तेमाल होता है। Japanese (US keyboard) US कीबोर्ड लेआउट के साथ Mozc प्रदान करता है। Hangul, Zhuyin और Cangjie की कीज़ अपनी मानक स्थितियों में ही रहती हैं, तब भी जब आप Dvorak, Colemak या AZERTY के साथ Latin अक्षर टाइप करते हैं। अगर आपने इससे पहले Hangul या Chewing जोड़ा था, तो उसकी कीज़ को वहाँ ले जाने के लिए उसे _Setup > Typing > Input Methods_ के अंतर्गत अचयनित करके फिर से चुनें; Omarchy उस इंजन को अकेला छोड़ देता है जिसके साथ आप पहले से टाइप करते हैं।

टाइपिंग Latin मोड में शुरू होती है। कॉन्फ़िगर किए गए इनपुट मेथड के बीच चक्र लगाने के लिए `Super + I` दबाएँ, और वापस चक्र लगाने के लिए `Super + Shift + I` दबाएँ। Pinyin जैसी किसी इनपुट मेथड से बाहर निकलकर Latin अक्षरों पर जाने के लिए अकेले `Shift` को टैप करें, और वापस जाने के लिए उसे फिर से टैप करें, ठीक वैसे ही जैसे Sogou, Microsoft Pinyin और macOS काम करते हैं; `Shift` के साथ कोई अक्षर दबाने पर अब भी बड़ा अक्षर टाइप होता है। Japanese कीबोर्ड पर, 全角/半角 इनपुट को टॉगल करता है, 変換 उसे चालू करता है, और 無変換 उसे बंद करता है। Korean के साथ, 한/영 Hangul को स्विच करता है और 한자 Hanja में बदलता है, चाहे आपके कीबोर्ड में इसके लिए समर्पित कीज़ हों या वह उनके लिए Right Alt और Right Ctrl भेजता हो, जैसा कि कई लैपटॉप करते हैं, इसलिए वहाँ Right Alt और Right Ctrl साधारण मॉडिफ़ायर नहीं हैं; इसके बजाय डिक्टेशन Alt + Space से टॉगल होता है। `Ctrl + Space` Tmux और Herdr के लिए उपलब्ध रहता है; `Shift + CapsLock` कंपोज़ की बना रहता है।

जब आपके पास कई कीबोर्ड लेआउट या इनपुट मेथड होते हैं, तो कीबोर्ड इंडिकेटर बार के दाईं ओर दिखाई देता है। इनपुट भाषाएँ बदलने के लिए उस पर क्लिक करें; Japanese में hiragana के लिए あ दिखता है। Japanese अक्षरों के विकल्पों के लिए, Japanese पर स्विच करें, `nihongo` जैसा कोई शब्द टाइप करें, फिर Space को दो बार दबाएँ। अपनी पसंद स्वीकार करने के लिए Enter दबाएँ। अगर आपके पास कई कीबोर्ड लेआउट भी हैं, तो उनके बीच चक्र लगाने के लिए इंडिकेटर पर राइट-क्लिक करें।

English और French जैसे लेआउट चुनने के लिए _Setup > Typing > Keyboard Layouts_ का इस्तेमाल करें, इंस्टॉलेशन के दौरान दिए गए उन्हीं विकल्पों में से। कौन से कंपोज़िशन इंजन सक्रिय हैं, यह चुनने के लिए _Setup > Typing > Input Methods_ का इस्तेमाल करें। दोनों पिकर Omarchy मेनू के अंदर खुलते हैं, जिनमें आपके मौजूदा चयन चेक किए हुए होते हैं। किसी विकल्प को टॉगल करने के लिए क्लिक करें या Enter दबाएँ; हर बदलाव तुरंत लागू हो जाता है। किसी इनपुट मेथड को अचयनित करने से वह उसे अनइंस्टॉल किए बिना चक्र से हट जाता है; कीबोर्ड उपलब्ध रहता है।

वही पिकर खोलने के लिए `omarchy setup keyboard` या `omarchy setup input` चलाएँ। कमांड लाइन से एक भाषा जोड़ने के लिए, `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` या `cangjie5` का इस्तेमाल करें। Quick, Boshiamy और Array Cangjie वाले ही पैकेज में आते हैं और Input Methods पिकर में दिखाई देते हैं। आपकी कस्टम स्विचिंग कीज़ सुरक्षित रहती हैं। वैकल्पिक इंजन लेआउट या कीज़ के लिए, `omarchy pkg add fcitx5-configtool` के साथ `fcitx5-configtool` इंस्टॉल करें और उसे टर्मिनल से लॉन्च करें। कोई इनपुट भाषा चुनने से डेस्कटॉप की भाषा नहीं बदलती। जब आपके पास अभी तक कोई इनपुट मेथड न हो, तो _Setup > Language_ के अंतर्गत Japanese, Korean या Chinese चुनने से उसका इनपुट मेथड जुड़ जाता है।

इनपुट मेथड या कीबोर्ड लेआउट के बीच चक्र लगाने के लिए `Super + I` का इस्तेमाल करें, और दूसरी दिशा में वापस जाने के लिए `Super + Shift + I` का इस्तेमाल करें, ताकि तीन कॉन्फ़िगर होने पर आप दो पड़ोसियों के बीच आ-जा सकें। इनपुट इंडिकेटर बार के दाईं ओर केवल तभी दिखाई देता है जब एक से ज़्यादा इनपुट मेथड या लेआउट कॉन्फ़िगर किया गया हो। यह डेस्कटॉप बाइंडिंग आपकी मौजूदा Fcitx स्विचिंग कीज़ के साथ-साथ काम करती है; आप इसे `~/.config/hypr/bindings.lua` में ओवरराइड कर सकते हैं। इनपुट इंजन और कंपोज़ सीक्वेंस हर सेशन में पहले से चल रही [Fcitx5](https://fcitx-im.org/) सेवा का इस्तेमाल करते हैं।

### ALT को SUPER के रूप में इस्तेमाल करें

कुछ कीबोर्ड पर, प्राथमिक मेटा की (Windows/cmd की) को SUPER के रूप में इस्तेमाल करना सुविधाजनक नहीं होता। आप इस बदलाव का इस्तेमाल करके इसे इसके बजाय ALT बना सकते हैं:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
