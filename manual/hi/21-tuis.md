# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) GitHub Desktop जैसे किसी application का एक बेहद शानदार विकल्प है, और यह terminal के अंदर चलता है।

आप इसे सीधे चला सकते हैं, git द्वारा managed किसी भी directory में जाकर `lazygit` चलाकर। या आप इसे Neovim के अंदर चला सकते हैं, जहाँ इसे `Space G G` से शुरू किया जा सकता है।

आप `Tab` का उपयोग करके अलग-अलग panes के बीच घूमते हैं। Files pane में, आप `Space` का उपयोग करके staging के लिए files चुनते हैं, और फिर `c` का उपयोग करके एक नया commit बना सकते हैं। आप `?` का उपयोग करके उपलब्ध सभी commands देख सकते हैं।

## Btop

[Btop](https://github.com/aristocratos/btop) एक सुंदर resource manager है जो memory, CPU, disk और network का उपयोग दिखाता है। यह सभी active processes को भी सूचीबद्ध करता है, और आपको उन्हें manage करने देता है।

Omarchy इसे Activity Monitor कहता है, और आप इसे app launcher से या `Super + Shift + T` दबाकर शुरू करते हैं। यह एक floating window के रूप में खुलता है, जिसे आप `Super + T` से tile कर सकते हैं।

## Herdr

[Herdr](https://github.com/omacom-io/herdr) एक terminal workspace manager है जो आपको workspaces, tabs और panes देता है, और उन सभी को एक persistent session में चलता रखता है, जिससे आप detach होकर बाद में वापस आ सकते हैं।

आप इसे `Super + Ctrl + Return` से शुरू करते हैं (या अपने मौजूदा session से फिर से जुड़ते हैं)। Omarchy एक Herdr configuration के साथ आता है जो इसके Tmux config की तरह ही है, इसलिए यहाँ भी prefix key `Ctrl + Space` है। आप `Super + Ctrl + K` से सभी keybindings देख सकते हैं।

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) system की जानकारी दिखाता है, जैसे kernel version, uptime, theme, CPU, memory और भी बहुत कुछ। यह लोकप्रिय neofetch tool का उत्तराधिकारी है।

Omarchy ने इसे Omarchy menu (`Super + Space`) में _About_ के रूप में packaged किया है।

## Cliamp

[Cliamp](https://www.cliamp.stream/) Winamp 2.x से प्रेरित एक retro terminal music player है, lo-fi beats के लिए built-in radio stations के साथ पूरा। इसे `Super + Shift + Alt + M` से, या Omarchy menu में _Apps_ के अंतर्गत launch करें। पूरी keybinding सूची के लिए `?` दबाएँ।

## Wi-Fi और Bluetooth का क्या?

आपको Wi-Fi और Bluetooth के लिए TUIs नहीं मिलेंगे — वे काम Omarchy shell के हैं। Networks देखने और connect करने के लिए top bar में Wi-Fi icon पर click करें (या `Super + Ctrl + N` दबाएँ), और devices को pair और connect करने के लिए Bluetooth icon पर click करें (या `Super + Ctrl + B` दबाएँ)। पूरी जानकारी के लिए [नेटवर्किंग](35-networking.md) देखें।

## अपना खुद का जोड़ना

कोई भी terminal program पूरा app treatment पा सकता है। Omarchy menu (`Super + Space`) में _Install > TUI_ पर जाएँ, उसे एक नाम, एक launch command, एक window style और एक icon दें, और वह किसी भी अन्य application की तरह app launcher में दिखाई देगा। आप उसे _Remove > TUI_ के अंतर्गत फिर से हटा सकते हैं।
