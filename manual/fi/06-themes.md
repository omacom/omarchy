# Teemat

Omarchyssa on mukana kaksikymmentäkolme kaunista teemaa. Voit valita niiden välillä Omarchy-valikon kohdasta _Ulkoasu > Teema_ (`Super + Space`) tai siirtyä suoraan teemavalitsimeen näppäinyhdistelmällä `Super + Ctrl + T`.

Jokainen teema tyylittää työpöydän, terminaalin, neovimin, aktiivisuusnäytön (btop), selaimesi (Chrome, Chromium, Edge tai Brave) ja koko Omarchy-kuoren: yläpalkin, valikon, ilmoitukset, OSD:n ja lukitusnäytön. (Obsidianissa sinun on valittava Omarchy-teema manuaalisesti sovelluksen sisältä kohdasta _Ulkoasu > Teemat_).

Teemoilla on joukko taustakuvia, joiden välillä voit valita näppäinyhdistelmällä `Super + Ctrl + W`.

Löydät vielä enemmän teemoja [ylimääräisten teemojen sivulta](https://omarchy.org/themes/) tai voit jopa [tehdä oman teemasi](43-making-your-own-theme.md).

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

### Sovelluskuvakkeet

Sovelluskäynnistimen ja telakan kuvakkeet piirretään teemasi väreissä, joten ne muuttuvat sen mukana. Ne tulevat kuvakejoukosta, jonka valitset teemasta erillään kohdasta _Ulkoasu > Kuvakkeet_, kunkin joukon esikatseluista, samalla tavalla kuin valitset teeman:

- _Papercraft_ on oletus: kaikki asennettuna tuleva, piirrettynä yhteen tyyliin. Logostaan tunnetut sovellukset, kuten Chrome, HEY tai YouTube, säilyttävät muotonsa ja saavat teeman värit.
- _Arcade_ piirtää samat sovellukset 8-bittisenä pikselitaiteena, niin kuin vanha pelikonsoli piirtäisi.
- _Original_ näyttää jokaisen sovelluksen kuvakkeella, jonka sen tekijä on sille antanut.

Voit asentaa jonkun toisen tekemän kuvakejoukon kohdasta _Asenna > Tyyli > Kuvakkeet_ (tai komennolla `omarchy icons install <git url>`), ja poistaa sen uudelleen kohdasta _Poista > Kuvakkeet_. _Päivitä > Lisäkuvakkeet_ hakee asentamiesi joukkojen uusimman version.

Tehdäksesi oman joukkosi laita kuvakkeesi hakemistoon `~/.config/omarchy/icons/<name>/`, yksi tiedosto sovellusta kohden, nimettynä sovelluksen `.desktop`-tiedoston `Icon=`-rivin mukaan. `.svg`-päätteinen tiedosto näytetään sellaisenaan. `.svg.tpl`-päätteinen tiedosto piirretään teeman väreissä: kirjoita `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` tai `{{ icon_shadow }}` kohtaan, johon väri tulee. Oletusjoukko hakemistossa `/usr/share/omarchy/icons/papercraft/` on hyvä lähtökohta. Lisää `preview.png` näyttääksesi joukkosi valitsimessa; ilman sitä Omarchy piirtää esikatselun kuvakkeistasi. Muuttaaksesi oletusjoukon yksittäistä kuvaketta laita oma versiosi hakemistoon `~/.config/omarchy/icons/papercraft/`.

### Avausnäytöt

Teemoilla voi olla myös mukautettu avausmuotoilu, jota käytetään käynnistyksenaikaisessa salauksenpurkuprosessissa. Voit valita sellaisen kohdasta _Ulkoasu > Avaus_. Ne näyttävät tältä:

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
