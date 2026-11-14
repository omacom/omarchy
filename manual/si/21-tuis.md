# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) යනු GitHub Desktop වැනි යෙදුමකට ප්‍රියජනක විකල්පයක් වන අතර, එය terminal එක තුළ ක්‍රියාත්මක වේ.

git මගින් කළමනාකරණය වන ඕනෑම directory එකකට ගොස් `lazygit` ධාවනය කිරීමෙන් ඔබට එය කෙලින්ම ධාවනය කළ හැකිය. නැතිනම් `Space G G` භාවිතයෙන් එය ආරම්භ කළ හැකි Neovim තුළ ඔබට එය ධාවනය කළ හැකිය.

ඔබ විවිධ panes අතර මාරු වන්නේ `Tab` භාවිතයෙනි. Files pane එක තුළ, staging සඳහා ගොනු තෝරා ගන්නේ `Space` භාවිතයෙන් වන අතර, ඉන්පසු `c` භාවිතයෙන් ඔබට නව commit එකක් සෑදිය හැකිය. `?` භාවිතයෙන් ඔබට ලබා ගත හැකි සියලුම commands දැක ගත හැකිය.

## Btop

[Btop](https://github.com/aristocratos/btop) යනු memory, CPU, disk සහ network භාවිතය පෙන්වන අලංකාර resource manager එකකි. එය සියලුම ක්‍රියාකාරී processes ලැයිස්තුගත කරන අතර, ඒවා කළමනාකරණය කිරීමටද ඔබට ඉඩ දෙයි.

Omarchy එය Activity ලෙස හඳුන්වන අතර, ඔබ එය ආරම්භ කරන්නේ `Super + Shift + T` එබීමෙනි. එය floating window එකක් ලෙස විවෘත වන අතර, `Super + T` භාවිතයෙන් ඔබට එය tile කළ හැකිය.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) යනු ඔබට workspaces, tabs සහ panes ලබා දෙන terminal workspace manager එකක් වන අතර, ඒවා සියල්ලම පසුව වෙන් වී නැවත පැමිණිය හැකි persistent session එකක ධාවනය කරමින් පවත්වා ගනියි.

ඔබ එය ආරම්භ කරන්නේ (හෝ ඔබගේ පවතින session එකට නැවත සම්බන්ධ වන්නේ) `Super + Ctrl + Return` භාවිතයෙනි. Omarchy එහි Tmux config එක පිළිබිඹු කරන Herdr configuration එකක් සමඟ එන බැවින්, මෙහිද prefix key එක `Ctrl + Space` වේ. `Super + Ctrl + K` භාවිතයෙන් ඔබට සියලුම keybindings බ්‍රවුස් කළ හැකිය.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) යනු kernel version, uptime, theme, CPU, memory සහ තවත් බොහෝ දේ වැනි system information පෙන්වයි. එය ජනප්‍රිය neofetch මෙවලමෙහි අනුප්‍රාප්තිකයා වේ.

Omarchy මෙය Omarchy menu එක තුළ (`Super + Space`) _About_ ලෙස ඇසුරුම් කර ඇත.

## Cliamp

[Cliamp](https://www.cliamp.stream/) යනු lo-fi beats සඳහාම වූ built-in radio stations සමඟ එන, Winamp 2.x මගින් ආභාෂය ලැබූ retro terminal music player එකකි. `Super + Shift + Alt + M` භාවිතයෙන්, නැතිනම් _Apps_ යටතේ Omarchy menu එකෙන් එය ආරම්භ කරන්න. සම්පූර්ණ keybinding ලැයිස්තුව සඳහා `?` ඔබන්න.

## Wi-Fi සහ Bluetooth ගැන කුමක් කිව හැකිද?

Wi-Fi සහ Bluetooth සඳහා TUIs ඔබට සොයා ගත නොහැකි වනු ඇත — එම කාර්යයන් අයත් වන්නේ Omarchy shell එකටය. networks බලා සම්බන්ධ වීමට ඉහළ තීරුවේ Wi-Fi icon එක click කරන්න (හෝ `Super + Ctrl + N` ඔබන්න), සහ devices යුගල කර සම්බන්ධ කිරීමට Bluetooth icon එක click කරන්න (හෝ `Super + Ctrl + B` ඔබන්න). සම්පූර්ණ කතාව සඳහා [ජාලකරණය](35-networking.md) බලන්න.

## ඔබගේම එකක් එකතු කිරීම

ඕනෑම terminal program එකකට සම්පූර්ණ app සැලකීම ලබා දිය හැකිය. Omarchy menu එක තුළ (`Super + Space`) _Install > TUI_ වෙත යන්න, එයට නමක්, launch command එකක්, window style එකක් සහ icon එකක් දෙන්න, එවිට එය අනෙක් ඕනෑම application එකක් මෙන් app launcher එක තුළ දිස් වනු ඇත. _Remove > TUI_ යටතේ ඔබට එය නැවත ඉවත් කළ හැකිය.
