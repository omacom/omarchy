# මොනිටර

Omarchy පෙරනිමියෙන්ම උපකල්පනය කරන්නේ ඔබ 2x හැකියාව ඇති retina මට්ටමේ සංදර්ශකයක් මත ධාවනය වන බවයි. ඒ නියම, තියුණු programmer fonts ලැබෙන්න ඔබට අවශ්‍ය දෙයයි. අධි-විභේදන තිර සහිත අලුත්ම premium laptops සියල්ලම පාහේ optimized කර ඇත්තේ ඒ සඳහායි. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) එකක් හෝ 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) එකක් මත ඔබ ධාවනය කරන්න කැමති වන්නෙත් ඒකමයි.

නමුත් ඔබ PPI 218 ක් හෝ ඊට වැඩි සංදර්ශකයක් ධාවනය නොකරන්නේ නම්, ඔබට monitor settings වෙනස් කරන්න අවශ්‍ය වේවි. උදාහරණයක් ලෙස, ඔබට 27" හෝ 32" 4K එකක් තිබේ නම්, `~/.config/hypr/monitors.lua` (Omarchy menu එකේ _Setup > Monitors_ හරහා) විවෘත කර, ඒ සංයෝජනය සඳහා නිර්දේශයට මාරු වීමෙන් ඔබට fractional scaling භාවිතා කළ හැකිය:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

ඔබ 1080p හෝ 1440p සංදර්ශකයක් භාවිතා කරන්නේ නම්, ඔබට බොහෝ විට අවශ්‍ය වන්නේ 1x scaling පමණක් බැවින්, ඔබට මෙය භාවිතා කළ හැකිය:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` වෙත කරන වෙනස්කම් අදාළ වන්නේ වෙනස්කමෙන් පසු ආරම්භ කරන applications වලටයි (තවද GTK පිළිගන්නේ පූර්ණ සංඛ්‍යා පමණක් බැවින්, එය ඔබේ monitor scale එකට ආසන්නතම පූර්ණ සංඛ්‍යාවේ තබා ගන්න). එබැවින් වෙනස්කමෙන් පසු ඔබට ඇති විශාල වූ windows වසා දමන බවට වග බලා ගන්න (හෝ `Ctrl + Alt + Del` සමඟ සියලු windows වසා දමන්න!).

ඉහළට යාමට `Super + /` සහ පහළට යාමට `Super + Alt + /` භාවිතා කරමින්, හෝ ඉහළ තීරුවේ monitor panel එකෙන් එකක් තෝරා ගනිමින්, ඔබට ප්‍රධාන monitor scaling අනුපාත (1x, 1.25x, 1.6x, 2x, 3x, 4x) හරහා ඉක්මනින් පියවරෙන් පියවර යා හැකිය. මේවා වෙනස් කරන්නේ ඔබ අවධානය යොමු කර ඇති monitor එක පමණක් බැවින්, laptop තිරයකට සහ බාහිර සංදර්ශකයකට ඒවාටම ආවේණික scale එක බැගින් තිබිය හැකිය. තේරීම ඒ monitor එක සඳහා `hl.monitor` රීතියක් ලෙස `~/.config/hypr/monitors.lua` වෙත සුරැකෙන බැවින්, එය reboot එකෙන් පසුවත් පවතින අතර, තමන්ටම කියා රීතියක් නැති සෑම monitor එකක් සඳහාම scale එක ලෙස පවතින `omarchy_monitor_scale` ට වඩා ප්‍රමුඛතාව ගනියි.

### පෙළ විශාල හෝ කුඩා කිරීම

Monitor scaling මඟින් සියල්ලේම ප්‍රමාණය වෙනස් වේ. ඔබට අවශ්‍ය වන්නේ විශාල හෝ කුඩා _පෙළ_ පමණක් නම්, ඒ සඳහා තනි knob එකක් තිබේ:

```
omarchy display text size 14
```

එය 9 සහ 20 අතර pixel ප්‍රමාණයක් ගන්නා අතර, මුළු desktop එකම අනුපාතයෙහි පවත්වා ගන්නා පරිදි Omarchy shell එක, GTK applications සහ ඔබේ terminal එක එකට ගෙන යයි. ඔබ සිටින්නේ කොතැනදැයි බැලීමට argument එකක් නොමැතිව එය ධාවනය කරන්න, සහ පෙරනිමියට ආපසු යාමට `omarchy display text size reset` භාවිතා කරන්න. Foot තමයි එකම පසුබටයා: එහි config එක reload කිරීමට ක්‍රමයක් නැති බැවින්, ඔබ අලුත් එකක් විවෘත කරන තුරු ධාවනය වන terminals ඒවායේ පැරණි ප්‍රමාණයම තබා ගනියි.

### Laptop සංදර්ශක විහිදුවීම සහ mirror කිරීම

ඔබ ඔබේ laptop එකට බාහිර තිරයක් සම්බන්ධ කළ විට, සංදර්ශකය ස්වයංක්‍රීයව විහිදේ. නමුත් Omarchy menu එකේ _Trigger > Hardware_ හෝ `Super + Ctrl + Alt + Delete` භාවිතයෙන් ඔබට එය වෙනුවට mirroring ලෙස වෙනස් කළ හැකිය. ඒ බාහිර තිරය projector එකක් නම්, සහ ඔබට වැඩ කරන අතරතුර යමක් පෙන්වීමට අවශ්‍ය නම් මෙය විශේෂයෙන් උපකාරී වේ.

ඔබ විහිදුවන විට, laptop එකේ පියන වැසීමෙන් අභ්‍යන්තර තිරය ස්වයංක්‍රීයව අක්‍රිය වේ. පියන විවෘත කිරීමෙන් එය නැවත ක්‍රියාත්මක වේ. Omarchy menu එකේ _Trigger > Hardware_ හෝ `Super + Ctrl + Delete` භාවිතයෙන් ඔබට මෙය අතින්ද පාලනය කළ හැකිය.

### තිර කිහිපයක් සැකසීම

Hyprland තිර කිහිපයක් සමඟ ඉතා හොඳින් වැඩ කරයි. ඒවා සකසන ආකාරය ගැන වැඩිදුර [Hyprland monitor ලේඛනයේ](https://wiki.hypr.land/Configuring/Basics/Monitors/) කියවන්න. Omarchy තුළ, මේවා `hl.monitor` ඇතුළත් කිරීම් ලෙස `~/.config/hypr/monitors.lua` තුළ යෙදේ — නිශ්චිත monitor එකක් resolution එකකට, පිහිටීමකට සහ භ්‍රමණයකට සවි කිරීම සඳහා අදහස් දක්වා ඇති උදාහරණ සමඟ ගොනුව එයි.

සෑම monitor එකකටම තමන්ගේම workspaces 1 සිට 10 දක්වා ඇති බැවින්, `Super + 1` යන්නෙන් සැමවිටම අදහස් වන්නේ ඔබ සිටින monitor එකේ පළමු workspace එකයි. තිරය පිටුපස, Hyprland තවමත් සියලු monitors හරහා workspaces අංකනය කරයි: ඔබේ laptop තිරයට (හෝ පළමු monitor එකට) 1–10 ද, ඊළඟ monitor එකට 11–20 ද, ආදී වශයෙන් ලැබෙන අතර, ඔබ එය plug කරන සෑම අවස්ථාවකම සෑම monitor එකක්ම එහි කොටස රඳවා ගනියි. නිශ්චිත monitor එකක් සඳහා ඔබ [workspace රීති](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) හෝ window රීති ලියන්නේ නම් ඒ අංක භාවිතා කරන්න, එවිට workspace 12 යනු ඔබේ දෙවන monitor එකේ දෙවන workspace එකයි. සෑම monitor එකකටම ඇති කොටස කුමක්දැයි `~/.local/state/omarchy/monitor-workspaces` ලැයිස්තුගත කරයි.

ඊතල යතුරු ක්‍රියා කරන්නේ ඔබේ සැකැස්මේ දාරයක් බෙදා ගන්නා monitors අතරයි. කොනකින් පමණක් ස්පර්ශ වන, හෝ අතර පරතරයක් ඇති තිර අසල්වැසියන් නොවේ, එබැවින් ඒවා අතර යාමට `Ctrl + Alt + Tab` භාවිතා කරන්න.

| Hotkey | Monitors අතර |
| --- | --- |
| `Super + Arrow` | ඒ දෙසට තවත් window එකක් නැති වූ පසු ඒ පැත්තේ monitor එක වෙත අවධානය ගෙන යයි |
| `Super + Shift + Arrow` | ඒ පැත්තේ monitor එකේ window එකක් සමඟ හුවමාරු වේ |
| `Super + Alt + Arrow` | window එක ඒ පැත්තේ monitor එකේ group එකක් තුළට ගෙන යයි |
| `Super + Shift + Ctrl + Arrow` | window එක ඒ පැත්තේ monitor එක වෙත, එය පෙන්වමින් සිටින workspace එක මතට ගෙන යයි |
| `Super + Shift + Alt + Arrow` | workspace එක නිදහස් නම් එහි අංකය තබා ගනිමින්, ඒ පැත්තේ monitor එක වෙත workspace එක ගෙන යයි |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | සැකැස්ම කුමක් වුවත්, ඊළඟ හෝ පෙර monitor එක වෙත අවධානය ගෙන යයි |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | ඔබ සිටින monitor එකේම රැඳේ |

ඔබට තිර කිහිපයක පිහිටීම සැකසීමට උපකාර වන TUI එකක් අවශ්‍ය නම්, ඔබට [Hyprmon](https://github.com/erans/hyprmon/) ද පරීක්ෂා කළ හැකිය.

### දීප්තිය පාලනය කිරීම

Monitor දීප්තිය පාලනය කරනු ලබන්නේ දීප්තිය ඉහළ/පහළ සඳහා ඇති කැපවුණු function keys මගිනි. මේවා එබීමේදී ඔබ shift ඔබාගෙන සිටියහොත්, ඔබ උපරිම හෝ අවම දීප්තියට යනු ඇත. යතුරු මඟින් පාලනය වන්නේ ඔබ අවධානය යොමු කර ඇති සංදර්ශකය බැවින්, DDC/CI කතා කරන බාහිර monitors laptop තිරය හා සමාන ආකාරයෙන්ම සකසනු ලැබේ.

### Apple සංදර්ශක

ඔබ Apple සංදර්ශකයක් භාවිතා කරන්නේ නම්, ඔබ Apple සංදර්ශකය වෙත අවධානය යොමු කර ඇත්නම්, සාමාන්‍ය keyboard brightness keys ද ස්වයංක්‍රීයව ක්‍රියා කරනු ඇත. මෙය සිදු කරනු ලබන්නේ `asdcontrol` විධානය හරහාය.

ඔබ Apple 6K XDR සංදර්ශකයක් භාවිතා කරන්නේ නම්, ඔබේ `hyprctl monitors` ලැයිස්තුවේ phantom තිරයක් ඔබට දැකිය හැකි බව සලකන්න. _Setup > Monitors_ හරහා `hl.monitor({ output = "DP-2", disabled = true })` වැනි දෙයක් භාවිතයෙන් ඔබට එය අක්‍රිය කළ හැකිය.

Intel යන්ත්‍රවල, ඔබ Apple සංදර්ශක වෙත සම්බන්ධ විය යුත්තේ සාමාන්‍ය Thunderbolt cable එකක් භාවිතයෙනි. Thunderbolt නොමැති වෙනත් යන්ත්‍රවල, එය ක්‍රියා කරවීමට ඔබට සාමාන්‍යයෙන් [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) එකක් භාවිතා කිරීමට සිදු වේ.
