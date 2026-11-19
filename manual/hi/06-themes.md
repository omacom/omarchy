# थीम

Omarchy बाईस खूबसूरत थीम के साथ आता है। आप Omarchy Menu (`Super + Space`) में _दिखावट > थीम_ के ज़रिए उनमें से चुन सकते हैं या `Super + Ctrl + T` का इस्तेमाल करके सीधे थीम चुनने वाले पर जा सकते हैं।

हर थीम डेस्कटॉप, टर्मिनल, neovim, गतिविधि स्क्रीन (btop), Chromium, और पूरे Omarchy शेल को स्टाइल करती है: टॉप बार, मेनू, सूचनाएँ, OSD, और लॉक स्क्रीन। (Obsidian के लिए, आपको ऐप के अंदर _दिखावट > थीम_ के ज़रिए Omarchy थीम को खुद चुनना होगा)।

थीम के पास पृष्ठभूमि छवियों का एक सेट होता है, जिन्हें आप `Super + Ctrl + W` का इस्तेमाल करके चुन सकते हैं।

आप [अतिरिक्त थीम पेज](https://omarchy.org/themes/) पर और भी थीम पा सकते हैं या [अपनी खुद की थीम भी बना सकते हैं](43-making-your-own-theme.md)।

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

ऐप लॉन्चर और डॉक में आइकन आपकी थीम के रंगों में बनाए जाते हैं, इसलिए वे इसके साथ बदल जाते हैं। वे एक आइकन सेट से आते हैं, जिसे आप थीम से अलग _दिखावट > आइकन_ के तहत, हर सेट के पूर्वावलोकन से चुनते हैं, ठीक उसी तरह जैसे आप थीम चुनते हैं:

- _Papercraft_ डिफ़ॉल्ट है: जो कुछ भी इंस्टॉल होकर आता है, सब एक ही शैली में बनाया गया है। अपने लोगो से पहचाने जाने वाले ऐप, जैसे Chrome, HEY, या YouTube, अपना आकार बनाए रखते हैं और थीम के रंग ले लेते हैं।
- _Arcade_ उन्हीं ऐप को 8-bit पिक्सेल आर्ट के रूप में बनाता है, जैसे कोई पुराना गेम कंसोल बनाता।
- _Original_ हर ऐप को उस आइकन के साथ दिखाता है जो उसके निर्माता ने उसे दिया था।

आप _इंस्टॉल > शैली > आइकन_ (या `omarchy icons install <git url>`) के साथ किसी और का बनाया हुआ आइकन सेट इंस्टॉल कर सकते हैं, और _हटाएँ > आइकन_ के तहत उसे फिर से हटा सकते हैं। _अपडेट > अतिरिक्त आइकन_ आपके इंस्टॉल किए गए सेट के नवीनतम संस्करण लाता है।

अपना खुद का बनाने के लिए, अपने आइकन `~/.config/omarchy/icons/<name>/` में रखें, हर ऐप के लिए एक फ़ाइल, जिसका नाम ऐप की `.desktop` फ़ाइल की `Icon=` पंक्ति के अनुसार रखा गया हो। `.svg` पर खत्म होने वाली फ़ाइल जैसी है वैसी ही दिखाई जाती है। `.svg.tpl` पर खत्म होने वाली फ़ाइल थीम के रंगों में बनाई जाती है: जहाँ रंग आता हो, वहाँ `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` या `{{ icon_shadow }}` लिखें। `/usr/share/omarchy/icons/papercraft/` में डिफ़ॉल्ट सेट शुरुआत करने के लिए अच्छी जगह है। चुनने वाले में अपना सेट दिखाने के लिए एक `preview.png` जोड़ें; इसके बिना, Omarchy आपके आइकन से एक पूर्वावलोकन बनाता है। डिफ़ॉल्ट सेट के किसी एक आइकन को बदलने के लिए, अपना संस्करण `~/.config/omarchy/icons/papercraft/` में रखें।

### अनलॉक

थीम में एक कस्टम अनलॉक डिज़ाइन भी हो सकता है, जिसका इस्तेमाल बूट डिक्रिप्शन प्रक्रिया के लिए किया जाता है। आप इनमें से एक को _दिखावट > अनलॉक_ के तहत चुन सकते हैं। वे ऐसे दिखते हैं:

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
