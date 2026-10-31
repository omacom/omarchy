# ඩොට්ෆයිල්ස්

Omarchy ප්‍රධාන වශයෙන් වින්‍යාස කරනු ලබන්නේ `~/.config` තුළ පවතින ඊනියා dotfiles හරහාය. ඒවා ඔබේ වෙනස්කම් සඳහා වූ ඔබේම ගොනු ලෙස සැලකේ. `/usr/share/omarchy` තුළ පවතින ගොනු Omarchy ටම අයත් වන අතර, ඔබ ඒවා සමඟ කරදර නොවිය යුතුය. `/usr/share/omarchy` තුළ යමක් වෙනස් කිරීමට ඔබට අවශ්‍ය නම්, ඒ වෙනුවට ඔබ එම අගය `~/.config` තුළ අභිබවා ලිවිය යුතුය.

ප්‍රධාන වින්‍යාස Omarchy මෙනුව (`Super + Space`) හරහා කෙලින්ම සංස්කරණය කළ හැක, උදාහරණයක් ලෙස _Setup > Keybindings_, _Setup > Input_, සහ _Setup > Config > [file]_. ඔබ මෙය මේ ආකාරයෙන් කරන විට, වින්‍යාස සංස්කරණයෙන් පසු නැවත ආරම්භ කළ යුතු ඕනෑම ක්‍රියාවලියක්, ඔබ සංස්කාරකයෙන් ඉවත් වූ පසුව ස්වයංක්‍රීයවම නැවත ආරම්භ වේ (පෙරනිමියෙන් Neovim — `:wq`, මතක තබා ගන්න! — නමුත් ඔබට එය _Setup > Defaults > Editor_ හරහා වෙනස් කළ හැක).

මෙන්න `~/.config` තුළ ඇති ප්‍රධාන ගොනු සහ ඒවා පාලනය කරන දේ පිළිබඳ ලැයිස්තුවක්:

| ගොනුව                  | අරමුණ              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | ප්‍රධාන Hyprland වින්‍යාසය. Omarchy පෙරනිමි සැකසුම් සහ පහත ඔබේ override ගොනු පූරණය කරයි. [Hyprland වින්‍යාස ගැන වැඩිදුර ඉගෙන ගන්න](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | ඔබේම keybindings සහ පෙරනිමි සැකසුම් සඳහා වන overrides. |
| `~/.config/hypr/monitors.lua` | monitor panel එකෙන් ආවරණය නොවන monitor සැකසුම්, භ්‍රමණය, අමතර modes, හෝ monitor එකක් අක්‍රියව තැබීම වැනි දේ. |
| `~/.config/hypr/input.lua` | ඔබේ keyboard layout එක, mouse එක, සහ trackpad සැකසුම් පාලනය කරයි. |
| `~/.config/hypr/looknfeel.lua` | gaps, borders, animations, සහ පෙනුමේ ඉතිරි සියල්ල පාලනය කරයි. |
| `~/.config/hypr/autostart.lua` | සැසිය සමඟ ආරම්භ වන අමතර ක්‍රියාවලි පාලනය කරයි. |
| `~/.config/omarchy/shell.json` | Omarchy shell එක පාලනය කරයි: bar එකේ පිහිටීම, layout එක, සහ widgets, තවද screensaver, lock, සහ idle කාල සැකසුම්. |
| `~/.config/foot/foot.ini` | ඔබේ terminal එක පාලනය කරයි (foot යනු පෙරනිමියයි). |
| `~/.XCompose` | ඔබේ ඉක්මන්-ප්‍රවේශ emoji සහ නම/ඊමේල් ස්වයං-සම්පූර්ණ කිරීම අර්ථ දක්වයි. වෙනස්කම් කිරීමෙන් පසු `omarchy-restart-xcompose` ධාවනය කිරීමට වග බලා ගන්න. |

ඔබ ඔබේම සැකසුම සියුම් ලෙස සකස් කිරීම සඳහා බොහෝ වෙනස්කම් කිරීමට පටන් ගන්නේ නම්, මෙම සියලු dotfiles උපස්ථ (backup) කිරීම හොඳ අදහසකි. [Stow ඒ සඳහා කදිම ක්‍රමයකි](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### සැසිය සමඟ ඔබේම apps ආරම්භ කිරීම

ඔබ ලොග් වන සෑම අවස්ථාවකම යමක් ධාවනය වීමට ඔබට අවශ්‍ය නම් — sync daemon එකක්, chat app එකක්, ඔබේම script එකක් — එය `~/.config/hypr/autostart.lua` තුළ දමන්න:

```lua
o.launch_on_start("my-service")
```

එය සැසියේ කොටසක් ලෙස විධානය ආරම්භ කරයි, එබැවින් ඔබ නැවත ලොග් අවුට් වන විට එය නිසි ලෙස පිරිසිදු කෙරේ.

### පද්ධති සිදුවීම් මත scripts ධාවනය කිරීම

Omarchy අවස්ථා කිහිපයකදී hooks ක්‍රියාත්මක කරයි, ඔබට ඔබේම scripts ඒවා මත රැඳවිය හැක. ඒවා `~/.config/omarchy/hooks/<event>.d/` තුළ, එක් සිදුවීමකට එක් directory එක බැගින් පවතින අතර, එහි ඇති සෑම ක්‍රියාත්මක කළ හැකි ගොනුවක්ම එම සිදුවීම සිදු වන විට ධාවනය වේ:

| සිදුවීම | එය ධාවනය වන්නේ කවදාද |
| ----- | ------------ |
| `post-boot` | desktop එක ආරම්භ වූ වහාම පසුව |
| `post-update` | `omarchy update` අවසානයට ආසන්නයේ, packages, migrations, සහ service නැවත ආරම්භ කිරීමෙන් පසු, mise tools යාවත්කාලීන කිරීමට පෙර |
| `pre-refresh-pacman` | `omarchy refresh pacman` package වින්‍යාසය නැවත සමමුහුර්ත කිරීමෙන් පසු, එය packages යාවත්කාලීන කිරීමට පෙර; channel මාරුවක් එම refresh පියවරේදීම එය ධාවනය කරයි |
| `theme-set` | තේමාව වෙනස් කිරීමකින් පසු (තේමා නම `$1` තුළ) |
| `font-set` | අකුරු වෙනස් කිරීමකින් පසු (අකුරු නම `$1` තුළ) |
| `battery-low` | බැටරිය අඩු වන විට (ප්‍රතිශතය `$1` තුළ) |

`pre-refresh-pacman` hook එක යනු අභිරුචි repositories හෝ `IgnorePkg` පේළි අයත් විය යුතු තැනයි, මන්ද එය package ගනුදෙනුවට පෙර ධාවනය වේ. යාවත්කාලීන කිරීම් සම්බන්ධ hooks දෙකම, Omarchy එහි හැඹිලිගත කළ sudo අවසරය ඉවත් කිරීමෙන් පසු ඔබේ පරිශීලකයා ලෙස ධාවනය වේ, එබැවින් `sudo` භාවිතා කරන hook එකකට එයටම ආවේණික අවසරයක් අවශ්‍ය වන අතර එය ඔබේ මුරපදය ඉල්ලා සිටිය හැක.

එම එක් එක් directory තුළ දැනටමත් hook එකක හැඩය පෙන්වන `.sample` ගොනුවක් තිබේ — එය ක්‍රියාවට නැංවීම සඳහා නමෙන් `.sample` කොටස ඉවත් කරන්න. ඔබ වෙනත් තැනක ලියූ script එකක් ස්ථාපනය කිරීමට, `omarchy hook install post-boot ~/my-hook` භාවිතා කරන්න, එය එය පිටපත් කර තබා ක්‍රියාත්මක කළ හැකි කරයි.

### ඔබේම මෙනු ඇතුළත් කිරීම් එකතු කිරීම

Omarchy මෙනුව (`Super + Space`) `~/.config/omarchy/extensions/omarchy-menu.jsonc` සංස්කරණය කිරීමෙන් ඔබේම පේළි සමඟ දීර්ඝ කළ හැක. ඇතුළත් කිරීම් තිත් සහිත id එකකින් යතුරු ලැබී ඇති අතර, id එකයි ඒවා ගස තුළ තබන්නේ, එබැවින් `personal` root මෙනුවේ දිස් වේ, `personal.notes` එහි ඇතුළත දිස් වේ:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

දැනට පවතින id එකක් නැවත භාවිතා කරන්න, එවිට ඔබ අලුත් එකක් එකතු කිරීම වෙනුවට එම පේළිය අභිබවා ලියයි. ගොනුව පවතින සියලුම fields අදහස් දැක්වීම් ලෙස ලේඛනගත කර ඇතුවා සමඟ නැව්ගත කෙරේ.

### ඔබේම shell exports, functions, සහ aliases එකතු කිරීම

Omarchy බොහෝ ergonomic aliases සහ ප්‍රයෝජනවත් functions සමඟ නැව්ගත කෙරේ, නමුත් ඔබේම දෑ එකතු කිරීමට අවශ්‍ය වීම ඉතා සුලභය. ඔබ aliases, functions, සහ exports යන දෙකම `~/.bashrc` තුළ එකතු කළ යුතුය. මෙම ගොනුව යාවත්කාලීන කිරීම්වලදී අභිබවා ලියනු නොලැබේ. Omarchy පෙරනිමි සැකසුම් කිසිවක් වෙනස් කිරීමට ඔබට අවශ්‍ය නම්, ඔබට ඒවා ද මෙහි ආරක්ෂිතව එකතු කළ හැක.

### desktop එක සඳහා environment variables සැකසීම

Desktop සැසි exports අයත් වන්නේ `~/.config/uwsm/env.d/` තුළටය. මෙම ගොනු ඔබේ desktop එක ආරම්භ වීමට පෙර ධාවනය වේ, එබැවින් shell දෝෂයක් ඔබව නැවත login තිරය වෙත යැවිය හැක. ඒවා සංස්කරණය කරන අතරතුර ක්‍රියා කරන terminal එකක් විවෘතව තබා ගන්න. override එකක් අක්‍රිය කිරීමට, එය `env.d` වෙතින් පිටතට ගෙන යන්න. වෙනසක් login වීම වළක්වන්නේ නම් [ඇතුළු වීම යථා තත්ත්වයට පත් කිරීම](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) බලන්න.

### අභ්‍යන්තර Omarchy ගොනු වෙනස් කිරීම

බලන්න, මේක ඔබේ පරිගණකයයි. ඔබට එය සමඟ අවශ්‍ය ඕනෑම දෙයක් කළ හැක, නමුත් `/usr/share/omarchy` තුළ ඇති ගොනු කෙලින්ම වෙනස් කිරීමට එරෙහිව මම ඔබට උපදෙස් දෙමි. ඒවා Omarchy pacman package එකට අයත් වේ, එබැවින් ඔබේ වෙනස්කම් ඊළඟ යාවත්කාලීනයේදී සරලවම අභිබවා ලියනු ලැබේ. ඒ වෙනුවට ඔබ කැමති නැති ඕනෑම පෙරනිමි අගයක් `~/.config/*` ෆෝල්ඩරය තුළ අභිබවා ලිවීම ඔබට වඩා හොඳය.

ඔබට එම ආකාරයෙන් සෑම දෙයක්ම වාගේ වෙනස් කළ හැක, පෙරනිමි keybindings වැනි. [Obsidian](https://obsidian.md/) වෙනුවට [Joplin](https://joplinapp.org/) යෙදීමට, `~/.config/hypr/bindings.lua` සංස්කරණය කරන්න, උදාහරණයක් ලෙස (`omarchy-pkg-add joplin-bin` සමඟ ස්ථාපනය කරන්න):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` එහි ප්‍රතිස්ථාපනය එකතු කිරීමට පෙර පවතින binding එක ඉවත් කරයි. launch helpers සහ binding options ඇතුළුව, එය `o.bind` හා සමානම arguments ගනී. binding එකක් එකතු කිරීමට `o.bind` භාවිතා කරන්න, හෝ එය ප්‍රතිස්ථාපනය නොකර එකක් ඉවත් කිරීමට `hl.unbind` භාවිතා කරන්න.

ඔබ අභ්‍යන්තර Omarchy ගොනු හැක් කිරීමටම අවධාරණය කරන්නේ නම්, _Update > Channel > Dev_ හරහා dev channel එකට මාරු වන්න. එය Omarchy `~/omarchy` තුළ ඇති source code හි git checkout එකකට සම්බන්ධ කරයි, එය ඔබට හිතේ හැටියට වෙනස් කිරීමට නිදහස තිබේ. ඔයාට කියන්න මෙතන কেউත් නෑ!

### ඕනෑම වෙනස්කමක් යළි සැකසීම

ඔබ වින්‍යාසයන් අවුල් කර ගන්නේ නම්, Omarchy මෙනුවේ _Update > Config_ හරහා ඔබට ඒවා සැමවිටම පෙරනිමි සැකසුම් වෙත ආපසු යැවිය හැක. නැතහොත් සියල්ල යළි සැකසීමට `omarchy reinstall configs` ධාවනය කිරීමෙන්.
