# තේමා

Omarchy ලස්සන තේමා විසිදෙකක් සමඟ එයි. ඔබට Omarchy Menu (`Super + Space`) එකේ _පෙනුම > තේමාව_ හරහා ඒවා අතරින් තෝරාගත හැක, නැතහොත් `Super + Ctrl + T` භාවිතයෙන් කෙළින්ම තේමා තෝරකය වෙත යා හැක.

සෑම තේමාවක්ම desktop එක, terminal එක, neovim, ක්‍රියාකාරකම් තිරය (btop), Chromium, සහ සම්පූර්ණ Omarchy shell එක: top bar එක, menu එක, දැනුම්දීම්, OSD එක, සහ lock screen එක විලාසවත් කරයි. (Obsidian සඳහා, ඔබ යෙදුම ඇතුළත _පෙනුම > තේමා_ හරහා අතින්ම Omarchy තේමාව තෝරාගත යුතුය).

තේමාවලට පසුබිම් රූප කට්ටලයක් ඇති අතර `Super + Ctrl + W` භාවිතයෙන් ඔබට ඒවා අතරින් තෝරාගත හැක.

ඔබට [අමතර තේමා පිටුවේ](https://omarchy.org/themes/) තවත් තේමා සොයාගත හැක, නැතහොත් [ඔබේම තේමාවක් සාදාගත හැක](43-making-your-own-theme.md).

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

### යෙදුම් අයිකන

යෙදුම් launcher එකේ සහ dock එකේ අයිකන ඔබේ තේමාවේ වර්ණවලින් ඇඳ ඇති බැවින්, ඒවා එයත් සමඟම වෙනස් වේ. ඒවා එන්නේ අයිකන කට්ටලයකින් වන අතර, ඔබ තේමාවක් තෝරන ආකාරයටම, එක් එක් කට්ටලයේ පෙරදසුන්වලින්, තේමාවෙන් වෙන්ව _පෙනුම > අයිකන_ යටතේ ඔබ එය තෝරයි:

- _Papercraft_ යනු පෙරනිමියයි: ස්ථාපනය වී එන සියල්ල, එකම විලාසයකින් ඇඳ ඇත. Chrome, HEY, හෝ YouTube වැනි, ඒවායේ ලාංඡනයෙන් හඳුනාගන්නා යෙදුම්, එහි හැඩය රඳවාගෙන තේමාවේ වර්ණ ලබා ගනී.
- _Arcade_ එම යෙදුම්ම 8-bit pixel art ලෙස, පැරණි game console එකක් කරන ආකාරයට අඳියි.
- _Original_ සෑම යෙදුමක්ම එය සාදන ලද තැනැත්තා එයට දුන් අයිකනය සමඟ පෙන්වයි.

වෙනත් කෙනෙකු සාදන ලද අයිකන කට්ටලයක් ඔබට _ස්ථාපනය > විලාසය > අයිකන_ සමඟ (නැතහොත් `omarchy icons install <git url>` සමඟ) ස්ථාපනය කළ හැක, සහ එය නැවත _ඉවත් කරන්න > අයිකන_ යටතේ ඉවත් කළ හැක. _යාවත්කාලීනය > අමතර අයිකන_ ඔබ ස්ථාපනය කර ඇති කට්ටලවල නවතම අනුවාදය ලබා ගනී.

ඔබේම එකක් සෑදීමට, ඔබේ අයිකන `~/.config/omarchy/icons/<name>/` තුළ දමන්න, එක් යෙදුමකට එක් ගොනුවක් බැගින්, යෙදුමේ `.desktop` ගොනුවේ `Icon=` පේළිය අනුව නම් කරමින්. `.svg` වලින් අවසන් වන ගොනුවක් ඇති ආකාරයටම පෙන්වයි. `.svg.tpl` වලින් අවසන් වන ගොනුවක් තේමාවේ වර්ණවලින් අඳියි: වර්ණයක් යන තැන `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` හෝ `{{ icon_shadow }}` ලියන්න. `/usr/share/omarchy/icons/papercraft/` හි ඇති පෙරනිමි කට්ටලය ආරම්භ කිරීමට හොඳ තැනකි. ඔබේ කට්ටලය තෝරකය තුළ පෙන්වීමට `preview.png` එකක් එක් කරන්න; එකක් නොමැතිව, Omarchy ඔබේ අයිකනවලින් පෙරදසුනක් අඳියි. පෙරනිමි කට්ටලයේ එක් අයිකනයක් වෙනස් කිරීමට, ඔබේ අනුවාදය `~/.config/omarchy/icons/papercraft/` තුළ දමන්න.

### අගුළු ඇරීම්

තේමාවලට boot decryption ක්‍රියාවලිය සඳහා භාවිතා කරන අභිරුචි අගුළු ඇරීමේ සැලසුමක් ද තිබිය හැක. ඔබට _පෙනුම > අගුළු ඇරීම_ යටතේ මේවායින් එකක් තෝරාගත හැක. ඒවා මේ ආකාරයෙන් පෙනේ:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
