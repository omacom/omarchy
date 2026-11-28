# Dotfiles

Omarchy ප්‍රධාන වශයෙන් වින්‍යාස කරන්නේ `~/.config` තුළ ඇති ඊනියා dotfiles හරහාය. ඒවා ඔබේ වෙනස්කම් සඳහා වූ ඔබේම ගොනු ලෙස සැලකේ. `/usr/share/omarchy` තුළ ඇති ගොනු Omarchy ටම අයත් වන අතර, ඔබ ඒවා සමඟ දැවටිය යුතු නැත. `/usr/share/omarchy` තුළ යමක් වෙනස් කිරීමට ඔබට අවශ්‍ය නම්, ඒ වෙනුවට ඔබ එම අගය `~/.config` තුළ අභිබවා ලිවිය යුතුය.

ප්‍රධාන වින්‍යාස Omarchy මෙනුවෙන් (`Super + Space`) කෙළින්ම සංස්කරණය කළ හැකිය, උදාහරණයක් ලෙස _Setup > Keyboard > Keybindings_, _Setup > Input_, සහ _Setup > Config > [file]_. ඔබ මේ ආකාරයෙන් එය කරන විට, වින්‍යාස සංස්කරණයෙන් පසුව නැවත ආරම්භ කළ යුතු ඕනෑම ක්‍රියාවලියක්, ඔබ සංස්කාරකයෙන් ඉවත් වූ පසු ස්වයංක්‍රීයවම නැවත ආරම්භ වේ (පෙරනිමියෙන් Neovim — `:wq`, මතක තබාගන්න! — නමුත් ඔබට එය _Setup > Defaults > Editor_ හරහා වෙනස් කළ හැකිය).

මෙහි `~/.config` තුළ ඇති ප්‍රධාන ගොනු සහ ඒවා පාලනය කරන දේ පිළිබඳ ලැයිස්තුවක් ඇත:

| ගොනුව                  | අරමුණ              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | ප්‍රධාන Hyprland වින්‍යාසය. Omarchy පෙරනිමි සහ පහත ඔබේ අභිබවා ලියන ගොනු පූරණය කරයි. [Hyprland වින්‍යාස පිළිබඳ වැඩිදුර දැනගන්න](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | ඔබේම keybindings සහ පෙරනිමි අභිබවා ලිවීම්. |
| `~/.config/hypr/monitors.lua` | භ්‍රමණය, අමතර modes, හෝ monitor එකක් අක්‍රියව තබා ගැනීම වැනි monitor panel එකෙන් ආවරණය නොවන monitor සැකසුම්. |
| `~/.config/hypr/input.lua` | ඔබේ keyboard layout, mouse, සහ trackpad සැකසුම් පාලනය කරයි. |
| `~/.config/hypr/looknfeel.lua` | gaps, borders, animations, සහ පෙනුමේ ඉතිරි කොටස් පාලනය කරයි. |
| `~/.config/hypr/autostart.lua` | සැසිය සමඟ ආරම්භ කරන අමතර ක්‍රියාවලි පාලනය කරයි. |
| `~/.config/omarchy/shell.json` | Omarchy shell එක පාලනය කරයි: bar එකේ පිහිටීම, පිරිසැලසුම, සහ විජට්, තවද screensaver, lock, සහ idle කාල සීමා. |
| `~/.config/foot/foot.ini` | ඔබේ terminal එක පාලනය කරයි (පෙරනිමිය foot). |
| `~/.XCompose` | ඔබේ ඉක්මන්-ප්‍රවේශ emoji සහ නම/email ස්වයං-සම්පූර්ණ කිරීම නිර්වචනය කරයි. වෙනස්කම් කිරීමෙන් පසු `omarchy-restart-xcompose` ධාවනය කිරීමට වගබලා ගන්න. |

ඔබේම සැකසුම සියුම් ලෙස සකස් කිරීමට ඔබ බොහෝ වෙනස්කම් කරන්නේ නම්, මෙම සියලු dotfiles උපස්ථ කිරීම හොඳ අදහසකි. [ඒ සඳහා Stow කදිම ක්‍රමයකි](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### ඔබේම යෙදුම් සැසිය සමඟ ආරම්භ කිරීම

ඔබ ලොග් වන සෑම විටම යමක් ධාවනය වීමට ඔබට අවශ්‍ය නම් — sync daemon එකක්, chat යෙදුමක්, ඔබේම script එකක් — එය `~/.config/hypr/autostart.lua` තුළ දමන්න:

```lua
o.launch_on_start("my-service")
```

එය සැසියේ කොටසක් ලෙස විධානය ආරම්භ කරයි, එබැවින් ඔබ නැවත ලොග් අවුට් වන විට එය නිසි ලෙස පිරිසිදු කරනු ලැබේ.

### පද්ධති සිදුවීම් මත scripts ධාවනය කිරීම

Omarchy අවස්ථා කිහිපයකදී hooks ක්‍රියාත්මක කරන අතර, ඔබට ඔබේම scripts ඒවා මත එල්ලිය හැකිය. ඒවා `~/.config/omarchy/hooks/<event>.d/` තුළ, එක් එක් සිදුවීම සඳහා එක් ඩිරෙක්ටරිය බැගින් ඇති අතර, `.sample` වලින් අවසන් නොවන එහි ඇති සෑම ගොනුවක්ම සිදුවීම සිදුවන විට bash සමඟ ධාවනය වේ:

| සිදුවීම | එය ක්‍රියාත්මක වන අවස්ථාව |
| ----- | ------------ |
| `post-boot` | desktop එක ආරම්භ වූ වහාම පසුව |
| `post-update` | `omarchy update` හි අවසානයට ආසන්නයේ, packages, migrations, සහ service නැවත ආරම්භ කිරීමෙන් පසුව, mise tools යාවත්කාලීන කිරීමට පෙර |
| `pre-refresh-pacman` | `omarchy refresh pacman` මඟින් package වින්‍යාසය නැවත සමමුහුර්ත කළ පසුව, එය packages යාවත්කාලීන කිරීමට පෙර; channel මාරුවක් එම refresh පියවර තුළදීම එය ධාවනය කරයි |
| `theme-set` | theme වෙනසකින් පසුව (theme නම `$1` තුළ) |
| `font-set` | font වෙනසකින් පසුව (font නම `$1` තුළ) |
| `battery-low` | battery එක අඩු වන විට (ප්‍රතිශතය `$1` තුළ) |

`pre-refresh-pacman` hook එක යනු custom repositories හෝ `IgnorePkg` පේළි අයත් විය යුතු තැනයි, එය package transaction එකට පෙර ධාවනය වන බැවිනි. දෙකම ඔබේ user ලෙස ධාවනය වේ. `omarchy update` හි sudo අවසරය තවමත් නැවුම්ව පවතින අතරතුර `post-update` ධාවනය වන බැවින්, `sudo` භාවිත කරන hook එකක් නැවත ඔබේ මුරපදය ඉල්ලන්නේ නැත; `omarchy refresh pacman` විසින්ම sudo භාවිත කළ වහාම පසුව `pre-refresh-pacman` ධාවනය වේ.

එම සෑම ඩිරෙක්ටරියකම දැනටමත් hook එකක හැඩය පෙන්වන `.sample` ගොනුවක් ඇත — එය ක්‍රියාවට නැංවීමට නමෙන් `.sample` ඉවත් කරන්න. ඔබ වෙනත් තැනක ලියූ script එකක් ස්ථාපනය කිරීමට, `omarchy hook install post-boot ~/my-hook` භාවිත කරන්න, එය එය පිටපත් කර executable බවට පත් කරයි.

### ඔබේම මෙනු ඇතුළත් කිරීම් එක් කිරීම

Omarchy මෙනුව (`Super + Space`) `~/.config/omarchy/extensions/omarchy-menu.jsonc` සංස්කරණය කිරීමෙන් ඔබේම පේළි සමඟ විස්තීර්ණ කළ හැකිය. ඇතුළත් කිරීම් dotted id එකකින් යතුරු කර ඇති අතර, id එක මඟින් ඒවා ගස තුළ ස්ථානගත කරයි, එබැවින් `personal` මූල මෙනුවේ දිස්වන අතර `personal.notes` එහි ඇතුළත දිස්වේ:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

පවතින id එකක් නැවත භාවිත කරන්න, එවිට ඔබ නව එකක් එක් කිරීම වෙනුවට එම පේළිය අභිබවා ලියයි. ලබා ගත හැකි සියලුම ක්ෂේත්‍ර අදහස් දැක්වීම් ලෙස ලේඛනගත කරමින් ගොනුව එවනු ලැබේ.

### ඔබේම shell exports, functions, සහ aliases එක් කිරීම

Omarchy ergonomic aliases සහ ප්‍රයෝජනවත් functions රාශියක් සමඟ එවනු ලැබේ, නමුත් ඔබේම ඒවා එක් කිරීමට අවශ්‍ය වීම ඉතා සුලභය. ඔබ aliases, functions, සහ exports සියල්ලම `~/.bashrc` තුළ එක් කළ යුතුය. මෙම ගොනුව updates වලදී අභිබවා ලියනු නොලැබේ. Omarchy පෙරනිමි කිසිවක් වෙනස් කිරීමට ඔබට අවශ්‍ය නම්, ඔබට ඒවා මෙහි ආරක්ෂිතව එක් කළ හැකිය.

### desktop එක සඳහා environment variables සැකසීම

Desktop සැසි exports `~/.config/uwsm/env.d/` ට අයත් වේ. මෙම ගොනු ඔබේ desktop එක ආරම්භ වීමට පෙර ධාවනය වන බැවින්, shell දෝෂයක් ඔබට නැවත ලොගින් තිරයට එවිය හැකිය. ඒවා සංස්කරණය කරන අතරතුර ක්‍රියා කරන terminal එකක් විවෘතව තබා ගන්න. අභිබවා ලිවීමක් අක්‍රිය කිරීමට, එය `env.d` වෙතින් ඉවතට ගෙන යන්න. වෙනසක් ලොගින් වීම වළක්වන්නේ නම් [ලොගින් ප්‍රතිසාධනය](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) බලන්න.

### අභ්‍යන්තර Omarchy ගොනු වෙනස් කිරීම

බලන්න, මෙය ඔබේ පරිගණකයයි. ඔබට එය සමඟ කැමති ඕනෑම දෙයක් කළ හැකිය, නමුත් `/usr/share/omarchy` තුළ ඇති ගොනු වලට කෙළින්ම වෙනස්කම් කිරීමට එරෙහිව මම උපදෙස් දෙමි. ඒවා Omarchy pacman package එකට අයත් වන බැවින්, ඔබේ වෙනස්කම් ඊළඟ update එකේදී සරලවම අභිබවා ලියනු ලැබේ. ඒ වෙනුවට ඔබ කැමති නැති ඕනෑම පෙරනිමි අගයක් `~/.config/*` ෆෝල්ඩරය තුළ අභිබවා ලිවීම ඔබට වඩා හොඳය.

ඔබට එම ආකාරයෙන් සෑම දෙයක්ම පාහේ වෙනස් කළ හැකිය, පෙරනිමි keybindings වැනි. උදාහරණයක් ලෙස, [Obsidian](https://obsidian.md/) වෙනුවට [Joplin](https://joplinapp.org/) යෙදීමට `~/.config/hypr/bindings.lua` සංස්කරණය කරන්න (`omarchy-pkg-add joplin-bin` සමඟ ස්ථාපනය කරන්න):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` එහි ප්‍රතිස්ථාපනය එක් කිරීමට පෙර පවතින binding එක ඉවත් කරයි. එය launch helpers සහ binding options ඇතුළුව `o.bind` හා සමාන arguments ම ගනී. Binding එකක් එක් කිරීමට `o.bind` භාවිත කරන්න, නැතහොත් එය ප්‍රතිස්ථාපනය නොකර ඉවත් කිරීමට `hl.unbind` භාවිත කරන්න.

ඔබ අභ්‍යන්තර Omarchy ගොනු හැක් කිරීමට අවධාරණය කරන්නේ නම්, _Update > Channel > Dev_ හරහා dev channel එකට මාරු වන්න. එය Omarchy `~/omarchy` තුළ ඇති source code එකේ git checkout එකකට සම්බන්ධ කරන අතර, එය ඔබේ සිත සෑහෙන තුරු වෙනස් කිරීමට ඔබට නිදහස ඇත. ඔබට කරන්න කියන්න මෙහි කවුරුත් නැහැ!

### ඕනෑම වෙනස්කමක් යළි සැකසීම

ඔබ වින්‍යාස අවුල් කරගන්නේ නම්, Omarchy මෙනුවේ _Update > Config_ හරහා ඔබට ඒවා සැමවිටම පෙරනිමි වලට ප්‍රතිවර්තනය කළ හැකිය. නැතහොත් සියල්ල යළි සැකසීමට `omarchy reinstall configs` ධාවනය කිරීමෙන්.
