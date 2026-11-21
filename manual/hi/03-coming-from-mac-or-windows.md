# Mac या Windows से आ रहे हैं

अगर आपने वर्षों macOS या Windows पर बिताए हैं, तो आपकी उंगलियों को सैकड़ों ऐसी चीज़ें याद हैं जिन्हें आपका दिमाग कभी सीखना ही भूल गया है। यह अध्याय वही अनुवाद-परत है: Omarchy में वे आदतें कहां जाती हैं। सुविधाओं को विस्तार से कहीं और समझाया गया है — यह सिर्फ़ नक्शा है।

### Super ही हर चीज़ का केंद्र है

Cmd या Windows key के इर्द-गिर्द बनी आपकी सारी मसल मेमोरी एक ही key में स्थानांतरित हो जाती है: Super। PC कीबोर्ड पर यही Windows key है, और Omarchy में लगभग हर hotkey का आधार यही है।

Spotlight या Raycast या Start-menu वाली आपकी आदत `Super + Space` बन जाती है। इससे Omarchy मेन्यू खुलता है, जो ऐप्स लॉन्च करता है, सेटिंग्स बदलता है, सॉफ़्टवेयर इंस्टॉल करता है, स्क्रीन कैप्चर करता है — लगभग सब कुछ। फ़िल्टर करने के लिए टाइप करना शुरू करें। `Super + Alt + Space` Launchpad की तरह सभी ऐप्स को एक ग्रिड में दिखाता है। [नेविगेशन](04-navigation.md) देखें।

### कोई desktop icons नहीं, और dock सिर्फ़ तब दिखता है जब आप float करते हैं

Desktop पर सजाने के लिए कोई icons नहीं हैं, और tiling workspace पर कोई dock नहीं है — dock सिर्फ़ floating workspace पर दिखाई देता है ([नेविगेशन](04-navigation.md) देखें)। ऐप्स किसी hotkey से शुरू होते हैं (terminal के लिए `Super + Return`, browser के लिए `Super + Shift + Return`, और जो कुछ भी mapped है उसकी सूची के लिए `Super + K`) या मेन्यू से। एकमात्र स्थायी UI हिस्सा [ऊपरी बार](05-the-top-bar.md) है, जो वह सब संभालती है जो पहले menu bar, system tray और Notification Center आपके लिए करते थे — और उस पर मौजूद लगभग हर widget left, right और middle click पर कुछ न कुछ करता है।

### Windows अपने-आप लग जाती हैं

सबसे बड़ा मानसिक बदलाव: आप windows को इधर-उधर नहीं खींचते, न ही उन्हें स्क्रीन के आधों में snap करते हैं। एक window खोलें और वह पूरी स्क्रीन ले लेती है। दूसरी खोलें और वे स्क्रीन को बांट लेती हैं। आपको कभी किसी window को दूसरी के नीचे से निकालना नहीं पड़ता, क्योंकि windows एक-दूसरे को overlap नहीं करतीं।

जब आपको सचमुच एक floating window चाहिए हो, तो `Super + T` सक्रिय window को tiling से बाहर (और वापस अंदर) कर देता है। लेकिन पहले tiling को एक असली मौका दें — यही पूरी चीज़ का दिल है। [Navigation](04-navigation.md) आपको इसमें ले चलता है।

Workspaces परिचित लगेंगे: ये macOS Spaces या Windows virtual desktops हैं, बस फ़र्क यह है कि आप इन्हें सचमुच इस्तेमाल करेंगे, क्योंकि `Super + 1/2/3/4` आपको सीधे किसी एक पर ले जाता है और `Super + Shift + 1/2/3/4` सक्रिय window को वहां भेज देता है। कोई animation delay नहीं, बस तुरंत छलांगें। इसका मतलब है कि आपको कई monitors की ज़रूरत ही न पड़े, अगर पहले आपको उनकी आदत थी।

### Copy और paste बस काम करते हैं

Mac पर आपके पास हर जगह Cmd + C था। Windows पर हर जगह Ctrl + C था — सिवाय terminal के, जहां यह आपके program को बंद कर देता है। Omarchy आपको `Super + C`, `Super + X` और `Super + V` देता है, और ये terminal समेत हर जगह काम करते हैं। Shell के लिए कोई अलग आदत सीखने की ज़रूरत नहीं।

Windows वालों के लिए: आपकी Win + V clipboard history `Super + Ctrl + V` पर रहती है, और इसमें text के साथ-साथ images भी रहती हैं। [unified clipboard & history](08-unified-clipboard-history.md) देखें।

### अनुवाद तालिका

| आप जिसे ढूंढते हैं | Omarchy में |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy मेन्यू |
| AirDrop | LocalSend, `Super + Ctrl + S` के ज़रिए — [GUIs](22-guis.md) देखें |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` या `Print Screen` — [screenshots & recording](12-screenshots-recording.md) देखें |
| Notification Center | `Super + Shift + Alt + ,` पर Notification history |
| Time Machine (system के लिए) | हर update पर स्वचालित [system snapshots](47-system-snapshots.md) |
| App Store / कोई installer download करना | मेन्यू में _Install_, या `omarchy pkg add` — [other packages](29-other-packages.md) देखें |
| System Settings / Control Panel | मेन्यू में _Setup_, जो सादी config files को edit करता है — [dotfiles](31-dotfiles.md) देखें |
| Finder / File Explorer | Files, `Super + Shift + F` पर — [GUIs](22-guis.md) देखें |
| Safari / Edge | `Super + Shift + Return` पर Google Chrome; _Setup > Defaults > Browser_ के तहत कोई और चुनें — [browsers](23-browsers.md) देखें |
| Preview / Photos | तस्वीरों, video और music के लिए Omaview, PDFs के लिए Document Viewer — [GUIs](22-guis.md) देखें |
| TextEdit / Notepad | Plain, `Super + Shift + N` पर; _Setup > Defaults > Editor_ के तहत कोई और चुनें |

### कुछ चीज़ें सचमुच अलग हैं

बहुत-सी सेटिंग्स उन text files में रहती हैं जिन्हें आप edit करते हैं, उन panels में नहीं जिनमें आप click करते फिरते हैं। यह तब तक आदिम लगता है जब तक आपको एहसास न हो कि इसका मतलब है हर बदलाव को देखा जा सकता है, आपकी अगली machine पर copy किया जा सकता है, और version control में रखा जा सकता है। _Setup_ मेन्यू आपको सीधे सही file में पहुंचा देता है और जब आप काम पूरा कर लेते हैं तो जो कुछ भी restart करना ज़रूरी हो उसे restart कर देता है।

Updates एक ही command से आते हैं — _Update > Omarchy_ — जो Omarchy को स्वयं और system के हर package को update करता है, और पहले एक snapshot लेता है। कोई per-app updaters आपको बेतरतीब ढंग से परेशान नहीं करते। [updates](30-updates.md) देखें।

सॉफ़्टवेयर किसी package manager से आता है, download किए गए installers से नहीं।

और जब आप कोई window बंद करते हैं, तो ऐप सचमुच quit हो जाता है। यहां कोई macOS वाला अधर नहीं है जहां program बिना किसी window के चलता रहे। `Super + W` — या `Super + Q`, अगर आप उसी उंगलियों की याद के साथ आए हैं — का मतलब है ख़त्म।

### Mac hardware पर

Omarchy Intel Macs पर अच्छी तरह चलता है — [Mac support](44-mac-support.md) देखें। और कीबोर्ड आपके साथ नरमी बरतता है: Omarchy कुछ भी remap नहीं करता, और Linux Command key को Super मानता है, इसलिए Super ठीक वहीं बैठता है जहां Cmd हमेशा था। आपके अंगूठे को यह बदलाव महसूस ही नहीं होगा।

### इसे दो हफ्ते दें

आदतें आपकी सोच से तेज़ी से स्थानांतरित होती हैं। [hotkeys](07-hotkeys.md) अध्याय को एक बार सरसरी तौर पर पढ़ें, और जब भी कोई binding याद न आए, `Super + K` दबाएं — यह आपको वे सब दिखा देता है। यही एकमात्र hotkey है जिसे आपको सचमुच याद करना है।
