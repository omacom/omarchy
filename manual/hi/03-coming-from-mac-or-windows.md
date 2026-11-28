# Mac या Windows से आ रहे हैं तो

अगर आपने वर्षों macOS या Windows पर बिताए हैं, तो आपकी उंगलियाँ सौ ऐसी बातें जानती हैं जिन्हें आपका दिमाग़ भूल ही चुका है कि उसने कभी सीखी थीं। यह अध्याय वही अनुवाद-परत है: Omarchy में वे सहज आदतें कहाँ जाती हैं। ख़ुद सुविधाओं पर विस्तार से कहीं और चर्चा है — यह बस नक्शा है।

### Super हर चीज़ के केंद्र में है

Cmd या Windows key के इर्द-गिर्द बनी आपकी सारी मसल मेमोरी एक ही key पर आ जाती है: Super। PC keyboard पर वही Windows key है, और Omarchy में लगभग हर hotkey का सहारा वही है।

आपका Spotlight या Raycast या Start-menu वाला रिफ़्लेक्स बन जाता है `Super + Space`। इससे Omarchy menu खुलता है, जो apps लॉन्च करता है, settings बदलता है, software install करता है, screen capture करता है — लगभग हर काम। फ़िल्टर करने के लिए बस टाइप करना शुरू कर दीजिए। `Super + Alt + Space` हर app को एक ही grid पर दिखाता है, ठीक Launchpad की तरह। देखें [नेविगेशन](04-navigation.md)।

### कोई desktop icons नहीं, और dock सिर्फ़ तब दिखता है जब आप float करते हैं

Desktop पर सजाने के लिए कोई icons नहीं हैं, और tiling workspace पर कोई dock नहीं है — dock सिर्फ़ floating workspace पर दिखाई देता है (देखें [नेविगेशन](04-navigation.md))। Apps किसी hotkey से शुरू होते हैं (`Super + Return` terminal के लिए, `Super + Shift + Return` browser के लिए, और `Super + K` उन सभी की सूची के लिए जिन पर कुछ mapped है) या menu से। UI का एकमात्र स्थायी हिस्सा है [ऊपरी बार](05-the-top-bar.md), जो आपके लिए पहले menu bar, system tray और Notification Center का काम समेटता है — और उस पर मौजूद लगभग हर widget left, right और middle click पर कुछ करता है।

### Windows ख़ुद अपनी जगह ले लेती हैं

सोच का सबसे बड़ा बदलाव: आप windows को इधर-उधर नहीं घसीटते, न उन्हें screen के आधों हिस्सों में snap करते हैं। एक window खोलिए और वह पूरी screen ले लेती है। दूसरी खोलिए और वे screen को बाँट लेती हैं। आपको कभी किसी window को दूसरी के नीचे से निकालना नहीं पड़ता, क्योंकि windows एक-दूसरे पर चढ़ती ही नहीं।

जब आपको सचमुच floating window चाहिए हो, तो `Super + T` सक्रिय window को tiling से बाहर (और वापस) ले आता है। लेकिन पहले tiling को एक असली मौका दीजिए — यही पूरे सिस्टम का दिल है। [नेविगेशन](04-navigation.md) आपको इसमें से गुज़ारता है।

Workspaces जाने-पहचाने लगेंगे: वे macOS Spaces या Windows virtual desktops हैं, फ़र्क़ यह है कि आप सचमुच उनका इस्तेमाल करेंगे, क्योंकि `Super + 1/2/3/4` सीधे किसी एक पर ले जाता है और `Super + Shift + 1/2/3/4` सक्रिय window को वहाँ भेज देता है। कोई animation delay नहीं, बस तुरंत jumps। इसका मतलब है कि आपको शायद कई monitors की ज़रूरत ही न पड़े, अगर पहले आपको उनकी आदत थी।

### Copy और paste बस काम करते हैं

Mac पर आपके पास हर जगह Cmd + C था। Windows पर आपके पास हर जगह Ctrl + C था — terminal को छोड़कर, जहाँ वह आपके program को मार देता है। Omarchy आपको `Super + C`, `Super + X` और `Super + V` देता है, और वे हर जगह काम करते हैं, terminal समेत। Shell के लिए अलग से कोई रिफ़्लेक्स सीखने की ज़रूरत नहीं।

Windows वालों: आपका Win + V clipboard history `Super + Ctrl + V` पर रहता है, और वह text के साथ-साथ images भी रखता है। देखें [एकीकृत clipboard और history](08-unified-clipboard-history.md)।

### अनुवाद की तालिका

| आप जिसकी ओर हाथ बढ़ाते हैं | Omarchy में |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy menu |
| AirDrop | LocalSend, `Super + Ctrl + S` के ज़रिए — देखें [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` या `Print Screen` — देखें [screenshots और recording](12-screenshots-recording.md) |
| Notification Center | `Super + Shift + Alt + ,` पर Notification history |
| Time Machine (system के लिए) | हर update पर स्वचालित [system snapshots](47-system-snapshots.md) |
| App Store / installer download करना | menu में _Install_, या `omarchy pkg add` — देखें [अन्य packages](29-other-packages.md) |
| System Settings / Control Panel | menu में _Setup_, जो सादी config files को edit करता है — देखें [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, `Super + Shift + F` पर — देखें [GUIs](22-guis.md) |
| Safari / Edge | `Super + Shift + Return` पर Google Chrome; _Setup > Defaults > Browser_ के अंतर्गत कोई और चुनें — देखें [ब्राउज़र](23-browsers.md) |
| Preview / Photos | तस्वीरों, video और music के लिए Omaview, PDFs के लिए Document Viewer — देखें [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, `Super + Shift + N` पर; _Setup > Defaults > Editor_ के अंतर्गत कोई और चुनें |

### कुछ चीज़ें सचमुच अलग हैं

कई settings उन text files में रहती हैं जिन्हें आप edit करते हैं, उन panels में नहीं जिनमें आप click करते-करते आगे बढ़ते हैं। यह तब तक पुराना-सा लगता है जब तक आपको एहसास नहीं होता कि इसका मतलब है हर tweak देखा जा सकता है, आपकी अगली machine पर copy किया जा सकता है, और version control में रखा जा सकता है। _Setup_ menu आपको सीधे सही file में ले जाता है और काम पूरा होने पर जो कुछ restart करना ज़रूरी हो, उसे restart कर देता है।

Updates एक ही command से आते हैं — _Update > Omarchy_ — जो Omarchy को ख़ुद और system के हर package को update करता है, और पहले एक snapshot लेता है। कोई per-app updaters बेवक़्त आपको परेशान नहीं करते। देखें [अपडेट्स](30-updates.md)।

Software किसी package manager से आता है, download किए गए installers से नहीं।

और जब आप कोई window बंद करते हैं, तो app सचमुच quit हो जाता है। कोई macOS वाला अधर-झूला नहीं है जहाँ program बिना किसी window के चलता रहता है। `Super + W` — या `Super + Q`, अगर आप उसी finger memory के साथ आए हैं — का मतलब है ख़त्म।

### Mac hardware पर

Omarchy Intel Macs पर, और Omarchy for Apple Silicon के साथ M1, M2 और M3 Macs पर अच्छी तरह चलता है। देखें [Mac समर्थन](44-mac-support.md)। और keyboard आपके साथ नरमी बरतता है: Omarchy कुछ भी remap नहीं करता, और Linux Command key को Super मानता है, इसलिए Super ठीक वहीं बैठता है जहाँ Cmd हमेशा था। आपके अँगूठे को यह बदलाव महसूस ही नहीं होगा।

### इसे दो हफ़्ते दीजिए

सहज आदतें आपकी सोच से तेज़ी से transfer हो जाती हैं। [हॉटकीज़](07-hotkeys.md) अध्याय को एक बार सरसरी तौर पर देख लीजिए, और जब भी कोई binding याद न आए, `Super + K` दबाइए — वह आपको वे सभी दिखा देता है। यही इकलौती hotkey है जिसे आपको सचमुच याद करना है।
