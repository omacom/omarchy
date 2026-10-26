# Gaming

Omarchy केवल _pRoDUcTiVItY_ के लिए नहीं है, यह मज़े के लिए भी है, और गेमिंग से अधिक मज़ेदार क्या है? Omarchy गेमिंग विकल्पों के पूरे सूट के साथ आता है — नेटिव और रेट्रो खेल के लिए Steam और RetroArch, गैर-Steam स्टोर के लिए Battle.net, Lutris और Heroic, PC स्ट्रीमिंग के लिए Moonlight, क्लाउड के लिए Xbox Cloud Gaming + NVIDIA GeForce NOW, साथ ही सदाबहार Minecraft।

[proton संगतता परत](https://en.wikipedia.org/wiki/Proton_(software)) पर Valve के अविश्वसनीय कार्य के लिए धन्यवाद, अब Linux पर दसियों हज़ार खेलने योग्य आधुनिक गेम हैं। ओह, और क्या आप जानते थे कि [Steam Deck](https://store.steampowered.com/steamdeck/) वास्तव में Arch चलाता है!

सभी गेमिंग इंस्टॉलर Omarchy मेनू (`Super + Space`) में _Install > Gaming_ के अंतर्गत रहते हैं। अगर आप कभी किसी एक को पूर्ववत करना चाहें, तो _Remove > Gaming_ का उपयोग करें।

## Steam

Omarchy मेनू (`Super + Space`) से _Install > Gaming > Steam_ चुनकर [Steam](https://store.steampowered.com/) इंस्टॉल करें।

एक बार जब आप इसे इंस्टॉल कर लें, तो आप `Super + Space` से Steam लॉन्च कर पाएँगे।

ध्यान दें कि Steam को शुरू होने में 10-20 सेकंड लग सकते हैं, और यह कोई दृश्य प्रतिक्रिया नहीं देगा कि यह लोड हो रहा है।

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Omarchy मेनू (`Super + Space`) से _Install > Gaming > RetroArch_ चुनकर [RetroArch](https://www.retroarch.com/) इंस्टॉल करें। यह libretro कोर के पूर्ण समूह के साथ आता है, इसलिए सभी क्लासिक सिस्टम कवर हैं।

RetroArch उस परिपूर्ण रेट्रो लुक के लिए सुंदर CRT Royale शेडर के साथ पूरी तरह पूर्व-कॉन्फ़िगर है।

शुरू करने के लिए:

1. अपनी BIOS फ़ाइलें `~/Games/bios` में और अपने ROM `~/Games/roms` में डालें।
2. `Super + Space` से RetroArch लॉन्च करें और `retro` टाइप करें।
3. `~/Games/roms` डायरेक्टरी को स्कैन करें और आप खेलने के लिए तैयार हैं।

आप किसी पसंदीदा गेम को _Install > Gaming > RetroArch Game Launcher_ के साथ ऐप लॉन्चर में अपनी स्वयं की प्रविष्टि भी दे सकते हैं, जो आपको एक कोर और एक ROM चुनने देता है, और `Super + Space` से सीधे गेम में जाने देता है।

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Omarchy मेनू (`Super + Space`) से _Install > Gaming > Xbox Cloud Gaming_ चुनकर Xbox Cloud Gaming वेब ऐप इंस्टॉल करें। यह सेवा के लिए "बस" एक वेब ऐप है, लेकिन यह शुरू करने में त्वरित है और 1080p पर बेहतरीन चलता है।

अगर आपके पास पहले से Xbox Game Pass है, तो यह Fortnite और अन्य शीर्षक खेलने का एक ठोस तरीका है जिन्हें आप Linux पर नेटिव रूप से नहीं चला सकते।

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Omarchy मेनू (`Super + Space`) से _Install > Gaming > NVIDIA GeForce NOW_ चुनकर क्लाउड-गेमिंग सेवा [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) इंस्टॉल करें। Linux पर नेटिव रूप से उपलब्ध न होने वाले शीर्षक खेलने का एक और बेहतरीन तरीका।

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Omarchy मेनू (`Super + Space`) से _Install > Gaming > Minecraft_ चुनकर Minecraft इंस्टॉल करें।

Steam की तरह, ध्यान दें कि लॉग इन करने या शुरू करने के बाद अगली स्क्रीन दिखाई देने में थोड़ा समय लग सकता है, और प्रतीक्षा करते समय आपको कोई प्रतिक्रिया नहीं मिलेगी।

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Omarchy मेनू (`Super + Space`) से _Install > Gaming > Xbox Controllers_ चुनकर Bluetooth Xbox कंट्रोलर के लिए समर्थन इंस्टॉल करें। Bluetooth (`Super + Ctrl + B`) के माध्यम से कंट्रोलर जोड़ें और वे आपके सभी गेम में काम करेंगे। अगर आप अपने कंट्रोलर को USB-C केबल से बस हार्डवायर कर रहे हैं तो आपको इसकी आवश्यकता नहीं है।

## Moonlight (Game streaming from a PC)

[Moonlight client](https://github.com/moonlight-stream/moonlight-qt) Omarchy के साथ पहले से इंस्टॉल आता है, इसलिए आप [Sunshine](https://app.lizardbyte.dev/Sunshine/) चलाने वाले Windows PC से तुरंत गेम स्ट्रीम कर सकते हैं। `Super + Space` के माध्यम से Moonlight लॉन्च करें।

अगर आपकी Omarchy मशीन और दूरस्थ गेमिंग PC दोनों हार्डवायर हैं, तो अनुभव स्थानीय रूप से खेलने से अप्रभेद्य है। रिज़ॉल्यूशन को नेटिव तक बढ़ाएँ, रिफ़्रेश को 120Hz पर सेट करें, और बिटरेट को अधिकतम करें — यह Linux पर Fortnite जैसे प्रतिस्पर्धी शूटर खेलने का सबसे अच्छा तरीका है।

आप `omarchy install service sunshine` चलाकर Omarchy मशीन को होस्ट में भी बदल सकते हैं, जो Sunshine इंस्टॉल करता है और आपके LAN और Tailscale के लिए Moonlight स्ट्रीमिंग पोर्ट खोलता है।

## Battle.net

Omarchy मेनू (`Super + Space`) से _Install > Gaming > Battle.net_ चुनकर [Battle.net](https://eu.shop.battle.net/en-us) इंस्टॉल करें। यह आपको Diablo, Starcraft और World of Warcraft जैसे शीर्षक GE-Proton के अंतर्गत चलने वाले स्टैंडअलोन इंस्टॉल के रूप में देता है — Steam, Lutris या Heroic की आवश्यकता नहीं।

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows games)

Omarchy मेनू (`Super + Space`) से _Install > Gaming > Lutris_ चुनकर [Lutris](https://lutris.net/) इंस्टॉल करें। Lutris EA और Ubisoft Connect जैसे स्टोर से Windows गेम खेलने का तरीका है जिनका ऊपर अपना इंस्टॉलर नहीं है।

इंस्टॉलेशन थोड़ा अजीब है और कई बार ऐसा लगता है जैसे कुछ हो ही नहीं रहा — बस धैर्य रखें, यह पृष्ठभूमि में काम कर रहा है।

## Heroic Launcher (Epic Games)

Omarchy मेनू (`Super + Space`) से _Install > Gaming > Heroic (Epic Games)_ चुनकर [Heroic Launcher](https://heroicgameslauncher.com/) इंस्टॉल करें। Heroic आपको Epic Games शीर्षक चलाने देता है, जैसे OddSparks, जो एंटी-चीट पर निर्भर नहीं हैं — साथ ही GOG और Amazon Prime Gaming के गेम। दुख की बात है कि इसका मतलब है कोई Fortnite नहीं और कोई Rocket League नहीं — जब तक Tim Sweeney Linux पर नहीं आते, यह उतना ही करीब है जितना मिल सकता है।

Lutris की तरह, गेम इंस्टॉल करते समय यह धीमा और अजीब महसूस हो सकता है। इसे समय दें।
