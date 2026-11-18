# गेमिंग

Omarchy सिर्फ़ _pRoDUcTiVItY_ के लिए नहीं है, यह मज़े के लिए भी है, और गेमिंग से ज़्यादा मज़ेदार क्या हो सकता है? Omarchy गेमिंग विकल्पों के पूरे सूट के साथ आता है — नेटिव और रेट्रो खेलने के लिए Steam और RetroArch, non-Steam स्टोर्स के लिए Battle.net, Lutris, और Heroic, PC स्ट्रीमिंग के लिए Moonlight, क्लाउड के लिए Xbox Cloud Gaming + NVIDIA GeForce NOW, साथ ही सदाबहार Minecraft।

Valve के [the proton compatibility layer](https://en.wikipedia.org/wiki/Proton_(software)) पर किए गए अविश्वसनीय काम की बदौलत, अब Linux पर हज़ारों की संख्या में आधुनिक गेम्स खेले जा सकते हैं। ओह, और क्या आप जानते थे कि [Steam Deck](https://store.steampowered.com/steamdeck/) असल में Arch चलाता है!

सभी गेमिंग इंस्टॉलर्स Omarchy मेनू (`Super + Space`) में _Install > Gaming_ के अंदर रहते हैं। अगर आप कभी किसी को हटाना चाहें, तो _Remove > Gaming_ का इस्तेमाल करें।

## Steam

Omarchy मेनू (`Super + Space`) से _Install > Gaming > Steam_ चुनकर [Steam](https://store.steampowered.com/) इंस्टॉल करें।

इसे इंस्टॉल करने के बाद, आप `Super + Space` से Steam लॉन्च कर पाएँगे।

ध्यान दें कि Steam को शुरू होने में 10-20 सेकंड लग सकते हैं, और यह कोई विज़ुअल फ़ीडबैक नहीं देगा कि यह लोड हो रहा है।

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Omarchy मेनू (`Super + Space`) से _Install > Gaming > RetroArch_ चुनकर [RetroArch](https://www.retroarch.com/) इंस्टॉल करें। यह libretro cores के पूरे सेट के साथ आता है, इसलिए सभी क्लासिक सिस्टम्स कवर हो जाते हैं।

RetroArch उस परफ़ेक्ट रेट्रो लुक के लिए खूबसूरत CRT Royale shader के साथ पूरी तरह प्रीकॉन्फ़िगर होकर आता है।

शुरू करने के लिए:

1. अपनी BIOS फ़ाइलें `~/Games/bios` में और अपने ROMs `~/Games/roms` में डालें।
2. `Super + Space` से RetroArch लॉन्च करें और `retro` टाइप करें।
3. `~/Games/roms` डायरेक्टरी को स्कैन करें और आप खेलने के लिए तैयार हैं।

आप _Install > Gaming > RetroArch Game Launcher_ के साथ किसी पसंदीदा गेम को ऐप लॉन्चर में उसकी अपनी एंट्री भी दे सकते हैं, जिससे आप एक core और एक ROM चुन सकते हैं, और `Super + Space` से सीधे गेम में कूद सकते हैं।

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Omarchy मेनू (`Super + Space`) से _Install > Gaming > Xbox Cloud Gaming_ चुनकर Xbox Cloud Gaming web app इंस्टॉल करें। यह सर्विस के लिए “बस” एक web app है, लेकिन यह जल्दी शुरू होता है और 1080p पर बढ़िया चलता है।

अगर आपके पास पहले से Xbox Game Pass है, तो यह Fortnite और अन्य ऐसे टाइटल्स खेलने का एक ठोस तरीका है जिन्हें आप Linux पर नेटिव रूप से नहीं चला सकते।

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Omarchy मेनू (`Super + Space`) से _Install > Gaming > NVIDIA GeForce NOW_ चुनकर क्लाउड-गेमिंग सर्विस [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) इंस्टॉल करें। उन टाइटल्स को खेलने का एक और बढ़िया तरीका जो Linux पर नेटिव रूप से उपलब्ध नहीं हैं।

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Omarchy मेनू (`Super + Space`) से _Install > Gaming > Minecraft_ चुनकर Minecraft इंस्टॉल करें।

Steam की तरह, ध्यान दें कि लॉग इन करने या शुरू करने के बाद अगली स्क्रीन आने में कुछ समय लग सकता है, और इंतज़ार करते समय आपको कोई फ़ीडबैक नहीं मिलेगा।

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Omarchy मेनू (`Super + Space`) से _Install > Gaming > Xbox Controllers_ चुनकर Bluetooth Xbox controllers के लिए सपोर्ट इंस्टॉल करें। Bluetooth (`Super + Ctrl + B`) के ज़रिए कंट्रोलर्स को पेयर करें और वे आपके सभी गेम्स में काम करेंगे। अगर आप बस अपने कंट्रोलर को USB-C केबल से जोड़ रहे हैं तो आपको इसकी ज़रूरत नहीं है।

## Moonlight (PC से गेम स्ट्रीमिंग)

Omarchy मेनू (`Super + Space`) से _Install > Gaming > Moonlight_ चुनकर [Moonlight client](https://github.com/moonlight-stream/moonlight-qt) इंस्टॉल करें, और आप [Sunshine](https://app.lizardbyte.dev/Sunshine/) चला रहे Windows PC से गेम्स स्ट्रीम कर सकते हैं।

अगर आपकी Omarchy मशीन और रिमोट गेमिंग PC दोनों हार्डवायर्ड हैं, तो अनुभव स्थानीय रूप से खेलने से अलग पहचानना मुश्किल है। रिज़ॉल्यूशन को नेटिव तक बढ़ाएँ, रिफ़्रेश को 120Hz पर सेट करें, और बिटरेट को अधिकतम करें — Linux पर Fortnite जैसे प्रतिस्पर्धी शूटर्स खेलने का यह सबसे अच्छा तरीका है।

आप `omarchy install service sunshine` चलाकर किसी Omarchy मशीन को होस्ट भी बना सकते हैं, जो Sunshine इंस्टॉल करता है और आपके LAN और Tailscale के लिए Moonlight स्ट्रीमिंग पोर्ट्स खोलता है।

## Battle.net

Omarchy मेनू (`Super + Space`) से _Install > Gaming > Battle.net_ चुनकर [Battle.net](https://eu.shop.battle.net/en-us) इंस्टॉल करें। यह आपको Diablo, Starcraft, और World of Warcraft जैसे टाइटल्स GE-Proton के तहत चलने वाले स्टैंडअलोन इंस्टॉल के रूप में देता है — किसी Steam, Lutris, या Heroic की ज़रूरत नहीं।

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows गेम्स)

Omarchy मेनू (`Super + Space`) से _Install > Gaming > Lutris_ चुनकर [Lutris](https://lutris.net/) इंस्टॉल करें। Lutris EA और Ubisoft Connect जैसे स्टोर्स से Windows गेम्स खेलने का तरीका है जिनके ऊपर अपना इंस्टॉलर नहीं है।

इंस्टॉलेशन थोड़ा अटपटा है और कई बार ऐसा लगता है जैसे कुछ हो ही नहीं रहा — बस धैर्य रखें, यह बैकग्राउंड में काम कर रहा है।

## Heroic Launcher (Epic Games)

Omarchy मेनू (`Super + Space`) से _Install > Gaming > Heroic (Epic Games)_ चुनकर [Heroic Launcher](https://heroicgameslauncher.com/) इंस्टॉल करें। Heroic आपको Epic Games टाइटल्स, जैसे OddSparks, चलाने देता है, जो anti-cheat पर निर्भर नहीं करते — साथ ही GOG और Amazon Prime Gaming के गेम्स भी। अफ़सोस की बात है, इसका मतलब है कोई Fortnite नहीं और कोई Rocket League नहीं — जब तक Tim Sweeney Linux पर नहीं आते, यही सबसे करीब है जो मिलेगा।

Lutris की तरह, गेम्स इंस्टॉल करते समय यह धीमा और अटपटा महसूस हो सकता है। इसे समय दें।
