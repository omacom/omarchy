# තිරපිටපත් සහ පටිගත කිරීම

තිරයෙන් ගත හැකි සියල්ලම Print Screen යතුර වටා රැඳී ඇත. යතුර තනිවම පින්තූරයක් ගනී, modifiers යතුරු පටිගත කිරීමක්, වර්ණයක්, හෝ ප්‍රදේශයක් තුළ ඇති පෙළ ගනී. ඔබේ keyboard එකේ Print Screen යතුරක් කිසිසේත්ම නැත්නම්, `Super + Ctrl + Alt + C` එම තිරපිටපතම ගනී, `Super + Ctrl + C` මුළු කට්ටලයම menu එකක් ලෙස විවෘත කරයි.

| යතුරු කෙටිමඟ | ක්‍රියාකාරිත්වය |
| ------ | -------- |
| `Print Screen` | තිරපිටපත |
| `Super + Ctrl + Alt + C` | තිරපිටපත |
| `Alt + Print Screen` | Screenrecord (හෝ දැනට ධාවනය වන එක නවත්වන්න) |
| `Super + Print Screen` | වර්ණ තෝරකය |
| `Super + Ctrl + Print Screen` | ප්‍රදේශයකින් පෙළ උපුටා ගන්න |
| `Super + Ctrl + C` | Capture menu |
| `Super + Ctrl + .` | පින්තූරයක් හෝ වීඩියෝවක් transcode කරන්න |

## තිරපිටපත්

`Print Screen` (හෝ `Super + Ctrl + Alt + C`) ඔබන්න, Omasnap එහි overlay එක දිස්වීමට පෙර focus වී ඇති monitor එක capture කරයි, එබැවින් ඔබ ඉලක්ක කරන අතරතුර කිසිවක් ඔබ යටින් මාරු නොවේ. නිදහස් හැඩයක ප්‍රදේශයක් drag කරන්න, window එකක් capture කිරීමට එය click කරන්න, හෝ මුළු monitor එකම capture කිරීමට විවෘත ඉඩ click කරන්න. ඇඳීමට පෙර scrolling ප්‍රදේශයක් capture කිරීමට `S` ඔබන්න. අදහස වෙනස් කළාද? Omasnap ඉවත දැමීමට එම යතුරම නැවත ඔබන්න.

ඔබ ප්‍රදේශයක් තෝරාගත් පසු, Omasnap capture එක save කරයි, එය clipboard එකට copy කරයි, තත්පර 10ක් preview එකක් පෙන්වයි. එය තිරයේ රඳවා ගැනීමට preview එකේ pin බොත්තම හෝ `Ctrl + P` භාවිතා කරන්න, නැතහොත් එය annotate කිරීමට Edit තෝරන්න.

Annotation editor එකට arrows, lines, shapes, highlights, අංකිත markers, text, සහ secure redactions ඇඳිය හැකිය; image එකේ කොටසක් crop කිරීමට හෝ කපා ඉවත් කිරීමට හැකිය; එහි text OCR කිරීමට හැකිය; සහ backdrop එකක් එක් කිරීමට හැකිය. Editor එකේදී, අවසන් PNG එක copy කර save කිරීමට `Enter` ද, save නොකර copy කිරීමට `Ctrl + C` ද, copy නොකර save කිරීමට `Ctrl + S` ද ඔබන්න.

Saved screenshots පෙරනිමියෙන් `~/Pictures/Screenshots` තුළට වැටේ, `screenshot-2026-08-13_14-22-05-firefox.png` වැනි නමක් සමඟ. වෙනත් directory එකක් භාවිතා කිරීමට `OMASNAP_SCREENSHOT_DIR` සකසන්න — session environment variables තැබිය යුත්තේ කොහේද යන්න සඳහා [නිතර අසන ප්‍රශ්න](46-faq.md) බලන්න. Omasnap පළමු shot එක save කරන විට එම directory එක සාදයි. ස්වයංක්‍රීයව save කිරීම අක්‍රිය කිරීමට `~/.config/omasnap/omasnap.conf` තුළ `[output] autosave = false` සකසන්න.

Terminal එකෙන්, `omarchy screenshot` එකම overlay එක විවෘත කරයි, එහි ආරම්භක mode එකද ඔබට තෝරාගත හැකිය: `omarchy capture screenshot region`, `windows`, `fullscreen`, හෝ `scroll`. දෙවන argument එක ලෙස `copy` හෝ `save` දුන්නොත් preview එක මග හැර shot එක කෙලින්ම එම ගමනාන්තයට යවයි. ප්‍රතිදානයට පෙර edit කිරීමට, fullscreen editor එකක් සඳහා `omarchy screenshot --editor=overlay` හෝ වෙනම window එකක් සඳහා `omarchy screenshot --editor=window` භාවිතා කරන්න.

### යතුරු පුවරුවෙන් picker එක මෙහෙයවීම

Selection එක දිස්ව තිබෙන අතරතුර, mouse එක කිසිසේත්ම භාවිතා කිරීමට ඔබට අවශ්‍ය නැත:

| යතුර | ක්‍රියාකාරිත්වය |
| --- | -------- |
| `S` | Scrolling-region mode එක toggle කරන්න |
| `Super + Arrow keys` | Window mode එකේදී windows අතර ගමන් කරන්න |
| `Return` | Highlight වී ඇති window එක capture කරන්න |
| `Ctrl + A` | Focus වී ඇති සම්පූර්ණ monitor එක capture කරන්න |
| `R` | මෙම session එකේදී අවසන් වරට ඇඳි ප්‍රදේශය restore කරන්න |
| `Esc` | Omasnap ඉවත දමන්න |

මෙම bindings පවතින්නේ Omasnap විවෘතව තිබෙන අතරතුර පමණි, එබැවින් ඒවාට ඔබේම config එකේ කිසිවක් සමඟ ගැටිය නොහැකිය.

## තිරය පටිගත කිරීම

`Alt + Print Screen` මඟින් _Trigger > Capture > Screenrecord_ විවෘත වන අතර, soundtrack එකේ තිබිය යුත්තේ කුමක්දැයි එය ඔබෙන් අසයි: audio නැත, desktop audio, desktop සහ microphone, හෝ desktop සහ microphone සහ webcam. ඔබට ඇත්තටම camera එකක් සම්බන්ධ කර ඇත්නම් පමණක් අවසන් විකල්පය දිස් වේ. එකක් තෝරන්න, Omarchy හි recording picker එක ඔබට ප්‍රදේශයක් drag කිරීමට හෝ window එකක් හෝ monitor එකක් click කිරීමට ඉඩ දෙයි.

Recording එක gpu-screen-recorder මත ධාවනය වේ, එය GPU එක මත 60fps වලින් encode කරයි, අවශ්‍ය වුවහොත් CPU එකට මාරු වේ. ප්‍රතිඵලය `~/Videos` තුළ ඇති MP4 එකක් වන අතර, එය `screenrecording-2026-08-13_14-22-05.mp4` ලෙස නම් කෙරේ. එය වෙනස් කිරීමට `OMARCHY_SCREENRECORD_DIR` සකසන්න — නමුත් screenshot directory එකට මෙන් නොව, මෙය දැනටමත් පැවතිය යුතු බව සලකන්න, එසේ නොමැති නම් recording එක ආරම්භ වීම ප්‍රතික්ෂේප කරයි.

ඔබ recording කරන අතරතුර, bar එකේ කුඩා indicator එකක් දිස් වේ. එය නවත්වීමට click කරන්න. ඔබට එය `Alt + Print Screen` නැවත එබීමෙන්ද, නැතහොත් _Trigger > Capture > Screenrecord_ යට ඇති _Stop Screenrecording_ entry එකෙන්ද නැවැත්විය හැකිය, එය දිස් වන්නේ ඇත්තටම යමක් recording වෙමින් පවතින විට පමණි.

නැවැත්වීම ඔබට file එක ලබා දීමට පෙර මඳක් පිරිසුදු කිරීමක් කරයි: පළමු frame එක trim කරනු ලැබේ, audio තිබේ නම් එය -14 LUFS වෙත normalize කරනු ලබන අතර ආරම්භයේම ඇති PipeWire capture pop ශබ්දය mute කරනු ලැබේ. ඉන්පසු recording එකෙන් ගත් thumbnail එකක් සමඟ notification එකක් දිස් වේ. mpv තුළ file එක play කිරීමට එය click කරන්න.

### Webcam overlay එක

ඔබ webcam එකක් සමඟ record කරන විට, ඔබ record කරන ඕනෑම දෙයක පහළ-දකුණු කෙළවරේ camera එක pinned, cropped portrait window එකක් ලෙස දිස් වේ. එය ඔබට අවශ්‍ය යමක් මත රැඳී තිබේ නම්, ක්ෂණිකවම එය resize කරන්න:

| යතුරු කෙටිමඟ | ක්‍රියාකාරිත්වය |
| ------ | -------- |
| `Super + Alt + [` | Webcam overlay එක කුඩා කරන්න |
| `Super + Alt + ]` | Webcam overlay එක විශාල කරන්න |

ප්‍රමාණ තුනක් ඇත — small, medium, සහ large — hotkeys ඒවා අතර පියවරෙන් පියවර ගමන් කරයි. Medium පෙරනිමියයි. ඒවා recording එකට සමානුපාතික වේ, එබැවින් ඔබ 1080p monitor එකක් හෝ 6K එකක් record කළත් camera එක frame එකෙන් එකම කොටසක් ගනී. ඔබ සම්පූර්ණ display එකක් නොව ප්‍රදේශයක් record කළේ නම්, overlay එක monitor එකේ කෙළවරට නොව එම ප්‍රදේශයේ කෙළවරට රැඳෙන බැවින් එය shot එක ඇතුළතම රැඳේ.

ඔබට එය `omarchy-capture-webcam-resize small` සමඟ කෙලින්මද ඇමතිය හැකිය, නැතහොත් medium වෙත ආපසු යාමට `reset` භාවිතා කළ හැකිය.

## පෙළ, QR කේත, සහ වර්ණ

`Super + Ctrl + Print Screen` ප්‍රදේශයක් තෝරා එය clipboard එකට OCR කරයි. එය [පෙළ උපුටා ගැනීම සහ Dictation](11-text-extraction-dictation.md) තුළ නිසි ලෙස ආවරණය කර ඇත.

_Trigger > Capture > QR Code_ QR කේත සඳහාද එම උපක්‍රමයම කරයි. කේතය ඇති ප්‍රදේශය තෝරන්න, decode කළ අගය clipboard එකට යයි. එය QR කේත පමණක් සොයයි — නැතහොත් ඝන තිර අන්තර්ගතය barcode එකක් ලෙස false-positive වීමට පුරුදු වී ඇත. දැන ගැනීම වටී: decode කළ අගය clipboard එකටම මිස වෙන කොහේවත් නොයයි. එය මුද්‍රණය වන්නේ නැත, notification එකේ නැත, එය සංවේදී ලෙස සලකුණු කර ඇති නිසා [clipboard history](08-unified-clipboard-history.md) තුළ රැඳෙන්නේ නැත. 2FA setup code එකක් පිටුපස ඇති `otpauth://` URI එක උදාහරණයක් ලෙස ගතහොත්, QR කේත නිතිපතා රහස් රැගෙන යයි — ඔබට එය log එකක තිබීම අවශ්‍ය නැත. Pasting තවමත් හොඳින් ක්‍රියා කරයි.

`Super + Print Screen` (හෝ _Trigger > Capture > Color_) cursor එක eyedropper එකක් බවට පත් කරයි. තිරයේ ඕනෑම දෙයක් click කළ විට වර්ණය clipboard එකට වැටේ. නොතෝරාම ආපසු යාමට hotkey එක නැවත ඔබන්න.

## බෙදා ගැනීමට පෙර transcoding කිරීම

4K screen recording එකක් හෝ ඔබේ දුරකථනයෙන් ගත් raw HEIC එකක් බොහෝ විට එලෙසම යැවීමට විශාල වැඩිය. `Super + Ctrl + .` (හෝ _Trigger > Transcode_) එය නිවැරදි කරයි. එය `~/Pictures` සහ `~/Videos` මත fuzzy file picker එකක් ඔබට ලබා දී, පසුව format එකක් සහ size එකක් ඉල්ලයි.

Pictures jpg හෝ png වෙත යන්නේ high, medium, හෝ low වලින් වන අතර, ඒවා width එක පිළිවෙලින් 3160, 2160, සහ 1080 pixels වලට සීමා කරයි. Videos mp4 හෝ animated gif එකකට යන්නේ 4k, 1080p, හෝ 720p වලිනි. Convert කළ file එක නමේ resolution එක සමඟ මුල් file එක අසලම ලියනු ලැබේ — `demo-1080p.mp4` — එහි path එක file URI එකක් ලෙස clipboard එකට copy කරනු ලැබේ, එබැවින් file drops ගන්නා app එකකට එය කෙලින්ම paste කළ හැකිය.

ඔබට අවශ්‍ය දේ දැනටමත් දන්නේ නම්, එය terminal එකෙන්ද ක්‍රියා කරයි: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. `omarchy transcode ascii` ද ඇත, එය image එකක් ASCII art බවට පත් කරයි — එය බොහෝ දුරට [සන්නාමකරණය](41-branding.md) සඳහායි.

## එය කොහේ හෝ යැවීම

ඔබට file එක ලැබුණු පසු, `Super + Ctrl + S` Share menu එක විවෘත කර LocalSend හරහා ඔබේ network එකේ වෙනත් device එකකට එය යවයි. ඒ සඳහා [GUIs](22-guis.md) බලන්න.
