# Teme

Omarchy dolazi s dvadeset i dvije prekrasne teme. Među njima možete birati putem _Appearance > Theme_ u izborniku Omarchy Menu (`Super + Space`) ili izravno otići na izbornik tema pomoću `Super + Ctrl + T`.

Svaka tema oblikuje radnu površinu, terminal, neovim, zaslon aktivnosti (btop), Chromium i cijelu ljusku Omarchy: gornju traku, izbornik, obavijesti, OSD i zaključani zaslon. (Za Obsidian morate ručno odabrati temu Omarchy putem _Appearance > Themes_ unutar aplikacije).

Teme imaju skup pozadinskih slika među kojima možete birati pomoću `Super + Ctrl + W`.

Još više tema možete pronaći na [stranici s dodatnim temama](https://omarchy.org/themes/) ili čak [izraditi vlastitu temu](43-making-your-own-theme.md).

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

### Ikone aplikacija

Ikone u pokretaču aplikacija i na docku nacrtane su u bojama vaše teme, pa se mijenjaju zajedno s njom. Dolaze iz skupa ikona, koji birate odvojeno od teme pod _Appearance > Icons_:

- _Papercraft_ je zadani: sve što dolazi instalirano, nacrtano u jednom stilu. Aplikacije poznate po svom logotipu, poput Chrome, HEY ili YouTube, zadržavaju svoj oblik i poprimaju boje teme.
- _Arcade_ iste aplikacije crta kao 8-bitnu piksel grafiku, kako bi to učinila stara igraća konzola.
- _Original_ svaku aplikaciju prikazuje s ikonom koju joj je dao njezin tvorac.

Skup ikona koji je izradio netko drugi možete instalirati pomoću _Install > Style > Icons_ (ili `omarchy icons install <git url>`), a ponovno ga ukloniti pod _Remove > Icons_. _Update > Extra Icons_ dohvaća najnoviju verziju skupova koje ste instalirali.

Da biste izradili vlastiti, stavite svoje ikone u `~/.config/omarchy/icons/<name>/`, po jednu datoteku za svaku aplikaciju, nazvanu prema retku `Icon=` u `.desktop` datoteci aplikacije. Datoteka koja završava na `.svg` prikazuje se kakva jest. Datoteka koja završava na `.svg.tpl` crta se u bojama teme: napišite `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` ili `{{ icon_shadow }}` tamo gdje ide boja. Zadani skup u `/usr/share/omarchy/icons/papercraft/` dobro je mjesto za početak. Da biste promijenili jednu ikonu zadanog skupa, stavite svoju verziju u `~/.config/omarchy/icons/papercraft/`.

### Otključavanja

Teme mogu imati i prilagođeni dizajn otključavanja, koji se koristi za postupak dešifriranja pri pokretanju sustava. Jedan od njih možete odabrati pod _Appearance > Unlock_. Izgledaju ovako:

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
