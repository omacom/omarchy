# GUIs

## Files

Files (Folio) යනු චිත්‍රකමය ගොනු කළමනාකරුවයි. `Super + Shift + F` එය විවෘත කරයි, සහ `Super + Shift + Alt + F` එය ඔබේ terminal එක සිටින directory එක තුළ විවෘත කරයි, එමගින් බොහෝ clicking ඉතිරි වේ. `Ctrl + L` මඟින් ඔබට path එකක් type කිරීමට ඉඩ දෙයි, සහ ඕනෑම ගොනුවක් මත `Space` එබීමෙන් එය විවෘත නොකර සම්පූර්ණ ප්‍රමාණයෙන් preview කළ හැක.

USB stick එකක් හෝ SD card එකක් plug කළ විට එය ස්වයංක්‍රීයව mount වේ, එබැවින් එය sidebar එකේ සරලවම දිස් වේ. ඊට වඩා සංකීර්ණ දේවල් සඳහා — drive එකක් format කිරීම, SMART health පරීක්ෂා කිරීම, partitions සෑදීම — app launcher එකෙන් (`Super + Space`) _Disks_ launch කරන්න.

ඇතැම් encrypted drive එකක් plug කළ විට එහි password එක ඉල්ලයි. එකක් තනිවම unlock වීමට, `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` සමඟ එයට keyfile එකක් එක් කර, එම keyfile එක `~/.config/omarchy/drive-keys/<UUID>` හි තබන්න, encrypted partition එක සඳහා `lsblk -dno UUID /dev/sdX1` මුද්‍රණය කරන UUID එකෙන් එය නම් කර, ඔබෙන් පමණක් කියවිය හැකි පරිදි (`chmod 600`) තබන්න. එම keyfile එක අතුරුදහන් නම් හෝ ප්‍රතික්ෂේප වුවහොත්, සාමාන්‍ය පරිදි ඔබෙන් password එක ඉල්ලනු ලැබේ.

Double-click කිරීම sensible defaults අනුගමනය කරයි: pictures, videos සහ music Omaview හි විවෘත වේ, PDFs Document Viewer හි විවෘත වේ, Markdown Omawrite හි විවෘත වේ, සහ plain text ඔබේ editor එකේ විවෘත වේ, ඔබ _Setup > Defaults > Editor_ යටතේ වෙනත් එකක් තෝරන්නේ නැත්නම් Plain හි විවෘත වේ.

## Disktree

drive එක පිරී යන විට සහ එය අනුභව කරන්නේ කුමක්දැයි ඔබට කිසිම අදහසක් නැති විට, app launcher එකෙන් (`Super + Space`) [Disktree](https://github.com/tobi/disktree) launch කරන්න. එය ඔබේ home directory එකේ චිත්‍රකමය treemap එකක් පෙන්වයි. විශාල blocks වැඩි ඉඩක් ගනී; keyboard එකෙන් හෝ mouse එකෙන් directories තුළට යන්න, ඉවත් කළ යුතු දේ mark කරන්න, සහ කිසිවක් ඉවත් කිරීමට පෙර ඔබේ selections review කරන්න. මුළු disk එකම scan කිරීමට `disktree --disk` run කරන්න.

## Obsidian

[Obsidian](https://obsidian.md/) යනු storage සඳහා සරල Markdown ගොනු භාවිතා කරන, නොමිලේ ලැබෙන සහ ඉතා පුළුල් කළ හැකි note taking application එකකි.

Obsidian සියලු අරමුණු සඳහා නොමිලේය, personal, commercial සහ non-profit භාවිතය ද ඇතුළුව.

Obsidian විසින් iOS සහ Android හි mobile apps සමඟ [syncing සඳහා commercial add-on එකක්](https://obsidian.md/sync) ද ලබා දෙයි. (https://obsidian.md/pricing).

ඔබ Obsidian ආරම්භ කරන්නේ `Super + Shift + O` සමඟිනි. theme syncing භාවිතා කිරීමට, ඔබට settings යටතේ `Omarchy` theme එක තෝරා ගත යුතුය.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) යනු Omarchy හිම ඉතා සරල Markdown writing app එකයි. vaults නැත, plugins නැත, ඔබ සහ වචන පමණි.

ඔබ Omawrite ආරම්භ කරන්නේ `Super + Shift + W` සමඟිනි.

## Pinta

[Pinta](https://www.pinta-project.com/) යනු cropping, resizing සහ අනෙකුත් මූලික manipulations සඳහා විශිෂ්ට මූලික image editing tool එකකි. Photoshop alternative එකක් නම් බලාපොරොත්තු නොවන්න. නමුත් එහි තවමත් Magic Wand එකක් සහ layers තිබේ!

ඔබ Pinta ආරම්භ කරන්නේ application launcher එක හරහාය (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) යනු background image එකකින් colors extract කර ඒවා සම්පූර්ණ, සංගත theme එකක් බවට පත් කළ හැකි theming application එකකි. එය [ඔබේම theme එකක් සෑදීමට](43-making-your-own-theme.md) ඇති පහසුම ක්‍රමයයි.

ඔබ Aether ආරම්භ කරන්නේ application launcher එක හරහාය (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) මඟින් ඔබට app එක run වන එකම network එකේ ඇති අනෙකුත් devices වෙත ගොනු යැවීමට ඉඩ දෙයි, Apple හි AirDrop වැනිය. කෙසේ වෙතත්, එය cross-platform ය, එබැවින් ඔබට Windows, macOS, Android, iOS, සහ ඇත්ත වශයෙන්ම Linux වෙත සහ ඒවායින් ගොනු යැවිය හැක.

ඔබට Share menu එක `Super + Ctrl + S` මත හෝ Omarchy menu එකේ _Trigger > Share_ යටතේ විවෘත කළ හැක. එය ඔබට options හතරක් දෙයි:

- **Clipboard** ඔබ copy කළ ඕනෑම දෙයක් text file එකක් ලෙස යවයි. ඔබටම email නොකර link එකක් හෝ snippet එකක් ඔබේ phone එකට ලබා ගැනීමට විශිෂ්ටයි.
- **File** file picker එකක් විවෘත කරයි, එහිදී ඔබට එකවර කිහිපයක් select කළ හැක.
- **Folder** සම්පූර්ණ directory එකක් යවයි.
- **Receive** LocalSend නිසි පරිදි විවෘත කරයි, එවිට තවත් device එකකට ඔබට යමක් යැවිය හැක.

එම දෙයම terminal එකෙන් `omarchy share clipboard`, `omarchy share file [path]`, සහ `omarchy share folder [path]` සමඟ ක්‍රියා කරයි. path එක අත්හරින්න, ඔබට picker එක ලැබේ.

ඔබට file manager එකෙන් සෘජුවම යැවිය හැක: Files හි ඕනෑම selection එකක් මත right-click කර LocalSend සමඟ එය share කරන්න.

Omarchy හි firewall එක LocalSend හි port එක හැර default වශයෙන් වසා ඇත, එබැවින් මෙය fresh install එකක කිසිම සැකසුමක් නැතිව ක්‍රියා කරයි. [ආරක්ෂාව](48-security.md) බලන්න.

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) යනු word processor, spreadsheet, presentations, drawing application සහ තවත් දේ සහිත සම්පූර්ණ office package එකකි. එය Microsoft Office හි ගොනු සමඟ compatible ය, එබැවින් එම Word documents විවෘත කිරීමට හැකි වීමට මෙය විශිෂ්ට ක්‍රමයකි.

ඔබ LibreOffice ආරම්භ කරන්නේ application launcher එක හරහාය (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) යනු Omarchy හිම ඉතා සරල presentation app එකයි. ඔබේ deck එක යනු එහි images සහ videos එය අසල ඇති තනි Markdown file එකකි: live preview එකක් යටින් එක් එක් slide එක ලියන්න, slides පිළිවෙළට drag කරන්න, ඉන්පසු fullscreen present කරන්න හෝ PDF සහ PowerPoint වෙත export කරන්න. එය ඔබේ Omarchy theme එක පවා ලබා ගනී.

ඔබ Hype ආරම්භ කරන්නේ application launcher එක හරහාය (`Super + Space`). සෑම shortcut එකක්ම බැලීමට එහි ඇතුළත `?` ඔබන්න.

## Signed

[Signed](https://github.com/omacom/signed) යනු PDFs අත්සන් කිරීමට සහ ඒවා පිරවීමට Omarchy හිම ඉතා සරල ක්‍රමයයි. ඔබ සුරකින ලද signature එක, text එක සහ අද දිනය පිටුවක ඕනෑම තැනක තබන්න, ඉන්පසු original එක අසල signed copy එකක් save කරන්න. කෙසේ දැයි සඳහා [PDFs පුරවා ගැනීම](27-filling-out-pdfs.md) බලන්න.

ඔබ Signed ආරම්භ කරන්නේ application launcher එක හරහාය (`Super + Space`), නැතහොත් file manager එකෙන් එය සමඟ PDF එකක් විවෘත කරන්න.

## Game Vibes

application launcher එකේ (`Super + Space`) ඇති Game Vibes යනු Omarchy හි කුඩා games වාසය කරන ස්ථානයයි: Checkmate, මිතුරෙකුට හෝ built-in opponent කෙනෙකුට එරෙහිව 3D chess game එකක්; Cards, Klondike solitaire; Death Wish, spikes සහ saws පිරුණු කාමර දහයක pixel-precise platformer එකක්; සහ Neon Swarm, arcade shooter එකක්. සෑම එකක්ම ඔබේ theme එක අනුගමනය කරන තනි web page එකකි. arrows සහ `Enter` සමඟ එකක් තෝරන්න, සහ game එකක title screen එකෙන් `Esc` සමඟ හෝ එය paused අතරතුර `Q` සමඟ list එකට නැවත එන්න. එය full screen විවෘත වේ: `Super + F` එය window එකක් බවට පත් කරයි, සහ `Super + W` එය වසයි.

ඔබ agent කෙනෙකු සමඟ සාදන games ද මෙහි දිස් වේ: agents panel එකේ _Make something cool → Game_ තෝරා එකක් විස්තර කරන්න, නැතහොත් දැනට වැඩ කරමින් සිටීමට Game Vibes හි දැනටමත් ඇති game එකක් නම් කරන්න. agent එය `~/Games/vibes` වෙත copy කරයි, එහිදී එය වෙනස් කිරීමට ඔබගේ වේ, සහ එය අවසන් වූ විට එය විවෘත කරයි. ඔබට එම copy එක `omarchy games vibes copy <game>` සමඟ ඔබම සාදා ගත හැක. වෙනත් කෙනෙකු share කරන game එකක් theme එකක් මෙන් install වේ: _Install > Gaming > Game Vibes_ තෝරා එහි git address එක paste කරන්න, නැතහොත් `omarchy games vibes install <git-repo-url>` run කරන්න. _Remove > Gaming_ එකක් නැවත ඉවත් කරයි, සහ _Update > Game Vibes Games_ නව versions ලබා ගනී. Games three.js web එකෙන් load කරයි, එබැවින් ඒවා ආරම්භ වීමට connection එකක් අවශ්‍ය වේ.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) යනු floating window එකක විවෘත වන Omarchy හිම ඉතා සරල calculator එකයි.

ඔබ Omacalc ආරම්භ කරන්නේ `Super + Shift + Q` සමඟිනි (නැතහොත් ඔබේ keyboard එකේ එකක් ඇත්නම් calculator key එක සමඟිනි).

## Signal

[Signal](https://signal.org/) යනු E2E encrypted messaging හි පුරෝගාමියා වන අතර, විශාල tech conglomerates එකක් හරහා යාමට කැමති නැති ඕනෑම කෙනෙකුට විශිෂ්ට communication option එකකි.

ඔබ Signal ආරම්භ කරන්නේ `Super + Shift + G` සමඟිනි. එය base install එකේ කොටසක් නොවේ, එබැවින් ඔබ පළමු වරට එය එබූ විට, Omarchy එය ඔබට install කිරීමට ඉදිරිපත් වේ (එය Omarchy menu එකේ _Install > Service_ යටතේ ද ඇත).

## Omaview

[Omaview](https://github.com/omacom/omaview) යනු Omarchy හිම ඉතා සරල picture viewer සහ media player එකයි: ඔබේ photos, videos සහ music සඳහා එක් window එකක්. photo එකක් විවෘත කරන්න, arrow keys එහි folder එකේ ඉතිරි කොටස හරහා ගමන් කරයි, `N` සහ `P` ඕනෑම දෙයක් සඳහා එය කරයි, සහ `Ctrl + M` මුළු folder එකම grid එකක් ලෙස පෙන්වයි. එය HEIC, AVIF සහ JPEG XL photos ද පෙන්වයි, සහ දිග ඕනෑම දෙයක ඔබ නතර කළ තැනින් නැවත ආරම්භ කරයි.

fullscreen සඳහා `F` ඔබන්න, Omasnap හි picture එකක් edit කිරීමට හෝ Omacut හි video එකක් trim කිරීමට `E` ඔබන්න, picture එකක් print කිරීමට `Ctrl + P` ඔබන්න, සහ ගොනුවක් Trash වෙත ගෙන යාමට `Delete` ඔබන්න (`Ctrl + Z` එය ආපසු ගෙන එයි). සෑම shortcut එකක්ම බැලීමට එහි ඇතුළත `?` ඔබන්න.

ඔබ Omaview application launcher එක හරහා _Media Viewer_ ලෙස ආරම්භ කරයි (`Super + Space`), නැතහොත් file manager එකේ picture එකක්, video එකක් හෝ song එකක් මත double-click කරන්න.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) යනු Omarchy හිම ඉතා සරල video trimmer එකයි. ඔබට අවශ්‍ය වන්නේ clip එකක ආරම්භය සහ අවසානය කපා දැමීම පමණක් නම්, එය සම්පූර්ණ video editor එකක් දියත් කිරීමට වඩා හොඳය.

ඔබ Omacut ආරම්භ කරන්නේ application launcher එක හරහාය (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) යනු Omarchy හිම ඉතා සරල webcam recorder එකයි. ඔබේ camera එක සහ microphone එක එක් වරක් තෝරන්න, ඉන්පසු record කිරීමට `Space` ඔබන්න, සහ එම take එකම pause කිරීමට සහ resume කිරීමට නැවත ඔබන්න. එය සැමවිටම ඔබේ camera එකේ ඉහළම resolution එකෙන් record කරයි, ඔබ ආරම්භ කිරීමට පෙර ඔබේ levels පරීක්ෂා කළ හැකි වන පරිදි live microphone meter එකක් සමඟිනි.

take එක නවත්වන්න, එය built-in editor එකක වහාම විවෘත වේ. clip එකක් split කිරීමට එය මත double-click කරන්න, එක් එක් piece එක trim කිරීමට handles drag කරන්න, සහ ඔබට අවශ්‍ය නැති කොටස් ඉවත් කරන්න. ඉන්පසු එය MP4 එකක් ලෙස save කරන්න. ඔබ එය discard කරන තෙක් ඔබේ original recording එක තබා ගනී, එබැවින් ඔබට සැමවිටම ආපසු පැමිණ එය වෙනස් ලෙස cut කළ හැක.

ඔබ Monologue ආරම්භ කරන්නේ application launcher එක හරහාය (`Super + Space`).
