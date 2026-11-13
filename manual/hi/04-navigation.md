# नेविगेशन

Omarchy में हर चीज़ कीबोर्ड के ज़रिए होती है — _हर चीज़!_ जब सिस्टम पहली बार शुरू होता है, तो आप सचमुच अकेले माउस से एक भी काम नहीं कर सकते। लेकिन आप `Super + Space` दबाकर Omarchy Menu सामने ला सकते हैं और यहाँ से आप लगभग हर काम कर सकते हैं।

लेकिन Omarchy menu को ज़्यादातर समय सिस्टम चलाने का मुख्य तरीका बनने के लिए बनाया ही नहीं गया है। हम इससे तेज़ हो सकते हैं! सभी सबसे महत्वपूर्ण applications सीधे अलग-अलग hotkeys से बँधे हैं। आप `Super + Return` से terminal शुरू करते हैं और `Super + Shift + Return` से browser। एक के बाद एक करके देखिए, और आपको Hyprland की tiling का जादू काम करता हुआ दिखेगा:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

फिर आप उन्हें साथ-साथ रखने के बजाय एक के ऊपर एक रखने के लिए `Super + J` दबा सकते हैं:

 ![navigation-stacked](images/navigation-stacked.webp)

उन्हें फिर से साथ-साथ वाली स्थितियों में लौटाने के लिए फिर से `Super + J` दबाएँ। फिर browser में रहते हुए windows को आपस में बदलने के लिए `Super + Shift + Arrow Right` दबाकर देखें।

अब Activity monitor शुरू करने के लिए `Super + Shift + T` दबाकर देखें। वह एक floating window के रूप में दिखाई देगा। आप `Super + T` का उपयोग करके उसे tile कर सकते हैं (और उसे फिर से floating बनाने के लिए वही फिर से दबाएँ)। अब file manager खोलने के लिए `Super + Shift + F` दबाएँ। आपके सामने एक साफ़-सुथरी चार-तरफ़ा व्यवस्था होगी:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

आप जिस window को सक्रिय करना चाहते हैं, उस पर आप `Super + Arrow` से जाते हैं। यह focus बदल देगा और cursor को नए application के केंद्र में ले जाएगा। किसी screen के किनारे पर, यह उसी तरफ़ वाले monitor पर आगे बढ़ जाता है।

यदि आप `Super + Shift + 2` दबाते हैं, तो आप वर्तमान में focused application को दूसरे workspace पर ले जाएँगे। `Super + Shift + 1` उसे वापस ले आता है। (और `Super + Shift + Alt + 2` वर्तमान में focused application को उस पर switch किए बिना दूसरे workspace पर ले जाएगा)।

एक से अधिक monitor होने पर, हर monitor के अपने 1 से 10 तक के workspaces होते हैं। `Super + 2` आपको जिस monitor पर आप हैं, उसके दूसरे workspace पर ले जाता है, और हर monitor की top bar उसके अपने workspaces और वह जो दिखा रहा है, उसे दिखाती है। `Super + Tab` जिस monitor पर आप हैं, उसके workspaces में चक्र लगाता है। `Super + Shift + Ctrl + Arrows` जिस window पर आप हैं, उसे उस दिशा वाले monitor पर, उसके दिखाए जा रहे workspace पर ले जाता है, और `Super + Shift + Alt + Arrows` जिस workspace पर आप हैं, उसे उस दिशा वाले monitor पर ले जाता है, जहाँ वह खाली होने पर वही number लेता है। कोई monitor जब आप उसे unplug करते हैं तो उसके workspaces बने रहते हैं: वे किसी दूसरी screen के workspaces से जुड़ जाते हैं, उसके पास पहले से मौजूद workspaces के बाद की संख्याओं के साथ, और monitor के वापस आने पर अपनी पुरानी संख्याओं के नीचे वापस चले जाते हैं।

यदि आप `Super` दबाकर रखते हैं और माउस से किसी window पर click करते हैं, तो आप उसकी जगह को फिर से व्यवस्थित कर पाएँगे। यदि आप `Super` दबाकर रखते हैं और माउस का दायाँ button उपयोग करते हैं, तो आप window का आकार स्वतंत्र रूप से बदल सकते हैं।

आप किसी window को `Super + W` या `Super + Q` से बंद करते हैं (और सभी windows को `Ctrl + Alt + Delete` से बंद करते हैं)।

आप `Super + F` से full screen पर भी जा सकते हैं या `Super + Alt + F` से केवल full-width (top bar बनाए रखते हुए) पर भी, या `Super + Ctrl + F` से किसी window के भीतर full-screen पर भी (YouTube के लिए बढ़िया!)।

### Dwindle बनाम scrolling layout

Omarchy के default layout को dwindle कहा जाता है। यह आपके द्वारा एक ही workspace पर खोली गई सभी windows को हर समय दिखाई देता रखता है, भले ही उसे उन्हें छोटा करना पड़े।

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

लेकिन आप किसी workspace को scrolling layout में बदलने का चुनाव भी कर सकते हैं जहाँ windows display के दिखाई देने वाले किनारे से परे साथ-साथ कतार में लगी होती हैं। आप `Super + L` के ज़रिए किसी एक workspace को इस layout में बदलते हैं।

`Super + L` को फिर से दबाने से workspace floating हो जाता है, जहाँ windows स्वतंत्र रूप से एक-दूसरे पर चढ़ती हैं और आप उन्हें खुद रखते हैं, और तीसरी बार दबाने से वह dwindle पर लौट आता है। `Super + Alt + L` उनमें दूसरी तरफ़ से जाता है। कोई window जो वैसे भी float करती है — जिसे आपने `Super + T` से बाहर निकाला हो, या कोई app जो हमेशा floating खुलता हो — workspace के tiling पर वापस जाने पर भी floating बनी रहती है। top bar जिस workspace पर आप हैं, उसे उसके layout से चिन्हित करती है: dwindle के लिए एक वर्ग, scrolling के लिए एक वृत्त, और floating के लिए एक त्रिभुज। उस चिन्ह पर click करने से भी layout का चक्र चलता है।

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

चुनाव हर workspace के लिए अलग है, और वह बना रहता है। इसलिए आप workspace 1 को browsing के लिए dwindle पर और workspace 2 को code के लिए scrolling पर रख सकते हैं, और restart के बाद वे उसी तरह वापस आएँगे।

यदि आप scrolling layout को default के रूप में उपयोग करना चाहते हैं, तो आप उसे `~/.config/hypr/looknfeel.lua` में set कर सकते हैं:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### फ़्लोटिंग workspaces

कोई floating workspace एक पारंपरिक desktop की तरह काम करता है: windows एक-दूसरे पर चढ़ती हैं, और आप उन्हें खुद हटाते और उनका आकार तय करते हैं। हर window को आपकी theme के रंगों में एक titlebar मिलता है, जिसमें minimize, maximize और close करने के buttons होते हैं। `Super + M` focused window को भी minimize करता है। कोई minimized window dock में प्रतीक्षा करती है; उसे वापस लाने के लिए उसके app पर click करें। किसी window को आगे लाने के लिए उस पर click करें। किसी भी किनारे या कोने से उसका आकार बदलें। top bar को दिखाई देता रखते हुए window को maximize करने के लिए titlebar पर double-click करें, और उसका पुराना आकार वापस पाने के लिए फिर से ऐसा करें। Chrome और अन्य Chromium-आधारित browsers, Disks और Document Viewer titlebar को छोड़ देते हैं और इसके बजाय अपना header उपयोग करते हैं; `Super + Alt + F` उन्हें maximize करता है, और `Super + M` उन्हें minimize करता है।

कोई floating workspace एक dock भी दिखाता है, जिसमें आपके pinned apps, चल रही हर चीज़, और apps button के पीछे हर app की एक grid होती है, जिसे `Super + Alt + Space` और Omarchy menu में _Apps_ भी खोलते हैं। किसी app को uninstall करने के लिए grid पर उस पर right-click करें, या `Delete` दबाएँ। किसी app को खोलने के लिए, या उसकी window को आगे लाने के लिए उस पर click करें; उसकी windows में चक्र लगाने के लिए फिर से click करें। Middle-click एक नई window खोलता है। किसी icon को dock के साथ-साथ drag करके उसे हटाएँ; किसी चल रहे app को बाकियों के बीच drag करने से वह वहाँ बना रहता है। किसी app को dock में बनाए रखने, उसे बाहर निकालने, या उसे quit करने के लिए right-click करें। dock किसी fullscreen window के रास्ते से हट जाता है। dock को किसी दूसरे किनारे पर ले जाने के लिए या pointer के उसके किनारे तक पहुँचने तक उसे छिपाए रखने के लिए apps button पर right-click करें। यह स्थिति _Appearance > Dock > Dock Position_ के अंतर्गत भी है, और `omarchy dock position left` और `omarchy dock autohide on` terminal से दोनों को set करते हैं। जिन apps को आप dock में बनाए रखते हैं, वे तब तक फीके रहते हैं जब तक वे चल नहीं रहे होते।

नए workspaces, और वे जिन्हें आपने `Super + L` से उनका अपना layout नहीं दिया है, default layout का उपयोग करते हैं। default बदलने से बिना windows वाला हर workspace उस पर reset हो जाता है, जबकि जिस पर windows हैं वह अपना मौजूदा layout बनाए रखता है। dock में minimized कोई window अब भी उस workspace पर एक window के रूप में गिनी जाती है जिसे उसने छोड़ा था। इसे _Appearance > Workspace Layout_ के अंतर्गत चुनें: Tiling, Scrolling, या Floating। `omarchy-hyprland-workspace-layout-default scrolling` इसे terminal से set करता है।

### Windows को group करना

`Super + G` का उपयोग करके windows को group किया जा सकता है। एक बार जब आप किसी group में हों, तो उसके सक्रिय रहते हुए आप जो भी window शुरू करेंगे वह group की होगी। आप इन grouped windows के बीच `Super + Ctrl + Arrow Left/Right` का उपयोग करके जा सकते हैं या क्रम में grouped windows पर सीधे जाने के लिए `Super + Alt + 1/2/3/4` का उपयोग कर सकते हैं।

आप `Super + Alt + G` से किसी window को grouping से बाहर ले जा सकते हैं या फिर से `Super + G` दबाकर पूरे group को तोड़ सकते हैं। अंत में, आप `Super + Alt + Arrows` से group के बाहर की windows को उसमें ले जा सकते हैं।

### Windows को pop करना

आप `Super + O` से किसी window को उसके workspace आवंटन से बाहर pop कर सकते हैं। यह उसे एक floating window के रूप में pin कर देगा जो आप जिस भी workspace पर जाएँगे वहाँ आपके साथ जाएगी। video players और ऐसी ही चीज़ों के लिए बढ़िया।

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad workspace

एक विशेष full-size scratchpad workspace है जो आप वर्तमान में जिस भी workspace पर हैं उस पर चढ़ जाता है। उस पर जो है उसे आप `Super + S` का उपयोग करके access करते हैं, और वहाँ windows को आप `Super + Alt + S` का उपयोग करके रखते हैं।

यह controls या किसी terminal के लिए अच्छी तरह काम करता है जिसके साथ आप वर्तमान workspace को छोड़े बिना जल्दी से interact करना चाहते हैं।

### Quake console

अंत में, एक आधी-ऊँचाई वाला Quake console है जो आप वर्तमान में जिस भी workspace पर हैं उस पर नीचे गिरता है। इसे `Super + Grave` से toggle करें, और वहाँ कोई window `Super + Shift + Grave` का उपयोग करके रखें।

यह आपके default agent के साथ तैयार खुलता है। जब console में एक ही window होती है, तो यह screen पर फैलने के बजाय एक केंद्रित panel के रूप में नीचे आता है। उस पर दूसरा app रखें और यह पूरी चौड़ाई पर वापस चला जाता है, ताकि दोनों को साथ-साथ बैठने की जगह मिले।

किसी window को scratchpad या console दोनों में से किसी से भी हटाने के लिए, उसे `Super + Shift + 1` जैसी किसी चीज़ से सीधे दूसरे workspace पर भेजें।

### इसकी आदत पड़ने में थोड़ा समय लगता है!

इस तरह अपने desktop पर navigate करने की आदत पड़ने में थोड़ा समय लगता है, लेकिन एक बार पड़ जाए, तो पारंपरिक माउस-चालित desktop अनुभव पर वापस जाना मुश्किल होगा!
