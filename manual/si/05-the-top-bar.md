# ඉහළ තීරුව

ඔබේ තිරයේ ඉහළින් ඇති තීරුව Omarchy තීරුවයි. එය බෝල්ට් කර සවි කළ තත්ත්ව තීරුවක් නොව, Omarchy shell එකේම කොටසකි — menu එක, දැනුම්දීම්, OSD popup, සහ lock screen එකද අඳින තනි, දිගු කාලයක් ක්‍රියාත්මක වන Quickshell process එකමයි. ඒ නිසයි එය අනෙක් සියල්ල සමඟම පරිපූර්ණව theme වෙන්නේ, සහ panel එකක් නව app එකක් spawn කරනවා වෙනුවට ක්ෂණිකව විවෘත වෙන්නේ.

එය desktop එකේ සෑම විටම තිරයේ පවතින එකම කොටසද වන නිසා, ඒ කුඩා glyph සියල්ල කරන්නේ කුමක්දැයි දැනගැනීම වටිනවා.

## පෙරනිමියෙන් එහි ඇත්තේ මොනවාද

තීරුවට කොටස් තුනක් ඇත. වම් පැත්තේ Omarchy ලාංඡනය (menu launcher එක) සහ workspace දර්ශක පිහිටා ඇත. මැදින් ඔබට තත්ත්ව දර්ශක, ඔරලෝසුව, Elsewhen (ලෝක ඔරලෝසුවක්), කාලගුණය, සහ Omarchy යාවත්කාලීන ලාංඡනය ලැබේ. දකුණු පැත්තේ: system tray එක, keyboard layout එක (එකකට වඩා configure කර ඇති විට), agents, Bluetooth, ජාලය, ශ්‍රව්‍ය, සංදර්ශකය, සහ බලය.

ඒවායින් කිහිපයක් පෙනෙන්නේ ඒවාට කීමට යමක් ඇති විට පමණි. Keyboard layout එක පෙනෙන්නේ ඔබ layout එකකට වඩා configure කර ඇත්නම් පමණි. යාවත්කාලීන ලාංඡනය පෙනෙන්නේ Omarchy යාවත්කාලීනයක් බලාපොරොත්තුවෙන් සිටින විට පමණි. සහ agents අයිකනය පෙනෙන්නේ Omarchy විසින් යන්ත්‍රයේ AI coding භාවිතය මුල් වරට සොයාගත් විටයි (බලන්න [AI](17-ai.md)).

## වටේ ක්ලික් කිරීම

සෑම widget එකක්ම පාහේ වම්, දකුණු, සහ මැද ක්ලික් කිරීමෙන් යමක් කරයි, කිහිපයක් scrolling වලටද ප්‍රතිචාර දක්වයි. මිනිසුන්ට මගහැරෙන්නේ මේ කොටසයි — හොඳ දේවල් බොහොමයක් සැඟවී ඇත්තේ දකුණු සහ මැද බොත්තම්වලයි.

| Widget එක | වම | දකුණ | මැද / scroll |
| --- | --- | --- | --- |
| Menu | Omarchy menu එක | නව terminal එකක් | — |
| Workspaces | එම workspace එක මෙම monitor එකේ focus කරන්න | — | Scroll: ඊළඟ/පෙර workspace එක |
| Clock | Calendar popup එක | ලේබල ආකෘතිය චක්‍රීයව මාරු කරන්න | මැද: timezone තෝරනය |
| Weather | අනාවැකි popup එක | සම්පූර්ණ කාලගුණය දැනුම්දීමක් ලෙස | මැද: refresh කරන්න |
| Audio | Audio panel එක | නිශ්ශබ්ද කරන්න | මැද: panel එක · scroll: හඬ ප්‍රමාණය |
| Microphone | මයික් එක නිශ්ශබ්ද කරන්න | — | මැද: audio panel එක · scroll: ආදාන හඬ ප්‍රමාණය |
| Network | Network panel එක | — | — |
| Bluetooth | Bluetooth panel එක | radio එක toggle කරන්න | — |
| Display | Display panel එක | — | Scroll: දීප්තිය |
| Power | Power panel එක | බැටරි ප්‍රතිශතය toggle කරන්න | — |
| Media | Play/pause | Cover-art popup එක | මැද: ඊළඟ · scroll: පෙර/ඊළඟ |
| Agents | Agents panel එක | ඔබේ agent දියත් කරන්න | මැද: ඊළඟ subscription එක |
| Tray | Drawer එක පෙන්වීමට hover කරන්න | කළමනාකරණය කිරීමට chevron එක මත දකුණු ක්ලික් කරන්න | — |
| Omarchy update | යාවත්කාලීනය ධාවනය කරන්න | — | — |

ඒ වගුවේ ඇති සියල්ලම මුල සිටම ඔබේ තීරුවේ නැත. Media widget එක (MPRIS now-playing, scroll වන track එකක් සහ artist කෙනෙක් සමඟ) සහ microphone widget එක යන දෙකම built in නමුත් පෙරනිමියෙන් අක්‍රියයි — ඔබට ඒවා අවශ්‍ය නම්, පහත විස්තර කර ඇති පරිදි ඒවා එක් කරන්න.

## Panel

බාර් අයිකනයක් ක්ලික් කිරීමෙන් panel එකක් විවෘත වේ, එය tooltip එකක් වෙනුවට slider, ලැයිස්තු, සහ keyboard navigation සහිත නිසි popup එකකි. සෑම එකකටම hotkey එකක්ද ඇත, එබැවින් ඔබට කිසිවිට 16-pixel glyph එකක් ඉලක්ක කිරීමට සිදු නොවේ:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + 1-9` | දකුණු කොටසේ n වැනි panel එක toggle කරන්න |

Panel යනු කියවීම් පෙන්වන ඒවා පමණක් නොවේ. ඔබ ඇත්තටම දේ කරන්නේ එතැනයි:

- **Audio** හි master volume slider එකක්, output-device තෝරනයක්, සහ per-app mixer එකක් ඇත, එබැවින් අනෙක් සියල්ලට අත නොතබාම එම එක browser tab එකක හඬ අඩු කළ හැක.
- **Network** Wi-Fi සඳහා scan කරයි, signal ශක්තිය පෙන්වයි, සම්බන්ධ වේ, සහ DNS provider කෙනෙක් තෝරා ගැනීමට ඔබට ඉඩ දෙයි.
- **Bluetooth** ඔබේ උපාංග connect/disconnect සහ බැටරි මට්ටම් සමඟ ලැයිස්තු කරයි.
- **Power** බැටරි සංඛ්‍යාලේඛන පෙන්වයි, power profile මාරු කරයි (එය බැටරිය සහ AC සඳහා වෙනම තේරීමක් මතක තබා ගනී), සහ යම් system තොරතුරු මුද්‍රණය කරයි.
- **Display** හි brightness slider එකක්, text size එක, monitor scaling preset, සහ — ඔබට තිර එකකට වඩා ඇති විට — per-monitor පාලන ඇත. ගැඹුරු කතාව සඳහා බලන්න [මොනිටර](33-monitors.md).
- **Clock** ISO සති අංක සහ මාසයෙන් මාසයට යාම සහිත මාස ජාලයක් විවෘත කරයි.
- **World clock** නගරයකට එක පේළිය බැගින් තබා ගනී, එහි කාලගුණය සහ එහි දවස ගෙවී යන්නේ කෙසේද යන්න සමඟ. Search මඟින් time zone මෙන්ම නගරද සොයා ගනී, එබැවින් Fort Lauderdale යනු Fort Lauderdale මිස New York නොවේ. ඉහළින් ඇති පේළිය වැරදි නගරය නම් කරන්නේ නම්, එය ක්ලික් කර ඔබ සිටින්නේ කොතැනදැයි කියන්න; වෙනත් time zone එකක ස්ථානයක් තෝරන්න, system ඔරලෝසුවද එතැනට ගමන් කරයි, එය ඔබ සංචාරය කරන විට ප්‍රයෝජනවත් වේ. නගරයක් මත hover කර person බොත්තම ක්ලික් කර එහි ජීවත් වන්නේ කවුරුන්දැයි කියන්න — සරල නම්, හෝ ඔවුන්ගේ මුහුණුද රැගෙන ඒමට `@` GitHub handle.

සෑම panel එකක්ම mouse එක මෙන්ම keyboard එකද ගනී: arrow මඟින් ගමන් කරයි, Return සක්‍රිය කරයි, Tab අසල්වැසි panel එකට පියවර ගනී, සහ Escape වසා දමයි.

`Super + Ctrl + 1-9` දකුණු කොටසේ panel වමේ සිට දකුණට ගණන් කරයි, tray එකට තමන්ගේම panel එකක් නොමැති බැවින් එය මඟ හරියි. එබැවින් අංකය ඔබ යොමු කරන අයිකනයට ගැලපේ.

### Tailscale සහ Dropbox

ඔබ ගැලපෙන සේවාව **Install → Service** වෙතින් install කළ පසු තවත් widget දෙකක් තීරුවේ පෙනේ, සහ ඒ දෙකම තත්ත්වය වාර්තා කිරීමට වඩා වැඩි යමක් කරන බැවින් දැනගැනීම වටිනවා.

**Tailscale** panel එක tailnet එක connect සහ disconnect කරයි, ගිණුම් අතර මාරු වේ, සහ exit node එකක් තෝරයි (ඔබේම යන්ත්‍ර සහ Mullvad කලාප දෙකම ඒ ලැයිස්තුවේ පෙනේ). එය ඔබේ යන්ත්‍ර browse කිරීමටද ඉඩ දෙයි — සහ එකක් තෝරාගත් විට, `s` එයට Taildrop හරහා ගොනු යවයි, එය ඔබේ දුරකථනයට හෝ වෙනත් laptop එකකට ගොනුවක් ගෙන යාමට ඇති වේගවත්ම ක්‍රමයයි. `c` යන්ත්‍රයේ IP එක copy කරයි, `n` එහි නම, සහ `d` එහි සම්පූර්ණ DNS නම. ඔබට ක්ලික් කිරීමට කැමති නම්, සෑම යන්ත්‍ර පේළියකම send බොත්තමක්ද ඇත. Terminal එකෙන් එම දේම `omarchy tailscale send <machine> [file...]` වේ.

**Dropbox** panel එක login කිරීම හසුරුවයි, ඔබ කොපමණ storage එකක් භාවිතා කර ඇත්දැයි පෙන්වයි, සහ මෑතකදී sync කළ ගොනු ලැයිස්තු කරයි.

සේවාවන් දෙකෙන් එකක් ඉවත් කිරීම එහි widget එක නැවත තීරුවෙන් ඉවත් කරයි.

## දර්ශක

මැද ඇති කුඩා පොකුර indicators widget එකයි. මේවා ඔබ සක්‍රිය කර ඇති mode සඳහා වන තත්ත්ව glyph ය: do not disturb, night light, පෝලිමේ ඇති [උපදේශනයක්](09-reminders.md), සක්‍රිය screen recording එකක්, අවදිව සිටීම, සහ [උච්චාරණය](11-text-extraction-dictation.md). Mode එක සක්‍රිය වූ විට ඒවා දැල්වී, එසේ නොමැති නම් බාධාවක් නොවී පවතී — ඒවා දෙස බැලීමට, අක්‍රිය ඒවා පිහිටිය යුතු ස්ථානයේ, ඒවාට මදක් යාබදව hover කරන්න. දර්ශකයක් ක්ලික් කිරීමෙන් එම mode එක toggle වේ. තවත් එකක් තත්ත්වය සඳහා පමණි: යමෙක් gliff හරහා මෙම යන්ත්‍රයට සම්බන්ධ වී සිටින අතරතුර remote session එකක් රතු පැහැයෙන් දැල්වේ.

ඔබට ඒවා සෑම විටම දෘශ්‍යමානව තිබීමට අවශ්‍ය නම්, widget එකේ `alwaysShow` යන්න `true` ලෙස සකසන්න. සහ ඔබ සැලකිලිමත් වන්නේ ඒවායින් සමහරක් ගැන පමණක් නම්, ඔබට අවශ්‍ය ඒවා `items` හි ලැයිස්තු කරන්න: `["Dnd", "Reminder", "NightLight"]`. ඔබට indicators widget එකකට වඩා තිබිය හැක, එබැවින් විවිධ කොටස්වලට විවිධ උපකුලක පෙන්විය හැක.

## තීරුව නැවත සකස් කිරීම

තීරුව තමන්ම configure වේ. දේවල් ගෙනයාමට ඔබට config ගොනුවක් විවෘත කිරීමට සිදු නොවේ.

මැද වටා ඇති තීරුවේ හිස් ප්‍රදේශයක් අල්ලා වෙනත් තිර අද්දරක් දෙසට එය drag කරන්න, එවිට තීරුව එතැනට ගමන් කරයි — වම, දකුණ, ඉහළ, හෝ පහළ යන සියල්ලම ක්‍රියා කරයි, සහ සෑම widget එකක්ම අනුගත වේ (සිරස් තීරු සංයුක්ත icon-only ආකාරවලට ආපසු වැටේ). Click-and-hold එකක්ද එම drag එකම ආරම්භ කරයි. එම හිස් ඉඩම double-left-click කර තීරු පසුබිම clear සිට glassy සිට opaque දක්වා චක්‍රීයව මාරු කරන්න. සහ ඕනෑම widget එකක් drag කර එය නැවත සකසන්න හෝ වෙනත් කොටසකට විසි කරන්න; අනෙක් widget එය ගොඩබසින ස්ථානයේ ඉඩ සෑදීමට දෙපසට ලිස්සා යයි.

තීරුවේ මැද box එකකි: එහි ඇති ඕනෑම දෙයක් එක කණ්ඩායමක් ලෙස මැදින් පවතී, සහ එහි දෙපස ඇති widget එහි දාරවලින් එල්ලී සිටී. ඔබ widget එකක් drag කරන අතරතුර box එක outline එකක් ලෙස පෙනේ, හෝ එය හිස් වූ විට තීරුව හරහා රේඛාවක් ලෙස පෙනේ, සහ ඔබට එය තුළට හෝ එය අසලට drop කළ හැක. Drop එකක් box එක තුළට ගොඩබසින විට, box එක widget එක ඇතුළට ගැනීමට විශාල වේ.

ඔබට අවට තබා ගැනීමට අවශ්‍ය නමුත් සෑම විටම පෙනෙන්නට අවශ්‍ය නැති widget එකක් tray එකේ drawer එකට යා හැක: එය tray එක මතට drag කරන්න, එවිට drawer එක එය ගැනීමට විවෘත වේ. එය app අයිකනවලින් පසුව එහි හිඳී, drawer එක පෙනෙන සෑම විටම පෙනේ, සහ එහි panel එක ඉහළින් ඇති අතරතුර එහි drawer එක විවෘතව තබා ගනී. එය නැවත තීරුව මත තැබීමට තීරුව මතට ආපසු drag කරන්න.

ඔබට menu එකකින් තෝරා ගැනීමට අවශ්‍ය නම්, **Appearance → Menu Bar** හි පිහිටීම ඇත, සහ **Bar Background** තීරුව අඳින ආකාරය තෝරයි: **Opaque Bar**, **Glassy Bar** (see-through, එහි පිටුපස ඇති දේ බොඳ කර ඇති), හෝ **Clear Bar**.

එම දේවල්ටම commands ඇත, එය [dotfiles](31-dotfiles.md) setup එකක් සඳහා ඔබට අවශ්‍ය දෙයයි:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Widget එකක් සම්පූර්ණයෙන්ම එක් කිරීමට හෝ ඉවත් කිරීමට, plugin commands භාවිතා කරන්න. `omarchy plugin list` shell එක දන්නා සෑම widget එකක්ම එහි id එක සමඟ මුද්‍රණය කරයි, ඉන් පසුව:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## තීරුව සැඟවීම

`Super + Shift + Space` shell එක kill නොකර තීරුව අක්‍රිය කර නැවත සක්‍රිය කරයි — panel සහ hotkey දිගටම ක්‍රියා කරයි, ඔබට පික්සල නැවත ලැබෙනවා පමණි. එය menu එකේ **Appearance → Menu Bar → Hide Bar** යටතේද ඇත.

## Config ගොනුව

ඒ සියල්ල `~/.config/omarchy/shell.json` හි, `bar` යතුර යටතේ ගබඩා කර ඇත. මෙන්න කෙටි කළ අනුවාදයක්:

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

සෑම widget එකක්ම layout array පහෙන් එකක එක entry එකක් වන අතර, එහි settings එම entry එකේම inlineව පිහිටා ඇත — වෙනම settings ගොනුවක් නැත, `config` sub-object එකක්ද නැත. ඔරලෝසුවේ `format`, `formatAlt` (දකුණු-ක්ලික් කිරීම චක්‍රීයව මාරු වන්නේ කුමක් වෙතද යන්න), සහ `verticalFormat` යන සියල්ලම එතැනම `{ "id": "omarchy.clock" }` මත ජීවත් වේ.

`center` යනු තීරුවේ මැද ඇති box එකයි: එහි ඇති සියල්ල තිරයේ එක කණ්ඩායමක් ලෙස මැදින් තබා ඇත. `centerBegin` සහ `centerEnd` box එකේ දෙපසින් එල්ලී සිටී, කාලගුණය සහ යාවත්කාලීන ලාංඡනය එන යන අතරතුර වුවද ඔරලෝසුව හරියටම මැද රැඳෙන්නේ එලෙසයි. `center` තුළ widget එකකට වඩා තබන්න, එවිට ඒවා එකට මැදින් තබා ඇත; එය හිස්ව තබන්න, එවිට `centerBegin` සහ `centerEnd` තීරුවේ මැදින් හමු වේ.

ඇතුළට ගත යුතු එක් නීතියක්: **ඔබට ඔබේම `shell.json` එකක් ලැබුණු පසු, එය canonical වේ**. ඔබ කිසිවක් customize කරන තුරු, shell එක Omarchy හි පෙරනිමි ගොනුව කියවයි. ඔබ widget එකක් drag කළ, `omarchy bar` ධාවනය කළ, හෝ ගොනුව ඔබම edit කළ මොහොතේම, එය ඔබ සතු වේ — deep merge එකක් නැත, එබැවින් අනාගත Omarchy නිකුතුවල නව පෙරනිමි widget ඔබේ තීරුවේ ස්වයංක්‍රීයව පෙනෙන්නේ නැත. ඔබට පිරිසිදු ආරම්භයක් අවශ්‍ය ඕනෑම විටක `omarchy bar defaults` විසින් නැව්ගත කළ layout එක ආපසු තබයි.

එම ගොනුවම ඔබේ idle වේලාවන්ද, `bar` යතුරෙන් පිටත, ඉහළ මට්ටමේ තබා ගනී: `idle.screensaver` සහ `idle.lock`, දෙකම ඔබ idle වූ දා සිට තත්පර වලින්. එබැවින් පෙරනිමි screensaver එක තත්පර 150 දී ආරම්භ වන අතර lock එක තත්පර 300 දී ආරම්භ වේ.
