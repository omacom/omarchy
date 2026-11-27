# हॉटकी

आप सभी मुख्य कीबोर्ड बाइंडिंग `Super + K` से देख सकते हैं (Tmux बाइंडिंग `Super + Alt + K` से और Herdr बाइंडिंग `Super + Ctrl + K` से)।

## हॉटकी कैसे व्यवस्थित हैं

हर हॉटकी एक तल पर बैठती है, जो उसके मॉडिफ़ायर से तय होता है, और हर तल का एक काम है। यही हॉटकी को आपस में घुलने-मिलने से रोकता है, और इसका मतलब है कि आप आमतौर पर अंदाज़ा लगा सकते हैं कि कोई चीज़ कहाँ रहती है।

| तल | वहाँ क्या रहता है | उदाहरण |
| --- | --- | --- |
| `Super + key` | सिस्टम: विंडो, वर्कस्पेस, लेआउट और मुख्य मेनू | `Super + Space` Omarchy मेनू, `Super + W` विंडो बंद करें, `Super + F` फुल स्क्रीन |
| `Super + Shift + key` | ऐप्स | `Super + Shift + B` ब्राउज़र, `Super + Shift + E` ईमेल, `Super + Shift + N` एडिटर |
| `Super + Ctrl + key` | पैनल और सिस्टम मेनू | `Super + Ctrl + A` ऑडियो, `Super + Ctrl + N` नेटवर्क, `Super + Ctrl + C` कैप्चर मेनू |
| `Super + Ctrl + Alt + key` | त्वरित कार्रवाइयाँ और सूचनाएँ | `Super + Ctrl + Alt + T` समय दिखाएँ, `Super + Ctrl + Alt + B` बैटरी, `Super + Ctrl + Alt + C` स्क्रीनशॉट |

हॉटकी में `Alt` जोड़ने से आपको उसी चीज़ का एक रूप मिलता है, कभी कोई असंबंधित चीज़ नहीं:

- `Super + Shift + B` ब्राउज़र खोलता है; `Super + Shift + Alt + B` प्राइवेट विंडो खोलता है
- `Super + Shift + E` ईमेल खोलता है; `Super + Shift + Alt + E` नया ईमेल शुरू करता है
- `Super + F` फुल स्क्रीन पर जाता है; `Super + Alt + F` फुल विड्थ पर जाता है
- `Super + Ctrl + C` कैप्चर मेनू खोलता है; `Super + Ctrl + Alt + C` मेनू छोड़कर स्क्रीनशॉट लेता है

हॉटकी जोड़ते समय:

1. यह क्या करता है, उससे तल चुनें, फिर कुंजी चुनें।
2. जगह बनाने के लिए मौजूदा हॉटकी न हटाएँ। सही तल पर खाली कुंजी खोजें।
3. `Alt` केवल बिना `Alt` वाली हॉटकी के रूप के लिए इस्तेमाल करें।

कुछ हॉटकी सुविधाजनक होने के कारण इन नियमों को तोड़ती हैं। तीर या `Tab` के साथ `Shift` ऐप खोलने के बजाय ले जाता है या उलटता है, और `Print`, मीडिया कुंजियाँ, `Alt + Tab`, और `Ctrl + Alt + Del` वैसे ही काम करते हैं जैसे वे हर जगह करते हैं। ये अपवाद हैं, नकल करने के पैटर्न नहीं।

यदि कोई डिफ़ॉल्ट आपको ठीक न लगे (मान लीजिए आप Windows की तरह स्क्रीनशॉट के लिए `Super + Shift + S` चाहते हैं), तो उसे `~/.config/hypr/bindings.lua` में रीबाइंड करें।

## नेविगेट करना

| हॉटकी | कार्य |
| --- | --- |
| `Super + Space` | Omarchy मेनू (ऐप्स और बाकी सब कुछ) |
| `Super + Alt + Space` | ऐप ग्रिड |
| `Super + Escape` | सिस्टम मेनू (सस्पेंड, रीस्टार्ट, आदि) |
| `Super + Ctrl + L` | कंप्यूटर लॉक करें |
| `Super + W` or `Super + Q` | विंडो बंद करें |
| `Ctrl + Alt + Del` | सभी विंडो बंद करें |
| `Super + K` | सभी हॉटकी दिखाएँ |
| `Super + Alt + K` | tmux हॉटकी दिखाएँ |
| `Super + Ctrl + K` | herdr हॉटकी दिखाएँ |
| `Super + M` | विंडो को डॉक में मिनिमाइज़ करें |
| `Super + T` | विंडो को टाइलिंग/फ़्लोटिंग के बीच टॉगल करें |
| `Super + J` | विंडो की स्थिति टॉगल करें (क्षैतिज/ऊर्ध्वाधर) |
| `Super + O` | विंडो को sticky'n'floating में पॉप करना टॉगल करें |
| `Super + L` | dwindle, scrolling और floating लेआउट में चक्र करें |
| `Super + Alt + L` | लेआउट में उल्टे क्रम में चक्र करें |
| `Super + P` | pseudo विंडो स्टाइल टॉगल करें (natural बनाम stretch) |
| `Super + F` | फुल स्क्रीन पर जाएँ |
| `Super + Alt + F` | फुल विड्थ पर जाएँ |
| `Super + Ctrl + F` | विंडो के अंदर फुल स्क्रीन पर जाएँ |
| `Super + 1…9/0` | फ़ोकस किए गए मॉनीटर पर विशिष्ट वर्कस्पेस पर जाएँ (0 यानी 10) |
| `Super + Tab` | फ़ोकस किए गए मॉनीटर पर अगले वर्कस्पेस पर जाएँ |
| `Super + Shift + Tab` | फ़ोकस किए गए मॉनीटर पर पिछले वर्कस्पेस पर जाएँ |
| `Super + Ctrl + Tab` | फ़ोकस किए गए मॉनीटर पर पूर्व वर्कस्पेस पर जाएँ |
| `Super + Shift + 1…9/0` | विंडो को फ़ोकस किए गए मॉनीटर के वर्कस्पेस पर ले जाएँ |
| `Super + Shift + Alt + 1…9/0` | बिना पीछे जाए विंडो को फ़ोकस किए गए मॉनीटर के वर्कस्पेस पर ले जाएँ |
| `Super + S` | फुल scratchpad टॉगल करें |
| `Super + Alt + S` | विंडो को फुल scratchpad पर ले जाएँ |
| `Super + the key above Tab` (grave on US layouts) | Quake कंसोल टॉगल करें |
| `Super + Shift + the key above Tab` (grave on US layouts) | विंडो को Quake कंसोल पर ले जाएँ |
| `Super + Shift + Ctrl + Arrows` | विंडो को उस दिशा के मॉनीटर पर ले जाएँ |
| `Super + Shift + Alt + Arrows` | वर्कस्पेस को उस दिशा के मॉनीटर पर ले जाएँ |
| `Super + Arrow` | तीर की दिशा में विंडो पर फ़ोकस ले जाएँ, स्क्रीन के किनारे पर उस ओर के मॉनीटर पर पार करते हुए |
| `Super + Shift + Arrow` | तीर की दिशा में दूसरी विंडो से अदला-बदली करें, उस ओर के मॉनीटर पर मौजूद विंडो सहित |
| `Super + Minus` | विंडो को बाईं ओर फैलाएँ |
| `Super + Equal` | विंडो को बाईं ओर सिकोड़ें |
| `Super + Shift + Minus` | विंडो को ऊपर की ओर सिकोड़ें |
| `Super + Shift + Equal` | विंडो को नीचे की ओर फैलाएँ |
| `Super + Alt + Minus/Equal` | छोटे चरणों में वही आकार बदलना |
| `Super + Ctrl + Minus/Equal` | बड़े चरणों में वही आकार बदलना |
| `Super + Alt + Home` | विंडो की चौड़ाई सहेजें |
| `Super + Home` | सहेजी गई विंडो चौड़ाई बहाल करें |
| `Super + Left Mouse` | विंडो को इधर-उधर खींचें |
| `Super + Right Mouse` | विंडो का आकार बदलें |
| `Super + Scroll Wheel` | फ़ोकस किए गए मॉनीटर पर वर्कस्पेस में स्क्रॉल करें |
| `Super + G` | विंडो ग्रुपिंग टॉगल करें |
| `Super + Alt + G` | विंडो को ग्रुपिंग से बाहर ले जाएँ |
| `Super + Alt + Tab` | ग्रुपिंग में विंडो के बीच चक्र करें |
| `Super + Alt + Shift + Tab` | ग्रुपिंग में विंडो के बीच पीछे की ओर चक्र करें |
| `Super + Alt + Scroll Wheel` | ग्रुपिंग में विंडो के बीच चक्र करें |
| `Super + Alt + 1/2/3/4/5` | ग्रुपिंग में विशिष्ट विंडो पर जाएँ |
| `Super + Alt + Arrow` | तीर की दिशा में विंडो को ग्रुपिंग में ले जाएँ, उस ओर के मॉनीटर पर मौजूद विंडो सहित |
| `Super + Ctrl + Left/Right` | टाइलिंग ग्रुप के अंदर विंडो के बीच जाएँ |
| `Super + Ctrl + Z` | स्क्रीन पर ज़ूम इन करें (अधिक ज़ूम के लिए दोहराएँ) |
| `Super + Ctrl + Alt + Z` | स्क्रीन से पूरी तरह ज़ूम आउट करें |
| `Super + /` | मॉनीटर स्केलिंग विकल्पों में आगे बढ़ें |
| `Super + Alt + /` | मॉनीटर स्केलिंग विकल्पों में पीछे बढ़ें |
| `Alt + Tab` | सक्रिय वर्कस्पेस पर विंडो में आगे की ओर चक्र करें |
| `Alt + Shift + Tab` | सक्रिय वर्कस्पेस पर विंडो में पीछे की ओर चक्र करें |
| `Ctrl + Alt + Tab` | मॉनीटर में फ़ोकस आगे की ओर चक्र करें |
| `Ctrl + Alt + Shift + Tab` | मॉनीटर में फ़ोकस पीछे की ओर चक्र करें |
| `Super + I` | इनपुट भाषा बदलें (एक से अधिक लेआउट या इनपुट विधि होने पर) |
| `Super + Shift + I` | इनपुट भाषा वापस बदलें |

टचपैड पर, तीन- और चार-उंगली स्वाइप वर्कस्पेस बदलते हैं, विंडो ले जाते हैं, और मेनू और Quake कंसोल खोलते हैं; इशारों के लिए [कीबोर्ड, माउस और ट्रैकपैड](34-keyboard-mouse-trackpad.md) देखें।

आकार बदलने में 0 के दाईं ओर की दो कुंजियाँ इस्तेमाल होती हैं, आपके कीबोर्ड पर उन पर जो भी छपा हो: US कीबोर्ड पर `-` और `=`, डेनिश और स्वीडिश पर `+` और `´`, नॉर्वेजियन पर `+` और `\`, जर्मन पर `ß` और `´`, स्पेनिश पर `'` और `¡`, और जापानी (JIS) पर `-` और `^`। `Super + K` उन्हें वैसे सूचीबद्ध करता है जैसे आपके कीबोर्ड पर छपी हैं। JIS पर, `Super + ^` यानी `Super + Equal` है, जबकि `Super + Shift + -` (जो `=` टाइप करता है) यानी `Super + Shift + Minus` है। मॉनीटर स्केलिंग और पासवर्ड मैनेजर `/` इस्तेमाल करते हैं; उन लेआउट पर जो `/` केवल Shift के साथ टाइप करते हैं, जैसा कि अधिकांश यूरोपीय लेआउट करते हैं, वे दाएँ Shift के बाईं ओर की कुंजी इस्तेमाल करते हैं (डेनिश और जर्मन पर `-`)।

## सिस्टम नियंत्रण

| हॉटकी | कार्य |
| --- | --- |
| `Super + Ctrl + A` | ऑडियो पैनल |
| `Super + Ctrl + B` | Bluetooth पैनल |
| `Super + Ctrl + N` | Wifi/नेटवर्क पैनल |
| `Super + Ctrl + D` | Display पैनल |
| `Super + Ctrl + P` | Power पैनल |
| `Super + Ctrl + X` | Agents पैनल |
| `Super + Ctrl + Alt + D` | कैलेंडर पैनल |
| `Super + Ctrl + Alt + E` | विश्व घड़ी पैनल |
| `Super + Ctrl + 1-9` | स्थिति के अनुसार बार पैनल टॉगल करें |
| `Super + Ctrl + S` | शेयर मेनू (LocalSend के ज़रिए) |
| `Super + Ctrl + C` | कैप्चर नियंत्रण (स्क्रीनशॉट/-रिकॉर्डिंग/पिकर) |
| `Super + Ctrl + O` | मेनू टॉगल करें |
| `Super + Ctrl + H` | Hardware मेनू |
| `Super + Ctrl + E` | Emoji पिकर |
| `Super + Ctrl + .` | मीडिया ट्रांसकोड करें |
| `Super + Shift + Ctrl + A` | अपना डिफ़ॉल्ट agent शुरू करें |
| `Power` key | सिस्टम मेनू |
| `Super + Shift + Copilot` key | Omarchy मेनू |

## समायोजन

| हॉटकी | कार्य |
| --- | --- |
| `Shift + Brightness Up` | अधिकतम स्क्रीन ब्राइटनेस |
| `Shift + Brightness Down` | न्यूनतम स्क्रीन ब्राइटनेस |
| `Alt + Brightness Up/Down` | सटीक 1% ब्राइटनेस बदलाव |
| `Alt + Volume Up/Down` | सटीक 1% वॉल्यूम बदलाव |
| `Keyboard Brightness Up/Down` | कीबोर्ड बैकलाइट तेज़/मंद |
| `Keyboard Backlight` | कीबोर्ड बैकलाइट स्तरों में चक्र करें |
| `Ctrl + Brightness Up/Down` | कीबोर्ड बैकलाइट तेज़/मंद, उन कीबोर्ड पर जिनमें अपनी कुंजियाँ नहीं हैं |
| `Mic Mute` | माइक्रोफ़ोन म्यूट करें |
| `Shift + Mute` | ऑडियो आउटपुट बदलें |
| `Touchpad Toggle` | टचपैड चालू या बंद करें |
| `Display` key | वर्कस्पेस लेआउट में चक्र करें |
| `Alt + Play` | अगला ट्रैक |
| `Alt + Shift + Play` | पिछला ट्रैक |

## ऐप्स लॉन्च करना

| हॉटकी | कार्य |
| --- | --- |
| `Super + Return` | टर्मिनल |
| `Super + Alt + Return` | Tmux टर्मिनल |
| `Super + Ctrl + Return` | Herdr (agent मैनेजर) |
| `Super + Shift + Return` or `Super + Shift + B` | ब्राउज़र |
| `Super + Shift + Alt + B` | ब्राउज़र (private/incognito) |
| `Super + Shift + F` | फ़ाइल मैनेजर |
| `Super + Shift + Alt + F` | टर्मिनल के cwd में फ़ाइल मैनेजर |
| `Super + Shift + M` | Music (Spotify) |
| `Super + Shift + Alt + M` | Music (cliamp) |
| `Super + Shift + /` | पासवर्ड मैनेजर (1password) |
| `Super + Shift + Q` or `Calculator` key | कैलकुलेटर (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, इंस्टॉल होने के बाद) |
| `Super + Shift + T` | Activity (btop) |
| `Super + Shift + N` | एडिटर (Plain, या आपका चुना हुआ डिफ़ॉल्ट) |
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

## यूनिवर्सल क्लिपबोर्ड

| हॉटकी | कार्य |
| --- | --- |
| `Super + A` | उन ऐप्स में सब चुनें जो `Ctrl + A` का समर्थन करते हैं |
| `Super + C` | कॉपी |
| `Super + X` | कट (टर्मिनल में नहीं) |
| `Super + V` | पेस्ट |
| `Super + Ctrl + V` | क्लिपबोर्ड मैनेजर |

आमतौर पर Linux पर, टर्मिनल में copy'n'paste के लिए आपको `Ctrl + Shift + C/V` चाहिए होता है और बाकी हर जगह के लिए `Ctrl + C/V` चाहिए होता है। ये Omarchy एकीकृत क्लिपबोर्ड हॉटकी हर जगह काम करती हैं।

## कैप्चर

| हॉटकी | कार्य |
| --- | --- |
| `Print Screen` | स्क्रीनशॉट |
| `Super + Ctrl + Alt + C` | स्क्रीनशॉट (वही शॉट, उन कीबोर्ड के लिए जिनमें Print Screen कुंजी नहीं है) |
| `Super + Ctrl + C` | कैप्चर मेनू |
| `Alt + Print Screen` | स्क्रीनरिकॉर्ड |
| `Super + Shift + Ctrl + Alt + C` | बिना ऑडियो के स्क्रीनरिकॉर्ड, मेनू छोड़कर (रोकने के लिए फिर दबाएँ) |
| `Super + Print Screen` | कलर पिकर |
| `Super + Ctrl + Print Screen` | क्लिपबोर्ड पर टेक्स्ट निकालना |
| `Super + Alt + [` | रिकॉर्डिंग के दौरान webcam ओवरले छोटा करें |
| `Super + Alt + ]` | रिकॉर्डिंग के दौरान webcam ओवरले बड़ा करें |
| `Alt + Shift + L` | webapp या ब्राउज़र से वर्तमान URL कॉपी करें |
| `Alt + Shift + D` | वर्तमान पेज का वीडियो `~/Videos` में डाउनलोड करें |
| `Alt + Space` | डिक्टेशन शुरू/बंद करें (_Setup > Defaults > Dictation_ आवश्यक है) |
| `Right Alt` | डिक्टेट करने के लिए दबाए रखें (_Setup > Defaults > Dictation_ आवश्यक है) |

स्क्रीनरिकॉर्डिंग के साथ, हॉटकी पहले पूछती है कि आपको कौन सा ऑडियो चाहिए, फिर रिकॉर्डिंग शुरू करती है। रोकने के लिए इसे फिर दबाएँ। विवरण के लिए [स्क्रीनशॉट और रिकॉर्डिंग](12-screenshots-recording.md) देखें।

सभी कैप्चर विकल्प Omarchy मेनू (`Super + Space`) में _Trigger > Capture_ के तहत भी उपलब्ध हैं।

## सूचनाएँ

| हॉटकी | कार्य |
| --- | --- |
| `Super + ,` | नवीनतम सूचना पर कार्रवाई करें: उसे खोलें या उसका एकमात्र बटन दबाएँ, उसके विकल्पों में से चुनें, या जब उसमें कोई न हो तो उसे खारिज करें |
| `Super + Shift + ,` | सभी सूचनाएँ खारिज करें |
| `Super + Ctrl + ,` | कीबोर्ड से सूचनाएँ नियंत्रित करें |
| `Super + Alt + ,` | नवीनतम सूचना खारिज करें |
| `Super + Shift + Alt + ,` | सूचना इतिहास खोलें |
| `Super + Ctrl + Alt + ,` | सूचनाएँ चुप करना टॉगल करें |

## स्टाइल

| हॉटकी | कार्य |
| --- | --- |
| `Super + Ctrl + T` | नई थीम चुनें (यह भी `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | थीम बैकग्राउंड चुनें (यह भी `Super + Ctrl + Space`) |
| `Super + Backspace` | विंडो पर पारदर्शिता टॉगल करें |
| `Super + Ctrl + Backspace` | एकल-विंडो वर्ग पहलू टॉगल करें |

अतिरिक्त बैकग्राउंड इमेज `~/.config/omarchy/backgrounds/<theme name>` में रहती हैं। Omarchy मेनू में _Install > Style > Background_ के ज़रिए भी उपलब्ध।

सभी स्टाइल विकल्प Omarchy मेनू (`Super + Space`) में _Appearance_ के तहत भी उपलब्ध हैं।

## टॉगल

| हॉटकी | कार्य |
| --- | --- |
| `Super + Ctrl + I` | निष्क्रिय होने पर लॉक करना टॉगल करें |
| `Super + Ctrl + Delete` | लैपटॉप डिस्प्ले चालू/बंद टॉगल करें |
| `Super + Ctrl + Alt + Delete` | लैपटॉप डिस्प्ले मिररिंग टॉगल करें |
| `Super + Shift + Space` | शीर्ष बार टॉगल करें |
| `Shift + Mute` | अगले ऑडियो आउटपुट पर बदलें |
| `Shift + Play` | अगले मीडिया स्रोत पर बदलें |
| `Super + Shift + Backspace` | विंडो गैप टॉगल करें |
| `Super + Ctrl + Alt + F` | फुल स्क्रीन डेस्कटॉप टॉगल करें (शीर्ष बार + विंडो गैप) |

## रिमाइंडर

| हॉटकी | कार्य |
| --- | --- |
| `Super + Ctrl + R` | रिमाइंडर सेट करें |
| `Super + Ctrl + Alt + R` | सभी रिमाइंडर देखें |
| `Super + Ctrl + Shift + R` | सभी रिमाइंडर साफ़ करें |

## नोटिस

| हॉटकी | कार्य |
| --- | --- |
| `Super + Ctrl + Alt + T` | समय सूचना के रूप में दिखाएँ |
| `Super + Ctrl + Alt + B` | बैटरी सूचना के रूप में दिखाएँ |
| `Super + Ctrl + Alt + W` | मौसम सूचना के रूप में टॉगल करें |

## Tmux

उपसर्ग कुंजी `Ctrl + Space` है (`Ctrl + B` भी काम करता है)। आप इन बाइंडिंग को `~/.config/tmux/tmux.conf` में बदल सकते हैं।

### पेन

| हॉटकी | कार्य |
| --- | --- |
| `Prefix + v` | बगल में पेन विभाजित करें (ऊर्ध्वाधर) |
| `Prefix + h` | नीचे पेन विभाजित करें (क्षैतिज) |
| `Prefix + x` | पेन समाप्त करें |
| `Prefix + z` | पेन ज़ूम टॉगल करें (फुलस्क्रीन) |
| `Alt + Enter` | नीचे पेन विभाजित करें (बिना उपसर्ग) |
| `Alt + Shift + Enter` | बगल में पेन विभाजित करें (बिना उपसर्ग) |
| `Alt + Escape` | पेन समाप्त करें (बिना उपसर्ग) |
| `Ctrl + Alt + Arrows` | पेन के बीच जाएँ |
| `Ctrl + Alt + Shift + Arrows` | पेन का आकार बदलें |

### विंडो

| हॉटकी | कार्य |
| --- | --- |
| `Prefix + c` | नई विंडो |
| `Prefix + k` | विंडो समाप्त करें |
| `Prefix + r` | विंडो का नाम बदलें |
| `Alt + 1-9` | विशिष्ट विंडो पर जाएँ |
| `Alt + Arrow Left/Right` | विंडो के बीच जाएँ |
| `Alt + Shift + Arrow Left/Right` | विंडो बाएँ/दाएँ ले जाएँ |

### सेशन

| हॉटकी | कार्य |
| --- | --- |
| `Prefix + C` | नया सेशन |
| `Prefix + K` | सेशन समाप्त करें |
| `Prefix + R` | सेशन का नाम बदलें |
| `Prefix + N` | अगला सेशन |
| `Prefix + P` | पिछला सेशन |
| `Alt + Arrow Up/Down` | सेशन के बीच जाएँ |
| `Prefix + s` | सेशन सूचीबद्ध करें |
| `Prefix + d` | सेशन से अलग हों |

### कॉपी मोड (vi-शैली)

| हॉटकी | कार्य |
| --- | --- |
| `Prefix + [` | कॉपी मोड में प्रवेश करें |
| `v` | चयन शुरू करें (कॉपी मोड में) |
| `y` | चयन कॉपी करें (कॉपी मोड में) |

### सामान्य

| हॉटकी | कार्य |
| --- | --- |
| `Prefix + q` | कॉन्फ़िग रीलोड करें |
| `Prefix + ?` | Tmux कीबाइंडिंग दिखाएँ |
| `Prefix + :` | कमांड प्रॉम्प्ट |

### Tmux लेआउट फ़ंक्शन

ये फ़ंक्शन Tmux सेशन के अंदर चलाने होंगे।

| कमांड | कार्य |
| --- | --- |
| `tdl <ai> [<second_ai>]` | एडिटर, AI और टर्मिनल के साथ dev लेआउट बनाएँ |
| `tdlm <ai> [<second_ai>]` | प्रति सबडायरेक्टरी dev लेआउट बनाएँ |
| `tsl <count> <command>` | मल्टी-पेन swarm लेआउट बनाएँ |

## Ghostty Terminal

Ghostty टर्मिनल Omarchy मेनू के ज़रिए _Install > Terminal_ से इंस्टॉल किया जाता है।

| हॉटकी | कार्य |
| --- | --- |
| `Ctrl + Shift + E` | नीचे नया स्प्लिट |
| `Ctrl + Shift + O` | बगल में नया स्प्लिट |
| `Ctrl + Alt + Arrows` | स्प्लिट के बीच जाएँ |
| `Super + Ctrl + Shift + Arrows` | स्प्लिट का आकार 10 लाइनों से बदलें |
| `Super + Ctrl + Shift + Alt + Arrows` | स्प्लिट का आकार 100 लाइनों से बदलें |
| `Ctrl + Shift + T` | नया टैब |
| `Ctrl + Shift + Arrows` | टैब के बीच जाएँ |
| `Alt + Numbers` | विशिष्ट टैब पर जाएँ |
| `Shift + Pg Up/Down` | इतिहास स्क्रॉल करें |
| `Ctrl + Left mouse` | ब्राउज़र में लिंक खोलें |

## फ़ाइल मैनेजर

| हॉटकी | कार्य |
| --- | --- |
| `Ctrl + L` | पाथ पर जाएँ |
| `Space` | फ़ाइल पूर्वावलोकन (तीरों से नेविगेट करें) |
| `Alt + Up` | पैरेंट फ़ोल्डर पर ऊपर जाएँ |

## Neovim (w/ lazyvim)

### नेविगेशन

| हॉटकी | कार्य |
| --- | --- |
| `Space` | कमांड विकल्प दिखाएँ |
| `Space Space` | fuzzy सर्च से फ़ाइल खोलें |
| `Space E` | साइडबार टॉगल करें |
| `Space G G` | git नियंत्रण दिखाएँ |
| `Space S G` | फ़ाइल सामग्री खोजें |
| `Ctrl + W W` | साइडबार और एडिटर के बीच जाएँ |
| `Ctrl + Left/right arrow` | साइडबार का आकार बदलें |
| `Shift + H` | बाएँ फ़ाइल टैब पर जाएँ |
| `Shift + L` | दाएँ फ़ाइल टैब पर जाएँ |
| `Space B D` | फ़ाइल टैब बंद करें |

### साइडबार में रहते हुए

| हॉटकी | कार्य |
| --- | --- |
| `A` | पैरेंट dir में नई फ़ाइल जोड़ें |
| `Shift + A` | पैरेंट dir में नई सबdir जोड़ें |
| `D` | हाइलाइट की गई फ़ाइल/dir हटाएँ |
| `M` | हाइलाइट की गई फ़ाइल/dir ले जाएँ |
| `R` | हाइलाइट की गई फ़ाइल/dir का नाम बदलें |
| `?` | सभी कमांड के लिए सहायता दिखाएँ |

[LazyVim द्वारा कॉन्फ़िगर की गई सभी Neovim हॉटकी देखें](https://www.lazyvim.org/keymaps)।

## त्वरित इमोजी

आप पूरा emoji पिकर दिखाने के लिए `Super + Ctrl + E` इस्तेमाल कर सकते हैं जो चयन को क्लिपबोर्ड पर रखेगा या आप ये त्वरित पहुँच विकल्प इस्तेमाल कर सकते हैं।

| हॉटकी | EM | संकेत |
| --- | -- | --- |
| `Shift + CapsLock M S` | 😄 | मुस्कान |
| `Shift + CapsLock M C` | 😂 | रोना |
| `Shift + CapsLock M L` | 😍 | प्यार |
| `Shift + CapsLock M V` | ✌️ | जीत |
| `Shift + CapsLock M H` | ❤️ | दिल |
| `Shift + CapsLock M Y` | 👍 | हाँ |
| `Shift + CapsLock M N` | 👎 | नहीं |
| `Shift + CapsLock M F` | 🖕 | फ़क |
| `Shift + CapsLock M W` | 🤞 | इच्छा |
| `Shift + CapsLock M R` | 🤘 | रॉक |
| `Shift + CapsLock M K` | 😘 | चुंबन |
| `Shift + CapsLock M E` | 🙄 | आँखें घुमाना |
| `Shift + CapsLock M I` | 😉 | आँख मारना |
| `Shift + CapsLock M P` | 🙏 | प्रार्थना |
| `Shift + CapsLock M D` | 🤤 | लार |
| `Shift + CapsLock M M` | 💰 | पैसा |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | टोस्ट |
| `Shift + CapsLock M O` | 👌 | ठीक |
| `Shift + CapsLock M G` | 👋 | अभिवादन |
| `Shift + CapsLock M A` | 💪 | बाँह |
| `Shift + CapsLock M B` | 🤯 | दिमाग़ उड़ना |

## त्वरित पूर्णताएँ

| हॉटकी | पूर्णता |
| --- | --- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | आपका नाम (सेटअप पर दर्ज किया गया) |
| `Shift + CapsLock Space E` | आपका ईमेल (सेटअप पर दर्ज किया गया) |

आप `~/.XCompose` संपादित करके अपने और जोड़ सकते हैं, फिर बदलाव लागू होने के लिए टर्मिनल में `omarchy restart xcompose` चलाएँ।
