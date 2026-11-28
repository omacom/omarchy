# ඔබේම තේමාවක් සාදා ගැනීම

ඔබට ඔබේම තේමා `~/.config/omarchy/themes` වෙත එක් කළ හැකිය. පවතින තේමාවලින් එකක් පදනමක් ලෙස පිටපත් කරන්න (`/usr/share/omarchy/themes` තුළ බලන්න), ඉන්පසු ඔබ කැමති පරිදි එය වෙනස් කරන්න. ඔබේ තේමාව එම ෆෝල්ඩරය තුළ තිබෙන තාක්, එය තේමා තේරීමේ මෙනුවට ඇතුළත් වනු ඇත.

ඔබ වෙනස් කළ යුතු ප්‍රධාන ගොනුව `colors.toml` ය. එය terminal එක (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt apps, keyboard backlight එක, input method එක, screen-share picker එක, app icons, AI tools කිහිපයක් (Claude, Pi, Hermes, T3 Code, Herdr) සහ සම්පූර්ණ Omarchy shell එක (top bar එක, menu එක, notifications, OSD එක සහ lock screen එක) සඳහා වින්‍යාසයන් ජනනය කිරීමට පසුව භාවිත කරන වර්ණ කට්ටලය නිර්වචනය කරයි.

නව තේමාවක් නිර්මාණය කිරීමට වර්ණ සමඟ සෙල්ලම් කිරීමට සහ backgrounds සෙවීමට ඇති අලංකාර GUI අතුරුමුහුණතක් භාවිත කිරීමට, ඇතුළත් කර ඇති Aether application එකද ඔබට භාවිත කළ හැකිය. `Super + Alt + Space` මත app grid එකෙන් එය ආරම්භ කරන්න.

### ස්ථාපිත තේමාවක අඩංගු විය හැකි දේ

ඔබ විසින්ම `~/.config/omarchy/themes` තුළ ලියන තේමාවක ඔබ කැමති ඕනෑම දෙයක් අඩංගු විය හැකිය — එය ඔබේ යන්ත්‍රය සහ ඔබේ ගොනුව වන අතර, Omarchy ඒ සියල්ලම යොදයි.

`omarchy theme install` සමඟ වෙනත් අයෙකුගේ repo එකකින් ඔබ ස්ථාපනය කරන තේමාවක් වර්ණය වන සියල්ල රඳවා ගන්නා අතර, ඔබේ යන්ත්‍රයේ code ධාවනය කරන ගොනු අතලොස්ස අහිමි කරයි: ඕනෑම `.lua` ගොනුවක්, terminal configs (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) සහ `vscode.json`. තේමාවක `hyprland.lua` යනු පිවිසීමේදී ඔබේ compositor එක ධාවනය කරන Lua ය, terminal config එකක් ඔබේ terminal එක ආරම්භ කරන program එක නම් කරයි, සහ `vscode.json` ස්ථාපනය කිරීමට VSCode extension එකක් නම් කරයි. වෙනත් අයෙකුගේ තේමාවක් ස්ථාපනය කිරීම ඔබේ desktop එක පෙනෙන ආකාරය වෙනස් කළ යුතුය, එය ධාවනය කරන දේ කිසිවිටෙක නොවේ.

ඉතිරි සියල්ල තේමා කතුවරයා ලියූ ආකාරයටම හරියටම ක්‍රියා කරයි — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, backgrounds සහ previews සියල්ලම රඳවා ගනු ලැබේ. අතහැර දැමූ දේ පමණක් ඔබේ යන්ත්‍රයේ `colors.toml` වලින් නැවත ජනනය කරනු ලැබේ.

තේමාවකට එය තුළම තමන්ගේම git repo එකක් තිබේද යන්නෙන් Omarchy මේ දෙක වෙන්කර හඳුනා ගනී, එය `omarchy theme install` clone කරන විට ඉතිරි කරන දෙයයි. එබැවින් ඔබ ලියූ තේමාවක් ඔබේම ලෙස පවතින අතර, ඔබ අන්තර්ජාලයෙන් ලබා ගත් එකක් වර්ණ ලෙස පවතී.

### Light mode

ඔබ light mode තේමාවක් සාදන්නේ නම්, ඔබේ `colors.toml` හි ඉහළින්ම `mode = "light"` සකසන්න. එවිට එය සියලුම apps සඳහා ස්වයංක්‍රීයව light mode සමඟ යුගලනය වනු ඇත. (ඔබේ තේමාවේ මූලයේ `light.mode` නම් හිස් ගොනුවක් දැමීමේ පැරණි ක්‍රමයද තවමත් ක්‍රියා කරයි.)

### Boot සහ login තිර

Boot කිරීමේදී drive password එක ඉල්ලන තිරය සහ login තිරය, ඔබේ තේමාවේ `background` එක මත එහි `accent` වර්ණයෙන් Omarchy logo එක අඳින අතර, password field එක එහි `foreground` වලින් සහ වැරදි password එකක් සඳහා `red` වලින් දක්වයි. ඒවා සඳහා නැව්ගත කිරීමට අමතර කිසිවක් නැත: Omarchy තවදුරටත් තේමාවක `unlock.png` හෝ `preview-unlock.png` භාවිත නොකරයි. Apple Silicon Macs වල, තේමාව කුමක් වුවත් drive password තිරය Omarchy හි පෙරනිමි පෙනුම රඳවා ගනී.

### Omarchy ආවරණය නොකරන apps තේමා කිරීම

එම ලැයිස්තුවේ නැති app එකක් ඔබ භාවිත කරන්නේ නම්, template එකක් සමඟ එය තේමා කරන ආකාරය ඔබටම Omarchy වෙත උගන්වන්න පුළුවන්. එය ජනනය කරන config එක අනුව නම් කර `.tpl` දිගුවක් එක් කළ ගොනුවක් `~/.config/omarchy/themed/` තුළ දමන්න, සහ `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` සිට `{{ color15 }}` දක්වා සහ ඉතිරි palette එක placeholders ලෙස භාවිත කරමින් config එක ලියන්න. ඔබ තේමා මාරු කරන සෑම අවස්ථාවකම, එම තේමාවේ වර්ණ සමඟ ගොනුව නැවත ජනනය කරනු ලැබේ.

එම ෆෝල්ඩරයේ ඔබට පිටපත් කර ගත හැකි සම්පූර්ණයෙන්ම අදහස් දක්වා ඇති `alacritty.toml.tpl.sample` එකක් ඇත — එය ඔබට භාවිත කළ හැකි සෑම variable එකක්ම ලැයිස්තුගත කරන අතර, `#` නොමැතිව හෝ දශම RGB ලෙස වර්ණ අවශ්‍ය apps සඳහා `_strip` සහ `_rgb` modifiers ද ඇතුළත් කරයි. ඔබේ templates Omarchy හි ඒවාට වඩා ප්‍රමුඛතාව ගන්නා බැවින්, built-in app එකක් තේමා කරන ආකාරය override කිරීමටද ඔබට මෙය භාවිත කළ හැකිය.

### ඔබේ තේමාව බෙදා හැරීම

ඔබේ තේමාව අන් අයට භාවිත කළ හැකි පරිදි බෙදා හැරීමට ඔබට අවශ්‍ය නම්, ඔබ එය GitHub වැනි පොදු git server එකක තැබිය යුතුය. එවිට එම URL එක භාවිත කර Omarchy menu එකේ _Install > Style > Theme_ භාවිතයෙන් මිනිසුන්ට එය ස්ථාපනය කළ හැකිය. ඔබ `omarchy-[themename]-theme` යන නම් කිරීමේ සම්මුතිය අනුගමනය කිරීම නිර්දේශ කෙරේ, මන්ද ස්ථාපනයෙන් පසු තේමා තේරීමේ මෙනුවේ තේමාව හුදෙක් `[themename]` ලෙස නිවැරදිව පෙන්වනු ඇත.

ඉතිරි වන එම `[themename]` එක තේමාවේ directory නාමය බවට පත්වේ, එබැවින් එය Omarchy හට ආරක්ෂිතව එහා මෙහා යැවිය හැකි එකක් විය යුතුය: එය අකුරකින්, ඉලක්කමකින් හෝ underscore එකකින් ආරම්භ විය යුතු අතර, ඉතිරියේ අකුරු, ඉලක්කම්, `.`, `_`, `+` සහ `-` පැවතිය හැකිය. ලොකු අකුරු ඔබට කුඩා අකුරු බවට පත් කරනු ලැබේ, නමුත් වෙනත් ඕනෑම දෙයක් — හිඩැසක්, උද්ධරණ ලකුණක්, ඉංග්‍රීසි නොවන අක්ෂරයක් — directory නාමයක් බවට පත් කරනවා වෙනුවට ස්ථාපන අවස්ථාවේදීම ප්‍රතික්ෂේප කරනු ලැබේ. එබැවින් `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` සහ `omarchy-c++-theme` යන සියල්ලම හොඳින් ස්ථාපනය වේ.

එය repo එකකින් ස්ථාපනය කළ පසු, එය නැව්ගත කරන ඕනෑම `.lua`, terminal config එකක් හෝ `vscode.json` අතහැර දමන බව මතක තබා ගන්න, එබැවින් එම දේවල් වටා තේමාව ගොඩනඟන්න එපා.

[omarchy-site repo](https://github.com/omacom-io/omarchy-site) එකට pull request එකක් යැවීමෙන් ඔබට ඔබේ තේමාව [අමතර තේමා පිටුවට](https://omarchy.org/themes/) එක් කර ගත හැකිය.
