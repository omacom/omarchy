# सुरक्षा

Omarchy सुरक्षा को अत्यंत गंभीरता से लेता है। यह एक ऐसा operating system है जिसका इस्तेमाल आप _Real World_ में _Real Work_ करने के लिए कर सकें। जहाँ laptop खो जाने से कोई सुरक्षा आपात स्थिति पैदा न हो। तो हम यह करते हैं:

1. *Full-disk encryption डिफ़ॉल्ट रूप से चालू रहता है*: यह आपके डेटा की भौतिक सुरक्षा का सबसे महत्वपूर्ण कदम है। अगर आपका computer खो जाता है या चोरी हो जाता है, तो डेटा मानक LUKS (Linux Unified Key Setup) का उपयोग करके पूरी तरह encrypted रहता है। Installer आपको throw-away machines के लिए इससे opt out करने देता है (देखें [शुरुआत करना](02-getting-started.md)); encryption के बिना किए गए install में यह सुरक्षा बिल्कुल नहीं होती, और drive जिसके भी हाथ में हो, वह उसे पढ़ सकता है।
2. *Firewall डिफ़ॉल्ट रूप से सक्षम रहता है*: सभी incoming traffic डिफ़ॉल्ट रूप से blocked रहता है, कुछ अपवादों के साथ: [LocalSend](https://localsend.org/) के लिए port 53317; Docker bridge address (172.17.0.1) पर computer के अपने resolver को की जाने वाली DNS queries, जिन्हें Docker अपने containers को देने वाली private address ranges से स्वीकार किया जाता है; और multicast DNS (port 5353), जो आपके network पर मौजूद printers और अन्य devices को एक-दूसरे को खोजने देता है और वहाँ आपके computer का नाम भी घोषित करता है। इनके ऊपर, firewall ping, आपके router से address प्राप्त करने (DHCP), और UPnP discovery के लिए UFW की मानक अनुमतियाँ बनाए रखता है। ssh भी तब तक बंद रहता है जब तक आप इसे _Setup > Security > SSHD_ के ज़रिए चालू न करें, जो आपकी SSH key को authorize करता है, password logins को बंद करता है, और उसके बाद ही port 22 खोलता है (brute force के विरुद्ध rate limited)। हम [ufw-docker](https://github.com/chaifeng/ufw-docker) setup का उपयोग करके Docker access को भी lock down करते हैं, ताकि आपके containers गलती से दुनिया के सामने exposed न हो जाएँ।
3. *Arch के पास हमेशा नवीनतम updates रहते हैं*: Arch, वह underlying distro जिस पर Omarchy बना है, एक rolling distribution है। इसका मतलब है कि किसी भी package में खोजी और patch की गई कोई भी सुरक्षा vulnerability `omarchy-update` का उपयोग करके install के लिए शीघ्र उपलब्ध हो जाती है। इस तरह आप हमेशा हर चीज़ के नवीनतम, सबसे सुरक्षित versions चला रहे होते हैं।
4. *Omarchy अपने स्वयं के packages और mirror बनाए रखता है*: Omarchy डिफ़ॉल्ट रूप से केवल Arch के अपने core/extra/multilib repositories (ARM machines पर Arch Linux ARM, साथ ही Apple Silicon पर Asahi ALARM) से मिले packages और अपने स्वयं के Omarchy Package Repository पर निर्भर रहता है। आप सीधे AUR से software install कर सकते हैं, लेकिन base install ऐसा नहीं करता — केवल कुछ optional installs, जैसे third-party browsers, ही AUR से लेते हैं।
5. *Cloudflare हमें DDoS से बचाता है*: Omarchy distribution infrastructure — ISOs, Omarchy packages, Arch mirror — Cloudflare के दुर्जेय DDoS shield के पीछे संरक्षित है और उनके CDN पर hosted है। यह बेहतरीन उपलब्धता प्रदान करता है।

## अपने पासवर्ड बदलना

किसी encrypted install पर आपके पास दो passwords होते हैं: एक जो boot के समय drive को unlock करता है, और दूसरा जिससे आप log in करते हैं और `sudo` का उपयोग करते हैं। Setup दोनों को एक जैसा बना देता है। दोनों को Omarchy menu में _Update > Password_ के अंतर्गत बदला जा सकता है — पहले के लिए _Drive Encryption_, दूसरे के लिए _User_। Drive password बदलने पर पहले वर्तमान password माँगा जाता है, इसलिए उसे तैयार रखें। अगर कोई बदलाव बीच में बाधित हो जाए, तो _Drive Encryption_ फिर से चलाएँ: यह वह password माँगता है जो अभी drive को unlock करता है और बदलाव को पूरा कर देता है।

## इस्तेमाल की जा चुकी मशीन को आगे देना

अगर आप अपनी मशीन किसी और को सौंप रहे हैं, तो आपको उसे reinstall करने की ज़रूरत नहीं है। Omarchy menu में _Remove > Factory Reset_ चलाएँ, पुष्टि करने के लिए `reset` type करें, पूछे जाने पर अपना drive encryption password डालें, और reboot करें। यह हर user account और `/home` में मौजूद हर चीज़ को मिटा देता है, installation के बाद आपके द्वारा जोड़े गए सभी packages और system changes को हटा देता है, और मशीन की पहचान साफ़ कर देता है — network connections, host keys, और सब कुछ। जो वापस आता है वह पहले boot का setup wizard होता है, जो अपने नए मालिक के लिए अपना नाम, password, और encryption password डालने के लिए तैयार रहता है।

यह installer द्वारा लिए गए baseline snapshot को restore करके काम करता है, इसलिए यह केवल Omarchy ISO से installed machines पर ही उपलब्ध है। और encryption के बिना वाली drive पर, reset एक secure erase के बजाय deletion होता है, इसलिए अगर डेटा संवेदनशील था, तो इसके बजाय fresh install करें।

## पासवर्ड-रहित sudo

कभी-कभी आप चाहते हैं कि `sudo` पूछना बंद कर दे, सबसे अक्सर तब जब कोई AI agent आपके लिए लंबे समय तक system work कर रहा हो। _Setup > Security > Passwordless Sudo_ पूछता है कि कितनी देर तक access की अनुमति देनी है: **15 मिनट**, **1 घंटा**, **1 दिन**, या **स्थायी रूप से**। जब access सक्रिय होता है, तो अन्य menu bar indicators के बगल में एक लाल चेतावनी icon दिखाई देता है। Access बंद करने के लिए उस पर click करें या command फिर से चलाएँ। आप `omarchy-sudo-passwordless 30` के साथ मिनटों की अपनी संख्या (1 से 1440 तक) भी दे सकते हैं, या `omarchy-sudo-passwordless permanent` का उपयोग कर सकते हैं।

Timed access स्वतः समाप्त हो जाता है, जिसमें deadline पार कर चुके suspend से resume होने के तुरंत बाद भी शामिल है। Computer को restart करने से यह समय से पहले समाप्त हो जाता है। Permanent access reboots के बाद भी बना रहता है और तब तक सक्षम रहता है जब तक आप उसे disable न कर दें।

Omarchy के settings package को update या remove करने से कोई भी temporary grant उसकी expiry support बदलने से पहले समाप्त हो जाता है। अगर command कोई authorization या cleanup error रिपोर्ट करता है, तो दूसरा grant सक्षम करने का प्रयास करने से पहले उसे हल करें; error का मतलब यह नहीं है कि passwordless access निष्क्रिय है।

इस बारे में आँखें खुली रखें: जब यह चालू होता है, तो आपके user के रूप में चलने वाली कोई भी चीज़ बिना पूछे root के रूप में कुछ भी कर सकती है। यही इसका पूरा उद्देश्य है, और यही इसका पूरा जोखिम भी है।

## Signing Keys

सभी ISO signatures और Omarchy repo package के लिए public key `40DFB630FF42BCFFB047046CF0134EE680CAC571` है ([openpgp.org पर सत्यापित करें](https://keys.openpgp.org/search?q=pkgs%40omarchy.org))। `omarchy/omarchy-keyring` package में भी यह मौजूद है और इसका उपयोग किसी भी संभावित updates को seamlessly rollout करने के लिए किया जाएगा।

आप किसी भी ISO release के लिए signature उसके URL में `.sig` जोड़कर पा सकते हैं, जैसे `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`।
