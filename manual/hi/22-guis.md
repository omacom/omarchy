# GUIs

## Files

Files (Folio) ग्राफ़िकल file manager है। `Super + Shift + F` इसे खोलता है, और `Super + Shift + Alt + F` इसे उस directory में खोलता है जिसमें आपका terminal बैठा है, जिससे बहुत सारा clicking बच जाता है। `Ctrl + L` आपको path लिखने देता है, और किसी भी file पर `Space` दबाने से वह उसे खोले बिना full size में preview हो जाती है।

USB stick या SD card लगाएँ और यह अपने आप mount हो जाता है, इसलिए यह बस sidebar में दिख जाता है। इससे ज़्यादा शामिल किसी काम के लिए — drive को format करना, SMART health जाँचना, partitions बनाना — app launcher (`Super + Space`) से _Disks_ launch करें।

Double-click करने पर sensible defaults काम करते हैं: pictures, videos, और music Omaview में खुलते हैं, PDFs Document Viewer में, Markdown Omawrite में, और plain text आपके editor में, Plain में, जब तक कि आप _Setup > Defaults > Editor_ के तहत कोई दूसरा न चुन लें।

## Disktree

जब drive भर जाए और आपको पता ही न हो कि इसे क्या खा रहा है, तो app launcher (`Super + Space`) से [Disktree](https://github.com/tobi/disktree) launch करें। यह आपकी home directory का ग्राफ़िकल treemap दिखाता है। बड़े blocks ज़्यादा जगह लेते हैं; keyboard या mouse से directories के अंदर जाएँ, जो जाना चाहिए उसे mark करें, और कुछ भी हटाने से पहले अपने selections की समीक्षा करें। पूरी disk को scan करने के लिए `disktree --disk` चलाएँ।

## Obsidian

[Obsidian](https://obsidian.md/) एक मुफ़्त और अत्यधिक extensible note लेने वाला application है जो storage के लिए सरल Markdown files का उपयोग करता है।

Obsidian सभी उद्देश्यों के लिए मुफ़्त है, जिनमें personal, commercial, और non-profit उपयोग शामिल हैं।

Obsidian iOS और Android पर mobile apps के साथ sync करने के लिए एक [commercial add-on](https://obsidian.md/sync) भी प्रदान करता है। (https://obsidian.md/pricing)।

आप Obsidian को `Super + Shift + O` से शुरू करते हैं। Theme syncing का उपयोग करने के लिए, आपको settings के तहत `Omarchy` theme चुनना होगा।

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) Omarchy का अपना बेहद सरल Markdown writing app है। कोई vaults नहीं, कोई plugins नहीं, बस आप और शब्द।

आप Omawrite को `Super + Shift + W` से शुरू करते हैं।

## Pinta

[Pinta](https://www.pinta-project.com/) एक बुनियादी image editing tool है जो cropping, resizing, और अन्य बुनियादी manipulations के लिए बहुत अच्छा है। बस Photoshop के विकल्प की उम्मीद न करें। लेकिन इसमें फिर भी Magic Wand और layers हैं!

आप Pinta को application launcher (`Super + Space`) के ज़रिए शुरू करते हैं।

## Aether

[Aether](https://github.com/bjarneo/aether) एक theming application है जो background image से colors निकाल सकता है और उन्हें एक पूर्ण, cohesive theme में बदल सकता है। यह [अपनी खुद की theme बनाने](43-making-your-own-theme.md) का सबसे आसान तरीका है।

आप Aether को application launcher (`Super + Space`) के ज़रिए शुरू करते हैं।

## LocalSend

[LocalSend](https://localsend.org/) आपको उसी network पर app चला रहे अन्य devices को files भेजने देता है, जैसे Apple's AirDrop। हालाँकि, यह cross-platform है, इसलिए आप Windows, macOS, Android, iOS, और निश्चित रूप से Linux से और उन पर files भेज सकते हैं।

आप Share menu को `Super + Ctrl + S` पर या Omarchy menu में _Trigger > Share_ के तहत खोल सकते हैं। यह आपको चार विकल्प देता है:

- **Clipboard** जो कुछ भी आपने copy किया है उसे text file के रूप में भेजता है। खुद को email किए बिना अपने phone पर कोई link या snippet पाने के लिए बढ़िया है।
- **File** एक file picker खोलता है जहाँ आप एक साथ कई चुन सकते हैं।
- **Folder** एक पूरी directory भेजता है।
- **Receive** LocalSend को ठीक से खोलता है ताकि कोई दूसरा device आपको कुछ भेज सके।

यही काम terminal से `omarchy share clipboard`, `omarchy share file [path]`, और `omarchy share folder [path]` के साथ भी होता है। Path छोड़ दें और आपको picker मिल जाता है।

आप file manager से भी सीधे भेज सकते हैं: Files में किसी भी selection पर right-click करें और उसे LocalSend के साथ share करें।

Omarchy का firewall LocalSend के port को छोड़कर डिफ़ॉल्ट रूप से बंद रहता है, इसलिए यह fresh install पर out of the box काम करता है। [सुरक्षा](48-security.md) देखें।

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) word processor, spreadsheet, presentations, drawing application, और भी बहुत कुछ के साथ एक पूर्ण office package है। यह Microsoft Office की files के साथ compatible है, इसलिए उन Word documents को खोल पाने का यह एक बढ़िया तरीका है।

आप LibreOffice को application launcher (`Super + Space`) के ज़रिए शुरू करते हैं।

## Hype

[Hype](https://github.com/omacom/hype) Omarchy का अपना बेहद सरल presentation app है। आपका deck एक ही Markdown file है जिसके images और videos उसके पास हैं: हर slide को live preview के नीचे लिखें, slides को क्रम में drag करें, फिर fullscreen present करें या PDF और PowerPoint में export करें। यह आपकी Omarchy theme को भी अपना लेता है।

आप Hype को application launcher (`Super + Space`) के ज़रिए शुरू करते हैं। हर shortcut देखने के लिए इसके अंदर `?` दबाएँ।

## Signed

[Signed](https://github.com/omacom/signed) PDFs पर sign करने और उन्हें भरने का Omarchy का अपना बेहद सरल तरीका है। अपने saved signature, text, और आज की date को किसी page पर कहीं भी रखें, फिर मूल के पास एक signed copy save करें। कैसे, इसके लिए [PDF भरना](27-filling-out-pdfs.md) देखें।

आप Signed को application launcher (`Super + Space`) के ज़रिए शुरू करते हैं, या file manager से कोई PDF इसके साथ खोलते हैं।

## Game Vibes

Game Vibes, application launcher (`Super + Space`) में, वह जगह है जहाँ Omarchy के छोटे games रहते हैं: Checkmate, किसी मित्र या built-in opponent के ख़िलाफ़ एक 3D chess game; Cards, Klondike solitaire; Death Wish, spikes और saws से भरे दस rooms का pixel-precise platformer; और Neon Swarm, एक arcade shooter। हर एक एक ही web page है जो आपकी theme का पालन करता है। Arrows और `Enter` से एक चुनें, और किसी game की title screen से `Esc` या उसके paused होने पर `Q` से list पर वापस आएँ। यह full screen खुलता है: `Super + F` इसे window बनाता है, और `Super + W` इसे बंद करता है।

किसी agent के साथ बनाए गए games भी यहाँ दिखते हैं: agents panel में _Make something cool → Game_ चुनें और किसी एक का वर्णन करें, या Game Vibes में पहले से मौजूद किसी game का नाम लेकर उस पर काम जारी रखें। Agent उसे `~/Games/vibes` में copy करता है, जहाँ वह बदलने के लिए आपका है, और काम पूरा होने पर उसे खोलता है। आप `omarchy games vibes copy <game>` के साथ वह copy खुद बना सकते हैं। किसी दूसरे द्वारा share किया गया game theme की तरह install होता है: _Install > Gaming > Game Vibes_ चुनें और उसका git address paste करें, या `omarchy games vibes install <git-repo-url>` चलाएँ। _Remove > Gaming_ किसी एक को फिर से हटाता है, और _Update > Game Vibes Games_ नए versions लाता है। Games web से three.js load करते हैं, इसलिए उन्हें शुरू होने के लिए connection चाहिए।

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) Omarchy का अपना बेहद सरल calculator है, जो floating window में खुलता है।

आप Omacalc को `Super + Shift + Q` से शुरू करते हैं (या calculator key से, यदि आपके keyboard में एक है)।

## Signal

[Signal](https://signal.org/) E2E encrypted messaging का अग्रणी है, और उन सभी के लिए एक बढ़िया communication विकल्प है जो किसी बड़ी tech conglomerate के ज़रिए न जाना पसंद करेंगे।

आप Signal को `Super + Shift + G` से शुरू करते हैं। यह base install का हिस्सा नहीं है, इसलिए पहली बार जब आप वह दबाएँगे, Omarchy आपके लिए इसे install करने का प्रस्ताव देगा (यह Omarchy menu में _Install > Service_ के तहत भी है)।

## Omaview

[Omaview](https://github.com/omacom/omaview) Omarchy का अपना बेहद सरल picture viewer और media player है: आपकी photos, videos, और music के लिए एक ही window। कोई photo खोलें और arrow keys उसके folder की बाकी चीज़ों में कदम-कदम आगे बढ़ती हैं, `N` और `P` किसी भी चीज़ के लिए यही करते हैं, और `Ctrl + M` पूरे folder को grid के रूप में दिखाता है। यह HEIC, AVIF, और JPEG XL photos भी दिखाता है, और किसी भी लंबी चीज़ में जहाँ आपने छोड़ा था वहीं से फिर शुरू होता है।

Fullscreen के लिए `F`, किसी picture को Omasnap में edit करने या किसी video को Omacut में trim करने के लिए `E`, किसी picture को print करने के लिए `Ctrl + P`, और किसी file को Trash में भेजने के लिए `Delete` दबाएँ (`Ctrl + Z` उसे वापस लाता है)। हर shortcut देखने के लिए इसके अंदर `?` दबाएँ।

आप Omaview को application launcher (`Super + Space`) के ज़रिए _Media Viewer_ के रूप में शुरू करते हैं, या बस file manager में किसी picture, video, या song पर double-click करते हैं।

## Omacut

[Omacut](https://github.com/omacom-io/omacut) Omarchy का अपना बेहद सरल video trimmer है। जब आपको बस किसी clip का शुरू और अंत काटना हो, तो यह पूरा video editor चलाने से बेहतर है।

आप Omacut को application launcher (`Super + Space`) के ज़रिए शुरू करते हैं।

## Monologue

[Monologue](https://github.com/omacom/monologue) Omarchy का अपना बेहद सरल webcam recorder है। अपना camera और microphone एक बार चुनें, फिर record करने के लिए `Space` दबाएँ, और उसी take को pause और resume करने के लिए फिर से दबाएँ। यह हमेशा आपके camera के उच्चतम resolution पर record करता है, live microphone meter के साथ ताकि आप शुरू करने से पहले अपने levels जाँच सकें।

Take रोकें और यह तुरंत built-in editor में खुल जाता है। किसी clip को split करने के लिए उस पर double-click करें, हर टुकड़े को trim करने के लिए handles को drag करें, और जो हिस्से आप नहीं चाहते उन्हें हटा दें। फिर उसे MP4 के रूप में save करें। आपकी मूल recording तब तक रखी जाती है जब तक आप उसे discard न करें, इसलिए आप हमेशा वापस आकर उसे अलग तरह से काट सकते हैं।

आप Monologue को application launcher (`Super + Space`) के ज़रिए शुरू करते हैं।
