# Témy

Omarchy prichádza s dvadsiatimi tromi krásnymi témami. Môžete si medzi nimi vybrať cez _Vzhľad > Téma_ v Omarchy Menu (`Super + Space`) alebo skočiť priamo do výberu tém pomocou `Super + Ctrl + T`.

Každá téma upravuje štýl pracovnej plochy, terminálu, neovim, obrazovky aktivity (btop), vášho prehliadača (Chrome, Chromium, Edge alebo Brave) a celého prostredia Omarchy: horného panela, menu, oznámení, OSD a uzamknutej obrazovky. (V Obsidian musíte tému Omarchy vybrať ručne cez _Vzhľad > Témy_ priamo v aplikácii).

Témy majú sadu obrázkov na pozadí, medzi ktorými si môžete vyberať pomocou `Super + Ctrl + W`.

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

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### Ikony aplikácií

Ikony v spúšťači aplikácií a v docku sú vykreslené vo farbách vašej témy, takže sa menia spolu s ňou. Pochádzajú zo sady ikon, ktorú si vyberáte oddelene od témy v časti _Vzhľad > Ikony_, z ukážok jednotlivých sád, rovnakým spôsobom, ako si vyberáte tému:

- _Papercraft_ je predvolená: všetko, čo je nainštalované, nakreslené v jednom štýle. Aplikácie známe svojím logom, ako Chrome, HEY alebo YouTube, si zachovávajú svoj tvar a preberajú farby témy.
- _Arcade_ kreslí tie isté aplikácie ako 8-bit pixel art, ako by to urobila stará herná konzola.
- _Original_ zobrazuje každú aplikáciu s ikonou, ktorú jej dal jej tvorca.

Sadu ikon, ktorú vytvoril niekto iný, môžete nainštalovať cez _Inštalovať > Štýl > Ikony_ (alebo `omarchy icons install <git url>`) a znova ju odstrániť v časti _Odstrániť > Ikony_. _Aktualizovať > Extra ikony_ stiahne najnovšiu verziu sád, ktoré máte nainštalované.

Ak si chcete vytvoriť vlastné, umiestnite svoje ikony do `~/.config/omarchy/icons/<name>/`, jeden súbor pre každú aplikáciu, pomenovaný podľa riadka `Icon=` v súbore `.desktop` danej aplikácie. Súbor končiaci na `.svg` sa zobrazí tak, ako je. Súbor končiaci na `.svg.tpl` sa vykreslí vo farbách témy: tam, kam patrí farba, napíšte `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` alebo `{{ icon_shadow }}`. Predvolená sada v `/usr/share/omarchy/icons/papercraft/` je dobrým miestom, odkiaľ začať. Pridajte `preview.png`, aby sa vaša sada zobrazila vo výbere; bez neho Omarchy vytvorí ukážku z vašich ikon. Ak chcete zmeniť jedinú ikonu predvolenej sady, umiestnite svoju verziu do `~/.config/omarchy/icons/papercraft/`.

### Spustenie a prihlásenie

Obrazovka, ktorá pri spustení počítača žiada heslo k vášmu disku, a prihlasovacia obrazovka tiež nasledujú tému. Zakaždým, keď prepnete témy, preberú jej pozadie, text, akcentovú a červenú farbu, takže neexistuje žiadny samostatný dizajn odomknutia, ktorý by ste si museli vyberať. Na počítačoch Apple Silicon Mac si obrazovka s heslom k disku zachováva predvolený vzhľad Omarchy bez ohľadu na tému.
