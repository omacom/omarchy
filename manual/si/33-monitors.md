# මොනිටර

Omarchy පෙරනිමියෙන් උපකල්පනය කරන්නේ ඔබ 2x හැකියාව ඇති retina මට්ටමේ තිරයක් භාවිත කරන බවයි. ලස්සන, තියුණු programmer fonts ලබා ගැනීමට ඔබට අවශ්‍ය වන්නේ මෙයයි. අලුත් premium laptops සියල්ලම පාහේ ඉහළ විභේදනයක් ඇති තිර සමඟ ප්‍රශස්ත කර ඇත්තේ මෙය සඳහායි. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) හෝ 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) තිරයක් මත ඔබ භාවිත කිරීමට කැමති වන්නේද මෙයයි.

නමුත් ඔබ PPI 218ක් හෝ ඊට වැඩි තිරයක් භාවිත නොකරන්නේ නම්, ඔබට monitor settings වෙනස් කිරීමට අවශ්‍ය වනු ඇත. උදාහරණයක් ලෙස, ඔබට 27" හෝ 32" 4K තිරයක් තිබේ නම්, ඔබට ඉහළ තීරුවේ ඇති monitor panel එකෙන් ඒ සඳහා fractional scale එකක් තෝරා ගත හැකිය, නැතහොත් `~/.config/hypr/monitors.lua` විවෘත කර එම සංයෝජනය සඳහා වන නිර්දේශයට මාරු වීමෙන් සෑම මොනිටරයක් සඳහාම පෙරනිමිය සැකසිය හැකිය:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

ඔබ 1080p හෝ 1440p තිරයක් භාවිත කරන්නේ නම්, ඔබට බොහෝ විට අවශ්‍ය වනු ඇත්තේ 1x scaling පමණි, GTK සහ X11 apps සඳහාද එය එසේමය, එබැවින් ඔබට මෙය භාවිත කළ හැකිය:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` සඳහා කරන වෙනස්කම් අදාළ වන්නේ වෙනස්කමෙන් පසු ආරම්භ කළ applications සඳහා පමණි (GTK පිළිගන්නේ පූර්ණ සංඛ්‍යා පමණක් බැවින්, එය ඔබගේ monitor scale එකට ළඟම පූර්ණ සංඛ්‍යාවේ තබන්න). එමනිසා වෙනස්කමෙන් පසු අධි විශාල වී ඇති windows වසා දමන්න (හෝ `Ctrl + Alt + Del` සමඟ සියලු windows වසන්න!).

ඔබට `Super + /` භාවිතයෙන් ඉහළට සහ `Super + Alt + /` භාවිතයෙන් පහළට යමින් ප්‍රධාන monitor scaling අනුපාත (1x, 1.25x, 1.6x, 2x, 3x, 4x) හරහා ඉක්මනින් පියවරෙන් පියවර යා හැකිය, නැතහොත් ඉහළ තීරුවේ ඇති monitor panel එකෙන් එකක් තෝරා ගත හැකිය. මේවා වෙනස් කරන්නේ ඔබ මේ මොහොතේ focus කර ඇති මොනිටරය පමණි, එවිට laptop තිරයකට සහ බාහිර තිරයකට ඒවාටම ආවේණික scale එකක් තිබිය හැකිය. Panel එක මඟින් සෑම මොනිටරයකම විභේදනයද සකසයි. ඔබගේ තේරීම් එම භෞතික මොනිටරය සඳහා `~/.local/state/omarchy/monitors/settings` තුළ සුරකින බැවින්, ඒවා reboot කිරීමෙන් පසුවද පවතින අතර මොනිටරය ඊළඟට සම්බන්ධ කරන port එකට හෝ dock එකට එය අනුගමනය කරයි. ඒවා `~/.config/hypr/monitors.lua` තුළ එම මොනිටරය සඳහාම ඇති ඕනෑම නියමයකට වඩා ප්‍රමුඛතාව ලබයි, Omarchy කිසිවිටෙක එම ගොනුව සංස්කරණය නොකරයි. ඔබට අවශ්‍ය වන්නේ එම ගොනුව තුළම සම්පූර්ණයෙන්ම ඔබගේ මොනිටර සැකසීමට නම්, එයට `omarchy_monitor_panel_settings = false` එක් කරන්න, එවිට panel එකේ වෙනස්කම් පවතිනු ඇත්තේ Hyprland reload වන තෙක් පමණි. `GDK_SCALE` යනු සියලු තිර සඳහා එක් අගයක් බැවින්, තෝරා ගත් scale එකක් එය සකසන්නේ අවම scale එක ඇති මොනිටරයෙන් බැවින්, X11 apps අනික් තිරයේ අධි විශාල වනවාට වඩා ඝනත්වයෙන් වැඩි තිරයේ තරමක් කුඩා වී පෙනේ.

### පෙළ විශාල හෝ කුඩා කිරීම

Monitor scaling මඟින් සියල්ලේම ප්‍රමාණය වෙනස් කරයි. ඔබට අවශ්‍ය වන්නේ විශාල හෝ කුඩා _පෙළ_ පමණක් නම්, ඒ සඳහා එක් knob එකක් ඇත:

```
omarchy display text size 14
```

එය 9 සහ 20 අතර pixel ප්‍රමාණයක් ගන්නා අතර, Omarchy shell එක, GTK applications, සහ ඔබගේ terminal එක එකට ගෙන යයි, එවිට මුළු desktop එකම සමානුපාතිකව පවතී. ඔබ සිටින්නේ කොතැනදැයි බැලීමට argument එකක් නොමැතිව එය run කරන්න, සහ පෙරනිමියට ආපසු යාමට `omarchy display text size reset` භාවිත කරන්න. Foot යනු එකම පසුපසින් සිටින්නාය: එහි config එක reload කිරීමට ක්‍රමයක් නැත, එබැවින් ධාවනය වෙමින් පවතින terminals නව එකක් විවෘත කරන තෙක් ඒවායේ පැරණි ප්‍රමාණයම රඳවා ගනී.

### ලැප්ටොප් තිර දිගු කිරීම සහ mirror කිරීම

ඔබ බාහිර තිරයක් ඔබගේ laptop එකට සම්බන්ධ කළ විට, තිරය ස්වයංක්‍රීයව දිගු වේ. නමුත් Omarchy menu එකේ _Trigger > Hardware_ හෝ `Super + Ctrl + Alt + Delete` භාවිතයෙන් ඔබට ඒ වෙනුවට එය mirroring බවට වෙනස් කළ හැකිය. එම බාහිර තිරය projector එකක් නම් සහ ඔබට වැඩ කරන අතරතුර යමක් පෙන්වීමට අවශ්‍ය නම් මෙය විශේෂයෙන් උපකාරී වේ.

ඔබ දිගු කරමින් සිටින විට, laptop එකේ පියන වැසීමෙන් අභ්‍යන්තර තිරය ස්වයංක්‍රීයව ක්‍රියා විරහිත වේ. පියන විවෘත කිරීමෙන් එය නැවත ක්‍රියාත්මක වේ. Omarchy menu එකේ _Trigger > Hardware_ හෝ `Super + Ctrl + Delete` භාවිතයෙන් ඔබට මෙය අතින්ද පාලනය කළ හැකිය.

### තිර කිහිපයක් සැකසීම

Hyprland තිර කිහිපයක් සමඟ ඉතා හොඳින් වැඩ කරයි. ඉහළ තීරුවේ ඇති monitor panel එක ඒවා පිහිටා ඇති තැන ඒවා අඳියි: එකක් තවත් එකක පැත්තට ඇද දැමීමෙන් එය එතැනට ගෙන යන්න, එවිට එම සැකසුම සෑම මොනිටරයකම අනෙකුත් settings සමඟ සුරකිනු ලැබේ. Panel එකෙන් ආවරණය නොවන ඕනෑම දෙයක් සඳහා, ඒවා සකසන ආකාරය පිළිබඳ වැඩිදුර [Hyprland මොනිටර ලේඛනය](https://wiki.hypr.land/Configuring/Basics/Monitors/) තුළ කියවන්න. Omarchy තුළ, මේවා `~/.config/hypr/monitors.lua` තුළට `hl.monitor` entries ලෙස යයි — නිශ්චිත මොනිටරයක් විභේදනයකට, පිහිටීමකට, සහ භ්‍රමණයකට සවි කිරීම සඳහා වන අදහස් දක්වා ඇති උදාහරණ සමඟ ගොනුව එයි.

සෑම මොනිටරයකටම එයටම ආවේණික workspaces 1 සිට 10 දක්වා ඇත, එබැවින් `Super + 1` සැමවිටම අදහස් කරන්නේ ඔබ සිටින මොනිටරයේ පළමු workspace එකයි. තිරය පිටුපස, Hyprland තවමත් සියලු මොනිටර හරහා workspaces අංකනය කරයි: ඔබගේ laptop තිරයට (හෝ පළමු මොනිටරයට) 1–10 ලැබේ, ඊළඟ මොනිටරයට 11–20 ලැබේ, සහ එසේ ඉදිරියට, සහ සෑම මොනිටරයක්ම ඔබ එය සම්බන්ධ කරන සෑම අවස්ථාවකම එහි කොටස රඳවා ගනී. ඔබ නිශ්චිත මොනිටරයක් සඳහා [කාර්ය අවකාශ නීති](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) හෝ window rules ලියන්නේ නම් එම අංක භාවිත කරන්න, එවිට workspace 12 යනු ඔබගේ දෙවන මොනිටරයේ දෙවන workspace එකයි. `~/.local/state/omarchy/monitors/workspaces` මඟින් සෑම මොනිටරයකටම ඇති කොටස කුමක්දැයි ලැයිස්තුගත කරයි.

ඊතල යතුරු ඔබගේ සැකසුම තුළ දාරයක් බෙදා ගන්නා මොනිටර හරහා වැඩ කරයි. කොනකින් පමණක් ස්පර්ශ වන, හෝ ඒවා අතර පරතරයක් ඇති තිර අසල්වැසියන් නොවේ, එබැවින් ඒවා අතර යාමට `Ctrl + Alt + Tab` භාවිත කරන්න.

| හොට්කී | මොනිටර හරහා |
| --- | --- |
| `Super + Arrow` | එම දිශාවට තවත් window එකක් ඉතිරිව නැති වූ පසු එම පැත්තේ ඇති මොනිටරයට focus එක ගෙන යයි |
| `Super + Shift + Arrow` | එම පැත්තේ ඇති මොනිටරයේ window එකක් සමඟ මාරු වේ |
| `Super + Alt + Arrow` | එම පැත්තේ ඇති මොනිටරයේ group එකකට window එක ගෙන යයි |
| `Super + Shift + Ctrl + Arrow` | එම පැත්තේ ඇති මොනිටරයට, එය පෙන්වමින් සිටින workspace එක මතට window එක ගෙන යයි |
| `Super + Shift + Alt + Arrow` | එම පැත්තේ ඇති මොනිටරයට workspace එක ගෙන යයි, එය නිදහස් නම් එහි අංකය රඳවා ගනී |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | සැකසුම කුමක් වුවත්, ඊළඟ හෝ පෙර මොනිටරයට focus එක ගෙන යයි |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | ඔබ සිටින මොනිටරයේම රැඳී සිටියි |

තිර කිහිපයක් ස්ථානගත කිරීමට ඔබට උපකාර කිරීමට TUI එකක් අවශ්‍ය නම්, ඔබට [Hyprmon](https://github.com/erans/hyprmon/) ද පරීක්ෂා කළ හැකිය.

### දීප්තිය පාලනය කිරීම

Monitor දීප්තිය පාලනය කරනු ලබන්නේ දීප්තිය ඉහළ/පහළ දැමීම සඳහා ඇති කැප වූ function keys මඟිනි. ඔබ මේවා එබීමේදී Shift ඔබාගෙන සිටියහොත්, ඔබ උපරිම හෝ අවම දීප්තියට යනු ඇත. යතුරු මඟින් පාලනය කරන්නේ ඔබ focus කර ඇති තිරයයි, එබැවින් DDC/CI සමඟ කතා කරන බාහිර මොනිටර laptop තිරය ආකාරයටම සකසනු ලැබේ.

### Apple තිර

ඔබ Apple තිරයක් භාවිත කරන්නේ නම්, ඔබ Apple තිරය මත focus කර ඇත්නම්, සාමාන්‍ය keyboard දීප්ති යතුරුද ස්වයංක්‍රීයව වැඩ කරනු ඇත. මෙය සිදු කරනු ලබන්නේ `asdcontrol` command එක හරහායි.

ඔබ Apple 6K XDR තිරයක් භාවිත කරන්නේ නම්, ඔබගේ `hyprctl monitors` ලැයිස්තුවේ අවතාර තිරයක් ඔබට දැකිය හැකි බව සලකන්න. `~/.config/hypr/monitors.lua` තුළ `hl.monitor({ output = "DP-2", disabled = true })` වැනි දෙයක් සමඟ ඔබට මෙය ක්‍රියා විරහිත කළ හැකිය.

Intel machines මත, ඔබ Apple තිරවලට සම්බන්ධ විය යුත්තේ සාමාන්‍ය Thunderbolt cable එකක් භාවිතයෙනි. Thunderbolt නැති වෙනත් machines මත, එය වැඩ කරවීම සඳහා ඔබට සාමාන්‍යයෙන් [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) එකක් භාවිත කිරීමට සිදු වනු ඇත.
