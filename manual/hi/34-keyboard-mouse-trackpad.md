# कीबोर्ड, माउस, ट्रैकपैड

Hyprland आपको अपने सभी इनपुट को बहुत विस्तार से कॉन्फ़िगर करने देता है। आप कीबोर्ड रिपीट को सुपरसोनिक तेज़ बना सकते हैं या ट्रैकपैड को नैचुरल स्क्रॉलिंग का उपयोग करने के लिए सेट कर सकते हैं। आप यह सब `~/.config/hypr/input.lua` में बदलते हैं, जहाँ आप Omarchy मेनू (`Super + Space`) में _Setup > Input_ के ज़रिए भी पहुँच सकते हैं। वहाँ आप जो कुछ भी सेट करते हैं, वह Omarchy के डिफ़ॉल्ट की जगह ले लेता है।

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

CapsLock एक सामान्य Caps Lock की तरह काम करता है, और `Shift + CapsLock` [त्वरित इमोजी](07-hotkeys.md#quick-emojis) और [अन्य पूर्णताओं](07-hotkeys.md#quick-completions) के लिए compose कुंजी है। अगर आप compose कुंजी कहीं और रखना चाहेंगे, तो `kb_options` में `omarchy:shift_caps_compose` को बदल दें। उदाहरण के लिए, यह compose कुंजी को Right Alt पर ले जाता है:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ट्रैकपैड जेस्चर

आप [टचपैड जेस्चर](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) भी चालू कर सकते हैं, जैसे वर्कस्पेस बदलने के लिए तीन उंगलियों से स्वाइप करना:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

हैप्टिक टचपैड वाले Dell XPS लैपटॉप पर, आप _Trigger > Hardware > Touchpad Haptics_ के तहत क्लिक की मज़बूती को low, mid या high पर भी सेट कर सकते हैं।

### चीनी, जापानी और अन्य भाषाओं में टाइप करना

जब इंस्टॉलर आपके कीबोर्ड के बारे में पूछे, तो Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) या Hong Kong (Cangjie) चुनें। Omarchy कीबोर्ड और उससे मेल खाने वाले इनपुट इंजन को स्वचालित रूप से कॉन्फ़िगर कर देता है, ऑफ़लाइन first-boot सेटअप के दौरान भी। Japanese Mozc का उपयोग करता है, Korean मानक two-set Hangul का उपयोग करता है, Simplified Chinese Pinyin का उपयोग करता है, Taiwan Chewing की मानक Zhuyin व्यवस्था का उपयोग करता है, और Hong Kong Hong Kong वर्ण रूपों के साथ Cangjie का उपयोग करता है। Japanese (US keyboard) US कीबोर्ड लेआउट के साथ Mozc प्रदान करता है। Hangul, Zhuyin और Cangjie कुंजियाँ अपने मानक स्थानों पर रहती हैं, तब भी जब आप Dvorak, Colemak या AZERTY के साथ लैटिन अक्षर टाइप करते हैं। अगर आपने इससे पहले Hangul या Chewing जोड़ा था, तो उसकी कुंजियों को वहाँ ले जाने के लिए _Setup > Typing > Input Methods_ के तहत उसे अचयनित करके फिर से चुनें; Omarchy उस इंजन को नहीं छेड़ता जिसके साथ आप पहले से टाइप करते हैं।

टाइपिंग Latin मोड में शुरू होती है। कॉन्फ़िगर किए गए इनपुट तरीकों के बीच चक्र लगाने के लिए `Super + I` दबाएँ, और वापस चक्र लगाने के लिए `Super + Shift + I` दबाएँ। Pinyin जैसे किसी इनपुट तरीके से बाहर निकलकर लैटिन अक्षरों में आने के लिए अकेले `Shift` को टैप करें, और वापस जाने के लिए उसे फिर से टैप करें, ठीक वैसे ही जैसे Sogou, Microsoft Pinyin और macOS काम करते हैं; `Shift` के साथ कोई अक्षर दबाने पर अब भी बड़ा अक्षर टाइप होता है। जापानी कीबोर्ड पर, 全角/半角 इनपुट को टॉगल करता है, 変換 उसे चालू करता है, और 無変換 उसे बंद करता है। Korean के साथ, 한/영 Hangul को स्विच करता है और 한자 Hanja में बदलता है, चाहे आपके कीबोर्ड में समर्पित कुंजियाँ हों या वह उनके लिए Right Alt और Right Ctrl भेजता हो, जैसा कि कई लैपटॉप करते हैं, इसलिए Right Alt और Right Ctrl वहाँ साधारण मॉडिफ़ायर नहीं हैं; डिक्टेशन पुश-टू-टॉक F9 पर रहता है। `Ctrl + Space` Tmux और Herdr के लिए उपलब्ध रहता है; `Shift + CapsLock` compose कुंजी बना रहता है।

जब आपके पास कई कीबोर्ड लेआउट या इनपुट तरीके होते हैं, तो कीबोर्ड संकेतक बार के दाईं ओर दिखाई देता है। इनपुट भाषाएँ स्विच करने के लिए उस पर क्लिक करें; Japanese हीरागाना के लिए あ प्रदर्शित करता है। जापानी वर्ण विकल्पों के लिए, Japanese पर स्विच करें, `nihongo` जैसा कोई शब्द टाइप करें, फिर Space दो बार दबाएँ। अपनी पसंद स्वीकार करने के लिए Enter दबाएँ। अगर आपके पास कई कीबोर्ड लेआउट भी हैं, तो उनके बीच चक्र लगाने के लिए संकेतक पर राइट-क्लिक करें।

English और French जैसे लेआउट चुनने के लिए _Setup > Typing > Keyboard Layouts_ का उपयोग करें, उन्हीं विकल्पों में से जो इंस्टॉलेशन के दौरान दिए जाते हैं। कौन से कंपोज़िशन इंजन सक्रिय हैं, यह चुनने के लिए _Setup > Typing > Input Methods_ का उपयोग करें। दोनों पिकर Omarchy मेनू के अंदर खुलते हैं, जिनमें आपके वर्तमान चयन चेक किए हुए होते हैं। किसी विकल्प को टॉगल करने के लिए क्लिक करें या Enter दबाएँ; हर बदलाव तुरंत लागू होता है। किसी इनपुट तरीके को अचयनित करने से वह उसे अनइंस्टॉल किए बिना चक्र से हट जाता है; कीबोर्ड उपलब्ध रहता है।

वही पिकर खोलने के लिए `omarchy setup keyboard` या `omarchy setup input` चलाएँ। कमांड लाइन से एक भाषा जोड़ने के लिए, `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` या `cangjie5` का उपयोग करें। Quick, Boshiamy और Array Cangjie के साथ उसी पैकेज में आते हैं और Input Methods पिकर में दिखाई देते हैं। आपकी कस्टम स्विचिंग कुंजियाँ सुरक्षित रहती हैं। वैकल्पिक इंजन लेआउट या कुंजियों के लिए, `omarchy pkg add fcitx5-configtool` के साथ `fcitx5-configtool` इंस्टॉल करें और उसे टर्मिनल से लॉन्च करें। इनपुट भाषा चुनने से डेस्कटॉप भाषा नहीं बदलती। _Setup > Language_ के तहत Japanese, Korean या Chinese चुनने पर, जब आपके पास अभी तक कोई इनपुट तरीका नहीं है, तो उसका इनपुट तरीका जुड़ जाता है।

इनपुट तरीकों या कीबोर्ड लेआउट के बीच चक्र लगाने के लिए `Super + I` का उपयोग करें, और दूसरी दिशा में वापस जाने के लिए `Super + Shift + I` का उपयोग करें, ताकि तीन कॉन्फ़िगर किए हुए होने पर आप दो पड़ोसियों के बीच आ-जा सकें। इनपुट संकेतक बार के दाईं ओर तभी दिखाई देता है जब एक से अधिक इनपुट तरीका या लेआउट कॉन्फ़िगर किया गया हो। यह डेस्कटॉप बाइंडिंग आपकी मौजूदा Fcitx स्विचिंग कुंजियों के साथ-साथ काम करती है; आप इसे `~/.config/hypr/bindings.lua` में ओवरराइड कर सकते हैं। इनपुट इंजन और compose अनुक्रम हर सत्र में पहले से चल रही [Fcitx5](https://fcitx-im.org/) सेवा का उपयोग करते हैं।

### ALT को SUPER के रूप में उपयोग करें

कुछ कीबोर्ड पर, प्राथमिक meta कुंजी (Windows/cmd कुंजी) को SUPER के रूप में उपयोग करना सुविधाजनक नहीं होता। आप इस बदलाव का उपयोग करके इसे इसके बजाय ALT बना सकते हैं:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
