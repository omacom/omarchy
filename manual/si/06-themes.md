# තේමාවන්

Omarchy සමඟ ලස්සන තේමා විසි දෙකක් ලැබේ. Omarchy Menu එකෙහි (`Super + Space`) _පෙනුම > තේමාව_ හරහා ඔබට ඒවා අතරින් තෝරා ගත හැකි අතර, `Super + Ctrl + T` භාවිතයෙන් තේමා තේරීම වෙත කෙලින්ම යා හැකිය.

සෑම තේමාවක්ම desktop එක, terminal එක, neovim, ක්‍රියාකාරකම් තිරය (btop), Chromium සහ මුළු Omarchy shell එකම හැඩගන්වයි: ඉහළ තීරුව, මෙනුව, දැනුම්දීම්, OSD එක සහ අගුළු තිරය. (Obsidian සඳහා, යෙදුම තුළ _පෙනුම > තේමාවන්_ හරහා ඔබ Omarchy තේමාව අතින්ම තෝරා ගත යුතුය).

තේමාවන්ට තෝරා ගත හැකි පසුබිම් රූප කට්ටලයක් ඇති අතර, `Super + Ctrl + W` භාවිතයෙන් ඔබට ඒවා අතරින් තෝරා ගත හැකිය.

[අමතර තේමා පිටුවේ](https://omarchy.org/themes/) ඔබට තවත් තේමා සොයා ගත හැකි අතර, [ඔබේම තේමාවක් සාදා ගත](43-making-your-own-theme.md) හැකිය.

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

යෙදුම් දියත්කරයේ සහ dock එකේ ඇති අයිකන ඔබේ තේමාවේ වර්ණවලින් ඇඳ ඇති බැවින්, ඒවා ද එය සමඟම වෙනස් වේ. ඒවා අයිකන කට්ටලයකින් ලැබෙන අතර, _පෙනුම > අයිකන_ යටතේ තේමාවෙන් වෙන්ව ඔබ එය තෝරා ගනී:

- _Papercraft_ යනු පෙරනිමියයි: ස්ථාපනය වී එන සියල්ලම එකම විලාසයකින් ඇඳ ඇත. Chrome, HEY හෝ YouTube වැනි, ඒවායේ ලාංඡනයෙන් හඳුනාගන්නා යෙදුම්, ඒවායේ හැඩය රඳවා ගෙන තේමාවේ වර්ණ ලබා ගනී.
- _Arcade_ එම යෙදුම්ම පැරණි ක්‍රීඩා කොන්සෝලයක මෙන් 8-bit පික්සල් කලාවක් ලෙස අඳියි.
- _Original_ සෑම යෙදුමක්ම එහි නිර්මාතෘවරයා ලබා දුන් අයිකනය සමඟ පෙන්වයි.

වෙනත් කෙනෙකු සාදන ලද අයිකන කට්ටලයක් _ස්ථාපනය > විලාසය > අයිකන_ (හෝ `omarchy icons install <git url>`) හරහා ඔබට ස්ථාපනය කළ හැකි අතර, _ඉවත් කරන්න > අයිකන_ යටතේ එය නැවත ඉවත් කළ හැකිය. _යාවත්කාලීනය > අමතර අයිකන_ ඔබ ස්ථාපනය කර ඇති කට්ටලවල නවතම අනුවාදය ලබා ගනී.

ඔබේම අයිකන සෑදීමට, ඔබේ අයිකන `~/.config/omarchy/icons/<name>/` තුළ තබන්න. යෙදුමකට එක ගොනුව බැගින් තබන්න, යෙදුමේ `.desktop` ගොනුවේ `Icon=` පේළිය අනුව ඒවා නම් කරන්න. `.svg` වලින් අවසන් වන ගොනුවක් ඇති ආකාරයෙන්ම පෙන්වනු ලැබේ. `.svg.tpl` වලින් අවසන් වන ගොනුවක් තේමාවේ වර්ණවලින් අඳිනු ලැබේ: වර්ණයක් යන තැන `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` හෝ `{{ icon_shadow }}` ලියන්න. `/usr/share/omarchy/icons/papercraft/` හි ඇති පෙරනිමි කට්ටලය ආරම්භ කිරීමට හොඳ තැනකි. පෙරනිමි කට්ටලයේ තනි අයිකනයක් වෙනස් කිරීමට, ඔබේ අනුවාදය `~/.config/omarchy/icons/papercraft/` තුළ තබන්න.

### අගුළු හැරීම්

තේමාවන්ට අභිරුචි අගුළු හැරීමේ සැලසුමක් ද තිබිය හැකි අතර, එය boot විකේතන ක්‍රියාවලිය සඳහා භාවිත වේ. _පෙනුම > අගුළු හැරීම_ යටතේ ඔබට මේවායින් එකක් තෝරා ගත හැකිය. ඒවා මෙසේ දිස් වේ:

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
