# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) යනු GitHub Desktop වැනි යෙදුමකට ඇති ප්‍රියජනක විකල්පයක් වන අතර, එය terminal එක තුළ ධාවනය වේ.

ඔබට එය සෘජුවම ධාවනය කළ හැකිය, git මගින් කළමනාකරණය වන ඕනෑම directory එකකට ගොස් `lazygit` ධාවනය කිරීමෙන්. නැතහොත් එය Neovim තුළ ධාවනය කළ හැකි අතර, එහිදී එය `Space G G` මගින් ආරම්භ කළ හැකිය.

ඔබ `Tab` භාවිතයෙන් විවිධ panes අතර මාරු වේ. Files pane එකේ, ඔබ `Space` භාවිතයෙන් staging සඳහා ගොනු තෝරන අතර, පසුව `c` භාවිතයෙන් නව commit එකක් සෑදිය හැකිය. `?` භාවිතයෙන් ලබා ගත හැකි සියලුම commands ඔබට දැක ගත හැකිය.

## Btop

[Btop](https://github.com/aristocratos/btop) යනු මතකය, CPU, disk සහ ජාල භාවිතය පෙන්වන අලංකාර resource manager එකකි. එය සියලුම සක්‍රිය processes ලැයිස්තුගත කරන අතර, ඒවා කළමනාකරණය කිරීමටද ඔබට ඉඩ දෙයි.

Omarchy එය Activity Monitor ලෙස හඳුන්වන අතර, ඔබ එය app launcher එකෙන් හෝ `Super + Shift + T` එබීමෙන් ආරම්භ කරයි. එය floating window එකක් ලෙස විවෘත වන අතර, `Super + T` මගින් ඔබට එය tile කළ හැකිය.

## Herdr

[Herdr](https://herdr.dev) යනු ඔබට workspaces, tabs සහ panes ලබා දෙන terminal workspace manager එකක් වන අතර, ඒ සියල්ල ඔබට ඉවත් වී පසුව නැවත පැමිණිය හැකි persistent session එකක ධාවනය වෙමින් පවත්වා ගනියි.

ඔබ එය (හෝ ඔබේ පවතින session එකට නැවත සම්බන්ධ වීම) app launcher එකෙන් හෝ `Super + Ctrl + Return` මගින් ආරම්භ කරයි. Omarchy විසින් එහි Tmux config එක පිළිබිඹු කරන Herdr configuration එකක් සපයන බැවින්, මෙහිද prefix key එක `Ctrl + Space` වේ. `Super + Ctrl + K` මගින් ඔබට සියලුම keybindings බැලිය හැකිය.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) මගින් kernel version, uptime, theme, CPU, memory සහ තවත් බොහෝ දේ වැනි පද්ධති තොරතුරු පෙන්වයි. එය ජනප්‍රිය neofetch මෙවලමේ අනුප්‍රාප්තිකයා වේ.

Omarchy මෙනුවේ (`Super + Space`) Omarchy විසින් මෙය _පද්ධතිය > ගැන_ ලෙස ඇසුරුම් කර ඇත.

## Cliamp

[Cliamp](https://www.cliamp.stream/) යනු Winamp 2.x මගින් ආභාසය ලැබූ retro terminal music player එකක් වන අතර, lo-fi beats සඳහා built-in radio stations ද ඊට ඇතුළත් වේ. `Super + Shift + Alt + M` මගින්, හෝ Omarchy මෙනුවේ _යෙදුම්_ යටතේ සිට එය දියත් කරන්න. සම්පූර්ණ keybinding ලැයිස්තුව සඳහා `?` ඔබන්න.

## Wi-Fi සහ Bluetooth ගැන කුමක් කිව හැකිද?

Wi-Fi සහ Bluetooth සඳහා ඔබට TUIs සොයා ගත නොහැක — එම කාර්යයන් Omarchy shell එකට අයත් වේ. ජාල බැලීමට සහ සම්බන්ධ වීමට ඉහළ තීරුවේ Wi-Fi අයිකනය ක්ලික් කරන්න (හෝ `Super + Ctrl + N` ඔබන්න), උපාංග යුගල කිරීමට සහ සම්බන්ධ කිරීමට Bluetooth අයිකනය ක්ලික් කරන්න (හෝ `Super + Ctrl + B` ඔබන්න). සම්පූර්ණ විස්තරය සඳහා [ජාලකරණය](35-networking.md) බලන්න.

## ඔබේම ඒවා එක් කිරීම

ඕනෑම terminal program එකකට සම්පූර්ණ app සැලකිල්ල ලබා ගත හැකිය. Omarchy මෙනුවේ (`Super + Space`) _ස්ථාපනය > TUI_ වෙත යන්න, එයට නමක්, launch command එකක්, window style එකක් සහ අයිකනයක් දෙන්න, එවිට එය වෙනත් ඕනෑම application එකක් මෙන් app launcher එකේ දිස් වේ. _ඉවත් කරන්න > TUI_ යටතේ ඔබට එය නැවත ඉවත් කළ හැකිය.
