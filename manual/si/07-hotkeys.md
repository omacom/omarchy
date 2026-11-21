# හොට්කී

`Super + K` මඟින් ප්‍රධාන යතුරු බැඳීම් සියල්ලම දැකිය හැකිය (`Super + Alt + K` මඟින් Tmux බැඳීම් සහ `Super + Ctrl + K` මඟින් Herdr බැඳීම්).

## හොට්කී සකසා ඇති ආකාරය

සෑම හොට්කී එකක්ම එහි modifiers අනුව තීරණය වන තලයක පිහිටන අතර, සෑම තලයකටම එක් කාර්යයක් ඇත. හොට්කී එකිනෙකට පැටලීම වළක්වන්නේ එයයි, එමෙන්ම යමක් පිහිටන්නේ කොහේදැයි ඔබට සාමාන්‍යයෙන් අනුමාන කළ හැකි වන්නේද එයයි.

| තලය | එහි තිබෙන්නේ කුමක්ද | උදාහරණ |
| --- | --- | --- |
| `Super + key` | පද්ධතිය: කවුළු, වැඩතල, පිහිටුම් සහ මූලික මෙනු | `Super + Space` Omarchy මෙනුව, `Super + W` කවුළුව වසන්න, `Super + F` සම්පූර්ණ තිරය |
| `Super + Shift + key` | Apps | `Super + Shift + B` browser, `Super + Shift + E` email, `Super + Shift + N` editor |
| `Super + Ctrl + key` | පැනල සහ පද්ධති මෙනු | `Super + Ctrl + A` audio, `Super + Ctrl + N` network, `Super + Ctrl + C` capture මෙනුව |
| `Super + Ctrl + Alt + key` | ඉක්මන් ක්‍රියා සහ දැනුම්දීම් | `Super + Ctrl + Alt + T` වේලාව පෙන්වන්න, `Super + Ctrl + Alt + B` battery, `Super + Ctrl + Alt + C` screenshot |

හොට්කී එකකට `Alt` එක් කිරීමෙන් ඔබට ලැබෙන්නේ එම දේමෙහි ප්‍රභේදයක් මිස, කිසිසේත්ම සම්බන්ධ නැති දෙයක් නොවේ:

- `Super + Shift + B` මඟින් browser එක විවෘත වේ; `Super + Shift + Alt + B` මඟින් private කවුළුවක් විවෘත වේ
- `Super + Shift + E` මඟින් email විවෘත වේ; `Super + Shift + Alt + E` මඟින් අලුත් එකක් ආරම්භ වේ
- `Super + F` මඟින් සම්පූර්ණ තිරය වෙත යයි; `Super + Alt + F` මඟින් සම්පූර්ණ පළල වෙත යයි
- `Super + Ctrl + C` මඟින් capture මෙනුව විවෘත වේ; `Super + Ctrl + Alt + C` මඟින් මෙනුව මඟහැර screenshot එකක් ගනී

හොට්කී එකක් එක් කිරීමේදී:

1. එය කරන දෙය අනුව තලය තෝරන්න, ඉන්පසු යතුර තෝරන්න.
2. ඉඩ ලබා ගැනීම සඳහා පවතින හොට්කී එකක් ඉවත් නොකරන්න. නිවැරදි තලයේ නිදහස් යතුරක් සොයන්න.
3. `Alt` භාවිතා කරන්න එය නොමැති හොට්කී එකේ ප්‍රභේදයක් සඳහා පමණි.

හොට්කී කිහිපයක් පහසු බැවින් මෙම නීති කඩ කරයි. ඊතලයක් හෝ `Tab` සමඟ `Shift` යනු app එකක් විවෘත කිරීම වෙනුවට ගෙනයාම හෝ ආපසු හැරවීමයි, එමෙන්ම `Print`, media යතුරු, `Alt + Tab`, සහ `Ctrl + Alt + Del` අනෙකුත් සෑම තැනකම ක්‍රියා කරන ආකාරයටම ක්‍රියා කරයි. ඒවා ව්‍යතිරේකයන් මිස, අනුකරණය කළ යුතු රටා නොවේ.

පෙරනිමියක් ඔබට නොගැළපේ නම් (ඔබට Windows හි මෙන් screenshots සඳහා `Super + Shift + S` අවශ්‍ය යැයි සිතන්න), එය `~/.config/hypr/bindings.lua` හි නැවත බඳින්න.

## සංචාලනය

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Super + Space` | Omarchy මෙනුව (apps සහ අන් සියල්ල) |
| `Super + Alt + Space` | App ජාලකය |
| `Super + Escape` | පද්ධති මෙනුව (suspend, restart, ආදිය) |
| `Super + Ctrl + L` | පරිගණකය lock කරන්න |
| `Super + W` or `Super + Q` | කවුළුව වසන්න |
| `Ctrl + Alt + Del` | සියලු කවුළු වසන්න |
| `Super + K` | සියලු හොට්කී පෙන්වන්න |
| `Super + Alt + K` | tmux හොට්කී පෙන්වන්න |
| `Super + Ctrl + K` | herdr හොට්කී පෙන්වන්න |
| `Super + M` | කවුළුව dock එකට minimize කරන්න |
| `Super + T` | කවුළුව tiling/floating අතර toggle කරන්න |
| `Super + J` | කවුළු පිහිටීම toggle කරන්න (තිරස්/සිරස්) |
| `Super + O` | කවුළුව sticky'n'floating වෙත popping කිරීම toggle කරන්න |
| `Super + L` | dwindle, scrolling, සහ floating පිහිටුම් හරහා cycle කරන්න |
| `Super + Alt + L` | පිහිටුම් හරහා ආපසු cycle කරන්න |
| `Super + P` | pseudo කවුළු විලාසය toggle කරන්න (natural v stretch) |
| `Super + F` | සම්පූර්ණ තිරය වෙත යන්න |
| `Super + Alt + F` | සම්පූර්ණ පළල වෙත යන්න |
| `Super + Ctrl + F` | කවුළුව තුළ සම්පූර්ණ තිරය වෙත යන්න |
| `Super + 1…9/0` | අවධානය යොමු වූ මොනිටරයේ නිශ්චිත වැඩතලයට පනින්න (0 යනු 10) |
| `Super + Tab` | අවධානය යොමු වූ මොනිටරයේ ඊළඟ වැඩතලයට පනින්න |
| `Super + Shift + Tab` | අවධානය යොමු වූ මොනිටරයේ පෙර වැඩතලයට පනින්න |
| `Super + Ctrl + Tab` | අවධානය යොමු වූ මොනිටරයේ පෙර පැවති වැඩතලයට පනින්න |
| `Super + Shift + 1…9/0` | කවුළුව අවධානය යොමු වූ මොනිටරයේ වැඩතලයට ගෙන යන්න |
| `Super + Shift + Alt + 1…9/0` | පසුපස අනුගමනය නොකර කවුළුව අවධානය යොමු වූ මොනිටරයේ වැඩතලයට ගෙන යන්න |
| `Super + S` | සම්පූර්ණ scratchpad එක toggle කරන්න |
| `Super + Alt + S` | කවුළුව සම්පූර්ණ scratchpad එකට ගෙන යන්න |
| `Super + Grave` | Quake console එක toggle කරන්න |
| `Super + Shift + Grave` | කවුළුව Quake console එකට ගෙන යන්න |
| `Super + Shift + Ctrl + Arrows` | කවුළුව එම දිශාවේ ඇති මොනිටරයට ගෙන යන්න |
| `Super + Shift + Alt + Arrows` | වැඩතලය එම දිශාවේ ඇති මොනිටරයට ගෙන යන්න |
| `Super + Arrow` | ඊතලයේ දිශාවේ ඇති කවුළුව වෙත අවධානය ගෙන යන්න, තිරයේ කෙළවරේදී එම පැත්තේ මොනිටරයට හරවන්න |
| `Super + Shift + Arrow` | කවුළුව ඊතලයේ දිශාවේ ඇති තවත් කවුළුවක් සමඟ හුවමාරු කරන්න, එම පැත්තේ මොනිටරයේ ඇති එකක් ද ඇතුළුව |
| `Super + Minus` | කවුළුව වමට expand කරන්න |
| `Super + Equal` | කවුළුව වමට shrink කරන්න |
| `Super + Shift + Minus` | කවුළුව ඉහළට shrink කරන්න |
| `Super + Shift + Equal` | කවුළුව පහළට expand කරන්න |
| `Super + Alt + Minus/Equal` | කුඩා පියවරවලින් එම ප්‍රමාණය වෙනස් කිරීමම |
| `Super + Ctrl + Minus/Equal` | විශාල පියවරවලින් එම ප්‍රමාණය වෙනස් කිරීමම |
| `Super + Alt + Home` | කවුළු පළල සුරකින්න |
| `Super + Home` | සුරකින ලද කවුළු පළල restore කරන්න |
| `Super + Left Mouse` | කවුළුව වටා drag කරන්න |
| `Super + Right Mouse` | කවුළුව resize කරන්න |
| `Super + Scroll Wheel` | අවධානය යොමු වූ මොනිටරයේ වැඩතල හරහා scroll කරන්න |
| `Super + G` | කවුළු grouping එක toggle කරන්න |
| `Super + Alt + G` | කවුළුව grouping එකෙන් පිටතට ගෙන යන්න |
| `Super + Alt + Tab` | grouping එකේ කවුළු අතර cycle කරන්න |
| `Super + Alt + Shift + Tab` | grouping එකේ කවුළු අතර ආපස්සට cycle කරන්න |
| `Super + Alt + Scroll Wheel` | grouping එකේ කවුළු අතර cycle කරන්න |
| `Super + Alt + 1/2/3/4/5` | grouping එකේ නිශ්චිත කවුළුවට පනින්න |
| `Super + Alt + Arrow` | කවුළුව ඊතලයේ දිශාවට grouping එකට ගෙන යන්න, එම පැත්තේ මොනිටරයේ ඇති එකක් ද ඇතුළුව |
| `Super + Ctrl + Left/Right` | tiling කණ්ඩායමක් තුළ කවුළු අතර ගමන් කරන්න |
| `Super + Ctrl + Z` | තිරය මත zoom in කරන්න (වැඩි zoom සඳහා නැවත කරන්න) |
| `Super + Ctrl + Alt + Z` | තිරයෙන් සම්පූර්ණයෙන්ම zoom out කරන්න |
| `Super + /` | මොනිටර පරිමාණ විකල්ප හරහා ඉදිරියට පියවර තබන්න |
| `Super + Alt + /` | මොනිටර පරිමාණ විකල්ප හරහා ආපස්සට පියවර තබන්න |
| `Alt + Tab` | සක්‍රිය වැඩතලයේ කවුළු හරහා ඉදිරියට cycle කරන්න |
| `Alt + Shift + Tab` | සක්‍රිය වැඩතලයේ කවුළු හරහා ආපස්සට cycle කරන්න |
| `Ctrl + Alt + Tab` | මොනිටර හරහා අවධානය ඉදිරියට cycle කරන්න |
| `Ctrl + Alt + Shift + Tab` | මොනිටර හරහා අවධානය ආපස්සට cycle කරන්න |
| `Super + I` | ආදාන භාෂාව මාරු කරන්න (පිහිටුම් එකකට වැඩි ගණනක් හෝ ආදාන ක්‍රමයක් ඇති විට) |
| `Super + Shift + I` | ආදාන භාෂාව ආපසු මාරු කරන්න |

touchpad එකක, ඇඟිලි තුනේ සහ හතරේ swipes මඟින් වැඩතල මාරු කරයි, කවුළු ගෙන යයි, සහ මෙනුව සහ Quake console එක විවෘත කරයි; අභිනයන් සඳහා [යතුරු පුවරුව, මූසිකය සහ ට්‍රැක්පෑඩය](34-keyboard-mouse-trackpad.md) බලන්න.

Resize කෙටිමං, යතුරු පුවරුවේ මුද්‍රණය කර ඇති අක්ෂර නොසලකා, භෞතික යතුරු `code:20` සහ `code:21` (XKB `<AE11>` සහ `<AE12>`) භාවිතා කරයි. US යතුරු පුවරුවල මෙම යතුරු `-` සහ `=` වේ; ජපන් (JIS) යතුරු පුවරුවල ඒවා `-` සහ `^` වේ; ස්පාඤ්ඤ යතුරු පුවරුවල ඒවා `'` සහ `¡` වේ. JIS හි, `Super + ^` යනු `Super + Equal` වන අතර, `Super + Shift + -` (එය `=` type කරයි) යනු `Super + Shift + Minus` වේ.

## පද්ධති පාලන

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Super + Ctrl + A` | Audio පැනලය |
| `Super + Ctrl + B` | Bluetooth පැනලය |
| `Super + Ctrl + N` | Wifi/network පැනලය |
| `Super + Ctrl + D` | Display පැනලය |
| `Super + Ctrl + P` | Power පැනලය |
| `Super + Ctrl + X` | Agents පැනලය |
| `Super + Ctrl + Alt + X` | Local models පැනලය |
| `Super + Ctrl + Alt + D` | Calendar පැනලය |
| `Super + Ctrl + Alt + E` | World clock පැනලය |
| `Super + Ctrl + 1-9` | තත්ත්වය අනුව bar පැනලය toggle කරන්න |
| `Super + Ctrl + S` | Share මෙනුව (LocalSend හරහා) |
| `Super + Ctrl + C` | Capture පාලන (screenshot/-recording/picker) |
| `Super + Ctrl + O` | Toggle මෙනුව |
| `Super + Ctrl + H` | Hardware මෙනුව |
| `Super + Ctrl + E` | Emoji picker |
| `Super + Ctrl + .` | Media transcode කරන්න |
| `Super + Shift + Ctrl + A` | AI agent එකක් තෝරන්න |
| `Power` key | පද්ධති මෙනුව |
| `Super + Shift + Copilot` key | Omarchy මෙනුව |

## ගැලපීම්

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Shift + Brightness Up` | උපරිම තිර දීප්තිය |
| `Shift + Brightness Down` | අවම තිර දීප්තිය |
| `Alt + Brightness Up/Down` | නිරවද්‍ය 1% දීප්ති වෙනස්කම් |
| `Alt + Volume Up/Down` | නිරවද්‍ය 1% ශබ්ද වෙනස්කම් |
| `Keyboard Brightness Up/Down` | යතුරු පුවරු backlight දීප්තිමත්/අඳුරු කරන්න |
| `Keyboard Backlight` | යතුරු පුවරු backlight මට්ටම් cycle කරන්න |
| `Ctrl + Brightness Up/Down` | තමන්ගේම යතුරු නොමැති යතුරු පුවරුවල යතුරු පුවරු backlight දීප්තිමත්/අඳුරු කරන්න |
| `Mic Mute` | මයික්‍රෆෝනය mute කරන්න |
| `Shift + Mute` | Audio output මාරු කරන්න |
| `Touchpad Toggle` | touchpad එක සක්‍රිය හෝ අක්‍රිය කරන්න |
| `Display` key | වැඩතල පිහිටුම cycle කරන්න |
| `Alt + Play` | ඊළඟ track එක |
| `Alt + Shift + Play` | පෙර track එක |

## Apps දියත් කිරීම

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux terminal |
| `Super + Ctrl + Return` | Herdr (agent manager) |
| `Super + Shift + Return` or `Super + Shift + B` | Browser |
| `Super + Shift + Alt + B` | Browser (private/incognito) |
| `Super + Shift + F` | File manager |
| `Super + Shift + Alt + F` | terminal එකේ cwd හි File manager |
| `Super + Shift + M` | Music (Spotify) |
| `Super + Shift + Alt + M` | Music (cliamp) |
| `Super + Shift + /` | Password manager (1password) |
| `Super + Shift + Q` or `Calculator` key | Calculator (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, ස්ථාපනය කළ පසු) |
| `Super + Shift + T` | Activity (btop) |
| `Super + Shift + N` | Editor (Plain, හෝ ඔබ තෝරාගත් පෙරනිමිය) |
| `Super + Shift + C` | Calendar ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Email ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | New email ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Messenger (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Messenger (WhatsApp) |
| `Super + Shift + Ctrl + G` | Messenger (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Writing (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (new post) |
| `Super + Shift + Y` | YouTube |

`~/.config/hypr/bindings.lua` හි බැඳීම් වෙනස් කරන්න/එක් කරන්න.

## Universal clipboard

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Super + A` | `Ctrl + A` සඳහා සහය දක්වන apps හි සියල්ල තෝරන්න |
| `Super + C` | Copy |
| `Super + X` | Cut (terminal හි නොවේ) |
| `Super + V` | Paste |
| `Super + Ctrl + V` | Clipboard manager |

සාමාන්‍යයෙන් Linux හි, terminal හි copy'n'paste සඳහා `Ctrl + Shift + C/V` ද අනෙකුත් සෑම තැනකම එය කිරීමට `Ctrl + C/V` ද අවශ්‍ය වේ. මෙම Omarchy ඒකාබද්ධ clipboard හොට්කී සෑම තැනකම ක්‍රියා කරයි.

## Capture

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot (එකම ඡායාරූපය, Print Screen යතුරක් නොමැති යතුරු පුවරු සඳහා) |
| `Super + Ctrl + C` | Capture මෙනුව |
| `Alt + Print Screen` | Screenrecord |
| `Super + Shift + Ctrl + Alt + C` | මෙනුව මඟහැර audio නොමැතිව Screenrecord (නැවැත්වීමට නැවත ඔබන්න) |
| `Super + Print Screen` | Color picker |
| `Super + Ctrl + Print Screen` | පෙළ clipboard එකට extract කරන්න |
| `Super + Alt + [` | Record කිරීමේදී webcam overlay එක කුඩා කරන්න |
| `Super + Alt + ]` | Record කිරීමේදී webcam overlay එක විශාල කරන්න |
| `Alt + Shift + L` | webapp හෝ browser වෙතින් වත්මන් URL එක copy කරන්න |
| `Alt + Shift + D` | වත්මන් පිටුවේ video එක `~/Videos` වෙත download කරන්න |
| `Alt + Space` | Dictation ආරම්භ/නැවැත්වීම (අවශ්‍ය වේ _Setup > Defaults > Dictation_) |
| `Right Alt` | Dictate කිරීමට අල්ලාගෙන සිටින්න (අවශ්‍ය වේ _Setup > Defaults > Dictation_) |

screenrecordings සමඟ, හොට්කී එක මුලින්ම ඔබ කැමති audio කුමක්දැයි අසයි, ඉන්පසු recording ආරම්භ කරයි. නැවැත්වීමට එය නැවත ඔබන්න. විස්තර සඳහා [screenshots සහ recording](12-screenshots-recording.md) බලන්න.

සියලුම capture විකල්ප Omarchy මෙනුවේ (`Super + Space`) _Trigger > Capture_ යටතේද ප්‍රවේශ විය හැකිය.

## Notifications

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Super + ,` | නවතම notification මත ක්‍රියා කරන්න: එය විවෘත කරන්න හෝ එහි ඇති එකම button එක ඔබන්න, එහි තේරීම්වලින් තෝරන්න, හෝ කිසිවක් නැති විට එය dismiss කරන්න |
| `Super + Shift + ,` | සියලු notifications dismiss කරන්න |
| `Super + Ctrl + ,` | යතුරු පුවරුවෙන් notifications පාලනය කරන්න |
| `Super + Alt + ,` | නවතම notification එක dismiss කරන්න |
| `Super + Shift + Alt + ,` | Notification ඉතිහාසය විවෘත කරන්න |
| `Super + Ctrl + Alt + ,` | Notifications නිහඬ කිරීම toggle කරන්න |

## Style

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Super + Ctrl + T` | අලුත් theme එකක් තෝරන්න (`Super + Ctrl + Shift + Space` ද වේ) |
| `Super + Ctrl + W` | Theme background එක තෝරන්න (`Super + Ctrl + Space` ද වේ) |
| `Super + Backspace` | කවුළුවක් මත transparency toggle කරන්න |
| `Super + Ctrl + Backspace` | තනි-කවුළු square aspect toggle කරන්න |

අමතර background රූප `~/.config/omarchy/backgrounds/<theme name>` හි පිහිටයි. Omarchy මෙනුවේ _Install > Style > Background_ හරහාද තිබේ.

සියලුම style විකල්ප Omarchy මෙනුවේ (`Super + Space`) _Appearance_ යටතේද ප්‍රවේශ විය හැකිය.

## Toggles

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Super + Ctrl + I` | Idle විට locking toggle කරන්න |
| `Super + Ctrl + Delete` | Laptop display සක්‍රිය/අක්‍රිය toggle කරන්න |
| `Super + Ctrl + Alt + Delete` | Laptop display mirroring toggle කරන්න |
| `Super + Shift + Space` | Top bar එක toggle කරන්න |
| `Shift + Mute` | ඊළඟ audio output වෙත මාරු වන්න |
| `Shift + Play` | ඊළඟ media source වෙත මාරු වන්න |
| `Super + Shift + Backspace` | කවුළු gaps toggle කරන්න |
| `Super + Ctrl + Alt + F` | සම්පූර්ණ තිර desktop එක toggle කරන්න (top bar + window gaps) |

## Reminders

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Super + Ctrl + R` | Reminder එකක් සකසන්න |
| `Super + Ctrl + Alt + R` | සියලු reminders බලන්න |
| `Super + Ctrl + Shift + R` | සියලු reminders ඉවත් කරන්න |

## Notices

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Super + Ctrl + Alt + T` | වේලාව notification එකක් ලෙස පෙන්වන්න |
| `Super + Ctrl + Alt + B` | Battery එක notification එකක් ලෙස පෙන්වන්න |
| `Super + Ctrl + Alt + W` | කාලගුණය notification එකක් ලෙස toggle කරන්න |

## Tmux

prefix යතුර `Ctrl + Space` වේ (`Ctrl + B` ද ක්‍රියා කරයි). ඔබට මෙම බැඳීම් `~/.config/tmux/tmux.conf` හි වෙනස් කළ හැකිය.

### Panes

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Prefix + v` | Pane එක අසලින් බෙදන්න (සිරස්) |
| `Prefix + h` | Pane එක පහළින් බෙදන්න (තිරස්) |
| `Prefix + x` | Pane එක kill කරන්න |
| `Prefix + z` | Pane zoom toggle කරන්න (fullscreen) |
| `Alt + Enter` | Pane එක පහළින් බෙදන්න (prefix නැත) |
| `Alt + Shift + Enter` | Pane එක අසලින් බෙදන්න (prefix නැත) |
| `Alt + Escape` | Pane එක kill කරන්න (prefix නැත) |
| `Ctrl + Alt + Arrows` | Panes අතර ගමන් කරන්න |
| `Ctrl + Alt + Shift + Arrows` | Panes resize කරන්න |

### Windows

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Prefix + c` | New window |
| `Prefix + k` | Window එක kill කරන්න |
| `Prefix + r` | Window එක rename කරන්න |
| `Alt + 1-9` | නිශ්චිත window එකට යන්න |
| `Alt + Arrow Left/Right` | Windows අතර ගමන් කරන්න |
| `Alt + Shift + Arrow Left/Right` | Window එක වමට/දකුණට ගෙන යන්න |

### Sessions

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Prefix + C` | New session |
| `Prefix + K` | Session එක kill කරන්න |
| `Prefix + R` | Session එක rename කරන්න |
| `Prefix + N` | Next session |
| `Prefix + P` | Previous session |
| `Alt + Arrow Up/Down` | Sessions අතර ගමන් කරන්න |
| `Prefix + s` | Sessions ලැයිස්තුගත කරන්න |
| `Prefix + d` | Session එකෙන් detach වන්න |

### Copy mode (vi-style)

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Prefix + [` | Copy mode එකට ඇතුළු වන්න |
| `v` | තේරීම ආරම්භ කරන්න (copy mode හි) |
| `y` | තේරීම copy කරන්න (copy mode හි) |

### General

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Prefix + q` | Config reload කරන්න |
| `Prefix + ?` | Tmux keybindings පෙන්වන්න |
| `Prefix + :` | Command prompt |

### Tmux layout functions

මෙම functions Tmux session එකක් තුළ ධාවනය කළ යුතුය.

| Command | ක්‍රියාව |
| --- | --- |
| `tdl <ai> [<second_ai>]` | Editor, AI, සහ terminal සමඟ dev layout එකක් සාදන්න |
| `tdlm <ai> [<second_ai>]` | උපඩිරෙක්ටරියකට dev layout එකක් සාදන්න |
| `tsl <count> <command>` | බහු-pane swarm layout එකක් සාදන්න |

## Ghostty Terminal

Ghostty terminal එක Omarchy මෙනුව හරහා _Install > Terminal_ භාවිතයෙන් ස්ථාපනය කෙරේ.

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Ctrl + Shift + E` | පහළින් new split |
| `Ctrl + Shift + O` | අසලින් new split |
| `Ctrl + Alt + Arrows` | Splits අතර ගමන් කරන්න |
| `Super + Ctrl + Shift + Arrows` | Split එක පේළි 10කින් resize කරන්න |
| `Super + Ctrl + Shift + Alt + Arrows` | Split එක පේළි 100කින් resize කරන්න |
| `Ctrl + Shift + T` | New tab |
| `Ctrl + Shift + Arrows` | Tabs අතර ගමන් කරන්න |
| `Alt + Numbers` | නිශ්චිත tab එකට යන්න |
| `Shift + Pg Up/Down` | ඉතිහාසය scroll කරන්න |
| `Ctrl + Left mouse` | Link එක browser හි විවෘත කරන්න |

## File Manager

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Ctrl + L` | Path එකට යන්න |
| `Space` | File preview කරන්න (ඊතල මඟින් navigate කරයි) |
| `Alt + Up` | Parent folder එකට ඉහළට යන්න |

## Neovim (w/ lazyvim)

### Navigation

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `Space` | Command විකල්ප පෙන්වන්න |
| `Space Space` | Fuzzy search හරහා file විවෘත කරන්න |
| `Space E` | Sidebar එක toggle කරන්න |
| `Space G G` | Git controls පෙන්වන්න |
| `Space S G` | File අන්තර්ගතය සොයන්න |
| `Ctrl + W W` | Sidebar සහ editor අතර පනින්න |
| `Ctrl + Left/right arrow` | Sidebar එකේ ප්‍රමාණය වෙනස් කරන්න |
| `Shift + H` | වම් file tab එකට යන්න |
| `Shift + L` | දකුණු file tab එකට යන්න |
| `Space B D` | File tab එක වසන්න |

### While in sidebar

| හොට්කී | ක්‍රියාව |
| --- | --- |
| `A` | Parent dir හි new file එකක් එක් කරන්න |
| `Shift + A` | Parent dir හි new subdir එකක් එක් කරන්න |
| `D` | Highlight කළ file/dir මකන්න |
| `M` | Highlight කළ file/dir ගෙන යන්න |
| `R` | Highlight කළ file/dir rename කරන්න |
| `?` | සියලු commands සඳහා help පෙන්වන්න |

[LazyVim මඟින් වින්‍යාස කළ සියලුම Neovim හොට්කී බලන්න](https://www.lazyvim.org/keymaps).

## Quick Emojis

සම්පූර්ණ emoji picker එකක් පෙන්වීමට ඔබට `Super + Ctrl + E` භාවිතා කළ හැකිය, එය තේරීම clipboard එකට දමනු ඇත, නැතහොත් ඔබට මෙම quick access විකල්ප භාවිතා කළ හැකිය.

| හොට්කී | EM | ඉඟිය |
| --- | -- | --- |
| `Shift + CapsLock M S` | 😄 | සිනහව |
| `Shift + CapsLock M C` | 😂 | හැඬීම |
| `Shift + CapsLock M L` | 😍 | ආදරය |
| `Shift + CapsLock M V` | ✌️ | ජයග්‍රහණය |
| `Shift + CapsLock M H` | ❤️ | හදවත |
| `Shift + CapsLock M Y` | 👍 | ඔව් |
| `Shift + CapsLock M N` | 👎 | නැත |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | පැතුම |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | හාදුව |
| `Shift + CapsLock M E` | 🙄 | eyeroll |
| `Shift + CapsLock M I` | 😉 | wink |
| `Shift + CapsLock M P` | 🙏 | යාඥාව |
| `Shift + CapsLock M D` | 🤤 | drool |
| `Shift + CapsLock M M` | 💰 | මුදල් |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | toast |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | ආචාරය |
| `Shift + CapsLock M A` |💪 | අත |
| `Shift + CapsLock M B` |🤯 | blowing |

## Quick Completions

| හොට්කී | Completion |
| --- | --- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | ඔබේ නම (setup හි ඇතුළත් කළ පරිදි) |
| `Shift + CapsLock Space E` | ඔබේ email එක (setup හි ඇතුළත් කළ පරිදි) |

`~/.XCompose` සංස්කරණය කිරීමෙන් ඔබට ඔබේම තවත් එක් කළ හැකිය, ඉන්පසු වෙනස්කම් ලබා ගැනීම සඳහා terminal හි `omarchy restart xcompose` ධාවනය කරන්න.
