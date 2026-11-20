# පෙළ උපුටා ගැනීම සහ කටහඬින් ලිවීම

### පෙළ උපුටා ගැනීම

තිරයේ කලාපයක් තෝරා පෙළ උපුටා ගැනීමට `Super + Ctrl + PrtScr` ඔබන්න. එවිට tesseract විවෘත මූලාශ්‍ර OCR ආකෘතිය එම තේරීම ඉක්මනින් පෙළ බවට පරිවර්තනය කර clipboard එකට දමනු ඇත. ඉන්පසු ඔබ කළ යුත්තේ `Super + V` ඔබා ඇලවීම පමණි.

රූපවල පාදකවල ඇති ලිපින හෝ වෙබ් අඩවි සිරස්තලවල අන්තර්ගත දුරකථන අංක ලබා ගැනීමට මෙය ඉතා ප්‍රයෝජනවත් වේ.

 ![text-extraction](images/text-extraction.webp)

### කටහඬින් ලිවීම

නව ස්ථාපනයන්හි, නොබැඳි ආකෘති බාගත කිරීම් නොමැතිව cloud සැකසුම් භාවිත කරන [Superwhisper](https://superwhisper.com/) යනු පෙරනිමි dictation backend එකයි. Omarchy මෙනුවේ _Setup > Defaults > Dictation_ හරහා Superwhisper, [Voxtype](https://voxtype.io/), හෝ [Hex](https://anoma.ly/hex/) තෝරන්න. backend එකක් තෝරා ගැනීමෙන් අවශ්‍ය නම් එය ස්ථාපනය කර dictation සඳහා පෙරනිමිය බවට පත් කරයි. Voxtype විසින් 150MB ක් ගන්නා මූලික ඉංග්‍රීසි ආකෘතියක් පූරණය කරයි; `voxtype setup model` භාවිතයෙන් ආකෘතිය වෙනස් කරන්න, අනෙකුත් සැකසුම් `~/.config/voxtype/config.toml` හරහා වෙනස් කරන්න. Superwhisper එහි සැකසුම් විවෘත කර cloud හෝ local සැකසුම් තෝරා ගැනීමට ඉඩ දෙයි, OPR යෙදුම යාවත්කාලීනව තබා ගනී. Hex සැකසීමේදී එහි උපාංගයේම ඇති කථන ආකෘතිය බාගත කර `hex.service` පරිශීලක සේවාව ලෙස ධාවනය වේ; ආකෘතිය සහ අනෙකුත් සැකසුම් වෙනස් කිරීමට bar එකේ tray අයිකනයෙන් හෝ `hex` ධාවනය කිරීමෙන් එහි කවුළුව විවෘත කරන්න.

ඔබ `Right Alt` ඔබාගෙන සිටීමෙන්, හෝ `Alt + Space` භාවිතයෙන් toggle කිරීමෙන් dictation කළ හැකි අතර, කටහඬින් කියන පෙළ අවධානය යොමු වූ ආදාන ප්‍රදේශයේ දිස් වේ. මෙම කෙටිමං තෝරාගත් backend එක භාවිත කරයි. modifier chord එකක භාවිත කරන විටද Right Alt මඟින් dictation ආරම්භ වේ; එවැනි chords සඳහා Left Alt භාවිත කරන්න. Right Alt යනු AltGr වන යතුරුපුවරු පිරිසැලසුම්වල, ටයිප් කිරීම සඳහා AltGr ලබා ගත හැකිව තබා ගැනීමට `Alt + Space` භාවිත කරන්න. Alt + Space පෙරනිමිය වීමට පෙර සිදු කළ ස්ථාපනයන්, push-to-talk සඳහා `F9` සහ toggle කිරීම සඳහා `Super + Ctrl + X` රඳවා ගනී, ඒවා `~/.config/hypr/bindings.lua` වෙත එක් කර ඇති අතර, එහිදී එම `Super + Ctrl + X` agents panel එකේ ස්ථානය ගනී; එම යතුරු යෙදුම්වලට සහ panel එකට නැවත ලබා දීමට ඒවා එතැනින් ඉවත් කරන්න.

එකම කෙටිමං සෑම backend එකක් සමඟම ක්‍රියා කරයි. Setup > Defaults > Dictation හරහා ඔබේ backend එක තෝරන්න. backend ස්ථාපකය එය වින්‍යාස කර තේරීම සුරකියි. කුමන එක තෝරාගෙන ඇත්දැයි බැලීමට `omarchy default dictation` ධාවනය කරන්න. තේරීම `~/.config/omarchy/defaults/dictation` හි සුරකිනු ලැබේ. නව ස්ථාපනයන් ස්වයංක්‍රීයව Superwhisper තෝරා ගනී.

Omarchy තෝරාගත් backend එකේ desktop අනුකලනය ස්වයංක්‍රීයව පූරණය කරයි. `~/.config/hypr/` තුළ Superwhisper වින්‍යාසයක් අවශ්‍ය නොවේ.

අභිරුචි bindings සහ scripts වලට `omarchy dictation start`, `omarchy dictation stop`, සහ `omarchy dictation toggle` භාවිත කළ හැක. තෝරාගත් backend එක පටිගත කිරීම සහ පිටපත් කිරීම හසුරුවයි. Superwhisper තෝරා ගැනීමෙන් එහි ස්වදේශීය hold කෙටිමඟ අබල කර එහි ස්වදේශීය toggle එක `Ctrl + Alt + Space` ලෙස සකසයි, එය Omarchy හි පටිගත කිරීමේ යතුරුවලින් වෙන්ව තබා ගනී. Superwhisper සඳහා අවම වශයෙන් එක් ස්වදේශීය පටිගත කිරීමේ කෙටිමඟක්වත් අවශ්‍ය වන අතර, එහි අවලංගු කිරීමේ කෙටිමඟ දිගටම ලබා ගත හැක.

Omarchy වෙනස් නොකර අතිරේක backends අනුකලනය විය හැක. PATH මත `start`, `stop`, සහ `toggle` පිළිගන්නා, වහාම ආපසු එන, අසාර්ථක වූ විට ශුන්‍ය නොවන තත්ත්වයක් ලබා දෙන `omarchy-dictation-<backend>` නමැති executable එකක් සපයන්න. එහි ස්ථාපකය provider එක වින්‍යාස කර සාර්ථක සැකසීමෙන් පසු `omarchy-dictation-use <backend>` අමතයි. මෙය පෙර backend එක නවතා තේරීම පරමාණුකව සුරකියි; provider එක අක්‍රියව හෝ ලබා ගත නොහැකිව ඇති විට `stop` සාර්ථක විය යුතුය. Backend නම් සඳහා කුඩා අකුරු, ඉලක්කම්, සහ hyphens භාවිත වේ. සැකසීම සඳහා `omarchy-install-dictation-<backend>` සපයන්න; `omarchy default dictation <backend>` එය දියත් කරයි. එම selector එක ඇමතීමට Omarchy menu extension එකක් හරහා Defaults මෙනු ප්‍රවේශයක් එක් කරන්න. විකල්ප desktop අනුකලනය `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` තුළ තිබිය හැක.
