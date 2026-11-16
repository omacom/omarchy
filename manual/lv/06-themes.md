# Tēmas

Omarchy nāk ar divdesmit divām skaistām tēmām. Tu vari izvēlēties starp tām Omarchy izvēlnē (`Super + Space`) sadaļā _Izskats > Tēma_ vai pārlēkt tieši uz tēmu atlasītāju ar `Super + Ctrl + T`.

Katra tēma veido darbvirsmas, termināļa, neovim, aktivitāšu ekrāna (btop), Chromium un visas Omarchy čaulas stilu: augšējā josla, izvēlne, paziņojumi, OSD un bloķēšanas ekrāns. (Obsidian gadījumā Omarchy tēma tev manuāli jāizvēlas pašā lietotnē sadaļā _Izskats > Tēmas_). 

Tēmām ir fona attēlu kopums, starp kuriem vari izvēlēties ar `Super + Ctrl + W`.

Vēl vairāk tēmu atradīsi [papildu tēmu lapā](https://omarchy.org/themes/) vai pat [izveido savu tēmu](43-making-your-own-theme.md).

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

### Lietotņu ikonas

Ikonas lietotņu palaišanas rīkā un dokā ir uzzīmētas tavas tēmas krāsās, tāpēc tās mainās līdz ar to. Tās nāk no ikonu kopas, ko izvēlies atsevišķi no tēmas sadaļā _Izskats > Ikonas_, pēc katras kopas priekšskatījumiem, tāpat kā izvēlies tēmu:

- _Papercraft_ ir noklusējums: viss, kas nāk instalēts, uzzīmēts vienā stilā. Lietotnes, kas pazīstamas pēc sava logotipa, piemēram, Chrome, HEY vai YouTube, saglabā tā formu un iegūst tēmas krāsas.
- _Arcade_ tās pašas lietotnes zīmē kā 8 bitu pikseļu mākslu, kā to darītu veca spēļu konsole.
- _Original_ katru lietotni rāda ar ikonu, ko tai devis tās veidotājs.

Kādas citas personas izveidotu ikonu kopu vari instalēt ar _Instalēt > Stils > Ikonas_ (vai `omarchy icons install <git url>`) un atkal noņemt sadaļā _Noņemt > Ikonas_. _Atjaunināt > Papildu ikonas_ iegūst tavu instalēto kopu jaunāko versiju.

Lai izveidotu savu, ieliec savas ikonas mapē `~/.config/omarchy/icons/<name>/`, vienu failu katrai lietotnei, nosauktu pēc lietotnes `.desktop` faila rindiņas `Icon=`. Fails, kas beidzas ar `.svg`, tiek parādīts tāds, kāds tas ir. Fails, kas beidzas ar `.svg.tpl`, tiek uzzīmēts tēmas krāsās: vietā, kur jābūt krāsai, ieraksti `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` vai `{{ icon_shadow }}`. Noklusējuma kopa mapē `/usr/share/omarchy/icons/papercraft/` ir laba vieta, no kuras sākt. Pievieno `preview.png`, lai parādītu savu kopu atlasītājā; bez tā Omarchy uzzīmē priekšskatījumu no tavām ikonām. Lai mainītu vienu noklusējuma kopas ikonu, ieliec savu versiju mapē `~/.config/omarchy/icons/papercraft/`.

### Atbloķēšana

Tēmām var būt arī pielāgots atbloķēšanas dizains, ko izmanto sāknēšanas atšifrēšanas procesam. Vienu no tiem vari izvēlēties sadaļā _Izskats > Atbloķēšana_. Tie izskatās šādi:

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
