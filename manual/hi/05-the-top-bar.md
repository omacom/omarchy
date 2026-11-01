# शीर्ष पट्टी

आपकी स्क्रीन के शीर्ष पर बनी पट्टी Omarchy बार है। यह कोई ऊपर से जोड़ी गई status bar नहीं है, बल्कि Omarchy shell का हिस्सा है, वही एकल, लंबे समय तक चलने वाली Quickshell process जो menu, notifications, OSD popups और lock screen भी बनाती है। इसीलिए यह बाकी हर चीज़ के साथ पूरी तरह मेल खाती है और इसीलिए कोई panel किसी नए app को शुरू करने के बजाय तुरंत खुल जाता है।

यह desktop का वह एकमात्र हिस्सा भी है जो हमेशा स्क्रीन पर रहता है, इसलिए यह जानना फ़ायदेमंद है कि वे सभी छोटे-छोटे glyphs करते क्या हैं।

## डिफ़ॉल्ट रूप से इस पर क्या होता है

बार के तीन हिस्से हैं। बाईं ओर Omarchy logo (menu launcher) और workspace indicators बैठते हैं। बीच में आपको status indicators, घड़ी, Elsewhen (एक विश्व घड़ी), मौसम और Omarchy update badge मिलते हैं। दाईं ओर: system tray, keyboard layout (जब एक से अधिक कॉन्फ़िगर किया गया हो), agents, bluetooth, network, audio, display और power।

इनमें से कुछ तभी दिखाई देते हैं जब उनके पास कहने को कुछ हो। Keyboard layout तभी दिखाई देता है जब आपने एक से अधिक layout कॉन्फ़िगर किया हो। Update badge तभी दिखाई देता है जब कोई Omarchy update प्रतीक्षा कर रहा हो। और agents icon पहली बार तब दिखाई देता है जब Omarchy को मशीन पर AI coding का उपयोग मिलता है (देखें [AI](17-ai.md))।

## इधर-उधर क्लिक करना

लगभग हर widget left, right और middle click पर कुछ करता है, और कई scrolling पर भी प्रतिक्रिया देते हैं। यही वह हिस्सा है जो लोगों से छूट जाता है — right और middle buttons में बहुत-सी अच्छी चीज़ें छिपी होती हैं।

| Widget | Left | Right | Middle / scroll |
| --- | --- | --- | --- |
| Menu | Omarchy menu | नया terminal | — |
| Workspaces | इस monitor पर उस workspace पर focus करें | — | Scroll: अगला/पिछला workspace |
| Clock | Calendar popup | Label format बदलें | Middle: timezone picker |
| Weather | Forecast popup | Notification के रूप में पूरा मौसम | Middle: refresh |
| Audio | Audio panel | Mute | Middle: panel · scroll: volume |
| Microphone | Mic को mute करें | — | Middle: audio panel · scroll: input volume |
| Network | Network panel | — | — |
| Bluetooth | Bluetooth panel | Radio चालू/बंद करें | — |
| Display | Display panel | — | Scroll: brightness |
| Power | Power panel | Battery percentage चालू/बंद करें | — |
| Media | Play/pause | Cover-art popup | Middle: अगला · scroll: पिछला/अगला |
| Agents | Agents panel | अपना agent लॉन्च करें | Middle: अगली subscription |
| Tray | Drawer दिखाने के लिए hover करें | प्रबंधित करने के लिए chevron पर right click करें | — |
| Omarchy update | Update चलाएँ | — | — |

उस तालिका में मौजूद हर चीज़ शुरुआत से आपके बार पर नहीं होती। Media widget (MPRIS now-playing, scrolling track और artist के साथ) और microphone widget दोनों अंतर्निहित हैं लेकिन डिफ़ॉल्ट रूप से बंद हैं — अगर आप उन्हें चाहते हैं तो उन्हें जोड़ें, जैसा कि नीचे बताया गया है।

## Panels

किसी बार icon पर क्लिक करने से एक panel खुलता है, जो tooltip के बजाय sliders, lists और keyboard navigation वाला एक proper popup होता है। हर एक की एक hotkey भी होती है, ताकि आपको कभी 16-pixel glyph पर निशाना न लगाना पड़े:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + 1-9` | दाएँ हिस्से में nth panel चालू/बंद करें |

Panels सिर्फ़ जानकारी दिखाने के लिए नहीं हैं। वहीं आप असल में वह काम करते हैं:

- **Audio** में master volume slider, output-device picker और per-app mixer है, ताकि आप बाकी हर चीज़ को छुए बिना उस एक browser tab की आवाज़ कम कर सकें।
- **Network** Wi-Fi के लिए scan करता है, signal strength दिखाता है, connect करता है और आपको DNS provider चुनने देता है।
- **Bluetooth** आपके devices को connect/disconnect और battery levels के साथ सूचीबद्ध करता है।
- **Power** battery stats दिखाता है, power profiles बदलता है (यह battery और AC के लिए अलग-अलग पसंद याद रखता है), और कुछ system info छापता है।
- **Display** में brightness slider, text size, monitor scaling presets हैं, और — जब आपके पास एक से अधिक स्क्रीन हो — per-monitor controls हैं। गहरी कहानी के लिए देखें [मॉनिटर](33-monitors.md)।
- **Clock** ISO week numbers और month stepping के साथ एक month grid खोलता है।
- **World clock** हर शहर के लिए एक पंक्ति रखता है, उसके मौसम और उसके दिन की प्रगति के साथ। Search कस्बों के साथ-साथ time zones को भी ढूँढता है, इसलिए Fort Lauderdale, Fort Lauderdale ही है, New York नहीं। अगर शीर्ष पर बनी पंक्ति गलत शहर का नाम बताती है, तो उस पर क्लिक करें और बताएँ कि आप कहाँ हैं; किसी दूसरे time zone की जगह चुनें और system clock भी वहाँ चला जाता है, जो यात्रा के समय काम आता है। किसी शहर पर hover करें और person button पर क्लिक करके बताएँ कि वहाँ कौन रहता है — सादे नाम, या उनके चेहरे साथ लाने के लिए `@` GitHub handles।

हर panel mouse के साथ-साथ keyboard भी लेता है: arrows चलते हैं, Return सक्रिय करता है, Tab पड़ोसी panel पर जाता है, और Escape बंद करता है।

`Super + Ctrl + 1-9` दाएँ हिस्से में panels को बाएँ से दाएँ गिनता है, tray को छोड़कर क्योंकि उसका अपना कोई panel नहीं है। इसलिए संख्या उसी icon से मेल खाती है जिसकी ओर आप इशारा करते।

### Tailscale और Dropbox

दो और widgets बार पर तभी दिखाई देते हैं जब आप **Install → Service** से मेल खाने वाली service install करते हैं, और दोनों के बारे में जानना ज़रूरी है क्योंकि वे सिर्फ़ status बताने से ज़्यादा करते हैं।

**Tailscale** panel tailnet को connect और disconnect करता है, accounts के बीच बदलता है, और exit node चुनता है (आपकी अपनी machines और Mullvad regions दोनों उस सूची में दिखाई देते हैं)। यह आपकी machines को भी browse करता है — और किसी एक को चुने होने पर, `s` Taildrop के ज़रिए उसे files भेजता है, जो किसी file को अपने phone या दूसरे laptop पर ले जाने का सबसे तेज़ तरीका है। `c` मशीन का IP copy करता है, `n` उसका नाम, और `d` उसका पूरा DNS नाम। हर machine row पर एक send button भी है, अगर आप क्लिक करना पसंद करें। Terminal से वही काम `omarchy tailscale send <machine> [file...]` है।

**Dropbox** panel login संभालता है, दिखाता है कि आपने कितना storage इस्तेमाल किया है, और हाल में sync की गई files सूचीबद्ध करता है।

किसी भी service को हटाने से उसका widget बार से वापस हट जाता है।

## Indicators

बीच में बना छोटा समूह indicators widget है। ये आपके द्वारा चालू किए गए modes के लिए status glyphs हैं: do not disturb, night light, कतार में लगा [रिमाइंडर](09-reminders.md), सक्रिय screen recording, stay awake, और [डिक्टेशन](11-text-extraction-dictation.md)। Mode सक्रिय होने पर ये जल उठते हैं और अन्यथा रास्ते से हटे रहते हैं — निष्क्रिय ones को झाँककर देखने के लिए बार पर कहीं भी hover करें। किसी indicator पर क्लिक करने से वह mode चालू/बंद हो जाता है। एक और सिर्फ़ status के लिए है: जब कोई gliff के ज़रिए इस मशीन से जुड़ा होता है, तो remote session लाल रंग में जल उठता है।

अगर आप चाहते हैं कि वे हमेशा दिखाई दें, तो widget पर `alwaysShow` को `true` पर set करें। और अगर आपको उनमें से सिर्फ़ कुछ की परवाह है, तो `items` में वे सूचीबद्ध करें जिन्हें आप चाहते हैं: `["Dnd", "Reminder", "NightLight"]`। आपके पास एक से अधिक indicators widgets हो सकते हैं, ताकि अलग-अलग हिस्से अलग-अलग subsets दिखा सकें।

## बार को पुनर्व्यवस्थित करना

बार खुद को कॉन्फ़िगर करता है। चीज़ों को इधर-उधर करने के लिए आपको कोई config file खोलनी नहीं पड़ती।

बीच के आसपास बार के किसी खाली हिस्से को पकड़ें और उसे किसी दूसरी स्क्रीन edge की ओर खींचें, और बार वहाँ चला जाता है — left, right, top, या bottom सभी काम करते हैं, और हर widget खुद को ढाल लेता है (vertical bars compact icon-only रूपों पर वापस आ जाते हैं)। Click-and-hold भी वही drag शुरू करता है। उसी खाली जगह पर double-left-click करके बार background को clear से glassy से opaque तक बदलें। और किसी भी widget को खींचकर उसे पुनः क्रम में लगाएँ या दूसरे हिस्से में फेंक दें; बाकी widgets अलग-अलग खिसककर वहाँ जगह बनाते हैं जहाँ वह उतरेगा।

बार का मध्य एक box है: उसमें जो कुछ भी है वह एक समूह के रूप में केंद्रित रहता है, और उसके दोनों ओर के widgets उसके किनारों से लटके रहते हैं। जब आप किसी widget को खींचते हैं तो box एक outline के रूप में दिखाई देता है, या खाली होने पर बार के आर-पार एक रेखा के रूप में, और आप उसमें या उसके बगल में छोड़ सकते हैं। जब कोई drop box में पड़ने वाला होता है, तो box उस widget को अपने अंदर लेने के लिए बढ़ जाता है।

जिस widget को आप आसपास चाहते हैं लेकिन हमेशा सामने नहीं, वह tray के drawer में जा सकता है: उसे tray पर खींचें, और drawer उसे लेने के लिए खुल जाता है। वह वहाँ app icons के बाद बैठता है, जब भी drawer दिखाई देता है तब दिखाई देता है, और जब उसका panel खुला हो तो अपने drawer को खुला रखता है। उसे वापस बार पर खींचकर बाहर निकालें और वापस रख दें।

अगर आप menu से चुनना पसंद करते हैं, तो **Appearance → Menu Bar** में position है, और **Bar Background** चुनता है कि बार कैसे बनाया जाए: **Opaque Bar**, **Glassy Bar** (पारदर्शी, उसके पीछे जो है उसे धुंधला किए हुए), या **Clear Bar**।

उन्हीं चीज़ों के commands भी हैं, जो [dotfiles](31-dotfiles.md) setup के लिए आपकी पसंद होंगे:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

किसी widget को पूरी तरह जोड़ने या हटाने के लिए, plugin commands का उपयोग करें। `omarchy plugin list` shell को ज्ञात हर widget को उसकी id के साथ छापता है, और फिर:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## बार को छिपाना

`Super + Shift + Space` shell को मारे बिना बार को बंद और वापस चालू करता है — panels और hotkeys काम करते रहते हैं, आपको बस pixels वापस मिल जाते हैं। यह menu में **Appearance → Menu Bar → Hide Bar** के अंतर्गत भी है।

## Config file

यह सब `~/.config/omarchy/shell.json` में, `bar` key के अंतर्गत संग्रहीत है। यहाँ एक छोटा किया गया संस्करण है:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

हर widget पाँच layout arrays में से किसी एक में एक entry है, और उसकी settings उसी entry पर inline बैठती हैं — कोई अलग settings file नहीं है और कोई `config` sub-object नहीं है। Clock का `format`, `formatAlt` (जिस पर right-click बदलता है), और `verticalFormat` सभी ठीक वहीं `{ "id": "omarchy.clock" }` पर रहते हैं।

`center` बार के बीच में बना box है: उसमें मौजूद हर चीज़ स्क्रीन पर एक समूह के रूप में केंद्रित होती है। `centerBegin` और `centerEnd` box के दोनों ओर लटके रहते हैं, इसी तरह घड़ी ठीक केंद्र में बनी रहती है, जबकि मौसम और update badge आते-जाते रहते हैं। `center` में एक से अधिक widget रखें और वे एक साथ केंद्रित होते हैं; इसे खाली छोड़ दें और `centerBegin` और `centerEnd` बार के बीच में मिल जाते हैं।

एक नियम जिसे आत्मसात करना फ़ायदेमंद है: **एक बार जब आपके पास अपना `shell.json` हो जाता है, तो वह canonical है**। जब तक आप कुछ भी customize नहीं करते, shell Omarchy की default file पढ़ता है। जिस क्षण आप कोई widget खींचते हैं, `omarchy bar` चलाते हैं, या file को खुद संपादित करते हैं, आप उसके मालिक बन जाते हैं — कोई deep merge नहीं होता, इसलिए भविष्य के Omarchy releases में नए default widgets आपके बार पर अपने आप दिखाई नहीं देंगे। जब भी आप एक साफ़ शुरुआत चाहते हैं, `omarchy bar defaults` shipped layout वापस रख देता है।

वही file शीर्ष स्तर पर, `bar` key के बाहर, आपकी idle timings भी रखती है: `idle.screensaver` और `idle.lock`, दोनों आपके idle होने के बाद के seconds में। इसलिए default screensaver 150 seconds पर शुरू होता है और lock 300 पर।
