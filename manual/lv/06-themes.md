# Tēmas

Omarchy komplektā ir divdesmit trīs skaistas tēmas. Tās varat izvēlēties Omarchy izvēlnes sadaļā _Izskats > Tēma_ (`Super + Space`) vai doties tieši uz tēmu atlasītāju ar `Super + Ctrl + T`.

Katru tēmu veido darbvirsmas, termināļa, neovim, aktivitāšu ekrāna (btop), jūsu pārlūka (Chrome, Chromium, Edge vai Brave) un visas Omarchy čaulas noformējums: augšējā josla, izvēlne, paziņojumi, OSD un bloķēšanas ekrāns. (Obsidian gadījumā Omarchy tēma lietotnē manuāli jāizvēlas sadaļā _Izskats > Tēmas_).

Tēmām ir fona attēlu kopa, no kuras varat izvēlēties ar `Super + Ctrl + W`.

Vēl vairāk tēmu atradīsiet [papildu tēmu lapā](https://omarchy.org/themes/) vai pat varat [izveidot savu tēmu](43-making-your-own-theme.md).

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

Lietotņu palaidējā un dokā ikonas ir uzzīmētas jūsu tēmas krāsās, tāpēc tās mainās līdz ar tēmu. Tās nāk no ikonu kopas, kuru izvēlaties atsevišķi no tēmas sadaļā _Izskats > Ikonas_ pēc katras kopas priekšskatījumiem, tāpat kā izvēlaties tēmu:

- _Papercraft_ ir noklusējums: viss, kas nāk instalēts, uzzīmēts vienā stilā. Lietotnes, kuras pazīst pēc to logotipa, piemēram, Chrome, HEY vai YouTube, saglabā savu formu un iegūst tēmas krāsas.
- _Arcade_ tās pašas lietotnes zīmē kā 8 bitu pikseļu mākslu, kā to darītu sena spēļu konsole.
- _Original_ katru lietotni rāda ar ikonu, ko tai devis tās veidotājs.

Cita cilvēka izveidotu ikonu kopu varat instalēt ar _Instalēt > Stils > Ikonas_ (vai `omarchy icons install <git url>`) un atkal noņemt sadaļā _Noņemt > Ikonas_. _Atjaunināt > Papildu ikonas_ iegūst jūsu instalēto kopu jaunāko versiju.

Lai izveidotu savu, ielieciet ikonas mapē `~/.config/omarchy/icons/<name>/`, vienu failu katrai lietotnei, nosauktu pēc lietotnes `.desktop` faila `Icon=` rindas. Fails, kura nosaukums beidzas ar `.svg`, tiek rādīts tāds, kāds tas ir. Fails, kura nosaukums beidzas ar `.svg.tpl`, tiek zīmēts tēmas krāsās: vietā, kur jābūt krāsai, rakstiet `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` vai `{{ icon_shadow }}`. Noklusējuma kopa mapē `/usr/share/omarchy/icons/papercraft/` ir laba vieta, no kuras sākt. Pievienojiet `preview.png`, lai jūsu kopa tiktu rādīta atlasītājā; bez tā Omarchy priekšskatījumu uzzīmē no jūsu ikonām. Lai mainītu vienu noklusējuma kopas ikonu, ielieciet savu versiju mapē `~/.config/omarchy/icons/papercraft/`.

### Sāknēšana un pieteikšanās

Ekrāns, kas datora startēšanas laikā prasa jūsu diska paroli, un pieteikšanās ekrāns arī seko tēmai. Katru reizi, kad pārslēdzat tēmas, tie iegūst tās fonu, tekstu, akcenta un sarkanās krāsas, tāpēc nav atsevišķa atbloķēšanas noformējuma, ko izvēlēties. Apple Silicon Mac datoros diska paroles ekrāns saglabā Omarchy noklusējuma izskatu neatkarīgi no tēmas.
