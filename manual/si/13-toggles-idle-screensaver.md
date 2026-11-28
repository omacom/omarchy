# ටොගල්, Idle සහ Screensaver එක

ඔබ දිනපතා වෙනස් කරන බොහෝ දේ ඇත්තටම සැකසුමක් නොවේ. එය පැයක් පමණ ක්‍රියාත්මක කර නැවත අක්‍රිය කරන මාදිලියකි: රෑ වන තුරු වැඩ කරන විට night light එක, ඉදිරිපත් කරන විට බාධා නොකරන්න, යමක් නරඹන විට අවදිව සිටීම. Omarchy ඒවාට toggles යැයි කියයි, ඒ සියල්ලම ක්‍රියා කරන්නේ එකම ආකාරයටයි — hotkey එකක්, මෙනු ඇතුළත් කිරීමක් සහ විධානයක්, සියල්ලම එකම switch එකටම පහර දෙයි.

### ටොගල් මෙනුව

`Super + Ctrl + O` මගින් _Trigger > Toggle_ කෙලින්ම විවෘත වේ, නැතහොත් ඔබට Omarchy මෙනුවෙන් (`Super + Space`) එහි යා හැකිය. එම ලැයිස්තුවේ ඇති සියල්ලම, තත්ත්වය කොහේ තිබේදැයි සිතා නොබලා ඔබට පෙරළා දැමිය හැකි switch එකකි. Desktop එක පෙනෙන ආකාරය පිළිබඳ switches ඊට යාබදව, _Appearance_ යටතේ තිබේ.

Terminal එකෙන්, එම switches ම `omarchy toggle <thing>` වේ. මුළු කණ්ඩායමම බැලීමට `omarchy toggle` තනිවම ධාවනය කරන්න.

| ටොගලය | Hotkey එක | විධානය |
| ------ | ------ | ------- |
| රාත්‍රී ආලෝකය | — | `omarchy toggle nightlight` |
| දැනුම්දීම් නිහඬ කරන්න | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| අවදිව සිටින්න (idle lock නැත) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Crash capture එක | — | `omarchy toggle crash-capture` |
| Screensaver එක | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) තේමා සමමුහුර්තය | — | `omarchy toggle theme sync` |
| මෙනු තීරුව | `Super + Shift + Space` | `omarchy toggle bar` |
| සම්පූර්ණ තිර desktop එක (තීරුව නැත, හිඩැස් නැත) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animation, blur සහ සෙවණැලි | — | `omarchy toggle animations` |
| Touchpad එක | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Touchscreen එක | — | `omarchy device touchscreen` |
| Suspend කරන්න | — | `omarchy toggle suspend` |
| Hybrid GPU එක | — | `omarchy device gpu hybrid` |

Touchpad, touchscreen සහ hybrid GPU switches ඇත්තේ Toggle යටතේ නොව _Trigger > Hardware_ (`Super + Ctrl + H`) යටතේය, මන්ද ඒවා දිස්වන්නේ ඔබට ඇත්තටම එම hardware එක ඇති විට පමණක් බැවිනි. Touchpad සහ touchscreen switches Hyprland reload එකකින් පසුවත් රැඳී පවතී — අක්‍රිය කළ device එකේ නම කුඩා state file එකක සුරැකෙන අතර, එය නැවත අක්‍රිය කිරීමට Hyprland ආරම්භයේදී එය කියවයි.

_Appearance_ තුළ මෙනු තීරුව සහ animation ඇත, තවද `omarchy toggle` විධාන නොවුණත් ඒ ආකාරයටම හැසිරෙන දේ කිහිපයක්ද ඇත: තීරුවේ battery ප්‍රතිශතය, පෙරනිමි workspace layout එක, සහ _Windows_ යටතේ, window හිඩැස් (`Super + Shift + Backspace`) සහ 1-window square aspect එක (`Super + Ctrl + Backspace`).

Hyprland හට ඇඳීමට GPU එකක් නැතිව CPU එකෙන් render කරන විට (llvmpipe), GPU එක තවම සහාය නොදක්වන Mac වල, බොහෝ virtual machine වල, නැතහොත් graphics driver එකක් load වීමට අසමත් වූ විට වැනි, Omarchy එම session එක සඳහා animation, blur සහ සෙවණැලි ක්‍රියාවිරහිත කර, දැනුම්දීමකින් ඒ බව ඔබට එක් වරක් කියයි. _Appearance > Animations On_ මගින් ඒවා ආපසු ගෙන එන අතර, පසුකාලීන session සඳහාද Omarchy එය මතක තබා ගනියි.

මේවායින් බොහොමයක්ම `~/.local/state/omarchy/toggles/` යටතේ ඇති flag file එකක් පමණි. Script එකකදී එකක් මත branch වීමට ඔබට අවශ්‍ය නම්, එය සොයන්නට යනවා වෙනුවට `omarchy-toggle-enabled` ඔබට exit code එකක් දෙයි:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flags නම් කර ඇත්තේ off තත්ත්වය අනුවයි — `screensaver-off`, `suspend-off`, `bar-off` — එබැවින් ඒවා තිබීම යනු feature එක අක්‍රිය කර ඇති බවයි.

### තීරුවේ දර්ශක

මාදිලියක් ක්‍රියාත්මක වූ විට, ඔරලෝසුව අසල ඉහළ තීරුවේ මැද ඔබට කුඩා glyph එකක් ලැබේ. එය indicators widget එක වන අතර, එහි screen recording, εκκρεමείς මතක් කිරීම්, රාත්‍රී ආලෝකය, බාධා නොකරන්න සහ අවදිව සිටීම ඇති අතර, passwordless sudo ක්‍රියාත්මක වී ඇති විට හෝ යමෙකු remote session එකකට සම්බන්ධ වී ඇති විට අනතුරු ඇඟවීම්ද ඇත.

අක්‍රිය දර්ශක සැඟ වී ඇත. තීරුවේ ඕනෑම තැනක hover කරන්න, ඒවා මඳ අඳුරු වී මතුවේ, එවිට එහි hotkey එක නොදැන වුවත් ඔබට එකක් ක්ලික් කර ක්‍රියාත්මක කළ හැකිය. සක්‍රිය එකක් ක්ලික් කිරීමෙන් එය නැවත ක්‍රියාවිරහිත වේ. ඔබට ඒවා සියල්ලම සැමවිටම දැකීමට අවශ්‍ය නම්, `~/.config/omarchy/shell.json` හි `omarchy.indicators` ඇතුළත් කිරීමේ `alwaysShow` `true` ලෙස සකසන්න — තීරු widgets වින්‍යාස කරන ආකාරය සඳහා [ඉහළ තීරුව](05-the-top-bar.md) බලන්න.

### රාත්‍රී ආලෝකය

රාත්‍රී ආලෝකය තිරය 4000K දක්වා උණුසුම් කරයි, එය නැවත toggle කිරීමෙන් එය 6500K වෙත ආපසු යයි. ටොගල් මෙනුවෙන් (`Super + Ctrl + O`) නැතහොත් `omarchy toggle nightlight` මගින් එය පෙරළන්න. එය hyprsunset මගින් ධාවනය වන අතර, එය දැනටමත් ධාවනය නොවන්නේ නම් toggle එක ඔබ වෙනුවෙන් එය ආරම්භ කරයි.

පෙරනිමියෙන් hyprsunset ඔබේ තිරයට කිසිවක්ම නොකරයි. `~/.config/hypr/hyprsunset.conf` identity profile එකක් සමඟ එන්නේ හරියටම ඔබට උණුසුම ඉල්ලන තුරු display එක නොඇල්ලී තැබීමටයි. ඒ වෙනුවට ඔරලෝසුව අනුව මාරු වීමට ඔබට අවශ්‍ය නම්, එය time profile එකකින් ප්‍රතිස්ථාපනය කරන්න:

```
profile {
    time = 20:00
    temperature = 4000
}
```

ඉන්පසු `~/.config/hypr/autostart.lua` වෙත `o.launch_on_start("hyprsunset")` එක් කිරීමෙන් login එකේදී hyprsunset ආරම්භ කරන්න. Toggle එක භාවිත කරන 4000K/6500K යුගලය ස්ථාවරය, එබැවින් ඔබට වෙනත් temperature එකක් අවශ්‍ය නම් යා යුතු තැන config file එකයි.

### බාධා නොකරන්න

`Super + Ctrl + Alt + ,` දැනුම්දීම් නිහඬ කරයි. එය ක්‍රියාත්මකව ඇති අතරතුර කිසිදු toast එකක් මතුවන්නේ නැත, desktop එක නිහඬ වූයේ ඇයිදැයි ඔබට මතක් කිරීමට හරස් කළ සීනු දර්ශකය තීරුවේ රැඳී සිටියි.

කෙසේ වෙතත් කිසිවක් නැති වන්නේ නැත. නිහඬ කළ දැනුම්දීම් රඳවා තබා ගනියි: අන්තිම කිහිපය `Super + Shift + Alt + ,` මගින් ආපසු තිරයට ගෙන එන්න. ඉතිරිය සඳහා [දැනුම්දීම්](10-notices.md) බලන්න.

පණිවිඩ වර්ග තුනක් තවමත් හරහා එයි: ඔබ මේ දැන් කළ දෙයක් සඳහා Omarchy හිම තහවුරු කිරීමේ toast ("තේමාව වෙනස් විය", "Screenshot එක සුරකින ලදි"), command line එකෙන් එවන critical alerts, සහ verification codes. ඔබ ඉදිරිපිටට තමන්ව බලෙන් ගෙන ඒමට සියල්ල critical ලෙස සලකුණු කරන chat apps ඒ සඳහා සුදුසු නොවේ.

### Idle එක

Omarchy shell එක idle හැසිරීම හිමි කර ගනියි, එහි වේලාවන් `~/.config/omarchy/shell.json` හි ඉහළ මට්ටමේ `idle` block එකකි:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

අංක දෙකම ඔබ idle වූ මොහොතේ සිට ගණනය කරන තත්පර වේ — එකිනෙකාගෙන් නොවේ. එබැවින් පෙරනිමි සමඟ, විනාඩි දෙකහමාරකට පසු screensaver එක එන අතර screensaver එක ධාවනය වූවා හෝ නැතා හෝ විනාඩි පහේදී lock screen එක භාර ගනියි. File එක save කරන්න, shell එක නව වේලාවන් වහාම ලබා ගනියි.

Lock deadline එකට පෙර ඔබ screensaver එක ඉවත් කළහොත්, එය ක්‍රියාකාරකමක් ලෙස ගණන් ගන්නා අතර εκκρεමී lock එක අවලංගු වේ. ඔබේ machine එක දෙස බැලීම නිසා ඔබ lock out වන්නේ නැත.

Idle වීමේදී locking සම්පූර්ණයෙන්ම නැවැත්වීමට, `Super + Ctrl + I` — නැතහොත් `omarchy toggle idle` — stay awake ක්‍රියාත්මක කරන අතර, කෝපි කෝප්ප දර්ශකය තීරුවේ දිස්වේ. දිගු ඉදිරිපත් කිරීමකට පෙර හෝ ඔබ බලා සිටීමට කැමති build එකකට පෙර පහර දිය යුත්තේ එයටයි. සාමාන්‍ය තත්ත්වයට ආපසු යාමට එයට නැවත පහර දෙන්න. Script එකකින් ඔබට එය අවශ්‍ය නම් `omarchy toggle idle status` වත්මන් තත්ත්වය JSON ලෙස මුද්‍රණය කරයි.

මෙය බලය ගැන නොව locking සහ screensaver එක ගැනය. Suspend සහ hibernation සඳහා [පද්ධති නින්ද](36-system-sleep.md) හි ඒවාටම වෙන් වූ සැකසුම ඇත.

### Screensaver එක

Omarchy හි screensaver එක අහඹු text effects හරහා ධාවනය වන ASCII art එකක් වන අතර, monitor එකකට එක instances බැගින් ඇත. ඕනෑම key එකක් හෝ mouse චලනයක් එයින් පිටත් වේ.

ඔබට එය _System > Screensaver_ (`Super + Esc`) වෙතින් ඉල්ලුම මත ආරම්භ කළ හැකි අතර, ඔබ idle screensaver එක ක්‍රියාවිරහිත කර තිබුණත් එය බලෙන් ඉහළට ගෙන එයි. පෙරනිමියෙන් එයට කිසිදු hotkey එකක් බැඳී නැත.

ඔබට වැඩ කිරීමේ සිට කෙලින්ම locked වීමට කැමති නම්, idle එක ක්‍රියාවිරහිත කරන්නේ `omarchy toggle screensaver` යි. ඕනෑම key එකක්, click එකක්, scroll එකක් හෝ mouse චලනයක් එය වැසෙයි.

එය අඳින logo එක වෙනස් කිරීම ඔබ සතුය, _Appearance > Branding > Screensaver_ යටතේය. png එකක් හෝ svg එකක් upload කරන්න, Omarchy එය ASCII බවට පරිවර්තනය කරයි. [සන්නාමකරණය](41-branding.md) බලන්න.

### අගුළු තිරය

`Super + Ctrl + L` machine එක lock කරයි. එය Omarchy shell එකෙන් lock screen එක ධාවනය කරයි, display එක හිස් කරයි, ඔබේ මුරපදය වැරදි අකාරාදියකින් type නොකිරීමට ඔබේ keyboard layout එක පළමු එක වෙත reset කරයි, සහ — ඔබ එය ධාවනය කරගෙන සිටී නම් — පිටත් වන අතරමඟදී 1Password lock කරයි.

Lock screen එක මුරපදයක් ගන්නා අතර, ඔබ එකක් සකසා ගත් පසු එය fingerprint එකක්ද ගනියි. එය සහ සත්‍යාපනය කිරීමට ඇති අනෙකුත් ක්‍රම [දෘඩාංග සත්‍යාපනය](37-hardware-authentication.md) හි ආවරණය වේ.
