# GUIs

## Files

Files (Nautilus) යනු චිත්‍රක ගොනු කළමනාකරුවයි. `Super + Shift + F` එය විවෘත කරයි, `Super + Shift + Alt + F` ඔබේ terminal එක දැනට සිටින directory එක තුළම එය විවෘත කරයි, එමඟින් ක්ලික් කිරීම් ගොඩක් ඉතිරි වේ. `Ctrl + L` මඟින් ඔබට path එකක් ටයිප් කළ හැකිය, ඕනෑම ගොනුවක් මත `Space` එබීමෙන් කිසිවක් විවෘත නොකර ඔබටම ඉක්මන් පෙරදසුනක් ලැබේ.

USB stick එකක් හෝ SD card එකක් ගැසූ සැණින් එය ස්වයංක්‍රීයවම mount වේ, එබැවින් එය sidebar එකේ නිකන්ම පෙනේ. ඊට වඩා සංකීර්ණ දෙයකට — drive එකක් format කිරීම, SMART health එක පරීක්ෂා කිරීම, partitions සෑදීම — app launcher එකෙන් (`Super + Space`) _Disks_ දියත් කරන්න.

ද්වි-ක්ලික් කිරීම sensible defaults අනුගමනය කරයි: පින්තූර, වීඩියෝ සහ සංගීතය Omaview තුළද, PDFs Document Viewer තුළද, Markdown Omawrite තුළද, plain text _Setup > Default > Editor_ යටතේ තෝරාගත් editor එක තුළද විවෘත වේ.

## Disktree

Drive එක පිරී, එය කා දමන්නේ කුමක්දැයි ඔබට කිසිම අදහසක් නැති විට, app launcher එකෙන් (`Super + Space`) [Disktree](https://github.com/tobi/disktree) දියත් කරන්න. එය ඔබේ home directory එකේ චිත්‍රක treemap එකක් පෙන්වයි. විශාල blocks වැඩි ඉඩක් ගනී; keyboard එකෙන් හෝ mouse එකෙන් directories තුළට යන්න, ඉවත් කළ යුතු දේ mark කරන්න, කිසිවක් ඉවත් කිරීමට පෙර ඔබේ තේරීම් සමාලෝචනය කරන්න. මුළු disk එකම scan කිරීමට `disktree --disk` ධාවනය කරන්න.

## Obsidian

[Obsidian](https://obsidian.md/) යනු ගබඩා කිරීම සඳහා සරල Markdown ගොනු භාවිත කරන, නොමිලේ ලැබෙන සහ ඉතා පුළුල් කළ හැකි සටහන් ගැනීමේ application එකකි.

Obsidian පුද්ගලික, වාණිජ සහ ලාභ නොලබන භාවිතය ඇතුළුව සියලු අරමුණු සඳහා නොමිලේය.

Obsidian iOS සහ Android මත mobile apps සමඟ [සමමුහුර්ත කිරීම සඳහා වාණිජ add-on එකක්ද](https://obsidian.md/sync) ලබා දෙයි. (https://obsidian.md/pricing).

ඔබ Obsidian ආරම්භ කරන්නේ `Super + Shift + O` මගිනි. Theme syncing භාවිත කිරීමට, ඔබ settings යටතේ `Omarchy` theme එක තෝරාගත යුතුය.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) යනු Omarchy හිම අතිශයින් සරල Markdown ලිවීමේ app එකයි. Vaults නැත, plugins නැත, ඇත්තේ ඔබ සහ වචන පමණි.

ඔබ Omawrite ආරම්භ කරන්නේ `Super + Shift + W` මගිනි.

## Pinta

[Pinta](https://www.pinta-project.com/) යනු cropping, resizing සහ අනෙකුත් මූලික හැසිරවීම් සඳහා විශිෂ්ට මූලික රූප සංස්කරණ මෙවලමකි. Photoshop විකල්පයක් බලාපොරොත්තු නොවන්න. නමුත් එහි තවමත් Magic Wand එකක් සහ layers තිබේ!

ඔබ Pinta ආරම්භ කරන්නේ application launcher එක හරහාය (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) යනු background image එකකින් වර්ණ උකහා ගෙන ඒවා සම්පූර්ණ, සංගත theme එකක් බවට පත් කළ හැකි theming application එකකි. එය [ඔබේම තේමාව සාදා ගැනීමට](43-making-your-own-theme.md) ඇති පහසුම ක්‍රමයයි.

ඔබ Aether ආරම්භ කරන්නේ application launcher එක හරහාය (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) මඟින් ඔබට Apple's AirDrop එක මෙන්, එම app එකම ධාවනය වන එකම network එකේ ඇති වෙනත් devices වෙත ගොනු යැවිය හැකිය. කෙසේ වෙතත් එය cross-platform ය, එබැවින් ඔබට Windows, macOS, Android, iOS සහ ඇත්තෙන්ම Linux වෙත සහ ඉන් පිටතට ගොනු යැවිය හැකිය.

ඔබට Share menu එක `Super + Ctrl + S` මත හෝ Omarchy menu එකේ _Trigger > Share_ යටතේ විවෘත කළ හැකිය. එය ඔබට විකල්ප හතරක් දෙයි:

- **Clipboard** ඔබ පිටපත් කළ ඕනෑම දෙයක් text file එකක් ලෙස යවයි. ඔබටම email නොකර link එකක් හෝ snippet එකක් ඔබේ phone එකට ලබා ගැනීමට විශිෂ්ටයි.
- **File** ඔබට එකවර කිහිපයක් තෝරාගත හැකි file picker එකක් විවෘත කරයි.
- **Folder** සම්පූර්ණ directory එකක්ම යවයි.
- **Receive** LocalSend proper විවෘත කරයි, එවිට වෙනත් device එකකට ඔබට යමක් එවිය හැකිය.

එම දෙයම terminal එකෙන් `omarchy share clipboard`, `omarchy share file [path]` සහ `omarchy share folder [path]` සමඟ ක්‍රියා කරයි. Path එක අත්හරින්න, ඔබට picker එක ලැබේ.

ඔබට file manager එකෙන් කෙළින්මද යැවිය හැකිය: Nautilus හි ඕනෑම තේරීමක් right-click කර _Send via LocalSend_ තෝරන්න.

Omarchy හි firewall එක LocalSend හි port එක හැර පෙරනිමියෙන් වසා ඇති බැවින්, මෙය fresh install එකක out of the box ක්‍රියා කරයි. [ආරක්ෂාව](48-security.md) බලන්න.

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) යනු word processor, spreadsheet, presentations, drawing application සහ තවත් බොහෝ දේ සහිත සම්පූර්ණ office package එකකි. එය Microsoft Office වෙතින් ලැබෙන ගොනු සමඟ අනුකූලය, එබැවින් එම Word documents විවෘත කිරීමට හැකි වීමට මෙය විශිෂ්ට ක්‍රමයකි.

ඔබ LibreOffice ආරම්භ කරන්නේ application launcher එක හරහාය (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) යනු Omarchy හිම අතිශයින් සරල presentation app එකයි. ඔබේ deck එක එහි පින්තූර සහ වීඩියෝ ඊට යාබදව ඇති තනි Markdown ගොනුවකි: සජීවී පෙරදසුනක් යටතේ එක් එක් slide එක ලියන්න, slides අනුපිළිවෙළට drag කරන්න, ඉන්පසු fullscreen ඉදිරිපත් කරන්න හෝ PDF සහ PowerPoint වෙත export කරන්න. එය ඔබේ Omarchy theme එක පවා ලබා ගනී.

ඔබ Hype ආරම්භ කරන්නේ application launcher එක හරහාය (`Super + Space`). සෑම shortcut එකක්ම බැලීමට එහි ඇතුළත `?` ඔබන්න.

## Signed

[Signed](https://github.com/omacom/signed) යනු PDFs අත්සන් කිරීමට සහ ඒවා පිරවීමට Omarchy හිම අතිශයින් සරල ක්‍රමයයි. ඔබ සුරකින ලද අත්සන, text එක සහ අද දිනය පිටුවක ඕනෑම තැනක තබන්න, ඉන්පසු මුල් පිටපත අසල අත්සන් කළ පිටපතක් save කරන්න. ආකාරය සඳහා [PDF පිරවීම](27-filling-out-pdfs.md) බලන්න.

ඔබ Signed ආරම්භ කරන්නේ application launcher එක හරහාය (`Super + Space`), නැතහොත් file manager එකෙන් PDF එකක් එය සමඟ විවෘත කරන්න.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) යනු Omarchy හිම 3D chess game එකයි. එකම computer එකේ මිතුරෙකු සමඟ හෝ මට්ටම් තුනකින් ඇති built-in opponent සමඟ ක්‍රීඩා කරන්න, ඒ ඒ ආකාරයෙන් චලනය වන මූර්තිමත් කට්ටල හතරක් මත: කක්ෂීය යානා, කැටයම් කළ ලී සහ ඇත්දළ, වනාන්තර ජීවීන් සහ රසකැවිලි. Games වලට clock එකක් නැත, සෑම move එකකින් පසු save වේ.

ඔබ Checkmate ආරම්භ කරන්නේ application launcher එක හරහාය (`Super + Space`), එහි එය Chess ලෙස ලැයිස්තුගත කර ඇත. සෑම shortcut එකක්ම බැලීමට එහි ඇතුළත `?` ඔබන්න.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) යනු floating window එකක විවෘත වන, Omarchy හිම අතිශයින් සරල calculator එකයි.

ඔබ Omacalc ආරම්භ කරන්නේ `Super + Shift + Q` මගිනි (හෝ ඔබේ keyboard එකේ calculator key එකක් තිබේ නම් එයින්).

## Signal

[Signal](https://signal.org/) යනු E2E encrypted messaging හි පුරෝගාමියා වන අතර, විශාල තාක්ෂණික සමාගම් සමූහයකින් එකක් හරහා යාමට අකමැති ඕනෑම අයෙකුට විශිෂ්ට සන්නිවේදන විකල්පයකි.

ඔබ Signal ආරම්භ කරන්නේ `Super + Shift + G` මගිනි. එය base install එකේ කොටසක් නොවේ, එබැවින් ඔබ පළමු වරට එය එබූ විට, Omarchy එය ඔබ වෙනුවෙන් install කිරීමට ඉදිරිපත් වේ (එය Omarchy menu එකේ _Install > Service_ යටතේද ඇත).

## Omaview

[Omaview](https://github.com/omacom/omaview) යනු Omarchy හිම අතිශයින් සරල picture viewer සහ media player එකයි: ඔබේ photos, videos සහ music සඳහා එකම window එකක්. Photo එකක් විවෘත කරන්න, arrow keys එහි folder එකේ ඉතිරිය හරහා පියවරෙන් පියවර යයි, `N` සහ `P` ඕනෑම දෙයක් සඳහා එය කරයි, `Ctrl + M` මුළු folder එකම grid එකක් ලෙස පෙන්වයි. එය HEIC, AVIF සහ JPEG XL photos ද පෙන්වයි, දිග ඕනෑම දෙයක ඔබ නැවතුණු තැනින් නැවත ලබා ගනී.

Fullscreen සඳහා `F` ඔබන්න, Omasnap තුළ පින්තූරයක් සංස්කරණය කිරීමට හෝ Omacut තුළ වීඩියෝවක් trim කිරීමට `E`, පින්තූරයක් print කිරීමට `Ctrl + P`, ගොනුවක් Trash එකට යැවීමට `Delete` ඔබන්න (`Ctrl + Z` එය ආපසු ගෙන එයි). සෑම shortcut එකක්ම බැලීමට එහි ඇතුළත `?` ඔබන්න.

ඔබ Omaview _Media Viewer_ ලෙස application launcher එක හරහා (`Super + Space`) ආරම්භ කරයි, නැතහොත් file manager එකේ පින්තූරයක්, වීඩියෝවක් හෝ ගීතයක් ද්වි-ක්ලික් කරන්න.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) යනු Omarchy හිම අතිශයින් සරල video trimmer එකයි. ඔබට අවශ්‍ය වන්නේ clip එකක ආරම්භය සහ අවසානය කපා හැරීම පමණක් වන විට, එය සම්පූර්ණ video editor එකක් දියත් කිරීමට වඩා හොඳය.

ඔබ Omacut ආරම්භ කරන්නේ application launcher එක හරහාය (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) යනු Omarchy හිම අතිශයින් සරල webcam recorder එකයි. ඔබේ camera එක සහ microphone එක එක් වරක් තෝරන්න, ඉන්පසු record කිරීමට `Space` ඔබන්න, එම take එකම pause කර නැවත ආරම්භ කිරීමට නැවත ඔබන්න. එය සැමවිටම ඔබේ camera එකේ ඉහළම resolution එකෙන් record කරයි, ඔබ ආරම්භ කිරීමට පෙර ඔබේ levels පරීක්ෂා කළ හැකි වන පරිදි සජීවී microphone meter එකක් සමඟ.

Take එක නවත්වන්න, එය built-in editor එකක වහාම විවෘත වේ. Clip එකක් බෙදීමට එය ද්වි-ක්ලික් කරන්න, එක් එක් කොටස trim කිරීමට handles drag කරන්න, ඔබට අනවශ්‍ය කොටස් ඉවත් කරන්න. ඉන්පසු එය MP4 එකක් ලෙස save කරන්න. ඔබ එය අත්හරින තුරු ඔබේ මුල් recording එක තබා ගනු ලැබේ, එබැවින් ඔබට සැමවිටම ආපසු පැමිණ එය වෙනස් ලෙස කපා ගත හැකිය.

ඔබ Monologue ආරම්භ කරන්නේ application launcher එක හරහාය (`Super + Space`).
