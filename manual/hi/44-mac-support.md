# Mac support

Omarchy में **Intel Macs** के लिए बिल्ट-इन समर्थन है। फिलहाल कुछ ज्ञात सीमाएँ हैं, लेकिन जब तक आप जागरूक हैं और उनके साथ ठीक हैं; आप Omarchy लोड करके अपने पुराने Macs में कुछ नई जान फूँक सकते हैं।

कृपया ध्यान दें कि M-सीरीज़ Mac पर इंस्टॉल करना इस समय सीधे समर्थित नहीं है। आप हमारे [Discord](https://discord.gg/tXFUdasqhY) में #omarchy-on-other में इसकी स्थिति के बारे में अधिक जान सकते हैं।

एक साधारण परीक्षण में, हम सिर्फ़ Omarchy इंस्टॉल करके 2019 MacBook Pro पर 36% प्रदर्शन लाभ हासिल करने में सक्षम थे।

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Mac पर Omarchy इंस्टॉल करना

Omarchy फिलहाल केवल **एकमात्र** OS के रूप में इंस्टॉल होने का समर्थन करता है। इंस्टॉलेशन के दौरान, ड्राइव मिटा दी जाएगी और MacOS अब बूट करने योग्य नहीं रहेगा।

अगर आप चाहें तो बाद में Internet Recovery के ज़रिए इसे फिर भी बहाल कर सकते हैं।

इस हिस्से के लिए, हम मान लेंगे कि आपने पहले ही [Getting Started](02-getting-started.md) की समीक्षा कर ली है और आपकी USB ड्राइव तैयार है। अगर नहीं तो आगे बढ़ें और अभी ऐसा करें।

#### Secure Boot अक्षम करें

बूट करने योग्य USB, साथ ही OS को बूट करने के लिए Apple के Secure Boot को अक्षम करना आवश्यक है। इसे अक्षम करने के लिए, निम्नलिखित करें:

1. अपना Mac बंद करें
2. इसे चालू करें और लोडिंग स्क्रीन दिखाई देने तक _तुरंत_ Command-R दबाए रखें
3. अपना यूज़र चुनें और संकेत मिलने पर अपना पासवर्ड डालें
4. रिकवरी स्क्रीन में आने के बाद, मेनूबार से **Utilities > Startup Security Utility** चुनें
5. प्रमाणित करने के लिए संकेत मिलने पर अपना पासवर्ड डालें
6. Secure Boot विकल्पों में से "No Security" चुनें
7. External Boot विकल्पों में से "Allow booting from external or removable media" चुनें

#### इंस्टॉलेशन शुरू करें

1. USB ड्राइव डालें
2. अपना Mac रीस्टार्ट करें और बूट डिवाइसों की स्क्रीन दिखाई देने तक _तुरंत_ Option दबाए रखें
3. नारंगी EFI Boot डिवाइस चुनें
4. [सामान्य रूप से इंस्टॉल](02-getting-started.md) के साथ आगे बढ़ें

इंस्टॉलर Mac हार्डवेयर का पता लगाता है और आवश्यक सुधार स्वचालित रूप से लागू करता है: Broadcom Wi-Fi ड्राइवर और फ़र्मवेयर, उन MacBook मॉडलों पर SPI कीबोर्ड ड्राइवर जिन्हें इसकी आवश्यकता है, और उन्हीं मॉडलों के लिए एक NVMe सस्पेंड फ़िक्स।

### ज्ञात सीमाएँ

समुदाय के सदस्य इन चुनौतियों के समाधान पर लगातार काम कर रहे हैं इसलिए अगर ये आपके लिए समस्याग्रस्त हैं, तो हमारे [Discord](https://discord.gg/tXFUdasqhY) में #omarchy-on-other से जुड़ें और देखें कि क्या इन्हें हल करने के लिए कोई अप-टू-डेट तरीके हैं।

#### T1 Chip वाले डिवाइस

Apple T1 चिप 2016 के अंत में पेश की गई थी और Touch Bar वाले प्रथम-पीढ़ी के MacBook Pro मॉडलों में विशेष रूप से इस्तेमाल की गई थी।
- MacBook Pro 13-inch (2016, दो Thunderbolt 3 पोर्ट) – Model: A1706
- MacBook Pro 13-inch (2016, चार Thunderbolt 3 पोर्ट) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### ज्ञात समस्याएँ

- Touch Bar काम नहीं करता
- आवाज़ काम नहीं कर रही

#### T2 Chip वाले डिवाइस

Apple T2 Security Chip 2017 में पेश की गई थी। T2 चिप को 2020 से शुरू होने वाले Apple silicon (M-सीरीज़ चिप्स) में संक्रमण के साथ बंद कर दिया गया था।

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, चार Thunderbolt 3 पोर्ट) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, दो Thunderbolt 3 पोर्ट) – Model: A2159
- MacBook Pro 13-inch (2019, चार Thunderbolt 3 पोर्ट) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, दो Thunderbolt 3 पोर्ट) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

इन मॉडलों पर, इंस्टॉलर स्वचालित रूप से पैच किया गया `linux-t2` कर्नेल, T2 ऑडियो कॉन्फ़िगरेशन, Apple का Broadcom Wi-Fi/Bluetooth फ़र्मवेयर, और `t2fanrd` के ज़रिए पंखा नियंत्रण सेट अप करता है। Touch Bar कर्नेल के बिल्ट-इन Boot Camp-शैली समर्थन पर चलता है।
