# अपनी खुद की थीम बनाना

आप `~/.config/omarchy/themes` में अपनी खुद की थीम जोड़ सकते हैं। बस मौजूदा थीमों में से किसी एक को आधार के रूप में कॉपी करें (`/usr/share/omarchy/themes` में देखें), फिर अपनी खुशी के हिसाब से उसमें बदलाव करें। जब तक आपकी थीम उस फ़ोल्डर के अंदर है, वह थीम चुनने वाले मेनू में शामिल रहेगी।

मुख्य फ़ाइल जिसमें आपको बदलाव करना है, वह है `colors.toml`। वह रंगों का वह सेट तय करती है जिसका इस्तेमाल फिर terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt apps, keyboard backlight, input method, screen-share picker, app icons, कई AI tools (Claude, Pi, Hermes, T3 Code, Herdr) और पूरे Omarchy shell (top bar, menu, notifications, OSD और lock screen) के लिए configurations तैयार करने में होता है।

आप शामिल Aether application का इस्तेमाल करके भी एक नई थीम बना सकते हैं, एक प्यारे GUI interface के ज़रिए रंगों के साथ खेलकर और backgrounds खोजकर। इसे बस `Super + Alt + Space` पर app grid से शुरू करें।

### इंस्टॉल की गई थीम में क्या-क्या हो सकता है

`~/.config/omarchy/themes` में खुद लिखी गई थीम में आप जो चाहें रख सकते हैं — यह आपकी machine है और आपकी फ़ाइल है, और Omarchy वह सब लागू करता है।

किसी और के repo से `omarchy theme install` द्वारा इंस्टॉल की गई थीम में रंग से जुड़ी हर चीज़ बनी रहती है, और वे मुट्ठी भर फ़ाइलें हट जाती हैं जो आपकी machine पर कोड चलातीं: कोई भी `.lua` फ़ाइल, terminal configs (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), और `vscode.json`। किसी थीम की `hyprland.lua` वह Lua है जिसे आपका compositor login पर चलाता है, कोई terminal config उस program का नाम बताती है जिसे आपका terminal शुरू करता है, और `vscode.json` इंस्टॉल किए जाने वाले किसी VSCode extension का नाम बताती है। किसी की थीम इंस्टॉल करने से आपका desktop कैसा दिखता है, यह बदलना चाहिए, वह क्या चलाता है, यह कभी नहीं।

बाकी सब कुछ बिल्कुल वैसा ही काम करता रहता है जैसा थीम के लेखक ने लिखा था — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, backgrounds और previews, सब रखे जाते हैं। सिर्फ़ जो हटाया गया था, वही आपकी machine पर `colors.toml` से फिर से तैयार होता है।

Omarchy दोनों में फ़र्क़ इस बात से बताता है कि थीम के अंदर उसका अपना git repo है या नहीं, जो `omarchy theme install` clone करते समय पीछे छोड़ जाता है। तो जो थीम आपने लिखी, वह आपकी ही रहती है, और जो आपने internet से खींची, वह रंगों तक ही रहती है।

### Light mode

अगर आप light mode थीम बना रहे हैं, तो अपनी `colors.toml` के सबसे ऊपर `mode = "light"` सेट करें। फिर वह सभी apps के लिए अपने-आप light mode के साथ जुड़ जाएगी। (अपनी थीम की root में `light.mode` नाम की खाली फ़ाइल डालने का पुराना तरीका भी अभी काम करता है।)

### Unlock image

`unlock.png` और `preview-unlock.png` images के साथ दी गई थीमें _दिखावट > Unlock_ के तहत सूचीबद्ध होंगी। आपकी `unlock.png` बेहतर होगा कि एक पारदर्शी png हो। और आप `omarchy plymouth preview` का इस्तेमाल करके preview image बना सकते हैं।

### उन apps को थीम देना जिन्हें Omarchy कवर नहीं करता

अगर आप कोई ऐसा app इस्तेमाल करते हैं जो उस सूची में नहीं है, तो आप एक template के ज़रिए Omarchy को उसे खुद थीम देना सिखा सकते हैं। `~/.config/omarchy/themed/` में एक फ़ाइल डालें, जिसका नाम उसके द्वारा तैयार की जाने वाली config के नाम पर हो और उसमें `.tpl` extension जुड़ा हो, और config को `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` से लेकर `{{ color15 }}` तक और palette के बाकी हिस्सों को placeholders के रूप में लिखकर तैयार करें। हर बार जब आप थीम बदलते हैं, तो फ़ाइल उस थीम के रंगों के साथ फिर से तैयार हो जाती है।

उस फ़ोल्डर में पूरी तरह comments के साथ एक `alacritty.toml.tpl.sample` मौजूद है, जिसे कॉपी करके आप शुरुआत कर सकते हैं — उसमें हर वह variable सूचीबद्ध है जिसका आप इस्तेमाल कर सकते हैं, साथ ही उन apps के लिए `_strip` और `_rgb` modifiers भी हैं जो अपने रंग `#` के बिना या decimal RGB के रूप में चाहते हैं। आपकी templates को Omarchy की अपनी templates से ऊपर प्राथमिकता मिलती है, इसलिए आप इसका इस्तेमाल किसी built-in app को थीम दिए जाने के तरीके को बदलने के लिए भी कर सकते हैं।

### अपनी थीम वितरित करना

अगर आप अपनी थीम वितरित करना चाहते हैं ताकि दूसरे उसका इस्तेमाल कर सकें, तो आपको उसे किसी public git server, जैसे GitHub, पर डालना होगा। फिर लोग उस URL का इस्तेमाल करके Omarchy menu में _इंस्टॉल > Style > थीम_ के ज़रिए उसे इंस्टॉल कर सकते हैं। सलाह यह दी जाती है कि आप `omarchy-[themename]-theme` नामकरण परंपरा का पालन करें, क्योंकि इंस्टॉलेशन के बाद थीम चुनने वाले मेनू में थीम सही ढंग से सिर्फ़ `[themename]` के रूप में दिखेगी।

वह बचा हुआ `[themename]` थीम की directory का नाम बन जाता है, इसलिए उसे ऐसा होना चाहिए जिसे Omarchy सुरक्षित रूप से इधर-उधर दे सके: उसे किसी अक्षर, अंक या underscore से शुरू होना चाहिए, और बाकी हिस्से में अक्षर, अंक, `.`, `_`, `+` और `-` हो सकते हैं। बड़े अक्षरों को आपके लिए छोटे अक्षरों में बदल दिया जाता है, लेकिन और कुछ भी — कोई space, कोई quote, कोई गैर-अंग्रेज़ी अक्षर — उसे directory नाम में बदलने के बजाय इंस्टॉल के समय अस्वीकार कर दिया जाता है। इसलिए `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` और `omarchy-c++-theme`, ये सब ठीक से इंस्टॉल हो जाते हैं।

याद रखें कि repo से इंस्टॉल हो जाने के बाद, उसके साथ आने वाली कोई भी `.lua`, terminal config या `vscode.json` हटा दी जाती है, इसलिए थीम को उनके इर्द-गिर्द न बनाएँ।

आप अपनी थीम को [अतिरिक्त थीम पेज](https://omarchy.org/themes/) में जुड़वा सकते हैं, [omarchy-site repo](https://github.com/omacom-io/omarchy-site) को pull request भेजकर।
