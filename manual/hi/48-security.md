# सुरक्षा

Omarchy सुरक्षा को बेहद गंभीरता से लेता है। यह एक ऐसा operating system बनने के लिए है जिसे आप _Real World_ में _Real Work_ करने के लिए इस्तेमाल कर सकें। जहाँ एक laptop खो जाने से सुरक्षा आपातकाल न बन जाए। तो यहाँ बताया गया है कि हम क्या करते हैं:

1. *Full-disk encryption डिफ़ॉल्ट रूप से चालू है*: यह आपके डेटा की भौतिक सुरक्षा सुनिश्चित करने का सबसे महत्वपूर्ण कदम है। यदि आपका कंप्यूटर खो जाता है या चोरी हो जाता है, तो डेटा मानक LUKS (Linux Unified Key Setup) का उपयोग करके पूरी तरह encrypted रहता है। installer आपको throw-away मशीनों के लिए इससे बाहर निकलने का विकल्प देता है (देखें [शुरुआत करना](02-getting-started.md)); encryption के बिना किए गए install में यह सुरक्षा बिल्कुल नहीं होती, और ड्राइव जिसके पास भी हो, वह उसे पढ़ सकता है।
2. *Firewall डिफ़ॉल्ट रूप से सक्षम है*: सभी incoming traffic डिफ़ॉल्ट रूप से blocked रहता है, कुछ अपवादों के साथ: [LocalSend](https://localsend.org/) के लिए port 53317; Docker bridge address (172.17.0.1) पर कंप्यूटर के अपने resolver को DNS queries, जो उन private address ranges से स्वीकार की जाती हैं जो Docker अपने containers को देता है; और multicast DNS (port 5353), जो आपके network पर printers और अन्य devices को एक-दूसरे को खोजने देता है और वहाँ आपके कंप्यूटर के नाम की घोषणा भी करता है। इनके अलावा, firewall ping, आपके router से address प्राप्त करने (DHCP), और UPnP discovery के लिए UFW की मानक अनुमतियों को बनाए रखता है। ssh भी तब तक बंद रहता है जब तक आप इसे _Setup > Security > SSHD_ के माध्यम से चालू नहीं करते, जो setup के हिस्से के रूप में port 22 खोलता है (brute force के विरुद्ध rate limited)। हम [ufw-docker](https://github.com/chaifeng/ufw-docker) setup का उपयोग करके Docker access को भी lockdown कर देते हैं ताकि आपके containers गलती से दुनिया के सामने exposed न हो जाएँ।
3. *Arch में हमेशा नवीनतम updates होते हैं*: Arch, वह underlying distro जिस पर Omarchy बना है, एक rolling distribution है। इसका मतलब है कि किसी भी package में खोजी और patch की गई कोई भी security vulnerability `omarchy-update` का उपयोग करके install के लिए जल्दी उपलब्ध हो जाती है। इस तरह आप हमेशा हर चीज़ के नवीनतम, सबसे सुरक्षित versions चला रहे होते हैं।
4. *Omarchy अपने स्वयं के packages और mirror बनाए रखता है*: Omarchy डिफ़ॉल्ट रूप से केवल Arch के अपने core/extra/multilib repositories और अपने स्वयं के Omarchy Package Repository के packages पर निर्भर करता है। आप सीधे AUR से software install कर सकते हैं, लेकिन base install ऐसा नहीं करता — केवल कुछ optional installs, जैसे third-party browsers, AUR से लेते हैं।
5. *Cloudflare हमें DDoS से बचाता है*: Omarchy distribution infrastructure — ISOs, Omarchy packages, Arch mirror — Cloudflare के दुर्जेय DDoS shield के पीछे सुरक्षित है और उनके CDN पर hosted है। यह बेहतरीन उपलब्धता प्रदान करता है।

## अपने passwords बदलना

एक encrypted install पर आपके पास दो passwords होते हैं: एक जो boot पर drive को unlock करता है, और एक जिससे आप log in करते हैं और `sudo` के साथ उपयोग करते हैं। Setup उन्हें एक ही बनाता है। दोनों को Omarchy menu में _Update > Password_ के तहत बदला जा सकता है — पहले के लिए _Drive Encryption_, दूसरे के लिए _User_। Drive password बदलने पर पहले वर्तमान password माँगा जाता है, इसलिए उसे तैयार रखें। यदि कोई बदलाव बीच में बाधित हो जाए, तो _Drive Encryption_ फिर से चलाएँ: यह वह password माँगता है जो अभी drive को unlock करता है और बदलाव पूरा करता है।

## पहले से उपयोग की गई मशीन किसी और को सौंपना

यदि आप अपनी मशीन किसी और को सौंप रहे हैं, तो आपको उसे reinstall करने की आवश्यकता नहीं है। Omarchy menu में _Setup > Reset Computer_ चलाएँ, पुष्टि करने के लिए `reset` type करें, और reboot करें। यह हर user account और `/home` में मौजूद हर चीज़ को मिटा देता है, installation के बाद से आपके द्वारा किए गए सभी packages और system changes को हटा देता है, और मशीन की पहचान साफ़ कर देता है — network connections, host keys, और सब कुछ। जो वापस आता है वह पहले boot का setup wizard होता है, जो अपने नए मालिक के लिए उनका अपना नाम, password, और encryption password दर्ज करने के लिए तैयार होता है।

यह installer द्वारा लिए गए baseline snapshot को restore करके काम करता है, इसलिए यह केवल Omarchy ISO से install की गई मशीनों पर उपलब्ध है। और encryption के बिना किसी drive पर, reset एक secure erase के बजाय deletion होता है, इसलिए यदि डेटा संवेदनशील था, तो इसके बजाय fresh install करें।

## बिना password वाला sudo

कभी-कभी आप चाहते हैं कि `sudo` पूछना बंद कर दे, सबसे अक्सर तब जब कोई AI agent आपके लिए लंबे समय तक system work कर रहा हो। _Setup > Security > Passwordless Sudo_ पूछता है कि कितने समय तक access की अनुमति देनी है: **15 मिनट**, **1 घंटा**, **1 दिन**, या **स्थायी रूप से**। जब तक access सक्रिय रहता है, अन्य menu bar indicators के बगल में एक लाल चेतावनी icon दिखाई देता है। access बंद करने के लिए उस पर click करें या command फिर से चलाएँ। आप `omarchy-sudo-passwordless 30` के साथ मिनटों की अपनी संख्या (1 से 1440 तक) भी दे सकते हैं, या `omarchy-sudo-passwordless permanent` का उपयोग कर सकते हैं।

समयबद्ध access स्वचालित रूप से समाप्त हो जाता है, जिसमें deadline पार कर चुके suspend से resume होने के तुरंत बाद भी शामिल है। कंप्यूटर को restart करने से यह समय से पहले समाप्त हो जाता है। स्थायी access reboots के बाद भी बना रहता है और तब तक सक्षम रहता है जब तक आप इसे disable नहीं करते।

Omarchy के settings package को update या remove करने से किसी भी temporary grant की expiry support बदलने से पहले वह समाप्त हो जाता है। यदि command कोई authorization या cleanup error रिपोर्ट करता है, तो कोई अन्य grant सक्षम करने का प्रयास करने से पहले उसे हल करें; error का मतलब यह नहीं है कि passwordless access निष्क्रिय है।

इस बारे में स्पष्ट दृष्टि रखें: जब तक यह चालू है, आपके user के रूप में चलने वाली कोई भी चीज़ बिना पूछे root के रूप में कुछ भी कर सकती है। यही इसका पूरा उद्देश्य है, और यही इसका पूरा जोखिम भी है।

## Signing कुंजियाँ

सभी ISO signatures और Omarchy repo package के लिए public key `40DFB630FF42BCFFB047046CF0134EE680CAC571` है ([openpgp.org पर सत्यापित करें](https://keys.openpgp.org/search?q=pkgs%40omarchy.org))। `omarchy/omarchy-keyring` package में भी यह शामिल है और इसका उपयोग किसी भी संभावित updates को निर्बाध रूप से rollout करने के लिए किया जाएगा।

आप किसी भी ISO release के लिए उसके URL में `.sig` जोड़कर signature पा सकते हैं, जैसे `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`।
