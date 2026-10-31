# Dotfiles

Omarchy मुख्य रूप से तथाकथित dotfiles के माध्यम से कॉन्फ़िगर किया जाता है जो `~/.config` में रहती हैं। वे तुम्हारे बदलावों के लिए तुम्हारी फ़ाइलें मानी जाती हैं। `/usr/share/omarchy` में रहने वाली फ़ाइलें Omarchy की खुद की हैं, और तुम्हें उनसे छेड़छाड़ नहीं करनी चाहिए। अगर तुम्हें `/usr/share/omarchy` में कुछ बदलने की आवश्यकता है, तो तुम्हें इसके बजाय `~/.config` में उस मान को overwrite करना चाहिए।

मुख्य configs को Omarchy मेनू (`Super + Space`) से सीधे edit किया जा सकता है, जैसे _Setup > Keybindings_, _Setup > Input_, और _Setup > Config > [file]_। जब तुम ऐसा करते हो, तो config edits के बाद जिस भी process को restart करने की आवश्यकता होती है, वह तुम्हारे editor बंद करने के बाद अपने आप restart हो जाएगा (डिफ़ॉल्ट रूप से Neovim — `:wq`, याद है ना! — लेकिन तुम इसे _Setup > Defaults > Editor_ के माध्यम से बदल सकते हो)।

यहाँ `~/.config` में मौजूद मुख्य फ़ाइलों की सूची है और वे क्या control करती हैं:

| फ़ाइल | उद्देश्य |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | मुख्य Hyprland config। Omarchy defaults के साथ-साथ नीचे दी गई तुम्हारी override फ़ाइलें load करता है। [Hyprland configs के बारे में और जानें](https://wiki.hypr.land/Configuring/)। |
| `~/.config/hypr/bindings.lua` | तुम्हारी अपनी keybindings और defaults के overrides। |
| `~/.config/hypr/monitors.lua` | वे monitor settings जिन्हें monitor panel cover नहीं करता, जैसे rotation, extra modes, या किसी monitor को बंद रखना। |
| `~/.config/hypr/input.lua` | तुम्हारे keyboard layout, mouse, और trackpad settings को control करता है। |
| `~/.config/hypr/looknfeel.lua` | gaps, borders, animations, और बाकी पूरे look को control करता है। |
| `~/.config/hypr/autostart.lua` | सेशन के साथ शुरू होने वाले extra processes को control करता है। |
| `~/.config/omarchy/shell.json` | Omarchy shell को control करता है: bar position, layout, और widgets, साथ ही screensaver, lock, और idle timings। |
| `~/.config/foot/foot.ini` | तुम्हारे terminal को control करता है (foot डिफ़ॉल्ट है)। |
| `~/.XCompose` | तुम्हारे quick-access emoji और name/email autocomplete को define करता है। बदलाव करने के बाद `omarchy-restart-xcompose` चलाना सुनिश्चित करो। |

अगर तुम अंत में अपने खुद के setup को tweak करने के लिए बहुत सारे बदलाव कर डालते हो, तो इन सभी dotfiles का backup लेना एक अच्छा विचार है। [Stow ऐसा करने का एक बढ़िया तरीका है](https://www.youtube.com/watch?v=NoFiYOqnC4o)।

### सेशन के साथ अपने खुद के ऐप शुरू करना

अगर तुम चाहते हो कि हर बार log in करने पर कुछ चले — एक sync daemon, एक chat app, तुम्हारी अपनी script — तो उसे `~/.config/hypr/autostart.lua` में रख दो:

```lua
o.launch_on_start("my-service")
```

यह उस command को सेशन के हिस्से के रूप में शुरू करता है, इसलिए जब तुम फिर से log out करते हो तो वह ठीक ढंग से clean up हो जाता है।

### सिस्टम इवेंट्स पर स्क्रिप्ट चलाना

Omarchy कुछ चुनिंदा क्षणों पर hooks fire करता है, और तुम उन पर अपनी खुद की scripts टांग सकते हो। वे `~/.config/omarchy/hooks/<event>.d/` में रहती हैं, प्रत्येक event के लिए एक directory, और event होने पर वहाँ मौजूद हर executable फ़ाइल चलती है:

| Event | यह कब चलता है |
| ----- | ------------ |
| `post-boot` | Desktop शुरू होने के ठीक बाद |
| `post-update` | `omarchy update` के अंत के करीब, packages, migrations, और service restarts के बाद, mise tools update होने से पहले |
| `pre-refresh-pacman` | `omarchy refresh pacman` द्वारा package config को फिर से sync करने के बाद, उसके द्वारा packages update करने से पहले; channel switch उसी refresh step के दौरान इसे चलाता है |
| `theme-set` | Theme बदलने के बाद (theme का नाम `$1` में) |
| `font-set` | Font बदलने के बाद (font का नाम `$1` में) |
| `battery-low` | जब battery कम हो जाती है (percentage `$1` में) |

`pre-refresh-pacman` hook वह जगह है जहाँ custom repositories या `IgnorePkg` lines होनी चाहिए, क्योंकि यह package transaction से पहले चलता है। दोनों update-संबंधी hooks Omarchy द्वारा अपनी cached sudo authorization साफ़ करने के बाद तुम्हारे user के रूप में चलते हैं, इसलिए `sudo` का उपयोग करने वाले hook को अपनी खुद की authorization की आवश्यकता होगी और वह तुमसे तुम्हारा password माँग सकता है।

उनमें से प्रत्येक directory में पहले से ही एक `.sample` फ़ाइल मौजूद है जो hook का आकार दिखाती है — उसे काम में लाने के लिए नाम से `.sample` हटा दो। कहीं और लिखी हुई script install करने के लिए `omarchy hook install post-boot ~/my-hook` का उपयोग करो, जो उसे वहाँ copy कर देगा और executable बना देगा।

### अपने खुद के मेनू एंट्री जोड़ना

Omarchy मेनू (`Super + Space`) को `~/.config/omarchy/extensions/omarchy-menu.jsonc` edit करके अपनी खुद की rows के साथ बढ़ाया जा सकता है। Entries एक dotted id से keyed होती हैं, और id ही उन्हें tree में रखता है, इसलिए `personal` root मेनू पर दिखाई देता है और `personal.notes` उसके अंदर दिखाई देता है:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

मौजूदा id को फिर से उपयोग करने पर तुम नई row जोड़ने के बजाय उस row को override कर देते हो। फ़ाइल में सभी उपलब्ध fields comments के रूप में documented हैं।

### अपने खुद के shell exports, functions, और aliases जोड़ना

Omarchy बहुत सारे ergonomic aliases और मददगार functions के साथ आता है, लेकिन अपने खुद के जोड़ना चाहना बहुत आम है। तुम्हें aliases, functions, और exports को `~/.bashrc` में जोड़ना चाहिए। यह फ़ाइल updates पर overwrite नहीं होगी। अगर तुम Omarchy defaults में से किसी को बदलना चाहते हो, तो तुम उन्हें यहाँ भी सुरक्षित रूप से जोड़ सकते हो।

### आंतरिक Omarchy फ़ाइलें बदलना

देखो, यह तुम्हारा कंप्यूटर है। तुम इसके साथ जो चाहो कर सकते हो, लेकिन मैं `/usr/share/omarchy` में मौजूद फ़ाइलों में सीधे बदलाव करने के खिलाफ सलाह दूँगा। वे Omarchy pacman package से संबंधित हैं, इसलिए तुम्हारे बदलाव अगले update पर बस overwrite हो जाएँगे। इसके बजाय तुम्हारे लिए बेहतर होगा कि तुम `~/.config/*` folder में उन default values को ही overwrite कर दो जो तुम्हें पसंद नहीं हैं।

तुम उस तरीके से लगभग सब कुछ बदल सकते हो, जैसे default keybindings। बस `~/.config/hypr/bindings.lua` को edit करके, मान लो, [Obsidian](https://obsidian.md/) को [Joplin](https://joplinapp.org/) से बदल दो (`omarchy-pkg-add joplin-bin` से install करो):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` replacement जोड़ने से पहले मौजूदा binding को हटा देता है। यह `o.bind` के समान ही arguments लेता है, launch helpers और binding options सहित। Binding जोड़ने के लिए `o.bind` का उपयोग करो, या उसे बिना replace किए हटाने के लिए `hl.unbind` का उपयोग करो।

अगर तुम आंतरिक Omarchy फ़ाइलों को hack करने पर ही अड़े हुए हो, तो _Update > Channel > Dev_ के माध्यम से dev channel पर switch कर लो। इससे Omarchy `~/omarchy` में मौजूद source code के git checkout से link हो जाता है, जिसे तुम दिल भरकर बदलने के लिए स्वतंत्र हो। यहाँ तुम्हें यह बताने वाला कोई नहीं है कि तुम्हें क्या करना है!

### किसी भी बदलाव को रीसेट करना

अगर तुम अंत में configurations की गड़बड़ कर डालते हो, तो तुम उन्हें Omarchy मेनू में _Update > Config_ के माध्यम से हमेशा defaults पर वापस ले जा सकते हो। या सब कुछ रीसेट करने के लिए `omarchy reinstall configs` चलाकर।
