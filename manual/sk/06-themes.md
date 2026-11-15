# Témy

Omarchy prichádza s dvadsiatimi dvoma krásnymi témami. Môžete medzi nimi vyberať cez _Vzhľad > Téma_ v Omarchy Menu (`Super + Space`) alebo skočiť priamo do výberu témy pomocou `Super + Ctrl + T`.

Každá téma upravuje štýl pracovnej plochy, terminálu, neovim, obrazovky aktivity (btop), Chromium a celého prostredia Omarchy: horný panel, menu, notifikácie, OSD a uzamknutú obrazovku. (Pre Obsidian musíte tému Omarchy vybrať manuálne cez _Vzhľad > Témy_ vnútri aplikácie).

Témy majú sadu obrázkov pozadia, medzi ktorými môžete vyberať pomocou `Super + Ctrl + W`.

Ešte viac tém nájdete na [stránke s ďalšími témami](https://omarchy.org/themes/) alebo si dokonca môžete [vytvoriť vlastnú tému](43-making-your-own-theme.md).

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

### Ikony aplikácií

Ikony v spúšťači aplikácií a docku sú vykreslené vo farbách vašej témy, takže sa menia spolu s ňou. Pochádzajú zo sady ikon, ktorú si vyberáte oddelene od témy pod _Vzhľad > Ikony_:

- _Papercraft_ je predvolená: všetko, čo je nainštalované, vykreslené v jednom štýle. Aplikácie známe svojím logom, ako Chrome, HEY alebo YouTube, si zachovávajú jeho tvar a preberajú farby témy.
- _Arcade_ vykresľuje tie isté aplikácie ako 8-bit pixel art, ako by to robila stará herná konzola.
- _Original_ zobrazuje každú aplikáciu s ikonou, ktorú jej dal jej tvorca.

Sadu ikon, ktorú vytvoril niekto iný, môžete nainštalovať cez _Inštalovať > Štýl > Ikony_ (alebo `omarchy icons install <git url>`) a znova ju odstrániť pod _Odstrániť > Ikony_. _Aktualizovať > Extra ikony_ stiahne najnovšiu verziu sád, ktoré máte nainštalované.

Ak si chcete vytvoriť vlastnú, umiestnite svoje ikony do `~/.config/omarchy/icons/<name>/`, jeden súbor pre každú aplikáciu, pomenovaný podľa riadku `Icon=` v `.desktop` súbore aplikácie. Súbor končiaci na `.svg` sa zobrazí tak, ako je. Súbor končiaci na `.svg.tpl` sa vykreslí vo farbách témy: napíšte `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` alebo `{{ icon_shadow }}` tam, kde má byť farba. Predvolená sada v `/usr/share/omarchy/icons/papercraft/` je dobrým miestom, odkiaľ začať. Ak chcete zmeniť jednu ikonu z predvolenej sady, umiestnite svoju verziu do `~/.config/omarchy/icons/papercraft/`.

### Odomknutia

Témy môžu mať aj vlastný dizajn odomknutia, ktorý sa používa pri dešifrovaní pri štarte systému. Jeden z nich si môžete vybrať pod _Vzhľad > Odomknutie_. Vyzerajú takto:

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
