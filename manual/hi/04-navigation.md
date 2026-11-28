# नेविगेशन

Omarchy में सब कुछ कीबोर्ड के ज़रिए होता है — _सब कुछ!_ जब सिस्टम पहली बार शुरू होता है, तो आप सचमुच अकेले माउस से कुछ भी नहीं कर सकते। लेकिन आप `Super + Space` दबाकर Omarchy Menu सामने ला सकते हैं और यहाँ से आप लगभग सब कुछ कर सकते हैं।

लेकिन Omarchy menu ज़्यादातर समय सिस्टम चलाने का मुख्य तरीका बनने के लिए भी नहीं बना है। हम इससे भी तेज़ हो सकते हैं! सभी सबसे महत्वपूर्ण applications सीधे अलग-अलग hotkeys से बंधे हैं। आप `Super + Return` से terminal शुरू करते हैं और `Super + Shift + Return` से browser। एक के बाद एक करके देखिए, और आपको Hyprland की tiling का जादू काम करता दिखेगा:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

फिर आप उन्हें एक-दूसरे के बगल में रखने के बजाय एक के ऊपर एक रखने के लिए `Super + J` दबा सकते हैं:

 ![navigation-stacked](images/navigation-stacked.webp)

उन्हें वापस बगल-बगल की स्थिति में लाने के लिए फिर से `Super + J` दबाइए। फिर browser में रहते हुए windows को आपस में बदलने के लिए `Super + Shift + Arrow Right` दबाकर देखिए।

अब Activity monitor शुरू करने के लिए `Super + Shift + T` दबाकर देखिए। वह एक floating window के रूप में दिखाई देगा, जिसमें उसे खींचने के लिए एक titlebar और उसे minimize, maximize और close करने के buttons होंगे। हर floating window को एक ऐसा titlebar मिलता है, वह जहाँ भी हो। आप `Super + T` का उपयोग करके उसे tile कर सकते हैं (और उसे फिर से floating बनाने के लिए वही फिर दबाइए)। अब file manager खोलने के लिए `Super + Shift + F` दबाइए। आपके पास एक साफ़-सुथरा चार-तरफ़ा setup होगा:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

आप `Super + Arrow` से उस window पर जाते हैं जिसे आप active बनाना चाहते हैं। इससे focus बदल जाएगा और cursor नए application के केंद्र में चला जाएगा। screen के किनारे पर, यह उसी तरफ़ वाले monitor पर जारी रहता है।

यदि आप `Super + Shift + 2` दबाते हैं, तो आप वर्तमान focused application को दूसरे workspace पर ले जाएँगे। `Super + Shift + 1` उसे वापस ले आता है। (और `Super + Shift + Alt + 2` वर्तमान focused application को दूसरे workspace पर ले जाएगा, बिना उस पर switch किए)।

एक से अधिक monitor होने पर, हर monitor के अपने workspace 1 से 10 तक होते हैं। `Super + 2` आपको जिस monitor पर हैं उसके दूसरे workspace पर ले जाता है, और हर monitor की top bar उसके अपने workspaces और वह workspace दिखाती है जो वह दिखा रहा है। `Super + Tab` जिस monitor पर आप हैं उसके workspaces के बीच cycle करता है। `Super + Shift + Ctrl + Arrows` जिस window पर आप हैं उसे उस दिशा वाले monitor पर, उसके दिखाए जा रहे workspace पर ले जाता है, और `Super + Shift + Alt + Arrows` जिस workspace पर आप हैं उसे उस दिशा वाले monitor पर ले जाता है, जहाँ यदि वह खाली हो तो वह वही number ले लेता है। जब आप किसी monitor को unplug करते हैं तो वह अपने workspaces बनाए रखता है: वे किसी दूसरी screen के workspaces से जुड़ जाते हैं, उसके पहले से मौजूद workspaces के बाद की संख्या के साथ, और जब monitor वापस आता है तो वे अपने पुराने numbers के तहत वापस चले जाते हैं।

यदि आप `Super` दबाकर रखते हैं और mouse से किसी window पर click करते हैं, तो आप उसे जहाँ वह बैठा है वहाँ पुनर्व्यवस्थित कर पाएँगे। यदि आप `Super` दबाकर रखते हैं और mouse के right button का उपयोग करते हैं, तो आप window का आकार स्वतंत्र रूप से बदल सकते हैं।

आप किसी window को `Super + W` या `Super + Q` से बंद करते हैं (और सभी windows को `Ctrl + Alt + Delete` से बंद करते हैं)।

आप `Super + F` से full screen पर भी जा सकते हैं या `Super + Alt + F` से केवल full-width (top bar बनाए रखते हुए) या `Super + Ctrl + F` से किसी window के भीतर full-screen पर जा सकते हैं (YouTube के लिए अच्छा है!)।

### Dwindle बनाम scrolling layout

Omarchy के default layout को dwindle कहा जाता है। यह आपके द्वारा एक ही workspace पर खोले गए सभी windows को हर समय दृश्यमान रखता है, भले ही उसे उन्हें छोटा करना पड़े।

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

लेकिन आप किसी workspace को scrolling layout में बदलना भी चुन सकते हैं जहाँ windows display के दृश्यमान किनारे से परे, बगल-बगल में पंक्तिबद्ध होते हैं। आप `Super + L` के ज़रिए किसी एक workspace को इस layout में बदलते हैं।

`Super + L` फिर दबाने से workspace floating हो जाता है, जहाँ windows स्वतंत्र रूप से overlap होते हैं और आप उन्हें खुद रखते हैं, और तीसरी बार दबाने से वह dwindle पर वापस आ जाता है। `Super + Alt + L` इनमें से उल्टी दिशा में जाता है। कोई window जो वैसे भी float करता है — जिसे आपने `Super + T` से बाहर निकाला है, या कोई app जो हमेशा floating खुलता है — workspace के tiling पर वापस जाने पर भी floating बना रहता है। top bar जिस workspace पर आप हैं उसे उसके layout के साथ चिह्नित करती है: dwindle के लिए एक वर्ग, scrolling के लिए एक वृत्त, और floating के लिए एक त्रिभुज। उस चिह्न पर click करने से भी layout cycle होता है, और उन laptops पर जिनमें display key है, वह भी यही करता है।

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

यह चुनाव प्रति workspace है, और यह बना रहता है। इसलिए आप browsing के लिए workspace 1 को dwindle पर और code के लिए workspace 2 को scrolling पर रख सकते हैं, और restart के बाद वे उसी तरह वापस आएँगे।

यदि आप scrolling layout को default के रूप में उपयोग करना चाहते हैं, तो आप उसे `~/.config/hypr/looknfeel.lua` में set कर सकते हैं:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Floating workspaces

एक floating workspace पारंपरिक desktop की तरह काम करता है: windows overlap होते हैं, और आप उन्हें खुद ले जाते हैं और उनका आकार खुद तय करते हैं। हर window को आपके theme के रंगों में एक titlebar मिलता है, जिसमें minimize, maximize और close करने के buttons होते हैं। `Super + M` focused window को भी minimize कर देता है। एक minimized window dock में प्रतीक्षा करता है; उसे वापस लाने के लिए उसके app पर click कीजिए। किसी window को आगे लाने के लिए उस पर click कीजिए। उसे किसी भी किनारे या कोने से resize कीजिए। top bar को दृश्य में रखते हुए window को maximize करने के लिए titlebar पर double-click कीजिए, और उसका पुराना आकार वापस पाने के लिए फिर से double-click कीजिए। Chrome और अन्य Chromium-आधारित browsers, Disks और Document Viewer titlebar को छोड़ देते हैं और इसके बजाय अपने स्वयं के header का उपयोग करते हैं; `Super + Alt + F` उन्हें maximize करता है, और `Super + M` उन्हें minimize करता है।

हर workspace में एक dock होता है, जिसमें आपके pinned apps, जो कुछ भी चल रहा है वह सब, और apps button के पीछे हर app की एक grid होती है, जिसे `Super + Alt + Space` और Omarchy menu में _Apps_ भी खोलते हैं। किसी app को uninstall करने के लिए grid पर उस पर right-click कीजिए, या `Delete` दबाइए। किसी app को खोलने के लिए, या उसकी window को आगे लाने के लिए उस पर click कीजिए; उसकी windows के बीच cycle करने के लिए फिर से click कीजिए। Files केवल उसी workspace से एक window वापस लाता है जिस पर आप हैं और अन्यथा एक नई window खोलता है, और Terminal और Agent हमेशा एक और शुरू करते हैं, हालाँकि minimized window पहले वापस आता है। Middle-click एक नई window खोलता है। किसी icon को dock के साथ खींचकर उसे ले जाइए; किसी चल रहे app को अन्य apps के बीच खींचने से वह वहाँ बना रहता है। किसी app को dock में रखने, उसे बाहर निकालने, या उसे quit करने के लिए right-click कीजिए। जब workspace खाली होता है तो dock बाहर रहता है, और एक बार workspace में कोई window आ जाने पर यह तब तक छिपा रहता है जब तक pointer उसके किनारे तक न पहुँचे। एक fullscreen window उसे पूरी तरह छिपा देता है। dock को वहाँ ले जाने के लिए apps button को screen के किसी अन्य किनारे की ओर खींचिए। किसी किनारे को चुनने के लिए उस पर right-click करके _Position_, default layout को उसी तरह set करने के लिए _Layout_ जैसा _Appearance > Workspace Layout_ करता है, और dock को हमेशा चालू रखने, पहले app से उसे छिपाने, या उसे हमेशा छिपा रखने के लिए _Visibility_ चुनिए। `omarchy dock visibility always` terminal से उसे set करता है। position _Appearance > Dock > Dock Position_ के तहत भी है, और `omarchy dock position left` terminal से उसे set करता है। आप dock में जो apps रखते हैं वे तब फीके रहते हैं जब वे चल नहीं रहे होते। dock को floating workspaces तक सीमित रखने के लिए, _Appearance > Dock > Dock Only on Floating_ या `omarchy dock tiling off` का उपयोग कीजिए।

नए workspaces, और कोई भी workspace जिसे आपने `Super + L` से उसका अपना layout नहीं दिया है, default layout का उपयोग करते हैं। default बदलने से बिना windows वाले हर workspace उसी पर reset हो जाते हैं, जबकि जिस पर windows हैं वह जो layout उसके पास है उसे बनाए रखता है। dock में minimized की गई window अभी भी उस workspace पर एक window के रूप में गिनी जाती है जिसे उसने छोड़ा था। उसे _Appearance > Workspace Layout_ के तहत चुनिए: Tiling, Scrolling, या Floating। `omarchy hyprland workspace layout default scrolling` terminal से उसे set करता है।

### Windows को समूहबद्ध करना

Windows को `Super + G` का उपयोग करके समूहबद्ध किया जा सकता है। एक बार जब आप किसी group में होते हैं, तो जब वह active होता है तब आप जो भी window शुरू करेंगे वह group से संबंधित होगा। आप इन समूहबद्ध windows के बीच `Super + Ctrl + Arrow Left/Right` का उपयोग करके या क्रम में सीधे समूहबद्ध windows पर जाने के लिए `Super + Alt + 1/2/3/4` का उपयोग करके जा सकते हैं।

आप किसी window को `Super + Alt + G` से grouping से बाहर ले जा सकते हैं या फिर से `Super + G` दबाकर पूरे group को समाप्त कर सकते हैं। अंत में, आप group के बाहर की windows को `Super + Alt + Arrows` से उसके अंदर ले जा सकते हैं।

### Windows को बाहर निकालना

आप किसी window को `Super + O` से उसके workspace आवंटन से बाहर निकाल सकते हैं। वह उसे एक floating window के रूप में pin कर देगा जो आप जिस भी workspace पर जाते हैं वहाँ आपका पीछा करता है। video players और ऐसी ही चीज़ों के लिए बढ़िया।

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad workspace

एक विशेष full-size scratchpad workspace है जो आप वर्तमान में जिस भी workspace पर हैं उसके ऊपर overlay होता है। आप उस पर मौजूद चीज़ों तक `Super + S` से पहुँचते हैं, और आप वहाँ windows को `Super + Alt + S` का उपयोग करके रखते हैं।

यह controls या किसी terminal के लिए अच्छी तरह काम करता है जिसके साथ आप वर्तमान workspace को छोड़े बिना जल्दी से interact करना चाहते हैं।

### Quake console

अंत में, एक आधा-ऊँचाई वाला Quake console है जो आप वर्तमान में जिस भी workspace पर हैं उसके ऊपर नीचे आता है। उसे `Super + the key above Tab` (US layouts पर grave) से toggle कीजिए, और वहाँ एक window रखने के लिए `Super + Shift + the key above Tab` का उपयोग कीजिए।

पहली बार जब यह खुलता है, तो यह आपके default agent को शुरू करता है, या यदि आपने अभी तक एक नहीं चुना है तो आपको एक चुनने के लिए कहता है। जब console में एक ही window होता है, तो यह screen पर फैलने के बजाय एक केंद्रित panel के रूप में नीचे आता है। उस पर दूसरा app रखिए और यह full width पर वापस चला जाता है, ताकि दोनों को बगल-बगल बैठने के लिए जगह मिल सके।

किसी window को scratchpad या console दोनों में से किसी से भी हटाने के लिए, उसे `Super + Shift + 1` जैसी किसी चीज़ से सीधे किसी अन्य workspace पर भेज दीजिए।

### इसकी आदत पड़ने में कुछ समय लगता है!

अपने desktop को इस तरह navigate करने की आदत पड़ने में थोड़ा समय लगता है, लेकिन एक बार जब आपको इसकी आदत पड़ जाएगी, तो पारंपरिक mouse-संचालित desktop अनुभव पर वापस जाना कठिन होगा!
