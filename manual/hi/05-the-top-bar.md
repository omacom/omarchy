# ऊपरी बार

आपकी स्क्रीन के शीर्ष पर मौजूद पट्टी Omarchy बार है। यह कोई बाद में जोड़ी गई status bar नहीं है, बल्कि Omarchy shell का हिस्सा है, वही एकल, लंबे समय तक चलने वाली Quickshell प्रक्रिया जो menu, notifications, OSD popups और lock screen भी बनाती है। इसीलिए यह बाकी हर चीज़ के साथ पूरी तरह theme होती है और इसीलिए कोई panel किसी नए app को spawn करने के बजाय तुरंत खुलता है।

यह desktop का वह एकमात्र हिस्सा भी है जो हमेशा स्क्रीन पर रहता है, इसलिए यह जानना उपयोगी है कि वे सभी छोटे-छोटे glyphs क्या करते हैं।

## डिफ़ॉल्ट रूप से इस पर क्या होता है

बार के तीन खंड होते हैं। बाईं ओर Omarchy logo (menu launcher) और workspace संकेतक बैठते हैं। केंद्र में आपको status संकेतक, घड़ी, Elsewhen (एक world clock), मौसम और एक Omarchy update badge मिलता है। दाईं ओर: system tray, keyboard layout (जब एक से अधिक कॉन्फ़िगर किया गया हो), agents, bluetooth, network, audio, display और power।

इनमें से कुछ तभी दिखाई देते हैं जब उनके पास कहने के लिए कुछ हो। keyboard layout तभी दिखाई देता है यदि आपने एक से अधिक layout कॉन्फ़िगर किया हो। update badge तभी दिखाई देता है जब कोई Omarchy update प्रतीक्षा कर रहा हो। और agents आइकन पहली बार तभी दिखाई देता है जब Omarchy को मशीन पर AI coding उपयोग मिलता है (देखें [AI](17-ai.md))।

## इधर-उधर क्लिक करना

लगभग हर विजेट बाएँ, दाएँ और मध्य क्लिक पर कुछ करता है, और कई स्क्रॉल करने पर भी प्रतिक्रिया देते हैं। यही वह हिस्सा है जो लोगों से छूट जाता है — दायाँ और मध्य बटन ही वह जगह हैं जहाँ बहुत-सी अच्छी चीज़ें छिपी होती हैं।

| विजेट | बायाँ | दायाँ | मध्य / स्क्रॉल |
| --- | --- | --- | --- |
| Menu | Omarchy menu | नया terminal | — |
| Workspaces | इस मॉनिटर पर उस workspace पर फ़ोकस करें | — | स्क्रॉल: अगला/पिछला workspace |
| Clock | Calendar popup | label format को चक्रित करें | मध्य: timezone picker |
| Weather | Forecast popup | सूचना के रूप में पूरा मौसम | मध्य: refresh |
| Audio | Audio panel | Mute | मध्य: panel · स्क्रॉल: volume |
| Microphone | mic को mute करें | — | मध्य: audio panel · स्क्रॉल: input volume |
| Network | Network panel | — | — |
| Bluetooth | Bluetooth panel | radio को toggle करें | — |
| Display | Display panel | — | स्क्रॉल: brightness |
| Power | Power panel | battery प्रतिशत को toggle करें | — |
| Media | Play/pause | Cover-art popup | मध्य: अगला · स्क्रॉल: पिछला/अगला |
| Agents | Agents panel | अपना agent लॉन्च करें | मध्य: अगली subscription |
| Tray | drawer दिखाने के लिए hover करें | प्रबंधित करने के लिए chevron पर दायाँ क्लिक करें | — |
| Omarchy update | update चलाएँ | — | — |

उस तालिका में मौजूद हर चीज़ शुरुआत से ही आपके बार पर नहीं होती। media विजेट (MPRIS now-playing, स्क्रॉल होते track और artist के साथ) और microphone विजेट दोनों अंतर्निहित हैं लेकिन डिफ़ॉल्ट रूप से बंद रहते हैं — यदि आप उन्हें चाहते हैं तो उन्हें जोड़ें, जैसा कि नीचे बताया गया है।

## पैनल

किसी बार आइकन पर क्लिक करने से एक panel खुलता है, जो tooltip के बजाय sliders, सूचियों और keyboard navigation वाला एक उचित popup होता है। हर एक की एक hotkey भी होती है, ताकि आपको कभी किसी 16-pixel glyph पर निशाना न साधना पड़े:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + 1-9` | दाएँ खंड में nth panel को toggle करें |

ये panels केवल जानकारी दिखाने के लिए नहीं हैं। ये वह जगह हैं जहाँ आप असल में वह काम करते हैं:

- **Audio** में एक master volume slider, एक output-device picker और एक per-app mixer होता है, ताकि आप बाकी सब कुछ छुए बिना उस एक browser tab की आवाज़ कम कर सकें।
- **Network** Wi-Fi के लिए स्कैन करता है, signal strength दिखाता है, कनेक्ट करता है और आपको एक DNS provider चुनने देता है।
- **Bluetooth** आपके devices को connect/disconnect और battery स्तरों के साथ सूचीबद्ध करता है।
- **Power** battery के आँकड़े दिखाता है, power profiles बदलता है (यह battery और AC के लिए अलग-अलग पसंद याद रखता है), और कुछ system जानकारी छापता है।
- **Display** में एक brightness slider, text size, monitor scaling presets और — जब आपके पास एक से अधिक स्क्रीन हो — per-monitor नियंत्रण होते हैं। गहरी जानकारी के लिए देखें [मॉनिटर](33-monitors.md)।
- **Clock** ISO week संख्याओं और महीने बदलने की सुविधा के साथ एक महीने का grid खोलता है।
- **World clock** हर शहर के लिए एक पंक्ति रखता है, उसके मौसम और उसके दिन की स्थिति के साथ। Search कस्बों के साथ-साथ time zones को भी ढूँढता है, इसलिए Fort Lauderdale, Fort Lauderdale ही है, New York नहीं। यदि शीर्ष पर मौजूद पंक्ति गलत शहर का नाम देती है, तो उस पर क्लिक करें और बताएँ कि आप कहाँ हैं; किसी दूसरे time zone की जगह चुनें और system clock भी वहाँ चला जाता है, जो यात्रा के समय काम आता है। किसी शहर पर hover करें और person बटन पर क्लिक करके बताएँ कि वहाँ कौन रहता है — साधारण नाम, या उनके चेहरे साथ लाने के लिए `@` GitHub handles।

हर panel mouse के साथ-साथ keyboard भी लेता है: तीर घुमाते हैं, Return सक्रिय करता है, Tab पड़ोसी panel पर जाता है, और Escape बंद करता है।

`Super + Ctrl + 1-9` दाएँ खंड में panels को बाएँ से दाएँ गिनता है, tray को छोड़कर क्योंकि उसका अपना कोई panel नहीं है। इसलिए संख्या उसी आइकन से मेल खाती है जिसकी ओर आप इशारा करेंगे।

### Tailscale और Dropbox

दो और विजेट बार पर तभी दिखाई देते हैं जब आप **Install → Service** से मिलती-जुलती service स्थापित करते हैं, और दोनों को जानना उपयोगी है क्योंकि वे status बताने से अधिक काम करते हैं।

**Tailscale** panel tailnet को कनेक्ट और डिस्कनेक्ट करता है, accounts के बीच बदलता है, और एक exit node चुनता है (आपकी अपनी मशीनें और Mullvad क्षेत्र दोनों उस सूची में दिखाई देते हैं)। यह आपकी मशीनों को भी browse करता है — और किसी एक को चुने होने पर, `s` उसे Taildrop पर फ़ाइलें भेजता है, जो आपके फ़ोन या किसी अन्य laptop पर फ़ाइल ले जाने का सबसे तेज़ तरीका है। `c` मशीन का IP कॉपी करता है, `n` उसका नाम, और `d` उसका पूरा DNS नाम। हर मशीन पंक्ति पर एक send बटन भी होता है, यदि आप क्लिक करना पसंद करते हैं। terminal से वही काम है `omarchy tailscale send <machine> [file...]`।

**Dropbox** panel login संभालता है, दिखाता है कि आपने कितना storage इस्तेमाल किया है, और हाल में sync की गई फ़ाइलों को सूचीबद्ध करता है।

किसी भी service को हटाने से उसका विजेट बार से वापस हट जाता है।

## संकेतक

केंद्र में मौजूद छोटा समूह indicators विजेट है। ये उन modes के लिए status glyphs हैं जिन्हें आपने चालू किया है: do not disturb, night light, कतार में लगा [रिमाइंडर](09-reminders.md), सक्रिय screen recording, stay awake, और [डिक्टेशन](11-text-extraction-dictation.md)। जब mode सक्रिय होता है तो वे जगमगा उठते हैं और अन्यथा रास्ते से हटे रहते हैं — उन्हें झलक देखने के लिए उनके ठीक बगल में hover करें, जहाँ निष्क्रिय वाले बैठते होंगे। किसी संकेतक पर क्लिक करने से वह mode toggle हो जाता है। एक और केवल status के लिए है: जब कोई gliff के माध्यम से इस मशीन से जुड़ा होता है तो एक remote session लाल होकर जगमगाता है।

यदि आप चाहते हैं कि वे हमेशा दिखाई दें, तो विजेट पर `alwaysShow` को `true` पर सेट करें। और यदि आपको उनमें से केवल कुछ की ही परवाह है, तो जिन्हें आप चाहते हैं उन्हें `items` में सूचीबद्ध करें: `["Dnd", "Reminder", "NightLight"]`। आपके पास एक से अधिक indicators विजेट हो सकते हैं, इसलिए अलग-अलग खंड अलग-अलग subsets दिखा सकते हैं।

## बार को फिर से व्यवस्थित करना

बार खुद को कॉन्फ़िगर करता है। चीज़ों को इधर-उधर करने के लिए आपको कोई config file खोलनी नहीं पड़ती।

बार के केंद्र के आसपास किसी खाली हिस्से को पकड़ें और उसे किसी अन्य स्क्रीन किनारे की ओर खींचें, और बार वहाँ चला जाता है — बायाँ, दायाँ, ऊपर या नीचे, सभी काम करते हैं, और हर विजेट अनुकूल हो जाता है (ऊर्ध्वाधर बार compact icon-only रूपों पर वापस आ जाते हैं)। click-and-hold भी वही drag शुरू करता है। बार के background को clear से glassy से opaque तक चक्रित करने के लिए उसी खाली जगह पर double-left-click करें। और किसी भी विजेट को उसे फिर से क्रमबद्ध करने या उसे किसी अन्य खंड में फेंकने के लिए खींचें; अन्य विजेट वहाँ जगह बनाने के लिए अलग-अलग खिसक जाते हैं जहाँ वह उतरेगा।

बार का मध्य एक box है: उसमें जो भी है वह एक समूह के रूप में केंद्रित रहता है, और उसके किसी भी ओर के विजेट उसके किनारों से लटके रहते हैं। जब आप किसी विजेट को खींचते हैं तो box एक outline के रूप में दिखाई देता है, या खाली होने पर बार के आर-पार एक रेखा के रूप में, और आप उसमें या उसके बगल में छोड़ सकते हैं। जब कोई drop box में उतरने वाला होता है, तो box विजेट को अंदर लेने के लिए बढ़ जाता है।

जिस विजेट को आप आसपास तो चाहते हैं लेकिन हमेशा सामने नहीं, वह tray के drawer में जा सकता है: उसे tray पर खींचें, और drawer उसे लेने के लिए खुल जाता है। वह वहाँ app आइकनों के बाद बैठता है, जब भी drawer दिखाई देता है तब दिखाई देता है, और जब उसका panel खुला होता है तो अपने drawer को खुला रखता है। उसे वापस रखने के लिए उसे खींचकर वापस बार पर ले आएँ।

यदि आप किसी menu से चुनना पसंद करते हैं, तो **Appearance → Menu Bar** में स्थिति है, और **Bar Background** चुनता है कि बार कैसे बनाया जाए: **Opaque Bar**, **Glassy Bar** (पारदर्शी, उसके पीछे जो है वह धुंधला किया हुआ), या **Clear Bar**।

उन्हीं चीज़ों के commands भी हैं, जो आपको [dotfiles](31-dotfiles.md) setup के लिए चाहिए:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

किसी विजेट को पूरी तरह जोड़ने या हटाने के लिए, plugin commands का उपयोग करें। `omarchy plugin list` हर उस विजेट को उसकी id के साथ छापता है जिसे shell जानता है, और फिर:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## बार को छिपाना

`Super + Shift + Space` shell को मारे बिना बार को बंद और वापस चालू करता है — panels और hotkeys काम करते रहते हैं, आपको बस pixels वापस मिल जाते हैं। यह menu में **Appearance → Menu Bar → Hide Bar** के अंतर्गत भी है।

## कॉन्फ़िग फ़ाइल

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

हर विजेट पाँच layout arrays में से किसी एक में एक प्रविष्टि है, और उसकी settings उसी प्रविष्टि पर inline बैठती हैं — कोई अलग settings file नहीं है और कोई `config` sub-object नहीं है। घड़ी का `format`, `formatAlt` (जिस पर right-click चक्रित करता है), और `verticalFormat` सभी ठीक वहीं `{ "id": "omarchy.clock" }` पर रहते हैं।

`center` बार के मध्य में मौजूद box है: उसमें मौजूद हर चीज़ स्क्रीन पर एक समूह के रूप में केंद्रित होती है। `centerBegin` और `centerEnd` box के दोनों ओर लटके रहते हैं, इसी तरह घड़ी ठीक केंद्र में रहती है, भले ही मौसम और update badge आते-जाते रहें। `center` में एक से अधिक विजेट डालें और वे एक साथ केंद्रित होते हैं; उसे खाली छोड़ दें और `centerBegin` तथा `centerEnd` बार के मध्य में मिल जाते हैं।

याद रखने लायक एक नियम: **एक बार जब आपके पास अपनी `shell.json` हो जाती है, तो वही आधिकारिक होती है**। जब तक आप कुछ भी अनुकूलित नहीं करते, shell Omarchy की default file पढ़ता है। जिस क्षण आप किसी विजेट को खींचते हैं, `omarchy bar` चलाते हैं, या file को खुद संपादित करते हैं, वह आपकी हो जाती है — कोई deep merge नहीं होता, इसलिए भविष्य के Omarchy releases में नए default विजेट आपके बार पर अपने आप दिखाई नहीं देंगे। जब भी आप एक साफ़ शुरुआत चाहते हैं, `omarchy bar defaults` भेजी गई layout को वापस रख देता है।

वही file शीर्ष स्तर पर, `bar` key के बाहर, आपकी idle समय-सीमाएँ भी रखती है: `idle.screensaver` और `idle.lock`, दोनों आपके idle होने के बाद से सेकंड में। इसलिए default screensaver 150 सेकंड पर शुरू होता है और lock 300 पर।
