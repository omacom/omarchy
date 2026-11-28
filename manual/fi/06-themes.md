# Teemat

Omarchyn mukana tulee kaksikymmentäkolme kaunista teemaa. Voit valita niiden välillä Omarchy-valikon kohdasta _Ulkoasu > Teema_ (`Super + Space`) tai siirtyä suoraan teeman valitsimeen näppäinyhdistelmällä `Super + Ctrl + T`.

Jokainen teema tyylittelee työpöydän, terminaalin, neovimin, aktiviteettinäytön (btop), selaimesi (Chrome, Chromium, Edge tai Brave) ja koko Omarchy-kuoren: yläpalkin, valikon, ilmoitukset, OSD:n ja lukitusnäytön. (Obsidianissa sinun on valittava Omarchy-teema manuaalisesti sovelluksen sisältä kohdasta _Ulkoasu > Teemat_).

Teemoissa on joukko taustakuvia, joista voit valita näppäinyhdistelmällä `Super + Ctrl + W`.

Löydät vielä enemmän teemoja [lisäteemojen sivulta](https://omarchy.org/themes/) tai voit jopa [tehdä oman teemasi](43-making-your-own-theme.md).

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

Sovelluskäynnistimen ja telakan kuvakkeet piirretään teemasi väreillä, joten ne muuttuvat sen mukana. Ne tulevat kuvakejoukosta, jonka valitset erillään teemasta kohdasta _Ulkoasu > Kuvakkeet_, kunkin joukon esikatseluista, samalla tavalla kuin valitset teeman:

- _Papercraft_ on oletus: kaikki asennettuna tuleva, piirrettynä yhdellä tyylillä. Logostaan tunnetut sovellukset, kuten Chrome, HEY tai YouTube, säilyttävät muotonsa ja saavat teeman värit.
- _Arcade_ piirtää samat sovellukset 8-bittisenä pikselitaiteena, kuten vanha pelikonsoli tekisi.
- _Original_ näyttää jokaisen sovelluksen kuvakkeella, jonka sen tekijä on sille antanut.

Voit asentaa jonkun toisen tekemän kuvakejoukon kohdasta _Asenna > Tyyli > Kuvakkeet_ (tai komennolla `omarchy icons install <git url>`), ja poistaa sen uudelleen kohdasta _Poista > Kuvakkeet_. _Päivitä > Lisäkuvakkeet_ hakee asentamiesi joukkojen uusimman version.

Tee oma joukkosi laittamalla kuvakkeesi hakemistoon `~/.config/omarchy/icons/<name>/`, yksi tiedosto sovellusta kohden, nimettyinä sovelluksen `.desktop`-tiedoston `Icon=`-rivin mukaan. `.svg`-päätteinen tiedosto näytetään sellaisenaan. `.svg.tpl`-päätteinen tiedosto piirretään teeman väreillä: kirjoita `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` tai `{{ icon_shadow }}` kohtaan, johon väri kuuluu. Oletusjoukko hakemistossa `/usr/share/omarchy/icons/papercraft/` on hyvä lähtökohta. Lisää `preview.png` näyttääksesi joukkosi valitsimessa; ilman sitä Omarchy piirtää esikatselun kuvakkeistasi. Jos haluat muuttaa oletusjoukon yksittäistä kuvaketta, laita oma versiosi hakemistoon `~/.config/omarchy/icons/papercraft/`.

### Käynnistys ja kirjautuminen

Näyttö, joka kysyy aseman salasanaa tietokoneen käynnistyessä, ja kirjautumisnäyttö seuraavat myös teemaa. Joka kerta kun vaihdat teemaa, ne saavat sen taustan, tekstin, korostusvärin ja punaiset värit, joten erillistä lukituksen avaamisen ulkoasua ei tarvitse valita. Apple Silicon -Maceilla aseman salasanaa kysyvä näyttö säilyttää Omarchyn oletusulkoasun teemasta riippumatta.
