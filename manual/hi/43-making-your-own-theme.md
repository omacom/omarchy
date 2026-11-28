# अपनी खुद की थीम बनाना

आप `~/.config/omarchy/themes` में अपनी खुद की थीम जोड़ सकते हैं। बस मौजूदा थीमों में से किसी एक को आधार बनाकर कॉपी करें (`/usr/share/omarchy/themes` में देखें), फिर अपनी खुशी के हिसाब से उसमें बदलाव करें। जब तक आपकी थीम उस फ़ोल्डर के अंदर है, वह थीम चयन मेनू में शामिल रहेगी।

मुख्य फ़ाइल जिसमें आपको बदलाव करना है वह `colors.toml` है। यह उस रंग सेट को परिभाषित करती है जिसका उपयोग फिर terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt apps, keyboard backlight, input method, screen-share picker, app icons, कई AI tools (Claude, Pi, Hermes, T3 Code, Herdr), और पूरे Omarchy shell (top bar, menu, notifications, OSD, और lock screen) के लिए configurations बनाने में किया जाता है।

आप शामिल Aether application का उपयोग करके भी एक नई थीम बना सकते हैं, जिसमें रंगों के साथ खेलने और backgrounds खोजने के लिए एक सुंदर GUI interface मिलता है। बस इसे `Super + Alt + Space` पर app grid से शुरू करें।

### एक installed थीम में क्या हो सकता है

`~/.config/omarchy/themes` में आप खुद जो थीम लिखते हैं, उसमें जो चाहें रख सकते हैं — यह आपकी machine है और आपकी फ़ाइल है, और Omarchy वह सब लागू करता है।

किसी और के repo से `omarchy theme install` के साथ आप जो थीम install करते हैं, उसमें वह सब कुछ रहता है जो रंग है, और वे मुट्ठी भर फ़ाइलें हट जाती हैं जो आपकी machine पर code चलातीं: कोई भी `.lua` फ़ाइल, terminal configs (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), और `vscode.json`। किसी थीम की `hyprland.lua` वह Lua है जिसे आपका compositor login पर चलाता है, कोई terminal config उस program का नाम बताता है जिसे आपका terminal शुरू करता है, और `vscode.json` install किए जाने वाले किसी VSCode extension का नाम बताता है। किसी की थीम install करने से आपका desktop कैसा दिखता है यह बदलना चाहिए, यह कभी नहीं कि वह क्या चलाता है।

बाकी सब कुछ ठीक वैसा ही काम करता रहता है जैसा थीम के लेखक ने लिखा था — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, backgrounds और previews सभी रखे जाते हैं। केवल जो हटाया गया था वही आपकी machine पर `colors.toml` से फिर से बनाया जाता है।

Omarchy दोनों में अंतर इस बात से करता है कि थीम के अंदर उसका अपना git repo है या नहीं, जो वही है जो `omarchy theme install` clone करने पर पीछे छोड़ जाता है। तो जो थीम आपने लिखी वह आपकी रहती है, और जो आपने internet से ली वह केवल रंग रहती है।

### Light mode

अगर आप light mode थीम बना रहे हैं, तो अपनी `colors.toml` के शीर्ष पर `mode = "light"` सेट करें। फिर यह सभी apps के लिए अपने आप light mode के साथ जोड़ी जाएगी। (अपनी थीम की root में `light.mode` नाम की खाली फ़ाइल डालने का पुराना तरीका भी अभी काम करता है।)

### Boot और login screens

Boot पर drive password माँगने वाली screen, और login screen, Omarchy logo को आपकी थीम के `accent` रंग में उसके `background` पर बनाती हैं, जिसमें password field उसके `foreground` में और गलत password के लिए `red` होता है। उनके लिए कुछ अतिरिक्त भेजने की ज़रूरत नहीं है: Omarchy अब किसी थीम की `unlock.png` या `preview-unlock.png` का उपयोग नहीं करता। Apple Silicon Macs पर, drive password screen थीम चाहे जो हो Omarchy का default रूप ही रखती है।

### उन apps की थीमिंग जिन्हें Omarchy cover नहीं करता

अगर आप किसी ऐसे app का उपयोग करते हैं जो उस सूची में नहीं है, तो आप एक template के साथ Omarchy को खुद उसे थीम करना सिखा सकते हैं। `~/.config/omarchy/themed/` में एक फ़ाइल डालें जिसका नाम उस config के नाम पर हो जिसे यह बनाती है, साथ में एक `.tpl` extension हो, और config को `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` से लेकर `{{ color15 }}`, और palette के बाकी हिस्सों को placeholders के रूप में लिखकर लिखें। हर बार जब आप थीम बदलते हैं, फ़ाइल उस थीम के रंगों के साथ फिर से बनाई जाती है।

उस फ़ोल्डर में पूरी तरह comment की गई `alacritty.toml.tpl.sample` है जिससे कॉपी की जा सकती है — यह हर variable को सूचीबद्ध करती है जिसका आप उपयोग कर सकते हैं, साथ में उन apps के लिए `_strip` और `_rgb` modifiers भी, जो अपने रंगों को `#` के बिना या decimal RGB के रूप में चाहते हैं। आपके templates को Omarchy के अपने templates पर प्राथमिकता मिलती है, इसलिए आप इसका उपयोग यह override करने के लिए भी कर सकते हैं कि किसी built-in app को कैसे थीम किया जाए।

### अपनी थीम वितरित करना

अगर आप अपनी थीम वितरित करना चाहते हैं ताकि दूसरे इसका उपयोग कर सकें, तो आपको इसे किसी public git server, जैसे GitHub, पर रखना होगा। फिर लोग उस URL का उपयोग करके Omarchy menu में _Install > Style > Theme_ से इसे install कर सकते हैं। यह सलाह दी जाती है कि आप `omarchy-[themename]-theme` की नामकरण परंपरा का पालन करें, क्योंकि installation के बाद थीम चयन मेनू में थीम ठीक केवल `[themename]` के रूप में दिखाई देगी।

वह बचा हुआ `[themename]` थीम की directory का नाम बन जाता है, इसलिए यह ऐसा होना चाहिए जिसे Omarchy सुरक्षित रूप से इधर-उधर दे सके: यह किसी letter, digit, या underscore से शुरू होना चाहिए, और बाकी हिस्से में letters, digits, `.`, `_`, `+`, और `-` हो सकते हैं। Capitals आपके लिए lowercase कर दिए जाते हैं, लेकिन इसके अलावा कुछ भी — कोई space, कोई quote, कोई non-English character — directory नाम में बदलने के बजाय install के समय अस्वीकार कर दिया जाता है। इसलिए `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, और `omarchy-c++-theme` सभी ठीक से install हो जाते हैं।

याद रखें कि एक बार repo से install हो जाने के बाद, इसके साथ आने वाली कोई भी `.lua`, terminal config या `vscode.json` हटा दी जाती है, इसलिए थीम को उनके इर्द-गिर्द न बनाएँ।

आप [omarchy-site repo](https://github.com/omacom-io/omarchy-site) को एक pull request भेजकर अपनी थीम को [अतिरिक्त थीम पेज](https://omarchy.org/themes/) पर जुड़वा सकते हैं।
