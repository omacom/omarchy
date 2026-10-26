# මොනිටර

Omarchy පෙරනිමියෙන් ඔබ 2x-හැකි retina-class තිරයක් භාවිතා කරන බව උපකල්පනය කරයි. ඒ ලස්සන, තියුණු programmer fonts ලැබෙන්න ඔබට ඕනෑ වෙන්නේ මෙයයි. අධි-විභේදන තිර සහිත අලුත් premium laptops සියල්ලම පාහේ ප්‍රශස්ත කර ඇත්තේ මේ සඳහායි. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) හෝ 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) තිරයක ඔබට ධාවනය කිරීමට අවශ්‍ය වෙන්නේද මෙයයි.

නමුත් ඔබ PPI 218ක් හෝ ඊට වැඩි තිරයක් භාවිතා කරන්නේ නැත්නම්, ඔබට monitor settings වෙනස් කිරීමට අවශ්‍ය වනු ඇත. උදාහරණයක් ලෙස, ඔබට 27" හෝ 32" 4K තිරයක් තිබේ නම්, `~/.config/hypr/monitors.lua` විවෘත කර (Omarchy මෙනුවේ _සැකසුම > මොනිටර_ හරහා) එම සංයෝජනය සඳහා නිර්දේශයට මාරු වීමෙන් ඔබට fractional scaling භාවිතා කළ හැකිය:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

ඔබ 1080p හෝ 1440p තිරයක් භාවිතා කරන්නේ නම්, ඔබට බොහෝ විට අවශ්‍ය වන්නේ 1x scaling පමණි, එබැවින් ඔබට මෙය භාවිතා කළ හැකිය:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` වෙත කරන වෙනස්කම් අදාළ වන්නේ වෙනස් කිරීමෙන් පසුව ආරම්භ කරන applications වලටයි (GTK පිළිගන්නේ පූර්ණ සංඛ්‍යා පමණි, එබැවින් එය ඔබේ monitor scale එකට ළඟම පූර්ණ සංඛ්‍යාවේ තබා ගන්න). එබැවින් වෙනස් කිරීමෙන් පසුව විශාලව පෙනෙන windows ඔබ සතුව තිබේ නම් ඒවා වසා දැමීමට වග බලා ගන්න (නැතහොත් `Ctrl + Alt + Del` සමඟ සියලුම windows වසන්න!).

ඉහළට යාමට `Super + /` සහ පහළට යාමට `Super + Alt + /` භාවිතා කරමින් ඔබට ප්‍රධාන monitor scaling අනුපාත (1x, 1.25x, 1.6x, 2x, 3x, 4x) අතර ඉක්මනින් ගමන් කළ හැකිය. ඔබට පෙරනිමි configuration එක තිබේ නම්, මෙම වෙනස්කම් reboot කිරීමෙන් පසුවද පවතිනු ඇත.

### පෙළ විශාල හෝ කුඩා කිරීම

Monitor scaling මඟින් සියල්ලේම ප්‍රමාණය වෙනස් කරයි. ඔබට අවශ්‍ය වන්නේ විශාල හෝ කුඩා _පෙළ_ පමණක් නම්, ඒ සඳහා තනි knob එකක් තිබේ:

```
omarchy display text size 14
```

එය 9 සහ 20 අතර pixel ප්‍රමාණයක් ගන්නා අතර, මුළු desktop එකම අනුපාතයේ තබා ගැනීමට Omarchy shell එක, GTK applications සහ ඔබේ terminal එක එකට ගෙන යයි. ඔබ සිටින්නේ කොතැනදැයි බැලීමට argument එකක් නොමැතිව එය ධාවනය කරන්න, සහ පෙරනිමියට ආපසු යාමට `omarchy display text size reset` භාවිතා කරන්න. Foot යනු එකම පසුගාමියාය: එහි config එක reload කිරීමට ක්‍රමයක් නැත, එබැවින් ඔබ අලුත් එකක් විවෘත කරන තුරු ධාවනය වන terminals ඒවායේ පැරණි ප්‍රමාණයම තබා ගනී.

### ලැප්ටොප් තිර දිගු කිරීම සහ පිළිබිඹු කිරීම

ඔබ ඔබේ ලැප්ටොප් එකට බාහිර තිරයක් සම්බන්ධ කළ විට, තිරය ස්වයංක්‍රීයව දිගු වේ. නමුත් Omarchy මෙනුවේ _ඇරඹුම > දෘඩාංග_ හෝ `Super + Ctrl + Alt + Delete` භාවිතා කරමින් ඔබට ඒ වෙනුවට එය පිළිබිඹු කිරීමට වෙනස් කළ හැකිය. එම බාහිර තිරය projector එකක් නම්, සහ ඔබට වැඩ කරමින් සිටින අතරතුර යමක් පෙන්වීමට අවශ්‍ය නම් මෙය විශේෂයෙන් උපකාරී වේ.

ඔබ දිගු කරමින් සිටින විට, ලැප්ටොප් එකේ lid එක වැසීමෙන් අභ්‍යන්තර තිරය ස්වයංක්‍රීයව අක්‍රිය වේ. Lid එක විවෘත කිරීමෙන් එය නැවත ක්‍රියාත්මක වේ. Omarchy මෙනුවේ _ඇරඹුම > දෘඩාංග_ හෝ `Super + Ctrl + Delete` භාවිතා කරමින් ඔබට මෙය අතින්ද පාලනය කළ හැකිය.

### තිර කිහිපයක් සැකසීම

Hyprland තිර කිහිපයක් සමඟ ඉතා හොඳින් ක්‍රියා කරයි. ඒවා සකසන්නේ කෙසේද යන්න පිළිබඳව [Hyprland monitor documentation](https://wiki.hypr.land/Configuring/Basics/Monitors/) තුළින් වැඩිදුර කියවන්න. Omarchy තුළ, මේවා `hl.monitor` entries ලෙස `~/.config/hypr/monitors.lua` තුළට යයි — නිශ්චිත monitor එකක් විභේදනයකට, පිහිටීමකට සහ භ්‍රමණයකට pin කිරීම සඳහා අදහස් දක්වා ඇති උදාහරණ සමඟ ගොනුව එයි.

සෑම monitor එකකටම තමන්ගේම workspaces 1 සිට 10 දක්වා තිබේ, එබැවින් `Super + 1` යන්නෙන් හැමවිටම අදහස් වන්නේ ඔබ සිටින monitor එකේ පළමු workspace එකයි. තිරය පිටුපසින්, Hyprland තවමත් සියලුම monitors හරහා workspaces අංකනය කරයි: ඔබේ ලැප්ටොප් තිරයට (හෝ පළමු monitor එකට) 1–10 ද, ඊළඟ monitor එකට 11–20 ද, ඒ ආකාරයටම ලැබෙන අතර, ඔබ එය plug කරන සෑම අවස්ථාවකම සෑම monitor එකක්ම එහි block එක තබා ගනී. ඔබ නිශ්චිත monitor එකක් සඳහා [workspace rules](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) හෝ window rules ලියන්නේ නම් එම අංක භාවිතා කරන්න, එබැවින් workspace 12 යනු ඔබේ දෙවන monitor එකේ දෙවන workspace එකයි. `~/.local/state/omarchy/monitor-workspaces` මඟින් සෑම monitor එකකටම ඇත්තේ කුමන block එකදැයි ලැයිස්තුගත කරයි.

ඊතල යතුරු ක්‍රියා කරන්නේ ඔබේ සැකසුමේ පොදු දාරයක් බෙදා ගන්නා monitors හරහාය. කොනකින් පමණක් ස්පර්ශ වන, හෝ ඒවා අතර පරතරයක් ඇති තිර අසල්වැසියන් නොවේ, එබැවින් ඒවා අතර යාමට `Ctrl + Alt + Tab` භාවිතා කරන්න.

| Hotkey | Monitors හරහා |
| --- | --- |
| `Super + Arrow` | එම දිශාවට තවත් window එකක් ඉතිරි නොවූ විට එම පැත්තේ ඇති monitor එක වෙත focus එක ගෙන යයි |
| `Super + Shift + Arrow` | එම පැත්තේ ඇති monitor එකේ window එකක් සමඟ හුවමාරු වේ |
| `Super + Alt + Arrow` | Window එක එම පැත්තේ ඇති monitor එකේ group එකකට ගෙන යයි |
| `Super + Shift + Ctrl + Arrow` | Window එක එම පැත්තේ ඇති monitor එක වෙත, එය පෙන්වන workspace එක මතට ගෙන යයි |
| `Super + Shift + Alt + Arrow` | Workspace එක එම පැත්තේ ඇති monitor එක වෙත ගෙන යයි, එය නිදහස් නම් එහි අංකය තබා ගනී |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | සැකසුම කුමක් වුවද, ඊළඟ හෝ පෙර monitor එක වෙත focus එක ගෙන යයි |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | ඔබ සිටින monitor එකේම රැඳී සිටියි |

තිර කිහිපයක පිහිටීම සම්බන්ධයෙන් ඔබට උපකාර කිරීමට TUI එකක් අවශ්‍ය නම්, ඔබට [Hyprmon](https://github.com/erans/hyprmon/) ද පරීක්ෂා කළ හැකිය.

### දීප්තිය පාලනය කිරීම

Monitor දීප්තිය පාලනය කරන්නේ දීප්තිය ඉහළ/පහළ දැමීම සඳහා ඇති කැප වූ function keys මගිනි. මේවා එබීමේදී ඔබ shift ඔබාගෙන සිටියහොත්, ඔබ උපරිම හෝ අවම දීප්තියට යනු ඇත. යතුරු මඟින් පාලනය කරන්නේ ඔබ focus වී සිටින තිරයයි, එබැවින් DDC/CI කතා කරන බාහිර monitors ලැප්ටොප් තිරය මෙන්ම සකසනු ලැබේ.

### Apple තිර

ඔබ Apple තිරයක් භාවිතා කරන්නේ නම්, ඔබ Apple තිරය මත focus වී සිටී නම් සාමාන්‍ය keyboard brightness keys ද ස්වයංක්‍රීයව ක්‍රියා කරනු ඇත. මෙය සිදු කරන්නේ `asdcontrol` command එක හරහාය.

ඔබ Apple 6K XDR තිරයක් භාවිතා කරන්නේ නම්, ඔබේ `hyprctl monitors` ලැයිස්තුවේ phantom තිරයක් ඔබට දැකිය හැකි බව සලකන්න. _සැකසුම > මොනිටර_ හරහා `hl.monitor({ output = "DP-2", disabled = true })` වැනි දෙයක් සමඟ ඔබට මෙය අක්‍රිය කළ හැකිය.

Intel යන්ත්‍රවල, ඔබ Apple තිරවලට සම්බන්ධ විය යුත්තේ සාමාන්‍ය Thunderbolt cable එකක් භාවිතා කරමිනි. Thunderbolt නැති අනෙකුත් යන්ත්‍රවල, එය ක්‍රියාත්මක කිරීමට ඔබට සාමාන්‍යයෙන් [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) එකක් භාවිතා කිරීමට සිදු වනු ඇත.
