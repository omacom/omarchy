# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) යනු GitHub Desktop වැනි යෙදුමකට ඇති ප්‍රියජනක විකල්පයක් වන අතර, එය terminal එක තුළ ක්‍රියාත්මක වේ.

ඔබට එය කෙලින්ම ක්‍රියාත්මක කළ හැකිය, git මගින් කළමනාකරණය වන ඕනෑම directory එකකට ගොස් `lazygit` ක්‍රියාත්මක කිරීමෙන්. නැතහොත් Neovim තුළ එය ක්‍රියාත්මක කළ හැකි අතර, එහිදී එය `Space G G` මගින් ආරම්භ කළ හැකිය.

විවිධ panes අතර මාරු වීමට ඔබ `Tab` භාවිතා කරයි. Files pane එකේ, staging සඳහා ගොනු තෝරන්නේ `Space` භාවිතයෙන් වන අතර, ඉන්පසු `c` භාවිතයෙන් ඔබට නව commit එකක් සෑදිය හැකිය. ලබා ගත හැකි සියලුම commands බැලීමට ඔබට `?` භාවිතා කළ හැකිය.

## Btop

[Btop](https://github.com/aristocratos/btop) යනු memory, CPU, disk, සහ network භාවිතය පෙන්වන අලංකාර resource manager එකකි. එය සියලුම සක්‍රිය processes ලැයිස්තුගත කරන අතර, ඒවා කළමනාකරණය කිරීමටද ඔබට ඉඩ සලසයි.

Omarchy එය Activity Monitor ලෙස හඳුන්වන අතර, ඔබ එය app launcher එකෙන් හෝ `Super + Shift + T` එබීමෙන් ආරම්භ කරයි. එය floating window එකක් ලෙස විවෘත වන අතර, `Super + T` මගින් ඔබට එය tile කළ හැකිය.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) යනු ඔබට workspaces, tabs, සහ panes ලබා දෙන terminal workspace manager එකක් වන අතර, ඒ සියල්ලම ඔබට වෙන් වී පසුව නැවත පැමිණිය හැකි persistent session එකක ක්‍රියාත්මකව තබා ගනී.

ඔබ එය ආරම්භ කරන්නේ (හෝ ඔබේ පවතින session එකට නැවත සම්බන්ධ වන්නේ) `Super + Ctrl + Return` මගිනි. Omarchy, එහි Tmux config එක පිළිබිඹු කරන Herdr configuration එකක් සමඟ එන බැවින්, මෙහිදීද prefix key එක `Ctrl + Space` වේ. `Super + Ctrl + K` මගින් ඔබට සියලුම keybindings බ්‍රවුස් කළ හැකිය.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) මගින් kernel version, uptime, theme, CPU, memory, සහ තවත් බොහෝ දේ වැනි system information පෙන්වයි. එය ජනප්‍රිය neofetch tool එකේ අනුප්‍රාප්තිකයෙකි.

Omarchy මෙය Omarchy menu එකේ (`Super + Space`) _About_ ලෙස ඇසුරුම් කර ඇත.

## Cliamp

[Cliamp](https://www.cliamp.stream/) යනු Winamp 2.x මගින් ආභාසය ලත් retro terminal music player එකක් වන අතර, lo-fi beats සඳහා built-in radio stations සමඟ සම්පූර්ණ වේ. `Super + Shift + Alt + M` මගින්, හෝ Omarchy menu එකේ _Apps_ යටතෙන් එය දියත් කරන්න. සම්පූර්ණ keybinding ලැයිස්තුව සඳහා `?` ඔබන්න.

## Wi-Fi සහ Bluetooth ගැන කුමක් කිව හැකිද?

ඔබට Wi-Fi සහ Bluetooth සඳහා TUIs සොයාගත නොහැකි වනු ඇත — එම කාර්යයන් අයත් වන්නේ Omarchy shell එකටය. networks බැලීමට සහ සම්බන්ධ වීමට ඉහළ තීරුවේ Wi-Fi icon එක ක්ලික් කරන්න (හෝ `Super + Ctrl + N` ඔබන්න), සහ devices යුගල කිරීමට සහ සම්බන්ධ කිරීමට Bluetooth icon එක ක්ලික් කරන්න (හෝ `Super + Ctrl + B` ඔබන්න). සම්පූර්ණ විස්තරය සඳහා [networking](35-networking.md) බලන්න.

## ඔබේම ඒවා එක් කිරීම

ඕනෑම terminal program එකකට සම්පූර්ණ app සැලකිල්ල ලබා ගත හැකිය. Omarchy menu එකේ (`Super + Space`) _Install > TUI_ වෙත ගොස්, එයට නමක්, launch command එකක්, window style එකක්, සහ icon එකක් ලබා දෙන්න, එවිට එය වෙනත් ඕනෑම application එකක් මෙන් app launcher එකේ දිස් වනු ඇත. _Remove > TUI_ යටතේ ඔබට එය නැවත ඉවත් කළ හැකිය.
