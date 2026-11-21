# हॉटकीज़

आप सभी मुख्य कीबोर्ड बाइंडिंग `Super + K` से देख सकते हैं (Tmux बाइंडिंग `Super + Alt + K` से और Herdr बाइंडिंग `Super + Ctrl + K` से)।

## हॉटकीज़ कैसे व्यवस्थित हैं

हर हॉटकी एक तल पर होती है, जो उसके modifiers से तय होता है, और हर तल का एक ही काम होता है। यही हॉटकीज़ को आपस में गड़बड़ होने से रोकता है, और इसका मतलब है कि आप आमतौर पर अंदाज़ा लगा सकते हैं कि कोई चीज़ कहाँ मिलेगी।

| तल | वहाँ क्या रहता है | उदाहरण |
| --- | --- | --- |
| `Super + key` | सिस्टम: विंडो, workspaces, layouts, और मुख्य मेनू | `Super + Space` Omarchy मेनू, `Super + W` विंडो बंद करें, `Super + F` फुल स्क्रीन |
| `Super + Shift + key` | ऐप्स | `Super + Shift + B` ब्राउज़र, `Super + Shift + E` ईमेल, `Super + Shift + N` एडिटर |
| `Super + Ctrl + key` | पैनल और सिस्टम मेनू | `Super + Ctrl + A` ऑडियो, `Super + Ctrl + N` नेटवर्क, `Super + Ctrl + C` capture मेनू |
| `Super + Ctrl + Alt + key` | त्वरित कार्रवाइयाँ और सूचनाएँ | `Super + Ctrl + Alt + T` समय दिखाएं, `Super + Ctrl + Alt + B` बैटरी, `Super + Ctrl + Alt + C` स्क्रीनशॉट |

किसी हॉटकी में `Alt` जोड़ने से आपको उसी चीज़ का एक variant मिलता है, कभी कोई असंबंधित चीज़ नहीं:

- `Super + Shift + B` ब्राउज़र खोलता है; `Super + Shift + Alt + B` एक private विंडो खोलता है
- `Super + Shift + E` ईमेल खोलता है; `Super + Shift + Alt + E` एक नया ईमेल शुरू करता है
- `Super + F` फुल स्क्रीन पर जाता है; `Super + Alt + F` फुल width पर जाता है
- `Super + Ctrl + C` capture मेनू खोलता है; `Super + Ctrl + Alt + C` मेनू को छोड़कर स्क्रीनशॉट लेता है

हॉटकी जोड़ते समय:

1. वह क्या करती है, उससे तल चुनें, फिर कुंजी चुनें।
2. जगह बनाने के लिए किसी मौजूदा हॉटकी को न हटाएं। सही तल पर कोई खाली कुंजी खोजें।
3. `Alt` का इस्तेमाल केवल उसके बिना वाली हॉटकी के variant के लिए करें।

कुछ हॉटकीज़ इन नियमों को तोड़ती हैं क्योंकि वे सुविधाजनक हैं। किसी तीर या `Tab` के साथ `Shift` ऐप खोलने के बजाय ले जाता है या उलटता है, और `Print`, मीडिया कुंजियाँ, `Alt + Tab`, और `Ctrl + Alt + Del` उसी तरह काम करते हैं जैसे वे हर दूसरी जगह करते हैं। वे अपवाद हैं, नकल करने के पैटर्न नहीं।

यदि कोई default आपको पसंद नहीं आता (मान लें आप Windows की तरह स्क्रीनशॉट के लिए `Super + Shift + S` चाहते हैं), तो उसे `~/.config/hypr/bindings.lua` में rebind करें।

## नेविगेशन

| हॉटकी                  | कार्य              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy मेनू (ऐप्स और बाकी सब कुछ)    |
| `Super + Alt + Space` | ऐप ग्रिड |
| `Super + Escape` | सिस्टम मेनू (suspend, restart, आदि)  |
| `Super + Ctrl + L` | कंप्यूटर लॉक करें |
| `Super + W` or `Super + Q` | विंडो बंद करें             |
| `Ctrl + Alt + Del` | सभी विंडो बंद करें |
| `Super + K` | सभी हॉटकीज़ दिखाएं |
| `Super + Alt + K` | tmux हॉटकीज़ दिखाएं |
| `Super + Ctrl + K` | herdr हॉटकीज़ दिखाएं |
| `Super + M` | विंडो को dock पर minimize करें |
| `Super + T`               | विंडो को tiling/floating के बीच toggle करें             |
| `Super + J` | विंडो की स्थिति toggle करें (horizontal/vertical) |
| `Super + O`               | विंडो को sticky'n'floating में pop करना toggle करें |
| `Super + L`               | dwindle, scrolling, और floating layouts में चक्र लगाएं |
| `Super + Alt + L`         | layouts में उल्टा चक्र लगाएं |
| `Super + P`               | pseudo विंडो शैली toggle करें (natural v stretch) |
| `Super + F`                 | फुल स्क्रीन पर जाएं              |
| `Super + Alt + F`                 | फुल width पर जाएं              |
| `Super + Ctrl + F`                 | विंडो के अंदर फुल स्क्रीन पर जाएं              |
| `Super + 1…9/0`         | focused मॉनिटर पर विशिष्ट workspace पर जाएं (0 यानी 10) |
| `Super + Tab` | focused मॉनिटर पर अगले workspace पर जाएं |
| `Super + Shift + Tab` | focused मॉनिटर पर पिछले workspace पर जाएं |
| `Super + Ctrl + Tab` | focused मॉनिटर पर पूर्व workspace पर जाएं |
| `Super + Shift + 1…9/0` | विंडो को focused मॉनिटर पर workspace में ले जाएं |
| `Super + Shift + Alt + 1…9/0` | पीछे जाए बिना विंडो को focused मॉनिटर पर workspace में ले जाएं |
| `Super + S` | फुल scratchpad toggle करें |
| `Super + Alt + S` | विंडो को फुल scratchpad में ले जाएं |
| `Super + Grave` | Quake कंसोल toggle करें |
| `Super + Shift + Grave` | विंडो को Quake कंसोल में ले जाएं |
| `Super + Shift + Ctrl + Arrows` | विंडो को उस दिशा के मॉनिटर पर ले जाएं |
| `Super + Shift + Alt + Arrows` | workspace को उस दिशा के मॉनिटर पर ले जाएं |
| `Super + Arrow`  | तीर की दिशा में विंडो पर focus ले जाएं, स्क्रीन के किनारे पर उस ओर के मॉनिटर पर पार करके |
| `Super + Shift + Arrow`  | तीर की दिशा में दूसरी विंडो से swap करें, उस ओर के मॉनिटर पर मौजूद विंडो समेत |
| `Super + Minus` | विंडो को बाईं ओर फैलाएं |
| `Super + Equal` | विंडो को बाईं ओर सिकोड़ें |
| `Super + Shift + Minus` | विंडो को ऊपर की ओर सिकोड़ें |
| `Super + Shift + Equal` | विंडो को नीचे की ओर फैलाएं |
| `Super + Alt + Minus/Equal` | छोटे चरणों में वही resizing |
| `Super + Ctrl + Minus/Equal` | बड़े चरणों में वही resizing |
| `Super + Alt + Home` | विंडो की चौड़ाई सहेजें |
| `Super + Home` | सहेजी गई विंडो की चौड़ाई वापस लाएं |
| `Super + Left Mouse` | विंडो को इधर-उधर drag करें |
| `Super + Right Mouse` | विंडो का आकार बदलें |
| `Super + Scroll Wheel` | focused मॉनिटर पर workspaces में scroll करें |
| `Super + G`               | विंडो grouping toggle करें      |
| `Super + Alt + G`               | विंडो को grouping से बाहर ले जाएं      |
| `Super + Alt + Tab`               | grouping में विंडो के बीच चक्र लगाएं      |
| `Super + Alt + Shift + Tab`               | grouping में विंडो के बीच उल्टा चक्र लगाएं      |
| `Super + Alt + Scroll Wheel` | grouping में विंडो के बीच चक्र लगाएं |
| `Super + Alt + 1/2/3/4/5`               | grouping में विशिष्ट विंडो पर जाएं      |
| `Super + Alt + Arrow`  | विंडो को तीर की दिशा में grouping में ले जाएं, उस ओर के मॉनिटर पर मौजूद विंडो समेत |
| `Super + Ctrl + Left/Right`  | tiling group के अंदर विंडो के बीच जाएं |
| `Super + Ctrl + Z` | स्क्रीन पर zoom in करें (अधिक zoom के लिए दोहराएं) |
| `Super + Ctrl + Alt + Z` | स्क्रीन से पूरी तरह zoom out करें |
| `Super + /` | मॉनिटर scaling विकल्पों में आगे बढ़ें |
| `Super + Alt + /` | मॉनिटर scaling विकल्पों में पीछे बढ़ें |
| `Alt + Tab` | सक्रिय workspace पर विंडो में आगे चक्र लगाएं |
| `Alt + Shift + Tab` | सक्रिय workspace पर विंडो में उल्टा चक्र लगाएं |
| `Ctrl + Alt + Tab`| मॉनिटर में focus आगे चक्र लगाएं |
| `Ctrl + Alt + Shift + Tab`| मॉनिटर में focus उल्टा चक्र लगाएं |
| `Super + I` | input भाषा बदलें (एक से अधिक layout या input method के साथ) |
| `Super + Shift + I` | input भाषा वापस बदलें |

टचपैड पर, तीन- और चार-उंगली swipes workspaces बदलते हैं, विंडो ले जाते हैं, और मेनू और Quake कंसोल खोलते हैं; gestures के लिए [कीबोर्ड, माउस और ट्रैकपैड](34-keyboard-mouse-trackpad.md) देखें।

Resize शॉर्टकट भौतिक कुंजियाँ `code:20` और `code:21` (XKB `<AE11>` और `<AE12>`) इस्तेमाल करते हैं, कीबोर्ड पर छपे अक्षरों की परवाह किए बिना। US कीबोर्ड पर ये कुंजियाँ `-` और `=` हैं; जापानी (JIS) कीबोर्ड पर ये `-` और `^` हैं; स्पेनिश कीबोर्ड पर ये `'` और `¡` हैं। JIS पर, `Super + ^` ही `Super + Equal` है, जबकि `Super + Shift + -` (जो `=` टाइप करता है) ही `Super + Shift + Minus` है।

## सिस्टम नियंत्रण

| हॉटकी                  | कार्य              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | ऑडियो पैनल    |
| `Super + Ctrl + B`           | Bluetooth पैनल    |
| `Super + Ctrl + N`           | Wifi/network पैनल    |
| `Super + Ctrl + D`           | डिस्प्ले पैनल    |
| `Super + Ctrl + P`           | पावर पैनल    |
| `Super + Ctrl + X`           | Agents पैनल    |
| `Super + Ctrl + Shift + X`           | Local models पैनल    |
| `Super + Ctrl + Alt + D`           | कैलेंडर पैनल    |
| `Super + Ctrl + Alt + E`           | विश्व घड़ी पैनल    |
| `Super + Ctrl + 1-9`           | स्थिति के अनुसार bar पैनल toggle करें    |
| `Super + Ctrl + S` | Share मेनू (LocalSend के ज़रिए) |
| `Super + Ctrl + C` | Capture नियंत्रण (screenshot/-recording/picker) |
| `Super + Ctrl + O` | मेनू toggle करें |
| `Super + Ctrl + H` | Hardware मेनू |
| `Super + Ctrl + E` | Emoji picker |
| `Super + Ctrl + .` | मीडिया transcode करें |
| `Super + Shift + Ctrl + A` | AI agent चुनें |
| `Power` key | सिस्टम मेनू |
| `Super + Shift + Copilot` key | Omarchy मेनू |

## समायोजन

| हॉटकी                  | कार्य              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | स्क्रीन की अधिकतम brightness |
| `Shift + Brightness Down` | स्क्रीन की न्यूनतम brightness |
| `Alt + Brightness Up/Down` | सटीक 1% brightness बदलाव |
| `Alt + Volume Up/Down` | सटीक 1% volume बदलाव |
| `Keyboard Brightness Up/Down` | कीबोर्ड backlight अधिक तेज़/मंद |
| `Keyboard Backlight` | कीबोर्ड backlight स्तरों में चक्र लगाएं |
| `Ctrl + Brightness Up/Down` | कीबोर्ड backlight अधिक तेज़/मंद, उन कीबोर्ड पर जिनकी अपनी कुंजियाँ नहीं हैं |
| `Mic Mute` | माइक्रोफ़ोन mute करें |
| `Shift + Mute` | ऑडियो output बदलें |
| `Touchpad Toggle` | टचपैड चालू या बंद करें |
| `Display` key | workspace layout में चक्र लगाएं |
| `Alt + Play` | अगला track |
| `Alt + Shift + Play` | पिछला track |

## ऐप्स लॉन्च करना

| हॉटकी                  | कार्य              |
| ----------------------- | --------------------- |
| `Super + Return`           | टर्मिनल    |
| `Super + Alt + Return` | Tmux टर्मिनल |
| `Super + Ctrl + Return` | Herdr (agent manager) |
| `Super + Shift + Return` or `Super + Shift + B`  | ब्राउज़र    |
| `Super + Shift + Alt + B`           | ब्राउज़र (private/incognito)    |
| `Super + Shift + F`           | फ़ाइल मैनेजर    |
| `Super + Shift + Alt + F`           | टर्मिनल के cwd में फ़ाइल मैनेजर    |
| `Super + Shift + M`           | संगीत (Spotify)    |
| `Super + Shift + Alt + M`           | संगीत (cliamp)    |
| `Super + Shift + /`           | पासवर्ड मैनेजर (1password)    |
| `Super + Shift + Q` or `Calculator` key  | कैलकुलेटर (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, install होने के बाद)    |
| `Super + Shift + T`           | गतिविधि (btop)    |
| `Super + Shift + N`           | एडिटर (Plain, या आपका चुना हुआ default)  |
| `Super + Shift + C`           | कैलेंडर ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | ईमेल ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | नया ईमेल ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Messenger (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Messenger (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Messenger (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | लेखन (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (नई post) |
| `Super + Shift + Y`           | YouTube |

`~/.config/hypr/bindings.lua` में bindings बदलें/जोड़ें।

## सार्वभौमिक clipboard

| हॉटकी                  | कार्य              |
| ----------------------- | --------------------- |
| `Super + A`           | उन ऐप्स में सब चुनें जो `Ctrl + A` का समर्थन करते हैं    |
| `Super + C`           | कॉपी करें    |
| `Super + X`           | कट करें (टर्मिनल में नहीं)    |
| `Super + V`           | पेस्ट करें    |
| `Super + Ctrl + V`           | Clipboard मैनेजर    |

आमतौर पर Linux पर, टर्मिनल में copy'n'paste के लिए आपको `Ctrl + Shift + C/V` और हर दूसरी जगह के लिए `Ctrl + C/V` चाहिए होता है। ये Omarchy unified clipboard हॉटकीज़ हर जगह काम करती हैं।

## कैप्चर

| हॉटकी              | कार्य                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | स्क्रीनशॉट                      |
| `Super + Ctrl + Alt + C`            | स्क्रीनशॉट (वही shot, उन कीबोर्ड के लिए जिनमें कोई Print Screen कुंजी नहीं है) |
| `Super + Ctrl + C` | Capture मेनू |
| `Alt + Print Screen`            | स्क्रीन रिकॉर्डिंग                     |
| `Super + Shift + Ctrl + Alt + C` | बिना ऑडियो के स्क्रीन रिकॉर्डिंग, मेनू छोड़कर (रोकने के लिए फिर दबाएं) |
| `Super + Print Screen` | रंग picker |
| `Super + Ctrl + Print Screen` | clipboard पर text extraction |
| `Super + Alt + [` | रिकॉर्डिंग के दौरान webcam overlay छोटा करें |
| `Super + Alt + ]` | रिकॉर्डिंग के दौरान webcam overlay बड़ा करें |
| `Alt + Shift + L` | webapp या ब्राउज़र से वर्तमान URL कॉपी करें |
| `Alt + Shift + D` | वर्तमान पेज पर मौजूद वीडियो को `~/Videos` में डाउनलोड करें |
| `Alt + Space` | dictation शुरू/बंद करें (इसके लिए _Setup > Defaults > Dictation_ आवश्यक है) |
| `Right Alt` | dictation के लिए दबाए रखें (इसके लिए _Setup > Defaults > Dictation_ आवश्यक है) |

Screenrecordings के साथ, हॉटकी पहले पूछती है कि आप कौन-सा ऑडियो चाहते हैं, फिर रिकॉर्डिंग शुरू करती है। रोकने के लिए फिर दबाएं। विवरण के लिए [स्क्रीनशॉट और रिकॉर्डिंग](12-screenshots-recording.md) देखें।

सभी capture विकल्प Omarchy मेनू (`Super + Space`) में _Trigger > Capture_ के तहत भी उपलब्ध हैं।

## सूचनाएँ

| हॉटकी                  | कार्य              |
| ----------------------- | --------------------- |
| `Super + ,` | नवीनतम सूचना पर कार्रवाई करें: उसे खोलें या उसका एकमात्र बटन दबाएं, उसके विकल्पों में से चुनें, या जब कोई न हो तो उसे खारिज करें  |
| `Super + Shift + ,` | सभी सूचनाएँ खारिज करें |
| `Super + Ctrl + ,` | कीबोर्ड से सूचनाएँ नियंत्रित करें  |
| `Super + Alt + ,` | नवीनतम सूचना खारिज करें  |
| `Super + Shift + Alt + ,` | सूचना इतिहास खोलें  |
| `Super + Ctrl + Alt + ,` | सूचनाएँ मूक करना toggle करें  |

## शैली

| हॉटकी                  | कार्य              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | नई theme चुनें (साथ ही `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | theme background चुनें (साथ ही `Super + Ctrl + Space`) |
| `Super + Backspace` | विंडो पर transparency toggle करें |
| `Super + Ctrl + Backspace` | single-window square aspect toggle करें |

अतिरिक्त background images `~/.config/omarchy/backgrounds/<theme name>` में रहती हैं। Omarchy मेनू में _Install > Style > Background_ के ज़रिए भी उपलब्ध हैं।

सभी शैली विकल्प Omarchy मेनू (`Super + Space`) में _Appearance_ के तहत भी उपलब्ध हैं।

## टॉगल

| हॉटकी                  | कार्य              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | idle पर locking toggle करें |
| `Super + Ctrl + Delete` | लैपटॉप डिस्प्ले चालू/बंद toggle करें |
| `Super + Ctrl + Alt + Delete` | लैपटॉप डिस्प्ले mirroring toggle करें |
| `Super + Shift + Space` | शीर्ष bar toggle करें  |
| `Shift + Mute` | अगले ऑडियो output पर बदलें |
| `Shift + Play` | अगले मीडिया source पर बदलें |
| `Super + Shift + Backspace` | विंडो gaps toggle करें |
| `Super + Ctrl + Alt + F` | फुल स्क्रीन डेस्कटॉप toggle करें (top bar + window gaps) |

## रिमाइंडर

| हॉटकी                  | कार्य              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | रिमाइंडर सेट करें  |
| `Super + Ctrl + Alt + R` | सभी रिमाइंडर देखें  |
| `Super + Ctrl + Shift + R` | सभी रिमाइंडर साफ़ करें  |

## नोटिस

| हॉटकी                  | कार्य              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | समय को सूचना के रूप में दिखाएं  |
| `Super + Ctrl + Alt + B` | बैटरी को सूचना के रूप में दिखाएं  |
| `Super + Ctrl + Alt + W` | मौसम को सूचना के रूप में toggle करें  |

## Tmux

Prefix कुंजी `Ctrl + Space` है (`Ctrl + B` भी काम करता है)। आप इन bindings को `~/.config/tmux/tmux.conf` में बदल सकते हैं।

### Panes

| हॉटकी                  | कार्य              |
| ----------------------- | --------------------- |
| `Prefix + v` | pane को बगल में विभाजित करें (vertical) |
| `Prefix + h` | pane को नीचे विभाजित करें (horizontal) |
| `Prefix + x` | pane समाप्त करें |
| `Prefix + z` | pane zoom toggle करें (fullscreen) |
| `Alt + Enter` | pane को नीचे विभाजित करें (कोई prefix नहीं) |
| `Alt + Shift + Enter` | pane को बगल में विभाजित करें (कोई prefix नहीं) |
| `Alt + Escape` | pane समाप्त करें (कोई prefix नहीं) |
| `Ctrl + Alt + Arrows` | panes के बीच जाएं |
| `Ctrl + Alt + Shift + Arrows` | panes का आकार बदलें |

### विंडो

| हॉटकी                  | कार्य              |
| ----------------------- | --------------------- |
| `Prefix + c` | नई विंडो |
| `Prefix + k` | विंडो समाप्त करें |
| `Prefix + r` | विंडो का नाम बदलें |
| `Alt + 1-9` | विशिष्ट विंडो पर जाएं |
| `Alt + Arrow Left/Right` | विंडो के बीच जाएं |
| `Alt + Shift + Arrow Left/Right` | विंडो को बाएं/दाएं ले जाएं |

### सेशन

| हॉटकी                  | कार्य              |
| ----------------------- | --------------------- |
| `Prefix + C` | नया सेशन |
| `Prefix + K` | सेशन समाप्त करें |
| `Prefix + R` | सेशन का नाम बदलें |
| `Prefix + N` | अगला सेशन |
| `Prefix + P` | पिछला सेशन |
| `Alt + Arrow Up/Down` | सेशन के बीच जाएं |
| `Prefix + s` | सेशन सूचीबद्ध करें |
| `Prefix + d` | सेशन से detach करें |

### कॉपी मोड (vi-style)

| हॉटकी                  | कार्य              |
| ----------------------- | --------------------- |
| `Prefix + [` | कॉपी मोड में प्रवेश करें |
| `v` | चयन शुरू करें (कॉपी मोड में) |
| `y` | चयन कॉपी करें (कॉपी मोड में) |

### सामान्य

| हॉटकी                  | कार्य              |
| ----------------------- | --------------------- |
| `Prefix + q` | config फिर से लोड करें |
| `Prefix + ?` | Tmux keybindings दिखाएं |
| `Prefix + :` | Command prompt |

### Tmux layout फ़ंक्शन

इन फ़ंक्शन को Tmux सेशन के अंदर चलाना होगा।

| कमांड | कार्य |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | editor, AI, और टर्मिनल के साथ dev layout बनाएं |
| `tdlm <ai> [<second_ai>]` | प्रति subdirectory dev layout बनाएं |
| `tsl <count> <command>` | multi-pane swarm layout बनाएं |

## Ghostty टर्मिनल

Ghostty टर्मिनल Omarchy मेनू के ज़रिए _Install > Terminal_ का उपयोग करके install किया जाता है।

| हॉटकी                  | कार्य              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | नीचे नया split |
| `Ctrl + Shift + O` | बगल में नया split |
| `Ctrl + Alt + Arrows` | splits के बीच जाएं |
| `Super + Ctrl + Shift + Arrows` | split का आकार 10 लाइनों से बदलें |
| `Super + Ctrl + Shift + Alt + Arrows` | split का आकार 100 लाइनों से बदलें |
| `Ctrl + Shift + T` | नया टैब  |
| `Ctrl + Shift + Arrows` | टैब के बीच जाएं |
| `Alt + Numbers` | विशिष्ट टैब पर जाएं |
| `Shift + Pg Up/Down` | इतिहास scroll करें |
| `Ctrl + Left mouse` | लिंक ब्राउज़र में खोलें |

## फ़ाइल मैनेजर

| हॉटकी              | कार्य                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | path पर जाएं                     |
| `Space`               | फ़ाइल preview करें (तीर navigate करते हैं) |
| `Alt + Up`       | parent फ़ोल्डर पर ऊपर जाएं        |

## Neovim (w/ lazyvim)

### नेविगेशन

| हॉटकी                   | कार्य                        |
| ------------------------ | ------------------------------- |
| `Space`                    | command विकल्प दिखाएं            |
| `Space Space`              | fuzzy search के ज़रिए फ़ाइल खोलें      |
| `Space E`                  | sidebar toggle करें                  |
| `Space G G`                | git नियंत्रण दिखाएं               |
| `Space S G`                | फ़ाइल सामग्री खोजें             |
| `Ctrl + W W`               | sidebar और editor के बीच जाएं |
| `Ctrl + Left/right arrow`  | sidebar का आकार बदलें          |
| `Shift + H`                      | बाईं फ़ाइल टैब पर जाएं             |
| `Shift + L`                      | दाईं फ़ाइल टैब पर जाएं            |
| `Space B D`                | फ़ाइल टैब बंद करें                  |

### sidebar में रहते हुए

| हॉटकी                   | कार्य                        |
| ------------------------ | ------------------------------- |
| `A`                        | parent dir में नई फ़ाइल जोड़ें      |
| `Shift + A`                | parent dir में नई subdir जोड़ें    |
| `D`                        | highlighted फ़ाइल/dir हटाएं     |
| `M`                        | highlighted फ़ाइल/dir ले जाएं       |
| `R`                        | highlighted फ़ाइल/dir का नाम बदलें     |
| `?`                        | सभी commands के लिए सहायता दिखाएं      |

[LazyVim द्वारा कॉन्फ़िगर की गई सभी Neovim हॉटकीज़ देखें](https://www.lazyvim.org/keymaps).

## त्वरित Emojis

आप पूरा emoji picker दिखाने के लिए `Super + Ctrl + E` का उपयोग कर सकते हैं जो चयन को clipboard पर रख देगा या आप इन त्वरित पहुँच विकल्पों का उपयोग कर सकते हैं।

| हॉटकी       | EM | संकेत       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | मुस्कान      |
| `Shift + CapsLock M C` | 😂 | रोना        |
| `Shift + CapsLock M L` | 😍 | प्यार       |
| `Shift + CapsLock M V` | ✌️ | जीत    |
| `Shift + CapsLock M H` | ❤️ | दिल      |
| `Shift + CapsLock M Y` | 👍 | हाँ        |
| `Shift + CapsLock M N` | 👎 | नहीं         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | इच्छा       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | चुंबन       |
| `Shift + CapsLock M E` | 🙄 | eyeroll    |
| `Shift + CapsLock M I` | 😉 | wink       |
| `Shift + CapsLock M P` | 🙏 | प्रार्थना |
| `Shift + CapsLock M D` | 🤤 | लार      |
| `Shift + CapsLock M M` | 💰 | पैसा      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | अभिवादन |
| `Shift + CapsLock M A` |💪 | बाँह |
| `Shift + CapsLock M B` |🤯 | blowing |

## त्वरित पूर्णताएँ

| हॉटकी       | पूर्णता       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | आपका नाम (जैसा setup पर दर्ज किया गया था)  |
| `Shift + CapsLock Space E` | आपका ईमेल (जैसा setup पर दर्ज किया गया था)  |

आप `~/.XCompose` को संपादित करके अपने और जोड़ सकते हैं, फिर बदलावों को लागू करने के लिए टर्मिनल में `omarchy restart xcompose` चलाएं।
