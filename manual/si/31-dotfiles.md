# Dotfiles

Omarchy මූලික වශයෙන් වින්‍යාස කරනු ලබන්නේ `~/.config` තුළ පවතින dotfiles ලෙස හැඳින්වෙන ඒවා හරහාය. ඒවා ඔබේ වෙනස්කම් සඳහා වූ ඔබේම ගොනු ලෙස සැලකේ. `/usr/share/omarchy` තුළ පවතින ගොනු අයිති වන්නේ Omarchy එකටම වන අතර, ඔබ ඒවාට අත තැබිය යුතු නැත. ඔබට `/usr/share/omarchy` තුළ යමක් වෙනස් කිරීමට අවශ්‍ය නම්, ඒ වෙනුවට ඔබ කළ යුත්තේ `~/.config` තුළ එහි අගය උඩින් ලිවීමයි.

ප්‍රධාන වින්‍යාසයන් Omarchy මෙනුවෙන් (`Super + Space`) සෘජුවම සංස්කරණය කළ හැකිය, උදාහරණයක් ලෙස _Setup > Keybindings_, _Setup > Input_, සහ _Setup > Config > [file]_ වැනි ලෙස. ඔබ මේ ආකාරයෙන් කරන විට, වින්‍යාස සංස්කරණයෙන් පසුව නැවත ආරම්භ කළ යුතු ඕනෑම ක්‍රියාවලියක් ඔබ සංස්කාරකයෙන් ඉවත් වූ පසු ස්වයංක්‍රීයවම නැවත ආරම්භ වනු ඇත (පෙරනිමියෙන් Neovim — `:wq`, මතක තබාගන්න! — නමුත් _Setup > Defaults > Editor_ හරහා ඔබට එය වෙනස් කළ හැකිය).

මෙන්න `~/.config` තුළ ඇති ප්‍රධාන ගොනු සහ ඒවා පාලනය කරන දේ පිළිබඳ ලැයිස්තුවක්:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | ප්‍රධාන Hyprland වින්‍යාසය. Omarchy පෙරනිමි සහ පහත ඔබේ override ගොනු පූරණය කරයි. [Hyprland වින්‍යාසයන් ගැන වැඩිදුර දැනගන්න](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | ඔබේම keybindings සහ පෙරනිමිවල override. |
| `~/.config/hypr/monitors.lua` | භ්‍රමණය, අමතර modes, හෝ monitor එකක් අක්‍රියව තැබීම වැනි, monitor panel එකෙන් ආවරණය නොවන monitor සැකසුම්. |
| `~/.config/hypr/input.lua` | ඔබේ keyboard layout එක, mouse එක, සහ trackpad සැකසුම් පාලනය කරයි. |
| `~/.config/hypr/looknfeel.lua` | gaps, borders, animations, සහ පෙනුමට අදාළ ඉතිරි සියල්ල පාලනය කරයි. |
| `~/.config/hypr/autostart.lua` | සැසිය සමඟ ආරම්භ කරන අමතර ක්‍රියාවලි පාලනය කරයි. |
| `~/.config/omarchy/shell.json` | Omarchy shell එක පාලනය කරයි: bar එකේ පිහිටීම, layout එක, සහ widgets, තවද screensaver, lock, සහ idle කාල සැකසුම්. |
| `~/.config/foot/foot.ini` | ඔබේ terminal එක පාලනය කරයි (foot යනු පෙරනිමියයි). |
| `~/.XCompose` | ඔබේ ඉක්මන් ප්‍රවේශ emoji සහ නම/email autocomplete අර්ථ දක්වයි. වෙනස්කම් කිරීමෙන් පසුව `omarchy-restart-xcompose` ධාවනය කිරීමට වගබලාගන්න. |

ඔබේම සැකසුම සියුම් ලෙස සකස් කිරීම සඳහා ඔබ බොහෝ වෙනස්කම් කිරීමට සිදුවුවහොත්, මේ dotfiles සියල්ල backup කිරීම හොඳ අදහසකි. [Stow එය කිරීමට ඉතා හොඳ ක්‍රමයකි](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### සැසිය සමඟ ඔබේම apps ආරම්භ කිරීම

ඔබ ලොග් වන සෑම අවස්ථාවකම යමක් ක්‍රියාත්මක වීමට ඔබට අවශ්‍ය නම් — sync daemon එකක්, chat app එකක්, ඔබේම script එකක් — එය `~/.config/hypr/autostart.lua` තුළ තබන්න:

```lua
o.launch_on_start("my-service")
```

එය විධානය සැසියේ කොටසක් ලෙස ආරම්භ කරයි, එබැවින් ඔබ නැවත ලොග් අවුට් වන විට එය නිසි ලෙස පිරිසිදු කරනු ලැබේ.

### පද්ධති සිදුවීම්වලදී scripts ධාවනය කිරීම

Omarchy අවස්ථා ස්වල්පයකදී hooks ක්‍රියාත්මක කරයි, ඔබට ඔබේම scripts ඒවා මත එල්ලිය හැකිය. ඒවා `~/.config/omarchy/hooks/<event>.d/` තුළ පවතී, එක් සිදුවීමකට එක් directory එක බැගින්, සහ සිදුවීම සිදුවන විට එහි ඇති සෑම executable ගොනුවක්ම ක්‍රියාත්මක වේ:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | ඩෙස්ක්ටොප් එක ආරම්භ වූ වහාම පසුව |
| `post-update` | packages, migrations, සහ service restarts වලින් පසුව, mise tools යාවත්කාලීන කිරීමට පෙර, `omarchy update` එක අවසන් වීමට ආසන්නව |
| `pre-refresh-pacman` | `omarchy refresh pacman` මඟින් package config එක නැවත sync කිරීමෙන් පසුව, එය packages යාවත්කාලීන කිරීමට පෙර; channel මාරුවක් එම refresh පියවරේදීම එය ක්‍රියාත්මක කරයි |
| `theme-set` | තේමා වෙනස්කමකින් පසුව (තේමා නාමය `$1` තුළ) |
| `font-set` | font වෙනස්කමකින් පසුව (font නාමය `$1` තුළ) |
| `battery-low` | බැටරිය අඩු වන විට (ප්‍රතිශතය `$1` තුළ) |

`pre-refresh-pacman` hook එක යනු custom repositories හෝ `IgnorePkg` පේළි අයිති වන ස්ථානයයි, මන්ද එය package transaction එකට පෙර ක්‍රියාත්මක වේ. යාවත්කාලීනයට අදාළ hooks දෙකම Omarchy එහි cached sudo authorization එක ඉවත් කිරීමෙන් පසුව ඔබේ user ලෙස ක්‍රියාත්මක වේ, එබැවින් `sudo` භාවිතා කරන hook එකකට එයටම ආවේණික authorization එකක් අවශ්‍ය වන අතර ඔබේ password එක ඉල්ලා සිටිය හැකිය.

එම directories එකිනෙකෙහිම දැනටමත් hook එකක හැඩය පෙන්වන `.sample` ගොනුවක් තිබේ — එය ක්‍රියාත්මක කිරීමට නාමයෙන් `.sample` ඉවත් කරන්න. ඔබ වෙනත් තැනක ලියූ script එකක් ස්ථාපනය කිරීමට, `omarchy hook install post-boot ~/my-hook` භාවිතා කරන්න, එය එය පිටපත් කර ඇතුළත් කර executable බවට පත් කරයි.

### ඔබේම menu entries එකතු කිරීම

`~/.config/omarchy/extensions/omarchy-menu.jsonc` සංස්කරණය කිරීමෙන් Omarchy මෙනුව (`Super + Space`) ඔබේම පේළි සමඟ දිගු කළ හැකිය. Entries යතුරු කර ඇත්තේ තිත් සහිත id එකකින් වන අතර, id එක මඟින් ඒවා tree එක තුළ ස්ථානගත වේ, එබැවින් `personal` මූල මෙනුවේ දිස්වන අතර `personal.notes` එය තුළ දිස්වේ:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

පවතින id එකක්ම නැවත භාවිතා කරන්න, එවිට ඔබ නව එකක් එකතු කිරීම වෙනුවට එම පේළිය override කරයි. ගොනුව ලබාගත හැකි සියලුම fields comments ලෙස ලේඛනගත කරමින් ලබාදේ.

### ඔබේම shell exports, functions, සහ aliases එකතු කිරීම

Omarchy ergonomic aliases සහ ප්‍රයෝජනවත් functions රාශියක් සමඟ ලබාදෙනු ලැබේ, නමුත් ඔබේම ඒවා එකතු කිරීමට අවශ්‍ය වීම ඉතා සුලභය. ඔබ aliases, functions, සහ exports යන දෙකම `~/.bashrc` තුළ එකතු කළ යුතුය. මෙම ගොනුව යාවත්කාලීනයන්හිදී උඩින් ලියනු නොලැබේ. ඔබට Omarchy පෙරනිමි කිසිවක් වෙනස් කිරීමට අවශ්‍ය නම්, ඔබට ආරක්ෂිතව ඒවා මෙහිද එකතු කළ හැකිය.

### අභ්‍යන්තර Omarchy ගොනු වෙනස් කිරීම

බලන්න, මේක ඔබේ පරිගණකය. ඔබට අවශ්‍ය ඕනෑම දෙයක් එයින් කරන්න පුළුවන්, නමුත් `/usr/share/omarchy` තුළ ඇති ගොනු සෘජුවම වෙනස් කිරීමට එරෙහිව මම උපදෙස් දෙමි. ඒවා අයිති වන්නේ Omarchy pacman package එකට වන අතර, එබැවින් ඔබේ වෙනස්කම් ඊළඟ යාවත්කාලීනයේදී සරලවම උඩින් ලියනු ලැබේ. ඒ වෙනුවට `~/.config/*` folder එක තුළ ඔබ කැමති නැති ඕනෑම පෙරනිමි අගයක් උඩින් ලිවීම ඔබට වඩා හොඳය.

ඔබට ඒ ආකාරයෙන් බොහෝ දේ වෙනස් කළ හැකිය, පෙරනිමි keybindings වැනි. උදාහරණයක් ලෙස, [Obsidian](https://obsidian.md/) වෙනුවට [Joplin](https://joplinapp.org/) යෙදීමට (`omarchy-pkg-add joplin-bin` සමඟ ස්ථාපනය කරන්න) `~/.config/hypr/bindings.lua` සංස්කරණය කරන්න:

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` එහි ආදේශකය එකතු කිරීමට පෙර පවතින binding එක ඉවත් කරයි. එය launch helpers සහ binding options ඇතුළුව `o.bind` ගන්නා එම arguments ම ගනී. binding එකක් එකතු කිරීමට `o.bind` භාවිතා කරන්න, නැතහොත් එය ආදේශ නොකර ඉවත් කිරීමට `hl.unbind` භාවිතා කරන්න.

ඔබ අභ්‍යන්තර Omarchy ගොනු hack කිරීමටම බල කරන්නේ නම්, _Update > Channel > Dev_ හරහා dev channel එකට මාරු වන්න. එය Omarchy, `~/omarchy` තුළ ඇති source code එකේ git checkout එකකට සම්බන්ධ කරයි, එය ඔබේ සිතැඟි පරිදි වෙනස් කිරීමට ඔබට නිදහස තිබේ. මෙතන ඔබට කරන්න ඕනෑ දේ කියන්න කිසි කෙනෙක් නැහැ!

### ඕනෑම වෙනස්කමක් යළි පිහිටුවීම

ඔබ වින්‍යාසයන් අවුල් කරගත්තොත්, ඔබට සෑම විටම Omarchy මෙනුවේ _Update > Config_ හරහා ඒවා පෙරනිමි වෙත ආපසු ගෙන යා හැකිය. නැතහොත් සියල්ල යළි පිහිටුවීමට `omarchy reinstall configs` ධාවනය කිරීමෙන්.
