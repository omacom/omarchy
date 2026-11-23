# හොට්කී

ඔබට `Super + K` සමඟ සියලුම ප්‍රධාන යතුරුපුවරු බන්ධන දැකිය හැකිය (`Super + Alt + K` සමඟ Tmux බන්ධන සහ `Super + Ctrl + K` සමඟ Herdr බන්ධන).

## හොට්කී සකසා ඇති ආකාරය

සෑම හොට්කියක්ම තලයක පිහිටා ඇත, එය එහි modifiers මඟින් තීරණය වේ, සහ සෑම තලයකටම එක කාර්යයක් ඇත. එයයි හොට්කී එකිනෙකට නොගැටී තබා ගන්නේ, සහ සාමාන්‍යයෙන් යමක් කොතැනදැයි ඔබට අනුමාන කළ හැකි බව එයින් අදහස් වේ.

| තලය | එහි ඇති දේ | උදාහරණ |
| --- | --- | --- |
| `Super + key` | පද්ධතිය: කවුළු, workspaces, සැකැස්ම, සහ මූලික මෙනු | `Super + Space` Omarchy මෙනුව, `Super + W` කවුළුව වසන්න, `Super + F` සම්පූර්ණ තිරය |
| `Super + Shift + key` | යෙදුම් | `Super + Shift + B` බ්‍රවුසරය, `Super + Shift + E` විද්‍යුත් තැපෑල, `Super + Shift + N` සංස්කාරකය |
| `Super + Ctrl + key` | පැනල සහ පද්ධති මෙනු | `Super + Ctrl + A` ශ්‍රව්‍ය, `Super + Ctrl + N` ජාලය, `Super + Ctrl + C` ග්‍රහණ මෙනුව |
| `Super + Ctrl + Alt + key` | ඉක්මන් ක්‍රියා සහ නිවේදන | `Super + Ctrl + Alt + T` වේලාව පෙන්වන්න, `Super + Ctrl + Alt + B` බැටරිය, `Super + Ctrl + Alt + C` තිර දසුන |

හොට්කියකට `Alt` එකතු කිරීමෙන් ඔබට ලැබෙන්නේ එම දේමෙහි ප්‍රභේදයක් මිස, සම්බන්ධයක් නැති දෙයක් කිසිවිටෙක නොවේ:

- `Super + Shift + B` බ්‍රවුසරය විවෘත කරයි; `Super + Shift + Alt + B` පෞද්ගලික කවුළුවක් විවෘත කරයි
- `Super + Shift + E` විද්‍යුත් තැපෑල විවෘත කරයි; `Super + Shift + Alt + E` නව එකක් ආරම්භ කරයි
- `Super + F` සම්පූර්ණ තිරයට යයි; `Super + Alt + F` සම්පූර්ණ පළලට යයි
- `Super + Ctrl + C` ග්‍රහණ මෙනුව විවෘත කරයි; `Super + Ctrl + Alt + C` මෙනුව මඟ හැර තිර දසුනක් ගනී

හොට්කියක් එකතු කරන විට:

1. එය කරන දේ අනුව තලය තෝරන්න, පසුව යතුර තෝරන්න.
2. ඉඩ ලබා ගැනීමට පවතින හොට්කියක් ගෙන නොයන්න. නිවැරදි තලයේ නිදහස් යතුරක් සොයන්න.
3. `Alt` භාවිතා කරන්න එය නොමැති හොට්කියේ ප්‍රභේදයක් සඳහා පමණි.

හොට්කී කිහිපයක් මෙම නීති කඩ කරන්නේ ඒවා පහසු නිසාය. ඊතලයක් හෝ `Tab` සමඟ `Shift` යෙදුමක් විවෘත කරනවා වෙනුවට ගෙන යයි හෝ ආපසු හරවයි, සහ `Print`, මාධ්‍ය යතුරු, `Alt + Tab`, සහ `Ctrl + Alt + Del` අනෙක් සෑම තැනකම මෙන්ම ක්‍රියා කරයි. ඒවා ව්‍යතිරේක මිස, පිටපත් කළ යුතු රටා නොවේ.

පෙරනිමියක් ඔබට නොගැලපේ නම් (Windows වල මෙන් තිර දසුන් සඳහා ඔබට `Super + Shift + S` අවශ්‍ය යැයි සිතමු), එය `~/.config/hypr/bindings.lua` තුළ නැවත බඳින්න.

## සැරිසැරීම

| හොට්කිය | කාර්යය |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy මෙනුව (යෙදුම් සහ අනෙක් සියල්ල) |
| `Super + Alt + Space` | යෙදුම් ජාලකය |
| `Super + Escape` | පද්ධති මෙනුව (අත්හිටුවීම, නැවත ආරම්භ කිරීම, ආදිය) |
| `Super + Ctrl + L` | පරිගණකය අගුළු දමන්න |
| `Super + W` හෝ `Super + Q` | කවුළුව වසන්න |
| `Ctrl + Alt + Del` | සියලුම කවුළු වසන්න |
| `Super + K` | සියලුම හොට්කී පෙන්වන්න |
| `Super + Alt + K` | tmux හොට්කී පෙන්වන්න |
| `Super + Ctrl + K` | herdr හොට්කී පෙන්වන්න |
| `Super + M` | කවුළුව dock එකට අවම කරන්න |
| `Super + T` | කවුළුව tiling/floating අතර මාරු කරන්න |
| `Super + J` | කවුළු පිහිටීම මාරු කරන්න (තිරස්/සිරස්) |
| `Super + O` | කවුළුව sticky'n'floating බවට පිපිරවීම මාරු කරන්න |
| `Super + L` | dwindle, scrolling, සහ floating සැකැස්ම හරහා චක්‍රීයව යන්න |
| `Super + Alt + L` | සැකැස්ම හරහා ප්‍රතිලෝමව චක්‍රීයව යන්න |
| `Super + P` | pseudo කවුළු විලාසය මාරු කරන්න (natural v stretch) |
| `Super + F` | සම්පූර්ණ තිරයට යන්න |
| `Super + Alt + F` | සම්පූර්ණ පළලට යන්න |
| `Super + Ctrl + F` | කවුළුව තුළ සම්පූර්ණ තිරයට යන්න |
| `Super + 1…9/0` | අවධානය යොමු වූ monitor එකේ නිශ්චිත workspace එකට පනින්න (0 යනු 10 යි) |
| `Super + Tab` | අවධානය යොමු වූ monitor එකේ ඊළඟ workspace එකට පනින්න |
| `Super + Shift + Tab` | අවධානය යොමු වූ monitor එකේ පෙර workspace එකට පනින්න |
| `Super + Ctrl + Tab` | අවධානය යොමු වූ monitor එකේ පෙර පැවති workspace එකට පනින්න |
| `Super + Shift + 1…9/0` | අවධානය යොමු වූ monitor එකේ workspace එකට කවුළුව ගෙන යන්න |
| `Super + Shift + Alt + 1…9/0` | අනුගමනය නොකර අවධානය යොමු වූ monitor එකේ workspace එකට කවුළුව ගෙන යන්න |
| `Super + S` | සම්පූර්ණ scratchpad එක මාරු කරන්න |
| `Super + Alt + S` | කවුළුව සම්පූර්ණ scratchpad එකට ගෙන යන්න |
| `Super + Grave` | Quake console එක මාරු කරන්න |
| `Super + Shift + Grave` | කවුළුව Quake console එකට ගෙන යන්න |
| `Super + Shift + Ctrl + Arrows` | එම දිශාවේ ඇති monitor එකට කවුළුව ගෙන යන්න |
| `Super + Shift + Alt + Arrows` | එම දිශාවේ ඇති monitor එකට workspace එක ගෙන යන්න |
| `Super + Arrow` | ඊතලයේ දිශාවේ ඇති කවුළුවට අවධානය ගෙන යන්න, තිරයේ කෙළවරේදී එම පැත්තේ ඇති monitor එකට තරණය කරමින් |
| `Super + Shift + Arrow` | ඊතලයේ දිශාවේ ඇති වෙනත් කවුළුවක් සමඟ කවුළුව හුවමාරු කරන්න, එම පැත්තේ ඇති monitor එකේ එකක් ද ඇතුළුව |
| `Super + Minus` | කවුළුව වමට පුළුල් කරන්න |
| `Super + Equal` | කවුළුව වමින් හැකිළවන්න |
| `Super + Shift + Minus` | කවුළුව ඉහළින් හැකිළවන්න |
| `Super + Shift + Equal` | කවුළුව පහළට පුළුල් කරන්න |
| `Super + Alt + Minus/Equal` | කුඩා පියවරවලින් එම ප්‍රමාණය වෙනස් කිරීමම |
| `Super + Ctrl + Minus/Equal` | විශාල පියවරවලින් එම ප්‍රමාණය වෙනස් කිරීමම |
| `Super + Alt + Home` | කවුළු පළල සුරකින්න |
| `Super + Home` | සුරකින ලද කවුළු පළල ප්‍රතිසාධනය කරන්න |
| `Super + Left Mouse` | කවුළුව එහා මෙහා අදින්න |
| `Super + Right Mouse` | කවුළුවේ ප්‍රමාණය වෙනස් කරන්න |
| `Super + Scroll Wheel` | අවධානය යොමු වූ monitor එකේ workspaces හරහා scroll කරන්න |
| `Super + G` | කවුළු කාණ්ඩගත කිරීම මාරු කරන්න |
| `Super + Alt + G` | කවුළුව කාණ්ඩගත කිරීමෙන් පිටතට ගෙන යන්න |
| `Super + Alt + Tab` | කාණ්ඩගත කිරීම තුළ කවුළු අතර චක්‍රීයව යන්න |
| `Super + Alt + Shift + Tab` | කාණ්ඩගත කිරීම තුළ කවුළු අතර පසුපසට චක්‍රීයව යන්න |
| `Super + Alt + Scroll Wheel` | කාණ්ඩගත කිරීම තුළ කවුළු අතර චක්‍රීයව යන්න |
| `Super + Alt + 1/2/3/4/5` | කාණ්ඩගත කිරීම තුළ නිශ්චිත කවුළුවට පනින්න |
| `Super + Alt + Arrow` | ඊතලයේ දිශාවට කවුළුව කාණ්ඩගත කිරීම තුළට ගෙන යන්න, එම පැත්තේ ඇති monitor එකේ එකක් ද ඇතුළුව |
| `Super + Ctrl + Left/Right` | tiling කාණ්ඩයක් තුළ කවුළු අතර ගමන් කරන්න |
| `Super + Ctrl + Z` | තිරය විශාලනය කරන්න (වැඩි විශාලනයක් සඳහා නැවත කරන්න) |
| `Super + Ctrl + Alt + Z` | තිරයෙන් සම්පූර්ණයෙන්ම විශාලනය අඩු කරන්න |
| `Super + /` | monitor scaling විකල්ප හරහා ඉදිරියට යන්න |
| `Super + Alt + /` | monitor scaling විකල්ප හරහා පසුපසට යන්න |
| `Alt + Tab` | සක්‍රිය workspace එකේ කවුළු හරහා ඉදිරියට චක්‍රීයව යන්න |
| `Alt + Shift + Tab` | සක්‍රිය workspace එකේ කවුළු හරහා පසුපසට චක්‍රීයව යන්න |
| `Ctrl + Alt + Tab` | monitors හරහා අවධානය ඉදිරියට චක්‍රීයව යන්න |
| `Ctrl + Alt + Shift + Tab` | monitors හරහා අවධානය පසුපසට චක්‍රීයව යන්න |
| `Super + I` | ආදාන භාෂාව මාරු කරන්න (සැකැස්මක් හෝ ආදාන ක්‍රමයක් එකකට වඩා ඇති විට) |
| `Super + Shift + I` | ආදාන භාෂාව ආපසු මාරු කරන්න |

touchpad එකක, ඇඟිලි තුනේ සහ ඇඟිලි හතරේ swipes මඟින් workspaces මාරු කරයි, කවුළු ගෙන යයි, සහ මෙනුව සහ Quake console එක විවෘත කරයි; අභිනයන් සඳහා [යතුරුපුවරුව, mouse, සහ trackpad](34-keyboard-mouse-trackpad.md) බලන්න.

ප්‍රමාණය වෙනස් කිරීමේ කෙටිමං, යතුරුපුවරුවේ මුද්‍රණය කර ඇති අක්ෂර නොසලකා, භෞතික යතුරු `code:20` සහ `code:21` (XKB `<AE11>` සහ `<AE12>`) භාවිතා කරයි. US යතුරුපුවරුවල මෙම යතුරු `-` සහ `=` ය; Japanese (JIS) යතුරුපුවරුවල ඒවා `-` සහ `^` ය; Spanish යතුරුපුවරුවල ඒවා `'` සහ `¡` ය. JIS හි, `Super + ^` යනු `Super + Equal` ය, අතර `Super + Shift + -` (එය `=` ටයිප් කරයි) යනු `Super + Shift + Minus` ය.

## පද්ධති පාලන

| හොට්කිය | කාර්යය |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | ශ්‍රව්‍ය පැනලය |
| `Super + Ctrl + B` | Bluetooth පැනලය |
| `Super + Ctrl + N` | Wifi/ජාල පැනලය |
| `Super + Ctrl + D` | සංදර්ශක පැනලය |
| `Super + Ctrl + P` | බල පැනලය |
| `Super + Ctrl + X` | Agents පැනලය |
| `Super + Ctrl + Alt + X` | Local models පැනලය |
| `Super + Ctrl + Alt + D` | දින දර්ශන පැනලය |
| `Super + Ctrl + Alt + E` | ලෝක ඔරලෝසු පැනලය |
| `Super + Ctrl + 1-9` | පිහිටීම අනුව bar පැනලය මාරු කරන්න |
| `Super + Ctrl + S` | බෙදාගැනීමේ මෙනුව (LocalSend හරහා) |
| `Super + Ctrl + C` | ග්‍රහණ පාලන (තිර දසුන/-පටිගත කිරීම/තෝරනය) |
| `Super + Ctrl + O` | මෙනුව මාරු කරන්න |
| `Super + Ctrl + H` | Hardware මෙනුව |
| `Super + Ctrl + E` | Emoji තෝරනය |
| `Super + Ctrl + .` | මාධ්‍ය transcode කරන්න |
| `Super + Shift + Ctrl + A` | ඔබේ පෙරනිමි agent ආරම්භ කරන්න |
| `Power` යතුර | පද්ධති මෙනුව |
| `Super + Shift + Copilot` යතුර | Omarchy මෙනුව |

## ගැලපීම්

| හොට්කිය | කාර්යය |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | උපරිම තිර දීප්තිය |
| `Shift + Brightness Down` | අවම තිර දීප්තිය |
| `Alt + Brightness Up/Down` | නිරවද්‍ය 1% දීප්ති වෙනස්කම් |
| `Alt + Volume Up/Down` | නිරවද්‍ය 1% ශබ්ද ප්‍රමාණ වෙනස්කම් |
| `Keyboard Brightness Up/Down` | යතුරුපුවරු backlight දීප්තිමත්/අඳුරු කරන්න |
| `Keyboard Backlight` | යතුරුපුවරු backlight මට්ටම් චක්‍රීයව යන්න |
| `Ctrl + Brightness Up/Down` | තමන්ගේම යතුරු නැති යතුරුපුවරුවල, යතුරුපුවරු backlight දීප්තිමත්/අඳුරු කරන්න |
| `Mic Mute` | microphone එක නිහඬ කරන්න |
| `Shift + Mute` | ශ්‍රව්‍ය ප්‍රතිදානය මාරු කරන්න |
| `Touchpad Toggle` | touchpad එක සක්‍රිය හෝ අක්‍රිය කරන්න |
| `Display` යතුර | workspace සැකැස්ම චක්‍රීයව යන්න |
| `Alt + Play` | ඊළඟ ඛණ්ඩය |
| `Alt + Shift + Play` | පෙර ඛණ්ඩය |

## යෙදුම් දියත් කිරීම

| හොට්කිය | කාර්යය |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux terminal |
| `Super + Ctrl + Return` | Herdr (agent කළමනාකරු) |
| `Super + Shift + Return` හෝ `Super + Shift + B` | බ්‍රවුසරය |
| `Super + Shift + Alt + B` | බ්‍රවුසරය (පෞද්ගලික/incognito) |
| `Super + Shift + F` | ගොනු කළමනාකරු |
| `Super + Shift + Alt + F` | terminal එකේ cwd තුළ ගොනු කළමනාකරු |
| `Super + Shift + M` | සංගීතය (Spotify) |
| `Super + Shift + Alt + M` | සංගීතය (cliamp) |
| `Super + Shift + /` | මුරපද කළමනාකරු (1password) |
| `Super + Shift + Q` හෝ `Calculator` යතුර | ගණක යන්ත්‍රය (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, ස්ථාපනය කළ පසු) |
| `Super + Shift + T` | ක්‍රියාකාරකම් (btop) |
| `Super + Shift + N` | සංස්කාරකය (Plain, හෝ ඔබ තෝරාගත් පෙරනිමිය) |
| `Super + Shift + C` | දින දර්ශනය ([HEY](https://hey.com/)) |
| `Super + Shift + E` | විද්‍යුත් තැපෑල ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | නව විද්‍යුත් තැපෑල ([HEY](https://hey.com/)) |
| `Super + Shift + A` | ඔබේ පෙරනිමි agent, හෝ ඔබ එකක් තෝරන තුරු ChatGPT |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | පණිවිඩකරු (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | පණිවිඩකරු (WhatsApp) |
| `Super + Shift + Ctrl + G` | පණිවිඩකරු (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | ලිවීම (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (නව පළ කිරීම) |
| `Super + Shift + Y` | YouTube |

`~/.config/hypr/bindings.lua` තුළ බන්ධන වෙනස් කරන්න/එකතු කරන්න.

## විශ්වීය clipboard

| හොට්කිය | කාර්යය |
| ----------------------- | --------------------- |
| `Super + A` | `Ctrl + A` සඳහා සහය දක්වන යෙදුම්වල සියල්ල තෝරන්න |
| `Super + C` | පිටපත් කරන්න |
| `Super + X` | කපන්න (terminal තුළ නොවේ) |
| `Super + V` | අලවන්න |
| `Super + Ctrl + V` | Clipboard කළමනාකරු |

සාමාන්‍යයෙන් Linux හි, terminal තුළ පිටපත් කර ඇලවීමට ඔබට `Ctrl + Shift + C/V` අවශ්‍ය වන අතර අනෙක් සෑම තැනකම එය කිරීමට `Ctrl + C/V` අවශ්‍ය වේ. මෙම Omarchy ඒකාබද්ධ clipboard හොට්කී සෑම තැනකම ක්‍රියා කරයි.

## ග්‍රහණය

| හොට්කිය | කාර්යය |
| ------------------- | ------------------------------ |
| `Print Screen` | තිර දසුන |
| `Super + Ctrl + Alt + C` | තිර දසුන (එම දසුනම, Print Screen යතුරක් නැති යතුරුපුවරු සඳහා) |
| `Super + Ctrl + C` | ග්‍රහණ මෙනුව |
| `Alt + Print Screen` | තිර පටිගත කිරීම |
| `Super + Shift + Ctrl + Alt + C` | ශ්‍රව්‍ය නොමැතිව තිර පටිගත කිරීම, මෙනුව මඟ හරිමින් (නැවැත්වීමට නැවත ඔබන්න) |
| `Super + Print Screen` | වර්ණ තෝරනය |
| `Super + Ctrl + Print Screen` | clipboard එකට පෙළ උපුටා ගැනීම |
| `Super + Alt + [` | පටිගත කරන අතරතුර webcam overlay එක කුඩා කරන්න |
| `Super + Alt + ]` | පටිගත කරන අතරතුර webcam overlay එක විශාල කරන්න |
| `Alt + Shift + L` | webapp එකකින් හෝ බ්‍රවුසරයෙන් වත්මන් URL එක පිටපත් කරන්න |
| `Alt + Shift + D` | වත්මන් පිටුවේ වීඩියෝව `~/Videos` වෙත බාගත කරන්න |
| `Alt + Space` | dictation ආරම්භ කරන්න/නවත්වන්න (_Setup > Defaults > Dictation_ අවශ්‍ය වේ) |
| `Right Alt` | dictation කිරීමට අල්ලාගෙන සිටින්න (_Setup > Defaults > Dictation_ අවශ්‍ය වේ) |

තිර පටිගත කිරීම් සමඟ, හොට්කිය පළමුව ඔබට අවශ්‍ය ශ්‍රව්‍ය කුමක්දැයි අසයි, පසුව පටිගත කිරීම ආරම්භ කරයි. නැවැත්වීමට එය නැවත ඔබන්න. විස්තර සඳහා [තිර දසුන් සහ පටිගත කිරීම](12-screenshots-recording.md) බලන්න.

සියලුම ග්‍රහණ විකල්ප Omarchy මෙනුවේ (`Super + Space`) _Trigger > Capture_ යටතේ ද ප්‍රවේශ විය හැකිය.

## දැනුම්දීම්

| හොට්කිය | කාර්යය |
| ----------------------- | --------------------- |
| `Super + ,` | නවතම දැනුම්දීමට ක්‍රියා කරන්න: එය විවෘත කරන්න හෝ එහි ඇති එකම බොත්තම ඔබන්න, එහි තේරීම්වලින් තෝරන්න, හෝ කිසිවක් නොමැති විට එය ඉවත දමන්න |
| `Super + Shift + ,` | සියලුම දැනුම්දීම් ඉවත දමන්න |
| `Super + Ctrl + ,` | යතුරුපුවරුවෙන් දැනුම්දීම් පාලනය කරන්න |
| `Super + Alt + ,` | නවතම දැනුම්දීම ඉවත දමන්න |
| `Super + Shift + Alt + ,` | දැනුම්දීම් ඉතිහාසය විවෘත කරන්න |
| `Super + Ctrl + Alt + ,` | දැනුම්දීම් නිහඬ කිරීම මාරු කරන්න |

## විලාසය

| හොට්කිය | කාර්යය |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | නව තේමාවක් තෝරන්න (එසේම `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | තේමා පසුබිම තෝරන්න (එසේම `Super + Ctrl + Space`) |
| `Super + Backspace` | කවුළුවක පාරදෘශ්‍යතාව මාරු කරන්න |
| `Super + Ctrl + Backspace` | තනි-කවුළු චතුරස්‍ර අනුපාතය මාරු කරන්න |

අමතර පසුබිම් රූප `~/.config/omarchy/backgrounds/<theme name>` තුළ ඇත. Omarchy මෙනුවේ _Install > Style > Background_ හරහා ද ලබා ගත හැකිය.

සියලුම විලාස විකල්ප Omarchy මෙනුවේ (`Super + Space`) _Appearance_ යටතේ ද ප්‍රවේශ විය හැකිය.

## මාරු කිරීම්

| හොට්කිය | කාර්යය |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | idle විට අගුළු දැමීම මාරු කරන්න |
| `Super + Ctrl + Delete` | laptop සංදර්ශකය සක්‍රිය/අක්‍රිය කිරීම මාරු කරන්න |
| `Super + Ctrl + Alt + Delete` | laptop සංදර්ශක mirroring මාරු කරන්න |
| `Super + Shift + Space` | ඉහළ තීරුව මාරු කරන්න |
| `Shift + Mute` | ඊළඟ ශ්‍රව්‍ය ප්‍රතිදානයට මාරු වන්න |
| `Shift + Play` | ඊළඟ මාධ්‍ය මූලාශ්‍රයට මාරු වන්න |
| `Super + Shift + Backspace` | කවුළු හිඩැස් මාරු කරන්න |
| `Super + Ctrl + Alt + F` | සම්පූර්ණ තිර desktop එක මාරු කරන්න (ඉහළ තීරුව + කවුළු හිඩැස්) |

## මතක් කිරීම්

| හොට්කිය | කාර්යය |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | මතක් කිරීමක් සකසන්න |
| `Super + Ctrl + Alt + R` | සියලුම මතක් කිරීම් බලන්න |
| `Super + Ctrl + Shift + R` | සියලුම මතක් කිරීම් හිස් කරන්න |

## නිවේදන

| හොට්කිය | කාර්යය |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | වේලාව දැනුම්දීමක් ලෙස පෙන්වන්න |
| `Super + Ctrl + Alt + B` | බැටරිය දැනුම්දීමක් ලෙස පෙන්වන්න |
| `Super + Ctrl + Alt + W` | කාලගුණය දැනුම්දීමක් ලෙස පෙන්වීම මාරු කරන්න |

## Tmux

prefix යතුර `Ctrl + Space` ය (`Ctrl + B` ද ක්‍රියා කරයි). ඔබට මෙම බන්ධන `~/.config/tmux/tmux.conf` තුළ වෙනස් කළ හැකිය.

### Pane කොටස්

| හොට්කිය | කාර්යය |
| ----------------------- | --------------------- |
| `Prefix + v` | pane එක අසලින් බෙදන්න (සිරස්) |
| `Prefix + h` | pane එක පහළින් බෙදන්න (තිරස්) |
| `Prefix + x` | pane එක අවසන් කරන්න |
| `Prefix + z` | pane zoom මාරු කරන්න (සම්පූර්ණ තිරය) |
| `Alt + Enter` | pane එක පහළින් බෙදන්න (prefix නැත) |
| `Alt + Shift + Enter` | pane එක අසලින් බෙදන්න (prefix නැත) |
| `Alt + Escape` | pane එක අවසන් කරන්න (prefix නැත) |
| `Ctrl + Alt + Arrows` | panes අතර ගමන් කරන්න |
| `Ctrl + Alt + Shift + Arrows` | panes ප්‍රමාණය වෙනස් කරන්න |

### කවුළු

| හොට්කිය | කාර්යය |
| ----------------------- | --------------------- |
| `Prefix + c` | නව කවුළුව |
| `Prefix + k` | කවුළුව අවසන් කරන්න |
| `Prefix + r` | කවුළුව නැවත නම් කරන්න |
| `Alt + 1-9` | නිශ්චිත කවුළුවට යන්න |
| `Alt + Arrow Left/Right` | කවුළු අතර ගමන් කරන්න |
| `Alt + Shift + Arrow Left/Right` | කවුළුව වමට/දකුණට ගෙන යන්න |

### සැසි

| හොට්කිය | කාර්යය |
| ----------------------- | --------------------- |
| `Prefix + C` | නව සැසිය |
| `Prefix + K` | සැසිය අවසන් කරන්න |
| `Prefix + R` | සැසිය නැවත නම් කරන්න |
| `Prefix + N` | ඊළඟ සැසිය |
| `Prefix + P` | පෙර සැසිය |
| `Alt + Arrow Up/Down` | සැසි අතර ගමන් කරන්න |
| `Prefix + s` | සැසි ලැයිස්තුගත කරන්න |
| `Prefix + d` | සැසියෙන් වෙන් වන්න |

### පිටපත් ප්‍රකාරය (vi-style)

| හොට්කිය | කාර්යය |
| ----------------------- | --------------------- |
| `Prefix + [` | පිටපත් ප්‍රකාරයට ඇතුළු වන්න |
| `v` | තේරීම ආරම්භ කරන්න (පිටපත් ප්‍රකාරයේදී) |
| `y` | තේරීම පිටපත් කරන්න (පිටපත් ප්‍රකාරයේදී) |

### සාමාන්‍ය

| හොට්කිය | කාර්යය |
| ----------------------- | --------------------- |
| `Prefix + q` | config නැවත පූරණය කරන්න |
| `Prefix + ?` | Tmux යතුරු බන්ධන පෙන්වන්න |
| `Prefix + :` | විධාන prompt එක |

### Tmux සැකැස්ම ශ්‍රිත

මෙම ශ්‍රිත Tmux සැසියක් තුළ ධාවනය කළ යුතුය.

| විධානය | කාර්යය |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | සංස්කාරකය, AI, සහ terminal සමඟ dev සැකැස්මක් සාදන්න |
| `tdlm <ai> [<second_ai>]` | උප නාමාවලියකට dev සැකැස්මක් සාදන්න |
| `tsl <count> <command>` | බහු-pane swarm සැකැස්මක් සාදන්න |

## Ghostty Terminal

Ghostty terminal එක Omarchy මෙනුව හරහා _Install > Terminal_ භාවිතයෙන් ස්ථාපනය කෙරේ.

| හොට්කිය | කාර්යය |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | පහළින් නව බෙදීමක් |
| `Ctrl + Shift + O` | අසලින් නව බෙදීමක් |
| `Ctrl + Alt + Arrows` | බෙදීම් අතර ගමන් කරන්න |
| `Super + Ctrl + Shift + Arrows` | පේළි 10කින් බෙදීමේ ප්‍රමාණය වෙනස් කරන්න |
| `Super + Ctrl + Shift + Alt + Arrows` | පේළි 100කින් බෙදීමේ ප්‍රමාණය වෙනස් කරන්න |
| `Ctrl + Shift + T` | නව tab එක |
| `Ctrl + Shift + Arrows` | tabs අතර ගමන් කරන්න |
| `Alt + Numbers` | නිශ්චිත tab එකට යන්න |
| `Shift + Pg Up/Down` | ඉතිහාසය scroll කරන්න |
| `Ctrl + Left mouse` | සබැඳිය බ්‍රවුසරයේ විවෘත කරන්න |

## ගොනු කළමනාකරු

| හොට්කිය | කාර්යය |
| ------------------- | ------------------------------ |
| `Ctrl + L` | path එකට යන්න |
| `Space` | ගොනුව පෙරදක්වන්න (ඊතල මඟින් සැරිසරයි) |
| `Alt + Up` | මව් ෆෝල්ඩරයට ඉහළට යන්න |

## Neovim (w/ lazyvim)

### සැරිසැරීම

| හොට්කිය | කාර්යය |
| ------------------------ | ------------------------------- |
| `Space` | විධාන විකල්ප පෙන්වන්න |
| `Space Space` | fuzzy සෙවුම හරහා ගොනුව විවෘත කරන්න |
| `Space E` | sidebar එක මාරු කරන්න |
| `Space G G` | git පාලන පෙන්වන්න |
| `Space S G` | ගොනු අන්තර්ගතය සොයන්න |
| `Ctrl + W W` | sidebar එක සහ සංස්කාරකය අතර පනින්න |
| `Ctrl + Left/right arrow` | sidebar එකේ ප්‍රමාණය වෙනස් කරන්න |
| `Shift + H` | වම් ගොනු tab එකට යන්න |
| `Shift + L` | දකුණු ගොනු tab එකට යන්න |
| `Space B D` | ගොනු tab එක වසන්න |

### sidebar එකේ සිටින විට

| හොට්කිය | කාර්යය |
| ------------------------ | ------------------------------- |
| `A` | මව් dir එකේ නව ගොනුවක් එකතු කරන්න |
| `Shift + A` | මව් dir එකේ නව උප නාමාවලියක් එකතු කරන්න |
| `D` | උද්දීපනය කළ ගොනුව/dir එක මකන්න |
| `M` | උද්දීපනය කළ ගොනුව/dir එක ගෙන යන්න |
| `R` | උද්දීපනය කළ ගොනුව/dir එක නැවත නම් කරන්න |
| `?` | සියලුම විධාන සඳහා උදව් පෙන්වන්න |

[LazyVim මඟින් වින්‍යාස කළ සියලුම Neovim හොට්කී බලන්න](https://www.lazyvim.org/keymaps).

## ඉක්මන් Emojis

ඔබට තේරීම clipboard එකට දමන සම්පූර්ණ emoji තෝරනයක් පෙන්වීමට `Super + Ctrl + E` භාවිතා කළ හැකිය හෝ ඔබට මෙම ඉක්මන් ප්‍රවේශ විකල්ප භාවිතා කළ හැකිය.

| හොට්කිය | EM | ඉඟිය |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | සිනහව |
| `Shift + CapsLock M C` | 😂 | ඇඬීම |
| `Shift + CapsLock M L` | 😍 | ආදරය |
| `Shift + CapsLock M V` | ✌️ | ජයග්‍රහණය |
| `Shift + CapsLock M H` | ❤️ | හදවත |
| `Shift + CapsLock M Y` | 👍 | ඔව් |
| `Shift + CapsLock M N` | 👎 | නැහැ |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | ප්‍රාර්ථනය |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | හාදුව |
| `Shift + CapsLock M E` | 🙄 | ඇස් කරකැවීම |
| `Shift + CapsLock M I` | 😉 | ඇස් ගැසීම |
| `Shift + CapsLock M P` | 🙏 | යාච්ඤාව |
| `Shift + CapsLock M D` | 🤤 | කෙළ පෙරීම |
| `Shift + CapsLock M M` | 💰 | මුදල් |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | toast |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | ආචාරය |
| `Shift + CapsLock M A` |💪 | බාහුව |
| `Shift + CapsLock M B` |🤯 | පිඹීම |

## ඉක්මන් සම්පූර්ණ කිරීම්

| හොට්කිය | සම්පූර්ණ කිරීම |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | ඔබේ නම (සැකසීමේදී ඇතුළත් කළ පරිදි) |
| `Shift + CapsLock Space E` | ඔබේ විද්‍යුත් තැපෑල (සැකසීමේදී ඇතුළත් කළ පරිදි) |

ඔබට `~/.XCompose` සංස්කරණය කිරීමෙන් ඔබේම තවත් එකතු කළ හැකිය, පසුව වෙනස්කම් ලබා ගැනීමට terminal එකේ `omarchy restart xcompose` ධාවනය කරන්න.
