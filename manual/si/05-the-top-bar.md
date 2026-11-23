# ඉහළ තීරුව

ඔබේ තිරයේ ඉහළින් ඇති තීරුව Omarchy bar එකයි. එය වෙනම ගසා සවි කළ status bar එකක් නොව, Omarchy shell එකේම කොටසකි — මෙනුව, දැනුම්දීම්, OSD popups සහ lock screen එකද අඳින, දිගු කලක් ක්‍රියාත්මක වන එකම Quickshell process එකයි. ඒ නිසාම එය අනෙක් සියල්ල සමඟම පරිපූර්ණ ලෙස තේමාවට ගැලපෙන අතර, panel එකක් නව app එකක් spawn කිරීම වෙනුවට ක්ෂණිකව විවෘත වේ.

එය desktop එකේ සැමවිටම තිරයේ පවතින එකම කොටසද වන බැවින්, එම කුඩා glyphs සියල්ල කරන්නේ කුමක්ද යන්න දැනගැනීම වටී.

## පෙරනිමියෙන් එහි ඇත්තේ මොනවාද

තීරුවට කොටස් තුනක් ඇත. වම් පැත්තේ Omarchy logo එක (මෙනු launcher එක) සහ workspace indicators ඇත. මධ්‍යයේ ඔබට status indicators, ඔරලෝසුව, Elsewhen (ලෝක ඔරලෝසුවක්), කාලගුණය සහ Omarchy update badge එක ලැබේ. දකුණු පැත්තේ: system tray එක, keyboard layout එක (layout එකකට වඩා හෝ input method එකක් configure කර ඇති විට), agents, bluetooth, network, audio, display සහ power.

ඒවායින් කිහිපයක්ම දිස්වන්නේ ඒවාට කීමට යමක් ඇති විට පමණි. Keyboard layout එක දිස්වන්නේ ඔබ layout එකකට වඩා හෝ input method එකක් configure කර ඇත්නම් පමණි. Update badge එක දිස්වන්නේ Omarchy update එකක් බලාපොරොත්තුවෙන් ඇති විට පමණි.

## ක්ලික් කරමින් සැරිසැරීම

සෑම විජට් එකක්ම පාහේ වම්, දකුණු සහ මැද ක්ලික් කිරීමේදී යමක් කරන අතර, කිහිපයක් scroll කිරීමටද ප්‍රතිචාර දක්වයි. මෙය මිනිසුන්ට මගහැරෙන කොටසයි — දකුණු සහ මැද බොත්තම්වල බොහෝ හොඳ දේ සඟවා ඇත්තේය.

| විජට් එක | වම | දකුණ | මැද / scroll |
| --- | --- | --- | --- |
| මෙනුව | Omarchy මෙනුව | නව terminal එකක් | — |
| Workspaces | මෙම monitor එකේ එම workspace එක focus කරන්න | — | Scroll: ඊළඟ/පෙර workspace එක |
| ඔරලෝසුව | Calendar popup එක | label format එක චක්‍රීයව මාරු කරන්න | මැද: timezone picker එක |
| ලෝක ඔරලෝසුව | World clock panel එක | Refresh කරන්න | මැද: refresh කරන්න |
| කාලගුණය | Forecast popup එක | සම්පූර්ණ කාලගුණය දැනුම්දීමක් ලෙස | මැද: refresh කරන්න |
| Audio | Audio panel එක | Mute කරන්න | මැද: panel එක · scroll: volume |
| Microphone | mic එක mute කරන්න | — | මැද: audio panel එක · scroll: input volume |
| Network | Network panel එක | — | — |
| Bluetooth | Bluetooth panel එක | radio එක toggle කරන්න | — |
| Display | Display panel එක | — | Scroll: brightness |
| Power | Power panel එක | battery percentage එක toggle කරන්න | — |
| Media | Play/pause | Cover-art popup එක | මැද: ඊළඟ · scroll: පෙර/ඊළඟ |
| Agents | Agents panel එක | ඔබේ agent එක launch කරන්න | මැද: usage refresh කරන්න |
| Tray | drawer එක හෙළි කිරීමට hover කරන්න | කළමනාකරණය කිරීමට chevron එක මත දකුණු-ක්ලික් කරන්න | — |
| Omarchy update | update එක ධාවනය කරන්න | — | — |

එම වගුවේ ඇති සියල්ලම මුල සිටම ඔබේ තීරුවේ නැත. Media විජට් එක (scroll වන track එකක් සහ artist කෙනෙක් සහිත MPRIS now-playing) සහ microphone විජට් එක යන දෙකම built-in වුවත්, පෙරනිමියෙන් අක්‍රියව ඇත — ඔබට ඒවා අවශ්‍ය නම්, පහත විස්තර කර ඇති පරිදි ඒවා එක් කරන්න.

## Panels

තීරුවේ අයිකනයක් ක්ලික් කිරීමෙන් panel එකක් විවෘත වන අතර, එය tooltip එකක් වෙනුවට sliders, lists සහ keyboard navigation සහිත සුදුසු popup එකකි. සෑම එකකටම hotkey එකක්ද ඇති බැවින්, ඔබට කිසිවිටෙක pixel 16ක glyph එකක් ඉලක්ක කිරීමට සිදු නොවේ:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + X` | Agents |
| `Super + Ctrl + 1-9` | දකුණු කොටසේ n වැනි panel එක toggle කරන්න |

Panels යනු කියවීමට පමණක් ඇති දේ නොවේ. ඔබ සැබැවින්ම එම දෙය කරන්නේ ඒවා තුළින්ය:

- **Audio** හි master volume slider එකක්, output-device picker එකක් සහ per-app mixer එකක් ඇති බැවින්, අනෙක් සියල්ල නොඅල්ලාම එම එක browser tab එක නිහඬ කළ හැක.
- **Network** Wi-Fi සඳහා scan කරයි, signal strength එක පෙන්වයි, සම්බන්ධ වේ, සහ DNS provider කෙනෙක් තෝරා ගැනීමට ඔබට ඉඩ දෙයි.
- **Bluetooth** connect/disconnect සහ battery levels සහිතව ඔබේ උපාංග ලැයිස්තුගත කරයි.
- **Power** battery stats පෙන්වයි, power profiles මාරු කරයි (එය battery සහ AC සඳහා වෙනම තේරීමක් මතක තබා ගනී), සහ යම් system info මුද්‍රණය කරයි.
- **Display** හි brightness slider එකක්, text size, monitor scaling presets සහ — ඔබට තිර එකකට වඩා ඇති විට — per-monitor controls ඇත. ගැඹුරු කතාව සඳහා [මොනිටර](33-monitors.md) බලන්න.
- **Clock** ISO week numbers සහ month stepping සහිත month grid එකක් විවෘත කරයි.
- **World clock** එහි කාලගුණය සහ එහි දවස ගෙවෙන ආකාරය සමඟ, නගරයකට එක පේළිය බැගින් තබා ගනී. Search මඟින් time zones මෙන්ම නගරද සොයා ගන්නා බැවින්, Fort Lauderdale යනු Fort Lauderdale මිස New York නොවේ. ඉහළින් ඇති පේළිය වැරදි නගරයක් නම් කරයි නම්, එය ක්ලික් කර ඔබ සිටින තැන කියන්න; වෙනත් time zone එකක තැනක් තෝරන්න, එවිට system clock එකද එහි යන බැවින්, ඔබ සංචාරය කරන විට එය පහසු වේ. නගරයක් මත hover කර, එහි ජීවත් වන්නේ කවුරුන්දැයි කීමට person බොත්තම ක්ලික් කරන්න — සරල නම් හෝ ඔවුන්ගේ මුහුණුද සමඟ රැගෙන ඒමට `@` GitHub handles.

සෑම panel එකක්ම mouse එක මෙන්ම keyboard එකද ගනී: arrows චලනය වේ, Return සක්‍රිය කරයි, Tab අසල්වැසි panel එකට පියවර තබයි, සහ Escape වසා දමයි.

`Super + Ctrl + 1-9` දකුණු කොටසේ වමේ සිට දකුණට panels ගණන් කරයි, tray එකට එයටම අයත් panel එකක් නොමැති බැවින් එය මඟ හරිමින්. එබැවින් අංකය ඔබ යොමු කරන අයිකනයට ගැලපේ.

### Tailscale සහ Dropbox

තවත් විජට් දෙකක් තීරුවේ දිස්වන්නේ ඔබ **Install → Service** වෙතින් ගැලපෙන සේවාව ස්ථාපනය කළ පසු පමණක් වන අතර, ඒවා දෙකම status වාර්තා කිරීමට වඩා වැඩි දෙයක් කරන බැවින් දැනගැනීම වටී.

**Tailscale** panel එක tailnet එක සම්බන්ධ කර විසන්ධි කරයි, ගිණුම් අතර මාරු වේ, සහ exit node එකක් තෝරයි (ඔබේම machines සහ Mullvad regions යන දෙවර්ගයම එම ලැයිස්තුවේ දිස් වේ). එය ඔබේ machines ද බ්‍රවුස් කරයි — සහ එකක් තෝරාගත් පසු, `s` එයට Taildrop හරහා ගොනු යවයි, එය ඔබේ දුරකථනයට හෝ වෙනත් laptop එකකට ගොනුවක් ගෙන යාමට ඇති වේගවත්ම මාර්ගයයි. `c` machine එකේ IP එක පිටපත් කරයි, `n` එහි නම, සහ `d` එහි සම්පූර්ණ DNS නම. ඔබට ක්ලික් කිරීමට කැමති නම්, සෑම machine පේළියකම send බොත්තමක්ද ඇත. Terminal එකෙන් එම දෙයම වන්නේ `omarchy tailscale send <machine> [file...]` යන්නයි.

**Dropbox** panel එක login හසුරුවයි, ඔබ කොපමණ storage ප්‍රමාණයක් භාවිතා කර ඇත්දැයි පෙන්වයි, සහ මෑතකදී synced කළ ගොනු ලැයිස්තුගත කරයි.

එම සේවා දෙකෙන් ඕනෑම එකක් ඉවත් කිරීම එහි විජට් එක නැවත තීරුවෙන් ඉවත් කරයි.

## Indicators

මධ්‍යයේ ඇති කුඩා පොකුර indicators විජට් එකයි. මේවා ඔබ සක්‍රිය කළ modes සඳහා වන status glyphs වේ: do not disturb, night light, පෙළ ගැසූ [මතක් කිරීමක්](09-reminders.md), සක්‍රිය screen recording එක, සහ stay awake, ඊට අමතරව passwordless sudo සක්‍රියව ඇති අතරතුර හෝ යමෙක් remote session එකකට සම්බන්ධ වී ඇති විට අනතුරු ඇඟවීම්. Mode එක සක්‍රිය විට ඒවා දැල්වෙන අතර, එසේ නොමැති නම් මාර්ගයෙන් ඉවත්ව සිටී — අක්‍රිය ඒවා තිබෙන තැනට ආසන්නව, ඒවා දෙස බැලීමට ඒ අසලම hover කරන්න. Indicator එකක් ක්ලික් කිරීමෙන් එම mode එක toggle වේ. තව එකක් status සඳහා පමණි: යමෙක් gliff හරහා මෙම machine එකට සම්බන්ධ වී ඇති අතරතුර remote session එකක් රතු පැහැයෙන් දැල්වේ.

ඔබ ඒවා සැමවිටම දෘශ්‍යමානව තිබීමට කැමති නම්, විජට් එකේ `alwaysShow` යන්න `true` ලෙස සකසන්න. ඔබ සැලකිලිමත් වන්නේ ඒවායින් කිහිපයක් ගැන පමණක් නම්, ඔබට අවශ්‍ය ඒවා `items` හි ලැයිස්තුගත කරන්න: `["Dnd", "Reminder", "NightLight"]`. ඔබට indicators විජට් එකකට වඩා තිබිය හැකි බැවින්, විවිධ කොටස්වලට විවිධ උපකුලක පෙන්විය හැක.

## තීරුව නැවත සකස් කිරීම

තීරුව තමාම configure කර ගනී. දේවල් ගෙන යාමට ඔබට config ගොනුවක් විවෘත කිරීමට සිදු නොවේ.

මධ්‍යය වටා තීරුවේ හිස් ස්ථානයක් අල්ලා එය වෙනත් තිර දාරයක් දෙසට ඇදගෙන යන්න, එවිට තීරුව එහි යයි — වම, දකුණ, ඉහළ හෝ පහළ යන සියල්ල ක්‍රියා කරන අතර, සෑම විජට් එකක්ම අනුගත වේ (vertical bars සංයුක්ත icon-only ආකාරවලට ආපසු යයි). Click-and-hold එකකින්ද එම ඇදගෙන යාමම ආරම්භ වේ. එම හිස් ඉඩම දෙවරක් වම්-ක්ලික් කිරීමෙන් තීරුවේ පසුබිම clear සිට glassy දක්වා සහ opaque දක්වා චක්‍රීයව මාරු කරන්න. තවද ඕනෑම විජට් එකක් ඇදගෙන ගොස් එය නැවත සකස් කිරීමට හෝ වෙනත් කොටසකට විසි කිරීමට; අනෙක් විජට් එය පතිත වන ස්ථානයේ ඉඩ සැලසීමට දෙපසට ලිස්සා යයි.

තීරුවේ මැද box එකකි: එහි ඇති ඕනෑම දෙයක් එක කණ්ඩායමක් ලෙස මධ්‍යයේ පවතින අතර, එහි දෙපස ඇති විජට් එහි දාරවලින් එල්ලේ. ඔබ විජට් එකක් ඇදගෙන යන අතරතුර, box එක outline එකක් ලෙස පෙන්වයි, හෝ එය හිස් විට තීරුව හරහා රේඛාවක් ලෙස පෙන්වයි, ඔබට එහි හෝ එය අසලම වැටිය හැක. Drop එකක් box එක තුළ පතිත වීමට යන විට, box එක විජට් එක ඇතුළට ගැනීමට විශාල වේ.

ඔබට අවට තබා ගැනීමට අවශ්‍ය නමුත් සැමවිටම නොපෙනෙන විජට් එකක් tray එකේ drawer එකට යා හැක: එය tray එක මතට ඇදගෙන යන්න, එවිට drawer එක එය ගැනීමට විවෘත වේ. එය app අයිකනවලින් පසුව එහි හිඳින අතර, drawer එක දිස්වන සෑම විටම දිස් වේ, සහ එහි panel එක ක්‍රියාත්මකව ඇති අතරතුර එහි drawer එක විවෘතව තබා ගනී. එය ආපසු තැබීමට එය නැවත තීරුව මතට ඇදගෙන එන්න.

ඔබ මෙනුවකින් තේරීමට කැමති නම්, **Appearance → Menu Bar** හි ස්ථානය ඇති අතර, **Bar Background** තීරුව අඳින ආකාරය තෝරයි: **Opaque Bar**, **Glassy Bar** (පසුව ඇති දේ බොඳ කර ඇති, පාරදෘශ්‍ය), හෝ **Clear Bar**.

එම දේවල්ටම commands ද ඇති අතර, එය [dotfiles](31-dotfiles.md) සැකසුමක් සඳහා ඔබට අවශ්‍ය දෙයයි:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

විජට් එකක් සම්පූර්ණයෙන්ම එක් කිරීමට හෝ ඉවත් කිරීමට, plugin commands භාවිතා කරන්න. `omarchy plugin list` shell එක දන්නා සෑම විජට් එකක්ම එහි id එක සමඟ මුද්‍රණය කරන අතර, ඉන්පසුව:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## තීරුව සැඟවීම

`Super + Shift + Space` shell එක විනාශ නොකර තීරුව අක්‍රිය කර නැවත සක්‍රිය කරයි — panels සහ hotkeys දිගටම ක්‍රියා කරන අතර, ඔබට pixels ආපසු ලැබේ. එය **Appearance → Menu Bar → Hide Bar** යටතේ මෙනුවේද ඇත.

## Config ගොනුව

එම සියල්ල `~/.config/omarchy/shell.json` හි, `bar` යතුර යටතේ ගබඩා කර ඇත. මෙන්න කප්පාදු කළ අනුවාදයක්:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

සෑම විජට් එකක්ම layout arrays පහෙන් එකක එක entry එකක් වන අතර, එහි settings එම entry එකේම inlineව පිහිටයි — වෙනම settings ගොනුවක් නැත, `config` sub-object එකක්ද නැත. ඔරලෝසුවේ `format`, `formatAlt` (දකුණු-ක්ලික‍් කිරීම චක්‍රීයව මාරු කිරීමට යන්නේ කුමක්ද) සහ `verticalFormat` යන සියල්ල `{ "id": "omarchy.clock" }` මත එතැනම ජීවත් වේ.

`center` යනු තීරුවේ මැද ඇති box එකයි: එහි ඇති සියල්ල තිරය මත එක කණ්ඩායමක් ලෙස මධ්‍යගත කර ඇත. `centerBegin` සහ `centerEnd` box එකේ දෙපස එල්ලෙන අතර, කාලගුණය සහ update badge එක එහා මෙහා වන විට පවා ඔරලෝසුව මැදම රැඳෙන්නේ එලෙසිනි. `center` තුළ විජට් එකකට වඩා තබන්න, එවිට ඒවා එකට මධ්‍යගත වේ; එය හිස්ව තබන්න, එවිට `centerBegin` සහ `centerEnd` තීරුවේ මැදදී හමුවේ.

ඇතුළට ගත යුතු එක් නීතියක්: **ඔබට ඔබේම `shell.json` එකක් ඇති වූ පසු, එය ප්‍රමाणිකයි**. ඔබ කිසිවක් customize කරන තුරු, shell එක Omarchy හි පෙරනිමි ගොනුව කියවයි. ඔබ විජට් එකක් ඇදගෙන ගිය, `omarchy bar` ධාවනය කළ, හෝ ගොනුව ඔබම සංස්කරණය කළ මොහොතේ සිට, එය ඔබ සතුයි — deep merge එකක් නැත, එබැවින් අනාගත Omarchy releases වල නව පෙරනිමි විජට් ඔබේ තීරුවේ ස්වයංක්‍රීයව නොපෙනේ. ඔබට පිරිසිදු ආරම්භයක් අවශ්‍ය ඕනෑම විටෙක `omarchy bar defaults` නැව්ගත කළ layout එක ආපසු තබයි.

එම ගොනුවම `bar` යතුරෙන් පිටත, ඉහළ මට්ටමේ ඔබේ idle timings ද දරයි: `idle.screensaver` සහ `idle.lock`, දෙකම ඔබ idle වූ පසු තත්පර වලිනි. එබැවින් පෙරනිමි screensaver එක තත්පර 150 දී ආරම්භ වන අතර lock එක 300 දී ක්‍රියාත්මක වේ.
