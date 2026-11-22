# हॉटकีย์

आप सभी मुख्य कीबोर्ड बाइंडिंग `Super + K` के साथ देख सकते हैं (Tmux बाइंडिंग `Super + Alt + K` के साथ और Herdr बाइंडिंग `Super + Ctrl + K` के साथ)।

## हॉटकีย์ कैसे व्यवस्थित हैं

हर हॉटकีย์ एक स्तर पर रहती है, जो उसके modifiers से तय होता है, और हर स्तर का एक ही काम होता है। यही हॉटकีย์ को आपस में घुलने-मिलने से रोकता है, और इसका मतलब है कि आप आमतौर पर अनुमान लगा सकते हैं कि कोई चीज कहां रहती है।

| स्तर | वहां क्या रहता है | उदाहरण |
| --- | --- | --- |
| `Super + key` | सिस्टम: विंडो, वर्कस्पेस, लेआउट और मुख्य मेनू | `Super + Space` Omarchy मेनू, `Super + W` विंडो बंद करें, `Super + F` पूर्ण स्क्रीन |
| `Super + Shift + key` | ऐप्स | `Super + Shift + B` ब्राउज़र, `Super + Shift + E` ईमेल, `Super + Shift + N` एडिटर |
| `Super + Ctrl + key` | पैनल और सिस्टम मेनू | `Super + Ctrl + A` ऑडियो, `Super + Ctrl + N` नेटवर्क, `Super + Ctrl + C` कैप्चर मेनू |
| `Super + Ctrl + Alt + key` | त्वरित कार्य और सूचनाएं | `Super + Ctrl + Alt + T` समय दिखाएं, `Super + Ctrl + Alt + B` बैटरी, `Super + Ctrl + Alt + C` स्क्रीनशॉट |

हॉटकีย์ में `Alt` जोड़ने से आपको उसी चीज का एक रूप मिलता है, कभी कोई असंबंधित चीज नहीं:

- `Super + Shift + B` ब्राउज़र खोलता है; `Super + Shift + Alt + B` एक निजी विंडो खोलता है
- `Super + Shift + E` ईमेल खोलता है; `Super + Shift + Alt + E` एक नया ईमेल शुरू करता है
- `Super + F` पूर्ण स्क्रीन पर जाता है; `Super + Alt + F` पूर्ण चौड़ाई पर जाता है
- `Super + Ctrl + C` कैप्चर मेनू खोलता है; `Super + Ctrl + Alt + C` मेनू छोड़कर स्क्रीनशॉट लेता है

हॉटकีย์ जोड़ते समय:

1. यह क्या करता है, उससे स्तर चुनें, फिर कुंजी चुनें।
2. जगह बनाने के लिए मौजूदा हॉटकีย์ को न हटाएं। सही स्तर पर कोई खाली कुंजी खोजें।
3. `Alt` का उपयोग केवल इसके बिना वाली हॉटकีย์ के रूप के लिए करें।

कुछ हॉटकีย์ इन नियमों को तोड़ती हैं क्योंकि वे सुविधाजनक हैं। तीर या `Tab` के साथ `Shift` ऐप खोलने के बजाय ले जाता है या उलट देता है, और `Print`, मीडिया कुंजियां, `Alt + Tab` और `Ctrl + Alt + Del` वैसे ही काम करते हैं जैसे वे हर जगह करते हैं। वे अपवाद हैं, नकल करने के पैटर्न नहीं।

यदि कोई default आपको ठीक न लगे (मान लीजिए आप Windows की तरह स्क्रीनशॉट के लिए `Super + Shift + S` चाहते हैं), तो इसे `~/.config/hypr/bindings.lua` में फिर से बांधें।

## नेविगेट करना

| हॉटकีย์ | कार्य |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy मेनू (ऐप्स और बाकी सब कुछ) |
| `Super + Alt + Space` | ऐप ग्रिड |
| `Super + Escape` | सिस्टम मेनू (निलंबित करें, पुनरारंभ करें, आदि) |
| `Super + Ctrl + L` | कंप्यूटर लॉक करें |
| `Super + W` or `Super + Q` | विंडो बंद करें |
| `Ctrl + Alt + Del` | सभी विंडो बंद करें |
| `Super + K` | सभी हॉटकีย์ दिखाएं |
| `Super + Alt + K` | tmux हॉटकีย์ दिखाएं |
| `Super + Ctrl + K` | herdr हॉटकีย์ दिखाएं |
| `Super + M` | विंडो को डॉक पर छोटा करें |
| `Super + T` | विंडो को tiling/floating के बीच टॉगल करें |
| `Super + J` | विंडो की स्थिति टॉगल करें (क्षैतिज/ऊर्ध्वाधर) |
| `Super + O` | विंडो को sticky'n'floating में pop करना टॉगल करें |
| `Super + L` | dwindle, scrolling और floating लेआउट के बीच चक्र करें |
| `Super + Alt + L` | लेआउट के बीच उल्टी दिशा में चक्र करें |
| `Super + P` | pseudo विंडो शैली टॉगल करें (natural बनाम stretch) |
| `Super + F` | पूर्ण स्क्रीन पर जाएं |
| `Super + Alt + F` | पूर्ण चौड़ाई पर जाएं |
| `Super + Ctrl + F` | विंडो के अंदर पूर्ण स्क्रीन पर जाएं |
| `Super + 1…9/0` | focused मॉनिटर पर विशिष्ट वर्कस्पेस पर जाएं (0, 10 है) |
| `Super + Tab` | focused मॉनिटर पर अगले वर्कस्पेस पर जाएं |
| `Super + Shift + Tab` | focused मॉनिटर पर पिछले वर्कस्पेस पर जाएं |
| `Super + Ctrl + Tab` | focused मॉनिटर पर पूर्व वर्कस्पेस पर जाएं |
| `Super + Shift + 1…9/0` | विंडो को focused मॉनिटर पर वर्कस्पेस पर ले जाएं |
| `Super + Shift + Alt + 1…9/0` | विंडो को focused मॉनिटर पर वर्कस्पेस पर बिना पीछे गए ले जाएं |
| `Super + S` | पूर्ण scratchpad टॉगल करें |
| `Super + Alt + S` | विंडो को पूर्ण scratchpad पर ले जाएं |
| `Super + Grave` | Quake console टॉगल करें |
| `Super + Shift + Grave` | विंडो को Quake console पर ले जाएं |
| `Super + Shift + Ctrl + Arrows` | विंडो को उस दिशा के मॉनिटर पर ले जाएं |
| `Super + Shift + Alt + Arrows` | वर्कस्पेस को उस दिशा के मॉनिटर पर ले जाएं |
| `Super + Arrow` | तीर की दिशा में विंडो पर focus ले जाएं, स्क्रीन के किनारे पर उस ओर के मॉनिटर पर पार करते हुए |
| `Super + Shift + Arrow` | तीर की दिशा में दूसरी विंडो से विंडो बदलें, उस ओर के मॉनिटर पर मौजूद विंडो सहित |
| `Super + Minus` | विंडो को बाईं ओर फैलाएं |
| `Super + Equal` | विंडो को बाईं ओर सिकोड़ें |
| `Super + Shift + Minus` | विंडो को ऊपर की ओर सिकोड़ें |
| `Super + Shift + Equal` | विंडो को नीचे की ओर फैलाएं |
| `Super + Alt + Minus/Equal` | छोटे चरणों में वही आकार बदलना |
| `Super + Ctrl + Minus/Equal` | बड़े चरणों में वही आकार बदलना |
| `Super + Alt + Home` | विंडो की चौड़ाई सहेजें |
| `Super + Home` | सहेजी गई विंडो चौड़ाई बहाल करें |
| `Super + Left Mouse` | विंडो को इधर-उधर खींचें |
| `Super + Right Mouse` | विंडो का आकार बदलें |
| `Super + Scroll Wheel` | focused मॉनिटर पर वर्कस्पेस के बीच स्क्रॉल करें |
| `Super + G` | विंडो समूहीकरण टॉगल करें |
| `Super + Alt + G` | विंडो को समूहीकरण से बाहर ले जाएं |
| `Super + Alt + Tab` | समूहीकरण में विंडो के बीच चक्र करें |
| `Super + Alt + Shift + Tab` | समूहीकरण में विंडो के बीच पीछे की ओर चक्र करें |
| `Super + Alt + Scroll Wheel` | समूहीकरण में विंडो के बीच चक्र करें |
| `Super + Alt + 1/2/3/4/5` | समूहीकरण में विशिष्ट विंडो पर जाएं |
| `Super + Alt + Arrow` | विंडो को तीर की दिशा में समूहीकरण में ले जाएं, उस ओर के मॉनिटर पर मौजूद विंडो सहित |
| `Super + Ctrl + Left/Right` | tiling समूह के अंदर विंडो के बीच जाएं |
| `Super + Ctrl + Z` | स्क्रीन पर ज़ूम इन करें (अधिक ज़ूम के लिए दोहराएं) |
| `Super + Ctrl + Alt + Z` | स्क्रीन से पूरी तरह ज़ूम आउट करें |
| `Super + /` | मॉनिटर scaling विकल्पों में आगे बढ़ें |
| `Super + Alt + /` | मॉनिटर scaling विकल्पों में पीछे बढ़ें |
| `Alt + Tab` | सक्रिय वर्कस्पेस पर विंडो के बीच आगे की ओर चक्र करें |
| `Alt + Shift + Tab` | सक्रिय वर्कस्पेस पर विंडो के बीच पीछे की ओर चक्र करें |
| `Ctrl + Alt + Tab` | मॉनिटर के बीच focus आगे की ओर चक्र करें |
| `Ctrl + Alt + Shift + Tab` | मॉनिटर के बीच focus पीछे की ओर चक्र करें |
| `Super + I` | इनपुट भाषा बदलें (एक से अधिक लेआउट या इनपुट विधि के साथ) |
| `Super + Shift + I` | इनपुट भाषा वापस बदलें |

टचपैड पर, तीन- और चार-उंगली स्वाइप वर्कस्पेस बदलते हैं, विंडो ले जाते हैं, और मेनू व Quake console खोलते हैं; इशारों के लिए [कीबोर्ड, माउस और ट्रैकपैड](34-keyboard-mouse-trackpad.md) देखें।

आकार बदलने के शॉर्टकट भौतिक कुंजियों `code:20` और `code:21` (XKB `<AE11>` और `<AE12>`) का उपयोग करते हैं, कीबोर्ड पर छपे अक्षरों की परवाह किए बिना। US कीबोर्ड पर ये कुंजियां `-` और `=` हैं; जापानी (JIS) कीबोर्ड पर ये `-` और `^` हैं; स्पेनिश कीबोर्ड पर ये `'` और `¡` हैं। JIS पर, `Super + ^` ही `Super + Equal` है, जबकि `Super + Shift + -` (जो `=` टाइप करता है) ही `Super + Shift + Minus` है।

## सिस्टम नियंत्रण

| हॉटकีย์ | कार्य |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | ऑडियो पैनल |
| `Super + Ctrl + B` | Bluetooth पैनल |
| `Super + Ctrl + N` | Wi-Fi/नेटवर्क पैनल |
| `Super + Ctrl + D` | डिस्प्ले पैनल |
| `Super + Ctrl + P` | पावर पैनल |
| `Super + Ctrl + X` | Agents पैनल |
| `Super + Ctrl + Alt + X` | स्थानीय मॉडल पैनल |
| `Super + Ctrl + Alt + D` | कैलेंडर पैनल |
| `Super + Ctrl + Alt + E` | विश्व घड़ी पैनल |
| `Super + Ctrl + 1-9` | स्थिति के अनुसार बार पैनल टॉगल करें |
| `Super + Ctrl + S` | शेयर मेनू (LocalSend के माध्यम से) |
| `Super + Ctrl + C` | कैप्चर नियंत्रण (स्क्रीनशॉट/-रिकॉर्डिंग/picker) |
| `Super + Ctrl + O` | मेनू टॉगल करें |
| `Super + Ctrl + H` | हार्डवेयर मेनू |
| `Super + Ctrl + E` | इमोजी picker |
| `Super + Ctrl + .` | मीडिया transcode करें |
| `Super + Shift + Ctrl + A` | एक AI agent चुनें |
| `Power` key | सिस्टम मेनू |
| `Super + Shift + Copilot` key | Omarchy मेनू |

## समायोजन

| हॉटकีย์ | कार्य |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | अधिकतम स्क्रीन चमक |
| `Shift + Brightness Down` | न्यूनतम स्क्रीन चमक |
| `Alt + Brightness Up/Down` | सटीक 1% चमक परिवर्तन |
| `Alt + Volume Up/Down` | सटीक 1% वॉल्यूम परिवर्तन |
| `Keyboard Brightness Up/Down` | कीबोर्ड बैकलाइट अधिक तेज़/मंद |
| `Keyboard Backlight` | कीबोर्ड बैकलाइट स्तरों के बीच चक्र करें |
| `Ctrl + Brightness Up/Down` | कीबोर्ड बैकलाइट अधिक तेज़/मंद, जिन कीबोर्ड पर अपनी कुंजियां नहीं हैं उन पर |
| `Mic Mute` | माइक्रोफ़ोन म्यूट करें |
| `Shift + Mute` | ऑडियो आउटपुट बदलें |
| `Touchpad Toggle` | टचपैड चालू या बंद करें |
| `Display` key | वर्कस्पेस लेआउट के बीच चक्र करें |
| `Alt + Play` | अगला ट्रैक |
| `Alt + Shift + Play` | पिछला ट्रैक |

## ऐप्स लॉन्च करना

| हॉटकีย์ | कार्य |
| ----------------------- | --------------------- |
| `Super + Return` | टर्मिनल |
| `Super + Alt + Return` | Tmux टर्मिनल |
| `Super + Ctrl + Return` | Herdr (agent मैनेजर) |
| `Super + Shift + Return` or `Super + Shift + B` | ब्राउज़र |
| `Super + Shift + Alt + B` | ब्राउज़र (निजी/incognito) |
| `Super + Shift + F` | फ़ाइल मैनेजर |
| `Super + Shift + Alt + F` | टर्मिनल के cwd में फ़ाइल मैनेजर |
| `Super + Shift + M` | संगीत (Spotify) |
| `Super + Shift + Alt + M` | संगीत (cliamp) |
| `Super + Shift + /` | पासवर्ड मैनेजर (1password) |
| `Super + Shift + Q` or `Calculator` key | कैलकुलेटर (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, एक बार इंस्टॉल हो जाने पर) |
| `Super + Shift + T` | गतिविधि (btop) |
| `Super + Shift + N` | एडिटर (Plain, या आपका चुना हुआ default) |
| `Super + Shift + C` | कैलेंडर ([HEY](https://hey.com/)) |
| `Super + Shift + E` | ईमेल ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | नया ईमेल ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Messenger (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Messenger (WhatsApp) |
| `Super + Shift + Ctrl + G` | Messenger (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | लेखन (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (नई पोस्ट) |
| `Super + Shift + Y` | YouTube |

`~/.config/hypr/bindings.lua` में बाइंडिंग बदलें/जोड़ें।

## सार्वभौमिक क्लिपबोर्ड

| हॉटकีย์ | कार्य |
| ----------------------- | --------------------- |
| `Super + A` | उन ऐप्स में सब चुनें जो `Ctrl + A` का समर्थन करते हैं |
| `Super + C` | कॉपी करें |
| `Super + X` | कट करें (टर्मिनल में नहीं) |
| `Super + V` | पेस्ट करें |
| `Super + Ctrl + V` | क्लिपबोर्ड मैनेजर |

आमतौर पर Linux पर, टर्मिनल में कॉपी-और-पेस्ट करने के लिए आपको `Ctrl + Shift + C/V` चाहिए और बाकी हर जगह करने के लिए `Ctrl + C/V`। ये Omarchy एकीकृत क्लिपबोर्ड हॉटकีย์ हर जगह काम करती हैं।

## कैप्चर

| हॉटकีย์ | कार्य |
| ------------------- | ------------------------------ |
| `Print Screen` | स्क्रीनशॉट |
| `Super + Ctrl + Alt + C` | स्क्रीनशॉट (वही शॉट, उन कीबोर्ड के लिए जिन पर Print Screen कुंजी नहीं है) |
| `Super + Ctrl + C` | कैप्चर मेनू |
| `Alt + Print Screen` | स्क्रीनरिकॉर्ड |
| `Super + Shift + Ctrl + Alt + C` | बिना ऑडियो के स्क्रीनरिकॉर्ड, मेनू छोड़कर (रोकने के लिए फिर दबाएं) |
| `Super + Print Screen` | रंग picker |
| `Super + Ctrl + Print Screen` | क्लिपबोर्ड पर पाठ निकालना |
| `Super + Alt + [` | रिकॉर्डिंग के दौरान webcam overlay छोटा करें |
| `Super + Alt + ]` | रिकॉर्डिंग के दौरान webcam overlay बड़ा करें |
| `Alt + Shift + L` | webapp या ब्राउज़र से वर्तमान URL कॉपी करें |
| `Alt + Shift + D` | वर्तमान पेज का वीडियो `~/Videos` में डाउनलोड करें |
| `Alt + Space` | डिक्टेशन शुरू/रोकें (इसके लिए _Setup > Defaults > Dictation_ आवश्यक है) |
| `Right Alt` | डिक्टेट करने के लिए दबाए रखें (इसके लिए _Setup > Defaults > Dictation_ आवश्यक है) |

स्क्रीनरिकॉर्डिंग के साथ, हॉटकีย์ पहले पूछती है कि आप कौन-सा ऑडियो चाहते हैं, फिर रिकॉर्डिंग शुरू करती है। रोकने के लिए इसे फिर दबाएं। विवरण के लिए [स्क्रीनशॉट और रिकॉर्डिंग](12-screenshots-recording.md) देखें।

सभी कैप्चर विकल्प Omarchy मेनू (`Super + Space`) में _Trigger > Capture_ के तहत भी उपलब्ध हैं।

## सूचनाएं

| हॉटकีย์ | कार्य |
| ----------------------- | --------------------- |
| `Super + ,` | नवीनतम सूचना पर कार्य करें: इसे खोलें या इसका एकमात्र बटन दबाएं, इसके विकल्पों में से चुनें, या जब कोई विकल्प न हो तो इसे खारिज करें |
| `Super + Shift + ,` | सभी सूचनाएं खारिज करें |
| `Super + Ctrl + ,` | कीबोर्ड से सूचनाएं नियंत्रित करें |
| `Super + Alt + ,` | नवीनतम सूचना खारिज करें |
| `Super + Shift + Alt + ,` | सूचना इतिहास खोलें |
| `Super + Ctrl + Alt + ,` | सूचनाएं मौन करना टॉगल करें |

## शैली

| हॉटकีย์ | कार्य |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | नई थीम चुनें (यह भी `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | थीम पृष्ठभूमि चुनें (यह भी `Super + Ctrl + Space`) |
| `Super + Backspace` | विंडो पर पारदर्शिता टॉगल करें |
| `Super + Ctrl + Backspace` | एकल-विंडो वर्गाकार aspect टॉगल करें |

अतिरिक्त पृष्ठभूमि छवियां `~/.config/omarchy/backgrounds/<theme name>` में रहती हैं। Omarchy मेनू में _Install > Style > Background_ के माध्यम से भी उपलब्ध।

सभी शैली विकल्प Omarchy मेनू (`Super + Space`) में _Appearance_ के तहत भी उपलब्ध हैं।

## टॉगल

| हॉटकีย์ | कार्य |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | idle पर लॉक करना टॉगल करें |
| `Super + Ctrl + Delete` | लैपटॉप डिस्प्ले चालू/बंद टॉगल करें |
| `Super + Ctrl + Alt + Delete` | लैपटॉप डिस्प्ले mirroring टॉगल करें |
| `Super + Shift + Space` | शीर्ष बार टॉगल करें |
| `Shift + Mute` | अगले ऑडियो आउटपुट पर बदलें |
| `Shift + Play` | अगले मीडिया स्रोत पर बदलें |
| `Super + Shift + Backspace` | विंडो अंतराल टॉगल करें |
| `Super + Ctrl + Alt + F` | पूर्ण स्क्रीन डेस्कटॉप टॉगल करें (शीर्ष बार + विंडो अंतराल) |

## रिमाइंडर

| हॉटकีย์ | कार्य |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | रिमाइंडर सेट करें |
| `Super + Ctrl + Alt + R` | सभी रिमाइंडर देखें |
| `Super + Ctrl + Shift + R` | सभी रिमाइंडर साफ़ करें |

## नोटिस

| हॉटकีย์ | कार्य |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | समय को सूचना के रूप में दिखाएं |
| `Super + Ctrl + Alt + B` | बैटरी को सूचना के रूप में दिखाएं |
| `Super + Ctrl + Alt + W` | मौसम को सूचना के रूप में टॉगल करें |

## Tmux

prefix कुंजी `Ctrl + Space` है (`Ctrl + B` भी काम करता है)। आप इन बाइंडिंग को `~/.config/tmux/tmux.conf` में बदल सकते हैं।

### पेन

| हॉटकีย์ | कार्य |
| ----------------------- | --------------------- |
| `Prefix + v` | बगल में पेन विभाजित करें (ऊर्ध्वाधर) |
| `Prefix + h` | नीचे पेन विभाजित करें (क्षैतिज) |
| `Prefix + x` | पेन समाप्त करें |
| `Prefix + z` | पेन ज़ूम टॉगल करें (पूर्ण स्क्रीन) |
| `Alt + Enter` | नीचे पेन विभाजित करें (बिना prefix के) |
| `Alt + Shift + Enter` | बगल में पेन विभाजित करें (बिना prefix के) |
| `Alt + Escape` | पेन समाप्त करें (बिना prefix के) |
| `Ctrl + Alt + Arrows` | पेन के बीच जाएं |
| `Ctrl + Alt + Shift + Arrows` | पेन का आकार बदलें |

### विंडो

| हॉटकีย์ | कार्य |
| ----------------------- | --------------------- |
| `Prefix + c` | नई विंडो |
| `Prefix + k` | विंडो समाप्त करें |
| `Prefix + r` | विंडो का नाम बदलें |
| `Alt + 1-9` | विशिष्ट विंडो पर जाएं |
| `Alt + Arrow Left/Right` | विंडो के बीच जाएं |
| `Alt + Shift + Arrow Left/Right` | विंडो बाईं/दाईं ओर ले जाएं |

### सत्र

| हॉटकีย์ | कार्य |
| ----------------------- | --------------------- |
| `Prefix + C` | नया सत्र |
| `Prefix + K` | सत्र समाप्त करें |
| `Prefix + R` | सत्र का नाम बदलें |
| `Prefix + N` | अगला सत्र |
| `Prefix + P` | पिछला सत्र |
| `Alt + Arrow Up/Down` | सत्रों के बीच जाएं |
| `Prefix + s` | सत्रों की सूची देखें |
| `Prefix + d` | सत्र से अलग हों |

### कॉपी मोड (vi-शैली)

| हॉटकีย์ | कार्य |
| ----------------------- | --------------------- |
| `Prefix + [` | कॉपी मोड में प्रवेश करें |
| `v` | चयन शुरू करें (कॉपी मोड में) |
| `y` | चयन कॉपी करें (कॉपी मोड में) |

### सामान्य

| हॉटकีย์ | कार्य |
| ----------------------- | --------------------- |
| `Prefix + q` | config पुनः लोड करें |
| `Prefix + ?` | Tmux कीबाइंडिंग दिखाएं |
| `Prefix + :` | कमांड प्रॉम्प्ट |

### Tmux लेआउट फ़ंक्शन

ये फ़ंक्शन Tmux सत्र के अंदर चलाए जाने चाहिए।

| कमांड | कार्य |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | एडिटर, AI और टर्मिनल के साथ dev लेआउट बनाएं |
| `tdlm <ai> [<second_ai>]` | प्रति उपनिर्देशिका dev लेआउट बनाएं |
| `tsl <count> <command>` | बहु-पेन swarm लेआउट बनाएं |

## Ghostty टर्मिनल

Ghostty टर्मिनल Omarchy मेनू के माध्यम से _Install > Terminal_ का उपयोग करके इंस्टॉल किया जाता है।

| हॉटकีย์ | कार्य |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | नीचे नया split |
| `Ctrl + Shift + O` | बगल में नया split |
| `Ctrl + Alt + Arrows` | split के बीच जाएं |
| `Super + Ctrl + Shift + Arrows` | split का आकार 10 पंक्तियों से बदलें |
| `Super + Ctrl + Shift + Alt + Arrows` | split का आकार 100 पंक्तियों से बदलें |
| `Ctrl + Shift + T` | नया टैब |
| `Ctrl + Shift + Arrows` | टैब के बीच जाएं |
| `Alt + Numbers` | विशिष्ट टैब पर जाएं |
| `Shift + Pg Up/Down` | इतिहास स्क्रॉल करें |
| `Ctrl + Left mouse` | ब्राउज़र में लिंक खोलें |

## फ़ाइल मैनेजर

| हॉटकีย์ | कार्य |
| ------------------- | ------------------------------ |
| `Ctrl + L` | पथ पर जाएं |
| `Space` | फ़ाइल का पूर्वावलोकन करें (तीर नेविगेट करते हैं) |
| `Alt + Up` | मूल फ़ोल्डर पर ऊपर जाएं |

## Neovim (w/ lazyvim)

### नेविगेशन

| हॉटकีย์ | कार्य |
| ------------------------ | ------------------------------- |
| `Space` | कमांड विकल्प दिखाएं |
| `Space Space` | fuzzy खोज के माध्यम से फ़ाइल खोलें |
| `Space E` | साइडबार टॉगल करें |
| `Space G G` | git नियंत्रण दिखाएं |
| `Space S G` | फ़ाइल सामग्री खोजें |
| `Ctrl + W W` | साइडबार और एडिटर के बीच जाएं |
| `Ctrl + Left/right arrow` | साइडबार का आकार बदलें |
| `Shift + H` | बाईं फ़ाइल टैब पर जाएं |
| `Shift + L` | दाईं फ़ाइल टैब पर जाएं |
| `Space B D` | फ़ाइल टैब बंद करें |

### साइडबार में रहते हुए

| हॉटकีย์ | कार्य |
| ------------------------ | ------------------------------- |
| `A` | मूल dir में नई फ़ाइल जोड़ें |
| `Shift + A` | मूल dir में नई उपनिर्देशिका जोड़ें |
| `D` | हाइलाइट की गई फ़ाइल/dir हटाएं |
| `M` | हाइलाइट की गई फ़ाइल/dir ले जाएं |
| `R` | हाइलाइट की गई फ़ाइल/dir का नाम बदलें |
| `?` | सभी कमांड के लिए सहायता दिखाएं |

[LazyVim द्वारा कॉन्फ़िगर की गई सभी Neovim हॉटकีย์ देखें](https://www.lazyvim.org/keymaps)।

## त्वरित इमोजी

आप पूर्ण इमोजी picker दिखाने के लिए `Super + Ctrl + E` का उपयोग कर सकते हैं जो चयन को क्लिपबोर्ड पर रख देगा या आप इन त्वरित पहुंच विकल्पों का उपयोग कर सकते हैं।

| हॉटकีย์ | EM | Clue |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smile |
| `Shift + CapsLock M C` | 😂 | cry |
| `Shift + CapsLock M L` | 😍 | love |
| `Shift + CapsLock M V` | ✌️ | victory |
| `Shift + CapsLock M H` | ❤️ | heart |
| `Shift + CapsLock M Y` | 👍 | yes |
| `Shift + CapsLock M N` | 👎 | no |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | wish |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | kiss |
| `Shift + CapsLock M E` | 🙄 | eyeroll |
| `Shift + CapsLock M I` | 😉 | wink |
| `Shift + CapsLock M P` | 🙏 | pray |
| `Shift + CapsLock M D` | 🤤 | drool |
| `Shift + CapsLock M M` | 💰 | money |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | toast |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | greeting |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | blowing |

## त्वरित पूर्णीकरण

| हॉटकีย์ | पूर्णीकरण |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | आपका नाम (जैसा setup पर दर्ज किया गया) |
| `Shift + CapsLock Space E` | आपका ईमेल (जैसा setup पर दर्ज किया गया) |

आप `~/.XCompose` संपादित करके अपने और जोड़ सकते हैं, फिर परिवर्तनों को लागू करने के लिए टर्मिनल में `omarchy restart xcompose` चलाएं।
