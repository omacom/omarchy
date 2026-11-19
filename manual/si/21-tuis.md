# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) යනු GitHub Desktop වැනි යෙදුමකට ආහ්ලාදජනක විකල්පයක් වන අතර, එය terminal එක තුළ ධාවනය වේ.

ඔබට එය සෘජුවම ධාවනය කළ හැකිය, git මගින් කළමනාකරණය වන ඕනෑම directory එකකට ගොස් `lazygit` ධාවනය කිරීමෙන්. නැතහොත් `Space G G` මගින් ආරම්භ කළ හැකි Neovim තුළ එය ධාවනය කළ හැකිය.

ඔබ විවිධ panes අතර මාරු වන්නේ `Tab` භාවිතා කරමිනි. Files pane එකේ, ඔබට `Space` භාවිතයෙන් staging සඳහා ගොනු තෝරන අතර, පසුව `c` භාවිතයෙන් නව commit එකක් සෑදිය හැකිය. `?` භාවිතයෙන් ඔබට ලැබෙන සියලුම commands දැකිය හැකිය.

## Btop

[Btop](https://github.com/aristocratos/btop) යනු memory, CPU, disk, සහ network භාවිතය පෙන්වන අලංකාර resource manager එකකි. එය සියලුම සක්‍රිය processes ද ලැයිස්තුගත කරන අතර, ඒවා කළමනාකරණය කිරීමට ඔබට ඉඩ දෙයි.

Omarchy එය Activity Monitor ලෙස හඳුන්වන අතර, ඔබට එය app launcher එකෙන් හෝ `Super + Shift + T` එබීමෙන් ආරම්භ කළ හැකිය. එය floating window එකක් ලෙස විවෘත වන අතර, එය ඔබට `Super + T` මගින් tile කළ හැකිය.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) යනු ඔබට workspaces, tabs, සහ panes ලබා දෙන terminal workspace manager එකක් වන අතර, ඔබට වෙන් වී පසුව නැවත පැමිණිය හැකි persistent session එකක ඒ සියල්ල ධාවනය වෙමින් තබා ගනී.

ඔබ එය ආරම්භ කරන්නේ (හෝ ඔබේ පවතින session එකට නැවත සම්බන්ධ වන්නේ) app launcher එකෙන් හෝ `Super + Ctrl + Return` මගිනි. Omarchy එහි Tmux config එක පිළිබිඹු කරන Herdr configuration එකක් සමග එන බැවින්, මෙහිද prefix key එක `Ctrl + Space` වේ. ඔබට `Super + Ctrl + K` මගින් සියලුම keybindings පිරික්සිය හැකිය.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) kernel version, uptime, theme, CPU, memory, සහ තවත් බොහෝ දේ වැනි system information පෙන්වයි. එය ජනප්‍රිය neofetch tool එකේ අනුප්‍රාප්තිකයා වේ.

Omarchy මෙය Omarchy menu එකේ (`Super + Space`) _System > About_ ලෙස ඇසුරුම් කර ඇත.

## Cliamp

[Cliamp](https://www.cliamp.stream/) යනු lo-fi beats සඳහා built-in radio stations සහිතවම එන, Winamp 2.x මගින් ආභාසය ලැබූ retro terminal music player එකකි. එය `Super + Shift + Alt + M` මගින් හෝ Omarchy menu එකේ _Apps_ යටතේ ආරම්භ කරන්න. සම්පූර්ණ keybinding ලැයිස්තුව සඳහා `?` ඔබන්න.

## Wi-Fi සහ Bluetooth ගැන කුමක් කිව හැකිද?

ඔබට Wi-Fi සහ Bluetooth සඳහා TUIs හමු නොවනු ඇත — එම කාර්යයන් අයත් වන්නේ Omarchy shell එකටය. networks බලා සම්බන්ධ වීමට ඉහළ bar එකේ Wi-Fi icon එක click කරන්න (හෝ `Super + Ctrl + N` ඔබන්න), සහ devices යුගල කර සම්බන්ධ කිරීමට Bluetooth icon එක click කරන්න (හෝ `Super + Ctrl + B` ඔබන්න). සම්පූර්ණ විස්තරය සඳහා [ජාලකරණය](35-networking.md) බලන්න.

## ඔබේම ඒවා එක් කිරීම

ඕනෑම terminal program එකකට සම්පූර්ණ app සැලකිල්ල ලබා ගත හැකිය. Omarchy menu එකේ (`Super + Space`) _Install > TUI_ වෙත යන්න, එයට name එකක්, launch command එකක්, window style එකක්, සහ icon එකක් දෙන්න, එය වෙනත් ඕනෑම application එකක් මෙන් app launcher එකේ දිස් වනු ඇත. ඔබට එය නැවත _Remove > TUI_ යටතේ ඉවත් කළ හැකිය.
