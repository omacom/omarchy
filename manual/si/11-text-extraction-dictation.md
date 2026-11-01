# පෙළ උකහා ගැනීම සහ වාග් උච්චාරණයෙන් ලිවීම

### පෙළ උකහා ගැනීම

පෙළ උකහා ගැනීම සඳහා තිරයේ ප්‍රදේශයක් තෝරා ගැනීමට `Super + Ctrl + PrtScr` ඔබන්න. එවිට tesseract විවෘත මූලාශ්‍ර OCR මාදිලිය එම තේරීම ඉක්මනින් පෙළ බවට පරිවර්තනය කර එය clipboard එක මත තබනු ඇත. ඉන්පසු අලවන්නට ඔබ කළ යුත්තේ `Super + V` එබීම පමණි.

මෙය රූප පාදවලින් ලිපින හෝ වෙබ් අඩවි ශීර්ෂවල කාවැද්දූ දුරකථන අංක ලබා ගැනීමට ඉතා ප්‍රයෝජනවත් වේ.

 ![text-extraction](images/text-extraction.webp)

### වාග් උච්චාරණයෙන් ලිවීම

නව ස්ථාපනයන්හි, [Superwhisper](https://superwhisper.com/) යනු පෙරනිමි dictation backend එක වන අතර, එය offline මාදිලි බාගත කිරීම් නොමැතිව cloud සැකසුම භාවිත කරයි. Omarchy මෙනුවේ _Setup > Defaults > Dictation_ හරහා Superwhisper, [Voxtype](https://voxtype.io/), හෝ [Hex](https://anoma.ly/hex/) තෝරන්න. Backend එකක් තෝරා ගැනීමේදී අවශ්‍ය නම් එය ස්ථාපනය කර dictation සඳහා පෙරනිමිය බවට පත් කරයි. Voxtype විසින් 150MB ප්‍රමාණය ගන්නා මූලික ඉංග්‍රීසි මාදිලියක් පූරණය කරයි; `voxtype setup model` භාවිතයෙන් මාදිලිය වෙනස් කරන්න, අනෙකුත් සැකසුම් `~/.config/voxtype/config.toml` හරහා වෙනස් කරන්න. Superwhisper විසින් cloud හෝ local සැකසුම තෝරා ගැනීමට එහි සැකසුම් විවෘත කරන අතර, OPR යෙදුම යාවත්කාලීනව තබයි. Hex විසින් එහි උපාංගය මත ක්‍රියාත්මක වන කථන මාදිලිය සැකසුම අතරතුර බාගත කරන අතර `hex.service` පරිශීලක සේවාව ලෙස ක්‍රියාත්මක වේ; මාදිලිය සහ වෙනත් සැකසුම් වෙනස් කිරීමට තීරුවේ tray නිරූපකයෙන් හෝ `hex` ධාවනය කිරීමෙන් එහි කවුළුව විවෘත කරන්න.

ඔබ `Right Alt` ඔබාගෙන සිටීමෙන්, හෝ `Alt + Space` භාවිතයෙන් toggle කිරීමෙන් උච්චාරණය කරන අතර, උච්චාරණය කළ පෙළ අවධානය යොමු වූ ආදාන ප්‍රදේශයේ දිස් වේ. මෙම කෙටිමං තෝරාගත් backend එක භාවිත කරයි. modifier chord එකක භාවිත කරන විටද Right Alt උච්චාරණය ආරම්භ කරයි; එම chords සඳහා Left Alt භාවිත කරන්න. Right Alt යනු AltGr වන යතුරුපුවරු පිරිසැලසුම් මත, AltGr ටයිප් කිරීම සඳහා තබා ගැනීමට `Alt + Space` භාවිත කරන්න. Alt + Space පෙරනිමිය වීමට පෙර සිදු කළ ස්ථාපනයන් push-to-talk සඳහා `F9` සහ toggle කිරීමට `Super + Ctrl + X` තබා ගන්නා අතර, ඒවා `~/.config/hypr/bindings.lua` වෙත එක් කර ඇත; එම යතුරු යෙදුම් වෙත ආපසු දීමට ඒවා එතැනින් ඉවත් කරන්න.

එකම කෙටිමං සෑම backend එකක් සමඟම ක්‍රියා කරයි. ඔබේ backend එක Setup > Defaults > Dictation හරහා තෝරන්න. Backend ස්ථාපකය එය වින්‍යාස කර තේරීම සුරකියි. කුමක් තෝරා තිබේදැයි බැලීමට `omarchy default dictation` ධාවනය කරන්න. තේරීම `~/.config/omarchy/defaults/dictation` හි සුරකිනු ඇත. නව ස්ථාපනයන් Superwhisper ස්වයංක්‍රීයව තෝරා ගනී.

Omarchy තෝරාගත් backend එකේ desktop ඒකාබද්ධතාව ස්වයංක්‍රීයව පූරණය කරයි. `~/.config/hypr/` හි Superwhisper වින්‍යාසයක් අවශ්‍ය නොවේ.

අභිරුචි බැඳීම් සහ scripts `omarchy dictation start`, `omarchy dictation stop`, සහ `omarchy dictation toggle` භාවිත කළ හැක. තෝරාගත් backend එක පටිගත කිරීම සහ පිටපත් කිරීම සිදු කරයි. Superwhisper තේරීම එහි ස්වදේශික hold කෙටිමඟ අක්‍රිය කර එහි ස්වදේශික toggle එක `Ctrl + Alt + Space` ලෙස සකසයි, එය Omarchy හි පටිගත කිරීමේ යතුරුවලින් වෙන්ව තබයි. Superwhisper සඳහා අවම වශයෙන් එක් ස්වදේශික පටිගත කිරීමේ කෙටිමඟක්වත් අවශ්‍ය වන අතර, එහි අවලංගු කිරීමේ කෙටිමඟ දිගටම ලබා ගත හැක.

Omarchy වෙනස් නොකරම අමතර backends ඒකාබද්ධ විය හැක. PATH මත `start`, `stop`, සහ `toggle` පිළිගෙන වහාම ආපසු පැමිණෙන, අසාර්ථක වූ විට ශුන්‍ය නොවන තත්ත්වයක් ලබා දෙන `omarchy-dictation-<backend>` නම් ක්‍රියාත්මක කළ හැකි ගොනුවක් සපයන්න. එහි ස්ථාපකය සපයන්නා වින්‍යාස කරන අතර සාර්ථක සැකසුමකින් පසු `omarchy-dictation-use <backend>` අමතයි. මෙය පෙර backend එක නවතා තේරීම පරමාණුකව සුරකියි; සපයන්නා අක්‍රිය හෝ ලබා ගත නොහැකි විට `stop` සාර්ථක විය යුතුය. Backend නම් සඳහා කුඩා අකුරු, ඉලක්කම් සහ හයිෆන් භාවිත කරයි. සැකසුම සඳහා `omarchy-install-dictation-<backend>` සපයන්න; `omarchy default dictation <backend>` එය දියත් කරයි. එම selector එක ඇමතීමට Omarchy මෙනු දිගුවක් හරහා Defaults මෙනු ප්‍රවේශයක් එක් කරන්න. විකල්ප desktop ඒකාබද්ධතාව `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` හි තිබිය හැක.
