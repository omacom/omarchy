# अपनी खुद की theme बनाना

आप अपनी खुद की themes `~/.config/omarchy/themes` में जोड़ सकते हैं। बस मौजूदा themes में से किसी एक को आधार के तौर पर copy कर लें ( `/usr/share/omarchy/themes` में देखें), फिर अपनी पसंद के हिसाब से उसमें बदलाव करें। जब तक आपकी theme उस folder के अंदर है, वह theme selection menu में शामिल रहेगी।

आपको जिस मुख्य file में बदलाव करना है, वह है `colors.toml`। वही उस color set को परिभाषित करती है जिसका उपयोग फिर terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, और पूरे Omarchy shell (top bar, menu, notifications, OSD, और lock screen) के लिए configurations बनाने में किया जाता है।

आप साथ में आए Aether application का उपयोग करके भी एक नई theme बना सकते हैं, जिसमें colors के साथ खेलने और backgrounds खोजने के लिए एक सुंदर GUI interface मिलता है। इसे बस `Super + Alt + Space` पर app grid से शुरू करें।

### एक installed theme में क्या-क्या हो सकता है

जो theme आप खुद `~/.config/omarchy/themes` में लिखते हैं, उसमें आप जो चाहें रख सकते हैं — यह आपकी machine है और आपकी file है, और Omarchy उसका सब कुछ लागू करता है।

जो theme आप किसी और के repo से `omarchy theme install` के साथ install करते हैं, वह हर वह चीज़ रखती है जो colour है, और उन मुट्ठी भर files को खो देती है जो आपकी machine पर code चलातीं: कोई भी `.lua` file, terminal configs (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), और `vscode.json`। किसी theme की `hyprland.lua` वह Lua है जिसे आपका compositor login के समय चलाता है, कोई terminal config उस program का नाम बताता है जिसे आपका terminal शुरू करता है, और `vscode.json` install किए जाने वाले किसी VSCode extension का नाम बताता है। किसी की theme install करने से यह बदलना चाहिए कि आपका desktop कैसा दिखता है, यह कभी नहीं कि वह क्या चलाता है।

बाकी सब कुछ ठीक वैसे ही काम करता रहता है जैसा theme के लेखक ने लिखा था — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, backgrounds और previews, सब रखे जाते हैं। केवल जो हटाया गया था, वही आपकी machine पर `colors.toml` से फिर से बनाया जाता है।

Omarchy दोनों में अंतर इस बात से करता है कि theme के अंदर उसका अपना git repo है या नहीं, जो वही है जो `omarchy theme install` clone करते समय पीछे छोड़ जाता है। तो जो theme आपने लिखी, वह आपकी ही रहती है, और जो आपने internet से ली, वह colours ही रहती है।

### लाइट मोड

अगर आप light mode theme बना रहे हैं, तो अपनी `colors.toml` के सबसे ऊपर `mode = "light"` set करें। फिर वह सभी apps के लिए अपने आप light mode के साथ जोड़ दी जाएगी। (अपनी theme के root में `light.mode` नाम की एक खाली file डालने का पुराना तरीका भी अभी काम करता है।)

### Unlock image

जिन themes के साथ `unlock.png` और `preview-unlock.png` images दी गई होंगी, वे _Appearance > Unlock_ के अंतर्गत सूचीबद्ध होंगी। आपकी `unlock.png` अधिमानतः एक transparent png होनी चाहिए। और आप `omarchy plymouth preview` का उपयोग करके preview image बना सकते हैं।

### उन apps की theming जिन्हें Omarchy cover नहीं करता

अगर आप किसी ऐसे app का उपयोग करते हैं जो उस सूची में नहीं है, तो आप एक template के साथ Omarchy को खुद उसे theme करना सिखा सकते हैं। `~/.config/omarchy/themed/` में एक file डालें जिसका नाम उस config के नाम पर हो जिसे वह बनाती है, साथ में एक `.tpl` extension हो, और config को `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` से लेकर `{{ color15 }}` तक, और palette के बाकी हिस्सों को placeholders के रूप में लिखकर बनाएं। हर बार जब आप themes बदलते हैं, file उस theme के colors के साथ फिर से बनाई जाती है।

उस folder में पूरी तरह commented एक `alacritty.toml.tpl.sample` है जिससे आप copy कर सकते हैं — इसमें हर वह variable सूचीबद्ध है जिसका आप उपयोग कर सकते हैं, साथ में उन apps के लिए `_strip` और `_rgb` modifiers भी हैं जो अपने colors को `#` के बिना या decimal RGB के रूप में चाहते हैं। आपकी templates को Omarchy की अपनी templates पर प्राथमिकता मिलती है, इसलिए आप इसका उपयोग यह override करने के लिए भी कर सकते हैं कि किसी built-in app को कैसे theme किया जाए।

### अपनी theme वितरित करना

अगर आप अपनी theme वितरित करना चाहते हैं ताकि दूसरे उसका उपयोग कर सकें, तो आपको उसे किसी public git server, जैसे GitHub, पर रखना होगा। फिर लोग Omarchy menu में _Install > Style > Theme_ का उपयोग करके उस URL से उसे install कर सकते हैं। यह सलाह दी जाती है कि आप `omarchy-[themename]-theme` के naming convention का पालन करें, क्योंकि installation के बाद theme selection menu में theme सही ढंग से सिर्फ `[themename]` के रूप में दिखेगी।

वह बचा हुआ `[themename]` theme का directory name बन जाता है, इसलिए वह ऐसा होना चाहिए जिसे Omarchy सुरक्षित रूप से इधर-उधर दे सके: उसे किसी letter, किसी digit, या किसी underscore से शुरू होना चाहिए, और बाकी हिस्से में letters, digits, `.`, `_`, `+`, और `-` हो सकते हैं। Capitals आपके लिए lowercase में बदल दिए जाते हैं, लेकिन बाकी कुछ भी — कोई space, कोई quote, कोई non-English character — directory name में बदले जाने के बजाय install के समय अस्वीकार कर दिया जाता है। इसलिए `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, और `omarchy-c++-theme` सभी ठीक से install हो जाती हैं।

याद रखें कि एक बार जब वह किसी repo से install हो जाती है, तो उसके साथ आने वाली कोई भी `.lua`, terminal config या `vscode.json` हटा दी जाती है, इसलिए theme को उन चीज़ों के इर्द-गिर्द न बनाएं।

आप [अतिरिक्त themes पेज](https://omarchy.org/themes/) पर अपनी theme को [omarchy-site repo](https://github.com/omacom-io/omarchy-site) को एक pull request भेजकर जुड़वा सकते हैं।
