# පෙළ උකහා ගැනීම සහ කටහඬින් ලිවීම

### පෙළ උකහා ගැනීම

තිරයේ ප්‍රදේශයක් පෙළ උකහා ගැනීම සඳහා තෝරා ගැනීමට `Super + Ctrl + PrtScr` ඔබන්න. එවිට tesseract විවෘත මූලාශ්‍ර OCR ආකෘතිය එම තෝරාගැනීම ඉක්මනින් පෙළ බවට පරිවර්තනය කර එය clipboard එක මත තබනු ඇත. ඉන්පසුව ඔබට කළ යුත්තේ ඇලවීමට `Super + V` එබීම පමණි.

රූපවල පාද සටහන්වලින් ලිපිනයන් හෝ වෙබ් අඩවි ශීර්ෂයන් තුළ අන්තර්ගත දුරකථන අංක අල්ලා ගැනීමට මෙය ඉතාම ප්‍රයෝජනවත් වේ.

 ![text-extraction](images/text-extraction.webp)

### කටහඬින් ලිවීම

නැවුම් ස්ථාපනයන්හි, නොබැඳි ආකෘති බාගැනීම් නොමැතිව වලාකුළු සැකසීම භාවිත කරන [Superwhisper](https://superwhisper.com/) යනු පෙරනිමි කටහඬින් ලිවීමේ backend එකයි. Omarchy මෙනුවේ _Setup > Defaults > Dictation_ හරහා Superwhisper හෝ [Voxtype](https://voxtype.io/) තෝරන්න. Backend එකක් තේරීමෙන් අවශ්‍ය නම් එය ස්ථාපනය කර කටහඬින් ලිවීම සඳහා එය පෙරනිමිය බවට පත් කරයි. Voxtype විසින් 150MB ක් ගන්නා මූලික ඉංග්‍රීසි ආකෘතියක් පූරණය කරයි; `voxtype setup model` සමඟ ආකෘතිය වෙනස් කරන්න, අනෙකුත් සැකසුම් `~/.config/voxtype/config.toml` හරහා වෙනස් කරන්න. Superwhisper විසින් වලාකුළු හෝ දේශීය සැකසීම තෝරා ගැනීමට එහි සැකසුම් විවෘත කරන අතර, OPR විසින් යෙදුම යාවත්කාලීනව තබා ගනී.

ඔබ `Right Alt` ඔබාගෙන සිටීමෙන්, හෝ `Alt + Space` සමඟ toggle කිරීමෙන් කටහඬින් ලියවිය හැකි අතර, කටහඬින් ලියූ පෙළ නාභිගත කළ ආදාන ප්‍රදේශයේ දිස් වේ. මෙම කෙටිමං තෝරාගත් backend එක භාවිත කරයි. `Right Alt` modifier chord එකක භාවිත කරන විටද කටහඬින් ලිවීම ආරම්භ කරයි; එම chords සඳහා `Left Alt` භාවිත කරන්න. `Right Alt` යනු AltGr වන යතුරුපුවරු පිරිසැලසුම් මත, AltGr ටයිප් කිරීමට භාවිත කළ හැකිව තබා ගැනීමට `Alt + Space` භාවිත කරන්න. `Alt + Space` පෙරනිමිය බවට පත්වීමට පෙර ස්ථාපනයන් `F9` push-to-talk සඳහාද, toggle කිරීමට `Super + Ctrl + X` ද රඳවා ගනී, ඒවා `~/.config/hypr/bindings.lua` වෙත එක් කර ඇත; එම යතුරු යෙදුම් වෙත නැවත ලබා දීමට ඒවා එතැනින් ඉවත් කරන්න.

එම කෙටිමංම backend දෙකෙන් ඕනෑම එකක් සමඟ ක්‍රියා කරයි. Setup > Defaults > Dictation හරහා ඔබේ backend එක තෝරන්න. Backend ස්ථාපකය එය වින්‍යාස කර තේරීම සුරකියි. කුමක් තෝරාගෙන ඇත්දැයි බැලීමට `omarchy default dictation` ධාවනය කරන්න. තේරීම `~/.config/omarchy/defaults/dictation` තුළ සුරකිනු ලැබේ. නැවුම් ස්ථාපනයන් ස්වයංක්‍රීයවම Superwhisper තෝරා ගනී.

Omarchy විසින් තෝරාගත් backend එකේ desktop ඒකාබද්ධතාව ස්වයංක්‍රීයව පූරණය කරයි. `~/.config/hypr/` තුළ Superwhisper වින්‍යාසයක් අවශ්‍ය නැත.

අභිරුචි bindings සහ scripts වලට `omarchy dictation start`, `omarchy dictation stop`, සහ `omarchy dictation toggle` භාවිත කළ හැක. තෝරාගත් backend එක පටිගත කිරීම සහ පිටපත් කිරීම සිදු කරයි. Superwhisper තෝරා ගැනීමෙන් එහි ස්වදේශීය hold කෙටිමඟ අබල කර, එහි ස්වදේශීය toggle එක `Ctrl + Alt + Space` ලෙස සකසයි, එය Omarchy හි පටිගත කිරීමේ යතුරුවලින් වෙන්ව තබා ගනී. Superwhisper සඳහා අවම වශයෙන් එක් ස්වදේශීය පටිගත කිරීමේ කෙටිමඟක් හෝ අවශ්‍ය වන අතර, එහි අවලංගු කිරීමේ කෙටිමඟ දිගටම භාවිත කළ හැක.

Omarchy වෙනස් නොකරම අමතර backends වලට ඒකාබද්ධ විය හැක. `start`, `stop`, සහ `toggle` පිළිගන්නා සහ වහාම නැවත පැමිණෙන, අසාර්ථක වූ විට ශුන්‍ය නොවන තත්ත්වයක් ලබා දෙන, PATH මත `omarchy-dictation-<backend>` නමැති ක්‍රියාත්මක කළ හැකි ගොනුවක් සපයන්න. එහි ස්ථාපකය සැපයුම්කරු වින්‍යාස කර සාර්ථක සැකසීමෙන් පසුව `omarchy-dictation-use <backend>` අමතයි. මෙය පෙර backend එක නවතා තේරීම පරමාණුකව සුරකියි; සැපයුම්කරු idle හෝ නොමැති විට `stop` සාර්ථක විය යුතුය. Backend නම් කුඩා අකුරු, ඉලක්කම්, සහ hyphens භාවිත කරයි. සැකසීම සඳහා `omarchy-install-dictation-<backend>` සපයන්න; `omarchy default dictation <backend>` එය දියත් කරයි. එම තේරීම්කරු ඇමතීමට Omarchy menu extension එකක් හරහා Defaults මෙනු සටහනක් එක් කරන්න. විකල්ප desktop ඒකාබද්ධතාව `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` තුළ තිබිය හැක.
