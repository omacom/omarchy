# Mac समर्थन

## Apple Silicon के लिए Omarchy

Apple Silicon के लिए Omarchy एक आधिकारिक Omacom समाधान है, जिसे पहली बार Omarchy 4.5 के साथ जारी किया गया था। यह macOS के साथ-साथ इंस्टॉल होता है, और जब आपका Mac शुरू होता है तो आप दोनों में से एक चुनते हैं।

Omarchy Mac के बारे में कोई सूचना मिली है? [Omarchy Mac से आना](#coming-from-omarchy-mac) पर जाएं।

यह इन Mac पर चलता है:

| Mac | चिप्स |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 और नए Mac अभी समर्थित नहीं हैं। M4 समर्थन edge channel पर परीक्षण में है और अगला आएगा। इंस्टॉलर कुछ भी बदलने से पहले आपके Mac की जांच करता है।

किसी भी Apple Silicon Mac पर, M4 और नए सहित, आप [Try Omarchy](https://github.com/omacom/try-omarchy) के साथ वर्चुअल मशीन में Omarchy चला सकते हैं।

### आपको क्या चाहिए

- macOS 15 Sequoia या बाद का संस्करण, और एक administrator खाता
- Omarchy के लिए खाली disk स्थान। इंस्टॉलर एक आकार सुझाता है और आपको इसे बदलने देता है।
- आपके Mac का backup, power, और एक internet कनेक्शन। इंस्टॉल कई gigabytes डाउनलोड करता है।

### इंस्टॉल करना

आप macOS से इंस्टॉल करते हैं। [Homebrew](https://brew.sh) के साथ Omarchy Installer इंस्टॉल करें:

```sh
brew install omacom/mac/omarchy
```

या सबसे नया Omarchy Installer इसके [रिलीज़ पेज](https://github.com/omacom/omarchy-mac-installer/releases) से डाउनलोड करें और इसे खोलें।

इंस्टॉलर आपके Mac की जांच करता है, आपको योजना दिखाता है, और macOS partition को छोटा करके Omarchy के लिए जगह बनाता है। macOS disk पर रहता है और किसी USB drive की आवश्यकता नहीं होती। जब पहला चरण पूरा हो जाता है, तो यह आपको macOS Recovery में सेटअप पूरा करने के बारे में बताता है: बंद करें, power button को तब तक दबाए रखें जब तक "Loading startup options" दिखाई न दे, Omarchy चुनें, और चरणों का पालन करें।

पहली बार boot होने पर, Omarchy एक password मांगता है जो इसकी disk को encrypt करता है। कोई recovery key नहीं है: यदि आप password भूल जाते हैं, तो आपकी Omarchy फ़ाइलें पुनर्प्राप्त नहीं की जा सकतीं।

बाद में Omarchy और macOS के बीच स्विच करने के लिए, बंद करें, फिर power button को तब तक दबाए रखें जब तक startup विकल्प दिखाई न दें और एक चुनें।

### Omarchy Mac से आना

Omarchy Mac अब Apple Silicon के लिए Omarchy का हिस्सा है, और हर Mac जिसने इसे चलाया वह समर्थित है। आपका वर्तमान इंस्टॉल चलता रहेगा, और इसके system packages अभी भी update होते रहेंगे, लेकिन इसे और Omarchy updates नहीं मिलेंगे। कोई समय सीमा नहीं है और कोई in-place upgrade नहीं है: आप backup लेते हैं, पुराना इंस्टॉल हटाते हैं, नया इंस्टॉल करते हैं, और restore करते हैं। चरण 2 से 5 macOS में होते हैं, इसलिए restart करने से पहले इस पेज को अपने phone पर खोल लें।

1. **Omarchy से, Mac से बाहर backup लें।** पुराना इंस्टॉल हटाने से यह मिट जाता है, और macOS Omarchy disk को नहीं पढ़ सकता। अपने home folder को किसी external drive या दूसरे computer पर copy करें, जिसमें SSH और GPG keys, browser profiles और unpushed work शामिल हों। `pacman -Qqe > ~/packages.txt` के साथ अपनी package list सहेजें। macOS का भी backup लें, क्योंकि हटाने और इंस्टॉल करने दोनों से ही इसकी disk का आकार बदलता है।
2. **अपना Mac macOS में शुरू करें।** बंद करें, power button को तब तक दबाए रखें जब तक startup विकल्प दिखाई न दें, और macOS चुनें।
3. **Omarchy Installer इंस्टॉल करें** जैसा [इंस्टॉल करना](#installing) में दिखाया गया है।
4. **पुराना इंस्टॉल हटाएं।** Omarchy Installer खोलें और Installation > Remove Omarchy चुनें। यह दिखाता है कि यह क्या delete करेगा और स्थान macOS को लौटा देता है। यदि यह आपके इंस्टॉल को नहीं पहचानता, तो यह disk बदले बिना रुक जाता है। हाथ से partitions delete करने के बजाय [Discord](https://discord.gg/tXFUdasqhY) में मदद मांगें, जिससे macOS मिट सकता है।
5. **इंस्टॉलर के साथ Apple Silicon के लिए Omarchy इंस्टॉल करें।**
6. **अपनी फ़ाइलें restore करें।** पूरे `~/.config` को नए defaults पर copy करने के बजाय अपनी settings को एक-एक करके वापस लाएं, क्योंकि पुरानी settings उन्हें override कर सकती हैं।

### जानना अच्छा रहेगा

- M1 और M2 MacBooks पर, ढक्कन खोलकर या power button दबाकर sleep से जगाएं।
- प्रश्न या समस्याएं: हमारे [Discord](https://discord.gg/tXFUdasqhY) में पूछें।

[इंस्टॉलर का README](https://github.com/omacom/omarchy-mac-installer#readme) release channels, इंस्टॉलर को update करने और Omarchy हटाने के बारे में बताता है।

## Intel Macs

एक साधारण परीक्षण में, हम केवल Omarchy इंस्टॉल करके 2019 MacBook Pro पर 36% प्रदर्शन लाभ प्राप्त करने में सक्षम थे।

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Mac पर Omarchy इंस्टॉल करना

Omarchy फिलहाल एकमात्र इंस्टॉल किया गया OS होने का ही समर्थन करता है। इंस्टॉलेशन के दौरान, drive मिटा दी जाएगी और MacOS अब bootable नहीं रहेगा।

यदि आप चाहें तो बाद में भी Internet Recovery के माध्यम से इसे restore कर सकते हैं।

इस भाग के लिए, हम मान लेंगे कि आपने पहले ही [शुरुआत करना](02-getting-started.md) देख लिया है और आपकी USB drive तैयार है। यदि नहीं है, तो आगे बढ़ें और अभी वह कर लें।

#### Secure Boot अक्षम करें

bootable USB, साथ ही OS को boot करने के लिए Apple के Secure Boot को अक्षम करना आवश्यक है। इसे अक्षम करने के लिए, निम्नलिखित करें:

1. अपना Mac बंद करें
2. इसे चालू करें और _तुरंत_ Command-R दबाकर रखें जब तक आपको loading screen दिखाई न दे
3. अपना user चुनें और संकेत मिलने पर अपना password दर्ज करें
4. recovery screen में आने के बाद, menubar से **Utilities > Startup Security Utility** चुनें
5. प्रमाणित करने के लिए संकेत मिलने पर अपना password दर्ज करें
6. Secure Boot विकल्पों में से "No Security" चुनें
7. External Boot विकल्पों में से "Allow booting from external or removable media" चुनें

#### इंस्टॉलेशन शुरू करें

1. USB drive डालें
2. अपना Mac restart करें और _तुरंत_ Option दबाकर रखें जब तक आपको boot devices की screen दिखाई न दे
3. नारंगी EFI Boot device चुनें
4. [सामान्य रूप से इंस्टॉल](02-getting-started.md) के साथ आगे बढ़ें

इंस्टॉलर Mac hardware का पता लगाता है और आवश्यक सुधार स्वचालित रूप से लागू करता है: Broadcom Wi-Fi drivers और firmware, Broadcom 1570 वाली मशीनों पर FaceTime HD camera driver (Mac के online होते ही इसका firmware Apple से डाउनलोड किया जाता है, क्योंकि इंस्टॉलर offline काम करता है), उन MacBook models पर SPI keyboard driver जिन्हें इसकी आवश्यकता होती है, और उन्हीं models के लिए एक NVMe suspend सुधार।

### ज्ञात सीमाएं

समुदाय के सदस्य इन चुनौतियों के समाधान पर लगातार काम कर रहे हैं, इसलिए यदि ये आपके लिए समस्याजनक हैं, तो हमारे [Discord](https://discord.gg/tXFUdasqhY) में #omarchy-on-other से जुड़ें और देखें कि इन्हें हल करने के कोई अद्यतन तरीके हैं या नहीं।

#### FaceTime HD Camera

Camera driver मशीन को hang कर देता है यदि Mac के hibernate होने पर यह loaded हो, इसलिए इसे पहले unload किया जाता है। जब किसी app ने camera खोल रखा हो तो इसे unload नहीं किया जा सकता, इसलिए hibernation एक notification के साथ रद्द कर दिया जाता है जिसमें app का नाम होता है: इसे बंद करें और फिर से hibernate करें। इसमें critical battery पर स्वचालित रूप से hibernate होना, और suspend-then-hibernate शामिल है, जिसे suspend होने से पहले ही अस्वीकार कर दिया जाता है। सामान्य suspend को driver स्वयं ही अस्वीकार कर देता है जब camera खुला हो, बिना किसी notification के।

Camera का firmware Apple से डाउनलोड किया जाता है, इसलिए camera तभी काम करता है जब Mac एक बार online हो चुका हो। डाउनलोड boot पर शुरू होता है और जब तक network समस्या है, हर 15 मिनट में फिर से प्रयास किया जाता है; यदि Apple की फ़ाइल बदल गई है, तो यह रुक जाता है और Omarchy update की प्रतीक्षा करता है। यदि camera दिखाई नहीं देता, तो `journalctl -u facetimehd-firmware-fetcher` बताता है कि क्यों, `sudo systemctl restart facetimehd-firmware-fetcher` फिर से प्रयास करता है, और यदि डाउनलोड पूरा हो गया है लेकिन camera अभी भी नहीं है, तो reboot driver को load करता है।

#### T1 Chip वाले Devices

Apple T1 chip को 2016 के अंत में पेश किया गया था और इसका उपयोग विशेष रूप से Touch Bar वाले पहली पीढ़ी के MacBook Pro models में किया गया था।
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### ज्ञात समस्याएं

- Touch Bar काम नहीं करता
- ध्वनि काम नहीं कर रही है

#### T2 Chip वाले Devices

Apple T2 Security Chip को 2017 में पेश किया गया था। 2020 से शुरू हुए Apple silicon (M-series chips) में परिवर्तन के साथ T2 chip को बंद कर दिया गया था।

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

इन models पर, इंस्टॉलर स्वचालित रूप से patched `linux-t2` kernel, T2 audio configuration, Apple का Broadcom Wi-Fi/Bluetooth firmware, और `t2fanrd` के माध्यम से fan control सेट अप करता है। Touch Bar kernel के अंतर्निहित Boot Camp-शैली समर्थन पर चलता है।

#### iMac Retina 5K (2017)

2017 के 27-inch iMac में कोई T2 chip नहीं है, इसलिए इंस्टॉलर इसे अन्य Intel Macs की तरह सेट अप करता है।

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### ज्ञात समस्याएं

- Display अपने मूल 5120×2880 पर नहीं चलता: panel दो tiles का है, और stock driver केवल एक को ही जलाता है
- ध्वनि काम नहीं कर रही है
- brightness control का कोई प्रभाव नहीं पड़ता
- Sleep मशीन को hang कर देता है; केवल power cycle ही इसे ठीक करता है

इस model के लिए एक community patcher display, ध्वनि और brightness को ठीक करता है: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3)।
