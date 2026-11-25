# डॉटफ़ाइलें

Omarchy मुख्य रूप से तथाकथित dotfiles के माध्यम से कॉन्फ़िगर किया जाता है जो `~/.config` में रहती हैं। उन्हें आपके बदलावों के लिए आपकी फ़ाइलें माना जाता है। जो फ़ाइलें `/usr/share/omarchy` में रहती हैं वे खुद Omarchy की हैं, और आपको उनसे छेड़छाड़ नहीं करनी चाहिए। अगर आपको `/usr/share/omarchy` में कुछ भी बदलने की ज़रूरत पड़े, तो आपको इसके बजाय `~/.config` में मान को ओवरराइट करना चाहिए।

मुख्य कॉन्फ़िग को सीधे Omarchy मेनू (`Super + Space`) से संपादित किया जा सकता है, जैसे _Setup > Keyboard > Keybindings_, _Setup > Input_, और _Setup > Config > [file]_। जब आप इसे इस तरह करते हैं, तो कोई भी प्रोसेस जिसे कॉन्फ़िग संपादन के बाद रीस्टार्ट करने की ज़रूरत होगी, वह आपके एडिटर बंद करने के बाद स्वचालित रूप से रीस्टार्ट हो जाएगा (डिफ़ॉल्ट रूप से Neovim — `:wq`, याद रखें! — लेकिन आप इसे _Setup > Defaults > Editor_ के माध्यम से बदल सकते हैं)।

यहाँ `~/.config` में मौजूद मुख्य फ़ाइलों की सूची है और वे क्या नियंत्रित करती हैं:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | मुख्य Hyprland कॉन्फ़िग। Omarchy के डिफ़ॉल्ट के साथ-साथ नीचे दी गई आपकी ओवरराइड फ़ाइलें लोड करता है। [Hyprland कॉन्फ़िग के बारे में ज़्यादा जानें](https://wiki.hypr.land/Configuring/)।  |
| `~/.config/hypr/bindings.lua` | आपकी अपनी keybindings और डिफ़ॉल्ट की ओवरराइड। |
| `~/.config/hypr/monitors.lua` | मॉनिटर सेटिंग्स जो मॉनिटर पैनल कवर नहीं करता, जैसे rotation, अतिरिक्त मोड, या किसी मॉनिटर को बंद रखना। |
| `~/.config/hypr/input.lua` | आपके keyboard layout, माउस और trackpad सेटिंग्स को नियंत्रित करता है। |
| `~/.config/hypr/looknfeel.lua` | gaps, borders, animations और बाकी लुक को नियंत्रित करता है। |
| `~/.config/hypr/autostart.lua` | सेशन के साथ शुरू होने वाले अतिरिक्त प्रोसेस को नियंत्रित करता है। |
| `~/.config/omarchy/shell.json` | Omarchy shell को नियंत्रित करता है: bar की स्थिति, layout और widgets, साथ ही screensaver, lock और idle timings। |
| `~/.config/foot/foot.ini` | आपके टर्मिनल को नियंत्रित करता है (foot डिफ़ॉल्ट है)। |
| `~/.XCompose` | आपके quick-access emoji और name/email autocomplete को परिभाषित करता है। बदलाव करने के बाद `omarchy-restart-xcompose` चलाना सुनिश्चित करें। |

अगर आप अपने खुद के सेटअप को ट्वीक करने के लिए बहुत सारे बदलाव करने लगें, तो इन सभी dotfiles का बैकअप लेना एक अच्छा विचार है। [Stow ऐसा करने का एक शानदार तरीका है](https://www.youtube.com/watch?v=NoFiYOqnC4o)।

### सेशन के साथ अपने खुद के ऐप्स शुरू करना

अगर आप चाहते हैं कि हर बार लॉग इन करने पर कुछ चले — एक sync daemon, एक chat ऐप, आपकी खुद की script — तो उसे `~/.config/hypr/autostart.lua` में रखें:

```lua
o.launch_on_start("my-service")
```

वह कमांड को सेशन के हिस्से के रूप में शुरू करता है, इसलिए जब आप फिर से लॉग आउट करते हैं तो वह ठीक से साफ़ हो जाता है।

### सिस्टम इवेंट्स पर स्क्रिप्ट चलाना

Omarchy कुछ गिने-चुने मौकों पर hooks फ़ायर करता है, और आप उनसे अपनी खुद की scripts जोड़ सकते हैं। वे `~/.config/omarchy/hooks/<event>.d/` में रहती हैं, प्रति इवेंट एक डायरेक्टरी, और वहाँ मौजूद हर फ़ाइल जो `.sample` पर खत्म नहीं होती, इवेंट होने पर bash के साथ चलती है:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | डेस्कटॉप शुरू होने के ठीक बाद |
| `post-update` | `omarchy update` के अंत के करीब, packages, migrations और service restarts के बाद, mise tools अपडेट होने से पहले |
| `pre-refresh-pacman` | `omarchy refresh pacman` द्वारा package config को फिर से सिंक करने के बाद, packages अपडेट करने से पहले; channel switch उसी refresh स्टेप के दौरान इसे चलाता है |
| `theme-set` | थीम बदलने के बाद (थीम का नाम `$1` में) |
| `font-set` | फ़ॉन्ट बदलने के बाद (फ़ॉन्ट का नाम `$1` में) |
| `battery-low` | जब बैटरी कम हो जाती है (प्रतिशत `$1` में) |

`pre-refresh-pacman` hook वह जगह है जहाँ custom repositories या `IgnorePkg` लाइनें होनी चाहिए, क्योंकि यह package transaction से पहले चलता है। दोनों आपके उपयोगकर्ता के रूप में चलते हैं। `post-update` तब चलता है जब `omarchy update` का sudo authorization अभी भी ताज़ा होता है, इसलिए `sudo` का उपयोग करने वाला hook फिर से आपका पासवर्ड नहीं माँगेगा; `pre-refresh-pacman` ठीक तब चलता है जब `omarchy refresh pacman` खुद sudo का उपयोग कर चुका होता है।

उनमें से प्रत्येक डायरेक्टरी में पहले से ही एक `.sample` फ़ाइल मौजूद है जो hook का रूप दिखाती है — उसे काम में लाने के लिए नाम से `.sample` हटा दें। कहीं और लिखी गई script को इंस्टॉल करने के लिए, `omarchy hook install post-boot ~/my-hook` का उपयोग करें, जो उसे अंदर कॉपी करता है और executable बनाता है।

### अपनी खुद की मेनू प्रविष्टियाँ जोड़ना

Omarchy मेनू (`Super + Space`) को `~/.config/omarchy/extensions/omarchy-menu.jsonc` को संपादित करके अपनी खुद की पंक्तियों के साथ बढ़ाया जा सकता है। प्रविष्टियाँ एक dotted id द्वारा key की जाती हैं, और id ही उन्हें ट्री में रखती है, इसलिए `personal` रूट मेनू पर दिखाई देता है और `personal.notes` उसके अंदर दिखाई देता है:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

किसी मौजूद id का फिर से उपयोग करें और आप नई पंक्ति जोड़ने के बजाय उस पंक्ति को ओवरराइड कर देंगे। फ़ाइल सभी उपलब्ध फ़ील्ड को comments के रूप में दस्तावेज़ित करके भेजी जाती है।

### अपने खुद के shell exports, functions और aliases जोड़ना

Omarchy ढेर सारे ergonomic aliases और मददगार functions के साथ आता है, लेकिन अपने खुद के जोड़ना चाहना बहुत आम है। आपको aliases, functions और exports दोनों को `~/.bashrc` में जोड़ना चाहिए। यह फ़ाइल updates पर ओवरराइट नहीं होगी। अगर आप Omarchy के किसी भी डिफ़ॉल्ट को बदलना चाहते हैं, तो आप उन्हें यहाँ भी सुरक्षित रूप से जोड़ सकते हैं।

### डेस्कटॉप के लिए environment variables सेट करना

डेस्कटॉप सेशन exports `~/.config/uwsm/env.d/` में होने चाहिए। ये फ़ाइलें आपके डेस्कटॉप के शुरू होने से पहले चलती हैं, इसलिए shell error आपको वापस लॉगिन स्क्रीन पर भेज सकता है। उन्हें संपादित करते समय एक काम करता हुआ टर्मिनल खुला रखें। किसी ओवरराइड को अक्षम करने के लिए, उसे `env.d` से बाहर ले जाएँ। अगर कोई बदलाव लॉगिन को रोकता है तो [लॉगिन रिकवरी](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) देखें।

### आंतरिक Omarchy फ़ाइलें बदलना

देखो, यह आपका कंप्यूटर है। आप इसके साथ जो चाहो कर सकते हैं, लेकिन मैं `/usr/share/omarchy` में मौजूद फ़ाइलों में सीधे बदलाव करने के खिलाफ़ सलाह दूँगा। वे Omarchy pacman package की हैं, इसलिए आपके बदलाव अगले update पर बस ओवरराइट हो जाएँगे। इसके बजाय आपके लिए बेहतर होगा कि आप `~/.config/*` फ़ोल्डर में उन डिफ़ॉल्ट मानों को ही ओवरराइट कर दें जो आपको पसंद नहीं हैं।

आप इस तरह लगभग सब कुछ बदल सकते हैं, जैसे डिफ़ॉल्ट keybindings। बस `~/.config/hypr/bindings.lua` को संपादित करके, मान लीजिए, [Obsidian](https://obsidian.md/) को [Joplin](https://joplinapp.org/) से बदल दें (इसे `omarchy-pkg-add joplin-bin` से इंस्टॉल करें):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` अपना प्रतिस्थापन जोड़ने से पहले मौजूदा binding को हटा देता है। यह `o.bind` के समान ही arguments लेता है, जिसमें launch helpers और binding options शामिल हैं। binding जोड़ने के लिए `o.bind` का उपयोग करें, या किसी को बदले बिना हटाने के लिए `hl.unbind` का उपयोग करें।

अगर आप आंतरिक Omarchy फ़ाइलों पर हैकिंग करने पर ज़िद करते हैं, तो _Update > Channel > Dev_ के माध्यम से dev channel पर स्विच करें। वह Omarchy को `~/omarchy` में source code के git checkout से लिंक करता है, जिसे आप अपने दिल की मर्ज़ी से बदलने के लिए स्वतंत्र हैं। यहाँ कोई आपको यह बताने वाला नहीं है कि क्या करना है!

### कोई भी बदलाव रीसेट करना

अगर आप कॉन्फ़िगरेशन का कबाड़ा कर दें, तो आप Omarchy मेनू में _Update > Config_ के माध्यम से उन्हें हमेशा डिफ़ॉल्ट पर वापस ला सकते हैं। या सब कुछ रीसेट करने के लिए `omarchy reinstall configs` चलाकर।
