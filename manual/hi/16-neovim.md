# Neovim

[Neovim](https://neovim.io/) 1976 में Bill Joy द्वारा बनाए गए [vi एडिटर](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) का एक आधुनिक कार्यान्वयन है। यह एक मोडल एडिटर है जहाँ insert mode और command mode अलग-अलग होते हैं, और एक बार जब आप इसके अविश्वसनीय रूप से गहरे key command set का एक छोटा-सा हिस्सा भी सीख लेते हैं, तो यह किसी superpower से कम नहीं लगता। लेकिन इसे सीखना काफी मुश्किल भी है!

अगर आप vim-शैली की editing में बिल्कुल नए हैं, तो मैं आपको YouTube पर [ThePrimeagen की Vim As Your Editor series](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) देखने की सलाह देता हूँ। इससे आपको बुनियादी बातें सीखने को मिलेंगी। बस यह जान लीजिए कि ज़्यादा मिलते-जुलते mainstream editors के विपरीत, vim में बुनियादी महारत हासिल करने में आपको ज़्यादा समय लगेगा। लेकिन एक बार आप इसे सीख गए, तो इसका फ़ायदा भी उतना ही बड़ा होगा।

अब, Neovim को मूल रूप से असीमित रूप से configure किया जा सकता है। अगर आप सचमुच पागलपन की हद तक जाना चाहते हैं, तो आप शुरू से अपनी खुद की Neovim configuration बना सकते हैं। [Typecraft का Neovim को शुरू से setup करने पर एक बेहतरीन course](https://www.youtube.com/watch?v=zHTeCSVAFNY) है। और [ThePrimeagen का भी एक course है](https://www.youtube.com/watch?v=w7i4amO_zaE)।

लेकिन Omarchy एक संपूर्ण Neovim setup के साथ आता है — `omarchy-nvim` package — जिसे बड़े प्यार से इस तरह tune किया गया है कि यह out of the box जो कुछ भी संभव है, उसका सर्वश्रेष्ठ रूप दिखाए। आपको configuration की एक भी line लिखने की ज़रूरत नहीं! यह [LazyVim](https://www.lazyvim.org/) पर बना है, जो Neovim plugins और configurations का एक distribution है। यह कमाल का है।

## LazyVim की बुनियादी बातें

जैसा कि मैंने बताया, इस छोटे-से परिचय में मैं आपको vim नहीं सिखाने वाला, लेकिन मैं आपको LazyVim की कुछ बुनियादी बातें और इसमें इधर-उधर कैसे जाना है, यह दिखा सकता हूँ।

सबसे पहले, Neovim में leader key का विचार होता है। यह मूल रूप से सभी commands का प्रवेश द्वार है। LazyVim ने इसे `Space` पर set किया है। तो बस उसे दबाइए, एक second रुकिए, और आपको इस तरह inline समझाए गए ढेर सारे विकल्प दिखेंगे:

यहाँ कुछ बुनियादी commands हैं जिनका मैं हर समय इस्तेमाल करता हूँ:

- `Space Space` - वर्तमान directory में किसी भी file को fuzzy-find करें।
- `Space S G` - preview के साथ grep का उपयोग करके सभी files में खोजें।
- `Space E` - file tree को on/off करें।
- `Ctrl + W W` - file tree से editor तक और वापस जाएँ।
- `Shift + H` - खुले tabs (vim इन्हें buffers कहता है) के बीच बाईं ओर जाएँ।
- `Shift + L` - खुले tabs के बीच दाईं ओर जाएँ।
- `Space B D` - एक tab बंद करें।
- `Space B O` - वर्तमान tab को छोड़कर बाकी सभी tabs बंद करें।
- `Space G G` - वर्तमान directory से एक floating pane में LazyGit launch करें।
- `Space U W` - soft wrap को toggle करें।

जब आप file tree में हों (दिखाने के लिए `Space E`, वहाँ जाने के लिए `Ctrl + W W`), तो आप `a` से एक नई file या `A` से एक नई directory जोड़ सकते हैं। सभी commands देखने के लिए tree में रहते हुए `?` दबाएँ।

अगर आप बुनियादी vim भाषा सीखना चाहते हैं, तो मैंने [तीन-भाग वाले syntax](https://world.hey.com/dhh/wonderful-vi-a1d034d3) के बारे में और उन ज़बरदस्त combo moves को कैसे किया जाए, इस बारे में लिखा है!

आप सभी संभव commands [LazyVim Keymaps पेज](https://www.lazyvim.org/keymaps) पर देख सकते हैं।

## Neovim शुरू करना

`Super + Shift + N` आपके default editor को launch करता है, जो नई installations पर Plain होता है; इसके बजाय Neovim launch करने के लिए _Setup > Defaults > Editor_ में Neovim चुनें। लेकिन आमतौर पर इसे terminal से चलाना आसान होता है: उस directory में जाएँ जिसमें आप काम करना चाहते हैं और `n` type करें। `n`, `nvim` का alias है, जो default रूप से वर्तमान directory को खोलकर उपयोग करेगा। आप `n myfile.txt` के साथ कोई एक file खोल सकते हैं।

## sudo edits के लिए Neovim का उपयोग करना

अगर आपको ऐसी files edit करनी हैं जिन्हें आप केवल super user के रूप में बदल सकते हैं, तो `sudoedit /etc/sudoers.d/00-sudo-only-file` चलाएँ। यह आपके default editor को खोलता है, इसलिए अगर आप वहाँ अपने सभी plugins के साथ Neovim चाहते हैं, तो _Setup > Defaults > Editor_ में Neovim set करें।
