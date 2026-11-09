# नेविगेशन

Omarchy में सब कुछ कीबोर्ड के ज़रिए होता है — _सब कुछ!_ जब सिस्टम पहली बार शुरू होता है, तो आप सचमुच सिर्फ़ माउस से कुछ भी नहीं कर सकते। लेकिन आप `Super + Space` दबाकर Omarchy Menu सामने ला सकते हैं और यहाँ से आप लगभग सब कुछ कर सकते हैं।

लेकिन Omarchy menu ज़्यादातर समय सिस्टम चलाने का मुख्य तरीका बनने के लिए है ही नहीं। हम इससे भी तेज़ हो सकते हैं! सभी सबसे महत्वपूर्ण applications सीधे अलग-अलग hotkeys से जुड़े हैं। आप `Super + Return` से terminal शुरू करते हैं और `Super + Shift + Return` से browser। एक के बाद एक करके देखें, और आपको Hyprland की tiling का जादू काम करता दिखेगा:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

फिर आप उन्हें साथ-साथ रखने के बजाय एक के ऊपर एक रखने के लिए `Super + J` दबा सकते हैं:

 ![navigation-stacked](images/navigation-stacked.webp)

`Super + J` फिर से दबाएँ तो वे अपनी साथ-साथ वाली स्थितियों में लौट आएँगे। फिर browser में रहते हुए windows को आपस में बदलने के लिए `Super + Shift + Arrow Right` आज़माएँ।

अब Activity monitor शुरू करने के लिए `Super + Shift + T` आज़माएँ। वह एक floating window के रूप में दिखाई देगा। आप `Super + T` का उपयोग करके उसे tile कर सकते हैं (और उसे फिर से floating बनाने के लिए वही फिर दबाएँ)। अब file manager खोलने के लिए `Super + Shift + F` दबाएँ। आपके सामने एक सुव्यवस्थित चार-तरफ़ा setup होगा:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

आप जिस window को active बनाना चाहते हैं, उस पर `Super + Arrow` से जाते हैं। इससे focus बदल जाएगा और cursor नए application के केंद्र में चला जाएगा। screen के किनारे पर, यह उस तरफ़ वाले monitor पर आगे बढ़ जाता है।

यदि आप `Super + Shift + 2` दबाते हैं, तो आप वर्तमान focused application को दूसरे workspace पर ले जाएँगे। `Super + Shift + 1` उसे वापस ले आता है। (और `Super + Shift + Alt + 2` वर्तमान focused application को दूसरे workspace पर ले जाएगा, लेकिन उस पर switch किए बिना)।

एक से अधिक monitor होने पर, हर monitor के अपने workspaces 1 से 10 तक होते हैं। `Super + 2` उस monitor के दूसरे workspace पर जाता है जिस पर आप हैं, और हर monitor की top bar उसके अपने workspaces और वह workspace दिखाती है जो वह दिखा रहा है। `Super + Tab` उस monitor के workspaces के बीच क्रम से घूमता है जिस पर आप हैं। `Super + Shift + Ctrl + Arrows` जिस window पर आप हैं उसे उस दिशा वाले monitor पर, उसके दिखाए जा रहे workspace पर ले जाता है, और `Super + Shift + Alt + Arrows` जिस workspace पर आप हैं उसे उस दिशा वाले monitor पर ले जाता है, जहाँ यदि वह खाली हो तो वह वही number ले लेता है। monitor को unplug करने पर वह अपने workspaces रखता है: वे दूसरी screen के workspaces से जुड़ जाते हैं, उनके पहले से मौजूद workspaces के बाद number पाते हैं, और monitor के लौटने पर अपने पुराने numbers के तहत वापस चले जाते हैं।

यदि आप `Super` दबाकर रखते हैं और mouse से किसी window पर click करते हैं, तो आप उसकी जगह फिर से व्यवस्थित कर पाएँगे। यदि आप `Super` दबाकर रखते हैं और mouse का right button उपयोग करते हैं, तो आप window का आकार स्वतंत्र रूप से बदल सकते हैं।

आप किसी window को `Super + W` या `Super + Q` से बंद करते हैं (और सभी windows को `Ctrl + Alt + Delete` से बंद करते हैं)।

आप `Super + F` से full screen भी जा सकते हैं या `Super + Alt + F` से सिर्फ़ full-width (top bar बनाए रखते हुए) या `Super + Ctrl + F` से किसी window के भीतर full-screen भी जा सकते हैं (YouTube के लिए बढ़िया!)।

### Dwindle बनाम scrolling layout

Omarchy के default layout को dwindle कहा जाता है। यह एक workspace पर आपके द्वारा खोली गई सभी windows को हर समय दिखाई देता रखता है, भले ही इसके लिए उन्हें छोटा करना पड़े।

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

लेकिन आप किसी workspace को scrolling layout में बदलना भी चुन सकते हैं जहाँ windows display के दिखाई देने वाले किनारे से परे, साथ-साथ पंक्तिबद्ध होती हैं। आप `Super + L` के ज़रिए एक workspace को इस layout में बदलते हैं।

`Super + L` फिर से दबाने से workspace floating हो जाता है, जहाँ windows स्वतंत्र रूप से एक-दूसरे को overlap करती हैं और आप उन्हें खुद रखते हैं, और तीसरी बार दबाने से वह dwindle पर लौट आता है। `Super + Alt + L` उन्हें दूसरी दिशा में क्रम से ले जाता है। कोई window जो वैसे भी float करती है — जिसे आपने `Super + T` से बाहर निकाला हो, या कोई ऐसा app जो हमेशा floating खुलता हो — workspace के tiling पर लौटने पर भी floating ही रहती है। top bar जिस workspace पर आप हैं उसे उसके layout के साथ चिह्नित करती है: dwindle के लिए एक वर्ग, scrolling के लिए एक वृत्त, और floating के लिए एक त्रिभुज। उस चिह्न पर click करने से भी layout क्रम से बदलता है।

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

चुनाव हर workspace के लिए अलग होता है, और वह बना रहता है। इसलिए आप workspace 1 को browsing के लिए dwindle पर और workspace 2 को code के लिए scrolling पर रख सकते हैं, और restart के बाद वे उसी तरह वापस आएँगे।

यदि आप scrolling layout को default के रूप में उपयोग करना चाहते हैं, तो आप उसे `~/.config/hypr/looknfeel.lua` में set कर सकते हैं:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Floating workspaces

एक floating workspace एक पारंपरिक desktop की तरह काम करता है: windows overlap होती हैं, और आप उन्हें खुद move करते हैं और उनका आकार तय करते हैं। हर window को आपके theme के रंगों में एक titlebar मिलती है, जिसमें minimize, maximize और close करने के buttons होते हैं। `Super + M` focused window को भी minimize करता है। एक minimized window dock में प्रतीक्षा करती है; उसे वापस लाने के लिए उसके app पर click करें। किसी window को आगे लाने के लिए उस पर click करें। उसे किसी भी किनारे या कोने से resize करें। top bar को दिखाई देते रखते हुए window को maximize करने के लिए titlebar पर double-click करें, और उसका पुराना आकार वापस पाने के लिए फिर से ऐसा करें।

एक floating workspace एक dock भी दिखाता है, जिसमें आपके pinned apps, चल रही हर चीज़, और apps button के पीछे हर app की एक grid होती है, जिसे `Super + Alt + Space` और Omarchy menu में _Apps_ भी खोलते हैं। grid पर किसी app को uninstall करने के लिए उस पर right-click करें, या `Delete` दबाएँ। किसी app को खोलने के लिए, या उसकी window को आगे लाने के लिए उस पर click करें; उसकी windows के बीच क्रम से जाने के लिए फिर से click करें। Middle-click एक नई window खोलता है। किसी icon को dock के साथ drag करके उसे move करें; किसी running app को दूसरों के बीच drag करने से वह वहाँ बना रहता है। किसी app को dock में रखने, उसे वहाँ से हटाने, या उसे quit करने के लिए right-click करें। dock एक fullscreen window के रास्ते से हट जाता है। dock को दूसरे किनारे पर ले जाने के लिए या pointer के उसके किनारे तक पहुँचने तक उसे छिपाए रखने के लिए apps button पर right-click करें। यह स्थिति _Appearance > Dock > Dock Position_ के तहत भी है, और `omarchy dock position left` और `omarchy dock autohide on` दोनों को terminal से set करते हैं। जिन apps को आप dock में रखते हैं वे तब faded रहते हैं जब वे चल नहीं रहे होते।

नए workspaces, और वे सभी जिन्हें आपने `Super + L` से उनका अपना layout नहीं दिया है, default layout का उपयोग करते हैं। default बदलने से windows के बिना हर workspace उस पर reset हो जाता है, जबकि जिस पर windows हैं वह अपना मौजूदा layout बनाए रखता है। dock में minimized की गई window अभी भी उस workspace पर एक window के रूप में गिनी जाती है जिसे उसने छोड़ा था। इसे _Appearance > Workspace Layout_ के तहत चुनें: Tiling, Scrolling, या Floating। `omarchy-hyprland-workspace-layout-default scrolling` इसे terminal से set करता है।

### Windows को group करना

`Super + G` का उपयोग करके windows को group किया जा सकता है। जब आप किसी group में होते हैं, तो उसके active रहते हुए आप जो भी window शुरू करेंगे वह group की होगी। आप `Super + Ctrl + Arrow Left/Right` का उपयोग करके इन grouped windows के बीच जा सकते हैं या क्रम में grouped windows पर सीधे जाने के लिए `Super + Alt + 1/2/3/4` का उपयोग कर सकते हैं।

आप `Super + Alt + G` से किसी window को grouping से बाहर ले जा सकते हैं या `Super + G` फिर से दबाकर पूरे group को खत्म कर सकते हैं। अंत में, आप `Super + Alt + Arrows` से group के बाहर की windows को उसमें ले जा सकते हैं।

### Windows को pop करना

आप `Super + O` से किसी window को उसके workspace आवंटन से बाहर pop कर सकते हैं। इससे वह एक floating window के रूप में pin हो जाएगी जो आप जिस भी workspace पर जाएँगे वहाँ आपका पीछा करेगी। video players और ऐसी ही चीज़ों के लिए बढ़िया।

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad workspace

एक विशेष full-size scratchpad workspace है जो आप वर्तमान में जिस भी workspace पर हैं उसके ऊपर overlay होता है। आप `Super + S` का उपयोग करके उस पर मौजूद चीज़ों तक पहुँचते हैं, और `Super + Alt + S` का उपयोग करके वहाँ windows रखते हैं।

यह controls या ऐसे terminal के लिए अच्छी तरह काम करता है जिसके साथ आप वर्तमान workspace छोड़े बिना जल्दी से interact करना चाहते हैं।

### Quake console

अंत में, एक half-height Quake console है जो आप वर्तमान में जिस भी workspace पर हैं उसके ऊपर नीचे आता है। इसे `Super + Grave` से toggle करें, और `Super + Shift + Grave` का उपयोग करके वहाँ एक window रखें।

यह आपके default agent के साथ तैयार खुलता है। जब console में एक ही window होती है, तो यह screen पर फैलने के बजाय एक centered panel के रूप में नीचे आता है। उस पर दूसरा app रखें और यह full width पर वापस चला जाता है, ताकि दोनों को साथ-साथ बैठने की जगह मिले।

किसी window को scratchpad या console दोनों में से किसी से भी हटाने के लिए, उसे `Super + Shift + 1` जैसी किसी चीज़ से सीधे दूसरे workspace पर भेजें।

### इसे अपनाने में थोड़ा समय लगता है!

इस तरह अपने desktop पर navigate करने की आदत डालने में थोड़ा समय लगता है, लेकिन एक बार ऐसा हो जाए, तो पारंपरिक mouse-driven desktop अनुभव पर वापस जाना मुश्किल होगा!
