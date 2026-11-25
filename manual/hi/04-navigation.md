# नेविगेशन

Omarchy में सब कुछ कीबोर्ड के ज़रिए होता है — _सब कुछ!_ जब सिस्टम पहली बार शुरू होता है, तो आप सचमुच सिर्फ़ माउस से कुछ भी नहीं कर सकते। लेकिन आप Omarchy Menu को दिखाने के लिए `Super + Space` दबा सकते हैं और यहाँ से आप लगभग सब कुछ कर सकते हैं।

लेकिन Omarchy menu का मक़सद ज़्यादातर समय सिस्टम को चलाने का मुख्य तरीक़ा होना भी नहीं है। हम इससे भी तेज़ हो सकते हैं! सभी सबसे महत्वपूर्ण applications सीधे अलग-अलग hotkeys से बंधे हैं। आप `Super + Return` से terminal शुरू करते हैं और `Super + Shift + Return` से browser शुरू करते हैं। एक के बाद एक करके देखें, और आपको Hyprland की tiling का जादू काम करता हुआ दिखेगा:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

आप फिर उन्हें एक-दूसरे के बगल में रखने के बजाय एक के ऊपर एक रखने के लिए `Super + J` दबा सकते हैं:

 ![navigation-stacked](images/navigation-stacked.webp)

`Super + J` को फिर से दबाकर उन्हें उनकी बगल-बगल वाली स्थितियों में वापस लाएँ। फिर browser में रहते हुए windows को आपस में बदलने के लिए `Super + Shift + Arrow Right` आज़माएँ।

अब Activity monitor शुरू करने के लिए `Super + Shift + T` आज़माएँ। वह एक floating window के रूप में दिखाई देगा। आप `Super + T` का उपयोग करके उसे tile कर सकते हैं (और उसे फिर से floating बनाने के लिए उसी को फिर से दबाएँ)। अब file manager खोलने के लिए `Super + Shift + F` दबाएँ। आपके पास एक साफ़-सुथरा चार-तरफ़ा setup होगा:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

आप `Super + Arrow` से उस window के बीच नेविगेट करते हैं जिसे आप active रखना चाहते हैं। यह focus बदल देगा और cursor को नए application के केंद्र में ले जाएगा। किसी screen के किनारे पर, यह उसी तरफ़ वाले monitor पर आगे बढ़ जाता है।

यदि आप `Super + Shift + 2` दबाते हैं, तो आप वर्तमान में focused application को दूसरे workspace पर ले जाएँगे। `Super + Shift + 1` उसे वापस ले आता है। (और `Super + Shift + Alt + 2` वर्तमान में focused application को दूसरे workspace पर ले जाएगा, उस पर switch किए बिना)।

एक से अधिक monitor होने पर, हर monitor के अपने 1 से 10 तक के workspaces होते हैं। `Super + 2` आपको उस monitor के दूसरे workspace पर ले जाता है जिस पर आप हैं, और हर monitor की top bar उसके अपने workspaces और वह workspace दिखाती है जो वह दिखा रहा है। `Super + Tab` उस monitor पर workspaces में चक्र लगाता है जिस पर आप हैं। `Super + Shift + Ctrl + Arrows` उस window को जिसमें आप हैं, उस दिशा वाले monitor पर, उसके द्वारा दिखाए जा रहे workspace पर ले जाता है, और `Super + Shift + Alt + Arrows` उस workspace को जिसमें आप हैं, उस दिशा वाले monitor पर ले जाता है, जहाँ वह खाली होने पर वही number लेता है। कोई monitor unplug करने पर वह अपने workspaces बनाए रखता है: वे किसी दूसरी screen के workspaces से जुड़ जाते हैं, उन workspaces के बाद number पाते हैं जो उसके पास पहले से हैं, और monitor के वापस आने पर अपने पुराने numbers के तहत वापस चले जाते हैं।

यदि आप `Super` दबाकर रखते हैं और mouse से किसी window पर click करते हैं, तो आप उसे फिर से व्यवस्थित कर पाएँगे कि वह कहाँ बैठे। यदि आप `Super` दबाकर रखते हैं और mouse के right button का उपयोग करते हैं, तो आप window का आकार स्वतंत्र रूप से बदल सकते हैं।

आप `Super + W` या `Super + Q` से कोई window बंद करते हैं (और `Ctrl + Alt + Delete` से सभी windows बंद करते हैं)।

आप `Super + F` से full screen पर भी जा सकते हैं या `Super + Alt + F` से सिर्फ़ full-width (top bar बनाए रखते हुए) भी जा सकते हैं या `Super + Ctrl + F` से किसी window के भीतर full-screen भी जा सकते हैं (YouTube के लिए बढ़िया!)।

### Dwindle बनाम scrolling layout

Omarchy के default layout को dwindle कहा जाता है। यह आपके द्वारा एक ही workspace पर खोली गई सभी windows को हर समय दृश्यमान रखता है, भले ही उसे उन्हें छोटा करना पड़े।

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

लेकिन आप किसी workspace को scrolling layout में बदलना भी चुन सकते हैं जहाँ windows बगल-बगल में कतार में लगी होती हैं, display के दृश्यमान किनारे से परे। आप `Super + L` के ज़रिए एक workspace को इस layout में बदलते हैं।

`Super + L` को फिर से दबाने से workspace floating हो जाता है, जहाँ windows स्वतंत्र रूप से overlap होती हैं और आप उन्हें खुद रखते हैं, और तीसरी बार दबाने से वह dwindle पर वापस आ जाता है। `Super + Alt + L` इनमें विपरीत दिशा से जाता है। कोई window जो वैसे भी float करती है — जिसे आपने `Super + T` से बाहर निकाला है, या कोई app जो हमेशा floating खुलता है — workspace के tiling पर वापस जाने पर floating ही रहती है। top bar आपके workspace को उसके layout के साथ चिह्नित करती है: dwindle के लिए एक वर्ग, scrolling के लिए एक वृत्त, और floating के लिए एक त्रिभुज। उस चिह्न पर click करने से भी layout चक्र में बदलता है, और उन laptops पर display key भी ऐसा ही करती है जिनमें वह होती है।

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

यह चुनाव प्रति workspace होता है, और यह बना रहता है। इसलिए आप workspace 1 को browsing के लिए dwindle पर और workspace 2 को code के लिए scrolling पर रख सकते हैं, और restart के बाद वे उसी तरह वापस आएँगे।

यदि आप scrolling layout को default के रूप में उपयोग करना चाहते हैं, तो आप इसे `~/.config/hypr/looknfeel.lua` में set कर सकते हैं:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### फ़्लोटिंग workspaces

कोई फ़्लोटिंग workspace पारंपरिक desktop की तरह काम करता है: windows overlap होती हैं, और आप उन्हें खुद हिलाते और उनका आकार तय करते हैं। हर window को आपकी theme के रंगों में एक titlebar मिलती है, जिसमें minimize, maximize और close करने के buttons होते हैं। `Super + M` focused window को भी minimize करता है। Minimize की गई window dock में इंतज़ार करती है; उसे वापस लाने के लिए उसके app पर click करें। किसी window को आगे लाने के लिए उस पर click करें। उसे किसी भी किनारे या कोने से resize करें। Top bar को दृश्य में रखते हुए window को maximize करने के लिए titlebar पर double-click करें, और उसका पुराना आकार वापस पाने के लिए फिर से ऐसा करें। Chrome और अन्य Chromium-आधारित browsers, Disks और Document Viewer titlebar को छोड़ देते हैं और इसके बजाय अपने खुद के header का उपयोग करते हैं; `Super + Alt + F` उन्हें maximize करता है, और `Super + M` उन्हें minimize करता है।

एक फ़्लोटिंग workspace एक dock भी दिखाता है, जिसमें आपके pinned apps, चल रही हर चीज़, और apps button के पीछे हर app की एक grid होती है, जिसे `Super + Alt + Space` और Omarchy menu में _Apps_ भी खोलते हैं। Grid पर किसी app पर right-click करें, या उसे uninstall करने के लिए `Delete` दबाएँ। किसी app को खोलने के लिए, या उसकी window को आगे लाने के लिए उस पर click करें; उसकी windows में चक्र लगाने के लिए फिर से click करें। Files केवल उस workspace से कोई window वापस लाता है जिस पर आप हैं और अन्यथा एक नई window खोलता है, और Terminal और Agent हमेशा एक और शुरू करते हैं, हालाँकि minimize की गई window पहले वापस आती है। Middle-click एक नई window खोलता है। किसी icon को dock के साथ खींचकर उसे हिलाएँ; किसी चल रहे app को अन्य apps के बीच खींचने से वह वहीं रहता है। किसी app को dock में रखने, उसे बाहर निकालने, या उसे quit करने के लिए right-click करें। Dock fullscreen window के रास्ते से हट जाता है। Dock को किसी दूसरे किनारे पर ले जाने या pointer के उसके किनारे पर पहुँचने तक उसे छिपाए रखने के लिए apps button पर right-click करें। यह स्थिति _Appearance > Dock > Dock Position_ के तहत भी है, और `omarchy dock position left` और `omarchy dock autohide on` दोनों को terminal से set करते हैं। आप dock में जो apps रखते हैं वे चल न रहे होने पर फीके पड़े रहते हैं।

नए workspaces, और वे सभी जिन्हें आपने `Super + L` के साथ अपना खुद का layout नहीं दिया है, default layout का उपयोग करते हैं। Default बदलने से windows के बिना हर workspace उस पर reset हो जाता है, जबकि जिस पर windows हैं वह अपने पास मौजूद layout बनाए रखता है। Dock में minimize की गई window अभी भी उस workspace पर एक window के रूप में गिनी जाती है जिसे उसने छोड़ा था। उसे _Appearance > Workspace Layout_ के तहत चुनें: Tiling, Scrolling, या Floating। `omarchy hyprland workspace layout default scrolling` उसे terminal से set करता है।

### Windows को समूहबद्ध करना

Windows को `Super + G` का उपयोग करके समूहबद्ध किया जा सकता है। एक बार जब आप किसी group में होते हैं, तो उसके active रहते हुए आप जो भी window शुरू करेंगे वह group की होगी। आप `Super + Ctrl + Arrow Left/Right` का उपयोग करके या क्रम में सीधे समूहबद्ध windows पर जाने के लिए `Super + Alt + 1/2/3/4` का उपयोग करके इन समूहबद्ध windows के बीच जा सकते हैं।

आप `Super + Alt + G` के साथ किसी window को grouping से बाहर ले जा सकते हैं या `Super + G` को फिर से दबाकर पूरे group को तोड़ सकते हैं। अंत में, आप `Super + Alt + Arrows` के साथ group के बाहर की windows को इसमें ले जा सकते हैं।

### Windows को बाहर निकालना

आप `Super + O` के साथ किसी window को उसके workspace आवंटन से बाहर निकाल सकते हैं। यह उसे एक floating window के रूप में pin कर देगा जो आप जिस भी workspace पर जाएँगे वहाँ आपके साथ रहेगी। Video players और इसी तरह की चीज़ों के लिए बढ़िया।

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad workspace

एक विशेष full-size scratchpad workspace है जो आप वर्तमान में जिस भी workspace पर हैं उसे overlay करता है। आप `Super + S` का उपयोग करके उस पर मौजूद चीज़ों तक पहुँचते हैं, और आप `Super + Alt + S` का उपयोग करके वहाँ windows रखते हैं।

यह controls या किसी terminal के लिए अच्छी तरह काम करता है जिसके साथ आप वर्तमान workspace छोड़े बिना जल्दी से interact करना चाहते हैं।

### Quake console

अंत में, एक half-height Quake console है जो आप वर्तमान में जिस भी workspace पर हैं उसके ऊपर नीचे गिरता है। उसे `Super + the key above Tab` (US layouts पर grave) के साथ toggle करें, और `Super + Shift + the key above Tab` का उपयोग करके वहाँ कोई window रखें।

पहली बार खुलने पर, यह आपके default agent को शुरू करता है, या यदि आपने अभी तक कोई नहीं चुना है तो आपको एक चुनने के लिए कहता है। जबकि console में एक ही window होती है, यह screen पर फैलने के बजाय एक centered panel के रूप में नीचे आता है। उस पर दूसरा app रखें और यह full width पर वापस चला जाता है, ताकि दोनों को बगल-बगल में बैठने की जगह मिल सके।

किसी window को scratchpad या console दोनों से बाहर ले जाने के लिए, उसे `Super + Shift + 1` जैसी किसी चीज़ के साथ सीधे दूसरे workspace पर भेजें।

### इसकी आदत पड़ने में कुछ समय लगता है!

अपने desktop को इस तरह navigate करने की आदत पड़ने में थोड़ा समय लगता है, लेकिन एक बार पड़ जाने पर, पारंपरिक mouse-आधारित desktop अनुभव पर वापस जाना मुश्किल होगा!
