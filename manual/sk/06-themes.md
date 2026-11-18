# Témy

Omarchy obsahuje dvadsaťdva nádherných tém. Vybrať si medzi nimi môžete cez _Vzhľad > Téma_ v Omarchy Menu (`Super + Space`) alebo môžete prejsť priamo do výberu tém pomocou `Super + Ctrl + T`.

Každá téma upravuje vzhľad pracovnej plochy, terminálu, neovim, obrazovky aktivity (btop), Chromium a celého prostredia Omarchy: horného panela, ponuky, oznámení, OSD a uzamykacej obrazovky. (V prípade Obsidian musíte tému Omarchy vybrať ručne cez _Vzhľad > Témy_ priamo v aplikácii).

Témy majú sadu obrázkov na pozadí, medzi ktorými si môžete vybrať pomocou `Super + Ctrl + W`.

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

Ikony v spúšťači aplikácií a v docku sú vykreslené vo farbách vašej témy, takže sa menia spolu s ňou. Pochádzajú zo sady ikon, ktorú si vyberáte oddelene od témy v časti _Vzhľad > Ikony_, z ukážok jednotlivých sád, rovnako ako si vyberáte tému:

- _Papercraft_ je predvolená: všetko, čo je nainštalované, vykreslené v jednom štýle. Aplikácie známe svojím logom, ako Chrome, HEY alebo YouTube, si zachovajú jeho tvar a prevezmú farby témy.
- _Arcade_ vykresľuje tie isté aplikácie ako 8-bitový pixel art, ako by to urobila stará herná konzola.
- _Original_ zobrazuje každú aplikáciu s ikonou, ktorú jej dal jej tvorca.

Sadu ikon, ktorú vytvoril niekto iný, môžete nainštalovať cez _Inštalovať > Štýl > Ikony_ (alebo `omarchy icons install <git url>`) a znova ju odstrániť v časti _Odstrániť > Ikony_. _Aktualizovať > Extra ikony_ stiahne najnovšiu verziu sád, ktoré máte nainštalované.

Ak si chcete vytvoriť vlastnú, umiestnite svoje ikony do `~/.config/omarchy/icons/<name>/`, jeden súbor pre každú aplikáciu, pomenovaný podľa riadka `Icon=` v súbore `.desktop` danej aplikácie. Súbor končiaci na `.svg` sa zobrazí tak, ako je. Súbor končiaci na `.svg.tpl` sa vykreslí vo farbách témy: tam, kam patrí farba, napíšte `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` alebo `{{ icon_shadow }}`. Predvolená sada v `/usr/share/omarchy/icons/papercraft/` je dobrým východiskovým bodom. Pridajte `preview.png`, aby sa vaša sada zobrazila vo výbere; bez neho Omarchy vykreslí ukážku z vašich ikon. Ak chcete zmeniť jedinú ikonu predvolenej sady, umiestnite svoju verziu do `~/.config/omarchy/icons/papercraft/`.

### Odomykanie

Témy môžu mať aj vlastný dizajn odomykania, ktorý sa používa pri dešifrovaní počas zavádzania systému. Jeden z nich si môžete vybrať v časti _Vzhľad > Odomykanie_. Vyzerajú takto:

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
