# දෝෂ නිරාකරණය

### යාවත්කාලීනයකින් මගේ පද්ධතිය කැඩුණා!

මුලින්ම ඔබේ මෑත යාවත්කාලීනයට පෙර තිබූ අනුවාදයට [ඔබේ පද්ධතිය ආපසු හරවන්න](47-system-snapshots.md) උත්සාහ කරන්න. එය සාර්ථක නොවුණොත්, Discord හි #omarchy-help තුළ ඔබේ ගැටලුව බෙදා ගැනීමට `omarchy-debug` භාවිතා කරන්න. ඒ සියල්ලත් අසාර්ථක වුවහොත්, `omarchy-reinstall` භාවිතයෙන් පෙරනිමි configs සහ packages නැවත ස්ථාපනය කළ හැකිය.

### සමහර apps මගේ display එකේ මෙතරම් විශාලව පෙනෙන්නේ ඇයි?

Omarchy 2x අධි-විභේදන display එකක් උපකල්පනය කරයි, ඒ සඳහා `~/.config/hypr/monitors.lua` තුළ `GDK_SCALE` 2 ලෙස සැකසීම අවශ්‍ය වේ. නමුත් ඔබ 1x display එකක සිටී නම්, `local omarchy_gdk_scale = 2` යන්න 1 ලෙස වෙනස් කළ හැකිය (ඉන්පසු විශාලව පෙනෙන ඕනෑම app එකක් restart කරන්න). [monitors පිළිබඳ අත්පොත](33-monitors.md) බලන්න.

Spotify සඳහා, UI එක කුඩා කිරීමට `Ctrl + Minus` භාවිතා කළ හැකිය (විශාල කිරීමට `Ctrl + Plus`).

### මගේ Super key binds සියල්ලම ක්‍රියා කිරීම නැවැත්තුවේ ඇයි?

සමහර ASUS ROG සහ TUF laptops වල, `Fn + Super` යනු firmware Windows-key lock එකක් toggle කරන, පහසුවෙන් මග හැරෙන chord එකකි (ක්‍රීඩා කරන විට අහම්බෙන් ක්‍රීඩාවෙන් ඉවත් වීම වැළැක්වීමට අදහස් කළ එකකි). එය සිදු වූ බව තිරයේ කිසිවක් ඔබට නොකියයි. lock එක ක්‍රියාත්මකව තිබෙන අතරතුර, Super කිසිවක් emit නොකරයි — එබැවින් Super භාවිතා කරන සෑම Omarchy bind එකක්ම නතර වේ, එය Hyprland කැඩුණු ආකාරයක් ලෙස පෙනේ.

`~/.config/hypr/` තුළ හාරා බැලීමට පෙර `Fn + Super` වරක් ඔබන්න, එයින් Super නැවත නොලැබුණොත්, lock එක ක්‍රියාත්මකව තබා නොගැනීමට නැවත එය ඔබන්න. මෙය Fn-lock නොවේ, එය F-key පේළිය ක්‍රියා කරන ආකාරය පමණක් වෙනස් කරයි.

### මගේ Wi-Fi, Bluetooth, audio, හෝ trackpad එක ක්‍රියා කිරීම නිකම්ම නැවතුණා

ඔබ reboot කිරීමට පෙර, ගැටලුකාරී subsystem එක එයම පමණක් restart කිරීමට උත්සාහ කරන්න. Omarchy menu එකේ _Update > Hardware_ තුළ Wi-Fi, Bluetooth, Audio, සහ Trackpad ඇත, ඒවායින් එකක් reload කිරීමෙන් "මිනිත්තු පහකට පෙර එය ක්‍රියා කළා" වැනි බොහෝ අවස්ථා නිරාකරණය වේ — නැවත සම්බන්ධ නොවන Bluetooth headset එකක්, suspend එකකින් පසු අක්‍රිය වූ trackpad එකක්, monitor එකක් unplug කළ විට අතුරුදහන් වූ ශබ්දය.

### මගේ බාහිර speakers වාදනය නොවන්නේ ඇයි?

බොහෝ විට ඒවා primary output එක ලෙස සකසා නොතිබීම ඊට හේතුවයි. bar එකේ දකුණු පැත්තේ ඇති speaker icon එක click කරන්න, එවිට volume popup එක විවෘත වේ, එතැනින් ඔබට output device එක තෝරා ගත හැකිය (per-app volumes mix කිරීමටද හැකිය).

### මගේ laptop speakers වල ශබ්දය අමුතුයි

සමහර laptops වල, Omarchy ස්වයංක්‍රීයවම speaker tuning එකක් යොදයි, එය built-in speakers වල frequency response එක නිවැරදි කරයි. `omarchy audio tuning status` මගින් ඔබේ යන්ත්‍රයේ එකක් සක්‍රියදැයි කියයි, ඔබ speakers raw ලෙස ඇසීමට කැමති නම් `omarchy audio tuning off` මගින් එය අක්‍රිය කරයි.

### මට මගේ password එකෙන් login වීමට හෝ sudo කිරීමට නොහැකි ඇයි?

ඔබ බොහෝ විට එය වාර ගණනාවක් වැරදියට type කර lock out වී ඇත. lock screen එකේ මෙය සිදු වන්නේ නම්, `CTRL + ALT + F2` ඔබා නව TTY එකක් ආරම්භ කළ හැකිය, එහි root ලෙස login වී, පසුව `faillock --reset --user [your-username]` run කරන්න. එය lockout එක reset කරයි, ඉන්පසු ඔබට ඉදිරියට යා හැකිය.

### 1Password SSH Agent / CLI සඳහා මගේ 1Password authorization prompts දිස් නොවන්නේ ඇයි?

මෙය හේතු 2ක් නිසා සිදු විය හැකිය:

rich approval prompt එක දිස් වීමට නම්, Settings > Advanced > Use Hardware Acceleration ක්‍රියාත්මක කළ යුතුය. _සටහන: මෙය ක්‍රියා කිරීමට ආරම්භ වීමට reboot එකක් අවශ්‍ය වේ._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

නැතහොත් ඔබ booting up කළ දා සිට 1Password launch කර නොමැති නම්, prompt එක දිස් නොවේ.
