# ගැටලු විසඳීම

### යාවත්කාලීනයකින් මම මගේ පද්ධතිය කඩා දැම්මා!

පළමුව ඔබේ මෑත යාවත්කාලීනයට පෙර තිබූ අනුවාදයට [ඔබේ පද්ධතිය පෙරළා ගන්න](47-system-snapshots.md) උත්සාහ කරන්න. එය වැඩ නොකරන්නේ නම්, Discord හි #omarchy-help හි ඔබේ ගැටලුව බෙදා ගැනීමට `omarchy-debug` භාවිත කරන්න. ඒ සියල්ලම අසාර්ථක වුවහොත්, `omarchy-reinstall` භාවිතයෙන් පෙරනිමි configs සහ packages නැවත ස්ථාපනය කළ හැකිය.

### සමහර apps මගේ display එකේ මෙතරම් විශාල වන්නේ ඇයි?

Omarchy 2x අධි-විභේදන display එකක් ඇතැයි උපකල්පනය කරයි, එබැවින් ඔබ monitor panel එකේ scale එකක් තෝරන තුරු එය `GDK_SCALE` 2 ලෙස සකසයි. ඔබ 1x display එකක සිටින අතර GTK හෝ X11 apps අධික විශාලත්වයෙන් එන්නේ නම්, monitor panel එකේ එයට 1x තෝරන්න, නැතහොත් `~/.config/hypr/monitors.lua` වෙත `hl.env("GDK_SCALE", "1")` එක් කරන්න (ඉන්පසු අධික විශාල ඕනෑම app එකක් restart කරන්න). [monitors පිළිබඳ අත්පොත](33-monitors.md) බලන්න.

Spotify සඳහා, UI එක කුඩා කිරීමට `Ctrl + Minus` භාවිත කළ හැකිය (එය විශාල කිරීමට `Ctrl + Plus`).

### මගේ සියලුම Super key binds වැඩ කිරීම නැවැත්වූයේ ඇයි?

සමහර ASUS ROG සහ TUF laptops වල, `Fn + Super` යනු firmware Windows-key lock එකක් toggle කරන, පහසුවෙන් මග හැරෙන chord එකකි (ඔබ අහම්බෙන් game එකකින් පිටත් නොවීම සඳහා gaming සඳහා අදහස් කළ එකකි). එය සිදු වූ බව තිරයේ කිසිවක් ඔබට නොකියයි. Lock එක ක්‍රියාත්මකව තිබෙන අතරතුර, Super කිසිවක් emit නොකරයි — එබැවින් Super භාවිත කරන සෑම Omarchy bind එකක්ම නිකම්ම නවතියි, එය Hyprland කැඩුණු ආකාරයක් පෙනේ.

ඔබ `~/.config/hypr/` තුළ හාරා බැලීමට පෙර `Fn + Super` වරක් ඔබන්න, එයින් Super නැවත නොලැබෙන්නේ නම්, lock එක ක්‍රියාත්මකව තබා නොගැනීමට එය නැවත ඔබන්න. මෙය Fn-lock නොවේ, එය F-key පේළිය කරන දේ පමණක් වෙනස් කරයි.

### මගේ Wi-Fi, Bluetooth, audio, හෝ trackpad දැන් වැඩ කිරීම නැවැත්තුවා

ඔබ reboot කිරීමට පෙර, ගැටලුකාරී subsystem එක වෙනම restart කිරීමට උත්සාහ කරන්න. Omarchy menu එකේ _Update > Hardware_ හි Wi-Fi, Bluetooth, Audio, සහ Trackpad ඇත, ඒවායින් එකක් reload කිරීම "මිනිත්තු පහකට පෙර එය වැඩ කළා" තත්ත්වයන්ගෙන් බහුතරයක් විසඳයි — නැවත සම්බන්ධ නොවන Bluetooth headset එකක්, suspend එකකින් පසු අක්‍රිය වූ trackpad එකක්, ඔබ monitor එකක් ගලවූ විට අතුරුදහන් වූ ශබ්දය.

### මගේ බාහිර speakers වාදනය නොවන්නේ ඇයි?

සමහරවිට ඒවා primary output එක ලෙස සකසා නොමැති නිසා විය හැකිය. Bar එකේ දකුණු පැත්තේ speaker icon එක click කරන්න, එයින් volume popup එක විවෘත වේ, එහිදී ඔබට output device එක තෝරා ගත හැකිය (per-app volumes මිශ්‍ර කිරීමටද හැකිය).

### මගේ laptop speakers වල ශබ්දය අමුතුයි

සමහර laptops වල, Omarchy built-in speakers වල frequency response එක නිවැරදි කරන speaker tuning එකක් ස්වයංක්‍රීයව යොදයි. `omarchy audio tuning status` මගින් ඔබේ machine එකේ එකක් ක්‍රියාත්මකදැයි කියයි, ඔබ speakers raw ලෙස ඇසීමට කැමති නම් `omarchy audio tuning off` එය අක්‍රිය කරයි.

### මට මගේ password එකෙන් login වීමට හෝ sudo කිරීමට නොහැකි ඇයි?

ඔබ එය බොහෝ වාර ගණනක් වැරදියට type කර locked out වී ඇත. මෙය lock screen එකේ සිදු වන්නේ නම්, root ලෙස login විය හැකි නව TTY එකක් ආරම්භ කිරීමට ඔබට `CTRL + ALT + F2` ඔබා ගත හැකිය, ඉන්පසු `faillock --reset --user [your-username]` run කරන්න. එයින් lockout එක reset වේ, ඔබ සූදානම්.

### මගේ password එක පිළිගනු ලැබේ, නමුත් මම login screen එකටම ආපසු යමි

කැඩුණු session environment file එකකින්, ඔබේ password එක නිවැරදි වුවද desktop එක ආරම්භ වීම වැළැක්විය හැකිය. `~/.config/uwsm/env.d/` edit කිරීමෙන් පසු මෙය විශේෂයෙන් පරීක්ෂා කිරීම වටී.

`Ctrl + Alt + F2` ඔබන්න, ඔබේ සාමාන්‍ය username එක සහ password එක සමඟ log in වන්න, වත්මන් boot එකේ user journal එක පරීක්ෂා කරන්න:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Env output mark එක හමු නොවූ බවට පණිවිඩයකට මඳකට පෙර, `bad substitution` වැනි ඔබේ environment files එකක් නම් කරන error එකක් සොයන්න. නැවත log in වීමට උත්සාහ කිරීමට පෙර එම file එක `env.d` වලින් ඉවත් කරන්න. උදාහරණයක් ලෙස, error එක `99-custom` නම් කරන්නේ නම්:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM syntax error එකක් සහිත file එකක් skip කරයි, නමුත් file එක run වන විට පමණක් පෙනෙන `bad substitution` වැනි fatal error එකකින් තවමත් desktop එක ආරම්භ වීම වැළැක්විය හැකිය. System snapshot rollback එකකින් මෙම files අලුත්වැඩියා නොවේ, මන්ද `/home` rollback නොවන බැවිනි.

ඔබට log in විය හැකි වූ පසු, saved copy එක ආපසු ගෙන යාමට පෙර එය නිවැරදි කරන්න. `sh -n` file එක run නොකර syntax errors අල්ලා ගනී, නමුත් එය sourced කරන විට සිදුවන සෑම error එකක්ම අල්ලා ගත නොහැකිය. වෙනස්කම් test කරන අතරතුර වැඩ කරන terminal එකක් විවෘතව තබා ගන්න.

### මගේ 1Password SSH Agent / CLI සඳහා 1Password authorization prompts නොපෙනෙන්නේ ඇයි?

මෙය හේතු 2ක් නිසා සිදු විය හැකිය:

Rich approval prompt එක පෙනීමට නම්, Settings > Advanced > Use Hardware Acceleration ක්‍රියාත්මක කළ යුතුය. _සටහන: මෙය වැඩ ආරම්භ කිරීමට reboot එකක් අවශ්‍ය වේ._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

නැතහොත් ඔබ boot up වූ දා සිට 1Password launch කර නොමැති නම්, prompt එක නොපෙනේ.
