# GUI යෙදුම්

## Files

Files (Nautilus) යනු චිත්‍රක ගොනු කළමනාකාරකයයි. `Super + Shift + F` එය විවෘත කරයි, `Super + Shift + Alt + F` එය ඔබේ terminal එක පිහිටා ඇති directory එකෙන්ම විවෘත කරයි, එමඟින් බොහෝ clicking ඉතිරි වේ. `Ctrl + L` මඟින් ඔබට path එකක් type කළ හැකි අතර, ඕනෑම ගොනුවක් මත `Space` එබීමෙන් කිසිවක් විවෘත නොකර ඉක්මන් preview එකක් ලැබේ.

USB stick එකක් හෝ SD card එකක් plug කළ විට එය ස්වයංක්‍රීයවම mount වන බැවින්, එය sidebar එකේ සරලවම දිස් වේ. ඊට වඩා සංකීර්ණ දෙයක් සඳහා — drive එකක් format කිරීම, SMART health පරීක්ෂා කිරීම, partitions සෑදීම — app launcher එකෙන් (`Super + Space`) _Disks_ දියත් කරන්න.

Double-click කිරීම sensible defaults අනුගමනය කරයි: පින්තූර, videos, සහ music Omaview තුළත්, PDFs Document Viewer තුළත්, plain text Neovim තුළත් විවෘත වේ.

## Disktree

Drive එක පිරී, කුමක් විසින් එය කමින් සිටීදැයි ඔබට කිසිදු අදහසක් නැති විට, app launcher එකෙන් (`Super + Space`) [Disktree](https://github.com/tobi/disktree) දියත් කරන්න. එය ඔබේ home directory එකේ චිත්‍රක treemap එකක් පෙන්වයි. විශාල blocks වැඩි ඉඩක් ගනී; keyboard එකෙන් හෝ mouse එකෙන් directories තුළට යන්න, ඉවත් විය යුතු දේ mark කරන්න, සහ කිසිවක් ඉවත් කිරීමට පෙර ඔබේ selections review කරන්න. මුළු disk එකම scan කිරීමට `disktree --disk` ධාවනය කරන්න.

## Obsidian

[Obsidian](https://obsidian.md/) යනු ගබඩා කිරීම සඳහා සරල Markdown ගොනු භාවිතා කරන, නොමිලේ ලැබෙන සහ ඉතා පුළුල් කළ හැකි සටහන් ගැනීමේ application එකකි.

Obsidian පුද්ගලික, වාණිජ, සහ ලාභ නොලබන භාවිතය ඇතුළු සියලු අරමුණු සඳහා නොමිලේය.

Obsidian විසින් iOS සහ Android මත mobile apps සමඟ sync කිරීම සඳහා [වාණිජ add-on එකක්](https://obsidian.md/sync) ද ලබා දෙයි. (https://obsidian.md/pricing).

ඔබ `Super + Shift + O` සමඟ Obsidian ආරම්භ කරයි. Theme syncing භාවිතා කිරීමට, ඔබ settings යටතේ `Omarchy` theme එක select කළ යුතුය.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) යනු Omarchy හිම අතිශය සරල Markdown writing app එකයි. Vaults නැත, plugins නැත, ඇත්තේ ඔබ සහ වචන පමණි.

ඔබ `Super + Shift + W` සමඟ Omawrite ආරම්භ කරයි.

## Pinta

[Pinta](https://www.pinta-project.com/) යනු cropping, resizing, සහ වෙනත් මූලික manipulations සඳහා නියම මූලික image editing tool එකකි. Photoshop alternative එකක් නම් බලාපොරොත්තු නොවන්න. නමුත් එයට තවමත් Magic Wand එකක් සහ layers තිබේ!

ඔබ application launcher එක (`Super + Space`) හරහා Pinta ආරම්භ කරයි.

## Aether

[Aether](https://github.com/bjarneo/aether) යනු background image එකකින් වර්ණ උකහා ගෙන ඒවා සම්පූර්ණ, සුසංයෝගී theme එකක් බවට පත් කළ හැකි theming application එකකි. එය [ඔබේම theme එකක් සාදා ගැනීමට](43-making-your-own-theme.md) ඇති පහසුම ක්‍රමයයි.

ඔබ application launcher එක (`Super + Space`) හරහා Aether ආරම්භ කරයි.

## LocalSend

[LocalSend](https://localsend.org/) මඟින්, Apple's AirDrop වැනිව, එම app එක ධාවනය වන එකම network එකේ ඇති වෙනත් devices වෙත ගොනු යැවීමට ඔබට ඉඩ දෙයි. නමුත් එය cross-platform බැවින්, ඔබට Windows, macOS, Android, iOS, සහ ඇත්තෙන්ම Linux වෙත සහ ඉන් පිටතට ගොනු යැවිය හැකිය.

ඔබට `Super + Ctrl + S` මත හෝ Omarchy menu එකේ _Trigger > Share_ යටතේ Share menu එක විවෘත කළ හැකිය. එය ඔබට විකල්ප හතරක් දෙයි:

- **Clipboard** ඔබ copy කළ ඕනෑම දෙයක් text file එකක් ලෙස යවයි. ඔබටම email නොකර link එකක් හෝ snippet එකක් ඔබේ phone එකට ගැනීමට නියමයි.
- **File** එකවර කිහිපයක් select කළ හැකි file picker එකක් විවෘත කරයි.
- **Folder** සම්පූර්ණ directory එකක් යවයි.
- **Receive** වෙනත් device එකකට ඔබට යමක් යැවිය හැකි වන පරිදි LocalSend ම විවෘත කරයි.

එම දෙයම terminal එකෙන් `omarchy share clipboard`, `omarchy share file [path]`, සහ `omarchy share folder [path]` සමඟ ක්‍රියා කරයි. Path එක අත්හැරියහොත් ඔබට picker එක ලැබේ.

ඔබට file manager එකෙන් කෙලින්ම ද යැවිය හැකිය: Nautilus හි ඕනෑම selection එකක් right-click කර _Send via LocalSend_ තෝරන්න.

Omarchy හි firewall එක LocalSend හි port එක හැර default ලෙස වසා ඇති බැවින්, මෙය fresh install එකක කිසිදු සැකසුමකින් තොරවම ක්‍රියා කරයි. [ආරක්ෂාව](48-security.md) බලන්න.

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) යනු word processor, spreadsheet, presentations, drawing application, සහ තවත් බොහෝ දේ සහිත සම්පූර්ණ office package එකකි. එය Microsoft Office වෙතින් ලැබෙන ගොනු සමඟ compatible බැවින්, එම Word documents විවෘත කිරීමට හැකි වීමට මෙය නියම ක්‍රමයකි.

ඔබ application launcher එක (`Super + Space`) හරහා LibreOffice ආරම්භ කරයි.

## Hype

[Hype](https://github.com/omacom/hype) යනු Omarchy හිම අතිශය සරල presentation app එකයි. ඔබේ deck එක එහි images සහ videos ඊට යාබදව ඇති තනි Markdown file එකකි: live preview එකක් යටින් එක් එක් slide එක ලියන්න, slides පිළිවෙළට drag කරන්න, ඉන්පසු fullscreen present කරන්න හෝ PDF සහ PowerPoint වෙත export කරන්න. එය ඔබේ Omarchy theme එක පවා ලබා ගනී.

ඔබ application launcher එක (`Super + Space`) හරහා Hype ආරම්භ කරයි. සියලු shortcuts බැලීමට එහි ඇතුළත `?` ඔබන්න.

## Signed

[Signed](https://github.com/omacom/signed) යනු PDFs අත්සන් කිරීමට සහ ඒවා පිරවීමට Omarchy හිම අතිශය සරල ක්‍රමයයි. ඔබ save කළ signature එක, text එක, සහ අද දිනය page එකේ ඕනෑම තැනක තබන්න, ඉන්පසු original එක අසල signed copy එකක් save කරන්න. ආකාරය සඳහා [PDFs පුරවීම](27-filling-out-pdfs.md) බලන්න.

ඔබ application launcher එක (`Super + Space`) හරහා Signed ආරම්භ කරයි, නැතහොත් file manager එකෙන් PDF එකක් එය සමඟ විවෘත කරයි.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) යනු floating window එකක විවෘත වන Omarchy හිම අතිශය සරල calculator එකයි.

ඔබ `Super + Shift + Q` සමඟ (හෝ ඔබේ keyboard එකේ එකක් තිබේ නම් calculator key එක සමඟ) Omacalc ආරම්භ කරයි.

## Signal

[Signal](https://signal.org/) යනු E2E encrypted messaging හි පුරෝගාමියා වන අතර, විශාල tech conglomerates එකක් හරහා යාමට අකමැති ඕනෑම අයෙකුට නියම communication option එකකි.

ඔබ `Super + Shift + G` සමඟ Signal ආරම්භ කරයි. එය base install එකේ කොටසක් නොවන බැවින්, ඔබ පළමු වරට එය එබූ විට, Omarchy එය ඔබ වෙනුවෙන් install කිරීමට ඉදිරිපත් වනු ඇත (එය Omarchy menu එකේ _Install > Service_ යටතේ ද ඇත).

## Omaview

[Omaview](https://github.com/omacom/omaview) යනු Omarchy හිම අතිශය සරල picture viewer සහ media player එකයි: ඔබේ photos, videos, සහ music සඳහා එක window එකකි. Photo එකක් විවෘත කළ විට arrow keys මඟින් එහි folder එකේ ඉතිරි ඒවා අතරින් යා හැකි අතර, `N` සහ `P` ඕනෑම දෙයක් සඳහා එය කරයි, සහ `Ctrl + M` මුළු folder එකම grid එකක් ලෙස පෙන්වයි. එය HEIC, AVIF, සහ JPEG XL photos ද පෙන්වන අතර, දිගු ඕනෑම දෙයක ඔබ නැවැත්වූ තැනින් නැවත ආරම්භ කරයි.

Fullscreen සඳහා `F` ඔබන්න, picture එකක් Omasnap හි edit කිරීමට හෝ video එකක් Omacut හි trim කිරීමට `E` ඔබන්න, picture එකක් print කිරීමට `Ctrl + P` ඔබන්න, සහ file එකක් Trash එකට ගෙන යාමට `Delete` ඔබන්න (`Ctrl + Z` එය ආපසු ගෙන එයි). සියලු shortcuts බැලීමට එහි ඇතුළත `?` ඔබන්න.

ඔබ application launcher එක (`Super + Space`) හරහා _Media Viewer_ ලෙස Omaview ආරම්භ කරයි, නැතහොත් file manager එකේ picture එකක්, video එකක්, හෝ song එකක් double-click කරන්න.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) යනු Omarchy හිම අතිශය සරල video trimmer එකයි. ඔබට අවශ්‍ය වන්නේ clip එකක ආරම්භය සහ අවසානය කපා හැරීම පමණක් නම්, සම්පූර්ණ video editor එකක් දියත් කිරීමට වඩා මෙය හොඳය.

ඔබ application launcher එක (`Super + Space`) හරහා Omacut ආරම්භ කරයි.

## Monologue

[Monologue](https://github.com/omacom/monologue) යනු Omarchy හිම අතිශය සරල webcam recorder එකයි. ඔබේ camera එක සහ microphone එක එක් වරක් තෝරන්න, ඉන්පසු record කිරීමට `Space` ඔබන්න, සහ එම take එකම pause කර නැවත ආරම්භ කිරීමට නැවත ඔබන්න. එය සැමවිටම ඔබේ camera එකේ ඉහළම resolution එකෙන් record කරන අතර, ඔබ ආරම්භ කිරීමට පෙර ඔබේ levels පරීක්ෂා කළ හැකි වන පරිදි live microphone meter එකක් ඇත.

Take එක නැවැත්වූ විට එය built-in editor එකක වහාම විවෘත වේ. Clip එකක් split කිරීමට එය double-click කරන්න, එක් එක් කොටස trim කිරීමට handles drag කරන්න, සහ ඔබට අවශ්‍ය නැති කොටස් ඉවත් කරන්න. ඉන්පසු එය MP4 එකක් ලෙස save කරන්න. ඔබ එය අත්හරින තුරු ඔබේ original recording එක රඳවා ගනු ලබන බැවින්, ඔබට සැමවිටම ආපසු පැමිණ එය වෙනස් ලෙස කපා ගත හැකිය.

ඔබ application launcher එක (`Super + Space`) හරහා Monologue ආරම්භ කරයි.
