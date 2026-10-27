# अपनी खुद की थीम बनाना

आप `~/.config/omarchy/themes` में अपनी खुद की थीम जोड़ सकते हैं। बस मौजूदा थीमों में से किसी एक को आधार बनाकर कॉपी करें (`/usr/share/omarchy/themes` में देखें), फिर अपनी खुशी के हिसाब से बदलाव करें। जब तक आपकी थीम उस फ़ोल्डर के अंदर है, वह थीम चयन मेनू में शामिल रहेगी।

मुख्य फाइल जिसे आपको बदलना है वह `colors.toml` है। यह उन रंगों के सेट को परिभाषित करती है जिनका उपयोग फिर terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, और पूरे Omarchy shell (टॉप बार, मेनू, नोटिफ़िकेशन, OSD, और लॉक स्क्रीन) के लिए configurations तैयार करने में किया जाता है।

आप शामिल Aether application का उपयोग करके भी एक नई थीम बना सकते हैं, जिसमें रंगों के साथ खेलने और backgrounds खोजने के लिए एक सुंदर GUI interface मिलता है। बस इसे `Super + Alt + Space` पर app grid से शुरू करें।

### एक इंस्टॉल की गई थीम में क्या हो सकता है

जो थीम आप खुद `~/.config/omarchy/themes` में लिखते हैं, उसमें आप जो चाहें रख सकते हैं — यह आपकी मशीन है और आपकी फाइल है, और Omarchy इसे पूरा का पूरा लागू करता है।

जो थीम आप किसी और के repo से `omarchy theme install` के साथ इंस्टॉल करते हैं, वह रंग से जुड़ी हर चीज़ रखती है, और उन मुट्ठी भर फाइलों को हटा देती है जो आपकी मशीन पर code चलातीं: कोई भी `.lua` फाइल, terminal configs (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), और `vscode.json`। किसी थीम की `hyprland.lua` वह Lua होती है जिसे आपका compositor login के समय चलाता है, एक terminal config उस program का नाम बताता है जिसे आपका terminal शुरू करता है, और `vscode.json` इंस्टॉल किए जाने वाले VSCode extension का नाम बताता है। किसी की थीम इंस्टॉल करने से आपका desktop कैसा दिखता है, यह बदलना चाहिए, यह कभी नहीं कि वह क्या चलाता है।

बाकी सब कुछ ठीक वैसा ही काम करता है जैसा थीम के लेखक ने लिखा था — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, backgrounds और previews सभी रखे जाते हैं। केवल जो हटाया गया था, वही आपकी मशीन पर `colors.toml` से फिर से तैयार किया जाता है।

Omarchy दोनों के बीच अंतर इस बात से करता है कि थीम के अंदर उसका अपना git repo है या नहीं, जो वही है जो `omarchy theme install` clone करते समय पीछे छोड़ देता है। तो जो थीम आपने लिखी है, वह आपकी ही रहती है, और जो आपने internet से ली है, वह केवल रंगों तक रहती है।

### लाइट मोड

अगर आप light mode थीम बना रहे हैं, तो अपने `colors.toml` के शीर्ष पर `mode = "light"` सेट करें। फिर यह सभी apps के लिए अपने आप light mode के साथ जुड़ जाएगी। (आपकी थीम के root में `light.mode` नाम की एक खाली फाइल डालने का पुराना तरीका भी अभी काम करता है।)

### आइकन के रंग

अगर आप file manager icons को अपनी थीम से रंग-मेल करना चाहते हैं, तो `icons.theme` नाम की एक फाइल जोड़ें जिसमें उस icon set का नाम हो जिसका आप उपयोग करना चाहते हैं। डिफ़ॉल्ट रूप से, विकल्प हैं: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`।

### अनलॉक इमेज

`unlock.png` और `preview-unlock.png` images के साथ दी गई थीम _Appearance > Unlock_ के अंतर्गत सूचीबद्ध होंगी। आपकी `unlock.png` अधिमानतः एक transparent png होनी चाहिए। और आप `omarchy plymouth preview` का उपयोग करके preview image बना सकते हैं।

### उन apps की थीमिंग जिन्हें Omarchy कवर नहीं करता

अगर आप किसी ऐसे app का उपयोग करते हैं जो उस सूची में नहीं है, तो आप एक template के साथ Omarchy को खुद उसे थीम करना सिखा सकते हैं। `~/.config/omarchy/themed/` में एक फाइल डालें जिसका नाम उस config के नाम पर हो जिसे यह तैयार करती है, साथ में `.tpl` extension हो, और config को `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` से `{{ color15 }}` तक, और palette के बाकी हिस्सों को placeholders के रूप में लिखें। हर बार जब आप थीम बदलते हैं, तो फाइल उस थीम के रंगों के साथ फिर से तैयार की जाती है।

उस फ़ोल्डर में कॉपी करने के लिए एक पूरी तरह commented `alacritty.toml.tpl.sample` है — यह हर variable को सूचीबद्ध करता है जिसका आप उपयोग कर सकते हैं, साथ में उन apps के लिए `_strip` और `_rgb` modifiers भी, जो अपने रंगों को `#` के बिना या decimal RGB के रूप में चाहते हैं। आपके templates को Omarchy के अपने templates पर प्राथमिकता मिलती है, इसलिए आप इसका उपयोग यह बदलने के लिए भी कर सकते हैं कि कोई built-in app कैसे थीम किया जाता है।

### अपनी थीम वितरित करना

अगर आप अपनी थीम वितरित करना चाहते हैं ताकि दूसरे इसका उपयोग कर सकें, तो आपको इसे GitHub जैसे किसी public git server पर रखना होगा। फिर लोग उस URL का उपयोग करके Omarchy menu में _Install > Style > Theme_ के माध्यम से इसे इंस्टॉल कर सकते हैं। यह सलाह दी जाती है कि आप `omarchy-[themename]-theme` के नामकरण परंपरा का पालन करें, क्योंकि इंस्टॉलेशन के बाद थीम चयन मेनू में थीम सही ढंग से केवल `[themename]` के रूप में दिखेगी।

वह बचा हुआ `[themename]` थीम का directory नाम बन जाता है, इसलिए यह ऐसा होना चाहिए जिसे Omarchy सुरक्षित रूप से इधर-उधर दे सके: यह एक letter, एक digit, या एक underscore से शुरू होना चाहिए, और बाकी हिस्से में letters, digits, `.`, `_`, `+`, और `-` हो सकते हैं। Capitals आपके लिए lowercase में बदल दिए जाते हैं, लेकिन इसके अलावा कुछ भी — एक space, एक quote, एक गैर-English character — directory नाम में बदलने के बजाय install के समय अस्वीकार कर दिया जाता है। तो `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, और `omarchy-c++-theme` सभी ठीक से इंस्टॉल हो जाते हैं।

याद रखें कि एक बार जब यह किसी repo से इंस्टॉल हो जाती है, तो इसके साथ आने वाली कोई भी `.lua`, terminal config या `vscode.json` हटा दी जाती है, इसलिए थीम को उनके इर्द-गिर्द न बनाएं।

आप [omarchy-site repo](https://github.com/omacom-io/omarchy-site) को एक pull request भेजकर अपनी थीम को [अतिरिक्त थीम पेज](https://omarchy.org/themes/) में जुड़वा सकते हैं।
