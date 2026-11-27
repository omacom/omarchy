# Tēmas

Omarchy nāk ar divdesmit trim skaistām tēmām. Tās varat izvēlēties, izmantojot _Izskats > Tēma_ Omarchy izvēlnē (`Super + Space`), vai pāriet tieši uz tēmu izvēli ar `Super + Ctrl + T`.

Katra tēma noformē darbvirsmu, termināli, neovim, aktivitāšu ekrānu (btop), jūsu pārlūku (Chrome, Chromium, Edge vai Brave) un visu Omarchy apvalku: augšējo joslu, izvēlni, paziņojumus, OSD un bloķēšanas ekrānu. (Obsidian gadījumā Omarchy tēma ir jāizvēlas manuāli, izmantojot _Izskats > Tēmas_ lietotnē.)

Tēmām ir fona attēlu kopa, no kuras varat izvēlēties, izmantojot `Super + Ctrl + W`.

Vēl vairāk tēmu varat atrast [papildu tēmu lapā](https://omarchy.org/themes/) vai pat [izveidot savu tēmu](43-making-your-own-theme.md).

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

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### Lietotņu ikonas

Lietotņu palaidējā un dokā redzamās ikonas ir zīmētas jūsu tēmas krāsās, tāpēc tās mainās līdz ar tēmu. Tās nāk no ikonu kopas, kuru izvēlaties atsevišķi no tēmas sadaļā _Izskats > Ikonas_, no katras kopas priekšskatījumiem, tāpat kā izvēlaties tēmu:

- _Papercraft_ ir noklusējums: viss, kas ir instalēts, ir uzzīmēts vienā stilā. Lietotnes, kas atpazīstamas pēc to logotipa, piemēram, Chrome, HEY vai YouTube, saglabā tā formu un iegūst tēmas krāsas.
- _Arcade_ tās pašas lietotnes zīmē kā 8 bitu pikseļu mākslu, kā to darītu veca spēļu konsole.
- _Original_ katru lietotni rāda ar ikonu, ko tai devis tās veidotājs.

Kādas citas personas izveidotu ikonu kopu varat instalēt ar _Instalēt > Stils > Ikonas_ (vai `omarchy icons install <git url>`), un noņemt to atkal sadaļā _Noņemt > Ikonas_. _Atjaunināt > Papildu ikonas_ iegūst jūsu instalēto kopu jaunāko versiju.

Lai izveidotu savu kopu, ievietojiet savas ikonas mapē `~/.config/omarchy/icons/<name>/`, vienu failu katrai lietotnei, nosauktu atbilstoši lietotnes `.desktop` faila rindai `Icon=`. Fails ar paplašinājumu `.svg` tiek rādīts tāds, kāds tas ir. Fails ar paplašinājumu `.svg.tpl` tiek zīmēts tēmas krāsās: vietā, kur jābūt krāsai, ierakstiet `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` vai `{{ icon_shadow }}`. Noklusētā kopa mapē `/usr/share/omarchy/icons/papercraft/` ir laba vieta, no kuras sākt. Pievienojiet `preview.png`, lai jūsu kopa tiktu rādīta izvēlnē; bez tā Omarchy izveidos priekšskatījumu no jūsu ikonām. Lai mainītu vienu noklusētās kopas ikonu, ievietojiet savu versiju mapē `~/.config/omarchy/icons/papercraft/`.

### Atbloķēšana

Tēmām var būt arī pielāgots atbloķēšanas noformējums, kas tiek izmantots sāknēšanas atšifrēšanas procesā. Tādu varat izvēlēties sadaļā _Izskats > Atbloķēšana_. Tie izskatās šādi:

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

 ![last-horizon](../themes/last-horizon/preview-unlock.png)
_Last Horizon_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![lupine](../themes/lupine/preview-unlock.png)
_Lupine_

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

 ![solitude](../themes/solitude/preview-unlock.png)
_Solitude_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
