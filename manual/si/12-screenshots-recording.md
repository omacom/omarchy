# තිරරූප සහ පටිගත කිරීම

තිරයෙන් ගත හැකි සියල්ලම Print Screen යතුර වටා බැඳී ඇත. තනි යතුරකින් පමණක් ඡායාරූපයක් ගන්නා අතර, modifiers මඟින් පටිගත කිරීමක්, වර්ණයක්, හෝ ප්‍රදේශයක් තුළ ඇති පෙළ ගනී. ඔබේ යතුරු පුවරුවේ Print Screen යතුරක් කිසිසේත් නැත්නම්, `Super + Ctrl + Alt + C` මඟින් එම තිරරූපයම ගන්නා අතර, `Super + Ctrl + C` මඟින් සම්පූර්ණ කට්ටලයම මෙනුවක් ලෙස විවෘත කරයි.

| කෙටි යතුර | කාර්යය |
| ------ | -------- |
| `Print Screen` | තිරරූපය |
| `Super + Ctrl + Alt + C` | තිරරූපය |
| `Alt + Print Screen` | තිරය පටිගත කිරීම (හෝ ධාවනය වන එක නතර කිරීම) |
| `Super + Print Screen` | වර්ණ තෝරනය |
| `Super + Ctrl + Print Screen` | ප්‍රදේශයකින් පෙළ උකහා ගැනීම |
| `Super + Ctrl + C` | ග්‍රහණ මෙනුව |
| `Super + Ctrl + .` | ඡායාරූපයක් හෝ video එකක් transcode කිරීම |

## තිරරූප

`Print Screen` (හෝ `Super + Ctrl + Alt + C`) ඔබන්න. එවිට Omasnap එහි overlay එක දිස්වීමට පෙර අවධානය යොමු වූ monitor එක ග්‍රහණය කරන බැවින්, ඔබ ඉලක්ක කරන අතරතුර ඔබ යට කිසිවක් චලනය නොවේ. නිදහස් හැඩයක ප්‍රදේශයක් අඳින්න, එය ග්‍රහණය කිරීමට window එකක් click කරන්න, හෝ සම්පූර්ණ monitor එක ග්‍රහණය කිරීමට හිස් ඉඩක් click කරන්න. අඳීමට පෙර `S` ඔබා scrolling region එකක් ග්‍රහණය කරන්න. අදහස වෙනස් වුණාද? Omasnap ඉවත් කිරීමට එම යතුරම නැවත ඔබන්න.

ප්‍රදේශයක් තේරූ පසු, Omasnap ග්‍රහණය සුරකින අතර, එය clipboard එකට පිටපත් කර, සුරකින ලද තිර පටිගත කිරීමක් කරන ආකාරයටම එහි thumbnail එක සමඟ දැනුම්දීමක් පෙන්වයි. සුරකින ලද රූපය ඔබේ image viewer එකේ බැලීමට Open තෝරන්න, හෝ එය සටහන් කිරීමට Edit තෝරන්න.

annotation editor එකට arrows, lines, shapes, highlights, අංකිත markers, text, සහ ආරක්ෂිත redactions ඇඳිය හැකිය; රූපයේ කොටසක් crop කිරීමට හෝ කපා ඉවත් කිරීමට; එහි text එක OCR කිරීමට; සහ backdrop එකක් එක් කිරීමට හැකිය. editor එක තුළ, අවසන් PNG එක පිටපත් කර සුරැකීමට `Enter` ඔබන්න, සුරැකීමකින් තොරව පිටපත් කිරීමට `Ctrl + C` ඔබන්න, හෝ පිටපත් කිරීමකින් තොරව සුරැකීමට `Ctrl + S` ඔබන්න.

සුරකින ලද තිරරූප පෙරනිමියෙන් `~/Pictures/Screenshots` වෙත යන අතර, `screenshot-2026-08-13_14-22-05-firefox.png` වැනි නමක් ඇත. වෙනත් directory එකක් භාවිතා කිරීමට `OMASNAP_SCREENSHOT_DIR` සකසන්න — session environment variables තැබිය යුත්තේ කොතැනද යන්න සඳහා [නිතර ප්‍රශ්න](46-faq.md) බලන්න. Omasnap පළමු රූපය සුරකින විට directory එක සාදයි. ස්වයංක්‍රීය සුරැකීම අක්‍රිය කිරීමට `~/.config/omasnap/omasnap.conf` තුළ `[output] autosave = false` සකසන්න; එවිට ග්‍රහණයන් පිටපත් කරනු ලැබීම පමණක් සිදුවන අතර, තත්පර 10ක් preview එකක පෙන්වනු ලැබේ. එහි pin බොත්තම හෝ `Ctrl + P` මඟින් එය තිරයේ රඳවා තබාගත හැකිය.

terminal එකේ සිට, `omarchy screenshot` මඟින් එම overlay එකම විවෘත වන අතර, ඔබට එහි ආරම්භක mode එක තෝරාගත හැකිය: `omarchy capture screenshot region`, `windows`, `fullscreen`, හෝ `scroll`. `copy` හෝ `save` යන දෙවන argument එකක් මඟින් රූපය කෙලින්ම එම ගමනාන්තයට යවයි. ප්‍රතිදානයට පෙර සංස්කරණය කිරීමට, fullscreen editor එකක් සඳහා `omarchy screenshot --editor=overlay` හෝ වෙනම window එකක් සඳහා `omarchy screenshot --editor=window` භාවිතා කරන්න.

### යතුරු පුවරුවෙන් picker එක මෙහෙයවීම

selection එක දිස්ව තිබෙන අතරතුර, ඔබට mouse එක කිසිසේත් භාවිතා කිරීමට අවශ්‍ය නැත:

| යතුර | කාර්යය |
| --- | -------- |
| `S` | scrolling-region mode එක මාරු කිරීම |
| `Super + Arrow keys` | Window mode එකේ windows අතර ගමන් කිරීම |
| `Return` | උද්දීපනය වූ window එක ග්‍රහණය කිරීම |
| `Ctrl + A` | සම්පූර්ණ අවධානය යොමු වූ monitor එක ග්‍රහණය කිරීම |
| `R` | මෙම session එකේ අඳින ලද අවසන් ප්‍රදේශය ප්‍රතිෂ්ඨාපනය කිරීම |
| `Esc` | Omasnap ඉවත් කිරීම |

මෙම bindings පවතින්නේ Omasnap විවෘතව තිබෙන අතරතුර පමණි, එබැවින් ඒවාට ඔබේම config එකේ කිසිවක් සමඟ ගැටිය නොහැකිය.

## තිරය පටිගත කිරීම

`Alt + Print Screen` මඟින් _Trigger > Capture > Screenrecord_ විවෘත වන අතර, එය soundtrack එකේ ඔබට අවශ්‍ය දේ අසයි: audio නැත, desktop audio, desktop සහ microphone, හෝ desktop සහ microphone සහ webcam. ඔබට ඇත්තටම camera එකක් සම්බන්ධ කර ඇත්නම් පමණක් අන්තිම එක දිස්වේ. එකක් තෝරන්න, එවිට Omarchy හි recording picker එක මඟින් ප්‍රදේශයක් ඇඳීමට හෝ window එකක් හෝ monitor එකක් click කිරීමට ඔබට ඉඩ දෙයි.

පටිගත කිරීම gpu-screen-recorder මත ධාවනය වන අතර, එය 60fps බැගින් GPU එකේ encode කරන අතර, අවශ්‍ය වුවහොත් CPU එකට ආපසු යයි. ප්‍රතිඵලය `~/Videos` තුළ ඇති `screenrecording-2026-08-13_14-22-05.mp4` ලෙස නම් කළ MP4 එකකි. එය වෙනස් කිරීමට `OMARCHY_SCREENRECORD_DIR` සකසන්න — නමුත් screenshot directory එකට වෙනස්ව, මෙය දැනටමත් පැවතිය යුතු බව සලකන්න, එසේ නැත්නම් පටිගත කිරීම ආරම්භ වීම ප්‍රතික්ෂේප කරයි.

ඔබ පටිගත කරන අතරතුර, bar එකේ කුඩා indicator එකක් දිස්වේ. එය නතර කිරීමට එය click කරන්න. ඔබට `Alt + Print Screen` නැවත එබීමෙන්, හෝ ඇත්තටම යමක් පටිගත වෙමින් පවතින විට පමණක් දිස්වන _Trigger > Capture > Screenrecord_ යට ඇති _Stop Screenrecording_ entry එකෙන්ද නතර කළ හැකිය.

නැවැත්වීම ඔබට file එක ලබා දීමට පෙර තරමක් පිළිවෙළ කිරීමක් කරයි: පළමු frame එක trim කරන අතර, audio එකක් ඇත්නම් එය -14 LUFS දක්වා normalize කර, ආරම්භයේම ඇති PipeWire capture pop එක නිහඬ කරයි. ඉන්පසු පටිගත කිරීමෙන් ගත් thumbnail එකක් සමඟ දැනුම්දීමක් දිස්වේ. mpv තුළ file එක play කිරීමට එය click කරන්න.

### webcam overlay එක

ඔබ webcam එකක් සමඟ පටිගත කරන විට, camera එක ඔබ පටිගත කරන දේහි පහළ-දකුණු කෙළවරේ pinned, cropped portrait window එකක් ලෙස දිස්වේ. එය ඔබට අවශ්‍ය දෙයක් මත වසාගෙන සිටී නම්, එසැණින් එහි ප්‍රමාණය වෙනස් කරන්න:

| කෙටි යතුර | කාර්යය |
| ------ | -------- |
| `Super + Alt + [` | webcam overlay එක කුඩා කිරීම |
| `Super + Alt + ]` | webcam overlay එක විශාල කිරීම |

ප්‍රමාණ තුනක් ඇත — small, medium, සහ large — සහ hotkeys ඒවා අතර පියවරෙන් පියවර ගමන් කරයි. Medium පෙරනිමියයි. ඒවා පටිගත කිරීමට සමානුපාතික වේ, එබැවින් ඔබ 1080p monitor එකක් හෝ 6K එකක් පටිගත කළත් camera එක frame එකෙන් එම කොටසම ගනී. ඔබ සම්පූර්ණ display එකක් වෙනුවට ප්‍රදේශයක් පටිගත කළේ නම්, overlay එක monitor එකේ කෙළවරට නොව එම ප්‍රදේශයේ කෙළවරට බැඳෙන බැවින්, එය රූපය තුළම රැඳේ.

ඔබට එය `omarchy-capture-webcam-resize small` සමඟ කෙලින්ම ඇමතිය හැකිය, හෝ medium වෙත ආපසු යාමට `reset` සමඟය.

## පෙළ, QR codes, සහ වර්ණ

`Super + Ctrl + Print Screen` ප්‍රදේශයක් තෝරා එය clipboard එකට OCR කරයි. එය [පෙළ උකහා ගැනීම සහ Dictation](11-text-extraction-dictation.md) තුළ නිසි ලෙස ආවරණය කර ඇත.

_Trigger > Capture > QR Code_ QR codes සඳහා එම උපක්‍රමයම කරයි. code එක ඇති ප්‍රදේශය තෝරන්න, එවිට decode කළ අගය clipboard එකට යයි. එය QR codes පමණක් සොයයි — එසේ නොවුණහොත් ඝන තිර අන්තර්ගතය barcode එකක් ලෙස false-positive වීමේ පුරුද්දක් ඇත. දැනගැනීම වටී: decode කළ අගය clipboard එකට පමණක් යන අතර වෙන කොතැනකටවත් නොයයි. එය මුද්‍රණය නොකෙරේ, එය දැනුම්දීමේ නැත, සහ එය sensitive ලෙස සලකුණු කර ඇති බැවින් [clipboard ඉතිහාසය](08-unified-clipboard-history.md) තුළ රැඳී නොසිටියි. QR codes සාමාන්‍යයෙන් රහස් රැගෙන යයි — උදාහරණයක් ලෙස 2FA setup code එකක් පිටුපස ඇති `otpauth://` URI එක — සහ ඔබට එය log එකක තිබීමට අවශ්‍ය නැත. Pasting තවමත් හොඳින් ක්‍රියා කරයි.

`Super + Print Screen` (හෝ _Trigger > Capture > Color_) cursor එක eyedropper එකක් බවට පත් කරයි. තිරයේ ඕනෑම දෙයක් click කරන්න, එවිට වර්ණය clipboard එකට යයි. තේරීමකින් තොරව ආපසු යාමට hotkey එක නැවත ඔබන්න.

## බෙදා ගැනීමට පෙර transcoding කිරීම

4K තිර පටිගත කිරීමක් හෝ ඔබේ දුරකථනයෙන් ගත් raw HEIC එකක් බොහෝ විට එලෙසම යැවීමට තරම් විශාල වැඩිය. `Super + Ctrl + .` (හෝ _Trigger > Transcode_) එය නිවැරදි කරයි. එය `~/Pictures` සහ `~/Videos` මත fuzzy file picker එකක් ඔබට ලබා දෙන අතර, ඉන්පසු format එකක් සහ size එකක් අසයි.

Pictures jpg හෝ png වෙත high, medium, හෝ low ලෙස යන අතර, ඒවා width එක පිළිවෙළින් 3160, 2160, සහ 1080 pixels වලට සීමා කරයි. Videos mp4 හෝ animated gif එකක් ලෙස 4k, 1080p, හෝ 720p වෙත යයි. පරිවර්තනය කළ file එක මුල් file එක අසලම නමේ resolution එක සමඟ ලියැවේ — `demo-1080p.mp4` — සහ path එක file URI එකක් ලෙස clipboard එකට පිටපත් කෙරේ, එබැවින් file drops ගන්නා app එකකට ඔබට එය කෙලින්ම paste කළ හැකිය.

ඔබට අවශ්‍ය දේ දැනටමත් ඔබ දන්නේ නම්, එය terminal එකෙන්ද ක්‍රියා කරයි: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. `omarchy transcode ascii` ද ඇත, එය රූපයක් ASCII art බවට පත් කරයි — එය බොහෝ දුරට [සන්නාමකරණය](41-branding.md) සඳහාය.

## එය කොතැනකට හෝ යැවීම

file එක ලැබුණු පසු, `Super + Ctrl + S` මඟින් Share මෙනුව විවෘත වන අතර එය LocalSend හරහා ඔබේ network එකේ වෙනත් device එකකට යවයි. ඒ සඳහා [GUIs](22-guis.md) බලන්න.
