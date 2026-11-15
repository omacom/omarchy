# थीम्स

Omarchy बाईस खूबसूरत थीम्स के साथ आता है। आप Omarchy Menu (`Super + Space`) में _Appearance > Theme_ से उनके बीच चुन सकते हैं या `Super + Ctrl + T` का उपयोग करके सीधे थीम सेलेक्टर पर जा सकते हैं।

हर थीम डेस्कटॉप, टर्मिनल, neovim, एक्टिविटी स्क्रीन (btop), Chromium, और पूरे Omarchy शेल को स्टाइल करती है: टॉप बार, मेनू, नोटिफ़िकेशन, OSD, और लॉक स्क्रीन। (Obsidian के लिए, आपको ऐप के अंदर _Appearance > Themes_ से Omarchy थीम को मैन्युअल रूप से चुनना होगा)।

थीम्स के पास बैकग्राउंड इमेजेज़ का एक सेट होता है, जिनके बीच आप `Super + Ctrl + W` का उपयोग करके चुन सकते हैं।

आप [अतिरिक्त थीम्स वाले पेज](https://omarchy.org/themes/) पर और भी थीम्स पा सकते हैं या फिर [अपनी खुद की थीम भी बना सकते हैं](43-making-your-own-theme.md)।

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

### ऐप आइकन

ऐप लॉन्चर और डॉक में आइकन आपकी थीम के रंगों में बनाए जाते हैं, इसलिए वे थीम के साथ बदल जाते हैं। वे एक आइकन सेट से आते हैं, जिसे आप थीम से अलग _Appearance > Icons_ के तहत चुनते हैं:

- _Papercraft_ डिफ़ॉल्ट है: जो कुछ भी इंस्टॉल होकर आता है, सब एक ही शैली में बनाया गया है। अपने लोगो से पहचाने जाने वाले ऐप्स, जैसे Chrome, HEY, या YouTube, अपनी आकृति बनाए रखते हैं और थीम के रंग अपना लेते हैं।
- _Arcade_ उन्हीं ऐप्स को 8-bit पिक्सेल आर्ट के रूप में बनाता है, जैसे कोई पुराना गेम कंसोल बनाता।
- _Original_ हर ऐप को उस आइकन के साथ दिखाता है जो उसके निर्माता ने उसे दिया था।

आप _Install > Style > Icons_ (या `omarchy icons install <git url>`) से किसी और के बनाए हुए आइकन सेट को इंस्टॉल कर सकते हैं, और उसे _Remove > Icons_ के तहत फिर से हटा सकते हैं। _Update > Extra Icons_ आपके इंस्टॉल किए हुए सेट्स का नवीनतम संस्करण लाता है।

अपना खुद का सेट बनाने के लिए, अपने आइकन `~/.config/omarchy/icons/<name>/` में रखें, हर ऐप के लिए एक फ़ाइल, जिसका नाम ऐप की `.desktop` फ़ाइल की `Icon=` लाइन के नाम पर रखा गया हो। `.svg` पर समाप्त होने वाली फ़ाइल जैसी है वैसी ही दिखाई जाती है। `.svg.tpl` पर समाप्त होने वाली फ़ाइल थीम के रंगों में बनाई जाती है: जहाँ रंग आना हो वहाँ `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` या `{{ icon_shadow }}` लिखें। `/usr/share/omarchy/icons/papercraft/` में मौजूद डिफ़ॉल्ट सेट शुरुआत करने के लिए एक अच्छी जगह है। डिफ़ॉल्ट सेट के किसी एक आइकन को बदलने के लिए, उसका अपना संस्करण `~/.config/omarchy/icons/papercraft/` में रखें।

### अनलॉक

थीम्स में एक कस्टम अनलॉक डिज़ाइन भी हो सकता है, जिसका उपयोग बूट डिक्रिप्शन प्रक्रिया के लिए किया जाता है। आप इनमें से किसी एक को _Appearance > Unlock_ के तहत चुन सकते हैं। वे कुछ इस तरह दिखते हैं:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
