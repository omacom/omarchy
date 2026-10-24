# नेविगेशन

Omarchy में सब कुछ keyboard के जरिए होता है — _सब कुछ!_ जब system पहली बार शुरू होता है, तो सचमुच आप अकेले mouse से कुछ भी नहीं कर सकते। लेकिन आप `Super + Space` दबाकर Omarchy Menu खोल सकते हैं और यहाँ से आप लगभग सब कुछ कर सकते हैं।

लेकिन Omarchy menu का इरादा ज्यादातर समय system चलाने का मुख्य तरीका बनने का भी नहीं है। हम इससे तेज हो सकते हैं! सभी सबसे महत्वपूर्ण applications सीधे अलग-अलग hotkeys से जुड़े हैं। आप terminal `Super + Return` से और browser `Super + Shift + Return` से शुरू करते हैं। एक के बाद एक करके देखें, और आप Hyprland की tiling का जादू काम करते हुए देखेंगे:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

फिर आप `Super + J` दबाकर उन्हें बगल-बगल के बजाय एक के ऊपर एक रख सकते हैं:

 ![navigation-stacked](images/navigation-stacked.webp)

`Super + J` फिर से दबाकर उन्हें उनकी बगल-बगल वाली स्थितियों में वापस लौटाएँ। फिर browser पर होते हुए windows की अदला-बदली के लिए `Super + Shift + Arrow Right` आज़माएँ।

अब Activity monitor शुरू करने के लिए `Super + Ctrl + T` आज़माएँ। वह floating window के रूप में आएगा। आप `Super + T` से उसे tile कर सकते हैं (और उसे फिर से दबाकर उसे दोबारा floating बना सकते हैं)। अब files manager खोलने के लिए `Super + Shift + F` दबाएँ। आपके पास एक साफ-सुथरा चार-तरफ़ा setup होगा:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

आप `Super + Arrow` से उस window के बीच नेविगेट करते हैं जिसे आप active करना चाहते हैं। इससे focus बदलेगा और cursor नए application के केंद्र में चला जाएगा।

यदि आप `Super + Shift + 2` दबाते हैं, तो आप वर्तमान focused application को दूसरे workspace पर ले जाएँगे। `Super + Shift + 1` उसे वापस ले जाता है। (और `Super + Shift + Alt + 2` वर्तमान focused application को दूसरे workspace पर ले जाएगा, उस पर जाए बिना)।

यदि आप `Super` दबाए रखकर mouse से किसी window पर click करते हैं, तो आप उसे जहाँ रखा है वहाँ फिर से व्यवस्थित कर पाएँगे। यदि आप `Super` दबाए रखकर mouse के right button का उपयोग करते हैं, तो आप window का आकार स्वतंत्र रूप से बदल सकते हैं।

आप किसी window को `Super + W` या `Super + Q` पर बंद करते हैं (और सभी windows को `Ctrl + Alt + Delete` पर बंद करते हैं)।

आप `Super + F` से full screen भी जा सकते हैं या `Super + Alt + F` से केवल full-width (top bar को बनाए रखते हुए) या `Super + Ctrl + F` से window के भीतर full-screen भी जा सकते हैं (YouTube के लिए बढ़िया है!)।

### Dwindle बनाम scrolling layout

Omarchy के default layout को dwindle कहा जाता है। यह किसी एक workspace पर आपकी खोली गई सभी windows को हर समय दिखाई देता रखता है, भले ही उसे उन्हें छोटा करना पड़े।

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

लेकिन आप किसी workspace को scrolling layout में बदलने का विकल्प भी चुन सकते हैं जहाँ windows display के दिखाई देने वाले किनारे से परे, बगल-बगल में एक कतार में लगी होती हैं। आप `Super + L` के जरिए किसी एक workspace को इस layout में बदलते हैं।

`Super + L` फिर से दबाने से workspace floating हो जाता है, जहाँ windows स्वतंत्र रूप से overlap होती हैं और आप उन्हें खुद रखते हैं, और तीसरी बार दबाने से वह dwindle पर लौट आता है। `Super + Alt + L` उन्हें दूसरी दिशा में ले जाता है। कोई window जो वैसे भी float करती है — जिसे आपने `Super + T` से बाहर निकाला है, या कोई app जो हमेशा floating खुलती है — workspace के tiling पर वापस जाने पर भी floating ही रहती है। Top bar जिस workspace पर आप हैं उसे उसके layout के साथ चिह्नित करता है: dwindle के लिए एक वर्ग, scrolling के लिए एक वृत्त, और floating के लिए एक त्रिभुज। उस चिह्न पर click करने से भी layout बदलता रहता है।

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

यह चुनाव प्रति workspace होता है, और यह बना रहता है। इसलिए आप workspace 1 को browsing के लिए dwindle पर और workspace 2 को code के लिए scrolling पर रख सकते हैं, और restart के बाद वे उसी तरह वापस आएँगे।

यदि आप scrolling layout को default के रूप में उपयोग करना चाहते हैं, तो आप वह `~/.config/hypr/looknfeel.lua` में set कर सकते हैं:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Floating workspaces

Floating workspace पारंपरिक desktop की तरह काम करता है: windows overlap होती हैं, और आप उन्हें खुद हटाते और उनका आकार तय करते हैं। प्रत्येक window को आपकी theme के रंगों में एक titlebar मिलता है, जिसमें minimize, maximize, और close करने के buttons होते हैं। `Super + M` focused window को भी minimize कर देता है। Minimize की गई window dock में प्रतीक्षा करती है; उसे वापस लाने के लिए उसकी app पर click करें। किसी window को आगे लाने के लिए उस पर click करें। उसे किसी भी किनारे या कोने से resize करें। Window को maximize करते हुए top bar को दिखाई देता रखने के लिए titlebar पर double-click करें, और उसका पुराना आकार वापस पाने के लिए फिर से double-click करें।

Floating workspace एक dock भी दिखाता है, जिसमें आपकी pinned apps, जो कुछ भी चल रहा है वह सब, और apps button के पीछे हर app का grid होता है, जिसे `Super + Alt + Space` और Omarchy menu में _Apps_ भी खोलते हैं। किसी app को uninstall करने के लिए grid पर उस पर right-click करें, या `Delete` दबाएँ। किसी app को खोलने के लिए, या उसकी window को आगे लाने के लिए उस पर click करें; उसकी windows में चक्र लगाने के लिए फिर से click करें। Middle-click से नई window खुलती है। किसी icon को हटाने के लिए उसे dock के साथ-साथ drag करें; चल रही app को दूसरों के बीच drag करने से वह वहीं बनी रहती है। किसी app को dock में रखने, उसे बाहर निकालने, या उसे quit करने के लिए right-click करें। Dock fullscreen window के रास्ते से हट जाता है। Dock को किसी दूसरे किनारे पर ले जाने के लिए या pointer के उसके किनारे तक पहुँचने तक उसे छिपाए रखने के लिए apps button पर right-click करें। यह स्थिति _Trigger > Appearance > Dock > Dock Position_ के अंतर्गत भी है, और `omarchy dock position left` और `omarchy dock autohide on` दोनों को terminal से set करते हैं। Dock में आप जिन apps को रखते हैं वे तब फीके होते हैं जब वे नहीं चल रहे होते हैं।

नए workspaces, और जिन्हें भी आपने `Super + L` से अपना खुद का layout नहीं दिया है, वे default layout का उपयोग करते हैं। Default बदलने से बिना windows वाला हर workspace उस पर reset हो जाता है, जबकि जिस पर windows हैं वह अपना मौजूदा layout बनाए रखता है। Dock में minimize की गई window अभी भी उस workspace पर एक window मानी जाती है जिसे उसने छोड़ा था। उसे _Trigger > Appearance > Workspace Layout_ के अंतर्गत चुनें: Tiling, Scrolling, या Floating। `omarchy-hyprland-workspace-layout-default scrolling` उसे terminal से set करता है।

### Windows को group करना

Windows को `Super + G` का उपयोग करके group किया जा सकता है। एक बार जब आप किसी group में होते हैं, तो उसके active रहते हुए आप जो हर window शुरू करेंगे वह group से संबंधित होगी। आप `Super + Ctrl + Arrow Left/Right` का उपयोग करके या क्रम में सीधे grouped window पर जाने के लिए `Super + Alt + 1/2/3/4` का उपयोग करके इन grouped windows के बीच जा सकते हैं।

आप `Super + Alt + G` से किसी window को grouping से बाहर ले जा सकते हैं या `Super + G` फिर से दबाकर पूरे group को खत्म कर सकते हैं। अंत में, आप `Super + Alt + Arrows` से group के बाहर की windows को उसके भीतर ले जा सकते हैं।

### Windows को pop करना

आप `Super + O` से किसी window को उसके workspace आवंटन से बाहर pop कर सकते हैं। वह उसे एक floating window के रूप में pin कर देगा जो आप जिस भी workspace पर जाते हैं वहाँ आपका पीछा करेगी। Video players और ऐसी ही चीज़ों के लिए बढ़िया है।

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad workspace

अंत में, एक विशेष scratchpad workspace है जो आप वर्तमान में जिस भी workspace पर हैं उसके ऊपर नीचे आता है, काफी हद तक Quake console की तरह। उसे `Super + Grave` या `Super + S` से toggle करें, और वहाँ कोई window `Super + Shift + Grave` या `Super + Alt + S` का उपयोग करके रखें।

यह विशेष रूप से agent चला रहे terminal के लिए, या उन controls के लिए अच्छी तरह काम करता है जिनके साथ आप वर्तमान workspace को छोड़े बिना जल्दी से interact करना चाहते हैं। किसी window को scratchpad से हटाने के लिए, उसे `Super + Shift + 1` जैसी किसी चीज़ से सीधे दूसरे workspace पर भेजें।

जबकि scratchpad में एक ही window होती है, यह screen पर फैलने के बजाय केंद्र में स्थित panel के रूप में नीचे आता है। उस पर दूसरी app रखें और यह पूरी width पर वापस चला जाता है, ताकि दोनों को बगल-बगल में बैठने के लिए जगह मिले।

### इसकी आदत पड़ने में थोड़ा समय लगता है!

अपने desktop को इस तरह नेविगेट करने की आदत पड़ने में थोड़ा समय लगता है, लेकिन एक बार जब आपको इसकी आदत पड़ जाती है, तो पारंपरिक mouse-चालित desktop अनुभव पर वापस जाना मुश्किल होगा!
