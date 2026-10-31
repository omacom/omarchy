# नेविगेशन

Omarchy में सब कुछ कीबोर्ड के ज़रिए होता है — _सब कुछ!_ जब सिस्टम पहली बार शुरू होता है, तो आप सचमुच अकेले माउस से कुछ भी नहीं कर सकते। लेकिन आप `Super + Space` दबाकर Omarchy Menu सामने ला सकते हैं और यहाँ से आप लगभग सब कुछ कर सकते हैं।

लेकिन Omarchy menu को भी ज़्यादातर समय सिस्टम चलाने का मुख्य तरीका बनाने का इरादा नहीं है। हम इससे भी तेज़ हो सकते हैं! सभी सबसे महत्वपूर्ण applications सीधे अलग-अलग hotkeys से जुड़े हैं। आप `Super + Return` से terminal शुरू करते हैं और `Super + Shift + Return` से browser। एक के बाद एक करके देखें, और आपको Hyprland की tiling का जादू काम करता हुआ दिखेगा:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

फिर आप `Super + J` दबाकर उन्हें अगल-बगल की जगह एक के ऊपर एक रख सकते हैं:

 ![navigation-stacked](images/navigation-stacked.webp)

उन्हें उनकी अगल-बगल वाली स्थितियों में वापस लाने के लिए फिर से `Super + J` दबाएँ। फिर browser पर रहते हुए `Super + Shift + Arrow Right` दबाकर windows को आपस में बदलकर देखें।

अब `Super + Shift + T` दबाकर Activity मॉनिटर शुरू करके देखें। वह एक floating window के रूप में सामने आएगा। आप `Super + T` का उपयोग करके उसे tile कर सकते हैं (और उसे फिर से floating बनाने के लिए वही फिर दबाएँ)। अब files manager खोलने के लिए `Super + Shift + F` दबाएँ। आपके सामने एक साफ़-सुथरी चार-तरफ़ा व्यवस्था होगी:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

आप `Super + Arrow` से उस window पर जाते हैं जिसे आप सक्रिय करना चाहते हैं। इससे focus बदल जाएगा और cursor नई application के बीच में चला जाएगा। किसी screen के किनारे पर, यह उस तरफ़ मौजूद monitor पर आगे बढ़ जाता है।

यदि आप `Super + Shift + 2` दबाते हैं, तो आप वर्तमान में focused application को दूसरे workspace पर ले जाएँगे। `Super + Shift + 1` उसे वापस ले आता है। (और `Super + Shift + Alt + 2` वर्तमान में focused application को दूसरे workspace पर ले जाएगा, लेकिन उस पर switch नहीं करेगा)।

एक से अधिक monitor होने पर, हर monitor के अपने workspaces 1 से 10 होते हैं। `Super + 2` आपको उस monitor के दूसरे workspace पर ले जाता है जिस पर आप हैं, और हर monitor की top bar उसके अपने workspaces और वह workspace दिखाती है जो वह दिखा रहा है। `Super + Tab` उस monitor पर मौजूद workspaces के बीच चक्र लगाता है जिस पर आप हैं। `Super + Shift + Ctrl + Arrows` जिस window पर आप हैं उसे उस दिशा में मौजूद monitor पर, उसके द्वारा दिखाए जा रहे workspace पर ले जाता है, और `Super + Shift + Alt + Arrows` जिस workspace पर आप हैं उसे उस दिशा में मौजूद monitor पर ले जाता है, जहाँ वह खाली होने पर वही नंबर ले लेता है। जब आप किसी monitor को unplug करते हैं तो वह अपने workspaces बनाए रखता है: वे किसी दूसरी screen के workspaces से जुड़ जाते हैं, उनकी संख्या उसके पास पहले से मौजूद workspaces के बाद से क्रमबद्ध होती है, और monitor के वापस आने पर वे अपने पुराने नंबरों के तहत वापस चले जाते हैं।

यदि आप `Super` दबाकर रखते हैं और माउस से किसी window पर click करते हैं, तो आप उसकी स्थिति को फिर से व्यवस्थित कर सकेंगे। यदि आप `Super` दबाकर रखते हैं और माउस के दाएँ button का उपयोग करते हैं, तो आप window का आकार स्वतंत्र रूप से बदल सकते हैं।

आप `Super + W` या `Super + Q` पर कोई window बंद करते हैं (और `Ctrl + Alt + Delete` पर सभी windows बंद करते हैं)।

आप `Super + F` से full screen भी कर सकते हैं या `Super + Alt + F` से सिर्फ़ full-width (top bar बनाए रखते हुए) या `Super + Ctrl + F` से किसी window के भीतर full-screen भी कर सकते हैं (YouTube के लिए बढ़िया!)।

### Dwindle बनाम स्क्रॉलिंग लेआउट

Omarchy के default layout को dwindle कहा जाता है। यह आपके द्वारा एक ही workspace पर खोली गई सभी windows को हर समय दिखाई देता रखता है, भले ही इसके लिए उन्हें छोटा करना पड़े।

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

लेकिन आप किसी workspace को scrolling layout में बदलना भी चुन सकते हैं जहाँ windows अगल-बगल लगी होती हैं, display के दिखाई देने वाले किनारे से परे तक। आप `Super + L` के ज़रिए किसी एक workspace को इस layout में बदलते हैं।

`Super + L` फिर से दबाने से workspace floating हो जाता है, जहाँ windows स्वतंत्र रूप से एक-दूसरे पर चढ़ती हैं और आप उन्हें खुद रखते हैं, और तीसरी बार दबाने से वह dwindle पर वापस आ जाता है। `Super + Alt + L` इनमें दूसरी दिशा में जाता है। कोई window जो वैसे भी float करती है — जिसे आपने `Super + T` से बाहर निकाला है, या कोई app जो हमेशा floating ही खुलती है — workspace के tiling पर वापस जाने पर भी floating बनी रहती है। top bar आपके वर्तमान workspace को उसके layout से चिह्नित करती है: dwindle के लिए एक वर्ग, scrolling के लिए एक वृत्त, और floating के लिए एक त्रिभुज। उस चिह्न पर click करने से भी layout का चक्र बदलता है।

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

यह चुनाव प्रति workspace होता है, और यह बना रहता है। इसलिए आप browsing के लिए workspace 1 को dwindle पर और code के लिए workspace 2 को scrolling पर रख सकते हैं, और restart के बाद वे उसी तरह वापस आएँगे।

यदि आप scrolling layout को default के रूप में उपयोग करना चाहते हैं, तो आप इसे `~/.config/hypr/looknfeel.lua` में set कर सकते हैं:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Floating workspaces

एक floating workspace एक पारंपरिक desktop की तरह काम करता है: windows एक-दूसरे पर चढ़ती हैं, और आप उन्हें खुद ले जाते और उनका आकार तय करते हैं। हर window को आपके theme के रंगों में एक titlebar मिलती है, जिसमें minimize, maximize और close करने के buttons होते हैं। `Super + M` focused window को भी minimize करती है। एक minimized window dock में इंतज़ार करती है; उसे वापस लाने के लिए उसके app पर click करें। किसी window को आगे लाने के लिए उस पर click करें। किसी भी किनारे या कोने से उसका आकार बदलें। top bar को दिखाई देते रखते हुए window को maximize करने के लिए किसी titlebar पर double-click करें, और उसका पुराना आकार वापस पाने के लिए फिर से double-click करें।

एक floating workspace एक dock भी दिखाता है, जिसमें आपके pinned apps, जो कुछ भी चल रहा है वह सब, और apps button के पीछे हर app की एक grid होती है, जिसे `Super + Alt + Space` और Omarchy menu में _Apps_ भी खोलते हैं। grid पर किसी app पर right-click करके, या `Delete` दबाकर, उसे uninstall करें। किसी app को खोलने, या उसकी window को आगे लाने के लिए उस पर click करें; उसकी windows के बीच चक्र लगाने के लिए फिर से click करें। Middle-click एक नई window खोलता है। किसी icon को dock के साथ खींचकर उसे ले जाएँ; किसी चल रही app को बाकियों के बीच खींचने से वह वहीं रहती है। किसी app को dock में रखने, उसे वहाँ से हटाने, या उसे quit करने के लिए right-click करें। dock किसी fullscreen window के रास्ते से हट जाता है। dock को किसी दूसरे किनारे पर ले जाने या pointer के उसके किनारे तक पहुँचने तक उसे छिपाए रखने के लिए apps button पर right-click करें। यह स्थिति _Appearance > Dock > Dock Position_ के अंतर्गत भी है, और `omarchy dock position left` और `omarchy dock autohide on` दोनों को terminal से set करते हैं। जिन apps को आप dock में रखते हैं वे चल न रही हों तो फीकी दिखाई देती हैं।

नए workspaces, और कोई भी ऐसा workspace जिसे आपने `Super + L` से उसका अपना layout नहीं दिया है, default layout का उपयोग करते हैं। default बदलने से बिना windows वाला हर workspace उस पर reset हो जाता है, जबकि जिस पर windows हैं वह अपना मौजूदा layout बनाए रखता है। dock में minimize की गई window अब भी उस workspace पर एक window के रूप में गिनी जाती है जिसे उसने छोड़ा था। इसे _Appearance > Workspace Layout_ के अंतर्गत चुनें: Tiling, Scrolling, या Floating। `omarchy-hyprland-workspace-layout-default scrolling` इसे terminal से set करता है।

### Windows को समूहबद्ध करना

`Super + G` का उपयोग करके Windows को समूहबद्ध किया जा सकता है। एक बार जब आप किसी group में होते हैं, तो उसके सक्रिय रहते हुए आप जो भी window शुरू करेंगे वह उस group की होगी। आप `Super + Ctrl + Arrow Left/Right` का उपयोग करके या क्रम में सीधे किसी grouped window पर जाने के लिए `Super + Alt + 1/2/3/4` का उपयोग करके इन grouped windows के बीच जा सकते हैं।

आप `Super + Alt + G` से किसी window को grouping से बाहर ले जा सकते हैं या फिर से `Super + G` दबाकर पूरे group को खत्म कर सकते हैं। अंत में, आप `Super + Alt + Arrows` से group के बाहर की windows को उसके अंदर ले जा सकते हैं।

### Windows को बाहर निकालना

आप `Super + O` से किसी window को उसके workspace आवंटन से बाहर निकाल सकते हैं। इससे वह एक floating window के रूप में pin हो जाएगी जो आप जिस भी workspace पर जाएँगे वहाँ आपके साथ जाएगी। video players और ऐसी ही चीज़ों के लिए बढ़िया।

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad workspace

एक विशेष full-size scratchpad workspace है जो आप वर्तमान में जिस भी workspace पर हैं उस पर overlay हो जाता है। आप `Super + S` का उपयोग करके उस पर मौजूद चीज़ों तक पहुँचते हैं, और आप `Super + Alt + S` का उपयोग करके वहाँ windows रखते हैं।

यह controls या किसी terminal के लिए अच्छी तरह काम करता है जिसके साथ आप वर्तमान workspace छोड़े बिना जल्दी से interact करना चाहते हैं।

### Quake console

अंत में, एक आधी-ऊँचाई वाला Quake console है जो आप वर्तमान में जिस भी workspace पर हैं उस पर नीचे आ जाता है। इसे `Super + Grave` से toggle करें, और `Super + Shift + Grave` का उपयोग करके वहाँ कोई window रखें।

यह आपके default agent के साथ तैयार होकर खुलता है। जब console में एक ही window होती है, तो यह screen पर फैलने के बजाय एक केंद्रित panel के रूप में नीचे आता है। उस पर दूसरी app रखें और यह पूरी चौड़ाई पर वापस चला जाता है, ताकि दोनों को अगल-बगल बैठने की जगह मिले।

scratchpad या console, किसी से भी किसी window को हटाने के लिए, उसे `Super + Shift + 1` जैसी किसी चीज़ से सीधे किसी दूसरे workspace पर भेजें।

### इसकी आदत डालने में थोड़ा समय लगता है!

अपने desktop को इस तरह navigate करने की आदत डालने में थोड़ा समय लगता है, लेकिन एक बार जब आप डाल लेते हैं, तो पारंपरिक माउस-संचालित desktop अनुभव पर वापस जाना मुश्किल होगा!
