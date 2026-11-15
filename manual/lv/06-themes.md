# Motīvi

Omarchy komplektā ir divdesmit divi skaisti motīvi. Starp tiem varat izvēlēties Omarchy izvēlnē (`Super + Space`) sadaļā _Izskats > Motīvs_ vai pāriet tieši uz motīvu atlasītāju ar `Super + Ctrl + T`.

Katrs motīvs noformē darbvirsmu, termināli, neovim, aktivitāšu ekrānu (btop), Chromium un visu Omarchy apvalku: augšējo joslu, izvēlni, paziņojumus, OSD un bloķēšanas ekrānu. (Obsidian gadījumā Omarchy motīvs pašā lietotnē jāizvēlas manuāli sadaļā _Izskats > Motīvi_).

Motīviem ir fona attēlu kopa, starp kuriem varat izvēlēties ar `Super + Ctrl + W`.

Vēl vairāk motīvu varat atrast [papildu motīvu lapā](https://omarchy.org/themes/) vai pat [izveidot savu motīvu](43-making-your-own-theme.md).

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

Lietotņu palaidējā un dokā ikonas ir zīmētas jūsu motīva krāsās, tāpēc tās mainās līdz ar to. Tās nāk no ikonu kopas, ko izvēlaties atsevišķi no motīva sadaļā _Izskats > Ikonas_:

- _Papercraft_ ir noklusējums: viss, kas nāk instalēts, ir uzzīmēts vienā stilā. Lietotnes, kas pazīstamas pēc sava logotipa, piemēram, Chrome, HEY vai YouTube, saglabā savu formu un iegūst motīva krāsas.
- _Arcade_ tās pašas lietotnes zīmē kā 8 bitu pikseļu mākslu, kā to darītu sena spēļu konsole.
- _Original_ katru lietotni rāda ar ikonu, ko tai devis tās veidotājs.

Cita veidotu ikonu kopu varat instalēt ar _Instalēšana > Stils > Ikonas_ (vai `omarchy icons install <git url>`), un atkal to noņemt sadaļā _Noņemšana > Ikonas_. _Atjaunināšana > Papildu ikonas_ iegūst jūsu instalēto kopu jaunāko versiju.

Lai izveidotu savu, ievietojiet ikonas mapē `~/.config/omarchy/icons/<name>/`, vienu failu katrai lietotnei, nosauktu pēc lietotnes `.desktop` faila rindas `Icon=`. Fails, kas beidzas ar `.svg`, tiek rādīts tāds, kāds tas ir. Fails, kas beidzas ar `.svg.tpl`, tiek zīmēts motīva krāsās: vietā, kur jābūt krāsai, ierakstiet `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` vai `{{ icon_shadow }}`. Noklusējuma kopa mapē `/usr/share/omarchy/icons/papercraft/` ir laba vieta, no kuras sākt. Lai mainītu vienu noklusējuma kopas ikonu, ievietojiet savu versiju mapē `~/.config/omarchy/icons/papercraft/`.

### Atbloķēšanas ekrāni

Motīviem var būt arī pielāgots atbloķēšanas dizains, ko izmanto sāknēšanas atšifrēšanas procesā. Kādu no tiem varat atlasīt sadaļā _Izskats > Atbloķēšana_. Tie izskatās šādi:

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
